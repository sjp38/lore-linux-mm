Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B347EC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 460F820645
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FMP/aTB/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 460F820645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DED38E0006; Fri, 15 Feb 2019 17:03:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F00828E0001; Fri, 15 Feb 2019 17:03:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2DCE8E0006; Fri, 15 Feb 2019 17:03:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC238E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:03:52 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id r8so6911925ywh.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:03:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=yulhGIpWhQu+UjEN/kQgEyDI0008fvOEzH9bvf/BwbU=;
        b=mkXvNBhdvBzMKiK7aVPFCAhYIEQOo/r2c54HrKu1cTBs72vvBvV62MfljjoCVOZe0L
         1uXrB8Df4ciiO32uAgk1s9RvbUI1RIJqy77oun/RwHkvUqsFPvcnJqi+4vSdPvcSRezS
         uPCoFN33n4pz+0P6XE01sbBTtROqkars1In7yNONSeIGIgsXvGV4uDrj6NjBh6a94Cwz
         RCUvdp2pepMgxlPpHUO29AOzRx8tPHpjm5wtonlUjhizyiONH3EAsbq5SutOl2Jd6HK2
         r6aY22i1J7C3JOQi7hMz+CFio+5vFPArVHbHa1JGXrP0RtWUFO3LR7O1tBqoHd55Qp7X
         ImSQ==
X-Gm-Message-State: AHQUAuakrf6VVpc+AvSSTNJRmIdqLHtYDJ7C3gdKoa0iZrkDqOIkZ09p
	7SRhUgB+3NG1htW5zmoQYViZKpyVnm/ZGiQrV+XOUWj8g14L6IRZpwYIbdFNdd0srf6y1UmCb5x
	FjZIvWVhXGLyoV1VNcnURazqtf8V0ija9xYAgv5sy/Xxa8W0xmaC69658An2zjmC29Q==
X-Received: by 2002:a5b:4b:: with SMTP id e11mr9846403ybp.5.1550268232214;
        Fri, 15 Feb 2019 14:03:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZP26JW4RGk9235qfYKLcp3TRxqwxrXElpFhSslvhGA6YvSMACyjjcrmZYf+4S1ReneNnqQ
X-Received: by 2002:a5b:4b:: with SMTP id e11mr9846228ybp.5.1550268229766;
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268229; cv=none;
        d=google.com; s=arc-20160816;
        b=EHJJGbxrEATKu6saDXA9NkdhGQAZsRphq1HfZU2wnGvZFsmINtS0DaF04k9ArhA0vl
         xN2g9Mc6tv8S1WacBnDh/t5OYgOqeLQEy41eH2DiTfje0XOCqDMF5oCkDK0Ido3ufGSw
         8vSInV+moFMMLQuoKilgjXubv4exfnOdrE3Mp9ipyFWxClSYlJoaC7MORw+IM0aCmDDp
         jiLWQHRGp8OyvHmtcKmAetmh8/K8njnwYXPpvDMhg5B6EJ2zqiBLh1l0fIHQv14/pkJc
         ex+Twv3KHoH2/61bBjl9Sdl+RMSRfOhsKKU8SRWBzkxEqUP/rJp83hNJ09SiAnVjHP/u
         cQ0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=yulhGIpWhQu+UjEN/kQgEyDI0008fvOEzH9bvf/BwbU=;
        b=yxZ/lwYAebY4MA7vgllOWevSq3/wdOTBIuMG3gph8dV3YjuXcv1bgapUR3v6Dyj2NH
         tASgmVuqcWNAvdfM56M2xh4ONLV7MaREAjqvfssieNsEx8nKCLvtgPeeZX8SRx9lRWny
         eW1sknbXLZPYQkGu6+ylihuFjQBqjK5fBQjMtx8xiuzuWxv3Stfll2+wz+PFTjTI6Y5j
         rwaRLmiaXdMBqWHkcqvGnkyMwjtS7hKWpD7QeteT7cLEROsJrZ71qWGJjWQMZoh8/U2N
         tNIxAFHIJrwJ/NPCfSttuTxbN+LE5/9qln4mwDQ4TMDBTb3+h3bDGk3SIPnqX2EKALwU
         KVlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="FMP/aTB/";
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z3si4064440ybh.391.2019.02.15.14.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="FMP/aTB/";
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6737200000>; Fri, 15 Feb 2019 14:03:12 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 14:03:48 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 15 Feb 2019 14:03:48 -0800
Received: from nvrsysarch5.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 22:03:48 +0000
From: Zi Yan <ziy@nvidia.com>
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
	<mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>, Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two lists of pages.
