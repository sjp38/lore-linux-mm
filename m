Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id B480C6B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 13:15:48 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id o191so6138404vkd.18
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 10:15:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s188si2553620qkh.144.2017.10.04.10.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 10:15:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] userfaultfd: selftest -EEXIST update
Date: Wed,  4 Oct 2017 19:15:40 +0200
Message-Id: <20171004171541.1495-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello,

I was stress testing some backports and with high load, after some
time, the latest version of the selftest showed some false positive in
connection with the uffdio_copy_retry. This seems to fix it while
still exercising -EEXIST in the background transfer once in a while.

Andrea Arcangeli (1):
  userfaultfd: selftest: exercise -EEXIST only in background transfer

 tools/testing/selftests/vm/userfaultfd.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
