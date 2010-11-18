Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C99256B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 06:44:20 -0500 (EST)
Date: Thu, 18 Nov 2010 11:44:04 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04 of 66] define MADV_HUGEPAGE
Message-ID: <20101118114404.GI8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <e31f2c279d68d1c21435.1288798059@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e31f2c279d68d1c21435.1288798059@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On just the subject, I've been hassled before to add information to the
subject on what is being affected. In this case, it would be just mm:
because you are not affecting any subsystem but others might be

mm: migration: something something

On a practical point of view, it means if you sort mmotm's series file,
you can get an approximate breakdown of how many patches affect each
subsystem. No idea if it's required or not but don't be surprised if
someone complains :)

On Wed, Nov 03, 2010 at 04:27:39PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Define MADV_HUGEPAGE.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Otherwise;

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/arch/alpha/include/asm/mman.h b/arch/alpha/include/asm/mman.h
> --- a/arch/alpha/include/asm/mman.h
> +++ b/arch/alpha/include/asm/mman.h
> @@ -53,6 +53,8 @@
>  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/arch/mips/include/asm/mman.h b/arch/mips/include/asm/mman.h
> --- a/arch/mips/include/asm/mman.h
> +++ b/arch/mips/include/asm/mman.h
> @@ -77,6 +77,8 @@
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  #define MADV_HWPOISON    100		/* poison a page for testing */
>  
> +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/arch/parisc/include/asm/mman.h b/arch/parisc/include/asm/mman.h
> --- a/arch/parisc/include/asm/mman.h
> +++ b/arch/parisc/include/asm/mman.h
> @@ -59,6 +59,8 @@
>  #define MADV_MERGEABLE   65		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 66		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	67		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  #define MAP_VARIABLE	0
> diff --git a/arch/xtensa/include/asm/mman.h b/arch/xtensa/include/asm/mman.h
> --- a/arch/xtensa/include/asm/mman.h
> +++ b/arch/xtensa/include/asm/mman.h
> @@ -83,6 +83,8 @@
>  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
> --- a/include/asm-generic/mman-common.h
> +++ b/include/asm-generic/mman-common.h
> @@ -45,6 +45,8 @@
>  #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
>  #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
>  
> +#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
> +
>  /* compatibility flags */
>  #define MAP_FILE	0
>  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
