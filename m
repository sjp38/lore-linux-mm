Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA26462
	for <linux-mm@kvack.org>; Tue, 30 Mar 1999 04:34:31 -0500
Subject: [Conrad Sanderson <conrad@hive.me.gu.edu.au>] a plea for standard bigphysarea in Linux MM
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Mar 1999 00:55:42 -0600
Message-ID: <m1d81rpitt.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

------- Start of forwarded message -------
Date: Tue, 30 Mar 1999 14:50:19 -0500 (EST)
From: Conrad Sanderson <conrad@hive.me.gu.edu.au>
To: ebiederm+eric@ccr.net
Subject: a plea for standard bigphysarea in Linux MM 
Message-ID: <Pine.LNX.4.04.9903301449470.24322-100000@hive.me.gu.edu.au>


Hi.  As an avid Linux user and a PhD student, I am writing this letter 
as a plea to "The Linux MM core team" and other developers to put
standard bigphysarea functionality into the Linux kernel.

For many years (since 1.3.7x) we have been relying on the bigphysarea
patch to allow us to use devices such as the Matrox Meteor frame grabber.
Uses of Linux for video capture is increasing rapidly, and it would be of
great help to the users of Linux (and hence Linux popularity) to have the
meteor driver as a standard part of the Linux kernel - however, this
cannot occur because it relies on the bigphysarea patch.  Linux needs
this as standard functionality - the *BSD folks have this in their kernel.

It is also annoying to have to make sure the bigphysarea patch applies and
works correctly with the newest kernel.  For example, the patch does not
work on 2.2.x SMP machines.  Most recently, I've corrected a problem with
the meteor driver not working with the 2.2.3 kernel because of a slight
change in the way the kernel handles modules - it would be nice to
have this work acknowledged as part of the kernel proper.

I rely on the Matrox Meteor board for my PhD work, and while the current
support for it under Linux is sufficient for my purposes, things can be
better if Linux supported more hardware, out of the box, which would be
A Good Thing (tm).


Conrad Sanderson - Microelectronic Signal Processing Laboratory
Griffith University, Queensland, Australia
http://hive.me.gu.edu.au/~cam/                    <--- lab webcam
http://wave.me.gu.edu.au/~csand/md/0soft.html  


------- End of forwarded message -------
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
