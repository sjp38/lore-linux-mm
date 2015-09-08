Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 980FC6B025D
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 16:43:51 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so48759178pad.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 13:43:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si7458286pap.165.2015.09.08.13.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 13:43:37 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 11/12] userfaultfd: powerpc: implement syscall
Date: Tue,  8 Sep 2015 22:43:29 +0200
Message-Id: <1441745010-14314-12-git-send-email-aarcange@redhat.com>
In-Reply-To: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

Add userfaultfd to powerpc.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/include/asm/systbl.h      | 1 +
 arch/powerpc/include/uapi/asm/unistd.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 71f2b3f..4d65499 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -368,3 +368,4 @@ SYSCALL_SPU(memfd_create)
 SYSCALL_SPU(bpf)
 COMPAT_SYS(execveat)
 PPC64ONLY(switch_endian)
+SYSCALL_SPU(userfaultfd)
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index e4aa173..6ad58d4 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -386,5 +386,6 @@
 #define __NR_bpf		361
 #define __NR_execveat		362
 #define __NR_switch_endian	363
+#define __NR_userfaultfd	364
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
