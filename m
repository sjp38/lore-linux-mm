Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4235E6B7C54
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 16:20:33 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c7so1587359qkg.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 13:20:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w20si957827qts.23.2018.12.06.13.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 13:20:32 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] userfaultfd: check VM_MAYWRITE was set after verifying the uffd is registered
Date: Thu,  6 Dec 2018 16:20:27 -0500
Message-Id: <20181206212028.18726-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Jann Horn <jannh@google.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

Hello,

The juxtaposition with the other bugchecks didn't make it apparent
that the this WARN_ON was one line too soon.

An app trying to unregister a not-yet-registered range will trigger an
_harmless_ false positive WARN_ON. No real app would do that so it
went unnoticed during testing.

This should be applied on top of 29ec90660d68 ("userfaultfd:
shmem/hugetlbfs: only allow to register VM_MAYWRITE vmas") to shut off
the false positive warning.

Thanks,
Andrea

Andrea Arcangeli (1):
  userfaultfd: check VM_MAYWRITE was set after verifying the uffd is
    registered

 fs/userfaultfd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
