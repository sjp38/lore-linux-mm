Date: Mon, 14 Jun 1999 13:46:02 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: process selection
In-Reply-To: <199906141717.KAA31065@google.engr.sgi.com>
Message-ID: <Pine.LNX.3.96.990614133956.22744D-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sometime earlier, Rik wrote:

> > Could it be an idea to take the 'sleeping time' of each
> > process into account when selecting which process to swap
> > out?  Due to extreme lack of free time, I'm asking what
> > you folks think of it before testing it myself...

On Mon, 14 Jun 1999, Kanoj Sarcar wrote:

> You are right, sleep time is a good heuristic to determine 
> the "swappability" of a process. 

I'm starting to think that going back and benchmarking my vm patches
against 2.1.47 or 66 might prove useful as they used a physical page
scanning with the old LFU technique, but proved remarkably faster than
scanning the virtual addresses space of processes.  Gee, I guess it's time
for forward port the beast again and see what results it gets against
current things.

		-ben (who now has another project for tonight)


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
