Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 448416B0258
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 17:58:05 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id g73so36552439ioe.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:58:05 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x27si14500341ioi.119.2016.01.27.14.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 14:58:04 -0800 (PST)
Date: Thu, 28 Jan 2016 09:57:59 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2016-01-27-14-04 uploaded
Message-ID: <20160128095759.44af98f5@canb.auug.org.au>
In-Reply-To: <56a93efb.wTNmPJ0+jR+bz7eT%akpm@linux-foundation.org>
References: <56a93efb.wTNmPJ0+jR+bz7eT%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org

Hi Andrew,

On Wed, 27 Jan 2016 14:04:43 -0800 akpm@linux-foundation.org wrote:
>
> * compat-add-in_compat_syscall-to-ask-whether-were-in-a-compat-syscall.patch
> * sparc-compat-provide-an-accurate-in_compat_syscall-implementation.patch
> * sparc-compat-provide-an-accurate-in_compat_syscall-implementation-fix.patch
> * sparc-syscall-fix-syscall_get_arch.patch
> * seccomp-check-in_compat_syscall-not-is_compat_task-in-strict-mode.patch
> * ptrace-in-peek_siginfo-check-syscall-bitness-not-task-bitness.patch
> * auditsc-for-seccomp-events-log-syscall-compat-state-using-in_compat_syscall.patch
> * staging-lustre-switch-from-is_compat_task-to-in_compat_syscall.patch
> * ext4-in-ext4_dir_llseek-check-syscall-bitness-directly.patch
> * net-sctp-use-in_compat_syscall-for-sctp_getsockopt_connectx3.patch
> * net-xfrm_user-use-in_compat_syscall-to-deny-compat-syscalls.patch
> * firewire-use-in_compat_syscall-to-check-ioctl-compatness.patch
> * efivars-use-in_compat_syscall-to-check-for-compat-callers.patch
> * amdkfd-use-in_compat_syscall-to-check-open-caller-type.patch
> * input-redefine-input_compat_test-as-in_compat_syscall.patch
> * uhid-check-write-bitness-using-in_compat_syscall.patch
> * x86-compat-remove-is_compat_task.patch

> * compat-add-in_compat_syscall-to-ask-whether-were-in-a-compat-syscall.patch
> * sparc-compat-provide-an-accurate-in_compat_syscall-implementation.patch
> * sparc-compat-provide-an-accurate-in_compat_syscall-implementation-fix.patch
> * sparc-syscall-fix-syscall_get_arch.patch
> * seccomp-check-in_compat_syscall-not-is_compat_task-in-strict-mode.patch
> * ptrace-in-peek_siginfo-check-syscall-bitness-not-task-bitness.patch
> * auditsc-for-seccomp-events-log-syscall-compat-state-using-in_compat_syscall.patch
> * staging-lustre-switch-from-is_compat_task-to-in_compat_syscall.patch
> * ext4-in-ext4_dir_llseek-check-syscall-bitness-directly.patch
> * net-sctp-use-in_compat_syscall-for-sctp_getsockopt_connectx3.patch
> * net-xfrm_user-use-in_compat_syscall-to-deny-compat-syscalls.patch
> * firewire-use-in_compat_syscall-to-check-ioctl-compatness.patch
> * efivars-use-in_compat_syscall-to-check-for-compat-callers.patch
> * amdkfd-use-in_compat_syscall-to-check-open-caller-type.patch
> * input-redefine-input_compat_test-as-in_compat_syscall.patch
> * uhid-check-write-bitness-using-in_compat_syscall.patch
> * x86-compat-remove-is_compat_task.patch

Note that the above patches appear twice in the series file.  I just
applied the first ones :-)
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
