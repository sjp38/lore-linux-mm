Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAC66B0271
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:47:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so34051151wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:47:14 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id n188si279554wmf.30.2016.06.13.12.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:47:13 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n184so17322330wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:47:13 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 10/18] limits: track RLIMIT_STACK actual max
Date: Mon, 13 Jun 2016 22:44:17 +0300
Message-Id: <1465847065-3577-11-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum stack size, presented in /proc/self/limits.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 mm/mmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 61867de..0963e7f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2019,6 +2019,8 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	if (security_vm_enough_memory_mm(mm, grow))
 		return -ENOMEM;
 
+	bump_rlimit(RLIMIT_STACK, actual_size);
+
 	return 0;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
