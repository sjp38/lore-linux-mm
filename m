Date: Wed, 2 Jul 2003 05:08:18 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030702030818.GX3040@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <Pine.LNX.4.53.0307012236310.16265@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0307012236310.16265@skynet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 01, 2003 at 10:46:31PM +0100, Mel Gorman wrote:
> On Tue, 1 Jul 2003, Andrea Arcangeli wrote:
> 
> > On Tue, Jul 01, 2003 at 02:39:47AM +0100, Mel Gorman wrote:
> > >    Reverse Page Table Mapping
> > >    ==========================
> > >
> > > <rmap stuff snipped>
> >
> > you mention only the positive things, and never the fact that's the most
> > hurting piece of kernel code in terms of performance and smp scalability
> > until you actually have to swapout or pageout.
> >
> 
> You're right, I was commenting only on the positive side of things. I
> didn't pay close enough attention to the development of the 2.5 series so
> right now I can only comment on whats there and only to a small extent on
> what it means or why it might be a bad thing. Here goes a more balanced
> view...

never mind, I think for your talk that was just perfect ;) Though I
think your last paragraph addition on the rmap thing is fair enough.

I only abused your very nice and detailed list of features, to comment
on some that IMHO had some drawback (and for some [not rmap] I don't
recall any discussion about their drawbacks on l-k ever, that's why I
answered).

thanks,

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
