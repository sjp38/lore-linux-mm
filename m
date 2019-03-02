Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18944C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 15:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AAD120838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 15:12:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AAD120838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D33838E0003; Sat,  2 Mar 2019 10:12:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2EF8E0001; Sat,  2 Mar 2019 10:12:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAB2C8E0003; Sat,  2 Mar 2019 10:12:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9026B8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 10:12:19 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k1so754211qta.2
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 07:12:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=sjSqMIoEjtI7SM2/h9YXuH0OJaBmS4bgBeYZjNAxlxg=;
        b=IcBUQA60RpRm4t39hJ4pLc4Uo+MXMQS9V81Q9RwmDq/AiqC/j3aPYzAt8OUMRZyJK8
         Cm3AYnGP3780aNepmszM/OBfim83FPlyJuD+mbZ31FrZUGtnQr6VmfoBgQ+RnhO6hTUs
         U4bBpQu1lkzjpp0sYHDmbnFBI1hIqqmLytrn0Jqkx25HQ8dJGC/itps/FZbfrbNl4rgD
         yWJZBNzAfJScPv7VUjPlvKmtTcXj+OAOQYRotf9Jwjs8dVIg9Kqp+g8x4WFnYNxIfCKN
         OCZ2J+HspNLoNhFv8GZtgfDAL6PMkYHy981HbNJRizFhBr936jfZYaAqtZysEL2UbFro
         aWTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUa9bzRJ0gThND0+zFnz1shGU3WzQ4ChT16y4O6aQAh2eCvTPsT
	j6MIHYpbon/BtC59SiT6CyDSk0Vxdjrgs/rmBB73U3Z2ARZ9S2PW7/gBW1Z0WXcpLSIdIIFoy7i
	G1FsQb+G5S9/BZQsfv8YB97NEqYYdeWG2jgO957Bu7+G7qAe0Cj/xE/EdMR/OIigpJw==
X-Received: by 2002:a37:d9cb:: with SMTP id q72mr7471130qkl.143.1551539539272;
        Sat, 02 Mar 2019 07:12:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqygLqagk+JvPSMTyTgLGxqC1LopSScXenVnWBOcC9PbaCXgVMbzmki4SncDVdirQHrUXfI+
X-Received: by 2002:a37:d9cb:: with SMTP id q72mr7471078qkl.143.1551539538272;
        Sat, 02 Mar 2019 07:12:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551539538; cv=none;
        d=google.com; s=arc-20160816;
        b=AGnI7VL08A9V9U90c7poaZ2cplLwh/lWcCHLkzc8ny8FuaNYseOvFHC1CLBt881nD+
         kz71Uwf61AQbA8IOSfyEWZ03PKTlp0pVcdEPpOHm5JLLcki5sNMyNKCmLXBdb9a+ajyT
         UyFfbPvDl5PN3y11qxHCN/CvNr3mpWAlU/Z95rWijDwS/7zYSIys9Zjk4QZUMO7NqhRx
         LwJrKFkBQ6l7KC3Mf3ejn/RyduJLyhuUnFolDfDMp4zplhHGr40QAlOxSW4TFTn5tOBm
         zYSAarP0u4nxcwdC4tbSrWBSyjmmLSLRZEqwolHbqttXRVRiwpuPp8uN+kGCGeYNb7km
         /lKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=sjSqMIoEjtI7SM2/h9YXuH0OJaBmS4bgBeYZjNAxlxg=;
        b=tKecL7SYgZAf/D3TDfmC6ZZxM5NlbW2ykVgYTteUx5d6jc/V6BCdyzQMH0Mz8baA5p
         +/0wbHFqrMQnI1ip8pX+irp4x5ivgSwX1O46No34m6PpgU6mKNwaogrDbui41DEZFjEM
         jUiJzbov0XysSkjZ5ArhxZEwR/6AGXdBM3sjGdz2roKcGEymO6xZnbEbV2NK86TZpbML
         fAiLTuUjqWL9ANOfN5evMCyO3QxBF1PK8mgBCi5SyMhq+N++ctjcA7cZInN/228QY78p
         WuKSPfjUNan2XGPtVY+9a8YQp4726Qbl41/lHXFbMIn7ZallXEo6iMT/Zji/hi9Rlecm
         c2MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n92si518704qte.103.2019.03.02.07.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 07:12:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05BD711BB79;
	Sat,  2 Mar 2019 15:11:47 +0000 (UTC)
