Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9253C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 02:35:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 180CF217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 02:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="agWp14HF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 180CF217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C9FA8E00A5; Tue,  5 Feb 2019 21:35:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6542B8E001C; Tue,  5 Feb 2019 21:35:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A7768E00A5; Tue,  5 Feb 2019 21:35:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E42198E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 21:35:04 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so3626287pgi.14
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 18:35:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ApKCEzo8RhYd2Jky/u2pYoeIXX1Nl4FeNibEZamIk9M=;
        b=siEbE01phtQJ2YyCcaNN1IiIkpihX5gienRydaLKEvNe00MPtPhDRlHbhomLlZGePJ
         j05R67gYT2Unna41iKRHkfJ/7Sd5W4B0fsqtECRrQxHxN6LKRlrWJa1kkZMFVo+1QJsi
         57LBwArDe73aOXqPvqSFD+knu1/RQp5DT1kJzn3fU3FiiwBpLuBC2bTUBXs0Kt2qjslA
         otm8pRqlAPldBuA5YOZor/TIgiuiMr8QAgC6yWh+GrUIwNKnf5H3lajV60hh0UTgSNIq
         31CsrTzAgrufyQu+EOgje3hO+W+KXjKO03LMq7g3+kNuqI586RkwxYE8WuG+6IEc2yIL
         efLg==
X-Gm-Message-State: AHQUAuYnsvFnqpWPjsaY6KcixNky8s1SbdTZl1Ix4xNFGXZplHMBQStI
	qReJkYiqz35/x8wfLIN/BqZW87PdZiV7GifyRRH4QEpy94fwsk+IOPDSg7xprvl1RqxW4BpkwFm
	jhTcUs2Jnujl6IJUeWNFIf1XUmm0UVxhuQzCVyllApZyXpW3ndGYP/mO5lDvZ7sWPoZfTeutI56
	rjl6Iw8OF1BmM06xQLbJ5jdx2AbA6IOF+I8KZyAMY0rhr20OMir5LTfD986BiSjMVMJqUdtxnWo
	yXmDHs9dfRHL6b9Nx9VOyIMEWofuBKCdX0GEirHA6ikidkdu8xf73akyIzzjFUP/qozvDfk+/Y3
	gtCTydi87AgsAD2oA69K9AAEDmoWEBskSgyOkZ2/JLIKM9ATdE5Tl5NN0SmzPOilxTbodBABlDO
	/
X-Received: by 2002:a62:3141:: with SMTP id x62mr8129203pfx.12.1549420504263;
        Tue, 05 Feb 2019 18:35:04 -0800 (PST)
X-Received: by 2002:a62:3141:: with SMTP id x62mr8128982pfx.12.1549420500410;
        Tue, 05 Feb 2019 18:35:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549420500; cv=none;
        d=google.com; s=arc-20160816;
        b=m0dbr75fO33p0mQbxQK0GFAaw/2q6btJUqbvrCP3qRN7CcAE8cE4+32/eMZ5P70CZY
         CZD0ERj72bt8VPlu1GqoHYmhxhi6SpWbWINdYIBiK8XoBadjM5zeT2VgerN79rWXKf7e
         U/EE69rFAObZXPsrDE74OGV9zOWHUvCaRv58V+Z0RaCF9j5LioUxT6JfORotghvdjYzQ
         pCWS2Sh2+iCP0mCo3I11Co4tx/2cz+7r0itLbWecATkyKOruffXdwLz80VfhgD5F0iSO
         SnMeoDMxpa+NeyyAjboLa5SkyybgXNp36W3xZJvO9RrDT8cJcd9AGGFUcRCd4zIvoTkB
         sC0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ApKCEzo8RhYd2Jky/u2pYoeIXX1Nl4FeNibEZamIk9M=;
        b=NA49OBl4Gj2y0O+PNmBfVlviixwx4DhbKd7o76cRSPVBbSF+q62CaT85zs5czUnvS0
         UWk111NkSREaGL/MqmbdkV4TPWLFdi6KiEsxRgSbePrzF+Tb818t/lzT1HFbjQ59YE9/
         HMRSxV5+Hu2cvjDFfyk7aEcasx7rKqvHirZfHw4IvDqV3HkUfvdJvt833xD6+RBrYDID
         mrq7i9ZMDHS1aWp3r2YTO7/55d8FJdxd+ScEvXnPGU0K+nk3GCNmQAYLVxjqO8kSUfY8
         BgZIfdPUuDFDcsTIZC5fG6PcGHEMrmB9lZ6PgzxJGcxqi+JGc6fJ/bljaaEY34yW4Slp
         AbHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=agWp14HF;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor7288968plo.56.2019.02.05.18.35.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 18:35:00 -0800 (PST)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=agWp14HF;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ApKCEzo8RhYd2Jky/u2pYoeIXX1Nl4FeNibEZamIk9M=;
        b=agWp14HFiOLZO45M2BpSB7s1w7kG3D3c98BgKK54IlfrWf6reLeELjTy3eqKXklD8o
         dQGxrjmvRxtpXnfrkXGqyHHcFYXraX51LnXgKCg3N7Doz7BFmO0sHPGp9vk0kBKACrLD
         J7djI1oBNd00VVSWlvvwDYkcDu6dvhxz0lcYDCtTVj78w6lNCbAydOmTe0Rd5VhLhAWW
         LoQDKSJ4JSHjtYb/1krgNGSFS1AuyjaFutUwaou4pcPRhGLULC2i8gYNtqO+f1jUhw1I
         HrWfSvFZQgccXykpLy4RsIyK/lkPjY2m0mGMytuUMpefPeShEbrBoB//0DLXOctCa7mO
         al7A==
