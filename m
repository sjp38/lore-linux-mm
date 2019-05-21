Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67CF8C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:06:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFBB21773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:06:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="J3/6y9kK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFBB21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9102D6B0005; Tue, 21 May 2019 06:06:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89ADB6B0010; Tue, 21 May 2019 06:06:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73C416B0266; Tue, 21 May 2019 06:06:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE5B6B0005
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:06:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n23so29903780edv.9
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:06:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ORiID9Ap1Ob1uAeKkaBEOgmrOkRFTz441mfPcwfeVdo=;
        b=gt+BXX7yGaWNthWQ6FbTGm5p9J2oDDcXQqkkykxevnrxW4lz72COxPS9HCEV6Ok5tI
         kxoOorN/MKuxW4gT05Vqv/RP7pm724wbPH4AhnIK/OUaj4t/yq2DYyoYFHVqThbHrLId
         PMCXlKhRjJvFoJ0AbiEvSAx6mg8JUnhxHx/vh1W8IuLuAC7ziiwz/DcTq9M4mtsSqKoK
         Y1BWuBGkUK+aCKCKcgVc9INpFQWH0HzsiEq4PrgErWwzGDGCiBeMAunupo5hHph7K3gG
         LNalim7xHcO+yDfKcFH1U8jx22yDvuc7CBV1EnoVdG3W8tDSUVluqhb0TKzdydSTKqps
         JfmA==
X-Gm-Message-State: APjAAAXBOO8dKXkd58QqG+pVZhbJAC1r9hCPNWY+DeyE+0mIQfaSTh6Q
	aVf/uSlPITlo0fjpVppnsr98KwMREtJVUrYsS2ZFiK0AtcbMkOymaZ4DJCzcTIVQCva0mkUuTK2
	2pyxs7nGl5o4dy4WZwYDCXtqP+A8WRMm286VdM2CBC9+O31jjefFcoKKdCYPSz/4XeA==
X-Received: by 2002:aa7:c642:: with SMTP id z2mr48653477edr.231.1558433178486;
        Tue, 21 May 2019 03:06:18 -0700 (PDT)
X-Received: by 2002:aa7:c642:: with SMTP id z2mr48653375edr.231.1558433177462;
        Tue, 21 May 2019 03:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558433177; cv=none;
        d=google.com; s=arc-20160816;
        b=Nq7i6LypSU97sAqVAJA/gMkLOd4J6sHYjpSoBeI1s625Xa4mm747ioOhBnlLw1eu5o
         qdEJaav6Io9/9/lugubYbNrjE+WFvqqCNN4ih4EhqcJQ9w3yJn2MYbhFzk5rZJr+ya/2
         v3RsaqcPEdTNR3KDKt2KSugIKcfcUe4zI9CvD7qeJOQVmp7KNo2SZoAca0g+wDNfcUzg
         utA66fvSpS8ytSNhD+CDZpwfiN3I06jAUDPIchcH/F2cf/fvQU72Y5O+qaAM7ih1u0YQ
         i4sykCrjfk25rO5rDCnGPALw5Jl/reuhFW9Kcf6CbyRecOC+reVCYTFqB10FcaoX8ysW
         lKtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ORiID9Ap1Ob1uAeKkaBEOgmrOkRFTz441mfPcwfeVdo=;
        b=ombUOk3QYZ4yrs40v70u+vIjW1ZI8q3vAqm+HLQvvOm47K3bdj5pOenql4/IGbKqmQ
         8StPO2Z19bx3612hohUTNbc1g1xYJ24rsQU4UzjIk38MWAIB5WjQIZJNefn5g3GiChCu
         Qkkxn+oFzXx2OmDeW0zNl9p9FAO+0O8wnpBSje29ejKxwrdOS+nfUFTdE8rYM9JstQ1E
         VsjI9cmNODr1hhNcsgB5rPPi9AEFtHAIiqNN8sZeCpVeQ11vqnkJJdUkD+ZjBND106ek
         ieXYO77ILDQwgj0GwtI04Mrlp0P3oGSAxCYZeGwOX/dS24y6pSH4OBOa/SJu4Tt6Wgap
         zD+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b="J3/6y9kK";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16sor6233764ejp.35.2019.05.21.03.06.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 03:06:17 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b="J3/6y9kK";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ORiID9Ap1Ob1uAeKkaBEOgmrOkRFTz441mfPcwfeVdo=;
        b=J3/6y9kKcNs5Up92q6Ht3qYQr/8Q1Nn0GsZarKsE0BHF/9qWsjrqRfr4cQlGltRm2I
         wqsCyiUgW/KR4/TBpMTS5/CqMLQXMYJe1Ly5ewd7hgV3Ecwwtnn2EXCWyV3KLe59dHgz
         fvsyfkTo+LoIR3qdO9GW6+6Xw4/zcvaprDksY=
