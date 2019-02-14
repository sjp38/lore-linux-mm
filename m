Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84BF4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:04:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 278C0218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:04:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xwYy2aXo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 278C0218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8F068E0003; Wed, 13 Feb 2019 19:04:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3F1C8E0001; Wed, 13 Feb 2019 19:04:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB8E48E0003; Wed, 13 Feb 2019 19:04:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5669C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:04:50 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so2912853plt.7
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:04:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=TYTmjWk1Ud9xFO4O2CDjqPHQ3NzvMn4w1OlUR3qol7g=;
        b=cxzt8Z1MPCjQkgz/p7NNoNJroLuK804G8lKxHe7xnVDKbQ41s3OKbI3GoR4m9xMnTX
         FRV0sssBabu63dq9jLvnAHecqys+BI6SHB5A7adjf13PpNcNJ1GktBk21bdVVm6oNMht
         ruYP6dOdku46ZO1Ap/nqXw02Am/LocoZHAzpUUZSpGj0EVZuzK2Iz9tgj5Gt2Dx0VgXL
         ts8nlMWvketSQFfmF3lnWRL34J0VDU0PJzBjsF53lHcALumR9VfO0G7yTRnJWcft9Gbr
         GyO5/tcAiKdXMHuvIlxTF1O54BhPv2S2xJlNGGz0RFyfBwHOysl9ZiHduaU14VggsfcH
         xKag==
X-Gm-Message-State: AHQUAua4WP2CH5xfSnQ2rqo7tMhkXMVw/M//MzZsaWp227lLUCg8HOJX
	oqgYUwIM+3DaP0ZiWgFQEMoOsofbltFV1VizedLw0CYHfLvVGqN2rA3G1dkrD7Ybns01dTBmMNJ
	bM4q60HOryexhTFRR/g5FflBNJ7b5fpQUDIhK9dVbL+FxufjlNnGnYx3JYVPh/u3kBA==
X-Received: by 2002:a62:1f5c:: with SMTP id f89mr876698pff.137.1550102689953;
        Wed, 13 Feb 2019 16:04:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IatOIMwZKvTV/0gIgw1/4fTn+yaqRyXOc/p6SUSo4/gcg2JdB5HmL9SpB8clQ8IvXgdH1x2
X-Received: by 2002:a62:1f5c:: with SMTP id f89mr876604pff.137.1550102689015;
        Wed, 13 Feb 2019 16:04:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102689; cv=none;
        d=google.com; s=arc-20160816;
        b=iLvAwNXpaUApFp/pQcV98O86sTD2mTce5mAeT9ccbH6MEV3S6TOC61pU0eiNTa8Q0Z
         Rx/CxwYe7Clx6ZO/ueFtkWrN9WcBDPslnW9M6TmtM+W4ekZL/lvVJl1pmR3O1+oDHfSh
         Qal1cBbvVW/exl8nSjepUPBrgHnWK/zxvHOz0WIg+rmTQsUo7WUfU8Ml8F1FLIqCF9X8
         G+W9ThLHQk1wT7Bl2Ut0iRdGmX1CCzALc7BYXRkS8BNnttm+S+Qsms3R23l1MKLR1tKx
         CLcTzQiIb3HMyHTj7L2mkZFQOrhCGZXsieu73gEMi3suTD1wJZxI27AhGz1RjnOWRACD
         9/yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=TYTmjWk1Ud9xFO4O2CDjqPHQ3NzvMn4w1OlUR3qol7g=;
        b=ygkNdolWzwSvcGU52AF5BHHeMxDjTzKGEb/BYLPMa/okj4R1liyYFy/oFpkm2FwhQr
         iGox9thM9fsuLXoXQj78kravvIBmFAfevduD0N17MqZQDDuwKwIpNO5AOSoloE18yzTS
         8IRF7wFgYQUO6cYfL/qW2GV1hgDjtbA9llfp5KD6kDmRdQrbClAcS4Mev+/e0V53hJ6n
         +eLrZtSWdBhNOinzDayWaJyGObGQpWHQ2kGegFkjD+DiZyoDLotNKmKN2mLTp4WbNhca
         T9ERsop2zqQIADedcVXzsSZBJGOnifgiDbxF7WzaA7iU7RQ238e9ZiClUB07vBo92hZ9
         ZslA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xwYy2aXo;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o11si708738pls.374.2019.02.13.16.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:04:49 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xwYy2aXo;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwjFp099399;
	Thu, 14 Feb 2019 00:02:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=TYTmjWk1Ud9xFO4O2CDjqPHQ3NzvMn4w1OlUR3qol7g=;
 b=xwYy2aXo7t5xJC9+w32YfLL7cjgc3iIpBAE0V7wYjGFAQ06Se7GHUmGKKd3a8t4ViTPM
 hgsMfdwTc6d6rvLVimRpcx4hxWiqZKD+nUkx1x33WRzAvkWQYxjujKv9YZ4u+vG2ZrRK
 TTxa/WMoUVhUwZz7hR+pi68WsOnVaDmCXKCF/3R5yqBQTLOj2LJn4XmBTIh74W10CKhs
 UxA1QSEodqXxzu7zAkdK1fGxw33J2M/yvMyFF+CSQBOMgasBZ7a33Dqq6g4Aspx/2pF5
 Rsiuq3kqdpq0p0SsA48rdZvbLBUg/DgjD6G/t8Bot0UQ0KJBENA5cO5yi+dmHCm/oK5p 4g== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qhree55nk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:29 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02Nfp026321
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:23 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E02Mau018822;
	Thu, 14 Feb 2019 00:02:22 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:21 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        Tycho Andersen <tycho@docker.com>,
        Marco Benatto <marco.antonio.780@gmail.com>,
        David Woodhouse <dwmw2@infradead.org>
