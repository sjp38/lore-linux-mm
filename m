Message-ID: <37FF407F.155D7C64@colorfullife.com>
Date: Sat, 09 Oct 1999 15:17:51 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: locking question: do_mmap(), do_munmap()
References: <Pine.GSO.4.10.9910090903530.14891-100000@weyl.math.psu.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Alexander Viro wrote:
> Moreover, sys_uselib() may do
> interesting things to cloned processes. IMO the right thing would be to
> check for the number of mm users.

I don't know the details of the mm implementation, but if there is only
one user, then down(&mm->mmap_sem) will never sleep, and you loose
nothing by getting the semaphore.

I would prefer a clean implementation, ie always down() before
do_mmap(), and ASSERT_DOWN() macros to enforce this.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
