Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45B48C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDF4220851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 16:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Tvq7QCMc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDF4220851
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B2E98E0004; Thu,  7 Mar 2019 11:56:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 763CE8E0002; Thu,  7 Mar 2019 11:56:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 653148E0004; Thu,  7 Mar 2019 11:56:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2626B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 11:56:43 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id z24so18451063pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 08:56:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=gvD0D1bzLjFy9WCza61OCAcv7CRzmb0TlAuNri8hyFg=;
        b=PG53UqIqJviuZhBuXFI3A58Oyems1Ukj1tz4ECrVHs7LIlFpUBXBsBOPz/0x1U58bQ
         EhKBhNp09FJHKr3cCCgJ9rq6iIvtgKm1DOAarbkshUJ/ymEVA6fmeVzNS7wp/50U0DxQ
         tvBux7fU+AkGV3h3gKrcZYIbRyzxF3OiV6o+71XxpnJWv/E5/YV6m43/ykI/2mOzSjrk
         4igkHiMVv5Gu0KXvToLwaDfjcVaoTWaB/ut1MYT6+KbHTQO1w1HoT6WBG1Z8vyOH8o5d
         sScR8zH9/mksk/rGRVfo0dr5FX2hHI94Q/P8imtv26yOsPN31jM4Yqi2RBpRKQZzOcE9
         fdug==
X-Gm-Message-State: APjAAAXRzILtSfdV6wfRIsvfG8tMDu7eIECyX/nNAg1Avzw8/x9i2rpR
	cxC84wg3qAlMTdf0fWcSyMyUMenMZ4EkJ/xSvOxy/h0IlAXK5cjuKML9aGs3S/GghekNu7O2WLp
	UsNyVTR911SlGKflOjMz75thk/uYal0B/giSWs60lbKqmFQoDjM6/WqzY4cw3P5HeXIV/TwtNQE
	PkjMowytI3dCgsvgEBDXNcjo1WzGryoyDDju1Tp2UE7+jlgmdq6Mi66sJQ96egezShlyX/2UopE
	vlZpRKiXxphkY0D4S4TKyCGxT4bL1sDf/rvZ/KDY4gKrWHCd3rlw38RADeL2l0s9A9JYvCr4zzL
	4497r/vmYwNTRvibEyDEjmAe2M4iohkmhhu4yrPyFQS7f9PNMk0l0Ntl7a2s3Whu/XMHAwbhoUg
	R
X-Received: by 2002:a17:902:bb0c:: with SMTP id l12mr13939514pls.108.1551977802788;
        Thu, 07 Mar 2019 08:56:42 -0800 (PST)
