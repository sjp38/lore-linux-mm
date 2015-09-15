Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id A8DF66B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:47:20 -0400 (EDT)
Received: by qgt47 with SMTP id 47so154408384qgt.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:47:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a33si18579063qga.123.2015.09.15.13.47.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 13:47:20 -0700 (PDT)
Date: Tue, 15 Sep 2015 22:47:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 12/12] userfaultfd: register uapi generic syscall
 (aarch64)
Message-ID: <20150915204715.GB29064@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
 <1441745010-14314-13-git-send-email-aarcange@redhat.com>
 <20150915130253.c1a0fbbab9ce93b38a2bfd43@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915130253.c1a0fbbab9ce93b38a2bfd43@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Michael Ellerman <mpe@ellerman.id.au>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

On Tue, Sep 15, 2015 at 01:02:53PM -0700, Andrew Morton wrote:
> sys_membarrier got there first.  Does this version look OK?

Yes, but it's up to you.

While rebasing my tree on latest upstream I actually moved userfaultfd
to 283 here, as membarrier was already upstream at 282.

It makes no difference to me if userfaultfd gets 283 if you prefer to
leave 282 to membarrier considering it's already upstream. The
selftest will pick whatever number it gets with "make headers_install"
so it wouldn't require updates.

Thanks,
Andrea

> 
> From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
> Subject: userfaultfd: register uapi generic syscall (aarch64)
> 
> Add the userfaultfd syscalls to uapi asm-generic, it was tested with
> postcopy live migration on aarch64 with both 4k and 64k pagesize kernels.

> 
> Signed-off-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/uapi/asm-generic/unistd.h |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff -puN include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64 include/uapi/asm-generic/unistd.h
> --- a/include/uapi/asm-generic/unistd.h~userfaultfd-register-uapi-generic-syscall-aarch64
> +++ a/include/uapi/asm-generic/unistd.h
> @@ -709,17 +709,19 @@ __SYSCALL(__NR_memfd_create, sys_memfd_c
>  __SYSCALL(__NR_bpf, sys_bpf)
>  #define __NR_execveat 281
>  __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
> -#define __NR_membarrier 282
> +#define __NR_userfaultfd 282
> +__SYSCALL(__NR_userfaultfd, sys_userfaultfd)
> +#define __NR_membarrier 283
>  __SYSCALL(__NR_membarrier, sys_membarrier)
>  
>  #undef __NR_syscalls
> -#define __NR_syscalls 283
> +#define __NR_syscalls 284
>  
>  /*
>   * All syscalls below here should go away really,
>   * these are provided for both review and as a porting
>   * help for the C library version.
> -*
> + *
>   * Last chance: are any of these important enough to
>   * enable by default?
>   */
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
