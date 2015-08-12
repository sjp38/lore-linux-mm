Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 972C76B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:46:01 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so20023830wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:46:01 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id u2si9566189wjz.147.2015.08.12.02.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 02:46:00 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so210686459wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:45:59 -0700 (PDT)
Date: Wed, 12 Aug 2015 11:45:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/6] mm: mlock: Add new mlock system call
Message-ID: <20150812094558.GD14940@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-3-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439097776-27695-3-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, Andrea Arcangeli <aarcange@redhat.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun 09-08-15 01:22:52, Eric B Munson wrote:
> With the refactored mlock code, introduce a new system call for mlock.
> The new call will allow the user to specify what lock states are being
> added.  mlock2 is trivial at the moment, but a follow on patch will add
> a new mlock state making it useful.

Looks good to me

Acked-by: Michal Hocko <mhocko@suse.com>

> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: adi-buildroot-devel@lists.sourceforge.net
> Cc: linux-cris-kernel@axis.com
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-m68k@lists.linux-m68k.org
> Cc: linux-am33-list@redhat.com
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux-api@vger.kernel.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl | 1 +
>  arch/x86/entry/syscalls/syscall_64.tbl | 1 +
>  include/linux/syscalls.h               | 2 ++
>  include/uapi/asm-generic/unistd.h      | 4 +++-
>  kernel/sys_ni.c                        | 1 +
>  mm/mlock.c                             | 8 ++++++++
>  6 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index ef8187f..8e06da6 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -365,3 +365,4 @@
>  356	i386	memfd_create		sys_memfd_create
>  357	i386	bpf			sys_bpf
>  358	i386	execveat		sys_execveat			stub32_execveat
> +360	i386	mlock2			sys_mlock2
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 9ef32d5..67601e7 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -329,6 +329,7 @@
>  320	common	kexec_file_load		sys_kexec_file_load
>  321	common	bpf			sys_bpf
>  322	64	execveat		stub_execveat
> +324	common	mlock2			sys_mlock2
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index b45c45b..56a3d59 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -884,4 +884,6 @@ asmlinkage long sys_execveat(int dfd, const char __user *filename,
>  			const char __user *const __user *argv,
>  			const char __user *const __user *envp, int flags);
>  
> +asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
> +
>  #endif
> diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
> index e016bd9..14a6013 100644
> --- a/include/uapi/asm-generic/unistd.h
> +++ b/include/uapi/asm-generic/unistd.h
> @@ -709,9 +709,11 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
>  __SYSCALL(__NR_bpf, sys_bpf)
>  #define __NR_execveat 281
>  __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
> +#define __NR_mlock2 282
> +__SYSCALL(__NR_mlock2, sys_mlock2)
>  
>  #undef __NR_syscalls
> -#define __NR_syscalls 282
> +#define __NR_syscalls 283
>  
>  /*
>   * All syscalls below here should go away really,
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 7995ef5..4818b71 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -193,6 +193,7 @@ cond_syscall(sys_mlock);
>  cond_syscall(sys_munlock);
>  cond_syscall(sys_mlockall);
>  cond_syscall(sys_munlockall);
> +cond_syscall(sys_mlock2);
>  cond_syscall(sys_mincore);
>  cond_syscall(sys_madvise);
>  cond_syscall(sys_mremap);
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 5692ee5..3094f27 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -643,6 +643,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  	return do_mlock(start, len, VM_LOCKED);
>  }
>  
> +SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
> +{
> +	if (flags)
> +		return -EINVAL;
> +
> +	return do_mlock(start, len, VM_LOCKED);
> +}
> +
>  SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  {
>  	int ret;
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
