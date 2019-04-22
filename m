Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0840DC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1D7C218D3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1D7C218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6DEC6B000D; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA8456B0008; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 888EA6B000E; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13B3F6B000C
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so8457710pgv.15
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+opaO1awQtWXl9ApsaZ/rgEyOZ23bi+ZXWhS2cx66gg=;
        b=VLacFO/eRYx3xU+8yGgqaapuX1dBkkTpOKfIsqcAdS3CBx8MqeYz8h1EOhmd/TbaC6
         wATSwEtWvhUIGWqEbTH7EFLZU375Ec2GgfggGTUveyeIgrQ/i1aMqbm5IWEC0YXZZH3v
         t3dI8PsTA8Fzk9sXl2jXAc/P2OA7aqIGs/GcT2Gid18WGjAdFHNQpucQWDoXsob5saem
         tFkiIesFbCU2tHFiW5ysdaY3EpZk23j7GFKq6JrW2fvujviZQbataowQjrDVKAnD4fJL
         KuyIgmlz49iZn7drVPoUdtTDtu6llFAvGk7ObF5wTekpcXvRfrtqSePIezRybQF8NR24
         QYHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWOOlsLZBSU3SBXT+pRS/ZOTVw6DkmY+7W5NEr00pP9+o3Qy4dB
	z6Met1eL1/kAVek6BHW/4wHJphSlJSvURYjlgOe4+eRxTfSBucieDgBrbkVTrJrZbFEcJ3C85Cp
	8xqp0k1r+PxB0Dg8Qlh9/oibi9OgiqEaqu9SgATli03BH6CWTy5LNO9GgJQ7Sc4hNYA==
X-Received: by 2002:a65:4802:: with SMTP id h2mr18937043pgs.98.1555959523726;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKJo+cK5HWrFUB2d3Y5F0DvfXrbxgp96JQUE5a8z1blVUH6mZsH6AASeHpcbRxytVhBRP6
X-Received: by 2002:a65:4802:: with SMTP id h2mr18936993pgs.98.1555959522802;
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959522; cv=none;
        d=google.com; s=arc-20160816;
        b=SKZzqELvL+K1Abb2dArXvVRcJwDqtyF9gQMjmT0sx4nR7xKsNfZNwcpDA9EMPeIVLX
         IeYZxiH8Ui3a7nfU16jsor7Ge+x/USbQvBi6OAtq6oHW6PF9pstK4OVhsaYCZTJBeDZr
         iLROlrqgqOIdUY5hihtmIxuNbNFTVY+ZLEotdB9q0cFwB8JVv0oFH6kUvVs+0UkMIDjE
         3NPs2JLdS2NOzMUvV5t1HfjPU5Gu2YucB4iEhLVFigioSKjoZxEkqTyB86UBV189adJw
         BhULmicBZ+D06QNyh6NxRH6VrPatbdNSRPjIS7MW0zfMgAinI2Rm4In4y/xWtwAjYWvu
         T+ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+opaO1awQtWXl9ApsaZ/rgEyOZ23bi+ZXWhS2cx66gg=;
        b=H7WUJPHGSJxxZbo6Abp+/lM6hzrt4Vu8j9Bk7d1mbR7WMZh7MTGy6jygjUDsbKiqcT
         g4IjK5Wyxlpb+6Nj2uWDEUe2tJc74dTGVeQG9PLTohAU11baK8lYOhzRAQCutMb5ll+Z
         gfY+1FA8LV+JWRo0PZGrXy40uGHXo86cO3y+1bZsl4eOBFYnmNm23jzURiGvaJVsvnk2
         NSLDvGf6NfGmUQ7XcL3rUNU1YBTbS+rc9XVgAiuNNeMAVHAKnvSDEapN/RfUeMTbrKgY
         vLNuZIggnoZr4EpsQ8csPOIlFzQuLhhEQ4476RVvQmbLLtkjrN2l2BAAJe0naFMnJMrr
         KJNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417131"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 05/23] fork: Provide a function for copying init_mm
Date: Mon, 22 Apr 2019 11:57:47 -0700
Message-Id: <20190422185805.1169-6-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Provide a function for copying init_mm. This function will be later used
for setting a temporary mm.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/sched/task.h |  1 +
 kernel/fork.c              | 24 ++++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index 2e97a2227045..f1227f2c38a4 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -76,6 +76,7 @@ extern void exit_itimers(struct signal_struct *);
 extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
+struct mm_struct *copy_init_mm(void);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
 extern long kernel_wait4(pid_t, int __user *, int, struct rusage *);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa210b..099cca8f701c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1298,13 +1298,20 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 		complete_vfork_done(tsk);
 }
 
-/*
- * Allocate a new mm structure and copy contents from the
- * mm structure of the passed in task structure.
+/**
+ * dup_mm() - duplicates an existing mm structure
+ * @tsk: the task_struct with which the new mm will be associated.
+ * @oldmm: the mm to duplicate.
+ *
+ * Allocates a new mm structure and duplicates the provided @oldmm structure
+ * content into it.
+ *
+ * Return: the duplicated mm or NULL on failure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+static struct mm_struct *dup_mm(struct task_struct *tsk,
+				struct mm_struct *oldmm)
 {
-	struct mm_struct *mm, *oldmm = current->mm;
+	struct mm_struct *mm;
 	int err;
 
 	mm = allocate_mm();
@@ -1371,7 +1378,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	}
 
 	retval = -ENOMEM;
-	mm = dup_mm(tsk);
+	mm = dup_mm(tsk, current->mm);
 	if (!mm)
 		goto fail_nomem;
 
@@ -2186,6 +2193,11 @@ struct task_struct *fork_idle(int cpu)
 	return task;
 }
 
+struct mm_struct *copy_init_mm(void)
+{
+	return dup_mm(NULL, &init_mm);
+}
+
 /*
  *  Ok, this is the main fork-routine.
  *
-- 
2.17.1

