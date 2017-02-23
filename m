Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 035526B038B
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so48148786pgc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 05:36:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 127si5080030itx.63.2017.02.23.05.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 05:36:51 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1NDSlgL074843
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:50 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28sw9b1637-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:36:50 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 13:36:48 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] mm/cgroup soft limit data allocation
Date: Thu, 23 Feb 2017 14:36:37 +0100
Message-Id: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The first patch of this series is fixing a panic occurring when soft
limit data allocation is using soft limit data.

The second patch, as suggested by Michal Hocko, is pushing forward by
delaying the soft limit data allocation when a soft limit is set.

V1->V2:
 - move sanity pointer checks to the first patch
 - differ also the allocation of the pointer table
 - return error in the case allocation failed

Laurent Dufour (2):
  mm/cgroup: avoid panic when init with low memory
  mm/cgroup: delay soft limit data allocation

 mm/memcontrol.c | 74 ++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 57 insertions(+), 17 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
