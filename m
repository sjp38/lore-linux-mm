Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33748C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:29:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D583A21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:29:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="WaapcHLY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D583A21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66A5F6B000D; Wed, 12 Jun 2019 10:29:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C166B000E; Wed, 12 Jun 2019 10:29:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50BB96B0010; Wed, 12 Jun 2019 10:29:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1836C6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:29:56 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 59so9872715plb.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:29:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=iCHx3T9palofJ5ufImfnh5SBUFj5ut7Ba3GPj9Vf5ZY=;
        b=G5tOmAA6eSTxBXPo4ZFKGzFDMGYcc1p1DAUY/nd8xCDJ6WqlW6rnu+Pk+JUmC+h+6b
         YZmc2QKAtmXL28HvlgNdMXxTj4oWUFEuP7Pipd2Hyv6p/ZWeRwqo/G3RyY4YAnCgsHjZ
         mx32Vjm27tDFgaM8aOqIKSaUeHmT4sIPlPiPETUlzTt01gdPJ//D4Sev+M2kickBCHMw
         QnjBzO7E19bilnrZHqxC1rEsLeqx3n0cX9+OviKAxALITG23uryv7/16wpNdgaSPZKqf
         ri1ZLJ+vz7XZjDR5fDT9NS+ift/OI5+5R/8yHasmrcesTVg1V4bhvuixeIxwQhi5ulRO
         X9Mw==
X-Gm-Message-State: APjAAAUPXR1iOCzi8YJzCqij1Lqbt4hT1gI7I0jb11lGA9hxF9uttJiE
	yphwfiAmWJBCd3SkUshHIEaDYrsKa2sh4DeF8BxuoiJOzD28V7FB9xOBhG01+ZiepvdDdOvDPHb
	rlCpB99MTM5lUO2Nx4TYKX6rNQFzMiP+KJ09XRiYUy9LSMHRLLhCKk2/HWb5DIyvQ6g==
X-Received: by 2002:a17:90a:62cb:: with SMTP id k11mr31746018pjs.26.1560349795665;
        Wed, 12 Jun 2019 07:29:55 -0700 (PDT)
X-Received: by 2002:a17:90a:62cb:: with SMTP id k11mr31745943pjs.26.1560349794621;
        Wed, 12 Jun 2019 07:29:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349794; cv=none;
        d=google.com; s=arc-20160816;
        b=jWp7ioP1FU7/dlhednN9k9kyEM296FS7fZp7fT1OafGzZcY2Equ++ZOLem6b8J46YS
         RtuG0WTuvZgcuU9MMAMOkZ1SEb34mmvws+KQrcEaPE8cDiNA8rMQZp/4/vku4UxEKgoL
         YXV5jrQMZVHUh02bMIJIm95PsURisdryQIiHpwJE0xLCcqTNTn+9/NbVH0oowkems+9Z
         BSzp3pNFMZnjxwZJGlRox2QzoKLINmXT+rfayrr22hGnB8qSrVZkD1poTkvJbExHETJk
         iALtnQrGhwTz09ueXGtE+CNuTO1LvatFg5GMBoBe7etuyxxre45OCgdHKaemCfp/8HBC
         AxHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=iCHx3T9palofJ5ufImfnh5SBUFj5ut7Ba3GPj9Vf5ZY=;
        b=1JyP2no/lLE5PoUY5e0rFCSKYYLnnGzI9Ym9zFGF1jw6DyvsBN5BOGlMIKvsA3tHWP
         tsqza6udecbklIiQ2U3ise5upxbWjRoRg6Fwf9HfzgItWFc47waarVG9nTQdBHd5khli
         VXHqoDUunLXQis6ZsQWp+XSsWoBQBvBor6WoZF/SC1U3rYjidzzEAN03r2STqECHurlb
         w60oWBpAV31g9vjs2/qEaVkLBwJHIzzcrYJYoBRsQLUV8ydRZtqcquwBvOBoJD74M9qr
         DqWRqM1rioTOOoAYkPsbZYiaSGvX6U/5+HpGD3rQWwEngvIlCANlbP9IiYUWwO4y+70j
         4XLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WaapcHLY;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor19000688plt.10.2019.06.12.07.29.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 07:29:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=WaapcHLY;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=iCHx3T9palofJ5ufImfnh5SBUFj5ut7Ba3GPj9Vf5ZY=;
        b=WaapcHLYnn8KZ0Lr8heBAQlJlNFE3HgxWjGBFUPjzoDGoC4S1GtN+nIy+tLvqWWLky
         OxElrP5RWClFzJIYh3GA4NVx2QOBrH1j5IioJEs4fsIqXy5Z8vTv3WuSL6uKI2x53SVt
         aE4iEQBLtDgE0bGdVbBjU6Z4bpfoCMxuneI5E=
