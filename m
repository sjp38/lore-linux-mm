Date: Thu, 30 Sep 1999 12:05:24 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.3.96.990930110519.3724A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9909301144170.4106-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Here is another question since its very expensive putting another process 
> > to sleep. If the process owns both the accel engine and framebuffer then I
> > should be able to put the process to sleep while the accel engine is
> > running? Since the process is asleep it can't acces the framebuffer but
> > the accel engine is still running on the card.    
> 
> Oh gawd...  How much does the kernel know about the accelerator?

Its a memory region thats mmap to userspace. Thats all it knows. By the
way what I suggested above would work.

> Something to consider is that the 'right' solution might be to make the
> kernel pass console handling to a user task -- have you ever considered
> that?

Uhm. No. I don't think that will work for what I want.

> >   These are mmapped regions. So locking out the kernel will not help. You
> > have to prevent userland from accessing the memory region to prevent the
> > machine from locking. 
> 
> And the performance-correct way to do this is with a cooperative lock that
> is *not part* of the mmap'd region. 

That still doesn't prevent a rogue aplication from locking the machine on
purpose. A application could just ignore the locks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
