Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B54026B0270
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:36:46 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so359931084pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:36:46 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 185si36111454pfu.115.2016.07.25.17.36.12
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 18/33] HACK: block: bump BIO_MAX_PAGES
Date: Tue, 26 Jul 2016 03:35:20 +0300
Message-Id: <1469493335-3622-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to do IO a huge page a time. For x86-64, it's 512 pages, so
we need to double current BIO_MAX_PAGES.

To be portable to other archtectures we need more generic solution.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/bio.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index b7e1a00810f2..e10c67f21366 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -40,7 +40,7 @@
 #define BIO_BUG_ON
 #endif
 
-#define BIO_MAX_PAGES		256
+#define BIO_MAX_PAGES		512
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
