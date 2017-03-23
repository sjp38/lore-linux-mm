Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B58E6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 04:13:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y193so101793444lfd.3
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:13:34 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 18si1370410ljn.144.2017.03.23.01.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 01:13:32 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id v2so15964283lfi.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:13:32 -0700 (PDT)
Subject: [PATCH] mm: fix a coding style issue
References: <20170323074902.23768-1-kristaps.civkulis@gmail.com>
From: Kristaps Civkulis <kristaps.civkulis@gmail.com>
Message-ID: <52c53f8a-ef23-46ce-040b-d63498a7dfa5@gmail.com>
Date: Thu, 23 Mar 2017 10:12:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170323074902.23768-1-kristaps.civkulis@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fix a coding style issue.

Signed-off-by: Kristaps Civkulis <kristaps.civkulis@gmail.com>
---
Resend, because it should be only [PATCH] in subject.
---
  mm/hugetlb.c | 3 +--
  1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3d0aab9ee80d..4c72c1974c8c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1916,8 +1916,7 @@ static long __vma_reservation_common(struct hstate *h,
  			return 0;
  		else
  			return 1;
-	}
-	else
+	} else
  		return ret < 0 ? ret : 0;
  }

-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
