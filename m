Date: Tue, 15 Aug 2000 03:26:51 -0400
Message-Id: <200008150726.e7F7QpO32375@tbird.iworld.com>
Content-Type: text/plain
Content-Disposition: inline
Mime-Version: 1.0
From: Rares Marian <rmarian@linuxstart.com>
Subject: 2.4.0-t4-vmpatch rocks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just a note: this has to go into the official release.  I'll have more to say later today, but i'll leave with these two anecdotes:

1. 2.4.0-test4 caused synaesthesia-xmms to perform very poorly.

The patch fixed it.  The comparison is striking.  Not: rebuild modules, my sb32awe modules failed after the patch, so I had to rebuild them.

2. I used blackbox because mozilla and netscape performance as well as interactions with gnome drove me insane but I need 2.4.0-test4 for my TV input card

Normally, it would take between 30 and 45 seconds under 2.2.15 and 2.4.0-test4 unpatched to just start Helix.   While in blackbox I decided to test the patch.  I was able to shut down X, desktopcfg to GNOME, and get Helix 1.2 Preview + themes + several panel applets up in not more than 30 o seconds or so.  It's at least 2-3x faster.

See below:

<Tyrant> [02:32] *** rares (rares@wtrb-sh1-port77.snet.net) Quit ([x]chat)
<Tyrant> [02:32] <raptor> you need linux for that
<Tyrant> [02:32] <raptor> duh
<Tyrant> [02:32] <meff> gagh
<Tyrant> [02:32] <jdube> I'll kill you
<Tyrant> [02:32] <raptor> but it should port easily
<Tyrant> [02:32] <meff> openbsd is an awefull desktop os
<Tyrant> [02:32] <Skapare> Mankar: no ... was not me
<Tyrant> [02:32] <Skapare> meff: you noticed
<Tyrant> [02:32] <meff> freebsd is cool
<Tyrant> [02:33] <raptor> Manker is a Wanker on my speech synthesis 
<Tyrant> [02:33] <meff> Skapare: yah.. hehe.. openbsd sucks for desktop
<Tyrant> [02:33] <Skapare> meff: it also won't work for my tunneling project
<Tyrant> [02:33] <jdube> meff: actually openbsd rocks my world.
<Tyrant> [02:33] <Skapare> meff: openbsd doesn't let me set my video mode
<Tyrant> [02:33] <meff> good you keep on thinking that :)
<Tyrant> [02:33] <meff> Skapare: not surprising..
<Tyrant> [02:33] <meff> Skapare: not surprising..
<Tyrant> [02:33] <raptor> MacOs rocks you
<Tyrant> [02:33] <raptor> heh
<Tyrant> [02:33] <Skapare> meff: although it does have a text mode, I can't change it to the mode I like
<Tyrant> [02:33] *** rares (rares@wtrb-sh1-port77.snet.net) has joined #slashdot
<Tyrant> ----------- end -------------

It's up to Linus if he wants it in.  If it doesn't go in the official release I'll hack it in myself.  And I'm not all that experienced.

Note: Rik van Riel released the vmpatch a couple days ago plus a 1 line correction.  People can find the full patch here.

http://www.surriel.com/patches/2.4.0-t4-vmpatch

This was on an Athlon 500 w/ 64MB RAM UltraDMA66 20G IDE drive Gigabyte (hdparm 3.9 fails :/ though in boot up Mdk 7.0 says it's ok.)

Thanks to Free Unices, we've crawled back UP to 70's.
----------------------
Do you do Linux? :) 
Get your FREE @linuxstart.com email address at: http://www.linuxstart.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
