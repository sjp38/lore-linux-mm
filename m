Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA6D76B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:33:30 -0400 (EDT)
Date: Tue, 7 Jun 2011 13:33:27 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Dirty page tracking for physical system migration
Message-Id: <20110607133327.a0591930.rdunlap@xenotime.net>
In-Reply-To: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACD9D@EXHQ.corp.stratus.com>
References: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACD9D@EXHQ.corp.stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paradis, James" <James.Paradis@stratus.com>
Cc: linux-mm@kvack.org

On Tue, 7 Jun 2011 16:28:27 -0400 Paradis, James wrote:

>  
> 
> This patch implements a system to track re-dirtied pages and modified
> 
> PTEs.  It is used by Stratus Technologies for both our ftLinux product
> and
> 
> our new GPL Live Kernel Self Migration project (lksm.sourceforge.net).
> 
> In both cases, we bring a backup server online by copying the primary
> 
> server's state while it is running.  We start by copying all of memory
> 
> top to bottom.  We then go back and re-copy any pages that were changed
> 
> during the first copy pass.  After several such passes we momentarily
> 
> suspend processing so we can copy the last few pages over and bring up
> 
> the secondary system.  This patch keeps track of which pages need to be
> 
> copied during these passes.
> 
>  
> 
>  arch/x86/Kconfig                      |   11 +++++++++++
> 
>  arch/x86/include/asm/hugetlb.h        |    3 +++
> 
>  arch/x86/include/asm/pgtable-2level.h |    4 ++++
> 
>  arch/x86/include/asm/pgtable-3level.h |   11 +++++++++++
> 
>  arch/x86/include/asm/pgtable.h        |    4 ++--
> 
>  arch/x86/include/asm/pgtable_32.h     |    1 +
> 
>  arch/x86/include/asm/pgtable_64.h     |    7 +++++++
> 
>  arch/x86/include/asm/pgtable_types.h  |    5 ++++-
> 
>  arch/x86/mm/Makefile                  |    2 ++
> 
>  mm/huge_memory.c                      |    4 ++--
> 
>  11 files changed, 48 insertions(+), 6 deletions(-)
> 
>  
> 
> Signed-off-by: "James Paradis" <james.paradis@stratus.com>
> 
>  
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> 
> index cc6c53a..cc778a4 100644
> 
> --- a/arch/x86/Kconfig
> 
> +++ b/arch/x86/Kconfig
> 
> @@ -1146,6 +1146,17 @@ config DIRECT_GBPAGES
> 
>                   support it. This can improve the kernel's performance
> a tiny bit by
> 
>                   reducing TLB pressure. If in doubt, say "Y".
> 
>  
> 
> +config TRACK_DIRTY_PAGES
> 
> +              bool "Enable dirty page tracking"
> 
> +              default n
> 
> +              depends on !KMEMCHECK
> 
> +              ---help---
> 
> +                Turning this on enables tracking of re-dirtied and
> 
> +                changed pages.  This is needed by the Live Kernel
> 
> +                Self Migration project (lksm.sourceforge.net) to
> perform
> 
> +                live copying of memory and system state to another
> system.
> 
> +                Most users will say n here.
> 
> +
> 
>  # Common NUMA Features
> 
>  config NUMA
> 
>                 bool "Numa Memory Allocation and Scheduler Support"
> 

[rest is snipped]


a.  Please don't send html.

b.  What caused the double-spaced lines?  maybe CR/LF?
I haven't tested it, but I doubt that this patch will apply cleanly as is.

c.  There's lots of whitespace damage, i.e., spaces instead of tabs at the
beginning of many lines.

You probably need to try again.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
