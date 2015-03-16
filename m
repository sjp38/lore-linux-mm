Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7C16B0071
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:53:56 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so79314605pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:53:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xh9si25456881pab.119.2015.03.16.16.53.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 16:53:55 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH V2 4/4] hugetlbfs: document min_size mount option
Date: Mon, 16 Mar 2015 16:53:29 -0700
Message-Id: <3c82f2203e5453ddf3b29431863034afc7699303.1426549011.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
In-Reply-To: <cover.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Update documentation for the hugetlbfs min_size mount option.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 Documentation/vm/hugetlbpage.txt | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index f2d3a10..83c0305 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -267,8 +267,8 @@ call, then it is required that system administrator mount a file system of
 type hugetlbfs:
 
   mount -t hugetlbfs \
-	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
-	none /mnt/huge
+	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,min_size=<value>, \
+	nr_inodes=<value> none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
 /mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
@@ -277,11 +277,18 @@ the uid and gid of the current process are taken.  The mode option sets the
 mode of root of file system to value & 01777.  This value is given in octal.
 By default the value 0755 is picked. The size option sets the maximum value of
 memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
-rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
-inodes that /mnt/huge can use.  If the size or nr_inodes option is not
-provided on command line then no limits are set.  For size and nr_inodes
-options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
-example, size=2K has the same meaning as size=2048.
+rounded down to HPAGE_SIZE.  The min_size option sets the minimum value of
+memory (huge pages) allowed for the filesystem.  Like the size option,
+min_size is rounded down to HPAGE_SIZE.  At mount time, the number of huge
+pages specified by min_size are reserved for use by the filesystem.  If
+there are not enough free huge pages available, the mount will fail.  As
+huge pages are allocated to the filesystem and freed, the reserve count
+is adjusted so that the sum of allocated and reserved huge pages is always
+at least min_size.  The option nr_inodes sets the maximum number of
+inodes that /mnt/huge can use.  If the size, min_size or nr_inodes option
+is not provided on command line then no limits are set.  For size, min_size
+and nr_inodes options, you can use [G|g]/[M|m]/[K|k] to represent
+giga/mega/kilo. For example, size=2K has the same meaning as size=2048.
 
 While read system calls are supported on files that reside on hugetlb
 file systems, write system calls are not.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