X-Google-Smtp-Source: APXvYqysjXgN24E9kpl/sHL0aM/SlhKn92jleZoYpPMHrYiEBH1ShG3+dGGf1eFnSABr69oflL5xfw==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr82055857plb.221.1560349794178;
        Wed, 12 Jun 2019 07:29:54 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id j2sm6822436pgq.13.2019.06.12.07.29.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 07:29:53 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: Joel Fernandes <joelaf@google.com>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Bradley Bolen <bradleybolen@gmail.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Michal Hocko <mhocko@suse.cz>,
	stable@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Brian Foster <bfoster@redhat.com>,
	cgroups@vger.kernel.org,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Jan Kara <jack@suse.cz>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: [PATCH BACKPORT Android 4.9]: mm: memcontrol: fix NULL pointer crash in test_clear_page_writeback()
Date: Wed, 12 Jun 2019 10:29:50 -0400
Message-Id: <20190612142951.99559-1-joel@joelfernandes.org>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joel Fernandes <joelaf@google.com>

Johannes, all, could you take a look at the below backport of this fix
which I am apply for our Android 4.9 kernel? Since lruvec stats are not
present in the kernel and I did not want to backport that, I added my
own mem_cgroup_update_stat functions which should be sufficient for this
fix. Does this patch look good to you? Thanks for the help.

(Joel: Fixed conflicts and added new memcg stats functions)
(Cherry-picked from 739f79fc9db1)

Jaegeuk and Brad report a NULL pointer crash when writeback ending tries
to update the memcg stats:

    BUG: unable to handle kernel NULL pointer dereference at 00000000000003b0
    IP: test_clear_page_writeback+0x12e/0x2c0
    [...]
    RIP: 0010:test_clear_page_writeback+0x12e/0x2c0
    Call Trace:
     <IRQ>
     end_page_writeback+0x47/0x70
     f2fs_write_end_io+0x76/0x180 [f2fs]
     bio_endio+0x9f/0x120
     blk_update_request+0xa8/0x2f0
     scsi_end_request+0x39/0x1d0
     scsi_io_completion+0x211/0x690
     scsi_finish_command+0xd9/0x120
     scsi_softirq_done+0x127/0x150
     __blk_mq_complete_request_remote+0x13/0x20
     flush_smp_call_function_queue+0x56/0x110
     generic_smp_call_function_single_interrupt+0x13/0x30
     smp_call_function_single_interrupt+0x27/0x40
     call_function_single_interrupt+0x89/0x90
    RIP: 0010:native_safe_halt+0x6/0x10

    (gdb) l *(test_clear_page_writeback+0x12e)
    0xffffffff811bae3e is in test_clear_page_writeback (./include/linux/memcontrol.h:619).
    614		mod_node_page_state(page_pgdat(page), idx, val);
    615		if (mem_cgroup_disabled() || !page->mem_cgroup)
    616			return;
    617		mod_memcg_state(page->mem_cgroup, idx, val);
    618		pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
    619		this_cpu_add(pn->lruvec_stat->count[idx], val);
    620	}
    621
    622	unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
    623							gfp_t gfp_mask,

The issue is that writeback doesn't hold a page reference and the page
might get freed after PG_writeback is cleared (and the mapping is
unlocked) in test_clear_page_writeback().  The stat functions looking up
the page's node or zone are safe, as those attributes are static across
allocation and free cycles.  But page->mem_cgroup is not, and it will
get cleared if we race with truncation or migration.

It appears this race window has been around for a while, but less likely
to trigger when the memcg stats were updated first thing after
PG_writeback is cleared.  Recent changes reshuffled this code to update
the global node stats before the memcg ones, though, stretching the race
window out to an extent where people can reproduce the problem.

Update test_clear_page_writeback() to look up and pin page->mem_cgroup
before clearing PG_writeback, then not use that pointer afterward.  It
is a partial revert of 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
but leaves the pageref-holding callsites that aren't affected alone.

