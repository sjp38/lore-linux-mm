Date: Wed, 9 Jul 2003 08:42:53 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more)
 support
In-Reply-To: <55580000.1057727591@[10.10.2.4]>
Message-ID: <Pine.LNX.4.44.0307090841410.4997-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jul 2003, Martin J. Bligh wrote:

> > i'm pleased to announce the first public release of the "4GB/4GB VM split"
> > patch, for the 2.5.74 Linux kernel:
> > 
> >    http://redhat.com/~mingo/4g-patches/4g-2.5.74-F8
> 
> I presume this was for -bk something as it applies clean to -bk6, but
> not virgin.

indeed - it's for BK-curr.

> However, it crashes before console_init on NUMA ;-( I'll shove early
> printk in there later.

wli found the bug meanwhile - i'll do a new patch later today.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
