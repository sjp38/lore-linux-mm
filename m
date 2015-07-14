Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id AC726280246
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 10:05:49 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so82528655igc.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:05:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id h7si1980493pdj.127.2015.07.14.07.05.49
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 07:05:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-37-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-37-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 36/36] thp: update documentation
Content-Transfer-Encoding: 7bit
Message-Id: <20150714140543.5F9028B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 17:05:43 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> The patch updates Documentation/vm/transhuge.txt to reflect changes in
> THP design.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

checkpatch fixlet:

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index bfd967e442e1..b0cc5f8f161f 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -368,7 +368,7 @@ pages:
     succeed on tail pages.
 
   - map/unmap of the pages with PTE entry increment/decrement ->_mapcount
-    on relevent sub-page of the compound page.
+    on relevant sub-page of the compound page.
 
   - map/unmap of the whole compound page accounted in compound_mapcount
     (stored in first tail page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
