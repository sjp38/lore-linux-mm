Date: Tue, 11 Apr 2000 14:47:14 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: lock_page/LockPage/UnlockPage
In-Reply-To: <200004102341.SAA49583@fsgi344.americas.sgi.com>
Message-ID: <Pine.LNX.4.21.0004111442180.25673-100000@maclaurin.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jim Mostek <mostek@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Apr 2000, Jim Mostek wrote:

>Just a minor nit, but it seems to me that if UnlockPage wakes up
>sleepers, LockPage should go to sleep.

LockPage can be executed only in places where you know the page to be
unlocked. You could use it for example to set the PG_locked bitflag before
adding the page to the hashtable.

LockPage could be implemented with:

	if (test_and_set_bit(PG_locked, &page->flags)
		BUG();

And TryLockPage() should really not be changed since by design it's only a
bitflag operator and it's right it to remains so.

Only UnlockPage() should be called unlock_page() if you care about style.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
