Message-ID: <37CA73D8.E41F4F5@switchboard.ericsson.se>
Date: Mon, 30 Aug 1999 14:06:48 +0200
From: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
MIME-Version: 1.0
Subject: Re: accel handling
References: <Pine.LNX.4.10.9908291037120.28136-100000@imperial.edgeglobal.com> <14281.23624.70350.745345@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
>
> On Sun, 29 Aug 1999 10:52:29 -0400 (EDT), James Simmons
> <jsimmons@edgeglobal.com> said:
> >  My name is James Simmons and I'm one of the new core designers for the
> > framebuffer devices for linux. Well I have redesigned the framebuffer
> > system and now it takes advantages of accels. Now the problem is that alot
> > of cards can't have simulanteous access to the framebuffer and the accel
> > engine. What I need to a way to put any process to sleep when they access
> > the framebuffer while the accel engine is active. This is for both read
> > and write access. Then once the accel engine is idle wake up the
> > process.
> 
> You really need to have a cooperative locking engine.  Doing this sort
> of thing by playing VM tricks is not acceptable: you are just making the
> driver side of things simpler by placing a whole extra lot of work onto
> the VM, and things will not necessarily go any faster.

What I believe James is talking about here is allowing non-priviledged
processes to access graphics hardware where the graphics card, or even
the whole system, may enter an unrecoverable state if you try to access
the frame buffer while the accel engine is active. (Yes there really
exist such hardware...)

To achieve this you really must physicly prevent the process to access
the framebuffer while the accel engine is active. The question is what
the best way to do this is (and if that way is good enough to bother
doing it...) ?

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
