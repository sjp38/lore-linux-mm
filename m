Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MISSING_HEADERS,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10799C04A6B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 02:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 879BF20835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 02:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 879BF20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F06A16B0005; Mon,  6 May 2019 22:16:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB8C56B0006; Mon,  6 May 2019 22:16:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6536B0007; Mon,  6 May 2019 22:16:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9702E6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 22:16:30 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 94so6576970plc.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 19:16:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GeLcZdo/5beNBxirLUNRAyM7XN8sunhSI5kqtsyIDvw=;
        b=nEBD6K276FeySqFLlUFbiFhPBsAUaduHz+813nFVeXfHkdaogEmOO/N2/ttivqtFmT
         +j3fvCc2d7ZeuYu2ABjXGU0YDXc1PbrKyS3NF72Fqk7+ObKFZ5mY/mOpZVB8baE3hK93
         NCxze2zlCyNm2zzCeG6mnMI7pydsMjnV++OBMXmAgWi7YhNBjpOPIb9ldijnNsXHSntu
         ncP3K/mQjzbpTVuh2WIo8fG9sBaKK6R+EkpBUP/IGxos7Yoc0K4D4NYoDEyMfDZaL4lp
         aRUUuf/jbibEP0wboI9zwU3KF5qJ3QUQ1aUM5y3auDwT8WbGluVfIRutGNKshhgAKvcG
         XQ7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAU8AfW3xWC5IyU3hgdkfA7Rjb3jRZ1Q26C610B8mcuxNdlRNc8K
	MJ6fGxf1wpRokGBMbBYZyf+Gdk0d9xBSXisJ2B862qorDtGCs2Jq7mjpHrG+Wjn1yNOakRbYiO6
	KgNnwuJo3UmJQT7/tBkTeIGYXLFuNRIsI3AxARKAZtkhXSjUMiOtWsp9tftISLlg=
X-Received: by 2002:a63:6804:: with SMTP id d4mr36653051pgc.240.1557195390194;
        Mon, 06 May 2019 19:16:30 -0700 (PDT)
X-Received: by 2002:a63:6804:: with SMTP id d4mr36652952pgc.240.1557195388723;
        Mon, 06 May 2019 19:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557195388; cv=none;
        d=google.com; s=arc-20160816;
        b=QHBYVcdNXpQcnVkwDEkJdnIEsfnvcRsSqipG1deOoFbxgTjMyQYj9RnSWvhsOebM9o
         cmqHYK1cGX5GPg8Zw+/9wYOxqM9682dcj/x6Tc2i9cIWHQcUytOePBc+H9miElIUN1Ax
         v/gKKnS3BvKlf5LXiq72To1UdF+6KuZWdhB3GLWcpt48Z8Dbj/WobsKblq9NLbinpWCb
         iWpQqLutq2mgRqwIFnFnSm2EYSg5wcj5qFBxuAIGINIRT23Z1W3GM9uyBH8YqEvCBvB+
         NDYfWi21VAXuVcyr/QJgi4nq4FvquarZm92ISxskkbapHYEVI5LShl9cgwtrpI6fJcah
         inaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:from:date;
        bh=GeLcZdo/5beNBxirLUNRAyM7XN8sunhSI5kqtsyIDvw=;
        b=qy1ltQQO6aW2bG0AfvJe1qxcf3ZPUFS3f4WF0m1desweVUkKpkvIReuKZBUjB5HOIJ
         PfE1ZdAyIvzpzYutfl6sVhMojUaurF3Hsl1S+E2XHTvLZNOBbTG2AkpsJkVQDZrR8LB/
         KhFg49/PoFm0x584FoMvLzWN/lOzZzObvfdETUsXjDqUncZ7N31yscx5XWVapiKePVtz
         pBVpDrWjrrw4xA20sBVpSSLoYBOuL57mA+rLv4Vsz91v0TZmDhhYNjImpgBiYNkWk2og
         E7ul2UuguJ89h3bTqxUThuGB5d9IcKTrC6a35Pf9N1WFj0EcJCOQBEy0xoGbNXNvk+bL
         Xy4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k33sor11618956pgl.60.2019.05.06.19.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 19:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxttoTr39gNHG9H4p6ZIJfyhE3gOzbyBQFUXSgMokrt5R2+YrG8maRRTKExSXoTL1tMvKLwAw==
