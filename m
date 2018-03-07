Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBEC6B0008
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 12:30:38 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j21so1652662wre.20
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 09:30:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h30si14267775wrh.247.2018.03.07.09.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 09:30:36 -0800 (PST)
Date: Wed, 7 Mar 2018 09:30:36 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] x86/mm: Give each mm a unique ID
Message-ID: <20180307173036.GJ7097@kroah.com>
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
 <3351ba53a3b570ba08f2a0f5a59d01b7d80a8955.1520026221.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3351ba53a3b570ba08f2a0f5a59d01b7d80a8955.1520026221.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 02, 2018 at 01:32:09PM -0800, Tim Chen wrote:
> From: Andy Lutomirski <luto@kernel.org>
> commit: f39681ed0f48498b80455095376f11535feea332
> 
> This adds a new variable to mmu_context_t: ctx_id.
> ctx_id uniquely identifies the mm_struct and will never be reused.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: linux-mm@kvack.org
> Link: http://lkml.kernel.org/r/413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  arch/x86/include/asm/mmu.h         | 15 +++++++++++++--
>  arch/x86/include/asm/mmu_context.h |  5 +++++
>  arch/x86/mm/tlb.c                  |  2 ++
>  3 files changed, 20 insertions(+), 2 deletions(-)
> 

Does not apply to 4.4.y :(

Can you provide a working backport for that tree?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
