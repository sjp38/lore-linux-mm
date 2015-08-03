Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 53F066B0255
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 06:41:14 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so99043634wic.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:41:13 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id dd7si24724675wjc.40.2015.08.03.03.41.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 03:41:12 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so130256283wib.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:41:12 -0700 (PDT)
Date: Mon, 3 Aug 2015 13:41:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9 25/36] mm, thp: remove infrastructure for handling
 splitting PMDs
Message-ID: <20150803104110.GA25034@node.dhcp.inet.fi>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437402069-105900-26-git-send-email-kirill.shutemov@linux.intel.com>
 <55BB8DB2.9010804@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55BB8DB2.9010804@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 31, 2015 at 05:01:06PM +0200, Jerome Marchand wrote:
> On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> > @@ -1616,23 +1605,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >   * Note that if it returns 1, this routine returns without unlocking page
> >   * table locks. So callers must unlock them.
> >   */
> 
> The comment above should be updated.

Like this?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d32277463932..78a6c7cdf8f7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1627,11 +1627,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 /*
- * Returns 1 if a given pmd maps a stable (not under splitting) thp.
- * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
+ * Returns true if a given pmd maps a thp, false otherwise.
  *
- * Note that if it returns 1, this routine returns without unlocking page
- * table locks. So callers must unlock them.
+ * Note that if it returns true, this routine returns without unlocking page
+ * table lock. So callers must unlock it.
  */
 bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
