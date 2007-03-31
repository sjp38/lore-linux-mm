Date: Sat, 31 Mar 2007 12:55:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [SLUB 2/2] i386 arch page size slab fixes
Message-Id: <20070331125536.a984e5ce.akpm@linux-foundation.org>
In-Reply-To: <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
	<20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, 31 Mar 2007 11:31:07 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> Fixup i386 arch for SLUB support
> 
> i386 arch code currently uses the page struct of slabs for various purposes.
> This interferes with slub and so SLUB has been disabled for i386 by setting
> ARCH_USES_SLAB_PAGE_STRUCT.
> 
> This patch removes the use of page sized slabs for maintaining pgds and pmds.
> 
> Patch by William Irwin with only very minor modifications by me which are
> 
> 1. Removal of HIGHMEM64G slab caches. It seems that virtualization hosts
>    require a a full pgd page.
> 
> 2. Add missing virtualization hook. Seems that we need a new way
>    of serializing paravirt_alloc(). It may need to do its own serialization.
> 
> 3. Remove ARCH_USES_SLAB_PAGE_STRUCT
> 
> Note that this makes things work without debugging on.
> The arch still fails to boot properly if full SLUB debugging is on with
> a cryptic message:
> 
> CPU: AMD Athlon(tm) 64 Processor 3000+ stepping 00
> Checking 'hlt' instruction... OK.
> ACPI: Core revision 20070126
> ACPI: setting ELCR to 0200 (from 1ca0)
> BUG: at kernel/sched.c:3417 sub_preempt_count()
>  [<c0342d43>] _spin_unlock_irq+0x13/0x30
>  [<c01160e6>] schedule_tail+0x36/0xd0
>  [<c0102df8>] __switch_to+0x28/0x180
>  [<c0103f9a>] ret_from_fork+0x6/0x1c
>  [<c012acf0>] kthread+0x0/0xe0

This all has the potential to make my inbox hurt.

Can we disable SLUB on i386 in Kconfig until it gets sorted out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