Received: from dustball.brq.redhat.com (unknown [10.43.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3CC08600CD;
	Sat,  2 Mar 2019 15:11:40 +0000 (UTC)
From: Jan Stancek <jstancek@redhat.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	willy@infradead.org,
	peterz@infradead.org,
	riel@surriel.com,
	mhocko@suse.com,
	ying.huang@intel.com,
	jrdr.linux@gmail.com,
	jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com,
	david@redhat.com,
	aarcange@redhat.com,
	raquini@redhat.com,
	rientjes@google.com,
	kirill@shutemov.name,
	mgorman@techsingularity.net,
	jstancek@redhat.com
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH] mm/memory.c: do_fault: avoid usage of stale vm_area_struct
Date: Sat,  2 Mar 2019 16:11:26 +0100
Message-Id: <0b7a4604529e16ace8d65a42dac7c78582e7fb28.1551538524.git.jstancek@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Sat, 02 Mar 2019 15:11:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
This is a stress test, where one thread mmaps/writes/munmaps memory area
and other thread is trying to read from it:

  CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
  Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
  Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
  Call Trace:
  ([<0000000000000000>]           (null))
   [<00000000001adae4>] lock_acquire+0xec/0x258
   [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
   [<000000000012a780>] page_table_free+0x48/0x1a8
   [<00000000002f6e54>] do_fault+0xdc/0x670
   [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
   [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
   [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
   [<000000000080e5ee>] pgm_check_handler+0x19e/0x200

page_table_free() is called with NULL mm parameter, but because
"0" is a valid address on s390 (see S390_lowcore), it keeps
going until it eventually crashes in lockdep's lock_acquire.
This crash is reproducible at least since 4.14.

Problem is that "vmf->vma" used in do_fault() can become stale.
Because mmap_sem may be released, other threads can come in,
call munmap() and cause "vma" be returned to kmem cache, and
get zeroed/re-initialized and re-used:

handle_mm_fault                           |
  __handle_mm_fault                       |
    do_fault                              |
      vma = vmf->vma                      |
      do_read_fault                       |
        __do_fault                        |
          vma->vm_ops->fault(vmf);        |
            mmap_sem is released          |
                                          |
                                          | do_munmap()
                                          |   remove_vma_list()
                                          |     remove_vma()
                                          |       vm_area_free()
                                          |         # vma is released
                                          | ...
                                          | # same vma is allocated
                                          | # from kmem cache
                                          | do_mmap()
                                          |   vm_area_alloc()
                                          |     memset(vma, 0, ...)
                                          |
      pte_free(vma->vm_mm, ...);          |
        page_table_free                   |
          spin_lock_bh(&mm->context.lock);|
            <crash>                       |

This patch pins mm_struct and stores its value, to avoid using
potentially stale "vma" when calling pte_free().

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/memory.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..1287ee9acbdc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3517,12 +3517,17 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
  * but allow concurrent faults).
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
+ * If mmap_sem is released, vma may become invalid (for example
+ * by other thread calling munmap()).
  */
 static vm_fault_t do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
+	struct mm_struct *vm_mm = READ_ONCE(vma->vm_mm);
 	vm_fault_t ret;
 
+	mmgrab(vm_mm);
+
 	/*
 	 * The VMA was not fully populated on mmap() or missing VM_DONTEXPAND
 	 */
@@ -3561,9 +3566,12 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
 
 	/* preallocated pagetable is unused: free it */
 	if (vmf->prealloc_pte) {
-		pte_free(vma->vm_mm, vmf->prealloc_pte);
+		pte_free(vm_mm, vmf->prealloc_pte);
 		vmf->prealloc_pte = NULL;
 	}
+
+	mmdrop(vm_mm);
+
 	return ret;
 }
 
-- 
1.8.3.1

