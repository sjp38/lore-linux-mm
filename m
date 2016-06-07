Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 864AF828E1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:08:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ug1so68544805pab.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:08:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d7si9413920pac.77.2016.06.07.04.01.02
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 17/32] page-flags: relax policy for PG_mappedtodisk and PG_reclaim
Date: Tue,  7 Jun 2016 14:00:31 +0300
Message-Id: <1465297246-98985-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

These flags are in use for file THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 8cf09639185a..74e4dda91238 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -295,11 +295,11 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
