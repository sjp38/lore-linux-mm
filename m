Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA22654
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 21:28:55 -0500
Date: Wed, 20 Jan 1999 01:46:50 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: arca-vm-26
Message-ID: <Pine.LNX.3.96.990120011948.7203C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Nimrod Zimerman <zimerman@deskmail.com>, John Alvord <jalvo@cloud9.net>, "Stephen C. Tweedie" <sct@redhat.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Ben McCann <bmccann@indusriver.com>
List-ID: <linux-mm.kvack.org>

I've put out an arca-vm-26. The differences between arca-vm-25 and -26 are
that I don't do aging on the swap cache anymore (this should allow
shrink_mmap to decrease the size of the cache at least more easily also on
low memory systems), and a modifyed mem trashing heuristic. It fix also a
potential swap deadlock (triggerable only by the shm memory I think).

The patch can be downloaded from:

ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre8testing-arca-VM-26.gz

If you try it please feedback as usual ;). thanks.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
