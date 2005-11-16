Date: Wed, 16 Nov 2005 23:00:13 +0000
Subject: [PATCH 2/3] pfn_to_pgdat not used in common code
Message-ID: <20051116230013.GA16480@shadowen.org>
References: <exportbomb.1132181992@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pfn_to_pgdat not used in common code

pfn_to_pgdat() isn't used in common code.  Remove definition.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mmzone.h |    5 -----
 1 file changed, 5 deletions(-)
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -607,11 +607,6 @@ static inline int pfn_valid(unsigned lon
 #define pfn_to_nid		early_pfn_to_nid
 #endif
 
-#define pfn_to_pgdat(pfn)						\
-({									\
-	NODE_DATA(pfn_to_nid(pfn));					\
-})
-
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
 void sparse_init(void);
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
