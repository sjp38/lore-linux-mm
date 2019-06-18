Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35707C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 07:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA8F52084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 07:32:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA8F52084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 167756B0003; Tue, 18 Jun 2019 03:32:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2808E0002; Tue, 18 Jun 2019 03:32:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EACD28E0001; Tue, 18 Jun 2019 03:32:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B16A86B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:32:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y75so807131pfg.1
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:32:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=74HL889peYR3czd0O1hHxo0J/IaCxhDuYag2WrXiebc=;
        b=PgKoaG/TMWwIBvhkaCl1LIaDd6I9JmlDVFAzK18/7Hn5HibKUPTPqmk4J894neb+Ii
         qnzKXUz+08gytDpTgiMIGAQR6vHiwxfwwqgBHCkxo+Kg7CoIw3bFB69uiIU/A3FGaji5
         ztmsTJUrTqkpuxDeRJlR4PxObC3kBAMLldT2WJtexDg1O2rQG6d/BrizMDHMQI/Ef+oa
         7g1bvF3hw+kf3GWAVU061hDos8w30N28/IcCnFk9PhAd5S+xS6DEuWuL5OVO+Mkc8smM
         IT/XWJArpWI0RZYOCqyATBv/OP+bDXjLehsYmAr9iPPGdjwMsL+wooer0OhSa9JYQls7
         6CRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX7oV1PeSuE1QONCj8fwV5/g7D6vv4+bhgppagL11ar24B8LgYh
	JDf8icCPlQOn5QXfQ5C8GBv7INu/VA4aJHafom3ZgNfWA/qAjJvcRj3uaFRz6E64MOb0w1/SO12
	tDghzxZ33Dg5r7qROy85WTxuu/QFKf2Ap53qciswF2vzWebfn8ErqPjOamhmlrSwfkA==
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr3568220pjx.107.1560843161408;
        Tue, 18 Jun 2019 00:32:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNeI/wMFGB3xS24ml8ktwXtoVvmw5dam5+Cjl4U8cMrtn7tPaChJ+Pp/CkFgt8pbGzqg7G
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr3568149pjx.107.1560843160399;
        Tue, 18 Jun 2019 00:32:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560843160; cv=none;
        d=google.com; s=arc-20160816;
        b=k+Q7agedGdCNSIeNEPOFrbBMs9M2Zri0OCNOsW3VrTMV7P1uFpbmi8Uxtlo0kbNVis
         AOiPfK+MP9nFEAQIlU7KsXeSBsPuo6m1et+hKjtXscvNhJKj/kwXUtg8CFnjPjhBseUh
         07TJSLA9+zbNZ+KMmQX7aiksrztrgrNv4qq3hSrIwmRZCMWIkRVdcke/DwRSjYyvEiKJ
         0FzPGHSewtcGg7IqMr6/xY1L01LgHoOPVtkDRPQSdW6DSRNLuxE8cz4Zx0mFhC+tuq1I
         ehXl6l9VGdbvkCQHX1xtm+QSPAl9sN90/vZokyWnkQ+/AVbR/1JwaFkUbHgdTMzsx7GK
         BQng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=74HL889peYR3czd0O1hHxo0J/IaCxhDuYag2WrXiebc=;
        b=cT8//u1ggpF3X+tEql896N11s7EGuLl2jlZJHfg6dORRd+jf9vJy6fH/pZUmzrYU3V
         j0thzVz4uZWpBLyVqH3ts8LqaGU9xt/zQ/XH8OPiXi0vDNc6yudDM8JZmmThWufgYdT1
         Xm0kSmE+RYc/JeAGURcnxXf1xo21ygmyNrNJv1kWSTDSKZrO1ZBjUEn7PsXpjrTonhkQ
         jvFlF8jZnmTM7DfaLkUZ7QG3usK/NDbbX4BwAvCdS7He24QSnOAWvSfdMZOk3vi1Pkz9
         3sIVefeDRMsfDrfd7o6SlGlu+uipDZwpbFLXHk/q3h//iC7oeFdhUo7lb4E2hXz8qjxN
         TPyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q4si13250662pfg.286.2019.06.18.00.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 00:32:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5I7SYPd034649
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:32:39 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t6t8qu2pu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:32:39 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 18 Jun 2019 08:32:37 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 18 Jun 2019 08:32:33 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5I7WWdI32702618
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 07:32:32 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 94A9C4C046;
	Tue, 18 Jun 2019 07:32:32 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DFB6B4C063;
	Tue, 18 Jun 2019 07:32:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 18 Jun 2019 07:32:30 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 18 Jun 2019 10:32:30 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Qian Cai <cai@lca.pw>,
        Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-arm-kernel@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] arm64/mm: don't initialize pgd_cache twice
Date: Tue, 18 Jun 2019 10:32:29 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19061807-0016-0000-0000-0000028A04C9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061807-0017-0000-0000-000032E7538F
Message-Id: <1560843149-13845-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-18_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=854 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906180062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When PGD_SIZE != PAGE_SIZE, arm64 uses kmem_cache for allocation of PGD
memory. That cache was initialized twice: first through
pgtable_cache_init() alias and then as an override for weak
pgd_cache_init().

Remove the alias from pgtable_cache_init() and keep the only pgd_cache
initialization in pgd_cache_init().

Fixes: caa841360134 ("x86/mm: Initialize PGD cache during mm initialization")
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm64/include/asm/pgtable.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 2c41b04..851c68d 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -812,8 +812,7 @@ extern int kern_addr_valid(unsigned long addr);
 
 #include <asm-generic/pgtable.h>
 
-void pgd_cache_init(void);
-#define pgtable_cache_init	pgd_cache_init
+static inline void pgtable_cache_init(void) { }
 
 /*
  * On AArch64, the cache coherency is handled via the set_pte_at() function.
-- 
2.7.4

