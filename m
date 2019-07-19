Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C5DEC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0A59218A3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xgNF3teO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0A59218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 902038E000F; Fri, 19 Jul 2019 00:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B38F8E0001; Fri, 19 Jul 2019 00:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72E1E8E000F; Fri, 19 Jul 2019 00:07:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD018E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:07:32 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so15127214plq.21
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:07:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RIVSoNxRSVjTqd4Tgu5og1NW8HdOaYpDKWMdWkZkUmw=;
        b=nnLzvsAUAw1slU+x0ysU12sGM4schkrb1NzxWKR48ClcL8N5CAOKhJv+x2Xtoj1TP6
         O1GWuwNLLvfDjsR+Q5n4sib0tQ0zkop2mD/M7NB/aQtUcpZEv+ioa5vh7RkyOGhZdrZd
         01l9Eq0wg6bTd1GNLVnsgqELZShMG58eYenDqYNj/IjZBTFJTTENJl9E+QtjA7CABd9Z
         3qCpMp80JYo6ywGRrOf3+JYhRQ/T5R2PpCnFXCVSCeh3rnRtv/Idg6nMDO+kZWdcXjF/
         SlMT23tTLAquRQCt37dOuPycpmFfwwh1ubhsn+8eoMNwFHn7MrZ9otjdtrKJrDUUvGfm
         5Qag==
X-Gm-Message-State: APjAAAUT7OjAbtewrajDEdqYDPp/hhFJMyUe+KMzkacYVn7dDe0xN+Xx
	KGPACAoROAoBoGx4WIx/+RJXlVXyz+muZTt1e1RVIZi8AFxbyGlb0oojW3JF7QVAYsfz2ikZxuC
	rWBLSYU0EVFHJybRY++vS7DWmNFrj38jCOd/rc704t/zW75ftODI/fjnfjgxz0YvDdQ==
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr24124074pje.77.1563509251811;
        Thu, 18 Jul 2019 21:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOm1o7WbnssKVPYxMrtXRCueB/e5RqDj1p4L8AW9cQxX9g65yp7geLC2GteaepYYgPJpqM
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr24123988pje.77.1563509250703;
        Thu, 18 Jul 2019 21:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509250; cv=none;
        d=google.com; s=arc-20160816;
        b=VoXs5EeUD/X20BaHVe9twSroNd7/N0OwpWYrdfSwZ3tvBs4gUiAVhICIWh8jD0bNS1
         YDWQn6CmQLsEgcJjbfzxsqIRnsnywUWYj0ZO2HxU2dy2p8kHOifdtQvH4dTCk1qnXVo8
         ys/YttHAL+UKyqL5fUqll6Ytwa98aoidUMQgSsuqXsLoFz4F74lwh0cpSUfL8j8S729L
         EJTXdEQ/SzjPl050ES8dZZfGsNvrqWhtVonJe5BAFUz8v6Y487VhkoLSvJj8kLQdAh38
         IC9BXBW2gUREb+B+mQ2DIf3zYWZ0ae8QT2pGR5iREkSJnoHdlQ7EbC2Y16yarUt7m41r
         ZtwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RIVSoNxRSVjTqd4Tgu5og1NW8HdOaYpDKWMdWkZkUmw=;
        b=ahL+sN6xJUDtoC0BzmOBmiqYBXLewWG1FK+rrXMVxrvZrsQmoEM+fCXwrmnzyhmXdf
         yttBxQaFz3DbFKYMzYP1uOJifiBiuAObchSCtJym+NehVfI/fyxcW2pdiL2v5Mh3S4IK
         xNIKo6FVZ+X4E74PkiwyzdmVbESdtvWs4t1vk3V1ib8MKgKqsMmMvWCaHcDyZY6zp3VL
         sI2Atl1qPdBcQJbDuLwpgpOk60CH1Nou+GJywOjoLgXF0Ov8+6ryub94m6ngP8v++sWZ
         1YurkrD9CeAeqrE4Y1r3Ktq4UhbSbEMtWGqkKMjtlp9EA4B8lyYUKpbxQouL6qhubaVh
         5PYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xgNF3teO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u27si190879pgn.231.2019.07.18.21.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xgNF3teO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3692321873;
	Fri, 19 Jul 2019 04:07:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509250;
	bh=JQqXp82pekskbqrhmg7TXk7wIX7c/tmYDb1xETgLXTI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=xgNF3teOA5f8O8+t1uTOB+n/nHCUonRipEhZ8PNgrFjVOZW3GRsvnp0jYcTrY02XC
	 UAiAcr7krn7Lu0a8pC7pvqvCENXG0Gj51nu1pro5NvkFKJgRXUGtzhWHLJJkOlErgm
	 OwHnu2gl3Ar6oMHxHvu8X2kJss0YZplbqzLwhsHM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Huang Ying <ying.huang@intel.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Hugh Dickins <hughd@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@suse.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 141/141] mm, swap: fix race between swapoff and some swap operations