Subject: [RFC PATCH v8 11/14] xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION
Date: Wed, 13 Feb 2019 17:01:34 -0700
Message-Id: <465161d96733a9bda8dfbae9d2028912ee383faa.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Julian Stecklina <jsteckli@amazon.de>

Instead of using the page extension debug feature, encode all
information, we need for XPFO in struct page. This allows to get rid of
some checks in the hot paths and there are also no pages anymore that
are allocated before XPFO is enabled.

Also make debugging aids configurable for maximum performance.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 include/linux/mm_types.h       |   8 ++
 include/linux/page-flags.h     |  13 +++
 include/linux/xpfo.h           |   3 +-
 include/trace/events/mmflags.h |  10 ++-
 mm/page_alloc.c                |   3 +-
 mm/page_ext.c                  |   4 -
 mm/xpfo.c                      | 159 ++++++++-------------------------
 security/Kconfig               |  12 ++-
 8 files changed, 80 insertions(+), 132 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..d17d33f36a01 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -204,6 +204,14 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
+
+#ifdef CONFIG_XPFO
+	/* Counts the number of times this page has been kmapped. */
+	atomic_t xpfo_mapcount;
+
+	/* Serialize kmap/kunmap of this page */
+	spinlock_t xpfo_lock;
+#endif
 } _struct_page_alignment;
 
 /*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 50ce1bddaf56..a532063f27b5 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -101,6 +101,10 @@ enum pageflags {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
+#endif
+#ifdef CONFIG_XPFO
+	PG_xpfo_user,		/* Page is allocated to user-space */
+	PG_xpfo_unmapped,	/* Page is unmapped from the linear map */
 #endif
 	__NR_PAGEFLAGS,
 
@@ -398,6 +402,15 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_XPFO
+PAGEFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTCLEARFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTSETFLAG(XpfoUser, xpfo_user, PF_ANY)
+PAGEFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTCLEARFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTSETFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 117869991d5b..1dd590ff1a1f 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -28,7 +28,7 @@ struct page;
 
 #include <linux/types.h>
 
-extern struct page_ext_operations page_xpfo_ops;
+void xpfo_init_single_page(struct page *page);
 
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
 void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
@@ -57,6 +57,7 @@ phys_addr_t user_virt_to_phys(unsigned long addr);
 
 #else /* !CONFIG_XPFO */
 
+static inline void xpfo_init_single_page(struct page *page) { }
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
 static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
 static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..6bb000bb366f 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_XPFO
+#define IF_HAVE_PG_XPFO(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_XPFO(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -105,7 +111,9 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_XPFO(PG_xpfo_user,		"xpfo_user"	)		\
+IF_HAVE_PG_XPFO(PG_xpfo_unmapped,	"xpfo_unmapped" ) 		\
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 08e277790b5f..d00382b20001 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1024,6 +1024,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	if (bad)
 		return false;
 
+	xpfo_free_pages(page, order);
 	page_cpupid_reset_last(page);
 	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	reset_page_owner(page, order);
