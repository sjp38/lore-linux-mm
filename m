Date: Sun, 13 Jun 1999 03:17:01 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: process selection
In-Reply-To: <Pine.LNX.4.03.9906122156290.534-100000@mirkwood.nl.linux.org>
Message-ID: <Pine.LNX.4.10.9906130313510.7016-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 12 Jun 1999, Rik van Riel wrote:

>Could it be an idea to take the 'sleeping time' of each
>process into account when selecting which process to swap
>out?  Due to extreme lack of free time, I'm asking what

The CPUs set the "accessed" bit in hardware, and that should be enough to
do proper aging. If setiathome is all in RAM it means it gets touched more
fast than netscape.

BTW, I suggest you to try out:

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.2.9_andrea-VM4.gz

and see if the swapout behaviour changes.

(I have just ready a VM5 too but since there are not critical issues in
VM5 I am waiting a bit more before releasing it)

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