X-Received: by 2002:a63:3e47:: with SMTP id l68mr36240544pga.85.1557195388044;
        Mon, 06 May 2019 19:16:28 -0700 (PDT)
Received: from sultan-box.localdomain ([195.206.104.101])
        by smtp.gmail.com with ESMTPSA id o2sm26625604pgq.1.2019.05.06.19.16.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 19:16:26 -0700 (PDT)
Date: Mon, 6 May 2019 19:16:22 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507021622.GA27300@sultan-box.localdomain>
References: <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320015249.GC129907@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a complete low memory killer solution for Android that is small
and simple. Processes are killed according to the priorities that
Android gives them, so that the least important processes are always
killed first. Processes are killed until memory deficits are satisfied,
as observed from kswapd struggling to free up pages. Simple LMK stops
killing processes when kswapd finally goes back to sleep.

The only tunables are the desired amount of memory to be freed per
reclaim event and desired frequency of reclaim events. Simple LMK tries
to free at least the desired amount of memory per reclaim and waits
until all of its victims' memory is freed before proceeding to kill more
processes.

Signed-off-by: Sultan Alsawaf <sultan@kerneltoast.com>
---
Hello everyone,

I've addressed some of the concerns that were brought up with the first version
of the Simple LMK patch. I understand that a kernel-based solution like this
that contains policy decisions for a specific userspace is not the way to go,
but the Android ecosystem still has a pressing need for a low memory killer that
works well.

Most Android devices still use the ancient and deprecated lowmemorykiller.c
kernel driver; Simple LMK seeks to replace that, at the very least until PSI and
a userspace daemon utilizing PSI are ready for *all* Android devices, and not
just the privileged Pixel phone line.

The feedback I received last time was quite helpful. This Simple LMK patch works
significantly better than the first, improving memory management by a large
margin while being immune to transient spikes in memory usage (since the signal
to start killing processes is determined by how hard kswapd tries to free up
pages, which is something that occurs over a span of time and not a single point
in time).

I'd love to hear some feedback on this new patch. I do encourage those who are
interested to take it for a spin on an Android device. This patch has been
tested successfully on Android 4.4 and 4.9 kernels. For the sake of review here,
I have adapted the patch to 5.1.

Thanks,
Sultan

 drivers/android/Kconfig      |  33 ++++
 drivers/android/Makefile     |   1 +
 drivers/android/simple_lmk.c | 315 +++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h     |   4 +
 include/linux/simple_lmk.h   |  11 ++
 kernel/fork.c                |  13 ++
 mm/vmscan.c                  |  12 ++
 7 files changed, 389 insertions(+)
 create mode 100644 drivers/android/simple_lmk.c
 create mode 100644 include/linux/simple_lmk.h

diff --git a/drivers/android/Kconfig b/drivers/android/Kconfig
index 6fdf2abe4..bdd429338 100644
--- a/drivers/android/Kconfig
+++ b/drivers/android/Kconfig
@@ -54,6 +54,39 @@ config ANDROID_BINDER_IPC_SELFTEST
 	  exhaustively with combinations of various buffer sizes and
 	  alignments.
 
