Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1647C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 762D322CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 762D322CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21BCA6B0273; Tue, 20 Aug 2019 05:50:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A59B6B0272; Tue, 20 Aug 2019 05:50:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F11866B0273; Tue, 20 Aug 2019 05:50:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id C614D6B0271
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:50:22 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2D2AB269CE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:50:22 +0000 (UTC)
X-FDA: 75842335884.04.field72_5a5d0154ce702
X-HE-Tag: field72_5a5d0154ce702
X-Filterd-Recvd-Size: 8492
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com [115.124.30.44])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:50:20 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=37;SR=0;TI=SMTPD_---0TZzk.Cg_1566294578;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZzk.Cg_1566294578)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:38 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Jann Horn <jannh@google.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Arun KS <arunks@codeaurora.org>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Dave Chinner <dchinner@redhat.com>,
	Josef Bacik <josef@toxicpanda.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 14/14] mm/lru: fix the comments of lru_lock
Date: Tue, 20 Aug 2019 17:48:37 +0800
Message-Id: <1566294517-86418-15-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since we changed the pgdat->lru_lock to lruvec->lru_lock, have to fix the
incorrect comments in code. Also fixed some zone->lru_lock comment error
in ancient time.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Jann Horn <jannh@google.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Amir Goldstein <amir73il@gmail.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Josef Bacik <josef@toxicpanda.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Yafang Shao <laoar.shao@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/mm_types.h | 2 +-
 include/linux/mmzone.h   | 4 ++--
 mm/filemap.c             | 4 ++--
 mm/rmap.c                | 2 +-
 mm/vmscan.c              | 6 +++---
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6a7a1083b6fb..f9f990d8f08f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -79,7 +79,7 @@ struct page {
 		struct {	/* Page cache and anonymous pages */
 			/**
 			 * @lru: Pageout list, eg. active_list protected by
-			 * pgdat->lru_lock.  Sometimes used as a generic list
+			 * lruvec->lru_lock.  Sometimes used as a generic list
 			 * by the page owner.
 			 */
 			struct list_head lru;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8d0076d084be..d2f782263e42 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -159,7 +159,7 @@ static inline bool free_area_empty(struct free_area *=
area, int migratetype)
 struct pglist_data;
=20
 /*
- * zone->lock and the zone lru_lock are two of the hottest locks in the =
kernel.
+ * zone->lock and the lru_lock are two of the hottest locks in the kerne=
l.
  * So add a wild amount of padding here to ensure that they fall into se=
parate
  * cachelines.  There are very few zone structures in the machine, so sp=
ace
  * consumption is not a concern here.
@@ -295,7 +295,7 @@ struct zone_reclaim_stat {
=20
 struct lruvec {
 	struct list_head		lists[NR_LRU_LISTS];
-	/* move lru_lock to per lruvec for memcg */
+	/* perf lruvec lru_lock for memcg */
 	spinlock_t			lru_lock;
=20
 	struct zone_reclaim_stat	reclaim_stat;
diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..0a604c8284f2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -100,8 +100,8 @@
  *    ->swap_lock		(try_to_unmap_one)
  *    ->private_lock		(try_to_unmap_one)
  *    ->i_pages lock		(try_to_unmap_one)
- *    ->pgdat->lru_lock		(follow_page->mark_page_accessed)
- *    ->pgdat->lru_lock		(check_pte_range->isolate_lru_page)
+ *    ->lruvec->lru_lock	(follow_page->mark_page_accessed)
+ *    ->lruvec->lru_lock	(check_pte_range->isolate_lru_page)
  *    ->private_lock		(page_remove_rmap->set_page_dirty)
  *    ->i_pages lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e24232..6bee4aebced6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -27,7 +27,7 @@
  *         mapping->i_mmap_rwsem
  *           anon_vma->rwsem
  *             mm->page_table_lock or pte_lock
- *               pgdat->lru_lock (in mark_page_accessed, isolate_lru_pag=
e)
+ *               lruvec->lru_lock (in mark_page_accessed, isolate_lru_pa=
ge)
  *               swap_lock (in swap_duplicate, swap_info_get)
  *                 mmlist_lock (in mmput, drain_mmlist and others)
  *                 mapping->private_lock (in __set_page_dirty_buffers)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ea5c2f3f2567..1328eb182a3e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1662,7 +1662,7 @@ static __always_inline void update_lru_sizes(struct=
 lruvec *lruvec,
 }
=20
 /**
- * pgdat->lru_lock is heavily contended.  Some of the functions that
+ * lruvec->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
@@ -1864,9 +1864,9 @@ static int too_many_isolated(struct pglist_data *pg=
dat, int file,
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold zone_lru_lock across the whole operation.  But if
+ * appropriate to hold lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so w=
e
- * should drop zone_lru_lock around each page.  It's impossible to balan=
ce
+ * should drop lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing th=
em.
  * It is safe to rely on PG_active against the non-LRU pages in here bec=
ause
  * nobody will play with that bit on a non-LRU page.
--=20
1.8.3.1


