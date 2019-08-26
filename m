Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C075FC3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C7821883
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="VFNW6E8S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C7821883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5793D6B0279; Mon, 26 Aug 2019 16:14:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5293F6B027B; Mon, 26 Aug 2019 16:14:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37C8E6B027C; Mon, 26 Aug 2019 16:14:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id 161116B0279
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:14:38 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A56B3381E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:37 +0000 (UTC)
X-FDA: 75865681794.29.stew01_456bc70865663
X-HE-Tag: stew01_456bc70865663
X-Filterd-Recvd-Size: 11040
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:36 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id g8so28158370edm.6
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:14:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Hvc+94UsrSo0dvtxcfDnaVeEmPfhp0JVZ15+D+5kcxs=;
        b=VFNW6E8Sf5IO/vio8FpctFWFmv5uJj0ggZOq4v0zfOgDSSsylE0MV0cDqxpUJ0O3+J
         jJbfISI7yr3sm+aoIHAjZ4ksh6Ts3a0rodKmpkYQuExF0IXSOGXHenwQjq/PFnh2xjem
         JCdCkwAuhHfBH1F/2PAMX7b12BePRCojTK8VM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Hvc+94UsrSo0dvtxcfDnaVeEmPfhp0JVZ15+D+5kcxs=;
        b=qjPLFDnZHOCkyMQsjsJ/mWoRxs85tsG2FeUtv4mQK8Em5Uz3wlakgp6ko33LgGLvfk
         ++eRhMcxrKnfEhUsRFoZz2PTF+05EwISF5XSEqom8kdyHAhjgvM4UhP+LBL1IdcWa0CU
         2Lc9uDFHLKgQ2hxYsICR2hs3bBqcoqeO6yxeIeCMV+V1cpnVbbdVQNChPjWOlCoM29G2
         QpYa9XsaHcCM8PudQ0pDCwYlE3s8fktXxK9ipTBW0xydnCjQEu4hIi/9BQI9EiuGOMml
         lMNROLuKZlgdje/sgGeQycx0db2RgKS7UNXrz/hh343ir3kP08qokSQiesAqqSDr5PGT
         Mzqw==
X-Gm-Message-State: APjAAAWl+JIN3OPfUgrxJtHBgecHBi23ffyGljZtprLApy7+dlMSiRkl
	tFOqpfN+8MGstoeox0KFLs3wvg==
X-Google-Smtp-Source: APXvYqwb474jg9zO2UYtdgTPRZkQGqmNA6F5tuCOyD7Luea082jyI2817UPjUHI4jh54moplcdAmZw==
X-Received: by 2002:a17:906:3b09:: with SMTP id g9mr18654098ejf.297.1566850475866;
        Mon, 26 Aug 2019 13:14:35 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id j25sm3000780ejb.49.2019.08.26.13.14.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 13:14:35 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
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
Subject: [PATCH 3/5] kernel.h: Add non_block_start/end()
Date: Mon, 26 Aug 2019 22:14:23 +0200
Message-Id: <20190826201425.17547-4-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
References: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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

v4: Pick the suggestion from Andrew Morton to give non_block_start/end
some good kerneldoc comments. I added that other blocking calls like
wait_event pose similar issues, since that's the other example we
discussed.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
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
Acked-by: Christian K=C3=B6nig <christian.koenig@amd.com> (v1)
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/kernel.h | 25 ++++++++++++++++++++++++-
 include/linux/sched.h  |  4 ++++
 kernel/sched/core.c    | 19 ++++++++++++++-----
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 4fa360a13c1e..82f84cfe372f 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -217,7 +217,9 @@ extern void __cant_sleep(const char *file, int line, =
int preempt_offset);
  * might_sleep - annotation for functions that can sleep
  *
  * this macro will print a stack trace if it is executed in an atomic
- * context (spinlock, irq-handler, ...).
+ * context (spinlock, irq-handler, ...). Additional sections where block=
ing is
+ * not allowed can be annotated with non_block_start() and non_block_end=
()
+ * pairs.
  *
  * This is a useful debugging help to be able to catch problems early an=
