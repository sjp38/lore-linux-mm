Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id EC6D16B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:33:55 -0500 (EST)
Received: by pacej9 with SMTP id ej9so94321053pac.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:55 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id uj9si14397707pab.128.2015.11.19.14.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:33:54 -0800 (PST)
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJMT741021457
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:54 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6u7vmr-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:54 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 9cfa4e5a8f0d11e5872f0002c99331b0-9f9fc230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:53 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 1/8] userfaultfd: add helper for writeprotect check
Date: Thu, 19 Nov 2015 14:33:46 -0800
Message-ID: <0ca7fc28396ba827cdd6540127690e45ca120728.1447964595.git.shli@fb.com>
In-Reply-To: <cover.1447964595.git.shli@fb.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

add helper for writeprotect check. Will use it later.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/userfaultfd_k.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 587480a..4e22d11 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -48,6 +48,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_MISSING;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_UFFD_WP;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -75,6 +80,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return false;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
