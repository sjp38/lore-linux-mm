Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4567FC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E08BF2171F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:59:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fTUAJHmu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E08BF2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980026B0277; Thu, 15 Aug 2019 15:59:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 930976B027A; Thu, 15 Aug 2019 15:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81EFC6B027C; Thu, 15 Aug 2019 15:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF256B0277
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:59:34 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0F854181AC9B4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:59:34 +0000 (UTC)
X-FDA: 75825727068.17.fuel70_1941213432429
X-HE-Tag: fuel70_1941213432429
X-Filterd-Recvd-Size: 16670
Received: from mail-qt1-f169.google.com (mail-qt1-f169.google.com [209.85.160.169])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:59:33 +0000 (UTC)
Received: by mail-qt1-f169.google.com with SMTP id q4so3681095qtp.1
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:59:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ud07z5/psxOSblwwNPdaBzV4BiEQea+btrLNqweJWnU=;
        b=fTUAJHmuWefuhAPMBB40xKzqRQvfZGdI5MSSx6kqGIf7gsV/T4U348k1z68knsQH6L
         Iu+r0xrblgbGagjwASJnb64jKFKE95AvsfKlufI0kDhF1C71zfuh6wJ2RmSWH47a6Ehm
         X/u/cyuChrpjLgwyWxFiHKZLPfJ53zBwwHqz1fsoH9meT7WMDbHNG9kxAem1YFlvWSdj
         srVCnHILR7v8ZgI848qGgf0VBsDF9SM4ftGyQ6c1GuT8x4tWidfnsBzg5jitemFhjzov
         GI5LaBziSWIT06uQt4/71Tud45I6LnwoWxH4NtYV6Dj4h0na/ClottBDdc9nFsZqf836
         paEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=ud07z5/psxOSblwwNPdaBzV4BiEQea+btrLNqweJWnU=;
        b=iBIHgWPGxngvlL2ZZyE+E5L1WkK6m4c8TD7X8EyudanpWCaG4uPPnsDfhrgs24aKvo
         9W9fhd8rGBZeCSGf4robHaY3dLJygzpT8PgStELr5OSfsKmUgb26nwvql5C7dRTOCAXz
         vwA/9543oxb2GjKjU0knYkzfR1Jd5P66NrDhx7iz/HVLI3JYY2dMb9lRQMIFQTgmKrMZ
         HkIvwyZz7AOLG8wPTp4LUg5If5kfZAx+IamIYdC3LeW5zmjKFpw8fDXTrd8Bs54IzcaT
         wj8n4M9StaFokBBB4qwIJBtWXcGpFdXhzkdNwxw3+kixR+unIv3Xw34SGpRGd3KSAtyT
         OUUw==
X-Gm-Message-State: APjAAAVsGt/RVxS5uUDpxinS94TB7O1O8ZaEKibbgCI75rEYh4XHhOKe
	omczn1v9Kw5ZzZyGTsz4CSE=
X-Google-Smtp-Source: APXvYqyzw9nynFYELzR4kvkflWQBz/g9lbMuvJ70B+XSdD7MvLeKCxsDFr9wopZOwF2ouzGK1o5wJg==
X-Received: by 2002:ac8:358e:: with SMTP id k14mr3954849qtb.83.1565899172696;
        Thu, 15 Aug 2019 12:59:32 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id m9sm1773171qtp.27.2019.08.15.12.59.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 12:59:32 -0700 (PDT)
Date: Thu, 15 Aug 2019 12:59:30 -0700
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: [PATCH 5/5] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There's an inherent mismatch between memcg and writeback.  The former
trackes ownership per-page while the latter per-inode.  This was a
deliberate design decision because honoring per-page ownership in the
writeback path is complicated, may lead to higher CPU and IO overheads
and deemed unnecessary given that write-sharing an inode across
different cgroups isn't a common use-case.

Combined with inode majority-writer ownership switching, this works
well enough in most cases but there are some pathological cases.  For
example, let's say there are two cgroups A and B which keep writing to
different but confined parts of the same inode.  B owns the inode and
A's memory is limited far below B's.  A's dirty ratio can rise enough
to trigger balance_dirty_pages() sleeps but B's can be low enough to
avoid triggering background writeback.  A will be slowed down without
a way to make writeback of the dirty pages happen.

