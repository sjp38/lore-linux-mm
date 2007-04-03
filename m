Message-Id: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
Date: Tue, 03 Apr 2007 16:40:47 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 0/6] per device dirty throttling -V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi,

A new version of the per BDI dirty page throttle patches.

This is against 2.6.21-rc5-mm4 with:

 per-backing_dev-dirty-and-writeback-page-accounting.patch

reverted.

These patches should solve several problem we current have in this area,
namely:

 - mutual interference starvation (for any number of BDIs), and
 - deadlocks with stacked BDIs (loop and FUSE).

Dave, would you mind testing if the XFS umount problem is still present?
I could not reproduce it with this code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
