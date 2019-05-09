Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B1F9C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C52B2173B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:07:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MSFLQ2u1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C52B2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC7D96B000A; Thu,  9 May 2019 12:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7A0E6B000C; Thu,  9 May 2019 12:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40836B000D; Thu,  9 May 2019 12:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 836986B000A
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:07:35 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id f196so2545637itf.1
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=I6PRi0pOdbF1qRia4hyU8vB77984ia94C6lSX8nieBc=;
        b=ZpYVkGe/iZpvL30bE2S7XjvigwPKCiQm1DBH/0xCRWVw161BC4NAzwtZqCvI2QxnZt
         aTEpRcS8Zxhh4ZZnATK2RMti+knrEbN4ec8OUjqDy5VvdLolDdfKLWiGlvHf4iaxEgZn
         O4k12p/fqAEvWNzbHId3mbDSEhE7cddv8Hkqf1FRA1xztCknHftPXMo1KyTbzpGAmcGC
         K4TlumdOTdNqilI8qBuf0LVmtd2Pg2M4MBtjfwBeECbcZ79Rrl1dpQO3LzKhocOMG1XX
         NnlkbP/AcM4h4JVU4GR3DiTMSDxiESB89/Z5Mkd9IemJGNGlffTpa2ILjZX+CDVwGTX/
         bZNA==
X-Gm-Message-State: APjAAAWjQfKY4rcpUTdAQNYiCnvuQs2ApxYj0Ipf3/f44B2wxJuQqgR1
	l+CvUwuaDpoQ+OUz61+HwY4y7VvBH5Wgml/QFIKkJefL/Qv0n2V9aATjPlDgz/ikKpHFu3HUtsh
	IglcWF7BG3OD7Kmukm84BbM2xNDSb1o4gzX2yxEHOkuq0k1U9l2s47IwEvzhD2H2NYA==
X-Received: by 2002:a24:d241:: with SMTP id z62mr3455398itf.141.1557418055256;
        Thu, 09 May 2019 09:07:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBvGidortUkXv66d4mtLn605QoFvCapkB6qsjAmm+jZRCMYA/fucRf5H8ytR66F3iOEGIp
X-Received: by 2002:a24:d241:: with SMTP id z62mr3455345itf.141.1557418054564;
        Thu, 09 May 2019 09:07:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557418054; cv=none;
        d=google.com; s=arc-20160816;
        b=XbfG7J5fza9yCYx3QkFZgHOOynTDdRRatl/uy+iuPEvwnMP2v6hL5FlIspk5E9lvd5
         cA94tX/Irp1jGt7lDKlCwcYq86zbEk0+F3ithP2HlbPNkX1YEPVer2ry/LohJsa+Xy7t
         a1gy5S4ph55U+H5LtQFGEVXT4/34LpEJt9aDxo2GmIFzM1hI8TdGnnUyjBctbzcLPvaJ
         X5LEJJsSdIirgcilSWsGwy10n09ib8h+D3wizcVdtQOSKkixfoJ9A8GgMcpLft9DZG1m
         Mq5eMb/l34/fmPtutvMV/KdG7Op2KF+On6rID1929xwa3xJ9UfSuiV4A6oSAG+5ymDA8
         9xCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=I6PRi0pOdbF1qRia4hyU8vB77984ia94C6lSX8nieBc=;
        b=fG1acRQtGhdqfIeiYMHY6a0CiQmGDmMkNPr2tmqRd8PU3Tm7sqwWfzzV3tMCe/KGuE
         TFvP4j8Vg7dbXE/LXTeTX50nBTl6fK9YCoVUK3ZztVbkcIuMzfqWTKzhELxOjEcQWg1/
         g0CHWGLC+wfwa+Ubqu2IOVgd5TthP1SGJi2ttxazY46YUBdjqjKYq/QI08lrBTsIc/Fg
         erYPitzoO72Di3mmeGlV7xDiVfAzEDSBIzP5k8uhfVRLlfQGFCIskJrybyVZQB+vWEwr
         /4YErwhOYxaa3VBnUbGuFF7u5/t4YIphJYYV89k35VBBHCDAHepNJ9Urg++/w4vGoNY4
         2qkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MSFLQ2u1;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d3si1481516iob.16.2019.05.09.09.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:07:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MSFLQ2u1;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G41Lh084886;
	Thu, 9 May 2019 16:07:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=I6PRi0pOdbF1qRia4hyU8vB77984ia94C6lSX8nieBc=;
 b=MSFLQ2u1Jstz6EwPfaAn6k+Fs505zTzWCXVV7J67bbgMpgX2CNHS7Y9PJ6hA4vwDtfKz
 olX1oXmJ06oiPZ4TgLfJUyNliMfVg7nlvocWNAdq8fSKyBaDnbJGr2W1ZhCK4qxzsiMW
 S6OY3IS14npuzACKI9AG20RsokMuWhdbrwAXSn21K1Ef9hWNn8f8xKlvafsdPkwczcjE
 K22rBr3zok1fkiyBspvK38+RRRFZlDRsQL3qYY85BvPTMIc+xHCTv+/TNas6RWoknKrM
 CgGx7w+cqvvPMk0t+/TL2olpidfcB7QI3ldMe+9ZNL/VR8UycS1CPlG1Xr/M+pEzgZzc iw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2s94bgbytj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:07:19 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G75tS107307;
	Thu, 9 May 2019 16:07:19 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2scpy5rqht-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:07:19 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x49G7D1Q017003;
	Thu, 9 May 2019 16:07:13 GMT
Received: from oracle.com (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 09 May 2019 09:07:12 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
Cc: Larry Bassel <larry.bassel@oracle.com>
Subject: [PATCH, RFC 0/2] Share PMDs for FS/DAX on x86
Date: Thu,  9 May 2019 09:05:31 -0700
Message-Id: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=601
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905090092
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=625 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905090092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset implements sharing of page table entries pointing
to 2MiB pages (PMDs) for FS/DAX on x86.

Only shared mmapings of files (i.e. neither private mmapings nor
anonymous pages) are eligible for PMD sharing.

Due to the characteristics of DAX, this code is simpler and
less intrusive than the general case would be.

In our use case (high end Oracle database using DAX/XFS/PMEM/2MiB
pages) there would be significant memory savings.

A future system might have 6 TiB of PMEM on it and
there might be 10000 processes each mapping all of this 6 TiB.
Here the savings would be approximately
(6 TiB / 2 MiB) * 8 bytes (page table size) * 10000 = 240 GiB
(and these page tables themselves would be in non-PMEM (ordinary RAM)).

There would also be a reduction in page faults because in
some cases the page fault has already been satisfied and
the page table entry has been filled in (and so the processes
after the first would not take a fault).

The code for detecting whether PMDs can be shared and
the implementation of sharing and unsharing is based
on, but somewhat different than that in mm/hugetlb.c,
though some of the code from this file could be reused and
thus was made non-static.

Larry Bassel (2):
  Add config option to enable FS/DAX PMD sharing.
  Implement sharing/unsharing of PMDs for FS/DAX.

 arch/x86/Kconfig        |   3 ++
 include/linux/hugetlb.h |   4 ++
 mm/huge_memory.c        |  32 ++++++++++++++
 mm/hugetlb.c            |  21 ++++++++--
 mm/memory.c             | 108 +++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 163 insertions(+), 5 deletions(-)

-- 
1.8.3.1

