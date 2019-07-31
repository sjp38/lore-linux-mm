Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6947AC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D1642067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:25:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rVzjxOKL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D1642067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE7E78E0006; Wed, 31 Jul 2019 04:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F8B68E0001; Wed, 31 Jul 2019 04:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898AA8E0006; Wed, 31 Jul 2019 04:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69A958E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:25:37 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id x17so73996224iog.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=VzY9DtvcuYA0baJP6t/Benjg0AjHRQ2iCGpw97K47d4=;
        b=b2xoQE/rB/YGNMOqMMqjscLHlqc1fhOi7OgembbKA0fZPf0V/ZFor4RfzfoABztzdi
         vFhLeqghjFDYoIDpYLw+/dq9+uJQDJ0Nvm+GWV0YHFx+gwq6xBnKxC98VnPcKzvaCoue
         ZrurjBdT32KvSJbVRX5xZ/pkiIFkEpoxGscBjrrRq60mOf/6HbfP/YeEpGGGC50ClhFu
         VeTYWaMQl3xzL5z1VXk8AGQlkkFmR+YIdN9ogievMJ7FbI3Xnfrf5uSYK+zxmeI3Ss/P
         UUmCWByCIrTA9Lm6/YI5BvK7G5bkzkl4ySzot0g1XVs6S1WPlN2hozs1DHPaY5X1rlbh
         Z00Q==
X-Gm-Message-State: APjAAAUxBr7IpJLujFpIqfAaYpbVNKmUB9hOMzhVshOZBMKEDJEm/wJH
	6Ag40NAt1sAHLeYDQRxGvssapfwV0KstKPIMOksqtRHOIphhHqWMafvCMfRTCeafKufdTpaS//d
	AesisoW8DJGjxhr+nd3/0FMxha4wuuSyWK32qA81IZUEutcQ8wEWEKaAJT0vrCADNqQ==
X-Received: by 2002:a6b:ee15:: with SMTP id i21mr11467847ioh.281.1564561537218;
        Wed, 31 Jul 2019 01:25:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzYVgqrkLbyxCIhqqaQ4+BtUNfUan8K3iLy0YtUuyYXzI3JAYcMF4Zkk/V5MAymPKAgAvR
X-Received: by 2002:a6b:ee15:: with SMTP id i21mr11467786ioh.281.1564561536190;
        Wed, 31 Jul 2019 01:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564561536; cv=none;
        d=google.com; s=arc-20160816;
        b=dJ5OcHuHwcz5g+U7zDNAmsUpu3xom+0I4QBhy25lrKIE99OoL3cRHALFiB7PoSsLq+
         4NwtHUbkXAMThzK9tJhLXLyVL8zYahx5eFDJs6Ka19KfZLp5t8FKcC0GHo3Od0VSWzrX
         CiwGmqeX83cb3XNYPqcp1GCPZIO2EynnyAxwnCzg43cwDSbIuuRSY2FV8VQfQPSc1H9q
         B1VIHguThKCuBhHKd1LyP0xdkDBiBbviBMvRBz1vQS/VJER5yDAKII2iYtJ8uWCo3z2o
         zyoSmkbQv/Rk9/sMNWhCSWw97fdMrWo5+l0GQ4GvUxM8fQl/EDJAMq7tZMwQ+I1RG3DQ
         wfLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=VzY9DtvcuYA0baJP6t/Benjg0AjHRQ2iCGpw97K47d4=;
        b=AnTg25vvOMQbpJm96IUyKqEy9VFXiVAzn6n69IRar1Tws9S+llod5/Hm6xU5ZhZ+H+
         A2RrM/G7Q6vAZCxzki1/4EPPh9I95cFoQHXX+LvjKQeA8gG4nNZ+yA5h9kBWRyka2CKg
         xyyt3dmtN6nMMR8yQlFm8kBcOhG5x696b2nbUpOnKEXR9LonlHWCSA2Ycxc05CyUrbMS
         kcaO61sbOxCPkFBKxpTzOTkn4zUEMqo+YwONIEeuLFYMkBf40ofWIYE8s2I4RG1sa6F7
         LUHyXVIBUstCrYe7CsbUmc3mLfYK3e51w9Jl+3SCzD2KNayCUATAN543jVa7GTLjwu1D
         um6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rVzjxOKL;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id v20si97935288jan.70.2019.07.31.01.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rVzjxOKL;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V8O2rn081021;
	Wed, 31 Jul 2019 08:25:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=VzY9DtvcuYA0baJP6t/Benjg0AjHRQ2iCGpw97K47d4=;
 b=rVzjxOKLZYfncMJWM6YjSqp66vZz7Im9L9AWAq0M/1J1TSTOCQjdkPZzvqksQg3BDtbc
 nJsPa1E/SBHFmxcYmm+DS/oSaFMoyfQkqq1klkdzSBL5QD1IVniDBMrK86fNeeXZo+I1
 MitK1+U2rUnN19Eov28HOCs3UZlSsOhNkOqlY3KuHdLOTWWbkka9MGyly9Vq5PU9dtYQ
 p26QpaXYxH5xVxroX5K584wyuVmBcUCjaRQNIgaiNxa98T+sflxQUcwIuMYOjE1cUvLQ
 ZmWqK0OmFnRW9b+xFwvmN2euQ+jfySlnKzjDA5SjCE4REh0uQD83bVEuxTvwL4/w3UYt zw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u0ejpkkuc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 08:25:23 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V8Mu9M055712;
	Wed, 31 Jul 2019 08:25:22 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2u2exbbmha-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 08:25:22 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6V8PJ4X004270;
	Wed, 31 Jul 2019 08:25:19 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 31 Jul 2019 01:25:19 -0700
