Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 647066B03C7
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:24:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so4919464wry.4
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 02:24:24 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id z192si3495058wme.173.2017.06.23.02.24.22
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 02:24:23 -0700 (PDT)
Date: Fri, 23 Jun 2017 11:24:03 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 08/11] x86/mm: Disable PCID on 32-bit kernels
Message-ID: <20170623092403.qytmaokmhve5b6k4@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <d817b0638d5225c7ee5560f86e0b216dd9f76e9a.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <d817b0638d5225c7ee5560f86e0b216dd9f76e9a.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:14PM -0700, Andy Lutomirski wrote:
> 32-bit kernels on new hardware will see PCID in CPUID, but PCID can
> only be used in 64-bit mode.  Rather than making all PCID code
> conditional, just disable the feature on 32-bit builds.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/disabled-features.h | 4 +++-
>  arch/x86/kernel/cpu/bugs.c               | 8 ++++++++
>  2 files changed, 11 insertions(+), 1 deletion(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
