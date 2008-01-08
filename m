Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 13] oom deadlock fixes # try 2
Message-Id: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:31 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This introduces the memdie_jiffies and MEMDIE_DELAY plus some minor
improvement that probably isn't really necessary (but I found tasks looping in
fork() allocating pagetables with GFP_REPEAT and lots of tasks in
congestion_wait so I thought to improve those two bits too). I can still
reproduce one deadlock in a certain condition with this patchset while no
deadlock was happening with the previous one before memdie_jiffies for
whatever reason. I was trying to fix that last deadlock before submission but
because of the talks on linux-mm on what I already got implemented and working
fine, I'll submit this right now (the new deadlock is likely unrelated to
these changes). I'm wondering if perhaps it's related to having reintroduced
the PF_EXITING check but in theory it shouldn't because the PF_EXITING check
should go off after 60sec when we start skipping over the TIF_MEMDIE tasks.

I written the last two patches after checking stack traces while debugging the
new deadlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
