Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BD35C5AE59
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6B20216F4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:31:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aszPrJ2t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6B20216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 628F16B0008; Tue, 10 Sep 2019 19:31:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FF966B000A; Tue, 10 Sep 2019 19:31:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 516286B000C; Tue, 10 Sep 2019 19:31:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 32BDF6B0008
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:31:58 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CFECF181AC9CB
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:31:57 +0000 (UTC)
X-FDA: 75920611074.30.curve78_2e299510fdc52
X-HE-Tag: curve78_2e299510fdc52
X-Filterd-Recvd-Size: 11662
Received: from mail-pg1-f202.google.com (mail-pg1-f202.google.com [209.85.215.202])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:31:57 +0000 (UTC)
Received: by mail-pg1-f202.google.com with SMTP id w5so11570448pgs.5
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:31:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=fLM4n8WI6nBKYjlzv5uprslhLlKE5TPWeWkrSrLwO08=;
        b=aszPrJ2tWxWHZapeGA8AYjx2qGTRQziicUp8CmGG7Qp+54nwJxkE2yH8s4TD9eLTUJ
         H/wRBsbflFvO0nRXzK0ZIEJOb7vNyqdtJ18FmLBQO8axQW4qHyfzmbMfSoOBiLdtkc7i
         J4ZyrsHuc2c73N4u3oUhcspX/axS09sgPD/QpMZy48+RfHB3oJPYe1ZGGAsD3jkL2tPY
         eqkAZxtN+h6pBPb9Vjzq7yAuJMled3Y9FZIbnYumCdV8qjm9DGnSuc4DKPTOu7weMP2U
         MWx8AV7fOx1WCL2R8X9Y2/jB6UHfDmLwK58rSKUc5A3iUhC2WMCMOwMsJ3AULWoRQtHE
         943Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=fLM4n8WI6nBKYjlzv5uprslhLlKE5TPWeWkrSrLwO08=;
        b=ilI4R6AXWLCPZfNGbYnsWqnNbU3ZRsG8+kPkpRuU0VGLWA11UXbEGoKNUajotClb14
         I0DX0NK8cgvukxzuhWopWvaIrn3r9ZQYqOgNlcPoZSUdlnETrMt8wvjwm3YLk/YPCsmt
         gtIBHohqmB1DZfUJMrcfDEFH9AUtLuNiqre5XOAkU7DoeS8nj7HdvOlqLZJ9z8w1PxY3
         eB3XkJfi/TpE25SmZs4oIN6QCrR3mLzIf2dSjdKtsq47Sd317/wdJreRWam6P2zVh3ti
         SYEH62M5KFigvpZwAC67ZCeib3pX7W3WglyXJ6IJI27EHgwf9ZVcnoNWfvQoyvk3HBWi
         o58A==
X-Gm-Message-State: APjAAAX7S/O5MEXHQGglG1jmachuEDqxIhqigj5zj3n/vXFXxvjyt07N
	JfoGVun7Y2/LBeDthIlEVjqsDLWYP/srq7pbTA==
X-Google-Smtp-Source: APXvYqz8UkwjV9XfOFsV5NW86oxIsr5ArI24hFNz5KsCsRreiOOxGnQMOfXbgKHuDPGJArpX4kC+vvEQBe0w60wsaA==
X-Received: by 2002:a63:67c6:: with SMTP id b189mr30789935pgc.163.1568158315499;
 Tue, 10 Sep 2019 16:31:55 -0700 (PDT)
Date: Tue, 10 Sep 2019 16:31:39 -0700
In-Reply-To: <20190910233146.206080-1-almasrymina@google.com>
Message-Id: <20190910233146.206080-3-almasrymina@google.com>
Mime-Version: 1.0
References: <20190910233146.206080-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v4 2/9] hugetlb_cgroup: add interface for charge/uncharge
 hugetlb reservations
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Augements hugetlb_cgroup_charge_cgroup to be able to charge hugetlb
usage or hugetlb reservation counter.

Adds a new interface to uncharge a hugetlb_cgroup counter via
hugetlb_cgroup_uncharge_counter.

Integrates the counter with hugetlb_cgroup, via hugetlb_cgroup_init,
hugetlb_cgroup_have_usage, and hugetlb_cgroup_css_offline.

