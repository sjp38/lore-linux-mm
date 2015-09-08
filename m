Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2406B0256
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:40 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so136763057pac.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vz4si7470063pbc.51.2015.09.08.13.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:35 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/12] userfaultfd: selftest: update userfaultfd x86 32bit syscall number
Date: Tue,  8 Sep 2015 22:43:19 +0200
Message-Id: <1441745010-14314-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

It changed as result of linux-next merge of other syscalls.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 0c0b839..76071b1 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -69,7 +69,7 @@
 #ifdef __x86_64__
 #define __NR_userfaultfd 323
 #elif defined(__i386__)
-#define __NR_userfaultfd 359
+#define __NR_userfaultfd 374
 #elif defined(__powewrpc__)
 #define __NR_userfaultfd 364
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
