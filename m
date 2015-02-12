Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B00E56B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 03:54:37 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id eu11so10022639pac.10
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 00:54:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r2si4174673pds.131.2015.02.12.00.54.36
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 00:54:36 -0800 (PST)
Date: Thu, 12 Feb 2015 16:54:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH aa] userfaultfd: double_down_read() can be static
Message-ID: <20150212085404.GA52934@snb>
References: <201502121644.mekdzvbV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502121644.mekdzvbV%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mm/userfaultfd.c:48:6: sparse: symbol 'double_down_read' was not declared. Should it be static?
mm/userfaultfd.c:67:6: sparse: symbol 'double_up_read' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 userfaultfd.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d1e89ef..88b2650 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -45,7 +45,7 @@ void double_pt_unlock(spinlock_t *ptl1,
 		spin_unlock(ptl2);
 }
 
-void double_down_read(struct rw_semaphore *mm1,
+static void double_down_read(struct rw_semaphore *mm1,
 		      struct rw_semaphore *mm2)
 	__acquires(mm1)
 	__acquires(mm2)
@@ -64,7 +64,7 @@ void double_down_read(struct rw_semaphore *mm1,
 		down_read_nested(mm2, SINGLE_DEPTH_NESTING);
 }
 
-void double_up_read(struct rw_semaphore *mm1,
+static void double_up_read(struct rw_semaphore *mm1,
 		    struct rw_semaphore *mm2)
 	__releases(mm1)
 	__releases(mm2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
