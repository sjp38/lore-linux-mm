Date: Mon, 7 Feb 2005 15:53:26 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [barry@disus.com: RE: FW: OOM Killer problem since linux 2.6.8.1]
Message-ID: <20050207175326.GB5378@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Nick Piggin <piggin@cyberone.com.au>, andrea@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

FYI.

Success report on Andrea's OOM killer fixes!

----- Forwarded message from barry <barry@disus.com> -----

From: barry <barry@disus.com>
Date: Mon, 7 Feb 2005 14:29:56 -0500
To: 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>
Cc: andrea@suse.de
Subject: RE: FW: OOM Killer problem since linux 2.6.8.1

Hi Marcelo,

It has been a long time since we last communicated. We worked on my
problem of spurious OOM when there was plenty of swap space available
last September/October. 

I am just writing to tell you that the patch set below (in the
2.6.11-rc3 kernel) seems to have fixed the OOM problem that has been
plaguing me since 2.6.8.1..... (IE, I have been manually inserting a fix
for every kernel since then...)

Please thank Andrea for me.....

[PATCH] mm: fix several oom killer bugs

Fix several oom killer bugs, most important avoid spurious oom kills
badness algorithm tweaked by Thomas Gleixner to deal with fork bombs

This is the core of the oom-killer fixes I developed partly taking
the idea from Thomas's patches of getting feedback from the exit
path, plus I moved the oom killer into page_alloc.c as it should to
be able to check the watermarks before killing more stuff.  This
also tweaks the badness to take thread bombs more into account (that
change to badness is from Thomas, from my part I'd rather rewrite
badness from scratch instead, but that's an orthgonal issue ;).
With this applied the oom killer is very sane, no more 5 sec waits
and suprious oom kills.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Barry Silverman   Phone: 416-368-7677 x234
Disus Inc.        Cell:  416-407-8091
110 Spadina #705  Email: barry@disus.com
Toronto, Ontario M5V 2K4
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
