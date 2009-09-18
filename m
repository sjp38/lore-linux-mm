Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 492EF6B00F2
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 15:37:30 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n8IJbSZ7012235
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 12:37:28 -0700
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by spaceape14.eur.corp.google.com with ESMTP id n8IJahDO019999
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 12:37:25 -0700
Received: by pxi4 with SMTP id 4so1027838pxi.23
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 12:37:24 -0700 (PDT)
Date: Fri, 18 Sep 2009 12:37:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] remove duplicate asm/mman.h files
In-Reply-To: <200909181848.42192.arnd@arndb.de>
Message-ID: <alpine.DEB.1.00.0909181236190.27556@chino.kir.corp.google.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <20090917174616.f64123fb.akpm@linux-foundation.org> <200909181719.47240.arnd@arndb.de> <200909181848.42192.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009, Arnd Bergmann wrote:

> diff --git a/arch/ia64/include/asm/mman.h b/arch/ia64/include/asm/mman.h
> index cf55884..4459028 100644
> --- a/arch/ia64/include/asm/mman.h
> +++ b/arch/ia64/include/asm/mman.h
> @@ -8,21 +8,9 @@
>   *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
>   */
>  
> -#include <asm-generic/mman-common.h>
> +#include <asm-generic/mman.h>
>  
> -#define MAP_GROWSDOWN	0x00100		/* stack-like segment */
> -#define MAP_GROWSUP	0x00200		/* register stack-like segment */
> -#define MAP_DENYWRITE	0x00800		/* ETXTBSY */
> -#define MAP_EXECUTABLE	0x01000		/* mark it as an executable */
> -#define MAP_LOCKED	0x02000		/* pages are locked */
> -#define MAP_NORESERVE	0x04000		/* don't check for reservations */
> -#define MAP_POPULATE	0x08000		/* populate (prefault) pagetables */
> -#define MAP_NONBLOCK	0x10000		/* do not block on IO */
> -#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
> -#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> -
> -#define MCL_CURRENT	1		/* lock all current mappings */
> -#define MCL_FUTURE	2		/* lock all future mappings */
> +#define MAP_GROWSUP	0x0200		/* register stack-like segment */
>  
>  #ifdef __KERNEL__
>  #ifndef __ASSEMBLY__

ia64 doesn't use MAP_GROWSUP, so it's probably not necessary to carry it 
along with your cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
