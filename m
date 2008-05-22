Date: Thu, 22 May 2008 21:58:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
In-Reply-To: <20080522084736.GC31727@one.firstfloor.org>
Message-ID: <alpine.LFD.1.10.0805222157300.3295@apollo.tec.linutronix.de>
References: <20080521113028.GA24632@xs4all.net> <48341A57.1030505@redhat.com> <20080522084736.GC31727@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Glauber Costa <gcosta@redhat.com>, Miquel van Smoorenburg <miquels@cistron.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 May 2008, Andi Kleen wrote:
> On Wed, May 21, 2008 at 09:49:27AM -0300, Glauber Costa wrote:
> > probably andi has a better idea on why it was added, since it used to 
> > live in his tree?
> 
> d_a_c() tries a couple of zones, and running the oom killer for each
> is inconvenient. Especially for the 16MB DMA zone which is unlikely
> to be cleared by the OOM killer anyways because normal user applications
> don't put pages in there. There was a real report with some problems
> in this area.

Can you give some pointers please ?

Thanks,
	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
