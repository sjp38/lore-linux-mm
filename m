Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 992AE6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 06:30:53 -0400 (EDT)
Received: by pawu10 with SMTP id u10so11983818paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:30:53 -0700 (PDT)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com. [209.85.220.46])
        by mx.google.com with ESMTPS id so7si8807865pab.95.2015.08.12.03.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 03:30:52 -0700 (PDT)
Received: by pawu10 with SMTP id u10so11983481paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 03:30:52 -0700 (PDT)
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V1 Resend 09/10] mm: Drop unlikely before IS_ERR(_OR_NULL)
Date: Wed, 12 Aug 2015 15:59:46 +0530
Message-Id: <d68927c04ea7a284ec83f4401e83302eee6083c9.1439375087.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1439375087.git.viresh.kumar@linaro.org>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, Viresh Kumar <viresh.kumar@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Matthew Wilcox <willy@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

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