+config ANDROID_SIMPLE_LMK
+	bool "Simple Android Low Memory Killer"
+	depends on !ANDROID_LOW_MEMORY_KILLER && !MEMCG
+	---help---
+	  This is a complete low memory killer solution for Android that is
+	  small and simple. Processes are killed according to the priorities
+	  that Android gives them, so that the least important processes are
+	  always killed first. Processes are killed until memory deficits are
+	  satisfied, as observed from kswapd struggling to free up pages. Simple
+	  LMK stops killing processes when kswapd finally goes back to sleep.
+
+if ANDROID_SIMPLE_LMK
+
+config ANDROID_SIMPLE_LMK_AGGRESSION
+	int "Reclaim frequency selection"
+	range 1 3
+	default 1
+	help
+	  This value determines how frequently Simple LMK will perform memory
+	  reclaims. A lower value corresponds to less frequent reclaims, which
+	  maximizes memory usage. The range of values has a logarithmic
+	  correlation; 2 is twice as aggressive as 1, and 3 is twice as
+	  aggressive as 2, which makes 3 four times as aggressive as 1.
+
+config ANDROID_SIMPLE_LMK_MINFREE
+	int "Minimum MiB of memory to free per reclaim"
+	range 8 512
+	default 64
+	help
+	  Simple LMK will try to free at least this much memory per reclaim.
+
+endif
+
 endif # if ANDROID
 
 endmenu
diff --git a/drivers/android/Makefile b/drivers/android/Makefile
index c7856e320..7c91293b6 100644
--- a/drivers/android/Makefile
+++ b/drivers/android/Makefile
@@ -3,3 +3,4 @@ ccflags-y += -I$(src)			# needed for trace events
 obj-$(CONFIG_ANDROID_BINDERFS)		+= binderfs.o
 obj-$(CONFIG_ANDROID_BINDER_IPC)	+= binder.o binder_alloc.o
 obj-$(CONFIG_ANDROID_BINDER_IPC_SELFTEST) += binder_alloc_selftest.o
