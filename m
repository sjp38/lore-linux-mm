Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D02CC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:15:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A5C4218AF
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:15:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GkJ93X0V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A5C4218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C22758E0002; Wed, 30 Jan 2019 16:15:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD2C28E0001; Wed, 30 Jan 2019 16:15:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC1418E0002; Wed, 30 Jan 2019 16:15:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78A938E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:15:07 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id 63so538404ybf.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:15:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=rIMxUgtCRDVG/wcjmAlSmIOvfoTijxHPeFRFSa1Tavw=;
        b=jpUJManODdGgU8Z5S2sWtaJJLFalBsJQhgZFJ1Mp/73/ehaze0G6jKkpuufCpvLtvX
         SdTGnplBKb4+AvoavK0KSA7pqglzMGHZGwfbgUeLhZTw2IExiiUwZxTzTXBO8WEotZnZ
         JNlikMQ+TSSHuSKl3dxayQrEpIhcMBQMdoXfCQSVmkPFFKO0dADfCIc6DsuOfdoEXJmJ
         nLiaH9zw5hd/ebRcQFAgFuNKFXG3SpV5AOYNyqn7S2rwfVqx9XTkX31n7xoLwwkIKztp
         Tmb/NL6/Jsj4XrhUtSfEfuuUOU6/oLrUc51i/cSaXzzMNVebbzTW4AAARWckqPQ1UJv6
         SL7g==
X-Gm-Message-State: AJcUukfNlwyvv2NqFZenjm4NA8ygsdvAmjU4jqJP0aA91JmhbGETqRs0
	YNOxkN1RWIOjew4sOp1QnbJMIk0XTA+XeWrKopFi8ozRKts7pDlxz/JuXiLULAHnxyc6Ep3v+bb
	EH2o4W1W/8WHsMk6/c4myHrzHMTeZFyaLC7TPBbzqLwcUiCEQX7FwCVCptB/xgTt+1Q==
X-Received: by 2002:a81:1282:: with SMTP id 124mr31776759yws.154.1548882907180;
        Wed, 30 Jan 2019 13:15:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7+GTWjoVV8dCQH2T3dFLWO0YQ2Jo1t6I+3MxqoRlor42qQHjU8gzdAYV2+iCUX3lV4zjDT
X-Received: by 2002:a81:1282:: with SMTP id 124mr31776715yws.154.1548882906514;
        Wed, 30 Jan 2019 13:15:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548882906; cv=none;
        d=google.com; s=arc-20160816;
        b=aV3QAnNm54IXIRG7yTJwFWjeYeC3SgBH7XG6o6/Y4I3bwJD/XFhV3NlPHT9tUya1gY
         YiXO4kicQJtcDf9hNsLH2TrJQGjGHm4+/d4PMU35+ukgeidK9PIb1pEEPO4s9bcPmLGi
         +m/eJMwgt3GUkfcsjO030X+Z/gej9L5k+Xbpx8VJytuDrP8Zv2sKVpW/vdCMujW57sK2
         5L2lF5LTUMMabX65rK/fiTzKTDIDdF0JoIeLiNLWNn3mT0UTspBfORkT0t0SZu9Fsey3
         u610wxGi1vByt9waQfHT1cctG6Mpu7aNSsKXb4bR1+mg15CqNHtVxrSqqxwjNx7icn83
         UjQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=rIMxUgtCRDVG/wcjmAlSmIOvfoTijxHPeFRFSa1Tavw=;
        b=enGbMRLpT1Zd5gLl3kQlL8BaNfJqgEqEJsEMm08W8ZfwsiQ0pCEByTZuO9HAlWkLjB
         NJA0e/W3lYV9v+P4sHS7wl2EYPocx2UHmB+az/CMGuKczYXFqc5nhOe9k2tZtAQ5S+K3
         4F4hfHWlqsjU6gzv6E49MtDUVnePNG8oMx/rwipka6NFyC7mh8HvRaadX6IrRLvwepeF
         mhWQ+spddI/qP3wQZSLoN4glba356zcLcsMxNsgRkPTXDYcmNWkqp4GZeP29NgydsfUM
         XDxBIoXgDnFVvjE0zFb+8oX3xLKfiYcDMOII60951TDGrepyX65dLbdV+AjYWyul/4L8
         7yHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GkJ93X0V;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q10si1494196ybk.69.2019.01.30.13.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 13:15:06 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GkJ93X0V;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0UL49WS184680;
	Wed, 30 Jan 2019 21:15:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=rIMxUgtCRDVG/wcjmAlSmIOvfoTijxHPeFRFSa1Tavw=;
 b=GkJ93X0VCjyIV801XmWlC6UeUB/GCUYojQMy2FQosiwGh3DBOK/0IdCg143XqPAYC2CZ
 wfDsz4LFxWEHH58K6WjudPj2vMVZVLbNo9butG2yu7i24H4IgiZVWkX1w4sIeFvSSJRG
 7LjD84TGcBA+t48FQVytOk9OCsMV6BoqRCJ7ST//SYC0BThE+1Hsz00qJipaP+DkLtyK
 f++tsrKBoGajB9FUi0V2S04X5VwTE4E4XN3GEP3QK4kXNpdMN2U3j+OGrNpaAg30WYM4
 oEPRSY+0PjX6soREV/rzFLDoM9WTcRzc76d0ZEC4FxyH+WIi8TaVz0Smk/z2XEuOO9SH sA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2q8d2edah2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 21:15:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0ULEwIe011439
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 30 Jan 2019 21:14:59 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0ULEvN7006299;
	Wed, 30 Jan 2019 21:14:57 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 13:14:57 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org
