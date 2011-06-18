Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA9D6B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 14:12:37 -0400 (EDT)
Date: Sat, 18 Jun 2011 20:12:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [BUG] Invalid return address of mmap() followed by mbind() in multithreaded context
Message-ID: <20110618181232.GI16236@one.firstfloor.org>
References: <4DFB710D.7000902@cslab.ece.ntua.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFB710D.7000902@cslab.ece.ntua.gr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasileios Karakasis <bkk@cslab.ece.ntua.gr>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org

>     for (i = 0; i < NR_ITER; i++) {
>         addr = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE,
>                     MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
>         if (addr == (void *) -1) {
>             assert(0 && "mmap failed");
>         }
>         *addr = 0;
> 
>         err = mbind(addr, PAGE_SIZE, MPOL_BIND, &node, sizeof(node), 0);

mbind() can be only done before the first touch. you're not actually testing 
numa policy.

-andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
