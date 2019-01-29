Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D3B5C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5B4620881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:29:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5B4620881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66DF98E0002; Tue, 29 Jan 2019 15:29:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61D158E0001; Tue, 29 Jan 2019 15:29:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BFA38E0002; Tue, 29 Jan 2019 15:29:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 049118E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:29:25 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so17758196pfq.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:29:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=UqOElPVkkyzdKvfBPRr3RcV8RVN9dnbL5s5alNHC1E8=;
        b=V3m9oJ4op0PR6RrOL9lcnWHIe/nrqo8Rz/bBfiPwdqDiB2iEnv91FOImvfbXBmaHvF
         ZkgadMfHDPQiizxq6i0A2cIeYq0iA37zCH8dkhPGZvRHPmJvtuwsYAa2+ap3R9fTdDAo
         wM5Rd72UHfgqKzu0VAzvPORXyA4iL3HJDphHxEWVsxgWtXmXaB/w1HjmqeqsdrEK9Tpo
         OzLLba8eZvwFBahHPsLyXuWX6wXJVqh4Fm0C7NKo58TMJckIUJLlihwmqtNeApU3hvJQ
         0m7JMb9vJMHCYVjScsB+Fo/3J4GesIUJzupmETVyD/AGPId3iwQ8euUPUCKV5zCZMbMn
         EGrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukfEtciXUXCTDHcr0sM7Y5p7rQOHAwALAImM+azM1ATD3Yuv0+lB
	10WDsKcGNcf9BefPazpeDlcaWduwYsqpI+Fp3xXfHaAD1KrRNM/AjQ2EiPKPxWVEgxCRqO4plWu
	Mz8g+V7wIIhKhJbdRWN/Ug7nkpDuQsxRIvb8gOGuKpAOdcFKLJNa9P33gvFTseXV4yg==
X-Received: by 2002:a65:4381:: with SMTP id m1mr24589584pgp.358.1548793764596;
        Tue, 29 Jan 2019 12:29:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5XRMonXIaizyGxe4bR1OW5esoFrZX6AkV/BNvqaQWYbtkSgp4nJMqpM463RH2ejNbHk1tB
X-Received: by 2002:a65:4381:: with SMTP id m1mr24589500pgp.358.1548793763106;
        Tue, 29 Jan 2019 12:29:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548793763; cv=none;
        d=google.com; s=arc-20160816;
        b=T4NktJJKIrzhK7diSdvWVHawd6eaeXBDOPCaOT/nCNrds1ANUU36TZzU/iiKZ0SD7n
         u2al9z/9SIAsNOPam99CC33nXt+Q8IqOJgu0anKg8LkT7vbNWpiuw03G24es8CT/GSHM
         bADNHQxofUkmsvft/wsqqWbElOrGEdr7RB8MaRjvf4rb5uH6K2doZpJNQA9bor/CnFR4
         SlQw2P1bwVK6MEetvbyTf956emrthSgl+mzTfHH9IfKTQ5CTWjC45UG9sc3jgpJq0V59
         Vg4u11jv6kshz/cmvGdVYTzEOW1I22IMbHShN2Pb3nQgNrW36xOHzaVtkj4A8nWV2n8D
         MQDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=UqOElPVkkyzdKvfBPRr3RcV8RVN9dnbL5s5alNHC1E8=;
        b=qSEyzwMCUiPeF44MFq4Eki3AkDBLWc8mHrl1ZNseJt2Y1CJN1T1goSbKpAEyPrQfv/
         ciBXwHZtJTdbv3twJJGAwOK+eU7Di4lW3mtcvAhFoK/KgdrjOzvdMosIw/WB7JqYCZYy
         xlRqjx42ixoJt/XYyOdLKPNHiwahJ8aXCZW5a5gAK4CDzvq4lY3Ecerr72sJnTrfH2ic
         796Bk9l0PzRbXJe0qX7RIFN/jHrxX9x7nXsm7l61A3TKqmDntDyak8q09Vmyhclmueb1
         wJHHYyznF106Qzz1N2qKLM0ut6ZLVSUMuOu17+1Cbrh6Gjhd6v2wK945oInSL+HpJeSR
         1f6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id y7si36886900pgc.236.2019.01.29.12.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:29:23 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TJEYhtT_1548793753;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TJEYhtT_1548793753)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 30 Jan 2019 04:29:20 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ktkhai@virtuozzo.com,
	jhubbard@nvidia.com,
	hughd@google.com,
	aarcange@redhat.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH] mm: ksm: do not block on page lock when searching stable tree
