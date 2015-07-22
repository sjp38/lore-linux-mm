Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3119B6B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:41:37 -0400 (EDT)
Received: by pacan13 with SMTP id an13so129919369pac.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:41:36 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id re6si12788812pab.88.2015.07.21.17.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:41:36 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so56590401pab.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:41:36 -0700 (PDT)
Date: Tue, 21 Jul 2015 17:41:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mmap.2: document the munmap exception for underlying page
 size
Message-ID: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

munmap(2) will fail with an errno of EINVAL for hugetlb memory if the 
length is not a multiple of the underlying page size.

Documentation/vm/hugetlbpage.txt was updated to specify this behavior 
since Linux 4.1 in commit 80d6b94bd69a ("mm, doc: cleanup and clarify 
munmap behavior for hugetlb memory").

Signed-off-by: David Rientjes <rientjes@google.com>
---
 man2/mmap.2 | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -383,6 +383,10 @@ All pages containing a part
 of the indicated range are unmapped, and subsequent references
 to these pages will generate
 .BR SIGSEGV .
+An exception is when the underlying memory is not of the native page
+size, such as hugetlb page sizes, whereas
+.I length
+must be a multiple of the underlying page size.
 It is not an error if the
 indicated range does not contain any mapped pages.
 .SS Timestamps changes for file-backed mappings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
