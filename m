Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C505C0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:41:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B592320449
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:41:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ig+gtw/n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B592320449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658186B0006; Fri,  2 Aug 2019 18:41:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6085A6B0008; Fri,  2 Aug 2019 18:41:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A87E6B000A; Fri,  2 Aug 2019 18:41:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 228FC6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:41:48 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id x83so32739363vkx.12
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:41:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=V+S2cCRMzMkTYxl1DBlk1mcxDep6bRomMR5hspXDz/A=;
        b=j/yD+kYOEe9ljl6qABbdR2mwo36vaY8jexvBrE3OWlErRpj/QHcIN3bev+VRcXcSMi
         XTPoTbzU4e1PiEy2gRPT4NT+PKf4BMyqANizd46Wiqo/hAdfyG4yYCzONRklWcHMEyML
         x8GsY8GeYjrkBRxmclS5iEGOQr7Uk6IIzVwfng54I8PdU4rBZUl+lE6gNicgha/Bvm04
         BcpZolkC4XS/0l8LNjKd1K80RDImkI76GHfNAoDNyRIMDasPwAWcg1Y6gCSXu40BeHlI
         u+1r+cADyEY4zb+qUuw7fb9WD1elFv380yktF38P39AblDxUAPDUvvFM9SW1TRBUmtwa
         5wdA==
X-Gm-Message-State: APjAAAULgcHQQN3a2/9CfSdX75DpVy4USvxscyALXNNX/vRXFDq6k6gZ
	2+gQznEkG+UKFMmNPO1J1eRHlqfPy5/3ogirvhGBfcYiBEVuDQ2J/J2DOcYeUPBn0NNn+ThWixY
	S2ZUCZ3BMGIowQfrPneLxo8t+9kdH29ZarQ9AU2O8wRleLcnpUqscH4LaQh4MzIuh/g==
X-Received: by 2002:a67:fa08:: with SMTP id i8mr87841128vsq.140.1564785707694;
        Fri, 02 Aug 2019 15:41:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvSqnqSGtsoue/Xpd8hY5T0FflQ3rdINZdECDZFA4fOMnCKge9wQQvTUquLvb6bqjeskVU
X-Received: by 2002:a67:fa08:: with SMTP id i8mr87841114vsq.140.1564785707076;
        Fri, 02 Aug 2019 15:41:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564785707; cv=none;
        d=google.com; s=arc-20160816;
        b=PjllZ+g4KX2jT1HVvlfooIGpiWx9bSMK+l6KxLgddvuThiQtiwCxZNRlzPsPpIgdow
         olVuaSqd1wJxtP2kyJVkA9ruL+a+ZL3q5+veB7SG03y0rHDtKwKcG01k5en9HR3fZJFz
         E7symf62D2E6BPQXdvMYqfmimiQ4roa7M8n0gok7RXZxLYD6HbUiF+tSwykofuntmJPi
         Y3xEU8bJSkVO1MEqcaT3XQLEzpym3Iht1wbSzIoA2zcGN1fdNrRKyj3FyUYHMvyg2bMo
         z0jVKHMtKeRCNOPLqy3PQSrPzS2QyfM7OWhJbLf7Auqjig41by6V3gtIVr9uL9oqqMc8
         Js9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=V+S2cCRMzMkTYxl1DBlk1mcxDep6bRomMR5hspXDz/A=;
        b=R6IA/C/PNvdMUQWVclrDPbF31nstaw5AzU4nnfkfbSYuZy+x7TLG7HYFVScs8tW9bM
         dGs3Ct6KYTBeUFmgV6Ym6jmhiRa0vLY4ZfY0dzS5bTmQGA52h3yzwo0PH7FJjF+Il8XC
         p0gwilt1HoluHz5qF0OkaEeO+2zbqeJylCO7PcjEDrU2vIk9gjqGJbxd4fOUrO7MQwqF
         sCF64mUu7Yfbfvq+VF5MQePEBZShupTl+VjEyEbY9IUoy2VCquB1WkVRgcpr7VDAj84g
         LsZqnZSDdEzZUQRKRtG7nO5SUf+04TDZXw/dYbwBPWE+0DxmK/eJWxgf4Chmo6HSpdQC
         OXdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="ig+gtw/n";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u64si855129vkf.65.2019.08.02.15.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 15:41:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="ig+gtw/n";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72Mcsj7121652;
	Fri, 2 Aug 2019 22:41:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=V+S2cCRMzMkTYxl1DBlk1mcxDep6bRomMR5hspXDz/A=;
 b=ig+gtw/nHmMxdo2vG1ndB2NiEqFfiYcUxaaBUSJx4t41mk4jtfIZQjRxMKN/dFhqn3b5
 XQsuzLmoTDHEQCqi/cbSkIPx12KXT7FhePPM23IFMtCWoFs3MHcr/RL2XeLj7XCh9hrt
 AyBcRTJJW0AQqob8Dj6P3LUnk81ChUJssJVpahmd0Ax318/0mOiMPzywXJfWsFd+BKx9
 O2sZAt/f97yK9exYSXetY3PCHpaDSjSvcfn1twbJUfZdnX2pqJwMU5ylqUYjxJNcBGrA
 vptAdemis7KpqPAfGyaYys7n0jALfXZPnwkzD4orTRXtnc3rKcw7Q1qkiRmqKO1Dvapo Eg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2u0e1ucymc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:41:42 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72Mbq8A062797;
	Fri, 2 Aug 2019 22:39:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2u4vsj1upb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 22:39:41 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x72MdZrw022117;
	Fri, 2 Aug 2019 22:39:35 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 15:39:34 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] address hugetlb page allocation stalls
Date: Fri,  2 Aug 2019 15:39:27 -0700
Message-Id: <20190802223930.30971-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020238
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020238
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
The issues were initially discussed in mail thread [1] and RFC code at [2].

This series addresses the issues causing the stalls.  There are two distinct
fixes, and an optimization.  The reclaim patch by Hillf and compaction patch
by Vlasitmil address corner cases in their respective areas.  hugetlb page
allocation could stall due to either of these issues.  The hugetlb patch by
Mike is an optimization suggested during the debug and development process.

[1] http://lkml.kernel.org/r/d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com
[2] http://lkml.kernel.org/r/20190724175014.9935-1-mike.kravetz@oracle.com

Hillf Danton (1):
  mm, reclaim: make should_continue_reclaim perform dryrun detection

Mike Kravetz (1):
  hugetlbfs: don't retry when pool page allocations start to fail

Vlastimil Babka (1):
  mm, compaction: raise compaction priority after it withdrawns

 include/linux/compaction.h | 22 +++++++---
 mm/hugetlb.c               | 86 +++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c            | 16 +++++--
 mm/vmscan.c                | 28 +++++++------
 4 files changed, 120 insertions(+), 32 deletions(-)

-- 
2.20.1