Date: Wed, 30 Jan 2019 04:29:13 +0800
Message-Id: <1548793753-62377-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ksmd need search stable tree to look for the suitable KSM page, but the
KSM page might be locked for a while due to i.e. KSM page rmap walk.
Basically it is not a big deal since commit 2c653d0ee2ae
("ksm: introduce ksm_max_page_sharing per page deduplication limit"),
since max_page_sharing limits the number of shared KSM pages.

But it still sounds not worth waiting for the lock, the page can be skip,
then try to merge it in the next scan to avoid potential stall if its
content is still intact.

Introduce trylock mode to get_ksm_page() to not block on page lock, like
what try_to_merge_one_page() does.  And, define three possible
operations (nolock, lock and trylock) as enum type to avoid stacking up
bools and make the code more readable.

Return -EBUSY if trylock fails, since NULL means not find suitable KSM
page, which is a valid case.

With the default max_page_sharing setting (256), there is almost no
observed change comparing lock vs trylock.

However, with ksm02 of LTP, the reduced ksmd full scan time can be
observed, which has set max_page_sharing to 786432.  With lock version,
ksmd may tak 10s - 11s to run two full scans, with trylock version ksmd
may take 8s - 11s to run two full scans.  And, the number of
pages_sharing and pages_to_scan keep same.  Basically, this change has
no harm.

Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
Hi folks,

This patch was with "mm: vmscan: skip KSM page in direct reclaim if priority
is low" in the initial submission.  Then Hugh and Andrea pointed out commit
2c653d0ee2ae ("ksm: introduce ksm_max_page_sharing per page deduplication
limit") is good enough for limiting the number of shared KSM page to prevent
from softlock when walking ksm page rmap.  This commit does solve the problem.
So, the series was dropped by Andrew from -mm tree.

However, I thought the second patch (this one) still sounds useful.  So, I did
some test and resubmit it.  The first version was reviewed by Krill Tkhai, so
I keep his Reviewed-by tag since there is no change to the patch except the
commit log.

So, would you please reconsider this patch?

v3: Use enum to define get_ksm_page operations (nolock, lock and trylock) per
    John Hubbard
v2: Updated the commit log to reflect some test result and latest discussion

 mm/ksm.c | 46 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 36 insertions(+), 10 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 6c48ad1..5647bc1 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -667,6 +667,12 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 	free_stable_node(stable_node);
 }
 
+enum get_ksm_page_flags {
+	GET_KSM_PAGE_NOLOCK,
+	GET_KSM_PAGE_LOCK,
+	GET_KSM_PAGE_TRYLOCK
+};
+
 /*
  * get_ksm_page: checks if the page indicated by the stable node
  * is still its ksm page, despite having held no reference to it.
@@ -686,7 +692,8 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
  * a page to put something that might look like our key in page->mapping.
  * is on its way to being freed; but it is an anomaly to bear in mind.
  */
-static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
+static struct page *get_ksm_page(struct stable_node *stable_node,
+				 enum get_ksm_page_flags flags)
 {
 	struct page *page;
 	void *expected_mapping;
@@ -728,8 +735,15 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 		goto stale;
 	}
 
