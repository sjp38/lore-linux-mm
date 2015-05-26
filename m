Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 693566B0073
	for <linux-mm@kvack.org>; Tue, 26 May 2015 11:34:06 -0400 (EDT)
Received: by qkx62 with SMTP id 62so91974586qkx.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 08:34:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c41si14346656qkh.28.2015.05.26.08.34.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 08:34:05 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] userfaultfdv4.2 update for -mm
Date: Tue, 26 May 2015 17:34:00 +0200
Message-Id: <1432654441-28023-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Oops there was a leftover _irq, now I also checked there's no other
irq leftover, the word "irq" disappeared from the file.

The patch applies at the end but ideally should be moved earlier
(anywhere before the patch that activates the syscall).

Thanks,
Andrea

Andrea Arcangeli (1):
  userfaultfd: cleanup superfluous _irq locking

 fs/userfaultfd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
