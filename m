Date: Sat, 13 Jan 2001 20:36:07 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101132353360.11917-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101132034380.2856-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 14 Jan 2001, Marcelo Tosatti wrote:
> 
> As usual, the patch. (it also changes some other things which we discussed
> previously)

Have you tested with big VM's where the memory pressure is due to the VM?

We definitely need a feedback loop to dampen big-VM-footprint stuff. I
hate what you did to "swap_out()" - you removed the dampener, and you also
made it care about mm_users which I find totally non-intuitive.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