Date: Fri, 19 Jul 2019 00:02:46 -0400
Message-Id: <20190719040246.15945-141-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

[ Upstream commit eb085574a7526c4375965c5fbf7e5b0c19cdd336 ]

When swapin is performed, after getting the swap entry information from
the page table, system will swap in the swap entry, without any lock held
to prevent the swap device from being swapoff.  This may cause the race
like below,

CPU 1				CPU 2
-----				-----
				do_swap_page
				  swapin_readahead
				    __read_swap_cache_async
swapoff				      swapcache_prepare
  p->swap_map = NULL		        __swap_duplicate
					  p->swap_map[?] /* !!! NULL pointer access */

Because swapoff is usually done when system shutdown only, the race may
not hit many people in practice.  But it is still a race need to be fixed.

To fix the race, get_swap_device() is added to check whether the specified
swap entry is valid in its swap device.  If so, it will keep the swap
entry valid via preventing the swap device from being swapoff, until
put_swap_device() is called.

Because swapoff() is very rare code path, to make the normal path runs as
fast as possible, rcu_read_lock/unlock() and synchronize_rcu() instead of
reference count is used to implement get/put_swap_device().  >From
get_swap_device() to put_swap_device(), RCU reader side is locked, so
synchronize_rcu() in swapoff() will wait until put_swap_device() is
called.

In addition to swap_map, cluster_info, etc.  data structure in the struct
swap_info_struct, the swap cache radix tree will be freed after swapoff,
so this patch fixes the race between swap cache looking up and swapoff
too.

Races between some other swap cache usages and swapoff are fixed too via
calling synchronize_rcu() between clearing PageSwapCache() and freeing
swap cache data structure.

Another possible method to fix this is to use preempt_off() +
stop_machine() to prevent the swap device from being swapoff when its data
structure is being accessed.  The overhead in hot-path of both methods is
similar.  The advantages of RCU based method are,

1. stop_machine() may disturb the normal execution code path on other
   CPUs.

2. File cache uses RCU to protect its radix tree.  If the similar
   mechanism is used for swap cache too, it is easier to share code
   between them.

3. RCU is used to protect swap cache in total_swapcache_pages() and
   exit_swap_address_space() already.  The two mechanisms can be
   merged to simplify the logic.

