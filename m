Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52A466B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 20:14:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m78so1719200wma.7
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 17:14:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 46si1262863wrx.458.2018.03.09.17.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 17:14:40 -0800 (PST)
Date: Fri, 9 Mar 2018 17:14:35 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] x86/mm: Give each mm a unique ID
Message-ID: <20180310011435.GA27284@kroah.com>
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
 <3351ba53a3b570ba08f2a0f5a59d01b7d80a8955.1520026221.git.tim.c.chen@linux.intel.com>
 <20180307173036.GJ7097@kroah.com>
 <9b0d1195-23bd-5bf9-0dd8-b2ca29165bbb@linux.intel.com>
 <8322b21f-5ee7-41a6-7897-d73faa0ece27@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8322b21f-5ee7-41a6-7897-d73faa0ece27@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 09, 2018 at 05:04:39PM -0800, Tim Chen wrote:
> On 03/08/2018 10:23 AM, Tim Chen wrote:
> > On 03/07/2018 09:30 AM, Greg Kroah-Hartman wrote:
> >> On Fri, Mar 02, 2018 at 01:32:09PM -0800, Tim Chen wrote:
> >>> From: Andy Lutomirski <luto@kernel.org>
> >>> commit: f39681ed0f48498b80455095376f11535feea332
> >>>
> >>> This adds a new variable to mmu_context_t: ctx_id.
> >>> ctx_id uniquely identifies the mm_struct and will never be reused.
> >>>
> >>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> >>> Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
> >>> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> >>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Cc: Arjan van de Ven <arjan@linux.intel.com>
> >>> Cc: Borislav Petkov <bp@alien8.de>
> >>> Cc: Dave Hansen <dave.hansen@intel.com>
> >>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> >>> Cc: Mel Gorman <mgorman@suse.de>
> >>> Cc: Peter Zijlstra <peterz@infradead.org>
> >>> Cc: Rik van Riel <riel@redhat.com>
> >>> Cc: linux-mm@kvack.org
> >>> Link: http://lkml.kernel.org/r/413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org
> >>> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> >>> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> >>> ---
> >>>  arch/x86/include/asm/mmu.h         | 15 +++++++++++++--
> >>>  arch/x86/include/asm/mmu_context.h |  5 +++++
> >>>  arch/x86/mm/tlb.c                  |  2 ++
> >>>  3 files changed, 20 insertions(+), 2 deletions(-)
> >>>
> >>
> >> Does not apply to 4.4.y :(
> >>
> >> Can you provide a working backport for that tree?
> >>
> > 
> > Okay. Will do.  Thanks.
> > 
> 
> 
> Greg,
> 
> I actually found that there are a number of dependent IBPB related patches that haven't been
> backported yet to 4.4:
> 
>     x86/cpufeatures: Add AMD feature bits for Speculation Control
>     (cherry picked from commit 5d10cbc91d9eb5537998b65608441b592eec65e7)
> 
>     x86/msr: Add definitions for new speculation control MSRs
>     (cherry picked from commit 1e340c60d0dd3ae07b5bedc16a0469c14b9f3410)
> 
>     x86/speculation: Add basic IBPB (Indirect Branch Prediction Barrier) support
>     (cherry picked from commit 20ffa1caecca4db8f79fe665acdeaa5af815a24d)
> 
>     x86/cpufeatures: Clean up Spectre v2 related CPUID flags
>     (cherry picked from commit 2961298efe1ea1b6fc0d7ee8b76018fa6c0bcef2)
> 
> And probably and a few more.
> You have plans to backport these patches?

I don't, but I think someone from Amazon was looking into it, but I
haven't heard from them in a few weeks.  I'll gladly take patches if you
have them, or at the worse case, a list like above of the git commits
that are missing.

thanks,

greg k-h
