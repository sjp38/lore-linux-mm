Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6A8FC31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80EB221726
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kbhAFdlX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80EB221726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7D0F6B0010; Sat,  3 Aug 2019 10:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2D8D6B0266; Sat,  3 Aug 2019 10:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F8D26B0269; Sat,  3 Aug 2019 10:02:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 577B66B0010
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 10:02:14 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e22so5172687qtp.9
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 07:02:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=S29WNWkQzU++CjjwYZJ/xpf/eIhd3FbOeiovUi2IChc=;
        b=AvzOeJ/+DFqU1Wv/sZuXyxurx92Fixpitw6ZgMGUSxF0NdAqTVywLOOhG9q4gLNKdT
         6mxN7F2dapkfruW18artBeGD5WDIRS8w1N3QGB+TGyQSJ/RefNGfW3zXChhOG8obP2Ki
         qLhN25F/pfFnO8b6ah3TFfm5vHvm0D+oiywrTWSgNp6iKxg99BN7HyTy8zCWC4UvFAOg
         3tzVyjzTH8xcqGqhLantXjBvCGCQF09CmPhdQ6VrcvC3wzvLx0HeQGziw41om8Q0laZI
         0GyEvLZyzuA3Z3u4vzpMZ5YMFemADhfirZomwZs+QmTwEgYiVTT1oznKSOav6kjkHomh
         pWrw==
X-Gm-Message-State: APjAAAXxe/YIdDbLYn+iZLJcb+ibRJrJKFoE7dGmS97wQBeO6KF2N06O
	xqpL86Xfq9B0EBMWAAHImuHx/elnISkrfOm18h4U1uNzMwVlKIA8ddBr++FBYwenem3AChJtPYX
	W2RDqLbnxJJtW0J3lT7qiK4DEGWSoa9RPjF8QM6uauX+4xk+3MS/5H14bP8+7+I4=
X-Received: by 2002:aed:2fa7:: with SMTP id m36mr102331408qtd.344.1564840933931;
        Sat, 03 Aug 2019 07:02:13 -0700 (PDT)
X-Received: by 2002:aed:2fa7:: with SMTP id m36mr102331254qtd.344.1564840932403;
        Sat, 03 Aug 2019 07:02:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564840932; cv=none;
        d=google.com; s=arc-20160816;
        b=DTWOORTuoWiF9Pkh3HrLN61Dn9eX+tBqRXyltbdx/D6JOpsL8GYXzMMDOA+YlcRHTq
         +KpKMerW2kjecxuu/9cHRs5HyeI67XEf7biaR9KyR47DIw4lP6wPFz8qaNgu8bHd15X0
         n68urQyDA90GN7sHqZwkP1txe1Ubd2wZsWAijam58tUGlkaKk7y67be/s2FY7imis0qf
         ech80vPdoHe6Oh8PQsvmXJPiUX6uDXaFZ6AJBGodJCmIEXQ66+xrJdCu2i5CCxFJX0f8
         qRqmXLXHlyWWxPwbCtrRh9n0pyJdSF3ALef8tsH04ArG87eZ6C3xzTNx0SAsLJWOFzSU
         4D0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=S29WNWkQzU++CjjwYZJ/xpf/eIhd3FbOeiovUi2IChc=;
        b=tV9d/16Ahs6GOimcahJkPfOwoWwhx6u6+ovHqt+ADmRN9eZ2kGOQ0Vtm4govVFrcfC
         jCrnPIiKfP9gIFA5VnLOFbFIzWE90ISE7ajx/JPICq5WGme8MG5kyf43SgbN1cOck4bW
         wwuyVjk2oJFzdpC7KZhRBC0Qr3FnaVss/wvN1+nbgSO9o3O+zAgaE7CdFtyoYZONNkJ6
         CtXRe/T56F3emXvP1mZxwoQTbYyANyzklPdpYhZT5uEAdzWaUEdp0UhuT9ihjuJT8gjM
         iQHPJxubUNgsnT/oHFGYiQbMzQc6c5NPUQUOYRcVik+7BLZUyB05ek/n1GIsEgbYd98f
         izRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kbhAFdlX;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k30sor66144184qvk.58.2019.08.03.07.02.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 07:02:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kbhAFdlX;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=S29WNWkQzU++CjjwYZJ/xpf/eIhd3FbOeiovUi2IChc=;
        b=kbhAFdlXnWd69ZBZDBfysba4fmhy6LvtaMjAjv6emUktUDs6HxuvjRF2tJqq9UkllF
         CKg9z2vmBm0YgYfPgXKGTwZt8vm4+nnDAU0iQvLiSuq1OkuknWRrrFbtoX5pg+S3YPML
         uHzTU44N6Lnisgi96JuEDl7UzRQMCC9+eNGyP60qFVCNQmx6VXRmsCkCynQg8LLeuoW7
         FCqbpm30rc6h4XpOmYBUYEKtUM0MkuCwODRd4du0o7Ag0kIX6zQR4SZz8cEWZvMeSIBh
         thK+ayzeTEM7BFeySrLgi0oCKB/HqBGrrAiymbVrCrdPr/NPmZxepLrtQsv9pJWC9NOF
         I9zg==
