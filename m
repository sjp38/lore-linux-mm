Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 015D36B013B
	for <linux-mm@kvack.org>; Wed, 20 May 2015 15:14:11 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so63061720wgb.3
        for <linux-mm@kvack.org>; Wed, 20 May 2015 12:14:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r1si5511572wic.9.2015.05.20.12.14.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 12:14:09 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] userfaultfd: documentation update
Date: Wed, 20 May 2015 21:13:58 +0200
Message-Id: <1432149239-21760-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1432149239-21760-1-git-send-email-aarcange@redhat.com>
References: <1432149239-21760-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/userfaultfd.txt | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
index 3557edd..70a3c94 100644
--- a/Documentation/vm/userfaultfd.txt
+++ b/Documentation/vm/userfaultfd.txt
@@ -3,8 +3,8 @@
 == Objective ==
 
 Userfaults allow the implementation of on-demand paging from userland
-and more generally they allow userland to take control various memory
-page faults, something otherwise only the kernel code could do.
+and more generally they allow userland to take control of various
+memory page faults, something otherwise only the kernel code could do.
 
 For example userfaults allows a proper and more optimal implementation
 of the PROT_NONE+SIGSEGV trick.
@@ -47,10 +47,10 @@ When first opened the userfaultfd must be enabled invoking the
 UFFDIO_API ioctl specifying a uffdio_api.api value set to UFFD_API (or
 a later API version) which will specify the read/POLLIN protocol
 userland intends to speak on the UFFD and the uffdio_api.features
-userland needs to be enabled. The UFFDIO_API ioctl if successful
-(i.e. if the requested uffdio_api.api is spoken also by the running
-kernel and the requested features are going to be enabled) will return
-into uffdio_api.features and uffdio_api.ioctls two 64bit bitmasks of
+userland requires. The UFFDIO_API ioctl if successful (i.e. if the
+requested uffdio_api.api is spoken also by the running kernel and the
+requested features are going to be enabled) will return into
+uffdio_api.features and uffdio_api.ioctls two 64bit bitmasks of
 respectively all the available features of the read(2) protocol and
 the generic ioctl available.
 
@@ -77,7 +77,9 @@ The primary ioctl to resolve userfaults is UFFDIO_COPY. That
 atomically copies a page into the userfault registered range and wakes
 up the blocked userfaults (unless uffdio_copy.mode &
 UFFDIO_COPY_MODE_DONTWAKE is set). Other ioctl works similarly to
-UFFDIO_COPY.
+UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
+half copied page since it'll keep userfaulting until the copy has
+finished.
 
 == QEMU/KVM ==
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