+obj-$(CONFIG_ANDROID_SIMPLE_LMK)	+= simple_lmk.o
diff --git a/drivers/android/simple_lmk.c b/drivers/android/simple_lmk.c
new file mode 100644
index 000000000..a2ffb57b5
--- /dev/null
+++ b/drivers/android/simple_lmk.c
@@ -0,0 +1,315 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2019 Sultan Alsawaf <sultan@kerneltoast.com>.
+ */
+
+#define pr_fmt(fmt) "simple_lmk: " fmt
+
+#include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/mm.h>
+#include <linux/moduleparam.h>
+#include <linux/oom.h>
+#include <linux/sort.h>
+#include <linux/version.h>
+
+/* The sched_param struct is located elsewhere in newer kernels */
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 10, 0)
+#include <uapi/linux/sched/types.h>
+#endif
+
+/* SEND_SIG_FORCED isn't present in newer kernels */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 19, 0)
+#define SIG_INFO_TYPE SEND_SIG_FORCED
+#else
+#define SIG_INFO_TYPE SEND_SIG_PRIV
+#endif
+
+/* The minimum number of pages to free per reclaim */
+#define MIN_FREE_PAGES (CONFIG_ANDROID_SIMPLE_LMK_MINFREE * SZ_1M / PAGE_SIZE)
+
+/* Kill up to this many victims per reclaim. This is limited by stack size. */
+#define MAX_VICTIMS 64
+
+struct victim_info {
+	struct task_struct *tsk;
+	unsigned long size;
+};
+
+/* Pulled from the Android framework. Lower ADJ means higher priority. */
+static const short int adj_prio[] = {
+	906, /* CACHED_APP_MAX_ADJ */
+	905, /* Cached app */
+	904, /* Cached app */
+	903, /* Cached app */
+	902, /* Cached app */
+	901, /* Cached app */
+	900, /* CACHED_APP_MIN_ADJ */
+	800, /* SERVICE_B_ADJ */
+	700, /* PREVIOUS_APP_ADJ */
+	600, /* HOME_APP_ADJ */
+	500, /* SERVICE_ADJ */
+	400, /* HEAVY_WEIGHT_APP_ADJ */
+	300, /* BACKUP_APP_ADJ */
+	200, /* PERCEPTIBLE_APP_ADJ */
+	100, /* VISIBLE_APP_ADJ */
+	0    /* FOREGROUND_APP_ADJ */
+};
+
+static DECLARE_WAIT_QUEUE_HEAD(oom_waitq);
+static bool needs_reclaim;
+
+static int victim_info_cmp(const void *lhs_ptr, const void *rhs_ptr)
+{
+	const struct victim_info *lhs = (typeof(lhs))lhs_ptr;
+	const struct victim_info *rhs = (typeof(rhs))rhs_ptr;
+
+	return rhs->size - lhs->size;
+}
+
+static bool mm_is_duplicate(struct victim_info *varr, int vlen,
+			    struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < vlen; i++) {
+		if (varr[i].tsk->mm == mm)
+			return true;
+	}
+
+	return false;
+}
+
+static bool vtsk_is_duplicate(struct victim_info *varr, int vlen,
+			      struct task_struct *vtsk)
+{
+	int i;
+
+	for (i = 0; i < vlen; i++) {
+		if (same_thread_group(varr[i].tsk, vtsk))
+			return true;
+	}
+
+	return false;
+}
+
+static unsigned long find_victims(struct victim_info *varr, int *vindex,
+				  int vmaxlen, int min_adj, int max_adj)
+{
+	unsigned long pages_found = 0;
+	int old_vindex = *vindex;
+	struct task_struct *tsk;
+
+	for_each_process(tsk) {
+		struct task_struct *vtsk;
+		unsigned long tasksize;
+		short oom_score_adj;
+
+		/* Make sure there's space left in the victim array */
+		if (*vindex == vmaxlen)
+			break;
+
+		/* Don't kill current, kthreads, init, or duplicates */
+		if (same_thread_group(tsk, current) ||
+		    tsk->flags & PF_KTHREAD ||
+		    is_global_init(tsk) ||
+		    vtsk_is_duplicate(varr, *vindex, tsk))
+			continue;
+
+		vtsk = find_lock_task_mm(tsk);
+		if (!vtsk)
+			continue;
+
+		/* Skip tasks that lack memory or have a redundant mm */
+		if (test_tsk_thread_flag(vtsk, TIF_MEMDIE) ||
+		    mm_is_duplicate(varr, *vindex, vtsk->mm))
+			goto unlock_mm;
+
+		/* Check the task's importance (adj) to see if it's in range */
+		oom_score_adj = vtsk->signal->oom_score_adj;
+		if (oom_score_adj < min_adj || oom_score_adj > max_adj)
+			goto unlock_mm;
+
+		/* Get the total number of physical pages in use by the task */
+		tasksize = get_mm_rss(vtsk->mm);
+		if (!tasksize)
+			goto unlock_mm;
+
+		/* Store this potential victim away for later */
+		varr[*vindex].tsk = vtsk;
+		varr[*vindex].size = tasksize;
+		(*vindex)++;
+
+		/* Keep track of the number of pages that have been found */
+		pages_found += tasksize;
+		continue;
+
+unlock_mm:
+		task_unlock(vtsk);
+	}
+
+	/*
+	 * Sort the victims in descending order of size to prioritize killing
+	 * the larger ones first.
+	 */
+	if (pages_found)
+		sort(&varr[old_vindex], *vindex - old_vindex, sizeof(*varr),
+		     victim_info_cmp, NULL);
+
+	return pages_found;
+}
+
+static void scan_and_kill(unsigned long pages_needed)
+{
+	static DECLARE_WAIT_QUEUE_HEAD(victim_waitq);
+	struct victim_info victims[MAX_VICTIMS];
+	int i, nr_to_kill = 0, nr_victims = 0;
+	unsigned long pages_found = 0;
+	atomic_t victim_count;
+
+	/*
+	 * Hold the tasklist lock so tasks don't disappear while scanning. This
+	 * is preferred to holding an RCU read lock so that the list of tasks
+	 * is guaranteed to be up to date. Keep preemption disabled until the
+	 * SIGKILLs are sent so the victim kill process isn't interrupted.
+	 */
+	read_lock(&tasklist_lock);
+	preempt_disable();
+	for (i = 1; i < ARRAY_SIZE(adj_prio); i++) {
+		pages_found += find_victims(victims, &nr_victims, MAX_VICTIMS,
+					    adj_prio[i], adj_prio[i - 1]);
+		if (pages_found >= pages_needed || nr_victims == MAX_VICTIMS)
+			break;
+	}
+
+	/*
+	 * Calculate the number of tasks that need to be killed and quickly
+	 * release the references to those that'll live.
+	 */
+	for (i = 0, pages_found = 0; i < nr_victims; i++) {
+		struct victim_info *victim = &victims[i];
+		struct task_struct *vtsk = victim->tsk;
+
+		/* The victims' mm lock is taken in find_victims; release it */
+		if (pages_found >= pages_needed) {
+			task_unlock(vtsk);
+			continue;
+		}
+
+		/*
+		 * Grab a reference to the victim so it doesn't disappear after
+		 * the tasklist lock is released.
+		 */
+		get_task_struct(vtsk);
+		pages_found += victim->size;
+		nr_to_kill++;
+	}
+	read_unlock(&tasklist_lock);
+
+	/* Kill the victims */
+	victim_count = (atomic_t)ATOMIC_INIT(nr_to_kill);
+	for (i = 0; i < nr_to_kill; i++) {
+		struct victim_info *victim = &victims[i];
+		struct task_struct *vtsk = victim->tsk;
+
+		pr_info("Killing %s with adj %d to free %lu kiB\n", vtsk->comm,
+			vtsk->signal->oom_score_adj,
+			victim->size << (PAGE_SHIFT - 10));
+
+		/* Configure the victim's mm to notify us when it's freed */
+		vtsk->mm->slmk_waitq = &victim_waitq;
+		vtsk->mm->slmk_counter = &victim_count;
+
+		/* Accelerate the victim's death by forcing the kill signal */
+		do_send_sig_info(SIGKILL, SIG_INFO_TYPE, vtsk, true);
+
+		/* Finally release the victim's mm lock */
+		task_unlock(vtsk);
+	}
+	preempt_enable_no_resched();
+
+	/* Try to speed up the death process now that we can schedule again */
+	for (i = 0; i < nr_to_kill; i++) {
+		struct task_struct *vtsk = victims[i].tsk;
+
+		/* Increase the victim's priority to make it die faster */
+		set_user_nice(vtsk, MIN_NICE);
+
+		/* Allow the victim to run on any CPU */
+		set_cpus_allowed_ptr(vtsk, cpu_all_mask);
+
+		/* Finally release the victim reference acquired earlier */
+		put_task_struct(vtsk);
+	}
+
+	/* Wait until all the victims die */
+	wait_event(victim_waitq, !atomic_read(&victim_count));
+}
+
+static int simple_lmk_reclaim_thread(void *data)
+{
+	static const struct sched_param sched_max_rt_prio = {
+		.sched_priority = MAX_RT_PRIO - 1
+	};
+
+	sched_setscheduler_nocheck(current, SCHED_FIFO, &sched_max_rt_prio);
+
+	while (1) {
+		bool should_stop;
+
+		wait_event(oom_waitq, (should_stop = kthread_should_stop()) ||
+				      READ_ONCE(needs_reclaim));
+
+		if (should_stop)
+			break;
+
+		/*
+		 * Kill a batch of processes and wait for their memory to be
+		 * freed. After their memory is freed, sleep for 20 ms to give
+		 * OOM'd allocations a chance to scavenge for the newly-freed
+		 * pages. Rinse and repeat while there are still OOM'd
+		 * allocations.
+		 */
+		do {
+			scan_and_kill(MIN_FREE_PAGES);
+			msleep(20);
+		} while (READ_ONCE(needs_reclaim));
+	}
+
+	return 0;
+}
+
+void simple_lmk_start_reclaim(void)
+{
+	WRITE_ONCE(needs_reclaim, true);
+	wake_up(&oom_waitq);
+}
+
+void simple_lmk_stop_reclaim(void)
+{
+	WRITE_ONCE(needs_reclaim, false);
+}
+
+/* Initialize Simple LMK when lmkd in Android writes to the minfree parameter */
+static int simple_lmk_init_set(const char *val, const struct kernel_param *kp)
+{
+	static atomic_t init_done = ATOMIC_INIT(0);
+	struct task_struct *thread;
+
+	if (atomic_cmpxchg(&init_done, 0, 1))
+		return 0;
+
+	thread = kthread_run(simple_lmk_reclaim_thread, NULL, "simple_lmkd");
+	BUG_ON(IS_ERR(thread));
+
+	return 0;
+}
+
+static const struct kernel_param_ops simple_lmk_init_ops = {
+	.set = simple_lmk_init_set
+};
+
+/* Needed to prevent Android from thinking there's no LMK and thus rebooting */
+#undef MODULE_PARAM_PREFIX
+#define MODULE_PARAM_PREFIX "lowmemorykiller."
+module_param_cb(minfree, &simple_lmk_init_ops, NULL, 0200);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4ef4bbe78..a02852d6d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -501,6 +501,10 @@ struct mm_struct {
 #if IS_ENABLED(CONFIG_HMM)
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
+#endif
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+		wait_queue_head_t *slmk_waitq;
+		atomic_t *slmk_counter;
 #endif
 	} __randomize_layout;
 
