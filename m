Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5B1C6B03C3
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:08:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u110so10997954wrb.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 02:08:02 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id o3si3577349wmi.82.2017.06.23.02.08.01
        for <linux-mm@kvack.org>;
        Fri, 23 Jun 2017 02:08:01 -0700 (PDT)
Date: Fri, 23 Jun 2017 11:07:47 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 07/11] x86/mm: Stop calling leave_mm() in idle code
Message-ID: <20170623090747.oxomynwmbqx54a3t@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org>
 <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 20, 2017 at 10:22:13PM -0700, Andy Lutomirski wrote:
> Now that lazy TLB suppresses all flush IPIs (as opposed to all but
> the first), there's no need to leave_mm() when going idle.
> 
> This means we can get rid of the rcuidle hack in
> switch_mm_irqs_off() and we can unexport leave_mm().
> 
> This also removes acpi_unlazy_tlb() from the x86 and ia64 headers,
> since it has no callers any more.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/ia64/include/asm/acpi.h  |  2 --
>  arch/x86/include/asm/acpi.h   |  2 --
>  arch/x86/mm/tlb.c             | 19 +++----------------
>  drivers/acpi/processor_idle.c |  2 --
>  drivers/idle/intel_idle.c     |  9 ++++-----
>  5 files changed, 7 insertions(+), 27 deletions(-)

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
