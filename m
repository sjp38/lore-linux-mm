Received: by ag-out-0708.google.com with SMTP id 31so131690aga
        for <linux-mm@kvack.org>; Thu, 15 Nov 2007 05:56:49 -0800 (PST)
Date: Thu, 15 Nov 2007 21:54:28 +0800
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: [Patch] mm/sparse.c: Check the return value of
	sparse_index_alloc().
Message-ID: <20071115135428.GE2489@hacking>
Reply-To: WANG Cong <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Since sparse_index_alloc() can return NULL on memory allocation failure,
we must deal with the failure condition when calling it.

Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>

---

diff --git a/Makefile b/Makefile
diff --git a/mm/sparse.c b/mm/sparse.c
index e06f514..d245e59 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -83,6 +83,8 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 		return -EEXIST;
 
 	section = sparse_index_alloc(nid);
+	if (!section)
+		return -ENOMEM;
 	/*
 	 * This lock keeps two different sections from
 	 * reallocating for the same index

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