diff --git a/include/linux/simple_lmk.h b/include/linux/simple_lmk.h
new file mode 100644
index 000000000..e2cd56f1f
--- /dev/null
+++ b/include/linux/simple_lmk.h
@@ -0,0 +1,11 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (C) 2019 Sultan Alsawaf <sultan@kerneltoast.com>.
+ */
+#ifndef _SIMPLE_LMK_H_
+#define _SIMPLE_LMK_H_
+
+void simple_lmk_start_reclaim(void);
+void simple_lmk_stop_reclaim(void);
+
+#endif /* _SIMPLE_LMK_H_ */
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa2..f41bef5fe 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -995,6 +995,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->pmd_huge_pte = NULL;
 #endif
 	mm_init_uprobes_state(mm);
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+	mm->slmk_waitq = NULL;
+#endif
 
 	if (current->mm) {
 		mm->flags = current->mm->flags & MMF_INIT_MASK;
@@ -1037,6 +1040,10 @@ struct mm_struct *mm_alloc(void)
 
 static inline void __mmput(struct mm_struct *mm)
 {
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+	wait_queue_head_t *slmk_waitq = mm->slmk_waitq;
+	atomic_t *slmk_counter = mm->slmk_counter;
+#endif
 	VM_BUG_ON(atomic_read(&mm->mm_users));
 
 	uprobe_clear_state(mm);
@@ -1054,6 +1061,12 @@ static inline void __mmput(struct mm_struct *mm)
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
 	mmdrop(mm);
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+	if (slmk_waitq) {
+		atomic_dec(slmk_counter);
+		wake_up(slmk_waitq);
+	}
+#endif
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a815f73ee..f4fb91b53 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -51,6 +51,7 @@
 #include <linux/printk.h>
 #include <linux/dax.h>
 #include <linux/psi.h>
+#include <linux/simple_lmk.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -3541,6 +3542,11 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		bool balanced;
 		bool ret;
 
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+		if (sc.priority == CONFIG_ANDROID_SIMPLE_LMK_AGGRESSION)
+			simple_lmk_start_reclaim();
+#endif
+
 		sc.reclaim_idx = classzone_idx;
 
 		/*
@@ -3737,6 +3743,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	 * succeed.
 	 */
 	if (prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+		simple_lmk_stop_reclaim();
+#endif
 		/*
 		 * Compaction records what page blocks it recently failed to
 		 * isolate pages from and skips them in the future scanning.
@@ -3773,6 +3782,9 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 	 */
 	if (!remaining &&
 	    prepare_kswapd_sleep(pgdat, reclaim_order, classzone_idx)) {
+#ifdef CONFIG_ANDROID_SIMPLE_LMK
+		simple_lmk_stop_reclaim();
+#endif
 		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 
 		/*
-- 
2.21.0

