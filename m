Date: Tue, 8 Apr 2008 11:26:19 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 2 of 9] Core of mmu notifiers
Message-ID: <20080408162619.GP11364@sgi.com>
References: <patchbomb.1207669443@duo.random> <baceb322b45ed4328065.1207669445@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <baceb322b45ed4328065.1207669445@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This one does not build on ia64.  I get the following:

[holt@attica mmu_v12_xpmem_v003_v1]$ make compressed
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC      mm/mmu_notifier.o
In file included from include/linux/mmu_notifier.h:6,
                 from mm/mmu_notifier.c:12:
include/linux/mm_types.h:200: error: expected specifier-qualifier-list before a??cpumask_ta??
In file included from mm/mmu_notifier.c:12:
include/linux/mmu_notifier.h: In function a??mm_has_notifiersa??:
include/linux/mmu_notifier.h:62: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
include/linux/mmu_notifier.h: In function a??mmu_notifier_mm_inita??:
include/linux/mmu_notifier.h:117: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
In file included from include/asm/pgtable.h:155,
                 from include/linux/mm.h:39,
                 from mm/mmu_notifier.c:14:
include/asm/mmu_context.h: In function a??get_mmu_contexta??:
include/asm/mmu_context.h:81: error: a??struct mm_structa?? has no member named a??contexta??
include/asm/mmu_context.h:88: error: a??struct mm_structa?? has no member named a??contexta??
include/asm/mmu_context.h:90: error: a??struct mm_structa?? has no member named a??cpu_vm_maska??
include/asm/mmu_context.h:99: error: a??struct mm_structa?? has no member named a??contexta??
include/asm/mmu_context.h: In function a??init_new_contexta??:
include/asm/mmu_context.h:120: error: a??struct mm_structa?? has no member named a??contexta??
include/asm/mmu_context.h: In function a??activate_contexta??:
include/asm/mmu_context.h:173: error: a??struct mm_structa?? has no member named a??cpu_vm_maska??
include/asm/mmu_context.h:174: error: a??struct mm_structa?? has no member named a??cpu_vm_maska??
include/asm/mmu_context.h:180: error: a??struct mm_structa?? has no member named a??contexta??
mm/mmu_notifier.c: In function a??__mmu_notifier_releasea??:
mm/mmu_notifier.c:25: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c:26: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c: In function a??__mmu_notifier_clear_flush_younga??:
mm/mmu_notifier.c:47: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c: In function a??__mmu_notifier_invalidate_pagea??:
mm/mmu_notifier.c:61: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c: In function a??__mmu_notifier_invalidate_range_starta??:
mm/mmu_notifier.c:73: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c: In function a??__mmu_notifier_invalidate_range_enda??:
mm/mmu_notifier.c:85: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
mm/mmu_notifier.c: In function a??mmu_notifier_registera??:
mm/mmu_notifier.c:102: error: a??struct mm_structa?? has no member named a??mmu_notifier_lista??
make[1]: *** [mm/mmu_notifier.o] Error 1
make: *** [mm] Error 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
