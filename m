Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75F0A6B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:27:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c20so257662135pfc.2
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:27:11 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id 8si13345081pad.28.2016.04.16.16.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 16:27:10 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id n1so68317775pfn.2
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:27:10 -0700 (PDT)
Date: Sat, 16 Apr 2016 16:27:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm 1/5] huge tmpfs: try to allocate huge pages split into
 a team fix
Message-ID: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Please replace the
huge-tmpfs-try-to-allocate-huge-pages-split-into-a-team-fix.patch
you added to your tree by this one: nothing wrong with Stephen's,
but in this case I think the source is better off if we simply
remove that BUILD_BUG() instead of adding an IS_ENABLED():
fixes build problem seen on arm when putting together linux-next.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |    1 -
 1 file changed, 1 deletion(-)

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1744,7 +1744,6 @@ static inline struct page *shmem_hugetea
 
 static inline void shmem_disband_hugeteam(struct page *page)
 {
-	BUILD_BUG();
 }
 
 static inline void shmem_added_to_hugeteam(struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
