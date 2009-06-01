Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 920F86B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 05:39:33 -0400 (EDT)
Date: Mon, 01 Jun 2009 02:40:06 -0700 (PDT)
Message-Id: <20090601.024006.98975069.davem@davemloft.net>
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
From: David Miller <davem@davemloft.net>
In-Reply-To: <1243846708-805-4-git-send-email-tj@kernel.org>
References: <1243846708-805-1-git-send-email-tj@kernel.org>
	<1243846708-805-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: tj@kernel.org
Cc: JBeulich@novell.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, tglx@linutronix.de, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, chris@zankel.net, rusty@rustcorp.com.au, jens.axboe@oracle.com, davej@redhat.com, jeremy@xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Tejun Heo <tj@kernel.org>
Date: Mon,  1 Jun 2009 17:58:24 +0900

> --- a/arch/cris/include/asm/mmu_context.h
> +++ b/arch/cris/include/asm/mmu_context.h
> @@ -17,7 +17,7 @@ extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>   * registers like cr3 on the i386
>   */
>  
> -extern volatile DEFINE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
> +DECLARE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
>  
>  static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>  {

Yes volatile sucks, but might this break something?

Whether the volatile is actually needed or not, it's bad to have this
kind of potential behavior changing nugget hidden in this seemingly
inocuous change.  Especially if you're the poor soul who ends up
having to debug it :-/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