d not
  * be bitten later when the calling function happens to sleep when it is=
 not
@@ -233,6 +235,25 @@ extern void __cant_sleep(const char *file, int line,=
 int preempt_offset);
 # define cant_sleep() \
 	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change =3D 0)
+/**
+ * non_block_start - annotate the start of section where sleeping is pro=
hibited
+ *
+ * This is on behalf of the oom reaper, specifically when it is calling =
the mmu
+ * notifiers. The problem is that if the notifier were to block on, for =
example,
+ * mutex_lock() and if the process which holds that mutex were to perfor=
m a
+ * sleeping memory allocation, the oom reaper is now blocked on completi=
on of
+ * that memory allocation. Other blocking calls like wait_event() pose s=
imilar
+ * issues.
+ */
+# define non_block_start() \
+	do { current->non_block_count++; } while (0)
+/**
+ * non_block_end - annotate the end of section where sleeping is prohibi=
ted
+ *
+ * Closes a section opened by non_block_start().
+ */
+# define non_block_end() \
+	do { WARN_ON(current->non_block_count-- =3D=3D 0); } while (0)
 #else
   static inline void ___might_sleep(const char *file, int line,
 				   int preempt_offset) { }
@@ -241,6 +262,8 @@ extern void __cant_sleep(const char *file, int line, =
int preempt_offset);
 # define might_sleep() do { might_resched(); } while (0)
 # define cant_sleep() do { } while (0)
 # define sched_annotate_sleep() do { } while (0)
+# define non_block_start() do { } while (0)
+# define non_block_end() do { } while (0)
 #endif
=20
 #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b6ec130dff9b..e8bb965f5019 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -980,6 +980,10 @@ struct task_struct {
 	struct mutex_waiter		*blocked_on;
 #endif
=20
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	int				non_block_count;
+#endif
+
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int			irq_events;
 	unsigned long			hardirq_enable_ip;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 45dceec209f4..0d01c7994a9a 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3752,13 +3752,22 @@ static noinline void __schedule_bug(struct task_s=
truct *prev)
 /*
  * Various schedule()-time debugging checks and statistics:
  */
-static inline void schedule_debug(struct task_struct *prev)
+static inline void schedule_debug(struct task_struct *prev, bool preempt=
)
 {
 #ifdef CONFIG_SCHED_STACK_END_CHECK
 	if (task_stack_end_corrupted(prev))
 		panic("corrupted stack end detected inside scheduler\n");
 #endif
=20
+#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
+	if (!preempt && prev->state && prev->non_block_count) {
+		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i\n=
",
+			prev->comm, prev->pid, prev->non_block_count);
+		dump_stack();
+		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
+	}
+#endif
+
 	if (unlikely(in_atomic_preempt_off())) {
 		__schedule_bug(prev);
 		preempt_count_set(PREEMPT_DISABLED);
@@ -3870,7 +3879,7 @@ static void __sched notrace __schedule(bool preempt=
)
 	rq =3D cpu_rq(cpu);
 	prev =3D rq->curr;
=20
-	schedule_debug(prev);
+	schedule_debug(prev, preempt);
=20
 	if (sched_feat(HRTICK))
 		hrtick_clear(rq);
@@ -6641,7 +6650,7 @@ void ___might_sleep(const char *file, int line, int=
 preempt_offset)
 	rcu_sleep_check();
=20
 	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
-	     !is_idle_task(current)) ||
+	     !is_idle_task(current) && !current->non_block_count) ||
 	    system_state =3D=3D SYSTEM_BOOTING || system_state > SYSTEM_RUNNING=
 ||
 	    oops_in_progress)
 		return;
@@ -6657,8 +6666,8 @@ void ___might_sleep(const char *file, int line, int=
 preempt_offset)
 		"BUG: sleeping function called from invalid context at %s:%d\n",
 			file, line);
 	printk(KERN_ERR
-		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
-			in_atomic(), irqs_disabled(),
+		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %=
s\n",
+			in_atomic(), irqs_disabled(), current->non_block_count,
 			current->pid, current->comm);
=20
 	if (task_stack_end_corrupted(current))
--=20
2.23.0


