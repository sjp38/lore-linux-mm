Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3486FC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCE9A218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCE9A218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C5A88E0004; Wed, 26 Dec 2018 08:38:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7508D8E0001; Wed, 26 Dec 2018 08:38:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F1078E0004; Wed, 26 Dec 2018 08:38:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16CD88E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:38:44 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so15186482pgv.23
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:38:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=sK2wyaa9OQJCGIyx2U8qb6p7gEuhbJ2Wb9fFN0ccy8A=;
        b=qUYgFoCeggXdRRSLatYLRkAG7+JkeSw05P4c5nEvXsWrPATEFDdFWKSkbN3ZaSeJr6
         GoO+Q6tud3abzWaHQbZN5MID4k1Ki6E9ERleb4+aCgP3T0mFgdbVectxurehdjGVeNXD
         ghEAHvp7YUhpRFWekQd4rantmHWGZs4BSP7au7MHVvaSbA1DamoBfj2af6RuttzuWHBo
         aRftWcMffcrYBaGbsvrCg4UPYUmEIeSttHbwwj3lbnFmyD65EbzPW5xk0FjdmftZFVTw
         wJEZwHiYSzz4Gkr3vUzwhyFzdD6Wx4bosjtcNODNXHEB3s+0YEJUwqcQ/juqdxqUHi+P
         f24A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWbXB4SGzwm544XxD2SgMTwdlEMSRQV2TyMFBfktpL/M9SAcCqu7
	yGrNrQJYf4aLuPOcbfy5sJjrEMCgSi/SexFrloNPEI1yHSNS/gmxmBziOSS1NtEGr5Z+5VXn3vN
	q91fBvMqh60g0lWnIWFIh/wU5DtrEoO85PuRpmuR1cqIrXIpYdOf/Yhm+J+dLoRGPww==
X-Received: by 2002:a62:26c7:: with SMTP id m190mr20523555pfm.79.1545831523763;
        Wed, 26 Dec 2018 05:38:43 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UBy4hg46vX54Wa0Ux2AL/Xy/Dk8d1cW3RDid+ow1B734ewxKvU0mfa3Es1FltGLmDuNBuE
X-Received: by 2002:a62:26c7:: with SMTP id m190mr20518694pfm.79.1545831427585;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=v4wKV+vnVl+rS9y8N7aXdxqv7LGY19PZdWUAf0T1LEWicn/45kQDa/MNvjNYblkgKM
         hdnQ1/1NNZs9j3LyLYk/2x1+KFHWIr1PpJPKWq9pgsNeHPXm8tKqeBLwYI0GbPC1kw/s
         HYQJ4guylESZyjGBSgDi7KZYPjU5cZCkZdShNqwHnOlDsljcEKuvFFnj5AH75+fvLzQr
         ZgT6nLpIa8lGsL48hqd4ufMBcMslnTMdIwj+NYsOWGiRxbw/lG4BuO2a+khEt8sg/6G2
         hIQDdsMu35iIOGkR0Z1Fj16yEHaJUvb0pXc881k4ajVkPYB1YW2JzqmnPqZ9E0clCMpX
         xNjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=sK2wyaa9OQJCGIyx2U8qb6p7gEuhbJ2Wb9fFN0ccy8A=;
        b=w1FFsLvU/Xxhqkc/z8/qEpP/0TtBmhzt0QMGgmRD5ckGiP34epraN3xmwNnzUZzclq
         Dw3QqlD5GkRfsPv4QZkhiIlWgAmXAHUDnb2Cb50F49i20wLdW2VfXStTwYsZ20rT1HUS
         HF5GbbZ1dZ4d9B2bnCNOyMxs4mMV7zJYbeBCpSTfHzuAQ/w9U1uzSWeI8DpLa3BAdC1R
         BWrVMvESaMwqTX9ExTOIJOyxuMFw3goWgj6wjChYCZB2VdZRw08eF4OcdS/oEmdiCIkh
         4S1tM/Dk0ZEBZyzofhqvzL/E1La6aygogGCa4ID1Kj0XHSTzNj4YfAUmxHw2TRSE3jRR
         uVqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358947"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005PD-Kb; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133352.076749877@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Huang Ying <ying.huang@intel.com>,
 Brendan Gregg <bgregg@netflix.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 17/21] proc: introduce /proc/PID/idle_pages
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0008-proc-introduce-proc-PID-idle_pages.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131503.-TbBlaV8TN-7yG4-tuxEfnT4n-LGSDdZutz8L2cN3WQ@z>

