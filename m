Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9318C6B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 07:36:13 -0400 (EDT)
Message-ID: <4A23BD20.5030500@kernel.org>
Date: Mon, 01 Jun 2009 20:36:00 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
References: <1243846708-805-1-git-send-email-tj@kernel.org>	<1243846708-805-4-git-send-email-tj@kernel.org> <20090601.024006.98975069.davem@davemloft.net>
In-Reply-To: <20090601.024006.98975069.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: JBeulich@novell.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, tglx@linutronix.de, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, geert@linux-m68k.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, chris@zankel.net, rusty@rustcorp.com.au, jens.axboe@oracle.com, davej@redhat.com, jeremy@xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Tejun Heo <tj@kernel.org>
> Date: Mon,  1 Jun 2009 17:58:24 +0900
> 
>> --- a/arch/cris/include/asm/mmu_context.h
>> +++ b/arch/cris/include/asm/mmu_context.h
>> @@ -17,7 +17,7 @@ extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
>>   * registers like cr3 on the i386
>>   */
>>  
>> -extern volatile DEFINE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
>> +DECLARE_PER_CPU(pgd_t *,current_pgd); /* defined in arch/cris/mm/fault.c */
>>  
>>  static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
>>  {
> 
> Yes volatile sucks, but might this break something?
> 
> Whether the volatile is actually needed or not, it's bad to have this
> kind of potential behavior changing nugget hidden in this seemingly
> inocuous change.  Especially if you're the poor soul who ends up
> having to debug it :-/

You're right.  Aieee... how do I feed volatile to the DEFINE macro.
I'll think of something.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
