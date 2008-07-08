Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m68I8Wt8008417
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 14:08:32 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m68I8Ujv064074
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 12:08:30 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m68I8TZM014529
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 12:08:30 -0600
Date: Tue, 8 Jul 2008 11:08:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC PATCH 4/4] hugetlb: remove CONFIG_SYSFS dependency
Message-ID: <20080708180826.GF14908@us.ibm.com>
References: <20080708180348.GB14908@us.ibm.com> <20080708180542.GC14908@us.ibm.com> <20080708180644.GD14908@us.ibm.com> <20080708180751.GE14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080708180751.GE14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: mel@csn.ul.ie, agl@us.ibm.com, akpm@linux-foudation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I incorrectly made the hugetlb kobject functionality depend on SYSFS,
when, in fact, the kobject functions fully work even with out sysfs.
Without sysfs, there is no interface to manipulate the attributes of the
various hugetlb kobjects, but they still exist.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9c24f8f..a432889 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1130,7 +1130,6 @@ out:
 	return ret;
 }
 
-#ifdef CONFIG_SYSFS
 #define HSTATE_ATTR_RO(_name) \
 	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
 
@@ -1282,12 +1281,6 @@ static void __exit hugetlb_exit(void)
 }
 module_exit(hugetlb_exit);
 
-#else
-static void __init hugetlb_sysfs_init(void)
-{
-}
-#endif
-
 static int __init hugetlb_init(void)
 {
 	BUILD_BUG_ON(HPAGE_SHIFT == 0);

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