This will be similar to /sys/kernel/mm/page_idle/bitmap documented in
Documentation/admin-guide/mm/idle_page_tracking.rst, however indexed
by process virtual address.

When using the global PFN indexed idle bitmap, we find 2 kind of
overheads:

- to track a task's working set, Brendan Gregg end up writing wss-v1
  for small tasks and wss-v2 for large tasks:

  https://github.com/brendangregg/wss

  That's because VAs may point to random PAs throughout the physical
  address space. So we either query /proc/pid/pagemap first and access
  the lots of random PFNs (with lots of syscalls) in the bitmap, or
  write+read the whole system idle bitmap beforehand.

- page table walking by PFN has much more overheads than to walk a
  page table in its natural order:
  - rmap queries
  - more locking
  - random memory reads/writes

This interface provides a cheap path for the majority non-shared mapping
pages. To walk 1TB memory of 4k active pages, it costs 2s vs 15s system
time to scan the per-task/global idle bitmaps. Which means ~7x speedup.
The gap will be enlarged if consider

- the extra /proc/pid/pagemap walk
- natural page table walks can skip the whole 512 PTEs if PMD is idle

OTOH, the per-task idle bitmap is not suitable in some situations:

- not accurate for shared pages
- don't work with non-mapped file pages
- don't perform well for sparse page tables (pointed out by Huang Ying)

So it's more about complementing the existing global idle bitmap.

CC: Huang Ying <ying.huang@intel.com>
CC: Brendan Gregg <bgregg@netflix.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 fs/proc/base.c     |    2 +
 fs/proc/internal.h |    1 
 fs/proc/task_mmu.c |   54 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

--- linux.orig/fs/proc/base.c	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/base.c	2018-12-23 20:08:14.224919327 +0800
@@ -2969,6 +2969,7 @@ static const struct pid_entry tgid_base_
 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_pages", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",       S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
@@ -3357,6 +3358,7 @@ static const struct pid_entry tid_base_s
 	REG("smaps",     S_IRUGO, proc_pid_smaps_operations),
 	REG("smaps_rollup", S_IRUGO, proc_pid_smaps_rollup_operations),
 	REG("pagemap",    S_IRUSR, proc_pagemap_operations),
+	REG("idle_pages", S_IRUSR|S_IWUSR, proc_mm_idle_operations),
 #endif
 #ifdef CONFIG_SECURITY
 	DIR("attr",      S_IRUGO|S_IXUGO, proc_attr_dir_inode_operations, proc_attr_dir_operations),
--- linux.orig/fs/proc/internal.h	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/internal.h	2018-12-23 20:08:14.224919327 +0800
@@ -298,6 +298,7 @@ extern const struct file_operations proc
 extern const struct file_operations proc_pid_smaps_rollup_operations;
 extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
+extern const struct file_operations proc_mm_idle_operations;
 
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
--- linux.orig/fs/proc/task_mmu.c	2018-12-23 20:08:14.228919325 +0800
+++ linux/fs/proc/task_mmu.c	2018-12-23 20:08:14.224919327 +0800
@@ -1559,6 +1559,60 @@ const struct file_operations proc_pagema
 	.open		= pagemap_open,
 	.release	= pagemap_release,
 };
+
+/* will be filled when kvm_ept_idle module loads */
+struct file_operations proc_ept_idle_operations = {
+};
+EXPORT_SYMBOL_GPL(proc_ept_idle_operations);
+
+static ssize_t mm_idle_read(struct file *file, char __user *buf,
+			    size_t count, loff_t *ppos)
+{
+	if (proc_ept_idle_operations.read)
+		return proc_ept_idle_operations.read(file, buf, count, ppos);
+
+	return 0;
+}
+
+
+static int mm_idle_open(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = proc_mem_open(inode, PTRACE_MODE_READ);
+
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+
+	file->private_data = mm;
+
+	if (proc_ept_idle_operations.open)
+		return proc_ept_idle_operations.open(inode, file);
+
+	return 0;
+}
+
+static int mm_idle_release(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = file->private_data;
+
+	if (mm) {
+		if (!mm_kvm(mm))
+			flush_tlb_mm(mm);
+		mmdrop(mm);
+	}
+
+	if (proc_ept_idle_operations.release)
+		return proc_ept_idle_operations.release(inode, file);
+
+	return 0;
+}
+
+const struct file_operations proc_mm_idle_operations = {
+	.llseek		= mem_lseek, /* borrow this */
+	.read		= mm_idle_read,
+	.open		= mm_idle_open,
+	.release	= mm_idle_release,
+};
+
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA


