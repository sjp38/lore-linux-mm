Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Peng Hao <penghao122@sina.com.cn>
Subject: [PATCH] mm/sparse: remove a check that compare if unsigned variable is negative
Date: Sat, 13 Oct 2018 12:15:19 -0400
Message-Id: <1539447319-5383-1-git-send-email-penghao122@sina.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, osalvador@suse.de, linux-kernel@vger.kernel.org, Peng Hao <peng.hao2@zte.com.cn>
List-ID: <linux-mm.kvack.org>


From: Peng Hao <peng.hao2@zte.com.cn>

In all use locations for for_each_present_section_nr, variable
section_nr is unsigned. It is unnecessary to test if it is negative.

Signed-off-by: Peng Hao <peng.hao2@zte.com.cn>
---
 mm/sparse.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07ee..a6f9f22 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -196,8 +196,7 @@ static inline int next_present_section_nr(int section_nr)
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
-	     ((section_nr >= 0) &&				\
-	      (section_nr <= __highest_present_section_nr));	\
+	     section_nr <= __highest_present_section_nr;	\
 	     section_nr = next_present_section_nr(section_nr))
 
 static inline unsigned long first_present_section_nr(void)
-- 
1.8.3.1