X-Received: by 2002:a17:902:bb0c:: with SMTP id l12mr13939439pls.108.1551977801458;
        Thu, 07 Mar 2019 08:56:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551977801; cv=none;
        d=google.com; s=arc-20160816;
        b=mxFnekY+3uAVDhfuumqYZZufNxa7yqSPdyDfEF19JYP4xVD6T7eIuuEhEwvUqhsvPF
         Qlwz2tDqEaKCWLoSaAaFyUv08Bck103gpuQyERZghwSseJcR2+/O04lpafNY1WFHkNVq
         g/mOwtJpE4d3GmMLnvikehk2Qgk9eX3Nzw9QXZUq5lZSI9S0Rr5/0GtUvnMjfPzLCDcc
         XzZm0k2R8e1THzRxQ8KhXfbDvRSTRA4SMkSzkAl4TjWpXbc7z8hH8junQlpNOwy7lWMb
         WsRcybWRp3xRiqz9h+tHC2imE81UXhZTHi76VYsAGkNjMvSREHRYE+H8lghE5KrfHV7h
         av+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=gvD0D1bzLjFy9WCza61OCAcv7CRzmb0TlAuNri8hyFg=;
        b=fRiqDSujAPcQWma5r5YU62PIsDMiGlA7QG//2x6qlJhceTcjdjnjNJQAsSTjTnFmC7
         dXPa/k/Q9e4XM6JNwl0SyjYqoZmGohvK3Gtcm5H1E8n4bUTGwBDf3+tWlOjHb/5ctjIS
         JGXerpXNrE7/SlTpys5r+71dzsYN9n5mQta5kC1QJ0V+Y+sC5bV6tCR3wtlktlsZNR6J
         YoM1etDgjW3yjHur3jMug6PeSzx8QLzaipRfZ+8IUpR6kcUOxoVlkqVdkwqKSz2kxk+q
         iP6v2kS9gLuGZQGLBK41rX306G0ueKWtUG81Y8N1OdEzd5cNa1/EHlMv1oTI8jg4ARNb
         zzsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tvq7QCMc;
       spf=pass (google.com: domain of 3su2bxackcni4h5292b4cc492.0ca96bil-aa8jy08.cf4@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SU2BXAcKCNI4H5292B4CC492.0CA96BIL-AA8Jy08.CF4@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c7sor8078675pgd.85.2019.03.07.08.56.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 08:56:41 -0800 (PST)
Received-SPF: pass (google.com: domain of 3su2bxackcni4h5292b4cc492.0ca96bil-aa8jy08.cf4@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Tvq7QCMc;
       spf=pass (google.com: domain of 3su2bxackcni4h5292b4cc492.0ca96bil-aa8jy08.cf4@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3SU2BXAcKCNI4H5292B4CC492.0CA96BIL-AA8Jy08.CF4@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=gvD0D1bzLjFy9WCza61OCAcv7CRzmb0TlAuNri8hyFg=;
        b=Tvq7QCMcHopEyEi2PDzbYWCRVlxtwwUMWfeV/6YNqLe90vi/UjTQKjXP7pQbQ3g9/0
         /sSBLbihu06bYJ+nrgWQntDYWbx0VqUxw5HUi3AS7S1tyxFLmGXuDbxO1xeB6O8AX03a
         uJn8e2MfLID+ej2AdSsA44pKPmeBsATW9KaJmL1er4RubBRTg19o87GuZONE5scGkMl1
         3LkFbZWNm5vBOfYJkHS7Su4LbvP6+tMdL+vARNyxLdjaO7QFmuqkwaCOvw5OdJIc5Is0
         KxqxNcpJ7O66wd6RJ3imp6131vlG4qz7mIWfg5RTrOkfGVIJUQhnknTM+1jzXnsECu5S
         WMUw==
X-Google-Smtp-Source: APXvYqxcyB4omg5XNPlHg7A099kbRkvgg6GjDUOuUWL7q91uXbuXRLcIxn5sHjwbEn2VdFBbx4BOO6Eg75zf
X-Received: by 2002:a63:1d7:: with SMTP id 206mr5312675pgb.45.1551977801020;
 Thu, 07 Mar 2019 08:56:41 -0800 (PST)
Date: Thu,  7 Mar 2019 08:56:32 -0800
Message-Id: <20190307165632.35810-1-gthelen@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.352.gf09ad66450-goog
Subject: [PATCH] writeback: sum memcg dirty counters as needed
From: Greg Thelen <gthelen@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
memory.stat reporting") memcg dirty and writeback counters are managed
as:
1) per-memcg per-cpu values in range of [-32..32]
2) per-memcg atomic counter
When a per-cpu counter cannot fit in [-32..32] it's flushed to the
atomic.  Stat readers only check the atomic.
Thus readers such as balance_dirty_pages() may see a nontrivial error
margin: 32 pages per cpu.
Assuming 100 cpus:
   4k x86 page_size:  13 MiB error per memcg
  64k ppc page_size: 200 MiB error per memcg
Considering that dirty+writeback are used together for some decisions
the errors double.

This inaccuracy can lead to undeserved oom kills.  One nasty case is
when all per-cpu counters hold positive values offsetting an atomic
negative value (i.e. per_cpu[*]=32, atomic=n_cpu*-32).
balance_dirty_pages() only consults the atomic and does not consider
throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
13..200 MiB range then there's absolutely no dirty throttling, which
burdens vmscan with only dirty+writeback pages thus resorting to oom
kill.

It could be argued that tiny containers are not supported, but it's more
subtle.  It's the amount the space available for file lru that matters.
If a container has memory.max-200MiB of non reclaimable memory, then it
will also suffer such oom kills on a 100 cpu machine.

The following test reliably ooms without this patch.  This patch avoids
oom kills.

  $ cat test
  mount -t cgroup2 none /dev/cgroup
  cd /dev/cgroup
  echo +io +memory > cgroup.subtree_control
  mkdir test
  cd test
  echo 10M > memory.max
  (echo $BASHPID > cgroup.procs && exec /memcg-writeback-stress /foo)
  (echo $BASHPID > cgroup.procs && exec dd if=/dev/zero of=/foo bs=2M count=100)

  $ cat memcg-writeback-stress.c
  /*
   * Dirty pages from all but one cpu.
   * Clean pages from the non dirtying cpu.
   * This is to stress per cpu counter imbalance.
   * On a 100 cpu machine:
   * - per memcg per cpu dirty count is 32 pages for each of 99 cpus
   * - per memcg atomic is -99*32 pages
   * - thus the complete dirty limit: sum of all counters 0
   * - balance_dirty_pages() only sees atomic count -99*32 pages, which
   *   it max()s to 0.
   * - So a workload can dirty -99*32 pages before balance_dirty_pages()
   *   cares.
   */
  #define _GNU_SOURCE
  #include <err.h>
  #include <fcntl.h>
  #include <sched.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <sys/stat.h>
  #include <sys/sysinfo.h>
  #include <sys/types.h>
  #include <unistd.h>

  static char *buf;
  static int bufSize;

  static void set_affinity(int cpu)
  {
  	cpu_set_t affinity;

  	CPU_ZERO(&affinity);
  	CPU_SET(cpu, &affinity);
  	if (sched_setaffinity(0, sizeof(affinity), &affinity))
  		err(1, "sched_setaffinity");
  }

  static void dirty_on(int output_fd, int cpu)
  {
  	int i, wrote;

  	set_affinity(cpu);
  	for (i = 0; i < 32; i++) {
  		for (wrote = 0; wrote < bufSize; ) {
  			int ret = write(output_fd, buf+wrote, bufSize-wrote);
  			if (ret == -1)
  				err(1, "write");
  			wrote += ret;
  		}
  	}
  }

  int main(int argc, char **argv)
  {
  	int cpu, flush_cpu = 1, output_fd;
  	const char *output;

  	if (argc != 2)
  		errx(1, "usage: output_file");

  	output = argv[1];
  	bufSize = getpagesize();
  	buf = malloc(getpagesize());
  	if (buf == NULL)
  		errx(1, "malloc failed");

  	output_fd = open(output, O_CREAT|O_RDWR);
  	if (output_fd == -1)
  		err(1, "open(%s)", output);

  	for (cpu = 0; cpu < get_nprocs(); cpu++) {
  		if (cpu != flush_cpu)
  			dirty_on(output_fd, cpu);
  	}

  	set_affinity(flush_cpu);
  	if (fsync(output_fd))
  		err(1, "fsync(%s)", output);
  	if (close(output_fd))
  		err(1, "close(%s)", output);
  	free(buf);
  }

Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
collect exact per memcg counters when a memcg is close to the
throttling/writeback threshold.  This avoids the aforementioned oom
kills.

This does not affect the overhead of memory.stat, which still reads the
single atomic counter.

Why not use percpu_counter?  memcg already handles cpus going offline,
so no need for that overhead from percpu_counter.  And the
percpu_counter spinlocks are more heavyweight than is required.

It probably also makes sense to include exact dirty and writeback
counters in memcg oom reports.  But that is saved for later.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h | 33 +++++++++++++++++++++++++--------
 mm/memcontrol.c            | 26 ++++++++++++++++++++------
 mm/page-writeback.c        | 27 +++++++++++++++++++++------
 3 files changed, 66 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11cbd12c..6a133c90138c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -573,6 +573,22 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 	return x;
 }
 
