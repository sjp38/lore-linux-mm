Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DC9EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1D9A218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:02:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uIx25zRg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1D9A218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 712F28E0006; Wed, 13 Feb 2019 19:02:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C3958E0005; Wed, 13 Feb 2019 19:02:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1758E0006; Wed, 13 Feb 2019 19:02:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F22B88E0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:02:40 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q21so3205466pfi.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:02:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=B56xy1SykMvAYC6aqGnZB/bYPtFwWukcKOnvet3ifEU=;
        b=IqlchLeQxjj46gyvabWOVYKeSEnLm5QKzPDOzZjrRUufBDItDToinG5+/bD44kjSEr
         WEOvFFgDQkYwBeiFCJATzQYyNpwTYx0R0cKvV4zMpBBR+hCJETKdOjfPQDG/RNpMtfYB
         sUjIS1QEIVDmjuxTMoeMZPiHIwKAwWmbtLPHgXObCzs8wjkyXX7VYwdJPIxb/j59mxE7
         etaBTETVtfc+qD740vnF2qL9bXcBxzRKw4C6kdHhD+9mI8SYfGi1lBnIq21MJVxZrZy5
         QDhzz9mDBeArHdmr/qlYaQMd+cWhDRlwuoQp24gF/6lmYJxOT8LWquraZFmknIwULARL
         B7cQ==
X-Gm-Message-State: AHQUAuYSUpeqAFJJI7YxRV9uk5nUvSqnJ/MOwhVDY0Fhl+O+IZWTBtMP
	AOOF+FdfXZHJpmKSCq7N26yhpzCyjCX/LNlSDZZs7Huv3I06tRNt5vo6HGPZad8P9KJT9el7Ez1
	o/Ofx2sF03T9T2jT2ReBwtHnubpCgEOHg7oNvjMswsk/6+MHlRahEnnVinWbkHpOH4Q==
X-Received: by 2002:a63:1143:: with SMTP id 3mr782675pgr.447.1550102560629;
        Wed, 13 Feb 2019 16:02:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaNigTvT93gwUe4QoSXqTSoyaZFKQwgL6tXJ8BWi+EHZSnmf0RC8bChkTpKmD21E7OHPGd1
