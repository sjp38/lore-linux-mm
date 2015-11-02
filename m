Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9644A82F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 19:08:32 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so4889058pab.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 16:08:32 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id qp7si30277864pbc.93.2015.11.01.16.08.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 16:08:31 -0800 (PST)
Received: by pasz6 with SMTP id z6so128904702pas.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 16:08:31 -0800 (PST)
Date: Sun, 1 Nov 2015 16:08:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/8] arch: uapi: asm: mman.h: Let MADV_FREE have same
 value for all architectures
In-Reply-To: <1446188504-28023-4-git-send-email-minchan@kernel.org>
Message-ID: <alpine.LSU.2.11.1511011542030.11427@eggly.anvils>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org> <1446188504-28023-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Miller <davem@davemloft.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, Roland Dreier <roland@kernel.org>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, Chen Gang <gang.chen.5i5j@gmail.com>, "rth@twiddle.net" <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, "jejb@parisc-linux.org" <jejb@parisc-linux.org>, "deller@gmx.de" <deller@gmx.de>, "chris@zankel.net" <chris@zankel.net>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Fri, 30 Oct 2015, Minchan Kim wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> For uapi, need try to let all macros have same value, and MADV_FREE is
> added into main branch recently, so need redefine MADV_FREE for it.
> 
> At present, '8' can be shared with all architectures, so redefine it to
> '8'.
> 
> Cc: rth@twiddle.net <rth@twiddle.net>,
> Cc: ink@jurassic.park.msu.ru <ink@jurassic.park.msu.ru>
> Cc: mattst88@gmail.com <mattst88@gmail.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: jejb@parisc-linux.org <jejb@parisc-linux.org>
> Cc: deller@gmx.de <deller@gmx.de>
> Cc: chris@zankel.net <chris@zankel.net>
> Cc: jcmvbkbc@gmail.com <jcmvbkbc@gmail.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-arch@vger.kernel.org
> Cc: linux-api@vger.kernel.org
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Let me add
Acked-by: Hugh Dickins <hughd@google.com>
to this one too.

But I have extended your mail's Cc list: Darrick pointed out earlier
that dietlibc has a Solaris #define MADV_FREE 0x5 in its mman.h,
and that was in the kernel's sparc mman.h up until 2.6.25.  I doubt
that presents any obstacle nowadays, but Dave Miller should be Cc'ed.

I was a little suspicious that 8 is available for MADV_FREE: why did
the common/generic parameters start at 9 instead of 8 back in 2.6.16?
I think the answer is that we had MADV_REMOVE coming in from one
direction, and MADV_DONTFORK coming from another direction, and when
Roland looked for where to start the commons for MADV_DONTFORK, it
appeared that 8 was occupied - by MADV_REMOVE; then a little later
MADV_REMOVE was shifted to become the first of the commons, at 9.

Hugh

> ---
>  arch/alpha/include/uapi/asm/mman.h     | 2 +-
>  arch/mips/include/uapi/asm/mman.h      | 2 +-
>  arch/parisc/include/uapi/asm/mman.h    | 2 +-
>  arch/xtensa/include/uapi/asm/mman.h    | 2 +-
>  include/uapi/asm-generic/mman-common.h | 2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
> index 836fbd44f65b..0b8a5de7aee3 100644
> --- a/arch/alpha/include/uapi/asm/mman.h
> +++ b/arch/alpha/include/uapi/asm/mman.h
> @@ -44,9 +44,9 @@
>  #define MADV_WILLNEED	3		/* will need these pages */
>  #define	MADV_SPACEAVAIL	5		/* ensure resources are available */
>  #define MADV_DONTNEED	6		/* don't need these pages */
> -#define MADV_FREE	7		/* free pages only if memory pressure */
>  
>  /* common/generic parameters */
> +#define MADV_FREE	8		/* free pages only if memory pressure */
>  #define MADV_REMOVE	9		/* remove these pages & resources */
>  #define MADV_DONTFORK	10		/* don't inherit across fork */
>  #define MADV_DOFORK	11		/* do inherit across fork */
> diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
> index 106e741aa7ee..d247f5457944 100644
> --- a/arch/mips/include/uapi/asm/mman.h
> +++ b/arch/mips/include/uapi/asm/mman.h
> @@ -67,9 +67,9 @@
>  #define MADV_SEQUENTIAL 2		/* expect sequential page references */
>  #define MADV_WILLNEED	3		/* will need these pages */
>  #define MADV_DONTNEED	4		/* don't need these pages */
> -#define MADV_FREE	5		/* free pages only if memory pressure */
>  
>  /* common parameters: try to keep these consistent across architectures */
> +#define MADV_FREE	8		/* free pages only if memory pressure */
>  #define MADV_REMOVE	9		/* remove these pages & resources */
>  #define MADV_DONTFORK	10		/* don't inherit across fork */
>  #define MADV_DOFORK	11		/* do inherit across fork */
> diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
> index 6cb8db76fd4e..700d83fd9352 100644
> --- a/arch/parisc/include/uapi/asm/mman.h
> +++ b/arch/parisc/include/uapi/asm/mman.h
> @@ -40,9 +40,9 @@
>  #define MADV_SPACEAVAIL 5               /* insure that resources are reserved */
>  #define MADV_VPS_PURGE  6               /* Purge pages from VM page cache */
>  #define MADV_VPS_INHERIT 7              /* Inherit parents page size */
> -#define MADV_FREE	8		/* free pages only if memory pressure */
>  
>  /* common/generic parameters */
> +#define MADV_FREE	8		/* free pages only if memory pressure */
>  #define MADV_REMOVE	9		/* remove these pages & resources */
>  #define MADV_DONTFORK	10		/* don't inherit across fork */
>  #define MADV_DOFORK	11		/* do inherit across fork */
> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index 1b19f25bc567..77eaca434071 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -80,9 +80,9 @@
>  #define MADV_SEQUENTIAL	2		/* expect sequential page references */
>  #define MADV_WILLNEED	3		/* will need these pages */
>  #define MADV_DONTNEED	4		/* don't need these pages */
> -#define MADV_FREE	5		/* free pages only if memory pressure */
>  
>  /* common parameters: try to keep these consistent across architectures */
> +#define MADV_FREE	8		/* free pages only if memory pressure */
>  #define MADV_REMOVE	9		/* remove these pages & resources */
>  #define MADV_DONTFORK	10		/* don't inherit across fork */
>  #define MADV_DOFORK	11		/* do inherit across fork */
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index 7a94102b7a02..869595947873 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -34,9 +34,9 @@
>  #define MADV_SEQUENTIAL	2		/* expect sequential page references */
>  #define MADV_WILLNEED	3		/* will need these pages */
>  #define MADV_DONTNEED	4		/* don't need these pages */
> -#define MADV_FREE	5		/* free pages only if memory pressure */
>  
>  /* common parameters: try to keep these consistent across architectures */
> +#define MADV_FREE	8		/* free pages only if memory pressure */
>  #define MADV_REMOVE	9		/* remove these pages & resources */
>  #define MADV_DONTFORK	10		/* don't inherit across fork */
>  #define MADV_DOFORK	11		/* do inherit across fork */
> -- 
> 1.9.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
