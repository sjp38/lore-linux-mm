Received: from ledzep.cray.com (ledzep.cray.com [137.38.226.97]) by timbuk.cray.com (8.8.8/CRI-gate-news-1.3) with ESMTP id SAA13033 for <linux-mm@kvack.org>; Mon, 10 Apr 2000 18:41:49 -0500 (CDT)
Received: from ironwood-e185.americas.sgi.com (ironwood.cray.com [128.162.185.212]) by ledzep.cray.com (SGI-SGI-8.9.3/craymail-smart-nospam1.0) with ESMTP id SAA80311 for <linux-mm@kvack.org>; Mon, 10 Apr 2000 18:41:49 -0500 (CDT)
Received: from fsgi344.americas.sgi.com (fsgi344.americas.sgi.com [128.162.184.15]) by ironwood-e185.americas.sgi.com (8.8.4/SGI-ironwood-e1.4) with ESMTP id SAA25634 for <linux-mm@kvack.org>; Mon, 10 Apr 2000 18:41:42 -0500 (CDT)
From: Jim Mostek <mostek@sgi.com>
Message-Id: <200004102341.SAA49583@fsgi344.americas.sgi.com>
Subject: lock_page/LockPage/UnlockPage
Date: Mon, 10 Apr 2000 18:41:47 -0500 (CDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just a minor nit, but it seems to me that if UnlockPage wakes up
sleepers, LockPage should go to sleep.

The interface:

	LockPage
	UnlockPage
	TryLockPage(page)

should all be bit operators and then:

	lock_page
	unlock_page
	trylock_page

should be the ones that actually sleep/wakeup.


Not a big deal, but ....

Jim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
