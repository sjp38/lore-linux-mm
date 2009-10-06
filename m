Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BE806B005A
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 06:52:34 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH][RFC] add MAP_UNLOCKED mmap flag
Date: Tue, 6 Oct 2009 12:49:52 +0200
References: <20091006095111.GG9832@redhat.com>
In-Reply-To: <20091006095111.GG9832@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200910061249.53030.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 06 October 2009, Gleb Natapov wrote:
> If application does mlockall(MCL_FUTURE) it is no longer possible to
> mmap file bigger than main memory or allocate big area of anonymous
> memory. Sometimes it is desirable to lock everything related to program
> execution into memory, but still be able to mmap big file or allocate
> huge amount of memory and allow OS to swap them on demand. MAP_UNLOCKED
> allows to do that.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
> index 32c8bd6..0ab4c74 100644
> --- a/include/asm-generic/mman.h
> +++ b/include/asm-generic/mman.h
> @@ -12,6 +12,7 @@
>  #define MAP_NONBLOCK   0x10000         /* do not block on IO */
>  #define MAP_STACK      0x20000         /* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB    0x40000         /* create a huge page mapping */
> +#define MAP_UNLOKED    0x80000         /* pages are unlocked */
>  
>  #define MCL_CURRENT    1               /* lock all current mappings */
>  #define MCL_FUTURE     2               /* lock all future mappings */

Not all architectures use asm-generic/mman.h, so you have to change
the other architectures separately if you add a flag.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
