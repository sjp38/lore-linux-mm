Date: Wed, 11 Oct 2000 01:06:11 +0100 (BST)
From: Chris Evans <chris@scary.beasts.org>
Subject: 2.4.0test9 vm: disappointing streaming i/o under load
In-Reply-To: <Pine.LNX.4.21.0010101738110.11122-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010110056230.7853-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Finally got round to checking out 2.4.0test9.

Unfortunately, 2.4.0test9 exhibits poor streaming i/o performance when
under a bit of memory pressure.

The test is this: boot with mem=32M, log onto GNOME and start xmms playing
a big .wav ripped from a CD (this requires 100-200k read i/o per second).

Then, I start then kill netscape. I then started a find / and started
gnumeric firing up at the same time.

Results
=======

2.2 RH7.0: the music skipped maybe twice briefly during the test.

2.4.0test9: music stuttered repeatedly while netscape started. Worse, when
firing up gnumeric with the find / on the go, there were big pauses in
sound output. On pause was over 5 seconds!!!


So not so hot.

Could this perhaps be related to the drop_behind magic penalizing
streaming i/o pages too much? Perhaps the greater ago on the i/o pages
means that when there is a little memory pressure, they are getting thrown
out the page cache before the app (xmms) gets a chance to use them!

Might it be useful for me to try pre10-1, I note it has more "balancing
fixes".

Cheers
Chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
