Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A0E436B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 23:10:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z55so9358792wrz.2
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 20:10:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y204sor884914wmg.61.2017.10.22.20.10.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Oct 2017 20:10:15 -0700 (PDT)
Date: Mon, 23 Oct 2017 12:10:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Message-ID: <20171023031005.GA5981@bgram>
References: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
 <20171020195934.32108-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020195934.32108-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri, Oct 20, 2017 at 10:59:31PM +0300, Kirill A. Shutemov wrote:
> With boot-time switching between paging mode we will have variable
> MAX_PHYSMEM_BITS.
> 
> Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
> configuration to define zsmalloc data structures.
> 
> The patch introduces MAX_POSSIBLE_PHYSMEM_BITS to cover such case.
> It also suits well to handle PAE special case.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Nitin:

I think this patch works and it would be best for Kirill to be able to do.
So if you have better idea to clean it up, let's make it as another patch
regardless of this patch series.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