X-Google-Smtp-Source: APXvYqzgZksolNUaImJ0bbGEqwWi8Rgfmv8HxxaOizjS3v6/bgfD1LnAwjuVrYkHuzwCxF4nhDGPQw==
X-Received: by 2002:a05:6214:11ad:: with SMTP id u13mr8698935qvv.31.1564840931896;
        Sat, 03 Aug 2019 07:02:11 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::efce])
        by smtp.gmail.com with ESMTPSA id i17sm31874735qkl.71.2019.08.03.07.02.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 07:02:11 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk,
	jack@suse.cz,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	guro@fb.com,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/4] writeback, memcg: Implement foreign dirty flushing
Date: Sat,  3 Aug 2019 07:01:55 -0700
Message-Id: <20190803140155.181190-5-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190803140155.181190-1-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
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

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/backing-dev-defs.h |   1 +
 include/linux/memcontrol.h       |  35 +++++++++
 mm/memcontrol.c                  | 125 +++++++++++++++++++++++++++++++
 mm/page-writeback.c              |   4 +
 4 files changed, 165 insertions(+)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 1075f2552cfc..4fc87dee005a 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -63,6 +63,7 @@ enum wb_reason {
 	 * so it has a mismatch name.
 	 */
 	WB_REASON_FORKER_THREAD,
+	WB_REASON_FOREIGN_FLUSH,
 
 	WB_REASON_MAX,
 };
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44c41462be33..7422e4a4dbeb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -183,6 +183,19 @@ struct memcg_padding {
 #define MEMCG_PADDING(name)
 #endif
 
+/*
+ * Remember four most recent foreign inodes with dirty pages on this
+ * cgroup.  See mem_cgroup_track_foreign_dirty_slowpath() for details.
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
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -307,6 +320,7 @@ struct mem_cgroup {
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct list_head cgwb_list;
 	struct wb_domain cgwb_domain;
+	struct memcg_cgwb_frn cgwb_frn[MEMCG_CGWB_FRN_CNT];
 #endif
 
 	/* List of events which userspace want to receive */
@@ -1218,6 +1232,18 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
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
@@ -1233,6 +1259,15 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a84cb6e..e642fbacb504 100644
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
@@ -4145,6 +4149,118 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
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
+		unsigned long update_intv =
+			min_t(unsigned long, HZ,
+			      msecs_to_jiffies(dirty_expire_interval * 10) / 8);
+		/*
+		 * Re-using an existing one.  Let's update timestamp lazily
+		 * to avoid making the cacheline hot.
+		 */
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
+/*
+ * Issue foreign writeback flushes for recorded foreign dirtying events
+ * which haven't expired yet and aren't already being written out.
+ */
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
@@ -4661,6 +4777,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	struct mem_cgroup *memcg;
 	unsigned int size;
 	int node;
+	int __maybe_unused i;
 
 	size = sizeof(struct mem_cgroup);
 	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
@@ -4704,6 +4821,9 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
+	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++)
+		memcg->cgwb_frn[i].done =
+			__WB_COMPLETION_INIT(&memcg_cgwb_frn_waitq);
 #endif
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
@@ -4833,7 +4953,12 @@ static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
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
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 1804f64ff43c..50055d2e4ea8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1667,6 +1667,8 @@ static void balance_dirty_pages(struct bdi_writeback *wb,
 		if (unlikely(!writeback_in_progress(wb)))
 			wb_start_background_writeback(wb);
 
+		mem_cgroup_flush_foreign(wb);
+
 		/*
 		 * Calculate global domain's pos_ratio and select the
 		 * global dtc by default.
@@ -2427,6 +2429,8 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
+
+		mem_cgroup_track_foreign_dirty(page, wb);
 	}
 }
 
-- 
2.17.1

