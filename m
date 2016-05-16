Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 909046B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 11:25:26 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k5so372488979qkd.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 08:25:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n78si23426781qgn.65.2016.05.16.08.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 08:25:25 -0700 (PDT)
Date: Mon, 16 May 2016 17:25:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/1] userfaultfd: don't pin the user memory in
 userfaultfd_file_create()
Message-ID: <20160516152522.GA19120@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Sorry for delay. So this is the same patch, just I added the helpers for get/put
mm->mm_users. I won't mind to change userfaultfd_get_mm() to return mm_struct-or-
NULL, or perhaps instead we should simply add the trivial helper which does
atomic_inc_not_zero(mm->mm_users) into sched.h, it can have more callers (fs/proc,
uprobes).

Testing. I have found selftests/vm/userfaultfd.c and it seems to work.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