X-Received: by 2002:a63:1143:: with SMTP id 3mr782599pgr.447.1550102559801;
        Wed, 13 Feb 2019 16:02:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102559; cv=none;
        d=google.com; s=arc-20160816;
        b=zaaAAds8vajyB/dwTMLB4EANOpNEvxxpr60Q27pavYiDQ3pbbAOv3VCwWAEOH8ffl/
         kP1beHis6yedTLUFtZOlAkJCDqJZWe0I9dbdP09GxGS+64/7gszFdP9zuYFrllS0UylO
         YeTpfS5Ia/Zww9LkHYlbwkGjVvw3OO+zcqVpNN8NVWp1Bm9CAq0eBq4502c297h7Vn16
         PSfswTwqnyFBa4V6QFFz7PUqjY3UuSbTMBYaeY0GDfmCSGAFvr5OsQvqs4okfovhBgaq
         1BJ53Xm6G7Nh2SdzVaUwwKb1/u3pP0vUT0+2tyz6yQihWE2dCPrM29WauJOi0S3TIGoL
         0LTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=B56xy1SykMvAYC6aqGnZB/bYPtFwWukcKOnvet3ifEU=;
        b=jG0JdoLrjKd8Hdop9RSyf2JVPUXY5Z2CfB84Aizionj1Ktqolc9Kx3HErIFBemhyxT
         QzFcNb6IGjYaTh2Y58UxGU7vWyq+ADo3hsxRuXZt5x0/Jz7hdJbzg9RjUCCeChyu6tOC
         839CpaHmJOHAVunYRVj58xECGr4kSJz55x8yYR3W/OZ9ecUmpH45eQOZTVt2e4XwD+jA
         tRQU2prvJe18j2Yfo3oV/V7spNIAg9k34uJ/pKGgH1Pgl9t9F+8R1sKZbUS12gi1vPa+
         F/+/zBhj6mfpguCW6RTxLFuWeqJGV9DTjrniDkloQY8+DSpLhR8raoK1pKg3w7WCutEO
         eD4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uIx25zRg;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y12si716810pga.216.2019.02.13.16.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:02:39 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uIx25zRg;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DNwgkD100217;
	Thu, 14 Feb 2019 00:02:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : in-reply-to :
 references; s=corp-2018-07-02;
 bh=B56xy1SykMvAYC6aqGnZB/bYPtFwWukcKOnvet3ifEU=;
 b=uIx25zRg4V1mI7KE5rlBz/NOl4jvjuexvGmPkyZvqcfrmno71cCT5E+9JbWTSHC/QKat
 mwHwGgsn3lyUx7sgJV9UNpCRjTU6py7eGgk7lKgOpsDhpFjeerfPM2DbaBuKJ9UZcAKz
 DsSL/ZBoCBxdhR3YuaIpkJ3CIAyPWAuQv3sF7iGkSsqlEtLlb7Zeh/RNvN5hZ7YrOLsh
 sHsS6j1a4GAWGwWpXc9lQ+6XKaFyP9pfD/3U4ji5t9w3llUxgied6gcwwuUnMAESawHr
 XKG5wRxJo2PHsFrtNsUaPYHBCbF2txoevXeZNyWcby8O60DPcnZ1QRqSHrFDNLBVEldH TQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qhre5n3v1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:15 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02ERU026044
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 00:02:14 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1E02ELP001735;
	Thu, 14 Feb 2019 00:02:14 GMT
Received: from concerto.internal (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 16:02:14 -0800
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com
Cc: Tycho Andersen <tycho@docker.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
Subject: [RFC PATCH v8 08/14] arm64/mm: disable section/contiguous mappings if XPFO is enabled
Date: Wed, 13 Feb 2019 17:01:31 -0700
Message-Id: <0b9624b6c1fe5a31d73a6390e063d551bfebc321.1550088114.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1550088114.git.khalid.aziz@oracle.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tycho Andersen <tycho@docker.com>

XPFO doesn't support section/contiguous mappings yet, so let's disable it
if XPFO is turned on.

Thanks to Laura Abbot for the simplification from v5, and Mark Rutland for
pointing out we need NO_CONT_MAPPINGS too.

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Tycho Andersen <tycho@docker.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/arm64/mm/mmu.c  | 2 +-
 include/linux/xpfo.h | 4 ++++
 mm/xpfo.c            | 6 ++++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index d1d6601b385d..f4dd27073006 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -451,7 +451,7 @@ static void __init map_mem(pgd_t *pgdp)
 	struct memblock_region *reg;
 	int flags = 0;
 
-	if (debug_pagealloc_enabled())
+	if (debug_pagealloc_enabled() || xpfo_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	/*
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 1ae05756344d..8b029918a958 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -47,6 +47,8 @@ void xpfo_temp_map(const void *addr, size_t size, void **mapping,
 void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 		     size_t mapping_len);
 
+bool xpfo_enabled(void);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_kmap(void *kaddr, struct page *page) { }
@@ -69,6 +71,8 @@ static inline void xpfo_temp_unmap(const void *addr, size_t size,
 }
 
 
+static inline bool xpfo_enabled(void) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 92ca6d1baf06..150784ae0f08 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -71,6 +71,12 @@ struct page_ext_operations page_xpfo_ops = {
 	.init = init_xpfo,
 };
 
+bool __init xpfo_enabled(void)
+{
+	return !xpfo_disabled;
+}
+EXPORT_SYMBOL(xpfo_enabled);
+
 static inline struct xpfo *lookup_xpfo(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
-- 
2.17.1