X-Google-Smtp-Source: AHgI3IaN/oyoJISr5usvYncbOg3giDKskU77Xv9iT1jncDlZrvDrQTfVoZaFhs4u76goixtpjc+Ovw==
X-Received: by 2002:a17:902:8b81:: with SMTP id ay1mr1877863plb.320.1549420499013;
        Tue, 05 Feb 2019 18:34:59 -0800 (PST)
Received: from surenb0.mtv.corp.google.com ([2620:0:1000:1612:3320:4357:47df:276b])
        by smtp.googlemail.com with ESMTPSA id o2sm6173221pgq.90.2019.02.05.18.34.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 18:34:58 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org,
	lizefan@huawei.com,
	hannes@cmpxchg.org,
	axboe@kernel.dk,
	dennis@kernel.org,
	dennisszhou@gmail.com,
	mingo@redhat.com,
	peterz@infradead.org,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@android.com,
	Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH v4 1/1] psi: introduce psi monitor
Date: Tue,  5 Feb 2019 18:34:46 -0800
Message-Id: <20190206023446.177362-1-surenb@google.com>
X-Mailer: git-send-email 2.20.1.611.gfbb209baf1-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Psi monitor aims to provide a low-latency short-term pressure
detection mechanism configurable by users. It allows users to
monitor psi metrics growth and trigger events whenever a metric
raises above user-defined threshold within user-defined time window.

Time window and threshold are both expressed in usecs. Multiple psi
resources with different thresholds and window sizes can be monitored
concurrently.

Psi monitors activate when system enters stall state for the monitored
psi metric and deactivate upon exit from the stall state. While system
is in the stall state psi signal growth is monitored at a rate of 10 times
per tracking window. Min window size is 500ms, therefore the min monitoring
interval is 50ms. Max window size is 10s with monitoring interval of 1s.

When activated psi monitor stays active for at least the duration of one
tracking window to avoid repeated activations/deactivations when psi
signal is bouncing.

Notifications to the users are rate-limited to one per tracking window.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

This is respin of:
  https://lwn.net/ml/linux-kernel/20190124211518.244221-1-surenb%40google.com/

First 4 patches in the series are in linux-next:
1. fs: kernfs: add poll file operation
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=6a78cef7ad8a1734477a1352dd04a97f1dc58a70
2. kernel: cgroup: add poll file operation
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=c88177361203be291a49956b6c9d5ec164ea24b2
3. psi: introduce state_mask to represent stalled psi states
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=9d8a0c4a7f1c197de9c12bd53ef45fb6d273374e
4. psi: rename psi fields in preparation for psi trigger addition
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=0ef9bb049a4db519152a8664088f7ce34bbee5ac


This patch can be cleanly applied either over linux-next tree (tag: next-20190201)
or over linux-stable v5.0-rc4 after applying abovementioned 4 patches.


Changes in v4:
- Resolved conflict with "psi: fix aggregation idle shut-off" patch, as per Andrew Morton
- Replaced smp_mb__after_atomic() with smp_mb() for proper ordering, as per Peter
- Moved now=sched_clock() in psi_update_work() after mutex acquisition, as per Peter
- Expanded comments to explain why smp_mb() is needed in psi_update_work, as per Peter
- Fixed g->polling operation order in the diagram above psi_update_work(), as per Johannes
- Merged psi_trigger_parse() into psi_trigger_create(), as per Johannes 
- Replaced list_del_init with list_del in psi_trigger_destroy(), as per Minchan
- Replaced return value in get_recent_times and collect_percpu_times to
return-by-parameter, as per Minchan
- Renamed window_init into window_reset and reused it, as per Minchan
- Replaced kzalloc with kmalloc, as per Minchan
- Added explanation in psi.txt for min/max window size choices, as per Minchan
- Misc variable name cleanups, as per Minchan and Johannes

 Documentation/accounting/psi.txt | 107 ++++++
 include/linux/psi.h              |   8 +
 include/linux/psi_types.h        |  59 ++++
 kernel/cgroup/cgroup.c           |  95 +++++-
 kernel/sched/psi.c               | 559 +++++++++++++++++++++++++++++--
 5 files changed, 794 insertions(+), 34 deletions(-)

diff --git a/Documentation/accounting/psi.txt b/Documentation/accounting/psi.txt
index b8ca28b60215..4fb40fe94828 100644
--- a/Documentation/accounting/psi.txt
+++ b/Documentation/accounting/psi.txt
@@ -63,6 +63,110 @@ tracked and exported as well, to allow detection of latency spikes
 which wouldn't necessarily make a dent in the time averages, or to
 average trends over custom time frames.
 