This patch implements foreign dirty recording and foreign mechanism so
that when a memcg encounters a condition as above it can trigger
flushes on bdi_writebacks which can clean its pages.  Please see the
comment on top of mem_cgroup_track_foreign_dirty_slowpath() for
details.

A reproducer follows.

write-range.c::

  #include <stdio.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include <fcntl.h>
  #include <sys/types.h>

  static const char *usage = "write-range FILE START SIZE\n";

  int main(int argc, char **argv)
  {
	  int fd;
	  unsigned long start, size, end, pos;
	  char *endp;
	  char buf[4096];

	  if (argc < 4) {
		  fprintf(stderr, usage);
		  return 1;
	  }

	  fd = open(argv[1], O_WRONLY);
	  if (fd < 0) {
		  perror("open");
		  return 1;
	  }

	  start = strtoul(argv[2], &endp, 0);
	  if (*endp != '\0') {
		  fprintf(stderr, usage);
		  return 1;
	  }

	  size = strtoul(argv[3], &endp, 0);
	  if (*endp != '\0') {
		  fprintf(stderr, usage);
		  return 1;
	  }

	  end = start + size;

	  while (1) {
		  for (pos = start; pos < end; ) {
			  long bread, bwritten = 0;

			  if (lseek(fd, pos, SEEK_SET) < 0) {
				  perror("lseek");
				  return 1;
			  }

			  bread = read(0, buf, sizeof(buf) < end - pos ?
					       sizeof(buf) : end - pos);
			  if (bread < 0) {
				  perror("read");
				  return 1;
			  }
			  if (bread == 0)
				  return 0;

			  while (bwritten < bread) {
				  long this;

				  this = write(fd, buf + bwritten,
					       bread - bwritten);
				  if (this < 0) {
					  perror("write");
					  return 1;
				  }

				  bwritten += this;
				  pos += bwritten;
			  }
		  }
	  }
  }

repro.sh::

  #!/bin/bash

  set -e
  set -x

  sysctl -w vm.dirty_expire_centisecs=300000
  sysctl -w vm.dirty_writeback_centisecs=300000
  sysctl -w vm.dirtytime_expire_seconds=300000
  echo 3 > /proc/sys/vm/drop_caches

  TEST=/sys/fs/cgroup/test
  A=$TEST/A
  B=$TEST/B

  mkdir -p $A $B
  echo "+memory +io" > $TEST/cgroup.subtree_control
  echo $((1<<30)) > $A/memory.high
  echo $((32<<30)) > $B/memory.high

  rm -f testfile
  touch testfile
  fallocate -l 4G testfile

  echo "Starting B"

  (echo $BASHPID > $B/cgroup.procs
   pv -q --rate-limit 70M < /dev/urandom | ./write-range testfile $((2<<30)) $((2<<30))) &

  echo "Waiting 10s to ensure B claims the testfile inode"
  sleep 5
  sync
  sleep 5
  sync
  echo "Starting A"

  (echo $BASHPID > $A/cgroup.procs
   pv < /dev/urandom | ./write-range testfile 0 $((2<<30)))

v2: Added comments explaining why the specific intervals are being used.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/backing-dev-defs.h |    1 
 include/linux/memcontrol.h       |   39 +++++++++++
 mm/memcontrol.c                  |  132 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |    4 +
 4 files changed, 176 insertions(+)

