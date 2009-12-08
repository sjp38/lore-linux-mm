Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B955560021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 19:39:10 -0500 (EST)
Message-ID: <4B1DA06A.1050004@kernel.org>
Date: Tue, 08 Dec 2009 09:40:10 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 12/08/2009 08:35 AM, Andrew Morton wrote:
> arch/m68k/include/asm/pgtable_mm.h does the same thing.  Did it break too?

Oh... m64k does the same thing.  I think the correct thing to do here
would be to convert arch code as in ia64.  I think defining
VMALLOC_END to vmalloc_end is a bit error-prone.  If it were defined
simply as vmalloc_end, it's unnoticeable by both the compiler and
developer.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
