Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF280C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2555222CC
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5c4qlL79"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2555222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5CF8E000A; Wed, 13 Feb 2019 19:02:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3917E8E0005; Wed, 13 Feb 2019 19:02:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231548E000A; Wed, 13 Feb 2019 19:02:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D41DC8E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:54 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so2892852pgq.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=MZqi6ournax3KQmG8JyBwhw5kF/1WOYT8qIrSyRL3+o=;
        b=hAxY21JeJ9n5xrmvqR5m2MVWxkb3GgM82X5C35G/s5WXVPmTnA2XK25F7y+UPlZLZm
         Lv8TRHJ05YWvCn6qBipVWWEPift5Ual0d+KgBuBLXseCw2w//lYINl7tDuOWfr3EY+vL
         1ZCkbBpavNa1gZpiWfDiFfhoDArexQogXS1eYO83iXw8VG+VZl9ptMny642B/Waa2jZL
         Xp/4nsF1J0yAcdVeB/LqfcBZCfUlxLcSHCD3/XhCHSjneOLgvnXctEZsZw7/7KtB/hbW
         Prt5JdqLWjj7cqgwKjqAEZed0ugZkpC/XqBmtiZPZ36wf9mL5s0e8tyAoqND8Td+7DFJ
         2V+Q==
X-Gm-Message-State: AHQUAubisjRO2ip1ItF3B/cJW3upWou4cr7MqkUJVk8ghj3s0cVP/Yz5
	W76T8t1Ucp987LUh7HwSuODv5R2g0++lOcbYgO9MnwaH1P/AZNnoRygm477q0kaDO6dO9mpOLf+
	vkI/zAwxQGcolflOU0YkAJyGLU6BoMED5HkcQLwsn1KCQZuCjHnHvjSOJNIXte/Z3Rg==
X-Received: by 2002:a63:4913:: with SMTP id w19mr830786pga.394.1550102574460;
        Wed, 13 Feb 2019 16:02:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZumfSNdSEuP6jo3DsbeF8AjN2J5keDEGTGt/0vvQU5ZzM0meawRRDmvL6BU6L54rHitR7O
X-Received: by 2002:a63:4913:: with SMTP id w19mr830729pga.394.1550102573757;
        Wed, 13 Feb 2019 16:02:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102573; cv=none;
        d=google.com; s=arc-20160816;
        b=UZd/ufIeJrD8qVtbMhvEVgsdnkJBLzYnWhyryzCzRoKNMHgqGNnBc3jx/lqHpsoe5R
         AGgVEJ31baoWvTOZY9frdYueWhzsYD3x1oz8oJYyK+rkDLcMce++7Gx2Ogznr/dIlLii
         QcRgGza4stlbeo/57t534no/EYd2LpqfUBjh2q3nvJ3DWrAqN+DMaaHkPAPbBtgFt6+D
         Sc9nxHbPmU8N2B9T0FNgbV0UZPO4FmYytpL5m8TXXL16aVAtrjCipJaMlf+KaHCZBZC2
         i/7uXE67wsk5NXcrpC7yU96TF1H/eyxsveUHXQeNXqUwwtPfQuR2lhC3K0Jf3xxIuZKd
         8MBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=MZqi6ournax3KQmG8JyBwhw5kF/1WOYT8qIrSyRL3+o=;
        b=OJDiabx/7mpQIfqeOAKe4u1m+rYgzTWK5x6bHE0KTwmCIRwWx+RfV8JbDH1lV3p34y
         1WE+LBtq3T/zKd753cqQCbasvuT91JTZHXy76lCCqqyf06KAFrLhI+8t0EvrbGsEo5Jv
         E7d8gQBij2vPKWzLoFxYt3s/upf4jIwnRvHnBnwm1ZCFMzSWMaBDAFzw6R3P2kpb7Z57
         Yxv2EiJbIYlhdCsRgVZG8M18DKQoNVm8ZtB35Eoxoi5KcK4qZf0GDBZK4I3T68edG1qw
         RRd/A6E8KUVWu/0PzyxtUg3RG2UlJGnMhzbNjRlzIHMTvMBXHPpQBw7qLPDWr2z6yF2R
         QdiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5c4qlL79;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c6si720708plo.270.2019.02.13.16.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:53 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5c4qlL79;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwfsg100210;
	Thu, 14 Feb 2019 00:02:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=MZqi6ournax3KQmG8JyBwhw5kF/1WOYT8qIrSyRL3+o=;
 b=5c4qlL7951pylpPk/LYjHCqBaQh+OE07SNEncySbv9VpXjItDk191jRy8R2qAS/Si7wk
 5azy3SAjL1y5ZU+ayiqvpGeYyYPej1QFoowA8i7hY6LnuqWwGRdVeXP9R8NT7EnzXbG6
 VmTdJcDS8tsN+qApiiulm6FgWZxe8R1C9yy4gLDgnBMg2ET8uYg5u30QJc9jnecDxXLZ
 Ws9u2vhvaPb5ONbVL/qJNVAlo/vUy0Ks8iSwt4n7n8NmKRBZtbPL12yeMBe53Z6nM1Be
 It7bqaU0WEZ+yaRGwGM5y3xEn/ALsicHwZUxBoSgDXDN78jBld75C6noZszpY4wmUtbI 7A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3uq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:10 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E024xT025641
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:04 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1E024Xu018660;
	Thu, 14 Feb 2019 00:02:04 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:04 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho@docker.com>
Subject: [RFC PATCH v8 04/14] swiotlb: Map the buffer if it was unmapped by XPFO
Date: Wed, 13 Feb 2019 17:01:27 -0700
Message-Id: <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=845 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

v6: * guard against lookup_xpfo() returning NULL

CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/xpfo.h |  4 ++++
 kernel/dma/swiotlb.c |  3 ++-
 mm/xpfo.c            | 15 +++++++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index b15234745fb4..cba37ffb09b1 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -36,6 +36,8 @@ void xpfo_kunmap(void *kaddr, struct page *page);
 void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
 void xpfo_free_pages(struct page *page, int order);
 
+bool xpfo_page_is_unmapped(struct page *page);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -43,6 +45,8 @@ static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
 static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
 static inline void xpfo_free_pages(struct page *page, int order) { }
 
+static inline bool xpfo_page_is_unmapped(struct page *page) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 045930e32c0e..820a54b57491 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
 {
 	unsigned long pfn = PFN_DOWN(orig_addr);
 	unsigned char *vaddr = phys_to_virt(tlb_addr);
+	struct page *page = pfn_to_page(pfn);
 
-	if (PageHighMem(pfn_to_page(pfn))) {
+	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
 		/* The buffer does not have a mapping.  Map it in and copy */
 		unsigned int offset = orig_addr & ~PAGE_MASK;
 		char *buffer;
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 24b33d3c20cb..67884736bebe 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -221,3 +221,18 @@ void xpfo_kunmap(void *kaddr, struct page *page)
 	spin_unlock(&xpfo->maplock);
 }
 EXPORT_SYMBOL(xpfo_kunmap);
+
+bool xpfo_page_is_unmapped(struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+
+	xpfo = lookup_xpfo(page);
+	if (unlikely(!xpfo) && !xpfo->inited)
+		return false;
+
+	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+}
+EXPORT_SYMBOL(xpfo_page_is_unmapped);
-- 
2.17.1