Signed-off-by: Mina Almasry <almasrymina@google.com>
---
 include/linux/hugetlb_cgroup.h | 13 ++++--
 mm/hugetlb.c                   |  6 ++-
 mm/hugetlb_cgroup.c            | 82 +++++++++++++++++++++++++++-------
 3 files changed, 80 insertions(+), 21 deletions(-)

diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 063962f6dfc6a..c467715dd8fb8 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -52,14 +52,19 @@ static inline bool hugetlb_cgroup_disabled(void)
 }

 extern int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-					struct hugetlb_cgroup **ptr);
+					struct hugetlb_cgroup **ptr,
+					bool reserved);
 extern void hugetlb_cgroup_commit_charge(int idx, unsigned long nr_pages,
 					 struct hugetlb_cgroup *h_cg,
 					 struct page *page);
 extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 					 struct page *page);
 extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
-					   struct hugetlb_cgroup *h_cg);
+					   struct hugetlb_cgroup *h_cg,
+					   bool reserved);
+extern void hugetlb_cgroup_uncharge_counter(struct page_counter *p,
+					    unsigned long nr_pages);
+
 extern void hugetlb_cgroup_file_init(void) __init;
 extern void hugetlb_cgroup_migrate(struct page *oldhpage,
 				   struct page *newhpage);
@@ -83,7 +88,7 @@ static inline bool hugetlb_cgroup_disabled(void)

 static inline int
 hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-			     struct hugetlb_cgroup **ptr)
+			     struct hugetlb_cgroup **ptr, bool reserved)
 {
 	return 0;
 }
@@ -102,7 +107,7 @@ hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages, struct page *page)

 static inline void
 hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
-			       struct hugetlb_cgroup *h_cg)
+			       struct hugetlb_cgroup *h_cg, bool reserved)
 {
 }

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296dd11b83..e975f55aede94 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2078,7 +2078,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 			gbl_chg = 1;
 	}

-	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
+	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg,
+					   false);
 	if (ret)
 		goto out_subpool_put;

@@ -2126,7 +2127,8 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return page;

 out_uncharge_cgroup:
-	hugetlb_cgroup_uncharge_cgroup(idx, pages_per_huge_page(h), h_cg);
+	hugetlb_cgroup_uncharge_cgroup(idx, pages_per_huge_page(h), h_cg,
+			false);
 out_subpool_put:
 	if (map_chg || avoid_reserve)
 		hugepage_subpool_put_pages(spool, 1);
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 51a72624bd1ff..2ab36a98d834e 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -38,8 +38,8 @@ struct hugetlb_cgroup {
 static struct hugetlb_cgroup *root_h_cgroup __read_mostly;

 static inline
-struct page_counter *hugetlb_cgroup_get_counter(struct hugetlb_cgroup *h_cg, int idx,
-				 bool reserved)
+struct page_counter *hugetlb_cgroup_get_counter(struct hugetlb_cgroup *h_cg,
+						int idx, bool reserved)
 {
 	if (reserved)
 		return  &h_cg->reserved_hugepage[idx];
@@ -74,8 +74,12 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 	int idx;

 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
-		if (page_counter_read(&h_cg->hugepage[idx]))
+		if (page_counter_read(hugetlb_cgroup_get_counter(h_cg, idx,
+						true)) ||
+		    page_counter_read(hugetlb_cgroup_get_counter(h_cg, idx,
+				    false))) {
 			return true;
+		}
 	}
 	return false;
 }
@@ -86,18 +90,30 @@ static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
 	int idx;

 	for (idx = 0; idx < HUGE_MAX_HSTATE; idx++) {
-		struct page_counter *counter = &h_cgroup->hugepage[idx];
 		struct page_counter *parent = NULL;
+		struct page_counter *reserved_parent = NULL;
 		unsigned long limit;
 		int ret;

-		if (parent_h_cgroup)
-			parent = &parent_h_cgroup->hugepage[idx];
-		page_counter_init(counter, parent);
+		if (parent_h_cgroup) {
+			parent = hugetlb_cgroup_get_counter(
+					parent_h_cgroup, idx, false);
+			reserved_parent = hugetlb_cgroup_get_counter(
+					parent_h_cgroup, idx, true);
+		}
+		page_counter_init(hugetlb_cgroup_get_counter(
+					h_cgroup, idx, false), parent);
+		page_counter_init(hugetlb_cgroup_get_counter(
+					h_cgroup, idx, true),
+				  reserved_parent);

 		limit = round_down(PAGE_COUNTER_MAX,
 				   1 << huge_page_order(&hstates[idx]));
-		ret = page_counter_set_max(counter, limit);
+
+		ret = page_counter_set_max(hugetlb_cgroup_get_counter(
+					h_cgroup, idx, false), limit);
+		ret = page_counter_set_max(hugetlb_cgroup_get_counter(
+					h_cgroup, idx, true), limit);
 		VM_BUG_ON(ret);
 	}
 }
