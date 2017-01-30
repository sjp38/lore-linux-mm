Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 060906B0285
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so438244359pgc.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:39:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j17si7501309pgg.167.2017.01.29.19.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:39:25 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YK5Z069788
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:24 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2890j8sbch-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:24 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:39:22 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D64652CE8046
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:19 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3dB2810289198
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:19 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3clX9022421
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:47 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 17/21] mm: Export definition of 'zone_names' array through mmzone.h
Date: Mon, 30 Jan 2017 09:05:58 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-18-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

zone_names[] is used to identify any zone given it's index which
can be used in many other places. So exporting the definition
through include/linux/mmzone.h header for it's broader access.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 1 +
 mm/page_alloc.c        | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f4aac87..fd1ab32 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -341,6 +341,7 @@ enum zone_type {
 
 };
 
+extern char * const zone_names[];
 #ifndef __GENERATING_BOUNDS_H
 
 struct zone {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 609cf9c..80fba54 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -212,7 +212,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
 
 EXPORT_SYMBOL(totalram_pages);
 
-static char * const zone_names[MAX_NR_ZONES] = {
+char * const zone_names[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	 "DMA",
 #endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
