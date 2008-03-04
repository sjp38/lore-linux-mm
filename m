Date: Tue, 4 Mar 2008 10:36:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
Message-Id: <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
In-Reply-To: <47CD4AB3.3080409@linux.vnet.ibm.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
	<47CD4AB3.3080409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 04 Mar 2008 18:42:19 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> 3) Third attempt kernel booted up but had the following call trace 264 times while running
> test
> 
> Badness at include/linux/gfp.h:110
> NIP: c0000000000b4ff0 LR: c0000000000b4fa0 CTR: c00000000019cdb4
> REGS: c000000009edf250 TRAP: 0700   Not tainted  (2.6.25-rc3-mm1-autotest)
> MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 22024042  XER: 20000003
> TASK = c000000009062140[548] 'kjournald' THREAD: c000000009edc000 CPU: 0
> NIP [c0000000000b4ff0] .get_page_from_freelist+0x29c/0x898
> LR [c0000000000b4fa0] .get_page_from_freelist+0x24c/0x898
> Call Trace:
> [c000000009edf5f0] [c0000000000b56e4] .__alloc_pages_internal+0xf8/0x470
> [c000000009edf6e0] [c0000000000e0458] .kmem_getpages+0x8c/0x194
> [c000000009edf770] [c0000000000e1050] .fallback_alloc+0x194/0x254
> [c000000009edf820] [c0000000000e14b0] .kmem_cache_alloc+0xd8/0x144
> [c000000009edf8c0] [c0000000001fe0f8] .radix_tree_preload+0x50/0xd4
> [c000000009edf960] [c0000000000ad048] .add_to_page_cache+0x38/0x12c
> [c000000009edfa00] [c0000000000ad158] .add_to_page_cache_lru+0x1c/0x4c
> [c000000009edfa90] [c0000000000add58] .find_or_create_page+0x60/0xa8
> [c000000009edfb30] [c00000000011e478] .__getblk+0x140/0x310
> [c000000009edfc00] [c0000000001b78c4] .journal_get_descriptor_buffer+0x44/0xd8
> [c000000009edfca0] [c0000000001b236c] .journal_commit_transaction+0x948/0x1590
> [c000000009edfe00] [c0000000001b585c] .kjournald+0xf4/0x2ac
> [c000000009edff00] [c00000000007ff4c] .kthread+0x84/0xd0
> [c000000009edff90] [c000000000028900] .kernel_thread+0x4c/0x68
> Instruction dump:
> 7dc57378 48009575 60000000 2fa30000 419e0490 56c902d8 3c000018 7dd907b4 
> 7ad2c7e2 7f890000 7c000026 5400fffe <0b000000> e93e8128 3b000000 80090000 

/* Convert GFP flags to their corresponding migrate type */
static inline int allocflags_to_migratetype(gfp_t gfp_flags)
{
        WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);

Mel, Pekka: would you have some head-scratching time for this one please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
