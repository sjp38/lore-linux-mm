Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A97C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29ED921841
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29ED921841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B528E0011; Mon, 28 Jan 2019 19:39:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF8A28E0010; Mon, 28 Jan 2019 19:39:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF5AA8E0011; Mon, 28 Jan 2019 19:39:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89B428E0010
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:23 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v2so13025616plg.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=1TyrV2qExacMWNjbbAQV/870MI2JQFH4ha6NlSEuZPU=;
        b=SJtQgoroL2gHm9oWiybKtX0n+4j2BGkRD4kOjov4RBDrytaTxLWfZ0jB2Qm9Zm/gVO
         gi9YfGdIRVIhUDw1ioN3W5Mqt8vFSSg4v/yvbpkJAM91S6Fv/dATlE3EdbRm5wP4ciDE
         a1gndRa12bvNyekUSItGQjsL5DQYjGWdXh7PrHqQoKRFn/00jnNKYRM5wXfRyEkTaAe4
         dFROFqKoXOxLeFcx/DsduuPhoHKWzq6ipUT2WRiQp3vPhbu+A8oRzNxDJ/7O84X2ymK3
         leyOywvRGjIeYlpfGxdmaxS2i9bx2Fa1hLWhmurLLmvL5dz3tyyt/LQg1KW7dY8i07Xk
         Yocg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeImhszIJpdvfH9pg7U+yV+OnhBFOCYq6ShzqNrTwI53NLMhIzK
	JyQUGTBPna4R3gZ1IhHGmzFScmThFc/oxXIveBdWp0xVQxB9ZD2I0n5+64hd6uyGnRi2x00/1mv
	XGdXpDoFPxU1SnRBarA+XK6OMJlvEISwXKxgoExg+fVEYCPFA8S40MmAcFWLaP7eaew==
X-Received: by 2002:a65:43c5:: with SMTP id n5mr22312206pgp.250.1548722363218;
        Mon, 28 Jan 2019 16:39:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5dM0MY7oBuKHcZBgcAxAEhe0HdRadyhEigPoYX71rwZu7lMtHwezvKxkhflIWZQac2imZ6
X-Received: by 2002:a65:43c5:: with SMTP id n5mr22311692pgp.250.1548722353162;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=hWWdjYR9u2gCnjhxtffgYXMcPEaldfJEI/SuyoTVJD/DTRxPLOpO25bDCpAQ4oIvT/
         e3M7J0IyNIF8Z+K4LXnB52uhs2U6HTcgoiBB1eOrt6pOjWlh5VCxIGcGQ84pVsx75oH1
         PPsfDT0bgfvQim1nXzt/s9k+EDvq6HTIhFvnveao7A0wKjAvGlwkjLFMeoeCco0rsS6T
         qE0LsOWT88qmuLlB5R5T7B45tJurV3Jt0bw6EHs+2qknjWMBLF5pOOh7ZNBBlyg4BhQn
         hmho119aTmePa9SPDfsXUMBfvr24/RTipKUUjeK24UPQw+7QSD4RsgCam2K/CxlSX0DH
         Zl4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=1TyrV2qExacMWNjbbAQV/870MI2JQFH4ha6NlSEuZPU=;
        b=0ru26so2BDQCi245Xjjuic099V5hlhW7vKIrtu/YlkKzcGvp5IAlGiDxxz0KD/3ZFM
         HT4JhR0Kpvlmea8scDtbi1k4XDpDbIGlfVO8wn527o79bSjdgHdRxxCDwWqRfABHFo/A
         yOqSl8kjl3ZS7kdMhn5d9C+xMKXLhLfht5190Ks4K9zPwFr81SU3XTtCh+EmKkHNPisO
         5KAwyDgBQA/1IzsiF/eGCW8IsOuoxpg1HG6NBSYi1ZhlZ1Di1hC5dkhL+mGHjEkkvcBh
         /GYferwhf3OQW89H7iWZCtXlfX8PQq4zPH9t2IwB577omJVzQlspZQ48/4JQ1p54JwLC
         GlOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s17si4514712pgi.513.2019.01.28.16.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921894"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
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
Subject: [PATCH v2 04/20] fork: provide a function for copying init_mm
Date: Mon, 28 Jan 2019 16:34:06 -0800
Message-Id: <20190129003422.9328-5-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
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
index 44c6f15800ff..c5a00a7b3beb 100644
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
index b69248e6f0e0..d7b156c49f29 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1299,13 +1299,20 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
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
+ * Allocates a new mm structure and copy contents from the provided
+ * @oldmm structure.
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
@@ -1372,7 +1379,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	}
 
 	retval = -ENOMEM;
-	mm = dup_mm(tsk);
+	mm = dup_mm(tsk, current->mm);
 	if (!mm)
 		goto fail_nomem;
 
@@ -2187,6 +2194,11 @@ struct task_struct *fork_idle(int cpu)
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

