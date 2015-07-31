Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 01FA26B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 21:09:37 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so33644837pdj.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 18:09:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h4si6105405pdi.136.2015.07.30.18.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 18:09:36 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 2/3] selftests:vm: Point to libhugetlbfs for regression testing
Date: Thu, 30 Jul 2015 17:59:52 -0700
Message-Id: <1438304393-30413-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
References: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, joern@purestorage.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

The hugetlb selftests provide minimal coverage.  Have run script
point people at libhugetlbfs for better regression testing.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 tools/testing/selftests/vm/run_vmtests | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/testing/selftests/vm/run_vmtests b/tools/testing/selftests/vm/run_vmtests
index 9837a3f..9e5df58 100755
--- a/tools/testing/selftests/vm/run_vmtests
+++ b/tools/testing/selftests/vm/run_vmtests
@@ -75,6 +75,10 @@ else
 	echo "[PASS]"
 fi
 
+echo "NOTE: The above hugetlb tests provide minimal coverage.  Use"
+echo "      https://github.com/libhugetlbfs/libhugetlbfs.git for"
+echo "      hugetlb regression testing."
+
 echo "--------------------"
 echo "running userfaultfd"
 echo "--------------------"
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