Change-Id: I692226d6f183c11c27ed096967e6a5face3b9741
Link: http://lkml.kernel.org/r/20170809183825.GA26387@cmpxchg.org
Fixes: 62cccb8c8e7a ("mm: simplify lock_page_memcg()")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: Jaegeuk Kim <jaegeuk@kernel.org>
Tested-by: Jaegeuk Kim <jaegeuk@kernel.org>
Reported-by: Bradley Bolen <bradleybolen@gmail.com>
Tested-by: Brad Bolen <bradleybolen@gmail.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: <stable@vger.kernel.org>	[4.6+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Joel Fernandes <joelaf@google.com>

---
 include/linux/memcontrol.h | 31 +++++++++++++++++++++++++--
 mm/memcontrol.c            | 43 +++++++++++++++++++++++++++-----------
 mm/page-writeback.c        | 14 ++++++++++---
 3 files changed, 71 insertions(+), 17 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8b35bdbdc214c..f9e02fd7e86b7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -490,7 +490,8 @@ bool mem_cgroup_oom_synchronize(bool wait);
 extern int do_swap_account;
 #endif
 
-void lock_page_memcg(struct page *page);
+struct mem_cgroup *lock_page_memcg(struct page *page);
+void __unlock_page_memcg(struct mem_cgroup *memcg);
 void unlock_page_memcg(struct page *page);
 
 /**
@@ -529,6 +530,27 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
+static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
+				 enum mem_cgroup_stat_index idx, int val)
+{
+	VM_BUG_ON(!(rcu_read_lock_held()));
+
+	if (memcg)
+		this_cpu_add(memcg->stat->count[idx], val);
+}
+
+static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
+					    enum mem_cgroup_stat_index idx)
+{
+	mem_cgroup_update_stat(memcg, idx, 1);
+}
+
+static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
+					    enum mem_cgroup_stat_index idx)
+{
+	mem_cgroup_update_stat(memcg, idx, -1);
+}
+
 unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
@@ -709,7 +731,12 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void lock_page_memcg(struct page *page)
+static inline struct mem_cgroup *lock_page_memcg(struct page *page)
+{
+	return NULL;
+}
+
+static inline void __unlock_page_memcg(struct mem_cgroup *memcg)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 86a6b331b9648..8dfd048ca1602 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1619,9 +1619,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
  * @page: the page
  *
  * This function protects unlocked LRU pages from being moved to
- * another cgroup and stabilizes their page->mem_cgroup binding.
+ * another cgroup.
+ *
+ * It ensures lifetime of the returned memcg. Caller is responsible
+ * for the lifetime of the page; __unlock_page_memcg() is available
+ * when @page might get freed inside the locked section.
  */
-void lock_page_memcg(struct page *page)
+struct mem_cgroup *lock_page_memcg(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long flags;
@@ -1630,18 +1634,24 @@ void lock_page_memcg(struct page *page)
 	 * The RCU lock is held throughout the transaction.  The fast
 	 * path can get away without acquiring the memcg->move_lock
 	 * because page moving starts with an RCU grace period.
-	 */
+	 *
+	 * The RCU lock also protects the memcg from being freed when
+	 * the page state that is going to change is the only thing
+	 * preventing the page itself from being freed. E.g. writeback
+	 * doesn't hold a page reference and relies on PG_writeback to
+	 * keep off truncation, migration and so forth.
+         */
 	rcu_read_lock();
 
 	if (mem_cgroup_disabled())
-		return;
+		return NULL;
 again:
 	memcg = page->mem_cgroup;
 	if (unlikely(!memcg))
-		return;
+		return NULL;
 
 	if (atomic_read(&memcg->moving_account) <= 0)
-		return;
+		return memcg;
 
 	spin_lock_irqsave(&memcg->move_lock, flags);
 	if (memcg != page->mem_cgroup) {
@@ -1657,18 +1667,18 @@ void lock_page_memcg(struct page *page)
 	memcg->move_lock_task = current;
 	memcg->move_lock_flags = flags;
 
-	return;
+	return memcg;
 }
 EXPORT_SYMBOL(lock_page_memcg);
 
 /**
- * unlock_page_memcg - unlock a page->mem_cgroup binding
- * @page: the page
+ * __unlock_page_memcg - unlock and unpin a memcg
+ * @memcg: the memcg
+ *
+ * Unlock and unpin a memcg returned by lock_page_memcg().
  */
-void unlock_page_memcg(struct page *page)
+void __unlock_page_memcg(struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg = page->mem_cgroup;
-
 	if (memcg && memcg->move_lock_task == current) {
 		unsigned long flags = memcg->move_lock_flags;
 
@@ -1680,6 +1690,15 @@ void unlock_page_memcg(struct page *page)
 
 	rcu_read_unlock();
 }
+
+/**
+ * unlock_page_memcg - unlock a page->mem_cgroup binding
+ * @page: the page
+ */
+void unlock_page_memcg(struct page *page)
+{
+	__unlock_page_memcg(page->mem_cgroup);
+}
 EXPORT_SYMBOL(unlock_page_memcg);
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 46e36366a03a7..9225827230d8c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2704,9 +2704,10 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
 int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
+	struct mem_cgroup *memcg;
 	int ret;
 
-	lock_page_memcg(page);
+	memcg = lock_page_memcg(page);
 	if (mapping && mapping_use_writeback_tags(mapping)) {
 		struct inode *inode = mapping->host;
 		struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -2734,13 +2735,20 @@ int test_clear_page_writeback(struct page *page)
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
+
+	/*
+	 * NOTE: Page might be free now! Writeback doesn't hold a page
+	 * reference on its own, it relies on truncation to wait for
+	 * the clearing of PG_writeback. The below can only access
+	 * page state that is static across allocation cycles.
+	 */
 	if (ret) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_dec_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_node_page_state(page, NR_WRITTEN);
 	}
-	unlock_page_memcg(page);
+	__unlock_page_memcg(memcg);
 	return ret;
 }
 
-- 
2.22.0.rc2.383.gf4fbbf30c2-goog

