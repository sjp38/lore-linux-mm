Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C74F9C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FB132084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="TB/fDwiR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FB132084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AD666B000A; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25C836B000C; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101DA6B000D; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id DA9006B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:38 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6BE6C180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:38 +0000 (UTC)
X-FDA: 75822151356.11.end59_57ed92dafb31
X-HE-Tag: end59_57ed92dafb31
X-Filterd-Recvd-Size: 10123
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:37 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id m44so343633edd.9
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JoaO8Qe6CY1dfta4yCfl+sTgCnZHzLR+xJsBydvmafY=;
        b=TB/fDwiRpXDbYnbebe5pI330088X9XJlGQF+2IhRTfDYTMEq0INaebPwZsNsT8LD80
         +k2xt/FCnylJAZNGoH8zeEPnqj8+2txInoicG9vpjAfteV/ICjiT5gaNMKKQtYsYkrzg
         KNkRLGmFFbDP5EJsNKo7E/q8ZnanOmEVhmVQY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=JoaO8Qe6CY1dfta4yCfl+sTgCnZHzLR+xJsBydvmafY=;
        b=kSqH+J6zimjm8RxjxHHr6/ae1qexUgo6z9ML8nZhHM8OCZ/jqvnaAY2s4ojQvMh43n
         oOxx5wk+KFv4v6YsErJTB1LmFZe9pN3T91AGayD4EVlgGkpUyeIPcFw3LsNmfTCWK4cg
         gfrVAh00bzhWOfNuZ7nDmyM/3D/QFxIoXoj1i1suAD8fNnKhxv/FasIo/KlNiIyFbgzT
         8Wo9UZfx+D7Ca95+17vDyQNfWJi2LyrAF9R97Khqafdefyqt/ADRBlrn6CGyYHpOQdXp
         STiAxZbPQVMoJ1AhndG/KuH/6YTdp45hmd/pZwIWEa2OUyZhOqjzsCltz/Y3PCZPqOHk
         EZgw==
X-Gm-Message-State: APjAAAUVWYHLBpO6CiwDRh9S31GqxLmScZ6f/gUYpsWRKjnHZCV7sggY
	wtGqZFJwZYMhKh3k1c7eOf3ggA==
X-Google-Smtp-Source: APXvYqwfgJdqGV4TaVUUi1ZAyfmEy0estN74mYOzE8kf3NhnJNKCPuqJA+FY/2vvG54TdUF778ZM6A==
X-Received: by 2002:a17:906:198e:: with SMTP id g14mr1315533ejd.158.1565814036543;
        Wed, 14 Aug 2019 13:20:36 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:35 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
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
Subject: [PATCH 2/5] kernel.h: Add non_block_start/end()
Date: Wed, 14 Aug 2019 22:20:24 +0200
Message-Id: <20190814202027.18735-3-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
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
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/kernel.h | 10 +++++++++-
 include/linux/sched.h  |  4 ++++
 kernel/sched/core.c    | 19 ++++++++++++++-----
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 4fa360a13c1e..915fd9888afb 100644
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
@@ -233,6 +235,10 @@ extern void __cant_sleep(const char *file, int line,=
 int preempt_offset);
 # define cant_sleep() \
 	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
 # define sched_annotate_sleep()	(current->task_state_change =3D 0)
+# define non_block_start() \
+	do { current->non_block_count++; } while (0)
+# define non_block_end() \
+	do { WARN_ON(current->non_block_count-- =3D=3D 0); } while (0)
 #else
   static inline void ___might_sleep(const char *file, int line,
 				   int preempt_offset) { }
@@ -241,6 +247,8 @@ extern void __cant_sleep(const char *file, int line, =
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
index 9f51932bd543..c5630f3dca1f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -974,6 +974,10 @@ struct task_struct {
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
index 2b037f195473..57245770d6cc 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3700,13 +3700,22 @@ static noinline void __schedule_bug(struct task_s=
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
@@ -3813,7 +3822,7 @@ static void __sched notrace __schedule(bool preempt=
)
 	rq =3D cpu_rq(cpu);
 	prev =3D rq->curr;
=20
-	schedule_debug(prev);
+	schedule_debug(prev, preempt);
=20
 	if (sched_feat(HRTICK))
 		hrtick_clear(rq);
@@ -6570,7 +6579,7 @@ void ___might_sleep(const char *file, int line, int=
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
@@ -6586,8 +6595,8 @@ void ___might_sleep(const char *file, int line, int=
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
2.22.0


