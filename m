Received: from [212.238.108.69] (helo=mirkwood.nl.linux.org)
	by post.mail.nl.demon.net with esmtp (Exim 2.02 #1)
	id 10su0M-0007Om-00
	for linux-mm@kvack.org; Sat, 12 Jun 1999 20:03:53 +0000
Received: from localhost (riel@localhost)
	by mirkwood.nl.linux.org (8.9.0/8.9.3) with ESMTP id WAA02858
	for <linux-mm@kvack.org>; Sat, 12 Jun 1999 22:00:31 +0200
Date: Sat, 12 Jun 1999 22:00:30 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: process selection
Message-ID: <Pine.LNX.4.03.9906122156290.534-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

in mm/vmscan.c::swap_out() we select the process from
which to swap out pages. In my experience, this selection
is done on a somewhat random basis.

The way things are running on my system right now, X
and Netscape are swapped out while a stopped setiathome
(been sleeping for over an hour) remains in memory.

Could it be an idea to take the 'sleeping time' of each
process into account when selecting which process to swap
out?  Due to extreme lack of free time, I'm asking what
you folks think of it before testing it myself...

cheers,

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
