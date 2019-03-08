Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B074C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 491212081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:48:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="cPBtA15q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 491212081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F19BF8E0006; Fri,  8 Mar 2019 17:48:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA18A8E0002; Fri,  8 Mar 2019 17:48:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D90A78E0006; Fri,  8 Mar 2019 17:48:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 998C08E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 17:48:53 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e4so23768177pfh.14
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 14:48:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=O5EHSkQ/u9+Ox2Mr2Uq0ikS/eyXYPl8wihZ948OlhZ0=;
        b=E/fu8Ny4gHedZIJ0i0bhUbidL25pFjdZsG3nWo46vwSF8fNZs9rMehsbK2yQnaWIr+
         ww3e1lfU3ActCYyFG2RL1b+baLAG/Ra4Q8qchUYEDJ/7bRirOI8AuU0FoRWmUVpCG2r4
         PwtTKmVhdQLBVJ62kaVC8WLiELmB6RfhNAtAc98QgHlVO19Lt8FPa13pKU8F2DyV5APq
         rjo5xK3VlqVzHDHTJTG+KsrMs5gBjaMjer7DLRWEfxnHZLqgXosEMghZ93MRyC3r/jbL
         lXaIlLJOjOztwU3KoxJpvQU2UvE7opFsuT+dk2f33V1+7rUHUTnnnmtjQe6+5qnXbakz
         /0Rw==
X-Gm-Message-State: APjAAAU/f6cPw+jlSMm7/fGFzFAeb9PI2FSkJHoba9LjCeABjEEjCAYY
	NI8KpNV13myLbd2mKUmdRb0UaqGP4CQ6pKpT4oowmRJY+5IBApsKFveRNRJC1pIYpANlitdmy0u
	P0veZ4hPBxa6SqDkb1LFKPguoe3CoHJGG3ApcZmI0cGqUJ1p5E8yH7GtFrcOaGPNxUw==
X-Received: by 2002:a63:2d5:: with SMTP id 204mr1793340pgc.407.1552085333287;
        Fri, 08 Mar 2019 14:48:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqxpfJbqLxVUxPmr4ayczYGNCYCXX1hCHEw0gKoemM1wLuxbo9t/hpc8F/xhVSKGHUv8yYD8
X-Received: by 2002:a63:2d5:: with SMTP id 204mr1793302pgc.407.1552085332402;
        Fri, 08 Mar 2019 14:48:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552085332; cv=none;
        d=google.com; s=arc-20160816;
        b=fFVdi7+5n6Huo37/O9bVwSFyNeGejrPslGkE3kUr+zajHfPU4eYX5UmQ637SAKe2LU
         vFsSv+JJ+OVbxyTGOY7AeZ6VhYvd/Sw1FKJNuJ2L5A+g6NCukc5vSEU96HCDnxt8T5UG
         KpO1aLlY8M9jbxby1Tpx7zNOe54amo2/9JAGMn53bsTt5S2bCTgAj+wE2nEUmnUUEqP1
         rXbX+L9oG5/D1uoVEMyWA/Kwg46w6L67oMVhwjGCL0eDyfyCFq0/5HLx7rk5hL8EM1/G
         5oZiicVftI506LEP8UmCu6ZbWo920/R0uIV0zQY0Cjcx/6vBZx/o8nTfNqgSVKx3/IlG
         cLhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=O5EHSkQ/u9+Ox2Mr2Uq0ikS/eyXYPl8wihZ948OlhZ0=;
        b=LbHW+NVUYf/TXaetdRPEWP3wl2SeD3KWxFaNikZhj0UQLGn9+DtB1K67OVMv0w6znf
         2L7FL4XRXdinTqvo0OETSh/9EEYZ82wFziG6T46g25euOHmFyojKw6TU2+9Gz1F/6qQb
         i3rxwIhhgwNL2V8AqLZS/zRNpOR1aKRyZpD3ohhA6I8h0wlYODcwyUGzDIwN1cogzf1e
         gRvb332KO1AqX4Iw8+4Ti6Ux/VF8AvNkaKyEVjdVLvL1tWA+0Ah/hKxDaUPcGKwiMACE
         +CBDjT3zJBPWQ35f6u53EuVhuF+ltrji2HB7wMN3Nm5kGb0iqsUxPlISA4KYtjno8yVG
         mnqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=cPBtA15q;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m6si5694373pgq.24.2019.03.08.14.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 14:48:52 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=cPBtA15q;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x28MjIg3055924;
	Fri, 8 Mar 2019 22:48:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=O5EHSkQ/u9+Ox2Mr2Uq0ikS/eyXYPl8wihZ948OlhZ0=;
 b=cPBtA15qK2/F168SBEZ+z7296XCrKvDYA9dCZ7BC1hmaZsAgpKaYCNw+nR1umxdgUFzB
 BsqwwVFqXv1doaaG2tN1P35Euo9dMadG8mwvqb3Bs/21Pg3miTNm7S0SwZZhFgU56te7
 6qs5LcAT5hkU9g1ijsbSWLQcI5bn0lfxrdN0yG2h/nMAtUuHOV1+NWw0RzpUhpiNY5Rx
 h+1/lH5q3dDcPEbjHZemaORGLDkToIFD/nhoUl867Cje5jU8+xZ6OzxCZ/RjE9xrEDom
 4hKTcFC+nzmnjfjmgmaWTRsBHVMP1b9k848Do5sqLkjhoNvC7qv5ZA73r6PMGdTcy2An tw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qyfbeu3w0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Mar 2019 22:48:47 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x28MmfV0019849
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 22:48:42 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x28MmfTb027797;
	Fri, 8 Mar 2019 22:48:41 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 08 Mar 2019 14:48:41 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/2] huegtlbfs: on restore reserve error path retain subpool reservation
