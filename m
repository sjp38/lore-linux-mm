Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0CA6B03C9
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:50:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so21265855wrb.14
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:50:21 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id c186si11540161wmd.146.2017.06.21.02.50.13
        for <linux-mm@kvack.org>;
        Wed, 21 Jun 2017 02:50:13 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:50:02 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 03/11] x86/mm: Remove reset_lazy_tlbstate()
Message-ID: <20170621095002.ujtllmhtf44pakiw@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <3acc7ad02a2ec060d2321a1e0f6de1cb90069517.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3acc7ad02a2ec060d2321a1e0f6de1cb90069517.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:09PM -0700, Andy Lutomirski wrote:
> The only call site also calls idle_task_exit(), and idle_task_exit()
> puts us into a clean state by explicitly switching to init_mm.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h | 8 --------
>  arch/x86/kernel/smpboot.c       | 1 -
>  2 files changed, 9 deletions(-)

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