X-Google-Smtp-Source: APXvYqzBBGRnYGtpodRAQ8DMg63QLyln2/B1qsctPkiipoWafwF4J3ZQDE0/G6e2kd4uFdMZzId0Gg==
X-Received: by 2002:a17:906:7cc7:: with SMTP id h7mr12383525ejp.240.1558433177093;
        Tue, 21 May 2019 03:06:17 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id 1sm3457177eju.9.2019.05.21.03.06.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:06:16 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>,
	Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH] kernel.h: Add non_block_start/end()
Date: Tue, 21 May 2019 12:06:11 +0200
Message-Id: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In some special cases we must not block, but there's not a
spinlock, preempt-off, irqs-off or similar critical section already
that arms the might_sleep() debug checks. Add a non_block_start/end()
pair to annotate these.

This will be used in the oom paths of mmu-notifiers, where blocking is
not allowed to make sure there's forward progress. Quoting Michal:

"The notifier is called from quite a restricted context - oom_reaper -
which shouldn't depend on any locks or sleepable conditionals. The code
should be swift as well but we mostly do care about it to make a forward
progress. Checking for sleepable context is the best thing we could come
up with that would describe these demands at least partially."

Peter also asked whether we want to catch spinlocks on top, but Michal
said those are less of a problem because spinlocks can't have an
indirect dependency upon the page allocator and hence close the loop
with the oom reaper.

Suggested by Michal Hocko.

v2:
- Improve commit message (Michal)
- Also check in schedule, not just might_sleep (Peter)

v3: It works better when I actually squash in the fixup I had lying
around :-/

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Wei Wang <wvw@google.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Jann Horn <jannh@google.com>
Cc: Feng Tang <feng.tang@intel.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org
Acked-by: Christian König <christian.koenig@amd.com> (v1)
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/kernel.h | 10 +++++++++-
 include/linux/sched.h  |  4 ++++
 kernel/sched/core.c    | 19 ++++++++++++++-----
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 74b1ee9027f5..b5f2c2ff0eab 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -214,7 +214,9 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
  * might_sleep - annotation for functions that can sleep
  *
  * this macro will print a stack trace if it is executed in an atomic
- * context (spinlock, irq-handler, ...).
+ * context (spinlock, irq-handler, ...). Additional sections where blocking is
+ * not allowed can be annotated with non_block_start() and non_block_end()
+ * pairs.
  *
  * This is a useful debugging help to be able to catch problems early and not
  * be bitten later when the calling function happens to sleep when it is not
@@ -230,6 +232,10 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
 # define cant_sleep() \
 	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change = 0)
+# define non_block_start() \
+	do { current->non_block_count++; } while (0)
+# define non_block_end() \
+	do { WARN_ON(current->non_block_count-- == 0); } while (0)
 #else
   static inline void ___might_sleep(const char *file, int line,
 				   int preempt_offset) { }
@@ -238,6 +244,8 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
 # define might_sleep() do { might_resched(); } while (0)
 # define cant_sleep() do { } while (0)
 # define sched_annotate_sleep() do { } while (0)
+# define non_block_start() do { } while (0)
+# define non_block_end() do { } while (0)
 #endif
 
 #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 11837410690f..7f5b293e72df 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -908,6 +908,10 @@ struct task_struct {
 	struct mutex_waiter		*blocked_on;
 #endif
 
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	int				non_block_count;
+#endif
+
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int			irq_events;
 	unsigned long			hardirq_enable_ip;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 102dfcf0a29a..ed7755a28465 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3264,13 +3264,22 @@ static noinline void __schedule_bug(struct task_struct *prev)
 /*
  * Various schedule()-time debugging checks and statistics:
  */
-static inline void schedule_debug(struct task_struct *prev)
+static inline void schedule_debug(struct task_struct *prev, bool preempt)
 {
 #ifdef CONFIG_SCHED_STACK_END_CHECK
 	if (task_stack_end_corrupted(prev))
 		panic("corrupted stack end detected inside scheduler\n");
 #endif
 
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	if (!preempt && prev->state && prev->non_block_count) {
+		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i\n",
+			prev->comm, prev->pid, prev->non_block_count);
+		dump_stack();
+		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
+	}
+#endif
+
 	if (unlikely(in_atomic_preempt_off())) {
 		__schedule_bug(prev);
 		preempt_count_set(PREEMPT_DISABLED);
@@ -3377,7 +3386,7 @@ static void __sched notrace __schedule(bool preempt)
 	rq = cpu_rq(cpu);
 	prev = rq->curr;
 
-	schedule_debug(prev);
+	schedule_debug(prev, preempt);
 
 	if (sched_feat(HRTICK))
 		hrtick_clear(rq);
@@ -6102,7 +6111,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 	rcu_sleep_check();
 
 	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
-	     !is_idle_task(current)) ||
+	     !is_idle_task(current) && !current->non_block_count) ||
 	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
 	    oops_in_progress)
 		return;
@@ -6118,8 +6127,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
 		"BUG: sleeping function called from invalid context at %s:%d\n",
 			file, line);
 	printk(KERN_ERR
-		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
-			in_atomic(), irqs_disabled(),
+		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
+			in_atomic(), irqs_disabled(), current->non_block_count,
 			current->pid, current->comm);
 
 	if (task_stack_end_corrupted(current))
-- 
2.20.1

