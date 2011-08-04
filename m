Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 414046B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:26:59 -0400 (EDT)
Date: Thu, 4 Aug 2011 09:26:51 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] sparse: using kzalloc to clean up code
Message-ID: <20110804072651.GD21516@cmpxchg.org>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 04, 2011 at 11:09:49AM +0800, Bob Liu wrote:
> This patch using kzalloc to clean up sparse_index_alloc() and
> __GFP_ZERO to clean up __kmalloc_section_memmap().
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
