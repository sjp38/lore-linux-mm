Date: Sun, 14 Jan 2001 01:50:08 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.10.10101132034380.2856-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101140136200.11917-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2001, Linus Torvalds wrote:
> 
> On Sun, 14 Jan 2001, Marcelo Tosatti wrote:
> > 
> > As usual, the patch. (it also changes some other things which we discussed
> > previously)
> 
> Have you tested with big VM's where the memory pressure is due to the VM?
> We definitely need a feedback loop to dampen big-VM-footprint stuff. 

No, but I can imagine. I'll take a look into the feedback loop thing
Monday.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
