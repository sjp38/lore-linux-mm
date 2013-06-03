Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 2B0BD6B0072
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:10:33 -0400 (EDT)
Date: Mon, 3 Jun 2013 11:09:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: TLB and PTE coherency during munmap
Message-ID: <20130603100921.GA25367@localhost.cambridge.arm.com>
References: <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
 <20130603090501.GI5910@twins.programming.kicks-ass.net>
 <20130603091621.GA23320@gmail.com>
 <CAHkRjk7D=PAMgaqjGQ0t3e5Ftob2Z248uexvKGb0tWpycEMK6Q@mail.gmail.com>
 <20130603100444.GB8923@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603100444.GB8923@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Max Filippov <jcmvbkbc@gmail.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 03, 2013 at 11:04:44AM +0100, Peter Zijlstra wrote:
> On Mon, Jun 03, 2013 at 11:01:39AM +0100, Catalin Marinas wrote:
> > On ARM there is a lot of ongoing work on single zImage for multiple
> > SoCs and this implies SMP kernels. There is an SMP_ON_UP feature which
> > does run-time code patching to optimise the UP case in a few places.
> > 
> > Regarding tlb_fast_mode(), the ARM-specific implementation is always 0
> > on ARMv7 even if UP because of speculative TLB loads (the MMU could
> > pretty much act as a separate processor).
> 
> Oh right.. I should really refresh the mmu_gather unification patches so
> all archs are using the generic code.

That would be great! I'll help with testing/review (or if it needs
anything else) from an arm/arm64 perspective.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