Link: http://lkml.kernel.org/r/20190522015423.14418-1-ying.huang@intel.com
Fixes: 235b62176712 ("mm/swap: add cluster lock")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>
Not-nacked-by: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/swap.h |  13 +++-
 mm/memory.c          |   2 +-
 mm/swap_state.c      |  16 ++++-
 mm/swapfile.c        | 154 ++++++++++++++++++++++++++++++++++---------
 4 files changed, 146 insertions(+), 39 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..6358a6185634 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -175,8 +175,9 @@ enum {
 	SWP_PAGE_DISCARD = (1 << 10),	/* freed swap page-cluster discards */
 	SWP_STABLE_WRITES = (1 << 11),	/* no overwrite PG_writeback pages */
 	SWP_SYNCHRONOUS_IO = (1 << 12),	/* synchronous IO is efficient */
+	SWP_VALID	= (1 << 13),	/* swap is valid to be operated on? */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 13),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 14),	/* refcount in scan_swap_map */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -460,7 +461,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
-extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
+extern int __swap_count(swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -470,6 +471,12 @@ extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
+extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
+
+static inline void put_swap_device(struct swap_info_struct *si)
+{
+	rcu_read_unlock();
+}
 
 #else /* CONFIG_SWAP */
 
@@ -576,7 +583,7 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
-static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+static inline int __swap_count(swp_entry_t entry)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 57402801ab09..f71256959755 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2720,7 +2720,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 		struct swap_info_struct *si = swp_swap_info(entry);
 
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
-				__swap_count(si, entry) == 1) {
+				__swap_count(entry) == 1) {
 			/* skip swapcache */
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 							vmf->address);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 85245fdec8d9..61453f1faf72 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -310,8 +310,13 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 			       unsigned long addr)
 {
 	struct page *page;
+	struct swap_info_struct *si;
 
+	si = get_swap_device(entry);
+	if (!si)
+		return NULL;
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	put_swap_device(si);
 
 	INC_CACHE_INFO(find_total);
 	if (page) {
@@ -354,8 +359,8 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool *new_page_allocated)
 {
-	struct page *found_page, *new_page = NULL;
-	struct address_space *swapper_space = swap_address_space(entry);
+	struct page *found_page = NULL, *new_page = NULL;
+	struct swap_info_struct *si;
 	int err;
 	*new_page_allocated = false;
 
@@ -365,7 +370,12 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(swapper_space, swp_offset(entry));
+		si = get_swap_device(entry);
+		if (!si)
+			break;
+		found_page = find_get_page(swap_address_space(entry),
+					   swp_offset(entry));
+		put_swap_device(si);
 		if (found_page)
 			break;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index cf63b5f01adf..261cca70f022 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1078,12 +1078,11 @@ swp_entry_t get_swap_page_of_type(int type)
 static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
-	unsigned long offset, type;
+	unsigned long offset;
 
 	if (!entry.val)
 		goto out;
-	type = swp_type(entry);
-	p = swap_type_to_swap_info(type);
+	p = swp_swap_info(entry);
 	if (!p)
 		goto bad_nofile;
 	if (!(p->flags & SWP_USED))
@@ -1186,6 +1185,69 @@ static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
 	return usage;
 }
 
+/*
+ * Check whether swap entry is valid in the swap device.  If so,
+ * return pointer to swap_info_struct, and keep the swap entry valid
+ * via preventing the swap device from being swapoff, until
+ * put_swap_device() is called.  Otherwise return NULL.
+ *
+ * The entirety of the RCU read critical section must come before the
+ * return from or after the call to synchronize_rcu() in
+ * enable_swap_info() or swapoff().  So if "si->flags & SWP_VALID" is
+ * true, the si->map, si->cluster_info, etc. must be valid in the
+ * critical section.
+ *
+ * Notice that swapoff or swapoff+swapon can still happen before the
+ * rcu_read_lock() in get_swap_device() or after the rcu_read_unlock()
+ * in put_swap_device() if there isn't any other way to prevent
+ * swapoff, such as page lock, page table lock, etc.  The caller must
+ * be prepared for that.  For example, the following situation is
+ * possible.
+ *
+ *   CPU1				CPU2
+ *   do_swap_page()
+ *     ...				swapoff+swapon
+ *     __read_swap_cache_async()
+ *       swapcache_prepare()
+ *         __swap_duplicate()
+ *           // check swap_map
+ *     // verify PTE not changed
+ *
+ * In __swap_duplicate(), the swap_map need to be checked before
+ * changing partly because the specified swap entry may be for another
+ * swap device which has been swapoff.  And in do_swap_page(), after
+ * the page is read from the swap device, the PTE is verified not
+ * changed with the page table locked to check whether the swap device
+ * has been swapoff or swapoff+swapon.
+ */
+struct swap_info_struct *get_swap_device(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	unsigned long offset;
+
+	if (!entry.val)
+		goto out;
+	si = swp_swap_info(entry);
+	if (!si)
+		goto bad_nofile;
+
+	rcu_read_lock();
+	if (!(si->flags & SWP_VALID))
+		goto unlock_out;
+	offset = swp_offset(entry);
+	if (offset >= si->max)
+		goto unlock_out;
+
+	return si;
+bad_nofile:
+	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
+out:
+	return NULL;
+unlock_out:
+	rcu_read_unlock();
+	return NULL;
+}
+
 static unsigned char __swap_entry_free(struct swap_info_struct *p,
 				       swp_entry_t entry, unsigned char usage)
 {
@@ -1357,11 +1419,18 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
-int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+int __swap_count(swp_entry_t entry)
 {
+	struct swap_info_struct *si;
 	pgoff_t offset = swp_offset(entry);
+	int count = 0;
 
-	return swap_count(si->swap_map[offset]);
+	si = get_swap_device(entry);
+	if (si) {
+		count = swap_count(si->swap_map[offset]);
+		put_swap_device(si);
+	}
+	return count;
 }
 
 static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
@@ -1386,9 +1455,11 @@ int __swp_swapcount(swp_entry_t entry)
 	int count = 0;
 	struct swap_info_struct *si;
 
-	si = __swap_info_get(entry);
-	if (si)
+	si = get_swap_device(entry);
+	if (si) {
 		count = swap_swapcount(si, entry);
+		put_swap_device(si);
+	}
 	return count;
 }
 
@@ -2334,9 +2405,9 @@ static int swap_node(struct swap_info_struct *p)
 	return bdev ? bdev->bd_disk->node_id : NUMA_NO_NODE;
 }
 