Date: Fri, 15 Feb 2019 14:03:04 -0800
Message-ID: <20190215220334.29298-2-ziy@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220334.29298-1-ziy@nvidia.com>
References: <20190215220334.29298-1-ziy@nvidia.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550268192; bh=yulhGIpWhQu+UjEN/kQgEyDI0008fvOEzH9bvf/BwbU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Transfer-Encoding:Content-Type;
	b=FMP/aTB/6mLMQsbJpZs8dD1k6EWPJaV8/TWLaKipisw7+8IkiGlpYgrdL5Lyz7Tnj
	 PQUmwkYryIu9SY076OhXQt53cwYO84vt0NFWyPxA53DDofCIb4HvVa0+udsniEwla0
	 b7isGOSBlhLYMe3jwLec0lw53S41IVICyRpWtvUWOREJGvGNCkobOWDDn9ymvpHrA8
	 V3EfkaqraE5dNrfokgI32TXohkCl0kiTh+k1KtR1XiZisFCD9T4jgpdGDvpD2HIVpp
	 fjXS7chFb4gL49sz4DthC2ma2M5q33NA4SJnRjixZPji/WL3NRv/tj711Mmfu4+j8c
	 PKnzMaaMYZhbw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In stead of using two migrate_pages(), a single exchange_pages() would
be sufficient and without allocating new pages.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/ksm.h |   5 +
 mm/Makefile         |   1 +
 mm/exchange.c       | 846 ++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h       |   6 +
 mm/ksm.c            |  35 ++
 mm/migrate.c        |   4 +-
 6 files changed, 895 insertions(+), 2 deletions(-)
 create mode 100644 mm/exchange.c

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 161e8164abcf..87c5b943a73c 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -53,6 +53,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
=20
 void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
+void ksm_exchange_page(struct page *to_page, struct page *from_page);
=20
 #else  /* !CONFIG_KSM */
