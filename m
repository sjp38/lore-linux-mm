Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA03376
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 10:06:53 -0500
Message-ID: <36503F86.FC08594@varel.bg>
Date: Mon, 16 Nov 1998 17:06:46 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: Re: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home> <364FE29E.2CF14EEA@varel.bg> <wd8emr3yfeu.fsf@parate.irisa.fr>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "David Mentr\\'e" <David.Mentre@irisa.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Mentr\'e wrote:
> 
> Petko Manolov <petkan@varel.bg> writes:
> 
> > Also we have less TLB misses when the kernel is in 4M page.
> 
> The kernel is already using 4M pages (for a long time now).

Yes, i know that. I took a look at 
linux/arch/i386/mm/init.c - paging_init().
Yes we rise PSE bit in cr4 but don't rise the PS bit in
the pade directory entry for the kernel - which means the
kernel is in 4K pages.

regards
-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