+/* idx can be of type enum memcg_stat_item or node_stat_item */
+static inline unsigned long
+memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
+{
+	long x = atomic_long_read(&memcg->stat[idx]);
+#ifdef CONFIG_SMP
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		x += per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
 /* idx can be of type enum memcg_stat_item or node_stat_item */
 static inline void __mod_memcg_state(struct mem_cgroup *memcg,
 				     int idx, int val)
@@ -1222,9 +1238,10 @@ static inline void dec_lruvec_page_state(struct page *page,
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
-void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
-			 unsigned long *pheadroom, unsigned long *pdirty,
-			 unsigned long *pwriteback);
+unsigned long
+mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
+		    unsigned long *pheadroom, unsigned long *pdirty,
+		    unsigned long *pwriteback, bool exact);
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
@@ -1233,12 +1250,12 @@ static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
 	return NULL;
 }
 
-static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
-				       unsigned long *pfilepages,
-				       unsigned long *pheadroom,
-				       unsigned long *pdirty,
-				       unsigned long *pwriteback)
+static inline unsigned long
+mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
+		    unsigned long *pheadroom, unsigned long *pdirty,
+		    unsigned long *pwriteback, bool exact)
 {
+	return 0;
 }
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..0a50f1c523bb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3880,6 +3880,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
  * @pheadroom: out parameter for number of allocatable pages according to memcg
  * @pdirty: out parameter for number of dirty pages
  * @pwriteback: out parameter for number of pages under writeback