@@ -1038,7 +1039,6 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_pages(page, order);
-	xpfo_free_pages(page, order);
 
 	return true;
 }
@@ -1191,6 +1191,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	if (!is_highmem_idx(zone))
 		set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
+	xpfo_init_single_page(page);
 }
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 38e5013dcb9a..ae44f7adbe07 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -8,7 +8,6 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
-#include <linux/xpfo.h>
 
 /*
  * struct page extension
@@ -69,9 +68,6 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
-#ifdef CONFIG_XPFO
-	&page_xpfo_ops,
-#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 150784ae0f08..dc03c423c52f 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -17,113 +17,58 @@
 #include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/module.h>
-#include <linux/page_ext.h>
 #include <linux/xpfo.h>
 
 #include <asm/tlbflush.h>
 
-/* XPFO page state flags */
-enum xpfo_flags {
-	XPFO_PAGE_USER,		/* Page is allocated to user-space */
-	XPFO_PAGE_UNMAPPED,	/* Page is unmapped from the linear map */
-};
-
-/* Per-page XPFO house-keeping data */
-struct xpfo {
-	unsigned long flags;	/* Page state */
-	bool inited;		/* Map counter and lock initialized */
-	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
-	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
-};
-
-DEFINE_STATIC_KEY_FALSE(xpfo_inited);
-
-static bool xpfo_disabled __initdata;
+DEFINE_STATIC_KEY_TRUE(xpfo_inited);
 
 static int __init noxpfo_param(char *str)
 {
-	xpfo_disabled = true;
+	static_branch_disable(&xpfo_inited);
 
 	return 0;
 }
 
 early_param("noxpfo", noxpfo_param);
 
-static bool __init need_xpfo(void)
-{
-	if (xpfo_disabled) {
-		pr_info("XPFO disabled\n");
-		return false;
-	}
-
-	return true;
-}
-
-static void init_xpfo(void)
-{
-	pr_info("XPFO enabled\n");
-	static_branch_enable(&xpfo_inited);
-}
-
-struct page_ext_operations page_xpfo_ops = {
-	.size = sizeof(struct xpfo),
-	.need = need_xpfo,
-	.init = init_xpfo,
-};
-
 bool __init xpfo_enabled(void)
 {
-	return !xpfo_disabled;
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+	else
+		return true;
 }
-EXPORT_SYMBOL(xpfo_enabled);
 
-static inline struct xpfo *lookup_xpfo(struct page *page)
+void __meminit xpfo_init_single_page(struct page *page)
 {
-	struct page_ext *page_ext = lookup_page_ext(page);
-
-	if (unlikely(!page_ext)) {
-		WARN(1, "xpfo: failed to get page ext");
-		return NULL;
-	}
-
-	return (void *)page_ext + page_xpfo_ops.offset;
+	spin_lock_init(&page->xpfo_lock);
 }
 
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 {
 	int i, flush_tlb = 0;
-	struct xpfo *xpfo;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
 	for (i = 0; i < (1 << order); i++)  {
-		xpfo = lookup_xpfo(page + i);
-		if (!xpfo)
-			continue;
-
-		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
-		     "xpfo: unmapped page being allocated\n");
-
-		/* Initialize the map lock and map counter */
-		if (unlikely(!xpfo->inited)) {
-			spin_lock_init(&xpfo->maplock);
-			atomic_set(&xpfo->mapcount, 0);
-			xpfo->inited = true;
-		}
-		WARN(atomic_read(&xpfo->mapcount),
-		     "xpfo: already mapped page being allocated\n");
-
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(PageXpfoUser(page + i));
+		BUG_ON(PageXpfoUnmapped(page + i));
+		BUG_ON(spin_is_locked(&(page + i)->xpfo_lock));
+		BUG_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
 		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
 			/*
 			 * Tag the page as a user page and flush the TLB if it
 			 * was previously allocated to the kernel.
 			 */
-			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
+			if (!TestSetPageXpfoUser(page + i))
 				flush_tlb = 1;
 		} else {
 			/* Tag the page as a non-user (kernel) page */
-			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
+			ClearPageXpfoUser(page + i);
 		}
 	}
 
