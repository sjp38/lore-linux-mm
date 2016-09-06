Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC9F6B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 01:34:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f128so446770128qkd.1
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 22:34:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f205si20313856qkb.17.2016.09.05.22.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 22:34:45 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u865X4tC133682
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 01:34:45 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 259n65w9a9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Sep 2016 01:34:44 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 6 Sep 2016 15:34:41 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BB8A42CE8046
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 15:34:34 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u865YYc753477380
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 15:34:34 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u865YYIG011707
	for <linux-mm@kvack.org>; Tue, 6 Sep 2016 15:34:34 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2 1/2] mm: Export definition of 'zone_names' array through mmzone.h
Date: Tue,  6 Sep 2016 11:04:31 +0530
Message-Id: <1473140072-24137-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

zone_names[] is used to identify any zone given it's index which
can be used in many other places. So exporting the definition
through include/linux/mmzone.h header for it's broader access.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Changes in V2:
- Removed the static and declared in mmzone.h per Andrew

 include/linux/mmzone.h | 1 +
 mm/page_alloc.c        | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..9943204 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -341,6 +341,7 @@ enum zone_type {
 
 };
 
+extern char * const zone_names[];
 #ifndef __GENERATING_BOUNDS_H
 
 struct zone {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c6..cb46bf8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -207,7 +207,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
 
 EXPORT_SYMBOL(totalram_pages);
 
-static char * const zone_names[MAX_NR_ZONES] = {
+char * const zone_names[MAX_NR_ZONES] = {
 #ifdef CONFIG_ZONE_DMA
 	 "DMA",
 #endif
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
