Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98D036B0260
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 19:25:09 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u126so13078435oif.23
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 16:25:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j68si7584777otj.478.2017.12.22.16.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 16:25:08 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] Re: kernel BUG at fs/userfaultfd.c:LINE!
Date: Sat, 23 Dec 2017 01:25:04 +0100
Message-Id: <20171223002505.593-1-aarcange@redhat.com>
In-Reply-To: <20171222222346.GB28786@zzz.localdomain>
References: <20171222222346.GB28786@zzz.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

Hello,

Thanks for the CC, I'm temporarily very busy so if there's something
urgent, safer to CC.

This passed both testcases, the hard part was already done. I'm glad
there was nothing wrong in the previous fix that had to be redone.

Simply we forgot to undo the vma->vm_userfaultfd_ctx = NULL after
aborting the new child uffd ctx, the original code of course didn't do
that either.

Having just seen this issue, this isn't very well tested.

Thank you,
Andrea

Andrea Arcangeli (1):
  userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK
    fails

 fs/userfaultfd.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