@@ -134,27 +79,21 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 void xpfo_free_pages(struct page *page, int order)
 {
 	int i;
-	struct xpfo *xpfo;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
 	for (i = 0; i < (1 << order); i++) {
-		xpfo = lookup_xpfo(page + i);
-		if (!xpfo || unlikely(!xpfo->inited)) {
-			/*
-			 * The page was allocated before page_ext was
-			 * initialized, so it is a kernel page.
-			 */
-			continue;
-		}
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(atomic_read(&(page + i)->xpfo_mapcount));
+#endif
 
 		/*
 		 * Map the page back into the kernel if it was previously
 		 * allocated to user space.
 		 */
-		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
-			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+		if (TestClearPageXpfoUser(page + i)) {
+			ClearPageXpfoUnmapped(page + i);
 			set_kpte(page_address(page + i), page + i,
 				 PAGE_KERNEL);
 		}
@@ -163,84 +102,56 @@ void xpfo_free_pages(struct page *page, int order)
 
 void xpfo_kmap(void *kaddr, struct page *page)
 {
-	struct xpfo *xpfo;
-
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
-	xpfo = lookup_xpfo(page);
-
-	/*
-	 * The page was allocated before page_ext was initialized (which means
-	 * it's a kernel page) or it's allocated to the kernel, so nothing to
-	 * do.
-	 */
-	if (!xpfo || unlikely(!xpfo->inited) ||
-	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&xpfo->maplock);
+	spin_lock(&page->xpfo_lock);
 
 	/*
 	 * The page was previously allocated to user space, so map it back
 	 * into the kernel. No TLB flush required.
 	 */
-	if ((atomic_inc_return(&xpfo->mapcount) == 1) &&
-	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
+	    TestClearPageXpfoUnmapped(page))
 		set_kpte(kaddr, page, PAGE_KERNEL);
 
-	spin_unlock(&xpfo->maplock);
+	spin_unlock(&page->xpfo_lock);
 }
 EXPORT_SYMBOL(xpfo_kmap);
 
 void xpfo_kunmap(void *kaddr, struct page *page)
 {
-	struct xpfo *xpfo;
-
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
 
-	xpfo = lookup_xpfo(page);
-
-	/*
-	 * The page was allocated before page_ext was initialized (which means
-	 * it's a kernel page) or it's allocated to the kernel, so nothing to
-	 * do.
-	 */
-	if (!xpfo || unlikely(!xpfo->inited) ||
-	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&xpfo->maplock);
+	spin_lock(&page->xpfo_lock);
 
 	/*
 	 * The page is to be allocated back to user space, so unmap it from the
 	 * kernel, flush the TLB and tag it as a user page.
 	 */
-	if (atomic_dec_return(&xpfo->mapcount) == 0) {
-		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
-		     "xpfo: unmapping already unmapped page\n");
-		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+	if (atomic_dec_return(&page->xpfo_mapcount) == 0) {
+#ifdef CONFIG_XPFO_DEBUG
+		BUG_ON(PageXpfoUnmapped(page));
+#endif
+		SetPageXpfoUnmapped(page);
 		set_kpte(kaddr, page, __pgprot(0));
 		xpfo_flush_kernel_tlb(page, 0);
 	}
 
-	spin_unlock(&xpfo->maplock);
+	spin_unlock(&page->xpfo_lock);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
 
 bool xpfo_page_is_unmapped(struct page *page)
 {
-	struct xpfo *xpfo;
-
-	if (!static_branch_unlikely(&xpfo_inited))
-		return false;
-
-	xpfo = lookup_xpfo(page);
-	if (unlikely(!xpfo) && !xpfo->inited)
-		return false;
-
-	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+	return PageXpfoUnmapped(page);
 }
 EXPORT_SYMBOL(xpfo_page_is_unmapped);
 
diff --git a/security/Kconfig b/security/Kconfig
index 8d0e4e303551..c7c581bac963 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -13,7 +13,6 @@ config XPFO
 	bool "Enable eXclusive Page Frame Ownership (XPFO)"
 	default n
 	depends on ARCH_SUPPORTS_XPFO
-	select PAGE_EXTENSION
 	help
 	  This option offers protection against 'ret2dir' kernel attacks.
 	  When enabled, every time a page frame is allocated to user space, it
@@ -25,6 +24,17 @@ config XPFO
 
 	  If in doubt, say "N".
 
+config XPFO_DEBUG
+       bool "Enable debugging of XPFO"
+       default n
+       depends on XPFO
+       help
+         Enables additional checking of XPFO data structures that help find
+	 bugs in the XPFO implementation. This option comes with a slight
+	 performance cost.
+
+	 If in doubt, say "N".
+
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
 	default n
-- 
2.17.1

