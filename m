Message-Id: <20080225183308.159770000@polaris-admin.engr.sgi.com>
Date: Mon, 25 Feb 2008 10:33:08 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/1] x86_64: x86_64_cleanup_pda() should use nr_cpu_ids instead of NR_CPUS
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew - would you add this to your -mm patchset?  It fixes a
possible panic.

(I based it on 2.6.25-rc2 + 2.6.25-rc2-mm1 + my patches from broken-out-0223
as I could not get 2.6.25-rc2 + all of broken-out-0223 to apply.)

Thanks, Mike

..from Eric Dumazet:
> You might want to apply this patch.
> 
> I also wonder if _cpu_pda should be set only at the very end of 
> x86_64_cleanup_pda(), after array initialization, or maybe other
> cpus are not yet running ? (Sorry I cannot boot test this patch at this
> moment)
> 
> [PATCH] x86_64: x86_64_cleanup_pda() should use nr_cpu_ids instead of NR_CPUS
> 
> We allocate an array of nr_cpu_ids pointers, so we should respect its bonds.
> 
> Delay change of _cpu_pda after array initialization.
> 
> Also take into account that alloc_bootmem_low() :
> - calls panic() if not enough memory
> - already clears allocated memory

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---

Built and tested: (x86_64) defconfig, nonum, nosmp (*).
Built: (x86_64) all{yes,mod}config,
       (i386) defconfig, all{yes,mod}config, nonum, nosmp.

* - I add to disable ACPI to build the non-smp version of x86_64.

---

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