From: William Kucharski <william.kucharski@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        William Kucharski <william.kucharski@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 0/2] mm,thp: Add filemap_huge_fault() for THP
Date: Wed, 31 Jul 2019 02:25:11 -0600
Message-Id: <20190731082513.16957-1-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=820
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907310090
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=874 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907310090
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set of patches is the first step towards a mechanism for automatically
mapping read-only text areas of appropriate size and alignment to THPs
whenever possible.

For now, the central routine, filemap_huge_fault(), amd various support
routines are only included if the experimental kernel configuration option

	RO_EXEC_FILEMAP_HUGE_FAULT_THP

is enabled.

This is because filemap_huge_fault() is dependent upon the
address_space_operations vector readpage() pointing to a routine that will
read and fill an entire large page at a time without poulluting the page
cache with PAGESIZE entries for the large page being mapped or performing
readahead that would pollute the page cache entries for succeeding large
pages. Unfortunately, there is no good way to determine how many bytes
were read by readpage(). At present, if filemap_huge_fault() were to call
a conventional readpage() routine, it would only fill the first PAGESIZE
bytes of the large page, which is definitely NOT the desired behavior.

However, by making the code available now it is hoped that filesystem
maintainers who have pledged to provide such a mechanism will do so more
rapidly.

The first part of the patch adds an order field to __page_cache_alloc(),
allowing callers to directly request page cache pages of various sizes.
This code was provided by Matthew Wilcox.

The second part of the patch implements the filemap_huge_fault() mechanism
as described above.

Changes since v2:
1. FGP changes were pulled out to enable submission as an independent
   patch
2. Inadvertent tab spacing and comment changes were reverted

Changes since v1:
1. Fix improperly generated patch for v1 PATCH 1/2

Matthew Wilcox (1):
  mm: Allow the page cache to allocate large pages

William Kucharski (1):
  Add filemap_huge_fault() to attempt to satisfy page faults on
    memory-mapped read-only text pages using THP when possible.

 fs/afs/dir.c            |   2 +-
 fs/btrfs/compression.c  |   2 +-
 fs/cachefiles/rdwr.c    |   4 +-
 fs/ceph/addr.c          |   2 +-
 fs/ceph/file.c          |   2 +-
 include/linux/huge_mm.h |  16 +-
 include/linux/mm.h      |   6 +
 include/linux/pagemap.h |  10 +-
 mm/Kconfig              |  15 ++
 mm/filemap.c            | 320 ++++++++++++++++++++++++++++++++++++++--
 mm/huge_memory.c        |   3 +
 mm/mmap.c               |  36 ++++-
 mm/readahead.c          |   2 +-
 mm/rmap.c               |   8 +
 net/ceph/pagelist.c     |   4 +-
 net/ceph/pagevec.c      |   2 +-
 16 files changed, 401 insertions(+), 33 deletions(-)

-- 
2.21.0

