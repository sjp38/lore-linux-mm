Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBE06B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:02:56 -0400 (EDT)
Received: by qgt47 with SMTP id 47so153271879qgt.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:02:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y45si18393725qgd.42.2015.09.15.13.02.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 13:02:55 -0700 (PDT)
Date: Tue, 15 Sep 2015 13:02:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12/12] userfaultfd: register uapi generic syscall
 (aarch64)
Message-Id: <20150915130253.c1a0fbbab9ce93b38a2bfd43@linux-foundation.org>
In-Reply-To: <1441745010-14314-13-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
	<1441745010-14314-13-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

On Tue,  8 Sep 2015 22:43:30 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> 
> Add the userfaultfd syscalls to uapi asm-generic, it was tested with
> postcopy live migration on aarch64 with both 4k and 64k pagesize kernels.
> 
> ...
>
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -709,9 +709,11 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
>  __SYSCALL(__NR_bpf, sys_bpf)
>  #define __NR_execveat 281
>  __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
> +#define __NR_userfaultfd 282
> +__SYSCALL(__NR_userfaultfd, sys_userfaultfd)
>  
>  #undef __NR_syscalls
> -#define __NR_syscalls 282
> +#define __NR_syscalls 283

sys_membarrier got there first.  Does this version look OK?

From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: userfaultfd: register uapi generic syscall (aarch64)

Add the userfaultfd syscalls to uapi asm-generic, it was tested with
postcopy live migration on aarch64 with both 4k and 64k pagesize kernels.

Signed-off-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/uapi/asm-generic/unistd.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff -puN include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64 include/uapi/asm-generic/unistd.h
--- a/include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64
+++ a/include/uapi/asm-generic/unistd.h
@@ -709,17 +709,19 @@ __SYSCALL(__NR_memfd_create, sys_memfd_c
 __SYSCALL(__NR_bpf, sys_bpf)
 #define __NR_execveat 281
 __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
-#define __NR_membarrier 282
+#define __NR_userfaultfd 282
+__SYSCALL(__NR_userfaultfd, sys_userfaultfd)
+#define __NR_membarrier 283
 __SYSCALL(__NR_membarrier, sys_membarrier)
 
 #undef __NR_syscalls
-#define __NR_syscalls 283
+#define __NR_syscalls 284
 
 /*
  * All syscalls below here should go away really,
  * these are provided for both review and as a porting
  * help for the C library version.
-*
+ *
  * Last chance: are any of these important enough to
  * enable by default?
  */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
