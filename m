Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A6B186B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:09:13 -0400 (EDT)
Date: Wed, 27 Mar 2013 14:09:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 01/11] mm: frontswap: lazy initialization to allow
 tmem backends to build/run as modules
Message-Id: <20130327140911.b86641fb57070985cba4e457@linux-foundation.org>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>

On Wed,  6 Mar 2013 16:51:20 +0800 Bob Liu <lliubbo@gmail.com> wrote:

> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> built/loaded as modules rather than built-in and enabled by a boot parameter,
> this patch provides "lazy initialization", allowing backends to register to
> frontswap even after swapon was run. Before a backend registers all calls
> to init are recorded and the creation of tmem_pools delayed until a backend
> registers or until a frontswap store is attempted.

Your version of this patch series differed from Konrad's "[PATCH v3]
Make frontswap+cleancache and its friend be modularized." significantly.

In particular, Konrad had four additional patches:

Subject: frontswap: remove the check for frontswap_enabled
Subject: frontswap: Use static_key instead of frontswap_enabled and frontswap_ops
Subject: cleancache: Remove the check for cleancache_enabled.
Subject: cleancache: Use static_key instead of cleancache_ops and cleancache_enabled.

How come?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