+Monitoring for pressure thresholds
+==================================
+
+Users can register triggers and use poll() to be woken up when resource
+pressure exceeds certain thresholds.
+
+A trigger describes the maximum cumulative stall time over a specific
+time window, e.g. 100ms of total stall time within any 500ms window to
+generate a wakeup event.
+
+To register a trigger user has to open psi interface file under
+/proc/pressure/ representing the resource to be monitored and write the
+desired threshold and time window. The open file descriptor should be
+used to wait for trigger events using select(), poll() or epoll().
+The following format is used:
+
+<some|full> <stall amount in us> <time window in us>
+
+For example writing "some 150000 1000000" into /proc/pressure/memory
+would add 150ms threshold for partial memory stall measured within
+1sec time window. Writing "full 50000 1000000" into /proc/pressure/io
+would add 50ms threshold for full io stall measured within 1sec time window.
+
+Triggers can be set on more than one psi metric and more than one trigger
+for the same psi metric can be specified. However for each trigger a separate
+file descriptor is required to be able to poll it separately from others,
+therefore for each trigger a separate open() syscall should be made even
+when opening the same psi interface file.
+
+Monitors activate only when system enters stall state for the monitored
+psi metric and deactivates upon exit from the stall state. While system is
+in the stall state psi signal growth is monitored at a rate of 10 times per
+tracking window.
+
+The kernel accepts window sizes ranging from 500ms to 10s, therefore min
+monitoring update interval is 50ms and max is 1s. Min limit is set to
+prevent overly frequent polling. Max limit is chosen as a high enough number
+after which monitors are most likely not needed and psi averages can be used
+instead.
+
+When activated, psi monitor stays active for at least the duration of one
+tracking window to avoid repeated activations/deactivations when system is
+bouncing in and out of the stall state.
+
+Notifications to the userspace are rate-limited to one per tracking window.
+
+The trigger will de-register when the file descriptor used to define the
+trigger  is closed.
+
+Userspace monitor usage example
+===============================
+
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <poll.h>
+#include <string.h>
+#include <unistd.h>
+
+/*
+ * Monitor memory partial stall with 1s tracking window size
+ * and 150ms threshold.
+ */
+int main() {
+	const char trig[] = "some 150000 1000000";
+	struct pollfd fds;
+	int n;
+
+	fds.fd = open("/proc/pressure/memory", O_RDWR | O_NONBLOCK);
+	if (fds.fd < 0) {
+		printf("/proc/pressure/memory open error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+	fds.events = POLLPRI;
+
+	if (write(fds.fd, trig, strlen(trig) + 1) < 0) {
+		printf("/proc/pressure/memory write error: %s\n",
+			strerror(errno));
+		return 1;
+	}
+
+	printf("waiting for events...\n");
+	while (1) {
+		n = poll(&fds, 1, -1);
+		if (n < 0) {
+			printf("poll error: %s\n", strerror(errno));
+			return 1;
+		}
+		if (fds.revents & POLLERR) {
+			printf("got POLLERR, event source is gone\n");
+			return 0;
+		}
+		if (fds.revents & POLLPRI) {
+			printf("event triggered!\n");
+		} else {
+			printf("unknown event received: 0x%x\n", fds.revents);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 Cgroup2 interface
 =================
 
@@ -71,3 +175,6 @@ mounted, pressure stall information is also tracked for tasks grouped
 into cgroups. Each subdirectory in the cgroupfs mountpoint contains
 cpu.pressure, memory.pressure, and io.pressure files; the format is
 the same as the /proc/pressure/ files.
+
+Per-cgroup psi monitors can be specified and used the same way as
+system-wide ones.
diff --git a/include/linux/psi.h b/include/linux/psi.h
index 7006008d5b72..e9029e19e60c 100644
--- a/include/linux/psi.h
+++ b/include/linux/psi.h
@@ -4,6 +4,7 @@
 #include <linux/jump_label.h>
 #include <linux/psi_types.h>
 #include <linux/sched.h>
+#include <linux/poll.h>
 
 struct seq_file;
 struct css_set;
@@ -26,6 +27,13 @@ int psi_show(struct seq_file *s, struct psi_group *group, enum psi_res res);
 int psi_cgroup_alloc(struct cgroup *cgrp);
 void psi_cgroup_free(struct cgroup *cgrp);
 void cgroup_move_task(struct task_struct *p, struct css_set *to);
+
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+			char *buf, size_t nbytes, enum psi_res res);
+void psi_trigger_destroy(struct psi_trigger *t);
+
+__poll_t psi_trigger_poll(struct psi_trigger *t, struct file *file,
+			poll_table *wait);
 #endif
 
 #else /* CONFIG_PSI */
diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
index 47757668bdcb..92750524af27 100644
--- a/include/linux/psi_types.h
+++ b/include/linux/psi_types.h
@@ -3,6 +3,7 @@
 
 #include <linux/seqlock.h>
 #include <linux/types.h>
+#include <linux/wait.h>
 
 #ifdef CONFIG_PSI
 
@@ -68,6 +69,50 @@ struct psi_group_cpu {
 	u32 times_prev[NR_PSI_STATES] ____cacheline_aligned_in_smp;
 };
 
+/* PSI growth tracking window */
+struct psi_window {
+	/* Window size in ns */
+	u64 size;
+
+	/* Start time of the current window in ns */
+	u64 start_time;
+
+	/* Value at the start of the window */
+	u64 start_value;
+
+	/* Value growth in the previous window */
+	u64 prev_growth;
+};
+
+struct psi_trigger {
+	/* PSI state being monitored by the trigger */
+	enum psi_states state;
+
+	/* User-spacified threshold in ns */
+	u64 threshold;
+
+	/* List node inside triggers list */
+	struct list_head node;
+
+	/* Backpointer needed during trigger destruction */
+	struct psi_group *group;
+
+	/* Wait queue for polling */
+	wait_queue_head_t event_wait;
+
+	/* Pending event flag */
+	int event;
+
+	/* Tracking window */
+	struct psi_window win;
+
+	/*
+	 * Time last event was generated. Used for rate-limiting
+	 * events to one per window
+	 */
+	u64 last_event_time;
+};
+
 struct psi_group {
 	/* Protects data used by the aggregator */
 	struct mutex update_lock;
@@ -75,6 +120,8 @@ struct psi_group {
 	/* Per-cpu task state & time tracking */
 	struct psi_group_cpu __percpu *pcpu;
 
+	/* Periodic work control */
+	atomic_t polling;
 	struct delayed_work clock_work;
 
 	/* Total stall times observed */
@@ -85,6 +132,18 @@ struct psi_group {
 	u64 avg_last_update;
 	u64 avg_next_update;
 	unsigned long avg[NR_PSI_STATES - 1][3];
+
+	/* Configured polling triggers */
+	struct list_head triggers;
+	u32 nr_triggers[NR_PSI_STATES - 1];
+	u32 trigger_states;
+	u64 trigger_min_period;
+
+	/* Polling state */
+	/* Total stall times at the start of monitor activation */
+	u64 polling_total[NR_PSI_STATES - 1];
+	u64 polling_next_update;
+	u64 polling_until;
 };
 
 #else /* CONFIG_PSI */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 1e9e39a1dd6c..ee360881afcc 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3526,7 +3526,89 @@ static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
 {
 	return psi_show(seq, &seq_css(seq)->cgroup->psi, PSI_CPU);
 }
-#endif
+
+static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
+					  size_t nbytes, enum psi_res res)
+{
+	struct psi_trigger *old;
+	struct psi_trigger *new;
+	struct cgroup *cgrp;
+
+	cgrp = cgroup_kn_lock_live(of->kn, false);
+	if (!cgrp)
+		return -ENODEV;
+
+	cgroup_get(cgrp);
+	cgroup_kn_unlock(of->kn);
+
+	new = psi_trigger_create(&cgrp->psi, buf, nbytes, res);
+	if (IS_ERR(new)) {
+		cgroup_put(cgrp);
+		return PTR_ERR(new);
+	}
+
+	old = of->priv;
+	rcu_assign_pointer(of->priv, new);
+	if (old) {
+		synchronize_rcu();
+		psi_trigger_destroy(old);
+	}
+
+	cgroup_put(cgrp);
+
+	return nbytes;
+}
+
+static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
+}
+
+static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
+}
+
+static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
+					  char *buf, size_t nbytes,
+					  loff_t off)
+{
+	return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
+}
+
+static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
+					  poll_table *pt)
+{
+	struct psi_trigger *t;
+	__poll_t ret;
+
+	rcu_read_lock();
+	t = rcu_dereference(of->priv);
+	if (t)
+		ret = psi_trigger_poll(t, of->file, pt);
+	else
+		ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+static void cgroup_pressure_release(struct kernfs_open_file *of)
+{
+	struct psi_trigger *t = of->priv;
+
+	if (!t)
+		return;
+
+	rcu_assign_pointer(of->priv, NULL);
+	synchronize_rcu();
+	psi_trigger_destroy(t);
+}
+#endif /* CONFIG_PSI */
 
 static int cgroup_file_open(struct kernfs_open_file *of)
 {
@@ -4681,18 +4763,27 @@ static struct cftype cgroup_base_files[] = {
 		.name = "io.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_io_pressure_show,
+		.write = cgroup_io_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "memory.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_memory_pressure_show,
+		.write = cgroup_memory_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
 	{
 		.name = "cpu.pressure",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cgroup_cpu_pressure_show,
+		.write = cgroup_cpu_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
 	},
-#endif
+#endif /* CONFIG_PSI */
 	{ }	/* terminate */
 };
 
diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 5bc3b3a171a6..fa7e930ac56b 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -4,6 +4,9 @@
  * Copyright (c) 2018 Facebook, Inc.
  * Author: Johannes Weiner <hannes@cmpxchg.org>
  *
+ * Polling support by Suren Baghdasaryan <surenb@google.com>
+ * Copyright (c) 2018 Google, Inc.
+ *
  * When CPU, memory and IO are contended, tasks experience delays that
  * reduce throughput and introduce latencies into the workload. Memory
  * and IO contention, in addition, can cause a full loss of forward
@@ -127,11 +130,16 @@
 #include "../workqueue_internal.h"
 #include <linux/sched/loadavg.h>
 #include <linux/seq_file.h>
+#include <linux/eventfd.h>
 #include <linux/proc_fs.h>
 #include <linux/seqlock.h>
+#include <linux/uaccess.h>
 #include <linux/cgroup.h>
 #include <linux/module.h>
 #include <linux/sched.h>
+#include <linux/ctype.h>
+#include <linux/file.h>
+#include <linux/poll.h>
 #include <linux/psi.h>
 #include "sched.h"
 
@@ -151,11 +159,16 @@ static int __init setup_psi(char *str)
 __setup("psi=", setup_psi);
 
 /* Running averages - we need to be higher-res than loadavg */
-#define PSI_FREQ	(2*HZ+1)	/* 2 sec intervals */
+#define PSI_FREQ	(2*HZ+1UL)	/* 2 sec intervals */
 #define EXP_10s		1677		/* 1/exp(2s/10s) as fixed-point */
 #define EXP_60s		1981		/* 1/exp(2s/60s) */
 #define EXP_300s	2034		/* 1/exp(2s/300s) */
 
+/* PSI trigger definitions */
+#define WINDOW_MIN_US 500000	/* Min window size is 500ms */
+#define WINDOW_MAX_US 10000000	/* Max window size is 10s */
+#define UPDATES_PER_WINDOW 10	/* 10 updates per window */
+
 /* Sampling frequency in nanoseconds */
 static u64 psi_period __read_mostly;
 
@@ -174,8 +187,17 @@ static void group_init(struct psi_group *group)
 	for_each_possible_cpu(cpu)
 		seqcount_init(&per_cpu_ptr(group->pcpu, cpu)->seq);
 	group->avg_next_update = sched_clock() + psi_period;
+	atomic_set(&group->polling, 0);
 	INIT_DELAYED_WORK(&group->clock_work, psi_update_work);
 	mutex_init(&group->update_lock);
+	/* Init trigger-related members */
+	INIT_LIST_HEAD(&group->triggers);
+	memset(group->nr_triggers, 0, sizeof(group->nr_triggers));
+	group->trigger_states = 0;
+	group->trigger_min_period = U32_MAX;
+	memset(group->polling_total, 0, sizeof(group->polling_total));
+	group->polling_next_update = ULLONG_MAX;
+	group->polling_until = 0;
 }
 
 void __init psi_init(void)
@@ -210,7 +232,8 @@ static bool test_state(unsigned int *tasks, enum psi_states state)
 	}
 }
 