=20
@@ -86,6 +87,10 @@ static inline void rmap_walk_ksm(struct page *page,
 static inline void ksm_migrate_page(struct page *newpage, struct page *old=
page)
 {
 }
+static inline void ksm_exchange_page(struct page *to_page,
+				struct page *from_page)
+{
+}
 #endif /* CONFIG_MMU */
 #endif /* !CONFIG_KSM */
=20
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..1574ea5743e4 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,6 +43,7 @@ obj-y			:=3D filemap.o mempool.o oom_kill.o fadvise.o \
=20
 obj-y +=3D init-mm.o
 obj-y +=3D memblock.o
+obj-y +=3D exchange.o
=20
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+=3D madvise.o
diff --git a/mm/exchange.c b/mm/exchange.c
new file mode 100644
index 000000000000..a607348cc6f4
--- /dev/null
+++ b/mm/exchange.c
@@ -0,0 +1,846 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (C) 2016 NVIDIA, Zi Yan <ziy@nvidia.com>
+ *
+ * Exchange two in-use pages. Page flags and page->mapping are exchanged
+ * as well. Only anonymous pages are supported.
+ */
+
+#include <linux/syscalls.h>
+#include <linux/migrate.h>
+#include <linux/security.h>
+#include <linux/cpuset.h>
+#include <linux/hugetlb.h>
+#include <linux/mm_inline.h>
+#include <linux/page_idle.h>
+#include <linux/page-flags.h>
+#include <linux/ksm.h>
+#include <linux/memcontrol.h>
+#include <linux/balloon_compaction.h>
+#include <linux/buffer_head.h>
+#include <linux/fs.h> /* buffer_migrate_page  */
+#include <linux/backing-dev.h>
+
+
+#include "internal.h"
+
+struct exchange_page_info {
+	struct page *from_page;
+	struct page *to_page;
+
+	struct anon_vma *from_anon_vma;
+	struct anon_vma *to_anon_vma;
+
+	struct list_head list;
+};
+
+struct page_flags {
+	unsigned int page_error :1;
+	unsigned int page_referenced:1;
+	unsigned int page_uptodate:1;
+	unsigned int page_active:1;
+	unsigned int page_unevictable:1;
+	unsigned int page_checked:1;
+	unsigned int page_mappedtodisk:1;
+	unsigned int page_dirty:1;
+	unsigned int page_is_young:1;
+	unsigned int page_is_idle:1;
+	unsigned int page_swapcache:1;
+	unsigned int page_writeback:1;
+	unsigned int page_private:1;
+	unsigned int __pad:3;
+};
+
+
+static void exchange_page(char *to, char *from)
+{
+	u64 tmp;
+	int i;
+
+	for (i =3D 0; i < PAGE_SIZE; i +=3D sizeof(tmp)) {
+		tmp =3D *((u64 *)(from + i));
+		*((u64 *)(from + i)) =3D *((u64 *)(to + i));
+		*((u64 *)(to + i)) =3D tmp;
+	}
+}
+
+static inline void exchange_highpage(struct page *to, struct page *from)
+{
+	char *vfrom, *vto;
+
+	vfrom =3D kmap_atomic(from);
+	vto =3D kmap_atomic(to);
+	exchange_page(vto, vfrom);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
+}
+
+static void __exchange_gigantic_page(struct page *dst, struct page *src,
+				int nr_pages)
+{
+	int i;
+	struct page *dst_base =3D dst;
+	struct page *src_base =3D src;
+
+	for (i =3D 0; i < nr_pages; ) {
+		cond_resched();
+		exchange_highpage(dst, src);
+
+		i++;
+		dst =3D mem_map_next(dst, dst_base, i);
+		src =3D mem_map_next(src, src_base, i);
+	}
+}
+
+static void exchange_huge_page(struct page *dst, struct page *src)
+{
+	int i;
+	int nr_pages;
+
+	if (PageHuge(src)) {
+		/* hugetlbfs page */
+		struct hstate *h =3D page_hstate(src);
+
+		nr_pages =3D pages_per_huge_page(h);
+
+		if (unlikely(nr_pages > MAX_ORDER_NR_PAGES)) {
+			__exchange_gigantic_page(dst, src, nr_pages);
+			return;
+		}
+	} else {
+		/* thp page */
+		VM_BUG_ON(!PageTransHuge(src));
+		nr_pages =3D hpage_nr_pages(src);
+	}
+
+	for (i =3D 0; i < nr_pages; i++) {
+		cond_resched();
+		exchange_highpage(dst + i, src + i);
+	}
+}
+
+/*
+ * Copy the page to its new location without polluting cache
+ */
+static void exchange_page_flags(struct page *to_page, struct page *from_pa=
ge)
+{
+	int from_cpupid, to_cpupid;
+	struct page_flags from_page_flags, to_page_flags;
+	struct mem_cgroup *to_memcg =3D page_memcg(to_page),
+					  *from_memcg =3D page_memcg(from_page);
+
+	from_cpupid =3D page_cpupid_xchg_last(from_page, -1);
+
+	from_page_flags.page_error =3D TestClearPageError(from_page);
+	from_page_flags.page_referenced =3D TestClearPageReferenced(from_page);
+	from_page_flags.page_uptodate =3D PageUptodate(from_page);
+	ClearPageUptodate(from_page);
+	from_page_flags.page_active =3D TestClearPageActive(from_page);
+	from_page_flags.page_unevictable =3D TestClearPageUnevictable(from_page);
+	from_page_flags.page_checked =3D PageChecked(from_page);
+	ClearPageChecked(from_page);
+	from_page_flags.page_mappedtodisk =3D PageMappedToDisk(from_page);
+	ClearPageMappedToDisk(from_page);
+	from_page_flags.page_dirty =3D PageDirty(from_page);
+	ClearPageDirty(from_page);
+	from_page_flags.page_is_young =3D test_and_clear_page_young(from_page);
+	from_page_flags.page_is_idle =3D page_is_idle(from_page);
+	clear_page_idle(from_page);
+	from_page_flags.page_swapcache =3D PageSwapCache(from_page);
+	from_page_flags.page_writeback =3D test_clear_page_writeback(from_page);
+
+
+	to_cpupid =3D page_cpupid_xchg_last(to_page, -1);
+
+	to_page_flags.page_error =3D TestClearPageError(to_page);
+	to_page_flags.page_referenced =3D TestClearPageReferenced(to_page);
+	to_page_flags.page_uptodate =3D PageUptodate(to_page);
+	ClearPageUptodate(to_page);
+	to_page_flags.page_active =3D TestClearPageActive(to_page);
+	to_page_flags.page_unevictable =3D TestClearPageUnevictable(to_page);
+	to_page_flags.page_checked =3D PageChecked(to_page);
+	ClearPageChecked(to_page);
+	to_page_flags.page_mappedtodisk =3D PageMappedToDisk(to_page);
+	ClearPageMappedToDisk(to_page);
+	to_page_flags.page_dirty =3D PageDirty(to_page);
+	ClearPageDirty(to_page);
+	to_page_flags.page_is_young =3D test_and_clear_page_young(to_page);
+	to_page_flags.page_is_idle =3D page_is_idle(to_page);
+	clear_page_idle(to_page);
+	to_page_flags.page_swapcache =3D PageSwapCache(to_page);
+	to_page_flags.page_writeback =3D test_clear_page_writeback(to_page);
+
+	/* set to_page */
+	if (from_page_flags.page_error)
+		SetPageError(to_page);
+	if (from_page_flags.page_referenced)
+		SetPageReferenced(to_page);
+	if (from_page_flags.page_uptodate)
+		SetPageUptodate(to_page);
+	if (from_page_flags.page_active) {
+		VM_BUG_ON_PAGE(from_page_flags.page_unevictable, from_page);
+		SetPageActive(to_page);
+	} else if (from_page_flags.page_unevictable)
+		SetPageUnevictable(to_page);
+	if (from_page_flags.page_checked)
+		SetPageChecked(to_page);
+	if (from_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(to_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (from_page_flags.page_dirty)
+		SetPageDirty(to_page);
+
+	if (from_page_flags.page_is_young)
+		set_page_young(to_page);
+	if (from_page_flags.page_is_idle)
+		set_page_idle(to_page);
+
+	/* set from_page */
+	if (to_page_flags.page_error)
+		SetPageError(from_page);
+	if (to_page_flags.page_referenced)
+		SetPageReferenced(from_page);
+	if (to_page_flags.page_uptodate)
+		SetPageUptodate(from_page);
+	if (to_page_flags.page_active) {
+		VM_BUG_ON_PAGE(to_page_flags.page_unevictable, from_page);
+		SetPageActive(from_page);
+	} else if (to_page_flags.page_unevictable)
+		SetPageUnevictable(from_page);
+	if (to_page_flags.page_checked)
+		SetPageChecked(from_page);
+	if (to_page_flags.page_mappedtodisk)
+		SetPageMappedToDisk(from_page);
+
+	/* Move dirty on pages not done by migrate_page_move_mapping() */
+	if (to_page_flags.page_dirty)
+		SetPageDirty(from_page);
+
+	if (to_page_flags.page_is_young)
+		set_page_young(from_page);
+	if (to_page_flags.page_is_idle)
+		set_page_idle(from_page);
+
+	/*
+	 * Copy NUMA information to the new page, to prevent over-eager
+	 * future migrations of this same page.
+	 */
+	page_cpupid_xchg_last(to_page, from_cpupid);
+	page_cpupid_xchg_last(from_page, to_cpupid);
+
+	ksm_exchange_page(to_page, from_page);
+	/*
+	 * Please do not reorder this without considering how mm/ksm.c's
+	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
+	 */
+	ClearPageSwapCache(to_page);
+	ClearPageSwapCache(from_page);
+	if (from_page_flags.page_swapcache)
+		SetPageSwapCache(to_page);
+	if (to_page_flags.page_swapcache)
+		SetPageSwapCache(from_page);
+
+
+#ifdef CONFIG_PAGE_OWNER
+	/* exchange page owner  */
+	BUILD_BUG();
+#endif
+	/* exchange mem cgroup  */
+	to_page->mem_cgroup =3D from_memcg;
+	from_page->mem_cgroup =3D to_memcg;
+
+}
+
+/*
+ * Replace the page in the mapping.
+ *
+ * The number of remaining references must be:
+ * 1 for anonymous pages without a mapping
+ * 2 for pages with a mapping
+ * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
+ */
+
+static int exchange_page_move_mapping(struct address_space *to_mapping,
+			struct address_space *from_mapping,
+			struct page *to_page, struct page *from_page,
+			struct buffer_head *to_head,
+			struct buffer_head *from_head,
+			enum migrate_mode mode,
+			int to_extra_count, int from_extra_count)
+{
+	int to_expected_count =3D 1 + to_extra_count,
+		from_expected_count =3D 1 + from_extra_count;
+	unsigned long from_page_index =3D from_page->index;
+	unsigned long to_page_index =3D to_page->index;
+	int to_swapbacked =3D PageSwapBacked(to_page),
+		from_swapbacked =3D PageSwapBacked(from_page);
+	struct address_space *to_mapping_value =3D to_page->mapping;
+	struct address_space *from_mapping_value =3D from_page->mapping;
+
+	VM_BUG_ON_PAGE(to_mapping !=3D page_mapping(to_page), to_page);
+	VM_BUG_ON_PAGE(from_mapping !=3D page_mapping(from_page), from_page);
+
+	if (!to_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(to_page) !=3D to_expected_count)
+			return -EAGAIN;
+	}
+
+	if (!from_mapping) {
+		/* Anonymous page without mapping */
+		if (page_count(from_page) !=3D from_expected_count)
+			return -EAGAIN;
+	}
+
+	/* both are anonymous pages  */
+	if (!from_mapping && !to_mapping) {
+		/* from_page  */
+		from_page->index =3D to_page_index;
+		from_page->mapping =3D to_mapping_value;
+
+		ClearPageSwapBacked(from_page);
+		if (to_swapbacked)
+			SetPageSwapBacked(from_page);
+
+
+		/* to_page  */
+		to_page->index =3D from_page_index;
+		to_page->mapping =3D from_mapping_value;
+
+		ClearPageSwapBacked(to_page);
+		if (from_swapbacked)
+			SetPageSwapBacked(to_page);
+	} else if (!from_mapping && to_mapping) {
+		/* from is anonymous, to is file-backed  */
+		struct zone *from_zone, *to_zone;
+		void **to_pslot;
+		int dirty;
+
+		from_zone =3D page_zone(from_page);
+		to_zone =3D page_zone(to_page);
+
+		xa_lock_irq(&to_mapping->i_pages);
+
+		to_pslot =3D radix_tree_lookup_slot(&to_mapping->i_pages,
+			page_index(to_page));
+
+		to_expected_count +=3D 1 + page_has_private(to_page);
+		if (page_count(to_page) !=3D to_expected_count ||
+			radix_tree_deref_slot_protected(to_pslot,
+				&to_mapping->i_pages.xa_lock) !=3D to_page) {
+			xa_unlock_irq(&to_mapping->i_pages);
+			return -EAGAIN;
+		}
+
+		if (!page_ref_freeze(to_page, to_expected_count)) {
+			xa_unlock_irq(&to_mapping->i_pages);
+			pr_debug("cannot freeze page count\n");
+			return -EAGAIN;
+		}
+
+		if (mode =3D=3D MIGRATE_ASYNC && to_head &&
+				!buffer_migrate_lock_buffers(to_head, mode)) {
+			page_ref_unfreeze(to_page, to_expected_count);
+			xa_unlock_irq(&to_mapping->i_pages);
+
+			pr_debug("cannot lock buffer head\n");
+			return -EAGAIN;
+		}
+
+		if (!page_ref_freeze(from_page, from_expected_count)) {
+			page_ref_unfreeze(to_page, to_expected_count);
+			xa_unlock_irq(&to_mapping->i_pages);
+
+			return -EAGAIN;
+		}
+		/*
+		 * Now we know that no one else is looking at the page:
+		 * no turning back from here.
+		 */
+		ClearPageSwapBacked(from_page);
+		ClearPageSwapBacked(to_page);
+
+		/* from_page  */
+		from_page->index =3D to_page_index;
+		from_page->mapping =3D to_mapping_value;
+		/* to_page  */
+		to_page->index =3D from_page_index;
+		to_page->mapping =3D from_mapping_value;
+
+		if (to_swapbacked)
+			__SetPageSwapBacked(from_page);
+		else
+			VM_BUG_ON_PAGE(PageSwapCache(to_page), to_page);
+
+		if (from_swapbacked)
+			__SetPageSwapBacked(to_page);
+		else
+			VM_BUG_ON_PAGE(PageSwapCache(from_page), from_page);
+
+		dirty =3D PageDirty(to_page);
+
+		radix_tree_replace_slot(&to_mapping->i_pages,
+				to_pslot, from_page);
+
+		/* move cache reference */
+		page_ref_unfreeze(to_page, to_expected_count - 1);
+		page_ref_unfreeze(from_page, from_expected_count + 1);
+
+		xa_unlock(&to_mapping->i_pages);
+
+		/*
+		 * If moved to a different zone then also account
+		 * the page for that zone. Other VM counters will be
+		 * taken care of when we establish references to the
+		 * new page and drop references to the old page.
+		 *
+		 * Note that anonymous pages are accounted for
+		 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
+		 * are mapped to swap space.
+		 */
+		if (to_zone !=3D from_zone) {
+			__dec_node_state(to_zone->zone_pgdat, NR_FILE_PAGES);
+			__inc_node_state(from_zone->zone_pgdat, NR_FILE_PAGES);
+			if (PageSwapBacked(to_page) && !PageSwapCache(to_page)) {
+				__dec_node_state(to_zone->zone_pgdat, NR_SHMEM);
+				__inc_node_state(from_zone->zone_pgdat, NR_SHMEM);
+			}
+			if (dirty && mapping_cap_account_dirty(to_mapping)) {
+				__dec_node_state(to_zone->zone_pgdat, NR_FILE_DIRTY);
+				__dec_zone_state(to_zone, NR_ZONE_WRITE_PENDING);
+				__inc_node_state(from_zone->zone_pgdat, NR_FILE_DIRTY);
+				__inc_zone_state(from_zone, NR_ZONE_WRITE_PENDING);
+			}
+		}
+		local_irq_enable();
+
+	} else {
+		/* from is file-backed to is anonymous: fold this to the case above */
+		/* both are file-backed  */
+		VM_BUG_ON(1);
+	}
+
+	return MIGRATEPAGE_SUCCESS;
+}
+
+static int exchange_from_to_pages(struct page *to_page, struct page *from_=
page,
+				enum migrate_mode mode)
+{
+	int rc =3D -EBUSY;
+	struct address_space *to_page_mapping, *from_page_mapping;
+	struct buffer_head *to_head =3D NULL, *to_bh =3D NULL;
+
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+
+	/* copy page->mapping not use page_mapping()  */
+	to_page_mapping =3D page_mapping(to_page);
+	from_page_mapping =3D page_mapping(from_page);
+
+	/* from_page has to be anonymous page  */
+	VM_BUG_ON(from_page_mapping);
+	VM_BUG_ON(PageWriteback(from_page));
+	/* writeback has to finish */
+	BUG_ON(PageWriteback(to_page));
+
+
+	/* to_page is anonymous  */
+	if (!to_page_mapping) {
+exchange_mappings:
+		/* actual page mapping exchange */
+		rc =3D exchange_page_move_mapping(to_page_mapping, from_page_mapping,
+					to_page, from_page, NULL, NULL, mode, 0, 0);
+	} else {
+		if (to_page_mapping->a_ops->migratepage =3D=3D buffer_migrate_page) {
+
+			if (!page_has_buffers(to_page))
+				goto exchange_mappings;
+
+			to_head =3D page_buffers(to_page);
+
+			rc =3D exchange_page_move_mapping(to_page_mapping,
+					from_page_mapping, to_page, from_page,
+					to_head, NULL, mode, 0, 0);
+
+			if (rc !=3D MIGRATEPAGE_SUCCESS)
+				return rc;
+
+			/*
+			 * In the async case, migrate_page_move_mapping locked the buffers
+			 * with an IRQ-safe spinlock held. In the sync case, the buffers
+			 * need to be locked now
+			 */
+			if (mode !=3D MIGRATE_ASYNC)
+				VM_BUG_ON(!buffer_migrate_lock_buffers(to_head, mode));
+
+			ClearPagePrivate(to_page);
+			set_page_private(from_page, page_private(to_page));
+			set_page_private(to_page, 0);
+			/* transfer private page count  */
+			put_page(to_page);
+			get_page(from_page);
+
+			to_bh =3D to_head;
+			do {
+				set_bh_page(to_bh, from_page, bh_offset(to_bh));
+				to_bh =3D to_bh->b_this_page;
+
+			} while (to_bh !=3D to_head);
+
+			SetPagePrivate(from_page);
+
+			to_bh =3D to_head;
+		} else if (!to_page_mapping->a_ops->migratepage) {
+			/* fallback_migrate_page  */
+			if (PageDirty(to_page)) {
+				if (mode !=3D MIGRATE_SYNC)
+					return -EBUSY;
+				return writeout(to_page_mapping, to_page);
+			}
+			if (page_has_private(to_page) &&
+				!try_to_release_page(to_page, GFP_KERNEL))
+				return -EAGAIN;
+
+			goto exchange_mappings;
+		}
+	}
+	/* actual page data exchange  */
+	if (rc !=3D MIGRATEPAGE_SUCCESS)
+		return rc;
+
+
+	if (PageHuge(from_page) || PageTransHuge(from_page))
+		exchange_huge_page(to_page, from_page);
+	else
+		exchange_highpage(to_page, from_page);
+	rc =3D 0;
+
+	/*
+	 * 1. buffer_migrate_page:
+	 *   private flag should be transferred from to_page to from_page
+	 *
+	 * 2. anon<->anon, fallback_migrate_page:
+	 *   both have none private flags or to_page's is cleared.
+	 */
+	VM_BUG_ON(!((page_has_private(from_page) && !page_has_private(to_page)) |=
|
+				(!page_has_private(from_page) && !page_has_private(to_page))));
+
+	exchange_page_flags(to_page, from_page);
+
+	if (to_bh) {
+		VM_BUG_ON(to_bh !=3D to_head);
+		do {
+			unlock_buffer(to_bh);
+			put_bh(to_bh);
+			to_bh =3D to_bh->b_this_page;
+
+		} while (to_bh !=3D to_head);
+	}
+
+	return rc;
+}
+
+static int unmap_and_exchange(struct page *from_page,
+		struct page *to_page, enum migrate_mode mode)
+{
+	int rc =3D -EAGAIN;
+	struct anon_vma *from_anon_vma =3D NULL;
+	struct anon_vma *to_anon_vma =3D NULL;
+	int from_page_was_mapped =3D 0;
+	int to_page_was_mapped =3D 0;
+	int from_page_count =3D 0, to_page_count =3D 0;
+	int from_map_count =3D 0, to_map_count =3D 0;
+	unsigned long from_flags, to_flags;
+	pgoff_t from_index, to_index;
+	struct address_space *from_mapping, *to_mapping;
+
+	if (!trylock_page(from_page)) {
+		if (mode =3D=3D MIGRATE_ASYNC)
+			goto out;
+		lock_page(from_page);
+	}
+
+	if (!trylock_page(to_page)) {
+		if (mode =3D=3D MIGRATE_ASYNC)
+			goto out_unlock;
+		lock_page(to_page);
+	}
+
+	/* from_page is supposed to be an anonymous page */
+	VM_BUG_ON_PAGE(PageWriteback(from_page), from_page);
+
+	if (PageWriteback(to_page)) {
+		/*
+		 * Only in the case of a full synchronous migration is it
+		 * necessary to wait for PageWriteback. In the async case,
+		 * the retry loop is too short and in the sync-light case,
+		 * the overhead of stalling is too much
+		 */
+		if (mode !=3D MIGRATE_SYNC) {
+			rc =3D -EBUSY;
+			goto out_unlock_both;
+		}
+		wait_on_page_writeback(to_page);
+	}
+
+	if (PageAnon(from_page) && !PageKsm(from_page))
+		from_anon_vma =3D page_get_anon_vma(from_page);
+
+	if (PageAnon(to_page) && !PageKsm(to_page))
+		to_anon_vma =3D page_get_anon_vma(to_page);
+
+	from_page_count =3D page_count(from_page);
+	from_map_count =3D page_mapcount(from_page);
+	to_page_count =3D page_count(to_page);
+	to_map_count =3D page_mapcount(to_page);
+	from_flags =3D from_page->flags;
+	to_flags =3D to_page->flags;
+	from_mapping =3D from_page->mapping;
+	to_mapping =3D to_page->mapping;
+	from_index =3D from_page->index;
+	to_index =3D to_page->index;
+
+	/*
+	 * Corner case handling:
+	 * 1. When a new swap-cache page is read into, it is added to the LRU
+	 * and treated as swapcache but it has no rmap yet.
+	 * Calling try_to_unmap() against a page->mapping=3D=3DNULL page will
+	 * trigger a BUG.  So handle it here.
+	 * 2. An orphaned page (see truncate_complete_page) might have
+	 * fs-private metadata. The page can be picked up due to memory
+	 * offlining.  Everywhere else except page reclaim, the page is
+	 * invisible to the vm, so the page can not be migrated.  So try to
+	 * free the metadata, so the page can be freed.
+	 */
+	if (!from_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(from_page), from_page);
+		if (page_has_private(from_page)) {
+			try_to_free_buffers(from_page);
+			goto out_unlock_both;
+		}
+	} else if (page_mapped(from_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(from_page) && !PageKsm(from_page) &&
+					   !from_anon_vma, from_page);
+		try_to_unmap(from_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		from_page_was_mapped =3D 1;
+	}
+
+	if (!to_page->mapping) {
+		VM_BUG_ON_PAGE(PageAnon(to_page), to_page);
+		if (page_has_private(to_page)) {
+			try_to_free_buffers(to_page);
+			goto out_unlock_both_remove_from_migration_pte;
+		}
+	} else if (page_mapped(to_page)) {
+		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(to_page) && !PageKsm(to_page) &&
+						!to_anon_vma, to_page);
+		try_to_unmap(to_page,
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+		to_page_was_mapped =3D 1;
+	}
+
+	if (!page_mapped(from_page) && !page_mapped(to_page))
+		rc =3D exchange_from_to_pages(to_page, from_page, mode);
+
+
+	if (to_page_was_mapped) {
+		/* swap back to_page->index to be compatible with
+		 * remove_migration_ptes(), which assumes both from_page and to_page
+		 * below have the same index.
+		 */
+		if (rc =3D=3D MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+
+		remove_migration_ptes(to_page,
+			rc =3D=3D MIGRATEPAGE_SUCCESS ? from_page : to_page, false);
+
+		if (rc =3D=3D MIGRATEPAGE_SUCCESS)
+			swap(to_page->index, to_index);
+	}
+
+out_unlock_both_remove_from_migration_pte:
+	if (from_page_was_mapped) {
+		/* swap back from_page->index to be compatible with
+		 * remove_migration_ptes(), which assumes both from_page and to_page
+		 * below have the same index.
+		 */
+		if (rc =3D=3D MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+
+		remove_migration_ptes(from_page,
+			rc =3D=3D MIGRATEPAGE_SUCCESS ? to_page : from_page, false);
+
+		if (rc =3D=3D MIGRATEPAGE_SUCCESS)
+			swap(from_page->index, from_index);
+	}
+
+out_unlock_both:
+	if (to_anon_vma)
+		put_anon_vma(to_anon_vma);
+	unlock_page(to_page);
+out_unlock:
+	/* Drop an anon_vma reference if we took one */
+	if (from_anon_vma)
+		put_anon_vma(from_anon_vma);
+	unlock_page(from_page);
+out:
+	return rc;
+}
+
+/*
+ * Exchange pages in the exchange_list
+ *
+ * Caller should release the exchange_list resource.
+ *
+ */
+static int exchange_pages(struct list_head *exchange_list,
+			enum migrate_mode mode,
+			int reason)
+{
+	struct exchange_page_info *one_pair, *one_pair2;
+	int failed =3D 0;
+
+	list_for_each_entry_safe(one_pair, one_pair2, exchange_list, list) {
+		struct page *from_page =3D one_pair->from_page;
+		struct page *to_page =3D one_pair->to_page;
+		int rc;
+		int retry =3D 0;
+
+again:
+		if (page_count(from_page) =3D=3D 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(from_page);
+			ClearPageUnevictable(from_page);
+
+			mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page),
+					-hpage_nr_pages(from_page));
+			put_page(from_page);
+
+			if (page_count(to_page) =3D=3D 1) {
+				ClearPageActive(to_page);
+				ClearPageUnevictable(to_page);
+				put_page(to_page);
+				mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+						page_is_file_cache(to_page),
+						-hpage_nr_pages(to_page));
+			} else
+				goto putback_to_page;
+
+			continue;
+		}
+
+		if (page_count(to_page) =3D=3D 1) {
+			/* page was freed from under us. So we are done  */
+			ClearPageActive(to_page);
+			ClearPageUnevictable(to_page);
+
+			mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+					page_is_file_cache(to_page),
+					-hpage_nr_pages(to_page));
+			put_page(to_page);
+
+			mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+					page_is_file_cache(from_page),
+					-hpage_nr_pages(from_page));
+			putback_lru_page(from_page);
+			continue;
+		}
+
+		/* TODO: compound page not supported */
+		/* to_page can be file-backed page  */
+		if (PageCompound(from_page) ||
+			page_mapping(from_page)
+			) {
+			++failed;
+			goto putback;
+		}
+
+		rc =3D unmap_and_exchange(from_page, to_page, mode);
+
+		if (rc =3D=3D -EAGAIN && retry < 3) {
+			++retry;
+			goto again;
+		}
+
+		if (rc !=3D MIGRATEPAGE_SUCCESS)
+			++failed;
+
+putback:
+		mod_node_page_state(page_pgdat(from_page), NR_ISOLATED_ANON +
+				page_is_file_cache(from_page),
+				-hpage_nr_pages(from_page));
+
+		putback_lru_page(from_page);
+putback_to_page:
+		mod_node_page_state(page_pgdat(to_page), NR_ISOLATED_ANON +
+				page_is_file_cache(to_page),
+				-hpage_nr_pages(to_page));
+
+		putback_lru_page(to_page);
+	}
+	return failed;
+}
+
+int exchange_two_pages(struct page *page1, struct page *page2)
+{
+	struct exchange_page_info page_info;
+	LIST_HEAD(exchange_list);
+	int err =3D -EFAULT;
+	int pagevec_flushed =3D 0;
+
+	VM_BUG_ON_PAGE(PageTail(page1), page1);
+	VM_BUG_ON_PAGE(PageTail(page2), page2);
+
+	if (!(PageLRU(page1) && PageLRU(page2)))
+		return -EBUSY;
+
+retry_isolate1:
+	if (!get_page_unless_zero(page1))
+		return -EBUSY;
+	err =3D isolate_lru_page(page1);
+	put_page(page1);
+	if (err) {
+		if (!pagevec_flushed) {
+			migrate_prep();
+			pagevec_flushed =3D 1;
+			goto retry_isolate1;
+		}
+		return err;
+	}
+	mod_node_page_state(page_pgdat(page1),
+			NR_ISOLATED_ANON + page_is_file_cache(page1),
+			hpage_nr_pages(page1));
+
+retry_isolate2:
+	if (!get_page_unless_zero(page2)) {
+		putback_lru_page(page1);
+		return -EBUSY;
+	}
+	err =3D isolate_lru_page(page2);
+	put_page(page2);
+	if (err) {
+		if (!pagevec_flushed) {
+			migrate_prep();
+			pagevec_flushed =3D 1;
+			goto retry_isolate2;
+		}
+		return err;
+	}
+	mod_node_page_state(page_pgdat(page2),
+			NR_ISOLATED_ANON + page_is_file_cache(page2),
+			hpage_nr_pages(page2));
+
+	page_info.from_page =3D page1;
+	page_info.to_page =3D page2;
+	INIT_LIST_HEAD(&page_info.list);
+	list_add(&page_info.list, &exchange_list);
+
+
+	return exchange_pages(&exchange_list, MIGRATE_SYNC, 0);
+
+}
diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb02decf..77e205c423ce 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -543,4 +543,10 @@ static inline bool is_migrate_highatomic_page(struct p=
age *page)
=20
 void setup_zone_pageset(struct zone *zone);
 extern struct page *alloc_new_node_page(struct page *page, unsigned long n=
ode);
+
+bool buffer_migrate_lock_buffers(struct buffer_head *head,
+							enum migrate_mode mode);
+int writeout(struct address_space *mapping, struct page *page);
+extern int exchange_two_pages(struct page *page1, struct page *page2);
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index 6c48ad13b4c9..dc1ec06b71a0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2665,6 +2665,41 @@ void ksm_migrate_page(struct page *newpage, struct p=
age *oldpage)
 		set_page_stable_node(oldpage, NULL);
 	}
 }