+ * @exact: determines exact counters are required, indicates more work.
  *
  * Determine the numbers of file, headroom, dirty, and writeback pages in
  * @wb's memcg.  File, dirty and writeback are self-explanatory.  Headroom
@@ -3890,18 +3891,29 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
  * ancestors.  Note that this doesn't consider the actual amount of
  * available memory in the system.  The caller should further cap
  * *@pheadroom accordingly.
+ *
+ * Return value is the error precision associated with *@pdirty
+ * and *@pwriteback.  When @exact is set this a minimal value.
  */
-void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
-			 unsigned long *pheadroom, unsigned long *pdirty,
-			 unsigned long *pwriteback)
+unsigned long
+mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
+		    unsigned long *pheadroom, unsigned long *pdirty,
+		    unsigned long *pwriteback, bool exact)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
+	unsigned long precision;
 
-	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
-
+	if (exact) {
+		precision = 0;
+		*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);
+		*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
+	} else {
+		precision = MEMCG_CHARGE_BATCH * num_online_cpus();
+		*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
+		*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
+	}
 	/* this should eventually include NR_UNSTABLE_NFS */
-	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
 	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
 						     (1 << LRU_ACTIVE_FILE));
 	*pheadroom = PAGE_COUNTER_MAX;
@@ -3913,6 +3925,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
 		memcg = parent;
 	}
+
+	return precision;
 }
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7d1010453fb9..2c1c855db4b7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1612,14 +1612,17 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 		}
 
 		if (mdtc) {
-			unsigned long filepages, headroom, writeback;
+			bool exact = false;
+			unsigned long precision, filepages, headroom, writeback;
 
 			/*
 			 * If @wb belongs to !root memcg, repeat the same
 			 * basic calculations for the memcg domain.
 			 */
-			mem_cgroup_wb_stats(wb, &filepages, &headroom,
-					    &mdtc->dirty, &writeback);
+memcg_stats:
+			precision = mem_cgroup_wb_stats(wb, &filepages,
+							&headroom, &mdtc->dirty,
+							&writeback, exact);
 			mdtc->dirty += writeback;
 			mdtc_calc_avail(mdtc, filepages, headroom);
 
@@ -1634,6 +1637,10 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 				m_dirty = mdtc->dirty;
 				m_thresh = mdtc->thresh;
 				m_bg_thresh = mdtc->bg_thresh;
+				if (abs(m_dirty - mdtc->thresh) < precision) {
+					exact = true;
+					goto memcg_stats;
+				}
 			}
 		}
 
@@ -1945,10 +1952,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		return true;
 
 	if (mdtc) {
-		unsigned long filepages, headroom, writeback;
+		bool exact = false;
+		unsigned long precision, filepages, headroom, writeback;
 
-		mem_cgroup_wb_stats(wb, &filepages, &headroom, &mdtc->dirty,
-				    &writeback);
+memcg_stats:
+		precision = mem_cgroup_wb_stats(wb, &filepages, &headroom,
+						&mdtc->dirty, &writeback,
+						exact);
 		mdtc_calc_avail(mdtc, filepages, headroom);
 		domain_dirty_limits(mdtc);	/* ditto, ignore writeback */
 
@@ -1958,6 +1968,11 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 		if (wb_stat(wb, WB_RECLAIMABLE) >
 		    wb_calc_thresh(mdtc->wb, mdtc->bg_thresh))
 			return true;
+
+		if (abs(mdtc->dirty - mdtc->bg_thresh) < precision) {
+			exact = true;
+			goto memcg_stats;
+		}
 	}
 
 	return false;
-- 
2.21.0.352.gf09ad66450-goog