-	if (lock_it) {
+	if (flags == GET_KSM_PAGE_TRYLOCK) {
+		if (!trylock_page(page)) {
+			put_page(page);
+			return ERR_PTR(-EBUSY);
+		}
+	} else if (flags == GET_KSM_PAGE_LOCK)
 		lock_page(page);
+
+	if (flags != GET_KSM_PAGE_NOLOCK) {
 		if (READ_ONCE(page->mapping) != expected_mapping) {
 			unlock_page(page);
 			put_page(page);
@@ -763,7 +777,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		struct page *page;
 
 		stable_node = rmap_item->head;
-		page = get_ksm_page(stable_node, true);
+		page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
 		if (!page)
 			goto out;
 
@@ -863,7 +877,7 @@ static int remove_stable_node(struct stable_node *stable_node)
 	struct page *page;
 	int err;
 
-	page = get_ksm_page(stable_node, true);
+	page = get_ksm_page(stable_node, GET_KSM_PAGE_LOCK);
 	if (!page) {
 		/*
 		 * get_ksm_page did remove_node_from_stable_tree itself.
@@ -1385,7 +1399,7 @@ static struct page *stable_node_dup(struct stable_node **_stable_node_dup,
 		 * stable_node parameter itself will be freed from
 		 * under us if it returns NULL.
 		 */
-		_tree_page = get_ksm_page(dup, false);
+		_tree_page = get_ksm_page(dup, GET_KSM_PAGE_NOLOCK);
 		if (!_tree_page)
 			continue;
 		nr += 1;
@@ -1508,7 +1522,7 @@ static struct page *__stable_node_chain(struct stable_node **_stable_node_dup,
 	if (!is_stable_node_chain(stable_node)) {
 		if (is_page_sharing_candidate(stable_node)) {
 			*_stable_node_dup = stable_node;
-			return get_ksm_page(stable_node, false);
+			return get_ksm_page(stable_node, GET_KSM_PAGE_NOLOCK);
 		}
 		/*
 		 * _stable_node_dup set to NULL means the stable_node
@@ -1613,7 +1627,8 @@ static struct page *stable_tree_search(struct page *page)
 			 * wrprotected at all times. Any will work
 			 * fine to continue the walk.
 			 */
-			tree_page = get_ksm_page(stable_node_any, false);
+			tree_page = get_ksm_page(stable_node_any,
+						 GET_KSM_PAGE_NOLOCK);
 		}
 		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
 		if (!tree_page) {
@@ -1673,7 +1688,12 @@ static struct page *stable_tree_search(struct page *page)
 			 * It would be more elegant to return stable_node
 			 * than kpage, but that involves more changes.
 			 */
-			tree_page = get_ksm_page(stable_node_dup, true);
+			tree_page = get_ksm_page(stable_node_dup,
+						 GET_KSM_PAGE_TRYLOCK);
+
+			if (PTR_ERR(tree_page) == -EBUSY)
+				return ERR_PTR(-EBUSY);
+
 			if (unlikely(!tree_page))
 				/*
 				 * The tree may have been rebalanced,
@@ -1842,7 +1862,8 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 			 * wrprotected at all times. Any will work
 			 * fine to continue the walk.
 			 */
-			tree_page = get_ksm_page(stable_node_any, false);
+			tree_page = get_ksm_page(stable_node_any,
+						 GET_KSM_PAGE_NOLOCK);
 		}
 		VM_BUG_ON(!stable_node_dup ^ !!stable_node_any);
 		if (!tree_page) {
@@ -2060,6 +2081,10 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 
 	/* We first start with searching the page inside the stable tree */
 	kpage = stable_tree_search(page);
+
+	if (PTR_ERR(kpage) == -EBUSY)
+		return;
+
 	if (kpage == page && rmap_item->head == stable_node) {
 		put_page(kpage);
 		return;
@@ -2242,7 +2267,8 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 			list_for_each_entry_safe(stable_node, next,
 						 &migrate_nodes, list) {
-				page = get_ksm_page(stable_node, false);
+				page = get_ksm_page(stable_node,
+						    GET_KSM_PAGE_NOLOCK);
 				if (page)
 					put_page(page);
 				cond_resched();
-- 
1.8.3.1

