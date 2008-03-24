Subject: Re: [PATCH 3/6] compcache: TLSF Allocator interface
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200803242034.24264.nitingupta910@gmail.com>
References: <200803242034.24264.nitingupta910@gmail.com>
Content-Type: text/plain
Date: Mon, 24 Mar 2008 17:56:17 +0100
Message-Id: <1206377777.6437.123.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nitingupta910@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-24 at 20:34 +0530, Nitin Gupta wrote:
> Two Level Segregate Fit (TLSF) Allocator is used to allocate memory for
> variable size compressed pages. Its fast and gives low fragmentation.
> Following links give details on this allocator:
>  - http://rtportal.upv.es/rtmalloc/files/tlsf_paper_spe_2007.pdf
>  - http://code.google.com/p/compcache/wiki/TLSFAllocator
> 
> This kernel port of TLSF (v2.3.2) introduces several changes but underlying
> algorithm remains the same.
> 
> Changelog TLSF v2.3.2 vs this kernel port
>  - Pool now dynamically expands/shrinks.
>    It is collection of contiguous memory regions.
>  - Changes to pool create interface as a result of above change.
>  - Collect and export stats (/proc/tlsfinfo)
>  - Cleanups: kernel coding style, added comments, macros -> static inline, etc.

Can you explain why you need this allocator, why don't the current
kernel allocators work for you?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
