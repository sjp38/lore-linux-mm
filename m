Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01216280246
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:10 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d3so13318750qth.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:48:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o12si5041749qki.458.2018.01.23.01.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 01:48:09 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0N9lcSW086801
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:08 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fp24ehnja-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:07 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 09:48:04 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm: docs: add blank lines to silence sphinx "Unexpected indentation" errors
Date: Tue, 23 Jan 2018 11:47:51 +0200
In-Reply-To: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1516700871-22279-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/pagewalk.c          | 1 +
 mm/process_vm_access.c | 2 ++
 mm/vmscan.c            | 1 +
 3 files changed, 4 insertions(+)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 23a3e415ac2c..8d2da5dec1e0 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -265,6 +265,7 @@ static int __walk_page_range(unsigned long start, unsigned long end,
  * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of these
  * callbacks, the associated entries/pages are just ignored.
  * The return values of these callbacks are commonly defined like below:
+ *
  *  - 0  : succeeded to handle the current entry, and if you don't reach the
  *         end address yet, continue to walk.
  *  - >0 : succeeded to handle the current entry, and return to the caller
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 011edefd3c92..1a27c837f004 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -147,6 +147,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
  * @riovcnt: size of rvec array
  * @flags: currently unused
  * @vm_write: 0 if reading from other process, 1 if writing to other process
+ *
  * Returns the number of bytes read/written or error code. May
  *  return less bytes than expected if an error occurs during the copying
  *  process.
@@ -253,6 +254,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
  * @riovcnt: size of rvec array
  * @flags: currently unused
  * @vm_write: 0 if reading from other process, 1 if writing to other process
+ *
  * Returns the number of bytes read/written or error code. May
  *  return less bytes than expected if an error occurs during the copying
  *  process.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47d5ced51f2d..8d01b095d97b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1606,6 +1606,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
  * found will be decremented.
  *
  * Restrictions:
+ *
  * (1) Must be called with an elevated refcount on the page. This is a
  *     fundamentnal difference from isolate_lru_pages (which is called
  *     without a stable reference).
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