Date: Fri,  8 Mar 2019 14:48:22 -0800
Message-Id: <20190308224823.15051-2-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20190308224823.15051-1-mike.kravetz@oracle.com>
References: <20190308224823.15051-1-mike.kravetz@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9189 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903080157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a huge page is allocated, PagePrivate() is set if the allocation
consumed a reservation.  When freeing a huge page, PagePrivate is checked.
If set, it indicates the reservation should be restored.  PagePrivate
being set at free huge page time mostly happens on error paths.

When huge page reservations are created, a check is made to determine if
the mapping is associated with an explicitly mounted filesystem.  If so,
pages are also reserved within the filesystem.  The default action when
freeing a huge page is to decrement the usage count in any associated
explicitly mounted filesystem.  However, if the reservation is to be
restored the reservation/use count within the filesystem should not be
decrementd.  Otherwise, a subsequent page allocation and free for the same
mapping location will cause the file filesystem usage to go 'negative'.

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G -4.0M  4.1G    - /opt/hugepool

To fix, when freeing a huge page do not adjust filesystem usage if
PagePrivate() is set to indicate the reservation should be restored.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dfdffc34a99..64ef640126cd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1257,12 +1257,23 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under its
-	 * minimum size if the reservation is not restored after page is free.
-	 * Therefore, force restore_reserve operation.
+	 * If PagePrivate() was set on page, page allocation consumed a
+	 * reservation.  If the page was associated with a subpool, there
+	 * would have been a page reserved in the subpool before allocation
+	 * via hugepage_subpool_get_pages().  Since we are 'restoring' the
+	 * reservtion, do not call hugepage_subpool_put_pages() as this will
+	 * remove the reserved page from the subpool.
 	 */
-	if (hugepage_subpool_put_pages(spool, 1) == 0)
-		restore_reserve = true;
+	if (!restore_reserve) {
+		/*
+		 * A return code of zero implies that the subpool will be
+		 * under its minimum size if the reservation is not restored
+		 * after page is free.  Therefore, force restore_reserve
+		 * operation.
+		 */
+		if (hugepage_subpool_put_pages(spool, 1) == 0)
+			restore_reserve = true;
+	}
 
 	spin_lock(&hugetlb_lock);
 	clear_page_huge_active(page);
-- 
2.17.2

