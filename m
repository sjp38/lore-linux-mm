Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C58A56B0259
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 22:49:00 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so141990965pac.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 19:49:00 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id t5si8832282pbs.119.2015.09.08.19.48.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 19:48:59 -0700 (PDT)
Message-ID: <1441766935.7854.11.camel@ellerman.id.au>
Subject: Re: [PATCH 10/12] userfaultfd: powerpc: Bump up __NR_syscalls to
 account for __NR_userfaultfd
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 09 Sep 2015 12:48:55 +1000
In-Reply-To: <1441745010-14314-11-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
	 <1441745010-14314-11-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David
 Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On Tue, 2015-09-08 at 22:43 +0200, Andrea Arcangeli wrote:
> From: Bharata B Rao <bharata@linux.vnet.ibm.com>
> 
> With userfaultfd syscall, the number of syscalls will be 365 on PowerPC.
> Reflect the same in __NR_syscalls.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.vnet.ibm.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  arch/powerpc/include/asm/unistd.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
> index f4f8b66..4a055b6 100644
> --- a/arch/powerpc/include/asm/unistd.h
> +++ b/arch/powerpc/include/asm/unistd.h
> @@ -12,7 +12,7 @@
>  #include <uapi/asm/unistd.h>
>  
> 
> -#define __NR_syscalls		364
> +#define __NR_syscalls		365

I guess technically it's OK for this to get bumped first, but we typically do
it in a single patch with the addition of the syscall number.

I'd rather do the syscall addition via my tree.

cheers



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
