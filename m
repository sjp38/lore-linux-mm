Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 77B9D6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:15:49 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so49718637pdr.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 23:15:49 -0700 (PDT)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com. [209.85.220.48])
        by mx.google.com with ESMTPS id pa4si19787256pdb.151.2015.08.09.23.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 23:15:48 -0700 (PDT)
Received: by pacrr5 with SMTP id rr5so96397232pac.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 23:15:48 -0700 (PDT)
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V1 Resend 10/11] mm: Drop unlikely before IS_ERR(_OR_NULL)
Date: Mon, 10 Aug 2015 11:42:32 +0530
Message-Id: <a4c1dcb64bd60a990ec7ac031835120bec548680.1439187003.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439187003.git.viresh.kumar@linaro.org>
References: <cover.1439187003.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439187003.git.viresh.kumar@linaro.org>
References: <cover.1439187003.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, Viresh Kumar <viresh.kumar@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Matthew Wilcox <willy@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
is no need to do that again from its callers. Drop it.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7109330c5911..97b8d5cd4550 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -151,7 +151,7 @@ static int start_stop_khugepaged(void)
 		if (!khugepaged_thread)
 			khugepaged_thread = kthread_run(khugepaged, NULL,
 							"khugepaged");
-		if (unlikely(IS_ERR(khugepaged_thread))) {
+		if (IS_ERR(khugepaged_thread)) {
 			pr_err("khugepaged: kthread_run(khugepaged) failed\n");
 			err = PTR_ERR(khugepaged_thread);
 			khugepaged_thread = NULL;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
