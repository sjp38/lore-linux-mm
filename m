Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65687C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2119921852
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:52:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tup7p8Nc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2119921852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA9258E000D; Wed, 24 Jul 2019 13:52:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C58858E0005; Wed, 24 Jul 2019 13:52:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1FD88E000D; Wed, 24 Jul 2019 13:52:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94A408E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:52:33 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k31so42210845qte.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:52:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ijqWqbTQS+mO3BG8eUkyRBif1gJVoINohHHt0HHU2LM=;
        b=SOu2KKOi0d1vBtU62aaS27cEfgU8lz5TwENMmItxyygKICUqDQY77UyHStKv0vFfWa
         4SjbPXRehqFxjYNifjZls9uU7Q6FbMfQ0tgGOW6x1NcWntHsSPeSi62Cwn1mysBvPqTH
         d3YTPFsRdeeK5lWw14e2tosPUFapzScpocG2PgJaWFK1BdzNuG4TwgRrOWZHzJGkK1xK
         faVQGrtRyfpQETKdO/tHlvkYdYPuIFwPrfUpcsEjmcYyPj1tDvLgfucMIvmEpzWeV3RL
         QVo73AA9ehxz6UUL7K+a5SAH7xb2p31/wHLxhMw6uaNys1WUyz7/BWlSTwuzihmMNN48
         upew==
X-Gm-Message-State: APjAAAXRwXxxYWNO0OAu0G+rQ2L0lKUm/QRn2V3g1WxoDwPfdR+yZ8rn
	Z0h5DWnrxGMLyVzmQ47mtdIECGu/dHVeFgQFUbTfMKFBiMiWIbtqf4ws4CyEIDqqbh3nIZuy+W4
	7sgaJI0Fd8kynuO2YThCvC1x1dGv2JKx0Rj6DdGhefsowi3/s+AOJW9p6kvyyLMeqzQ==
X-Received: by 2002:ac8:24b8:: with SMTP id s53mr59990110qts.276.1563990753307;
        Wed, 24 Jul 2019 10:52:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwT0lKDbv5OaFN+nElG2jPwu8x5Z6PanALKm0koyxrYStqDKK2IlKwQbjRhu+tiIqZoaQz
X-Received: by 2002:ac8:24b8:: with SMTP id s53mr59990065qts.276.1563990752276;
        Wed, 24 Jul 2019 10:52:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563990752; cv=none;
        d=google.com; s=arc-20160816;
        b=EEeT12GI3kHq+tDFDk0QOr7OCgZQuVNz2Tq5HSBpbAet9h1U4ORnJWE05kRdMQ8Hvj
         izr52qgzhceOHsCTKKvtDc2zgQ4hYUmhh4QKEU5W27+VJCpk7uGiKY+PzzudClsBSR7w
         jVJPKuPvTOvIC8KWxJn3Ti4nVIAVQ6f6BiZpqBBVs0Lzlt1R5PjIo9ejt7F0Ah09VRxh
         9MojJt0sID9Rb79A4j+RkM4Z3uMEFWAzMaI3oEqmByT+Y9ATPkDQzTL41lzXs6pqZcJP
         XQaboLOoosTKguiBRQUrSZy4kYdSl1Kx1gI3URkHQ+s7+m8+Xkqiuyh2+j2Br/vEN/om
         zZUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ijqWqbTQS+mO3BG8eUkyRBif1gJVoINohHHt0HHU2LM=;
        b=C6PF6iqSJmGz5ynhXQpCc4TXISproEAXonWtdmpu2pqME9+BwbsLpn9CGB3Rfv+JgI
         8IpJJl6iTwCYaf7pP3yU6nZBCbGC/bQtICOlxPpOt+BzrzNgcHDgClMCE/7/dwevQnQP
         VNGdZdzpSZRTsxp1w3fD/IEuRjwFDMO46sOjQ00Q/+zv6oC4yJm5bs9h11mTfbitI2ph
         oERMbBoL6UrBGT5GMDtIXo2VqWzVKofDwLBHUFWtA+vd9Ay+9kkzFkwvF4ZJzJPah1wL
         M7LwawjYXW1oO8lipvVvWqTv7PLojWpFkd7c0kejQ/Pizk/zAahr0BifCxCttIgdC5ey
         Ra5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tup7p8Nc;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r10si32648079qtb.381.2019.07.24.10.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:52:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tup7p8Nc;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHde6B049688;
	Wed, 24 Jul 2019 17:52:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=ijqWqbTQS+mO3BG8eUkyRBif1gJVoINohHHt0HHU2LM=;
 b=tup7p8NclfqJa8HNUqc3r507Q+5d5c4/aRy/NdyxP+wvdiYSD1QTyx+qJ3sVlK2w61oa
 /8aL4/T0MK/QwIQYhZUuPHUZtnMFaHKDwfvodoE3lwcHbZEdeQKrK95iB5wp3dQF4Jjt
 Qrvq2pJrRa4oIqvapHFz0oln13nyP3xnTKqZ2FRosyKvNT3T6FSzEGKNNF2mJ2Ljr1wU
 Rhr6EUlHq8ayFK6cUHVjTHzbplH8Gkry5a3eHkWHJS9P4KjOUjPpZ5NsgUUiseifT0KO
 zqOS7u4WCOMTmfW6V0K8L3f3fWuC379XJ4fwuQaoQhBWryFiL2qLEqdCJokb/HDjCdbP Zg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2tx61by13q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:52:28 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OHcAo4188438;
	Wed, 24 Jul 2019 17:50:28 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2tx60y698g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 17:50:28 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6OHoMOj019819;
	Wed, 24 Jul 2019 17:50:22 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 10:50:22 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/3] fix hugetlb page allocation stalls
