Date: Sun, 10 Oct 1999 18:56:38 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101202240.16317-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.9910101852580.520-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Oct 1999, Alexander Viro wrote:

>Manfred, Andrea - please stop it. Yes, it does and yes, it should.

I don't want to use the big kernel lock of course.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