-static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
+static void get_recent_times(struct psi_group *group, int cpu, u32 *times,
+							 u32 *pchanged_states)
 {
 	struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
 	u64 now, state_start;
@@ -218,6 +241,8 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 	unsigned int seq;
 	u32 state_mask;
 
+	*pchanged_states = 0;
+
 	/* Snapshot a coherent view of the CPU state */
 	do {
 		seq = read_seqcount_begin(&groupc->seq);
@@ -246,6 +271,8 @@ static void get_recent_times(struct psi_group *group, int cpu, u32 *times)
 		groupc->times_prev[s] = times[s];
 
 		times[s] = delta;
+		if (delta)
+			*pchanged_states |= (1 << s);
 	}
 }
 
@@ -269,17 +296,14 @@ static void calc_avgs(unsigned long avg[3], int missed_periods,
 	avg[2] = calc_load(avg[2], EXP_300s, pct);
 }
 
-static bool update_stats(struct psi_group *group)
+static void collect_percpu_times(struct psi_group *group, u32 *pchanged_states)
 {
 	u64 deltas[NR_PSI_STATES - 1] = { 0, };
-	unsigned long missed_periods = 0;
 	unsigned long nonidle_total = 0;
-	u64 now, expires, period;
+	u32 changed_states = 0;
 	int cpu;
 	int s;
 
-	mutex_lock(&group->update_lock);
-
 	/*
 	 * Collect the per-cpu time buckets and average them into a
 	 * single time sample that is normalized to wallclock time.
@@ -291,8 +315,10 @@ static bool update_stats(struct psi_group *group)
 	for_each_possible_cpu(cpu) {
 		u32 times[NR_PSI_STATES];
 		u32 nonidle;
+		u32 cpu_changed_states;
 
-		get_recent_times(group, cpu, times);
+		get_recent_times(group, cpu, times, &cpu_changed_states);
+		changed_states |= cpu_changed_states;
 
 		nonidle = nsecs_to_jiffies(times[PSI_NONIDLE]);
 		nonidle_total += nonidle;
@@ -317,11 +343,19 @@ static bool update_stats(struct psi_group *group)
 	for (s = 0; s < NR_PSI_STATES - 1; s++)
 		group->total[s] += div_u64(deltas[s], max(nonidle_total, 1UL));
 
+	if (pchanged_states)
+		*pchanged_states = changed_states;
+}
+
+static u64 update_averages(struct psi_group *group, u64 now)
+{
+	unsigned long missed_periods = 0;
+	u64 expires, period;
+	u64 avg_next_update;
+	int s;
+
 	/* avgX= */
-	now = sched_clock();
 	expires = group->avg_next_update;
-	if (now < expires)
-		goto out;
 	if (now - expires > psi_period)
 		missed_periods = div_u64(now - expires, psi_period);
 
@@ -332,7 +366,7 @@ static bool update_stats(struct psi_group *group)
 	 * But the deltas we sample out of the per-cpu buckets above
 	 * are based on the actual time elapsing between clock ticks.
 	 */
-	group->avg_next_update = expires + ((1 + missed_periods) * psi_period);
+	avg_next_update = expires + ((1 + missed_periods) * psi_period);
 	period = now - (group->avg_last_update + (missed_periods * psi_period));
 	group->avg_last_update = now;
 
@@ -362,20 +396,241 @@ static bool update_stats(struct psi_group *group)
 		group->avg_total[s] += sample;
 		calc_avgs(group->avg[s], missed_periods, sample, period);
 	}
