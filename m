Message-Id: <20070614215817.389524447@chello.nl>
Date: Thu, 14 Jun 2007 23:58:17 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/17] per device dirty throttling -v7
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Latest version of the per bdi dirty throttling patches.

Most of the changes since last time are little cleanups and more
detail in the split out of the floating proportion into their
own little lib.

Patches are against 2.6.22-rc4-mm2

A rollup of all this against 2.6.21 is available here:
  http://programming.kicks-ass.net/kernel-patches/balance_dirty_pages/2.6.21-per_bdi_dirty_pages.patch

This patch-set passes the starve an USB stick test..
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
