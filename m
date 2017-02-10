Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B54A56B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so43124829pfx.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:07:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n9si1246182pll.11.2017.02.10.02.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 02:07:41 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1AA3rml086544
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:41 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28h2dfbkbs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:41 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 10 Feb 2017 20:07:38 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 890EF3578053
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:37 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1AA7TJS38994074
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:37 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1AA752V002047
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:05 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2 0/3] Define coherent device memory node
Date: Fri, 10 Feb 2017 15:36:37 +0530
Message-Id: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
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

Changes in V2:

* Removed redundant nodemask_has_cdm() check from zonelist iterator
* Dropped the nodemask_had_cdm() function itself
* Added node_set/clear_state_cdm() functions and removed bunch of #ifdefs
* Moved CDM helper functions into nodemask.h from node.h header file
* Fixed the build failure by additional CONFIG_NEED_MULTIPLE_NODES check

Previous V1: (https://lkml.org/lkml/2017/2/8/329)

Anshuman Khandual (3):
  mm: Define coherent device memory (CDM) node
  mm: Enable HugeTLB allocation isolation for CDM nodes
  mm: Enable Buddy allocation isolation for CDM nodes

 Documentation/ABI/stable/sysfs-devices-node |  7 ++++
 arch/powerpc/Kconfig                        |  1 +
 arch/powerpc/mm/numa.c                      |  7 ++++
 drivers/base/node.c                         |  6 +++
 include/linux/nodemask.h                    | 58 ++++++++++++++++++++++++++++-
 mm/Kconfig                                  |  4 ++
 mm/hugetlb.c                                | 25 ++++++++-----
 mm/memory_hotplug.c                         |  3 ++
 mm/page_alloc.c                             | 24 +++++++++++-
 9 files changed, 123 insertions(+), 12 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
