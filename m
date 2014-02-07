Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB7D6B0037
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:04:25 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so3157173pbc.16
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:04:25 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id gx4si4793312pbc.291.2014.02.07.04.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:04:23 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so3101325pad.11
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:04:23 -0800 (PST)
Date: Fri, 7 Feb 2014 17:34:18 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 3/9] mm: Mark function as static in mmap.c
Message-ID: <a2b21fa8852f0ee5c8da179240142e5f084154e9.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org

Mark function as static in mmap.c because they are not used outside this
file.

This eliminates the following warning in mm/mmap.c:
mm/mmap.c:407:6: warning: no previous prototype for a??validate_mma?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 834b2d7..4a03790 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -404,7 +404,7 @@ static void validate_mm_rb(struct rb_root *root, struct vm_area_struct *ignore)
 	}
 }
 
-void validate_mm(struct mm_struct *mm)
+static void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