Subject: [PATCH] huegtlbfs: fix page leak during migration of file pages
Date: Wed, 30 Jan 2019 13:14:43 -0800
Message-Id: <20190130211443.16678-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=499 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901300156
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Files can be created and mapped in an explicitly mounted hugetlbfs
filesystem.  If pages in such files are migrated, the filesystem
usage will not be decremented for the associated pages.  This can
result in mmap or page allocation failures as it appears there are
fewer pages in the filesystem than there should be.

For example, a test program which hole punches, faults and migrates
pages in such a file (1G in size) will eventually fail because it
can not allocate a page.  Reported counts and usage at time of failure:

node0
537	free_hugepages
1024	nr_hugepages
0	surplus_hugepages
node1
1000	free_hugepages
1024	nr_hugepages
0	surplus_hugepages

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G  4.0G     0 100% /var/opt/hugepool

Note that the filesystem shows 4G of pages used, while actual usage is
511 pages (just under 1G).  Failed trying to allocate page 512.

If a hugetlb page is associated with an explicitly mounted filesystem,
this information in contained in the page_private field.  At migration
time, this information is not preserved.  To fix, simply transfer
page_private from old to new page at migration time if necessary. Also,
migrate_page_states() unconditionally clears page_private and PagePrivate
of the old page.  It is unlikely, but possible that these fields could
be non-NULL and are needed at hugetlb free page time.  So, do not touch
these fields for hugetlb pages.

Cc: <stable@vger.kernel.org>
Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 10 ++++++++++
 mm/migrate.c         | 10 ++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..fb6de1db8806 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
+
+	/*
+	 * page_private is subpool pointer in hugetlb pages, transfer
+	 * if needed.
+	 */
+	if (page_private(page) && !page_private(newpage)) {
+		set_page_private(newpage, page_private(page));
+		set_page_private(page, 0);
+	}
+
 	if (mode != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..0d9708803553 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -703,8 +703,14 @@ void migrate_page_states(struct page *newpage, struct page *page)
 	 */
 	if (PageSwapCache(page))
 		ClearPageSwapCache(page);
-	ClearPagePrivate(page);
-	set_page_private(page, 0);
+	/*
+	 * Unlikely, but PagePrivate and page_private could potentially
+	 * contain information needed at hugetlb free page time.
+	 */
+	if (!PageHuge(page)) {
+		ClearPagePrivate(page);
+		set_page_private(page, 0);
+	}
 
 	/*
 	 * If any waiters have accumulated on the new page then
-- 
2.17.2