+
+void ksm_exchange_page(struct page *to_page, struct page *from_page)
+{
+	struct stable_node *to_stable_node, *from_stable_node;
+
+	VM_BUG_ON_PAGE(!PageLocked(to_page), to_page);
+	VM_BUG_ON_PAGE(!PageLocked(from_page), from_page);
+
+	to_stable_node =3D page_stable_node(to_page);
+	from_stable_node =3D page_stable_node(from_page);
+	if (to_stable_node) {
+		VM_BUG_ON_PAGE(to_stable_node->kpfn !=3D page_to_pfn(from_page),
+					from_page);
+		to_stable_node->kpfn =3D page_to_pfn(to_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+	if (from_stable_node) {
+		VM_BUG_ON_PAGE(from_stable_node->kpfn !=3D page_to_pfn(to_page),
+					to_page);
+		from_stable_node->kpfn =3D page_to_pfn(from_page);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+	}
+}
 #endif /* CONFIG_MIGRATION */
=20
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..b8c79aa62134 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -701,7 +701,7 @@ EXPORT_SYMBOL(migrate_page);
=20
 #ifdef CONFIG_BLOCK
 /* Returns true if all buffers are successfully locked */
-static bool buffer_migrate_lock_buffers(struct buffer_head *head,
+bool buffer_migrate_lock_buffers(struct buffer_head *head,
 							enum migrate_mode mode)
 {
 	struct buffer_head *bh =3D head;
@@ -849,7 +849,7 @@ int buffer_migrate_page_norefs(struct address_space *ma=
pping,
 /*
  * Writeback a page to clean the dirty state
  */
-static int writeout(struct address_space *mapping, struct page *page)
+int writeout(struct address_space *mapping, struct page *page)
 {
 	struct writeback_control wbc =3D {
 		.sync_mode =3D WB_SYNC_NONE,
--=20
2.20.1

