Date: Sun, 20 Jun 1999 18:45:48 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: 2.2.10_andrea-VM8
In-Reply-To: <Pine.LNX.4.10.9906200150510.7689-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9906201839270.1067-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Juergen Vollmer <vollmer@cocolab.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Jun 1999, Andrea Arcangeli wrote:

>Juergen, could you try if you can still oom-kill the machine with
>2.2.10_andrea-VM7?

If you didn't tried VM7 yet, please try directly VM8:

	ftp://e-mind.com/pub/andrea/kernel-patches/2.2.10_andrea-VM8.gz

I removed the simple oom killer in it since I noticed that the bigger task
may uninterruptible sleep in kernel mode... while we are sure that we'll
be able to kill a faulting task. VM8 still avoids init to be killed (or to
be remapped with bad pages). If it will work fine I'll provide also a
little patch against 2.2.10 clean for kernel inclusion.

Thanks.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
