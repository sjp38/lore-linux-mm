Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0896B0069
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:02:04 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so188518725pfg.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:02:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d10si7164360plj.152.2017.02.08.06.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:02:03 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18DwmTC026133
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 09:02:02 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28fmwrcvfk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:02:01 -0500
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 19:31:58 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6FDC2E005E
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 19:33:23 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18E1uIQ4128980
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:31:56 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18E1t0B023875
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:31:56 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 0/3] Define coherent device memory node
Date: Wed,  8 Feb 2017 19:31:45 +0530
Message-Id: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

	This three patches define CDM node with HugeTLB & Buddy allocation
isolation. Please refer to the last RFC posting mentioned here for details.
The series has been split for easier review process. The next part of the
work like VM flags, auto NUMA and KSM interactions with tagged VMAs will
follow later.

https://lkml.org/lkml/2017/1/29/198

Optional Buddy allocation isolation methods

(1) GFP flag based		(mm_cdm_v1_optional_gfp)
(2) Zonelist rebuilding		(mm_cdm_v1_optional_zonelist)
(3) Cpuset			(mm_cdm_v1_optional_cpusets)

All of these optional methods as well as the posted nodemask (mm_cdm_v1)
approach can be accessed from the following git tree.

https://github.com/akhandual/linux.git

Anshuman Khandual (3):
  mm: Define coherent device memory (CDM) node
  mm: Enable HugeTLB allocation isolation for CDM nodes
  mm: Enable Buddy allocation isolation for CDM nodes

 Documentation/ABI/stable/sysfs-devices-node |  7 +++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 +++++
 drivers/base/node.c                         |  6 ++++
 include/linux/node.h                        | 49 +++++++++++++++++++++++++++++
 include/linux/nodemask.h                    |  3 ++
 mm/Kconfig                                  |  4 +++
 mm/hugetlb.c                                | 25 +++++++++------
 mm/memory_hotplug.c                         | 10 ++++++
 mm/page_alloc.c                             | 33 +++++++++++++++++--
 10 files changed, 134 insertions(+), 11 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