@@ -127,6 +143,26 @@ static void hugetlb_cgroup_css_free(struct cgroup_subsys_state *css)
 	kfree(h_cgroup);
 }

+static void hugetlb_cgroup_move_parent_reservation(int idx,
+						   struct hugetlb_cgroup *h_cg)
+{
+	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(h_cg);
+
+	/* Move the reservation counters. */
+	if (!parent_hugetlb_cgroup(h_cg)) {
+		parent = root_h_cgroup;
+		/* root has no limit */
+		page_counter_charge(
+				&root_h_cgroup->reserved_hugepage[idx],
+				page_counter_read(hugetlb_cgroup_get_counter(
+						h_cg, idx, true)));
+	}
+
+	/* Take the pages off the local counter */
+	page_counter_cancel(hugetlb_cgroup_get_counter(h_cg, idx, true),
+			    page_counter_read(hugetlb_cgroup_get_counter(h_cg,
+					    idx, true)));
+}

 /*
  * Should be called with hugetlb_lock held.
@@ -181,6 +217,7 @@ static void hugetlb_cgroup_css_offline(struct cgroup_subsys_state *css)
 	do {
 		for_each_hstate(h) {
 			spin_lock(&hugetlb_lock);
+			hugetlb_cgroup_move_parent_reservation(idx, h_cg);
 			list_for_each_entry(page, &h->hugepage_activelist, lru)
 				hugetlb_cgroup_move_parent(idx, h_cg, page);

@@ -192,7 +229,7 @@ static void hugetlb_cgroup_css_offline(struct cgroup_subsys_state *css)
 }

 int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
-				 struct hugetlb_cgroup **ptr)
+				 struct hugetlb_cgroup **ptr, bool reserved)
 {
 	int ret = 0;
 	struct page_counter *counter;
@@ -215,8 +252,11 @@ int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
 	}
 	rcu_read_unlock();

-	if (!page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter))
+	if (!page_counter_try_charge(hugetlb_cgroup_get_counter(h_cg, idx,
+								reserved),
+				     nr_pages, &counter)) {
 		ret = -ENOMEM;
+	}
 	css_put(&h_cg->css);
 done:
 	*ptr = h_cg;
@@ -250,12 +290,14 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 	if (unlikely(!h_cg))
 		return;
 	set_hugetlb_cgroup(page, NULL);
-	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
+	page_counter_uncharge(hugetlb_cgroup_get_counter(h_cg, idx, false),
+			nr_pages);
+
 	return;
 }

 void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
-				    struct hugetlb_cgroup *h_cg)
+				    struct hugetlb_cgroup *h_cg, bool reserved)
 {
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
@@ -263,8 +305,17 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
 		return;

-	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
-	return;
+	page_counter_uncharge(hugetlb_cgroup_get_counter(h_cg, idx, reserved),
+			nr_pages);
+}
+
+void hugetlb_cgroup_uncharge_counter(struct page_counter *p,
+				     unsigned long nr_pages)
+{
+	if (hugetlb_cgroup_disabled() || !p)
+		return;
+
+	page_counter_uncharge(p, nr_pages);
 }

 static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
@@ -326,7 +377,8 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		/* Fall through. */
 	case HUGETLB_RES_LIMIT:
 		mutex_lock(&hugetlb_limit_mutex);
-		ret = page_counter_set_max(hugetlb_cgroup_get_counter(h_cg, idx, reserved),
+		ret = page_counter_set_max(hugetlb_cgroup_get_counter(h_cg, idx,
+								      reserved),
 					   nr_pages);
 		mutex_unlock(&hugetlb_limit_mutex);
 		break;
--
2.23.0.162.g0b9fbb3734-goog

