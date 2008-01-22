Message-Id: <20080122230409.198261000@sgi.com>
Date: Tue, 22 Jan 2008 15:04:09 -0800
From: travis@sgi.com
Subject: [PATCH 0/3] x86/non-x86: percpu, node ids, apic ids x86.git fixup
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[ patches for x86.git ]

Ingo Molnar wrote:

> well i picked up some more stuff so please check x86.git later today, 
> once i have updated it. It should have most of the x86.git relevant 
> bits.
> 
> the wider, multiple-arch patches you are doing should go via -mm. (or i 
> can pick any of them up into x86.git for testing, if you reshape it to a 
> "applies fine to x86.git and does not break other arches" x86-only and 
> perhaps generic-percpu bits.

Here is 3 patches to address the following:

    01-fix-x86.git-need
	- fixes up things missing in x86.git  [necessary]

    02-fix-x86.git-debug-maxsmp
	- adds debug options [do not include, except for DEBUG]

    03-fix-x86.git-non-x86-changes
	- non-x86 changes that should fix build errors when x86.git
	  is merged into -mm.  [necessary for -mm merge]
	  [percpu_modcopy() being the primary problem but also the
	  config option name for "HAVE_PER_CPU_SETUP" is different.]


Cc: Andi Kleen <ak@suse.de>
Cc: David Miller <davem@davemloft.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>
Cc: linux-ia64@vger.kernel.org
Cc: mingo@redhat.com
Cc: Paul Mackerras <paulus@samba.org>
Cc: schwidefsky@de.ibm.com
Cc: tglx@linutronix.de
Cc: tony.luck@intel.com
Cc: Yinghai Lu <yhlu.kernel@gmail.com>

Signed-off-by: Mike Travis <travis@sgi.com>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
