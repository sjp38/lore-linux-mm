From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.1425.683604.262468@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:43:13 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.LNX.4.10.9910101900210.520-100000@alpha.random>
References: <Pine.GSO.4.10.9910101219370.16317-100000@weyl.math.psu.edu>
	<Pine.LNX.4.10.9910101900210.520-100000@alpha.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alexander Viro <viro@math.psu.edu>, Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Oct 1999 19:12:58 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> The other option is to make the mmap semaphore recursive checking that GFP
> is not called in the middle of a vma change. I don't like this one it sound
> not robust as the spinlock way to me (see below).

Doesn't work, because you can still have a process which takes one mmap
semaphore and then attempts to take a different one inside the swapper
as the result of a memory allocation.  As soon as you have two processes
doing that to each other's semaphores, you still have a deadlock.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
