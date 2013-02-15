Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E0BBA6B0088
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 17:46:30 -0500 (EST)
Date: Fri, 15 Feb 2013 14:46:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ia64: rename cache_show to topology_cache_show
Message-Id: <20130215144629.be18bae9.akpm@linux-foundation.org>
In-Reply-To: <1360931904-5720-1-git-send-email-mhocko@suse.cz>
References: <511e236a.o0ibbB2U8xMoURgd%fengguang.wu@intel.com>
	<1360931904-5720-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Glauber Costa <glommer@parallels.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Fri, 15 Feb 2013 13:38:24 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Fenguang Wu has reported the following compile time issue
> arch/ia64/kernel/topology.c:278:16: error: conflicting types for 'cache_show'
> include/linux/slab.h:224:5: note: previous declaration of 'cache_show' was here
> 
> which has been introduced by 749c5415 (memcg: aggregate memcg cache
> values in slabinfo). Let's rename ia64 local function to prevent from
> the name conflict.

Confused.  Tony fixed this ages ago?

: commit 4fafc8c21487f6b5259d462e9bee98661a02390d
: Author: Tony Luck <tony.luck@intel.com>
: Date:   Wed Nov 7 15:51:04 2012 -0800
: 
:     [IA64] Resolve name space collision for cache_show()
:     
:     We have a local static function named rather generically
:     "cache_show()". Changes in progress in the slab code want
:     to use this same name globally - so they are adding their
:     declaration to <linux/slab.h> which then causes the compiler
:     to choke with:
:     
:     arch/ia64/kernel/topology.c:278: error: conflicting types for 'cache_show'
:     
:     Fix by adding an "ia64_" prefix to our local function.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
