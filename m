Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1648C6B009F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:53:52 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:53:12 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] Fix for hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch
 in -mm
In-Reply-To: <1253011613-6429-1-git-send-email-ebmunson@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0909152146470.25625@sister.anvils>
References: <1252487811-9205-1-git-send-email-ebmunson@us.ibm.com>
 <1253011613-6429-1-git-send-email-ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, Arnd Bergman <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Sep 2009, Eric B Munson wrote:
> Resending because this seems to have fallen between the cracks.

Yes, indeed.  I think it isn't quite what Arnd was suggesting, but I
agree with you that we might as well go for 0x080000 (so that even Alpha
can be just a cut-and-paste job from asm-generic), and right now it's
more important to finalize the number than what file it appears in.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> 
> The patch
> hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch
> used the value 0x40 for MAP_HUGETLB which is the same value used for
> various other flags on some architectures.  This collision causes
> unexpected use of huge pages in the best case and mmap to fail with
> ENOMEM or ENOSYS in the worst.  This patch changes the value for
> MAP_HUGETLB to a value that is not currently used on any arch.
> 
> This patch should be considered a fix to
> hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch.
> 
> Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> ---
>  include/asm-generic/mman-common.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> index 12f5982..e6adb68 100644
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -19,7 +19,7 @@
>  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
>  #define MAP_FIXED	0x10		/* Interpret addr exactly */
>  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> -#define MAP_HUGETLB	0x40		/* create a huge page mapping */
> +#define MAP_HUGETLB	0x080000	/* create a huge page mapping */
>  
>  #define MS_ASYNC	1		/* sync memory asynchronously */
>  #define MS_INVALIDATE	2		/* invalidate the caches */
> -- 
> 1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