--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -63,6 +63,7 @@ enum wb_reason {
 	 * so it has a mismatch name.
 	 */
 	WB_REASON_FORKER_THREAD,
+	WB_REASON_FOREIGN_FLUSH,
 
 	WB_REASON_MAX,
 };
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -184,6 +184,23 @@ struct memcg_padding {
 #endif
 
 /*
+ * Remember four most recent foreign writebacks with dirty pages in this
+ * cgroup.  Inode sharing is expected to be uncommon and, even if we miss
+ * one in a given round, we're likely to catch it later if it keeps
+ * foreign-dirtying, so a fairly low count should be enough.
+ *
+ * See mem_cgroup_track_foreign_dirty_slowpath() for details.
+ */
+#define MEMCG_CGWB_FRN_CNT	4
+
+struct memcg_cgwb_frn {
+	u64 bdi_id;			/* bdi->id of the foreign inode */
+	int memcg_id;			/* memcg->css.id of foreign inode */
+	u64 at;				/* jiffies_64 at the time of dirtying */
+	struct wb_completion done;	/* tracks in-flight foreign writebacks */
+};
+
+/*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
  * statistics based on the statistics developed by Rik Van Riel for clock-pro,
@@ -307,6 +324,7 @@ struct mem_cgroup {
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct list_head cgwb_list;
 	struct wb_domain cgwb_domain;
+	struct memcg_cgwb_frn cgwb_frn[MEMCG_CGWB_FRN_CNT];
 #endif
 
 	/* List of events which userspace want to receive */
@@ -1237,6 +1255,18 @@ void mem_cgroup_wb_stats(struct bdi_writ
 			 unsigned long *pheadroom, unsigned long *pdirty,
 			 unsigned long *pwriteback);
 
+void mem_cgroup_track_foreign_dirty_slowpath(struct page *page,
+					     struct bdi_writeback *wb);
+
+static inline void mem_cgroup_track_foreign_dirty(struct page *page,
+						  struct bdi_writeback *wb)
+{
+	if (unlikely(&page->mem_cgroup->css != wb->memcg_css))
+		mem_cgroup_track_foreign_dirty_slowpath(page, wb);
+}
+
+void mem_cgroup_flush_foreign(struct bdi_writeback *wb);
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
@@ -1252,6 +1282,15 @@ static inline void mem_cgroup_wb_stats(s
 {
 }
 
+static inline void mem_cgroup_track_foreign_dirty(struct page *page,
+						  struct bdi_writeback *wb)
+{
+}
+
+static inline void mem_cgroup_flush_foreign(struct bdi_writeback *wb)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -87,6 +87,10 @@ int do_swap_account __read_mostly;
 #define do_swap_account		0
 #endif
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+static DECLARE_WAIT_QUEUE_HEAD(memcg_cgwb_frn_waitq);
+#endif
+
 /* Whether legacy memory+swap accounting is active */
 static bool do_memsw_account(void)
 {
@@ -4184,6 +4188,125 @@ void mem_cgroup_wb_stats(struct bdi_writ
 	}
 }
 
+/*
+ * Foreign dirty flushing
+ *
+ * There's an inherent mismatch between memcg and writeback.  The former
+ * trackes ownership per-page while the latter per-inode.  This was a
+ * deliberate design decision because honoring per-page ownership in the
+ * writeback path is complicated, may lead to higher CPU and IO overheads
+ * and deemed unnecessary given that write-sharing an inode across
+ * different cgroups isn't a common use-case.
+ *
+ * Combined with inode majority-writer ownership switching, this works well
+ * enough in most cases but there are some pathological cases.  For
+ * example, let's say there are two cgroups A and B which keep writing to
+ * different but confined parts of the same inode.  B owns the inode and
+ * A's memory is limited far below B's.  A's dirty ratio can rise enough to
+ * trigger balance_dirty_pages() sleeps but B's can be low enough to avoid
+ * triggering background writeback.  A will be slowed down without a way to
+ * make writeback of the dirty pages happen.
+ *
+ * Conditions like the above can lead to a cgroup getting repatedly and
+ * severely throttled after making some progress after each
+ * dirty_expire_interval while the underyling IO device is almost
+ * completely idle.
+ *
+ * Solving this problem completely requires matching the ownership tracking
+ * granularities between memcg and writeback in either direction.  However,
+ * the more egregious behaviors can be avoided by simply remembering the
+ * most recent foreign dirtying events and initiating remote flushes on
+ * them when local writeback isn't enough to keep the memory clean enough.
+ *
+ * The following two functions implement such mechanism.  When a foreign
+ * page - a page whose memcg and writeback ownerships don't match - is
+ * dirtied, mem_cgroup_track_foreign_dirty() records the inode owning
+ * bdi_writeback on the page owning memcg.  When balance_dirty_pages()
+ * decides that the memcg needs to sleep due to high dirty ratio, it calls
+ * mem_cgroup_flush_foreign() which queues writeback on the recorded
+ * foreign bdi_writebacks which haven't expired.  Both the numbers of
+ * recorded bdi_writebacks and concurrent in-flight foreign writebacks are
+ * limited to MEMCG_CGWB_FRN_CNT.
+ *
+ * The mechanism only remembers IDs and doesn't hold any object references.
+ * As being wrong occasionally doesn't matter, updates and accesses to the
+ * records are lockless and racy.
+ */
+void mem_cgroup_track_foreign_dirty_slowpath(struct page *page,
+					     struct bdi_writeback *wb)
+{
+	struct mem_cgroup *memcg = page->mem_cgroup;
+	struct memcg_cgwb_frn *frn;
+	u64 now = jiffies_64;
+	u64 oldest_at = now;
+	int oldest = -1;
+	int i;
+
+	/*
+	 * Pick the slot to use.  If there is already a slot for @wb, keep
+	 * using it.  If not replace the oldest one which isn't being
+	 * written out.
+	 */
+	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++) {
+		frn = &memcg->cgwb_frn[i];
+		if (frn->bdi_id == wb->bdi->id &&
+		    frn->memcg_id == wb->memcg_css->id)
+			break;
+		if (frn->at < oldest_at && atomic_read(&frn->done.cnt) == 1) {
+			oldest = i;
+			oldest_at = frn->at;
+		}
+	}
+
+	if (i < MEMCG_CGWB_FRN_CNT) {
+		/*
+		 * Re-using an existing one.  Update timestamp lazily to
+		 * avoid making the cacheline hot.  We want them to be
+		 * reasonably up-to-date and significantly shorter than
+		 * dirty_expire_interval as that's what expires the record.
+		 * Use the shorter of 1s and dirty_expire_interval / 8.
+		 */
+		unsigned long update_intv =
+			min_t(unsigned long, HZ,
+			      msecs_to_jiffies(dirty_expire_interval * 10) / 8);
+
+		if (frn->at < now - update_intv)
+			frn->at = now;
+	} else if (oldest >= 0) {
+		/* replace the oldest free one */
+		frn = &memcg->cgwb_frn[oldest];
+		frn->bdi_id = wb->bdi->id;
+		frn->memcg_id = wb->memcg_css->id;
+		frn->at = now;
+	}
+}
+
+/* issue foreign writeback flushes for recorded foreign dirtying events */
+void mem_cgroup_flush_foreign(struct bdi_writeback *wb)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
+	unsigned long intv = msecs_to_jiffies(dirty_expire_interval * 10);
+	u64 now = jiffies_64;
+	int i;
+
+	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++) {
+		struct memcg_cgwb_frn *frn = &memcg->cgwb_frn[i];
+
+		/*
+		 * If the record is older than dirty_expire_interval,
+		 * writeback on it has already started.  No need to kick it
+		 * off again.  Also, don't start a new one if there's
+		 * already one in flight.
+		 */
+		if (frn->at > now - intv && atomic_read(&frn->done.cnt) == 1) {
+			frn->at = 0;
+			cgroup_writeback_by_id(frn->bdi_id, frn->memcg_id,
+					       LONG_MAX, WB_REASON_FOREIGN_FLUSH,
+					       &frn->done);
+		}
+	}
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
@@ -4700,6 +4823,7 @@ static struct mem_cgroup *mem_cgroup_all
 	struct mem_cgroup *memcg;
 	unsigned int size;
 	int node;
+	int __maybe_unused i;
 
 	size = sizeof(struct mem_cgroup);
 	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
@@ -4743,6 +4867,9 @@ static struct mem_cgroup *mem_cgroup_all
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
+	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++)
+		memcg->cgwb_frn[i].done =
+			__WB_COMPLETION_INIT(&memcg_cgwb_frn_waitq);
 #endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
@@ -4872,7 +4999,12 @@ static void mem_cgroup_css_released(stru
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	int __maybe_unused i;
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++)
+		wb_wait_for_completion(&memcg->cgwb_frn[i].done);
+#endif
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1667,6 +1667,8 @@ static void balance_dirty_pages(struct b
 		if (unlikely(!writeback_in_progress(wb)))
 			wb_start_background_writeback(wb);
 
+		mem_cgroup_flush_foreign(wb);
+
 		/*
 		 * Calculate global domain's pos_ratio and select the
 		 * global dtc by default.
@@ -2427,6 +2429,8 @@ void account_page_dirtied(struct page *p
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
+
+		mem_cgroup_track_foreign_dirty(page, wb);
 	}
 }
 

