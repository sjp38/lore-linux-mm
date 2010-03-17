Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A910620026
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:19:23 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 71/96] c/r: [signal 4/4] support for real/virt/prof itimers
Date: Wed, 17 Mar 2010 12:08:59 -0400
Message-Id: <1268842164-5590-72-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-57-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-58-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-59-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-60-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-61-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-62-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-63-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-64-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-65-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-66-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-67-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-68-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-69-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-70-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-71-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds support for real/virt/prof itimers.
Expiry and the interval values are both saved in nanoseconds.

Changelog[v19-rc2]:
  - Adjust virt/prof itimer code for kernel 2.6.32
Changelog[v1]:
  - [Louis Rilling] Fix saving of signal->it_real_incr if not expired
  - Fix restoring of signal->it_real_incr if expire is zero
  - Save virt/prof expire relative to process accumulated time

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Louis Rilling <Louis.Rilling@kerlabs.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/signal.c            |   90 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    6 +++
 include/linux/posix-timers.h   |    9 ++++
 kernel/posix-cpu-timers.c      |    9 ----
 4 files changed, 105 insertions(+), 9 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 3d13c56..ecb94f8 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -15,6 +15,8 @@
 #include <linux/signal.h>
 #include <linux/errno.h>
 #include <linux/resource.h>
+#include <linux/timer.h>
+#include <linux/posix-timers.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -315,6 +317,9 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct signal_struct *signal;
 	struct sigpending shared_pending;
 	struct rlimit *rlim;
+	struct timeval tval;
+	struct cpu_itimer *it;
+	cputime_t cputime;
 	unsigned long flags;
 	int i, ret;
 
@@ -351,6 +356,53 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
 		h->rlim[i].rlim_max = rlim[i].rlim_max;
 	}
+
+	/* real/virt/prof itimers */
+	if (hrtimer_active(&signal->real_timer)) {
+		/* For an active timer compute the time delta */
+		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
+		/*
+		 * If the timer expired after the the test above, then
+		 * set the expire to the minimum possible (because by
+		 * now the pending signal have been saved already, but
+		 * the signal from this very expiry won't be sent before
+		 * we release t->sighand->siglock).
+		 */
+		ckpt_debug("active ! %lld\n", delta.tv64);
+		if (delta.tv64 <= 0)
+			delta.tv64 = NSEC_PER_USEC;
+		h->it_real_value = ktime_to_ns(delta);
+	} else {
+		/*
+		 * Timer is inactive; if @it_real_incr is 0 the timer
+		 * will not be re-armed. Beacuse we hold siglock, if
+		 * @it_real_incr > 0, the timer must have just expired
+		 * but not yet re-armed, and we have a SIGALRM pending
+		 * - that will trigger timer re-arm after restart.
+		 */
+		h->it_real_value = 0;
+	}
+	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
+
+	/* for prof/virt, ignore error and incr_error */
+	it = &signal->it[CPUCLOCK_VIRT];
+	cputime = it->expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(it->expires, virt_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_virt_value = timeval_to_ns(&tval);
+	cputime_to_timeval(it->incr, &tval);
+	h->it_virt_incr = timeval_to_ns(&tval);
+
+	it = &signal->it[CPUCLOCK_PROF];
+	cputime = it->expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(it->expires, prof_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_prof_value = timeval_to_ns(&tval);
+	cputime_to_timeval(it->incr, &tval);
+	h->it_prof_incr = timeval_to_ns(&tval);
+
 	unlock_task_sighand(t, &flags);
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -424,6 +476,7 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct itimerval itimer;
 	struct rlimit rlim;
 	int i, ret;
 
@@ -444,12 +497,49 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	/*
+	 * Reset real/virt/prof itimer (in case they were set), to
+	 * prevent unwanted signals after flushing current signals
+	 * and before restoring original real/virt/prof itimer.
+	 */
+	itimer.it_value = (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
+	itimer.it_interval =  (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
+	do_setitimer(ITIMER_REAL, &itimer, NULL);
+	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
+	do_setitimer(ITIMER_PROF, &itimer, NULL);
+
 	spin_lock_irq(&current->sighand->siglock);
 	pending = &current->signal->shared_pending;
 	flush_sigqueue(pending);
 	pending->signal = new_pending.signal;
 	list_splice_init(&new_pending.list, &pending->list);
 	spin_unlock_irq(&current->sighand->siglock);
+
+	/* real/virt/prof itimers */
+	itimer.it_value = ns_to_timeval(h->it_real_value);
+	itimer.it_interval = ns_to_timeval(h->it_real_incr);
+	ret = do_setitimer(ITIMER_REAL, &itimer, NULL);
+	if (ret < 0)
+		goto out;
+	/*
+	 * If expire is 0 but incr > 0 then we have a SIGALRM pending.
+	 * It should re-arm the timer when handled. But do_setitimer()
+	 * above already ignored @it_real_incr because @it_real_value
+	 * that was zero. So we set it manually. (This is safe against
+	 * malicious input, because in the worst case will generate an
+	 * unexpected SIGALRM to this process).
+	 */
+	if (!h->it_real_value && h->it_real_incr)
+		current->signal->it_real_incr = ns_to_ktime(h->it_real_incr);
+
+	itimer.it_value = ns_to_timeval(h->it_virt_value);
+	itimer.it_interval = ns_to_timeval(h->it_virt_incr);
+	ret = do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
+	if (ret < 0)
+		goto out;
+	itimer.it_value = ns_to_timeval(h->it_prof_value);
+	itimer.it_interval = ns_to_timeval(h->it_prof_incr);
+	ret = do_setitimer(ITIMER_PROF, &itimer, NULL);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 939d6f2..a09b5e5 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -581,6 +581,12 @@ struct ckpt_rlimit {
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
 	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
+	__u64 it_real_value;
+	__u64 it_real_incr;
+	__u64 it_virt_value;
+	__u64 it_virt_incr;
+	__u64 it_prof_value;
+	__u64 it_prof_incr;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index d0d6a66..7dd69c3 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -125,4 +125,13 @@ void update_rlimit_cpu(unsigned long rlim_new);
 
 int invalid_clockid(const clockid_t which_clock);
 
+static inline cputime_t prof_ticks(struct task_struct *p)
+{
+	return cputime_add(p->utime, p->stime);
+}
+static inline cputime_t virt_ticks(struct task_struct *p)
+{
+	return p->utime;
+}
+
 #endif
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 438ff45..5031bdf 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -168,15 +168,6 @@ static void bump_cpu_timer(struct k_itimer *timer,
 	}
 }
 
-static inline cputime_t prof_ticks(struct task_struct *p)
-{
-	return cputime_add(p->utime, p->stime);
-}
-static inline cputime_t virt_ticks(struct task_struct *p)
-{
-	return p->utime;
-}
-
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *tp)
 {
 	int error = check_clock(which_clock);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
