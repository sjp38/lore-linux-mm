Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C8A1F6B0261
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:53 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fl4so17767674pad.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:53 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id z10si12941880pfi.50.2016.02.11.06.22.13
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 22/28] page-flags: relax policy for PG_mappedtodisk and PG_reclaim
Date: Thu, 11 Feb 2016 17:21:50 +0300
Message-Id: <1455200516-132137-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Therse flags are in use for file THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 19724e6ebd26..d0dfe4a5be33 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -292,11 +292,11 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  */
 TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
 	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
-PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_COMPOUND)
+PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
-	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
+PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
+	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
 PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