-out:
-	mutex_unlock(&group->update_lock);
-	return nonidle_total;
+
+	return avg_next_update;
 }
 
+/* Trigger tracking window manupulations */
+static void window_reset(struct psi_window *win, u64 now, u64 value,
+						 u64 prev_growth)
+{
+	win->start_time = now;
+	win->start_value = value;
+	win->prev_growth = prev_growth;
+}
+
+/*
+ * PSI growth tracking window update and growth calculation routine.
+ *
+ * This approximates a sliding tracking window by interpolating
+ * partially elapsed windows using historical growth data from the
+ * previous intervals. This minimizes memory requirements (by not storing
+ * all the intermediate values in the previous window) and simplifies
+ * the calculations. It works well because PSI signal changes only in
+ * positive direction and over relatively small window sizes the growth
+ * is close to linear.
+ */
+static u64 window_update(struct psi_window *win, u64 now, u64 value)
+{
+	u64 elapsed;
+	u64 growth;
+
+	elapsed = now - win->start_time;
+	growth = value - win->start_value;
+	/*
+	 * After each tracking window passes win->start_value and
+	 * win->start_time get reset and win->prev_growth stores
+	 * the average per-window growth of the previous window.
+	 * win->prev_growth is then used to interpolate additional
+	 * growth from the previous window assuming it was linear.
+	 */
+	if (elapsed > win->size)
+		window_reset(win, now, value, growth);
+	else {
+		u32 remaining;
+
+		remaining = win->size - elapsed;
+		growth += div_u64(win->prev_growth * remaining, win->size);
+	}
+
+	return growth;
+}
+
+static void init_triggers(struct psi_group *group, u64 now)
+{
+	struct psi_trigger *t;
+
+	list_for_each_entry(t, &group->triggers, node)
+		window_reset(&t->win, now, group->total[t->state], 0);
+	memcpy(group->polling_total, group->total,
+		   sizeof(group->polling_total));
+	group->polling_next_update = now + group->trigger_min_period;
+}
+
+static u64 update_triggers(struct psi_group *group, u64 now)
+{
+	struct psi_trigger *t;
+	bool new_stall = false;
+
+	/*
+	 * On subsequent updates, calculate growth deltas and let
+	 * watchers know when their specified thresholds are exceeded.
+	 */
+	list_for_each_entry(t, &group->triggers, node) {
+		u64 growth;
+
+		/* Check for stall activity */
+		if (group->polling_total[t->state] == group->total[t->state])
+			continue;
+
+		/*
+		 * Multiple triggers might be looking at the same state,
+		 * remember to update group->polling_total[] once we've
+		 * been through all of them. Also remember to extend the
+		 * polling time if we see new stall activity.
+		 */
+		new_stall = true;
+
+		/* Calculate growth since last update */
+		growth = window_update(&t->win, now, group->total[t->state]);
+		if (growth < t->threshold)
+			continue;
+
+		/* Limit event signaling to once per window */
+		if (now < t->last_event_time + t->win.size)
+			continue;
+
+		/* Generate an event */
+		if (cmpxchg(&t->event, 0, 1) == 0)
+			wake_up_interruptible(&t->event_wait);
+		t->last_event_time = now;
+	}
+
+	if (new_stall) {
+		memcpy(group->polling_total, group->total,
+			   sizeof(group->polling_total));
+	}
+
+	return now + group->trigger_min_period;
+}
+
+/*
+ * psi_update_work represents slowpath accounting part while psi_group_change
+ * represents hotpath part. There are two potential races between them:
+ * 1. Changes to group->polling when slowpath checks for new stall, then hotpath
+ *    records new stall and then slowpath resets group->polling flag. This leads
+ *    to the exit from the polling mode while monitored state is still changing.
+ * 2. Slowpath overwriting an immediate update scheduled from the hotpath with
+ *    a regular update further in the future and missing the immediate update.
+ * Both races are handled with a retry cycle in the slowpath:
+ *
+ *    HOTPATH:                         |    SLOWPATH:
+ *                                     |
+ * A) times[cpu] += delta              | E) delta = times[*]
+ * B) start_poll = (delta[poll_mask] &&|    polling = g->polling
+ *      cmpxchg(g->polling, 0, 1) == 0)|    if delta[poll_mask]:
+ *    if start_poll:                   | F)   polling_until = now + grace_period
+ * C)   mod_delayed_work(1)            |    if now > polling_until:
+ *     else if !delayed_work_pending():|      if polling:
+ * D)   schedule_delayed_work(PSI_FREQ)| G)     g->polling = polling = 0
+ *                                     |        smp_mb
+ *                                     | H)     goto SLOWPATH
+ *                                     |    else:
+ *                                     |      if !polling:
+ *                                     | I)     g->polling = polling = 1
+ *                                     | J) if delta && first_pass:
+ *                                     |      next_avg = update_averages()
+ *                                     |      if polling:
+ *                                     |        next_poll = update_triggers()
+ *                                     |    if (delta && first_pass) || polling:
+ *                                     | K)   mod_delayed_work(
+ *                                     |          min(next_avg, next_poll))
+ *                                     |      if !polling:
+ *                                     |        first_pass = false
+ *                                     | L)     goto SLOWPATH
+ *
+ * Race #1 is represented by (EABGD) sequence in which case slowpath deactivates
+ * polling mode because it misses new monitored stall and hotpath doesn't
+ * activate it because at (B) g->polling is not yet reset by slowpath in (G).
+ * This race is handled by the (H) retry, which in the race described above
+ * results in the new sequence of (EABGDHEIK) that reactivates polling mode.
+ *
+ * Race #2 is represented by polling==false && (JABCK) sequence which overwrites
+ * immediate update scheduled at (C) with a later (next_avg) update scheduled at
+ * (K). This race is handled by the (L) retry which results in the new sequence
+ * of polling==false && (JABCKLEIK) that reactivates polling mode and
+ * reschedules the next polling update (next_poll).
+ *
+ * Note that retries can't result in an infinite loop because retry #1 happens
+ * only during polling reactivation and retry #2 happens only on the first pass.
+ * Constant reactivations are impossible because polling will stay active for at
+ * least grace_period. Worst case scenario involves two retries (HEJKLE)
+ */
 static void psi_update_work(struct work_struct *work)
 {
 	struct delayed_work *dwork;
 	struct psi_group *group;
+	bool first_pass = true;
+	u64 next_update;
+	u32 changed_states;
+	int polling;
 	bool nonidle;
+	u64 now;
 
 	dwork = to_delayed_work(work);
 	group = container_of(dwork, struct psi_group, clock_work);
 
+	mutex_lock(&group->update_lock);
+
+	now = sched_clock();
+
+retry:
+	collect_percpu_times(group, &changed_states);
+	polling = atomic_read(&group->polling);
+
+	if (changed_states & group->trigger_states) {
+		/* Initialize trigger windows when entering polling mode */
+		if (now > group->polling_until)
+			init_triggers(group, now);
+
+		/*
+		 * Keep the monitor active for at least the duration of the
+		 * minimum tracking window as long as monitor states are
+		 * changing. This prevents frequent changes to polling flag
+		 * when system bounces in and out of stall states.
+		 */
+		group->polling_until = now +
+			group->trigger_min_period * UPDATES_PER_WINDOW;
+	}
+
+	/* Handle polling flag transitions */
+	if (now > group->polling_until) {
+		if (polling) {
+			group->polling_next_update = ULLONG_MAX;
+			polling = 0;
+			atomic_set(&group->polling, polling);
+			/*
+			 * Memory barrier is needed to order group->polling=0
+			 * write before times[] reads in collect_percpu_times()
+			 * to detect possible race with hotpath that modifies
+			 * times[] before it sets group->polling=1 (see Race #1
+			 * description in the comments at the top).
+			 */
+			smp_mb();
+			/*
+			 * Check if we missed stall recorded by hotpath while
+			 * polling flag was set to 1 causing hotpath to skip
+			 * entering polling mode
+			 */
+			goto retry;
+		}
+	} else {
+		if (!polling) {
+			/*
+			 * This can happen as a fixup in the retry cycle after
+			 * new stall is discovered
+			 */
+			polling = 1;
+			atomic_set(&group->polling, polling);
+		}
+	}
+	/*
+	 * At this point group->polling race with hotpath is resolved and
+	 * we rely on local polling flag ignoring possible further changes
+	 * to group->polling
+	 */
+
+	nonidle = (changed_states & (1 << PSI_NONIDLE));
 	/*
 	 * If there is task activity, periodically fold the per-cpu
 	 * times and feed samples into the running averages. If things
@@ -383,20 +638,34 @@ static void psi_update_work(struct work_struct *work)
 	 * Once restarted, we'll catch up the running averages in one
 	 * go - see calc_avgs() and missed_periods.
 	 */
+	if (nonidle && first_pass) {
+		if (now >= group->avg_next_update)
+			group->avg_next_update = update_averages(group, now);
 
-	nonidle = update_stats(group);
-
-	if (nonidle) {
-		unsigned long delay = 0;
-		u64 now;
-
-		now = sched_clock();
-		if (group->avg_next_update > now) {
-			delay = nsecs_to_jiffies(
-				group->avg_next_update - now) + 1;
+		if (now >= group->polling_next_update) {
+			group->polling_next_update = update_triggers(
+					group, now);
+		}
+	}
+	if ((nonidle && first_pass) || polling) {
+		/* Calculate closest update time */
+		next_update = min(group->polling_next_update,
+					group->avg_next_update);
+		mod_delayed_work(system_wq, dwork, nsecs_to_jiffies(
+				next_update - now) + 1);
+		if (!polling) {
+			/*
+			 * We might have overwritten an immediate update
+			 * scheduled from the hotpath with a longer regular
+			 * update (group->avg_next_update). Execute second pass
+			 * retry to discover that and resume polling.
+			 */
+			first_pass = false;
+			goto retry;
 		}
-		schedule_delayed_work(dwork, delay);
 	}
+
+	mutex_unlock(&group->update_lock);
 }
 
 static void record_times(struct psi_group_cpu *groupc, int cpu,
@@ -445,7 +714,7 @@ static void record_times(struct psi_group_cpu *groupc, int cpu,
 		groupc->times[PSI_NONIDLE] += delta;
 }
 
-static void psi_group_change(struct psi_group *group, int cpu,
+static u32 psi_group_change(struct psi_group *group, int cpu,
 			     unsigned int clear, unsigned int set)
 {
 	struct psi_group_cpu *groupc;
@@ -492,6 +761,8 @@ static void psi_group_change(struct psi_group *group, int cpu,
 	groupc->state_mask = state_mask;
 
 	write_seqcount_end(&groupc->seq);
+
+	return state_mask;
 }
 
 static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
@@ -552,7 +823,27 @@ void psi_task_change(struct task_struct *task, int clear, int set)
 		wake_clock = false;
 
 	while ((group = iterate_groups(task, &iter))) {
-		psi_group_change(group, cpu, clear, set);
+		u32 state_mask = psi_group_change(group, cpu, clear, set);
+
+		/*
+		 * Polling flag resets to 0 at the max rate of once per update
+		 * window (at least 500ms interval). smp_wmb is required after
+		 * group->polling 0-to-1 transition to order groupc->times and
+		 * group->polling writes because stall detection logic in the
+		 * slowpath relies on groupc->times changing before
+		 * group->polling. Explicit smp_wmb is missing because cmpxchg()
+		 * implies smp_mb.
+		 */
+		if ((state_mask & group->trigger_states) &&
+			atomic_cmpxchg(&group->polling, 0, 1) == 0) {
+			/*
+			 * Start polling immediately even if the work is already
+			 * scheduled
+			 */
+			mod_delayed_work(system_wq, &group->clock_work, 1);
+			continue;
+		}
+
 		if (wake_clock && !delayed_work_pending(&group->clock_work))
 			schedule_delayed_work(&group->clock_work, PSI_FREQ);
 	}
@@ -653,6 +944,8 @@ void psi_cgroup_free(struct cgroup *cgroup)
 
 	cancel_delayed_work_sync(&cgroup->psi.clock_work);
 	free_percpu(cgroup->psi.pcpu);
+	/* All triggers must be removed by now by psi_trigger_destroy */
+	WARN_ONCE(cgroup->psi.trigger_states, "psi: trigger leak\n");
 }
 
 /**
@@ -712,7 +1005,11 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
 	if (static_branch_likely(&psi_disabled))
 		return -EOPNOTSUPP;
 
-	update_stats(group);
+	/* Update averages before reporting them */
+	mutex_lock(&group->update_lock);
+	collect_percpu_times(group, NULL);
+	update_averages(group, sched_clock());
+	mutex_unlock(&group->update_lock);
 
 	for (full = 0; full < 2 - (res == PSI_CPU); full++) {
 		unsigned long avg[3];
@@ -764,25 +1061,223 @@ static int psi_cpu_open(struct inode *inode, struct file *file)
 	return single_open(file, psi_cpu_show, NULL);
 }
 
+struct psi_trigger *psi_trigger_create(struct psi_group *group,
+			char *buf, size_t nbytes, enum psi_res res)
+{
+	struct psi_trigger *t;
+	enum psi_states state;
+	u32 threshold_us;
+	u32 window_us;
+
+	if (static_branch_likely(&psi_disabled))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	if (sscanf(buf, "some %u %u", &threshold_us, &window_us) == 2)
+		state = PSI_IO_SOME + res * 2;
+	else if (sscanf(buf, "full %u %u", &threshold_us, &window_us) == 2)
+		state = PSI_IO_FULL + res * 2;
+	else
+		return ERR_PTR(-EINVAL);
+
+	if (state >= PSI_NONIDLE)
+		return ERR_PTR(-EINVAL);
+
+	if (window_us < WINDOW_MIN_US ||
+		window_us > WINDOW_MAX_US)
+		return ERR_PTR(-EINVAL);
+
+	/* Check threshold */
+	if (threshold_us == 0 || threshold_us > window_us)
+		return ERR_PTR(-EINVAL);
+
+	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	if (!t)
+		return ERR_PTR(-ENOMEM);
+
+	t->group = group;
+	t->state = state;
+	t->threshold = threshold_us * NSEC_PER_USEC;
+	t->win.size = window_us * NSEC_PER_USEC;
+	window_reset(&t->win, 0, 0, 0);
+
+	t->event = 0;
+	t->last_event_time = 0;
+	init_waitqueue_head(&t->event_wait);
+
+	mutex_lock(&group->update_lock);
+
+	list_add(&t->node, &group->triggers);
+	group->trigger_min_period = min(group->trigger_min_period,
+		div_u64(t->win.size, UPDATES_PER_WINDOW));
+	group->nr_triggers[t->state]++;
+	group->trigger_states |= (1 << t->state);
+
+	mutex_unlock(&group->update_lock);
+
+	return t;
+}
+
+void psi_trigger_destroy(struct psi_trigger *t)
+{
+	struct psi_group *group = t->group;
+
+	if (static_branch_likely(&psi_disabled))
+		return;
+
+	mutex_lock(&group->update_lock);
+	if (!list_empty(&t->node)) {
+		struct psi_trigger *tmp;
+		u64 period = ULLONG_MAX;
+
+		list_del(&t->node);
+		group->nr_triggers[t->state]--;
+		if (!group->nr_triggers[t->state])
+			group->trigger_states &= ~(1 << t->state);
+		/* reset min update period for the remaining triggers */
+		list_for_each_entry(tmp, &group->triggers, node) {
+			period = min(period, div_u64(tmp->win.size,
+					UPDATES_PER_WINDOW));
+		}
+		group->trigger_min_period = period;
+		/*
+		 * Wakeup waiters to stop polling.
+		 * Can happen if cgroup is deleted from under
+		 * a polling process.
+		 */
+		wake_up_interruptible(&t->event_wait);
+		kfree(t);
+	}
+	mutex_unlock(&group->update_lock);
+}
+
+__poll_t psi_trigger_poll(struct psi_trigger *t,
+				struct file *file, poll_table *wait)
+{
+	if (static_branch_likely(&psi_disabled))
+		return DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+
+	poll_wait(file, &t->event_wait, wait);
+
+	if (cmpxchg(&t->event, 1, 0) == 1)
+		return DEFAULT_POLLMASK | EPOLLPRI;
+
+	/* Wait */
+	return DEFAULT_POLLMASK;
+}
+
+static ssize_t psi_write(struct file *file, const char __user *user_buf,
+				size_t nbytes, enum psi_res res)
+{
+	char buf[32];
+	size_t buf_size;
+	struct seq_file *seq;
+	struct psi_trigger *old;
+	struct psi_trigger *new;
+
+	if (static_branch_likely(&psi_disabled))
+		return -EOPNOTSUPP;
+
+	buf_size = min(nbytes, (sizeof(buf) - 1));
+	if (copy_from_user(buf, user_buf, buf_size))
+		return -EFAULT;
+
+	buf[buf_size - 1] = '\0';
+
+	new = psi_trigger_create(&psi_system, buf, nbytes, res);
+	if (IS_ERR(new))
+		return PTR_ERR(new);
+
+	seq = file->private_data;
+	/* Take seq->lock to protect seq->private from concurrent writes */
+	mutex_lock(&seq->lock);
+	old = seq->private;
+	rcu_assign_pointer(seq->private, new);
+	mutex_unlock(&seq->lock);
+
+	if (old) {
+		synchronize_rcu();
+		psi_trigger_destroy(old);
+	}
+
+	return nbytes;
+}
+
+static ssize_t psi_io_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_IO);
+}
+
+static ssize_t psi_memory_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_MEM);
+}
+
+static ssize_t psi_cpu_write(struct file *file,
+		const char __user *user_buf, size_t nbytes, loff_t *ppos)
+{
+	return psi_write(file, user_buf, nbytes, PSI_CPU);
+}
+
+static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
+{
+	struct seq_file *seq = file->private_data;
+	struct psi_trigger *t;
+	__poll_t ret;
+
+	rcu_read_lock();
+	t = rcu_dereference(seq->private);
+	if (t)
+		ret = psi_trigger_poll(t, file, wait);
+	else
+		ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
+	rcu_read_unlock();
+
+	return ret;
+
+}
+
+static int psi_fop_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct psi_trigger *t = seq->private;
+
+	if (static_branch_likely(&psi_disabled) || !t)
+		goto out;
+
+	rcu_assign_pointer(seq->private, NULL);
+	synchronize_rcu();
+	psi_trigger_destroy(t);
+out:
+	return single_release(inode, file);
+}
+
 static const struct file_operations psi_io_fops = {
 	.open           = psi_io_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_io_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_memory_fops = {
 	.open           = psi_memory_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_memory_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static const struct file_operations psi_cpu_fops = {
 	.open           = psi_cpu_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release        = single_release,
+	.write          = psi_cpu_write,
+	.poll           = psi_fop_poll,
+	.release        = psi_fop_release,
 };
 
 static int __init psi_proc_init(void)
-- 
2.20.1.611.gfbb209baf1-goog

