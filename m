Received: from CONVERSION-DAEMON.jhuml3.jhu.edu by jhuml3.jhu.edu
 (PMDF V6.0-24 #47345) id <0G3200L01GYCRI@jhuml3.jhu.edu> for
 linux-mm@kvack.org; Thu, 26 Oct 2000 22:15:49 -0400 (EDT)
Received: from aa.eps.jhu.edu (aa.eps.jhu.edu [128.220.24.92])
 by jhuml3.jhu.edu (PMDF V6.0-24 #47345)
 with ESMTP id <0G3200L0UGYCQS@jhuml3.jhu.edu> for linux-mm@kvack.org; Thu,
 26 Oct 2000 22:15:48 -0400 (EDT)
Date: Thu, 26 Oct 2000 22:14:23 -0400 (EDT)
From: afei@jhu.edu
Subject: Re: page fault.
In-reply-to: <Pine.LNX.4.21.0010261752510.15696-100000@duckman.distro.conectiva>
Message-id: <Pine.GSO.4.05.10010262213310.16485-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: afei@jhu.edu, "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You are right. I misunderstood what he wants. To know when the pagefault
occured, one simply can work on the pagefault handler. It is trivial.

Fei

On Thu, 26 Oct 2000, Rik van Riel wrote:

> On Thu, 26 Oct 2000 afei@jhu.edu wrote:
> > On Fri, 27 Oct 2000, M.Jagadish Kumar wrote:
> > 
> > > Is there any way in which i can know when the pagefault occured,
> > > i mean at what instruction of my program execution.
> > > Does OS provide any support. This would help me to improve my program.
> 
> > The way I use is to use oops message and System.map to locate
> > the subroutine where the oops occured. To find the exact line
> > where the oops occured, you need to either check assemble code
> > or use more complicated kernel debug technique. I think Rik
> > covered some in his kernel debug slides.
> 
> You're confusing issues. A pagefault has NOTHING to do
> with an oops...
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/		http://www.surriel.com/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
