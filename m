Date: Mon, 14 Jun 1999 21:26:36 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: process selection
In-Reply-To: <Pine.LNX.3.96.990614133956.22744D-100000@mole.spellcast.com>
Message-ID: <Pine.LNX.4.03.9906142120170.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 1999, Benjamin C.R. LaHaise wrote:

> I'm starting to think that going back and benchmarking my vm
> patches against 2.1.47 or 66 might prove useful as they used a
> physical page scanning with the old LFU technique,

I don't think this will be worth the effort. Firstly, physical
scanning is disastrous for effective I/O clustering (once we
hit swap, disk seek is _far_ more important than CPU time) and
LFU just isn't as good as LRU.

If you want a real improvement, you should port over some of
the (very nice) FreeBSD algorithms for I/O clustering and
assorted stuff.

As for including the sleep time in VMA selection. I think we
should just give an added 'bonus' if the process to which the
VMA belongs has been sleeping for a long time. If it's been
sleeping for a very long time (> 15 minutes) and the VMA is
not shared, we might even consider swapping the whole thing
out in one (physically contiguous for easy reading) swoop.


regards,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
