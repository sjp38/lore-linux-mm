Date: Mon, 30 Oct 2000 10:53:08 +0100
From: G?bor L?n?rt <lgb@viva.uti.hu>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001030105308.B27537@viva.uti.hu>
References: <20001030100215.A26676@viva.uti.hu> <Pine.LNX.4.10.10010300940510.21656-100000@dax.joh.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010300940510.21656-100000@dax.joh.cam.ac.uk>; from jas88@cam.ac.uk on Mon, Oct 30, 2000 at 09:41:33AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2000 at 09:41:33AM +0000, James Sutherland wrote:
> On Mon, 30 Oct 2000, G?bor L?n?rt wrote:
> 
> > > > Policy should be decided user-side, and should prevent the kernel-side
> > > > killer EVER triggering.
> > > > 
> > > 
> > > Only problem is that your user side process will have been pushed out
> > > of memory by netcape and that in this kind of situations it will take
> > > a looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong
> > 
> > Nope. Use mlock().
> > Second it's clear that we should implement a stupid kernel side OOM killer
> > too in case of something goes really wrong, but that killer can be really
> > stupid and constant part of system. In normal cases user space OOM killer
> > should do the job for us ...
> 
> Yes, that's my plan. AIUI, Ingo is going to do the kernel hooks I need,
> I'll do the userspace policy daemon?

Sounds nice, but be carefull with mlock. If your userspace OOM killer
needs something special library, mlockall() lock its reversed memory
area in main memory too while probably that lib is not used by other apps !

IMHO, writing mlock()'ed application is a bad idea IN general, so you must
take care ... Probably try to use assembly for x86 ;-) or simply C programm
without any EXTRA lib ... OK, libc is not critical, since libc should fit
in memory ... almost every reachable program use it of course ...

- Gabor
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
