Message-Id: <20080219203226.746641000@polaris-admin.engr.sgi.com>
Date: Tue, 19 Feb 2008 12:32:26 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/2] percpu: Optimize percpu accesses v3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the generic (non-x86) changes for zero-based per cpu variables.

This patchset provides the following:

  * Init: Move setup of nr_cpu_ids to as early as possible for usage
    by early boot functions.

  * Generic: Percpu infrastructure to rebase the per cpu area to zero

    This provides for the capability of accessing the percpu variables
    using a local register instead of having to go through a table
    on node 0 to find this cpu specific offsets.  It also would allow
    atomic operations on percpu variables to reduce required locking.

  * Introduces a new DEFINE_PER_CPU_FIRST to locate a percpu variable
    (cpu_pda in this case) at the beginning of the percpu .data section.

Based on git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
v3: * split generic/x86-specific into two patches

v2: * rebased and retested using linux-2.6.git
    * fixed errors reported by checkpatch.pl

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
