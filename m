Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4430F6B0073
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:22:24 -0500 (EST)
Received: by pdjy10 with SMTP id y10so52995530pdj.6
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 17:22:24 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c4si2837236pdo.227.2015.03.03.17.22.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 17:22:23 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 4/4] hugetlbfs: document reserved mount option
Date: Tue,  3 Mar 2015 17:21:46 -0800
Message-Id: <1425432106-17214-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
References: <1425432106-17214-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

Update documentation for the hugetlbfs reserved mount option.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 Documentation/vm/hugetlbpage.txt | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index f2d3a10..1d88bfb 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -267,8 +267,8 @@ call, then it is required that system administrator mount a file system of
 type hugetlbfs:
 
   mount -t hugetlbfs \
-	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,nr_inodes=<value> \
-	none /mnt/huge
+	-o uid=<value>,gid=<value>,mode=<value>,size=<value>,reserved,\
+	nr_inodes=<value> none /mnt/huge
 
 This command mounts a (pseudo) filesystem of type hugetlbfs on the directory
 /mnt/huge.  Any files created on /mnt/huge uses huge pages.  The uid and gid
@@ -277,11 +277,15 @@ the uid and gid of the current process are taken.  The mode option sets the
 mode of root of file system to value & 01777.  This value is given in octal.
 By default the value 0755 is picked. The size option sets the maximum value of
 memory (huge pages) allowed for that filesystem (/mnt/huge). The size is
-rounded down to HPAGE_SIZE.  The option nr_inodes sets the maximum number of
-inodes that /mnt/huge can use.  If the size or nr_inodes option is not
-provided on command line then no limits are set.  For size and nr_inodes
-options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo. For
-example, size=2K has the same meaning as size=2048.
+rounded down to HPAGE_SIZE.  If the size option is specified, the reserved
+option may also be specified to reserve the number of huge pages required for
+the maximum filesystem size.  This number of huge pages is reserved at mount
+time and will be available for exclusive use by the filesystem.  If not enough
+huge pages are available, the mount will fail.  The option nr_inodes sets
+the maximum number of inodes that /mnt/huge can use.  If the size or nr_inodes
+option is not provided on command line then no limits are set.  For size and
+nr_inodes options, you can use [G|g]/[M|m]/[K|k] to represent giga/mega/kilo.
+For example, size=2K has the same meaning as size=2048.
 
 While read system calls are supported on files that reside on hugetlb
 file systems, write system calls are not.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