Date: Wed, 24 Jul 2019 10:50:11 -0700
Message-Id: <20190724175014.9935-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240191
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240191
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allocation of hugetlb pages via sysctl or procfs can stall for minutes
or hours.  A simple example on a two node system with 8GB of memory is
as follows:

echo 4096 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
echo 4096 > /proc/sys/vm/nr_hugepages

Obviously, both allocation attempts will fall short of their 8GB goal.
However, one or both of these commands may stall and not be interruptible.
The issues were discussed in this thread [1].

This series attempts to address the issues causing the stalls.  There are
two distinct issues, and an optimization.  For the reclaim and compaction
issues, suggestions were made to simply remove some existing code.  However,
the impact of such changes would be hard to address.  This series takes a
more conservative approach in an attempt to minimally impact existing
workloads.  The question of which approach is better is debatable, hence the
RFC designation.  Patches in the series address these issues:

1) Should_continue_reclaim returns true too often.
   Michal Hocko suggested removing the special casing for __GFP_RETRY_MAYFAIL
   in should_continue_reclaim.  This does indeed address the hugetlb
   allocations, but may impact other users.  Hillf Danton restructured
   the code in such a way to preserve much of the original semantics.  Hillf's
   patch also addresses hugetlb allocation issues and is included here.

2) With 1) addressed, should_compact_retry returns true too often.
   Mel Gorman suggested the removal of the compaction_zonelist_suitable() call.
   This routine/call was introduced by Michal Hocko for a specific use case.
   Therefore, removal would likely break that use case.  While examining the
   reasons for compaction_withdrawn() as in [2], it appears that there are
   several places where we should be using MIN_COMPACT_COSTLY_PRIORITY instead
   of MIN_COMPACT_PRIORITY for costly allocations.  This patch makes those
   changes which also causes more appropriate should_compact_retry behavior
   for hugetlb allocations.

3) This is simply an optimization of the allocation code for hugetlb pool
   pages.  After first __GFP_RETRY_MAYFAIL allocation failure on a node,
   it drops the __GFP_RETRY_MAYFAIL flag.


[1] http://lkml.kernel.org/r/d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com
[2] http://lkml.kernel.org/r/6377c199-2b9e-e30d-a068-c304d8a3f706@oracle.com

Hillf Danton (1):
  mm, reclaim: make should_continue_reclaim perform dryrun detection

Mike Kravetz (2):
  mm, compaction: use MIN_COMPACT_COSTLY_PRIORITY everywhere for costly
    orders
  hugetlbfs: don't retry when pool page allocations start to fail

 mm/compaction.c | 18 +++++++---
 mm/hugetlb.c    | 87 +++++++++++++++++++++++++++++++++++++++++++------
 mm/vmscan.c     | 28 ++++++++--------
 3 files changed, 105 insertions(+), 28 deletions(-)

-- 
2.20.1

