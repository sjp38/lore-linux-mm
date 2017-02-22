Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B72196B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:58:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t184so9698626pgt.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:58:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t63si1584751pfk.141.2017.02.22.07.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 07:58:23 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MFrrI8045174
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:58:23 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28rq70rn84-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:58:23 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 15:58:20 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 0/2] mm/cgroup soft limit data allocation
Date: Wed, 22 Feb 2017 16:58:09 +0100
Message-Id: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The first patch of this series is fixing a panic occurring when soft
limit data allocation is using soft limit data.

The second patch, as suggested by Michal Hocko, is pushing forward by
delaying the soft limit data allocation when a soft limit is set.

Laurent Dufour (2):
  mm/cgroup: avoid panic when init with low memory
  mm/cgroup: delay soft limit data allocation

 mm/memcontrol.c | 54 ++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 40 insertions(+), 14 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
