Date: Sat, 9 Oct 1999 18:01:27 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910090903530.14891-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.10.9910091758380.5808-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Oct 1999, Alexander Viro wrote:

>do_munmap() doesn't need the big lock. do_mmap() callers should grab

Look the swapout path. Without the big kernel lock you'll free vmas under
swap_out().

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/pending-2.3.x/munmap-lock-1

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
