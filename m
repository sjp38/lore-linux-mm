Date: Mon, 30 Oct 2000 09:41:33 +0000 (GMT)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001030100215.A26676@viva.uti.hu>
Message-ID: <Pine.LNX.4.10.10010300940510.21656-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: G?bor L?n?rt <lgb@viva.uti.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Oct 2000, G?bor L?n?rt wrote:

> > > Policy should be decided user-side, and should prevent the kernel-side
> > > killer EVER triggering.
> > > 
> > 
> > Only problem is that your user side process will have been pushed out
> > of memory by netcape and that in this kind of situations it will take
> > a looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong
> 
> Nope. Use mlock().
> Second it's clear that we should implement a stupid kernel side OOM killer
> too in case of something goes really wrong, but that killer can be really
> stupid and constant part of system. In normal cases user space OOM killer
> should do the job for us ...

Yes, that's my plan. AIUI, Ingo is going to do the kernel hooks I need,
I'll do the userspace policy daemon?


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