-static void _enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map,
-				struct swap_cluster_info *cluster_info)
+static void setup_swap_info(struct swap_info_struct *p, int prio,
+			    unsigned char *swap_map,
+			    struct swap_cluster_info *cluster_info)
 {
 	int i;
 
@@ -2361,7 +2432,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	}
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
-	p->flags |= SWP_WRITEOK;
+}
+
+static void _enable_swap_info(struct swap_info_struct *p)
+{
+	p->flags |= SWP_WRITEOK | SWP_VALID;
 	atomic_long_add(p->pages, &nr_swap_pages);
 	total_swap_pages += p->pages;
 
@@ -2388,7 +2463,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	 _enable_swap_info(p, prio, swap_map, cluster_info);
+	setup_swap_info(p, prio, swap_map, cluster_info);
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * Guarantee swap_map, cluster_info, etc. fields are valid
+	 * between get/put_swap_device() if SWP_VALID bit is set
+	 */
+	synchronize_rcu();
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2397,7 +2482,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
 {
 	spin_lock(&swap_lock);
 	spin_lock(&p->lock);
-	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	setup_swap_info(p, p->prio, p->swap_map, p->cluster_info);
+	_enable_swap_info(p);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 }
@@ -2500,6 +2586,17 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 
 	reenable_swap_slots_cache_unlock();
 
+	spin_lock(&swap_lock);
+	spin_lock(&p->lock);
+	p->flags &= ~SWP_VALID;		/* mark swap device as invalid */
+	spin_unlock(&p->lock);
+	spin_unlock(&swap_lock);
+	/*
+	 * wait for swap operations protected by get/put_swap_device()
+	 * to complete
+	 */
+	synchronize_rcu();
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -3264,17 +3361,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	unsigned char has_cache;
 	int err = -EINVAL;
 
-	if (non_swap_entry(entry))
-		goto out;
-
-	p = swp_swap_info(entry);
+	p = get_swap_device(entry);
 	if (!p)
-		goto bad_file;
-
-	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
 		goto out;
 
+	offset = swp_offset(entry);
 	ci = lock_cluster_or_swap_info(p, offset);
 
 	count = p->swap_map[offset];
@@ -3320,11 +3411,9 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 unlock_out:
 	unlock_cluster_or_swap_info(p, ci);
 out:
+	if (p)
+		put_swap_device(p);
 	return err;
-
-bad_file:
-	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
-	goto out;
 }
 
 /*
@@ -3416,6 +3505,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	struct page *list_page;
 	pgoff_t offset;
 	unsigned char count;
+	int ret = 0;
 
 	/*
 	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
@@ -3423,15 +3513,15 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	 */
 	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
 
-	si = swap_info_get(entry);
+	si = get_swap_device(entry);
 	if (!si) {
 		/*
 		 * An acceptable race has occurred since the failing
-		 * __swap_duplicate(): the swap entry has been freed,
-		 * perhaps even the whole swap_map cleared for swapoff.
+		 * __swap_duplicate(): the swap device may be swapoff
 		 */
 		goto outer;
 	}
+	spin_lock(&si->lock);
 
 	offset = swp_offset(entry);
 
@@ -3449,9 +3539,8 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 	}
 
 	if (!page) {
-		unlock_cluster(ci);
-		spin_unlock(&si->lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	/*
@@ -3503,10 +3592,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
 out:
 	unlock_cluster(ci);
 	spin_unlock(&si->lock);
+	put_swap_device(si);
 outer:
 	if (page)
 		__free_page(page);
-	return 0;
+	return ret;
 }
 
 /*
-- 
2.20.1

