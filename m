Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA09198
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 04:30:36 -0500
Message-ID: <36514231.714623B6@varel.bg>
Date: Tue, 17 Nov 1998 11:30:25 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: Re: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home> <364FE29E.2CF14EEA@varel.bg> <wd8emr3yfeu.fsf@parate.irisa.fr> <36503F86.FC08594@varel.bg> <wd8zp9rwtc7.fsf@parate.irisa.fr> <365057C8.50B31465@varel.bg> <wd8u2zzwlgb.fsf@parate.irisa.fr>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "David Mentr\\'e" <David.Mentre@irisa.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Mentr\'e wrote:
> 
> To much brute force. :)

Nope, i have already my own 2-3 drivers as modules. So the only thing
i had to do was:
	__asm__ __volatile__ (
	"movl	%%cr3, %0\n\t"
	:"=q" (__cr3));
	for( i=0; i<1024; i++ )
		printk("0x%x, ", (int)*(__cr3+i) );

in the init_module(). 

> BTW, I think I've found when the PS bit is set. In fact, I you may have
> overlooked arch/i386/mm/init.c. Around line 325, you have :
... 
>             __pe = _KERNPG_TABLE + _PAGE_4M + __pa(address); <----
... 
> Is it right ? Or you where looking at another page directory ? (I'm far
> from an expert in both kernel and i386 asm)

Yes, you catch it. I realy overlooked in my first glance while
i was looking for other thing.
 
> No. It's interesting to know how things are done. And while trying to
> explain this, I'm learning the Linux kernel. :)

;-) Me too. I'll keep on looking at mm.
As Linus said it can be a bitch ;-))

regards
-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
