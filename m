Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA076B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:36:48 -0400 (EDT)
Message-ID: <4A2FFBDB.7070504@zytor.com>
Date: Wed, 10 Jun 2009 11:30:51 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] percpu: clean up percpu variable definitions
References: <1243846708-805-1-git-send-email-tj@kernel.org>	<1243846708-805-4-git-send-email-tj@kernel.org> <20090601.024006.98975069.davem@davemloft.net>
In-Reply-To: <20090601.024006.98975069.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: tj@kernel.org, JBeulich@novell.com, andi@firstfloor.org, mingo@elte.hu, tglx@linutronix.de, linux-kernel@vger.kernel.org, x86@kernel.org, ink@jurassic.park.msu.ru, rth@twiddle.net, linux@arm.linux.org.uk, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, jesper.nilsson@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, tony.luck@intel.com, takata@linux-m32r.org, monstr@monstr.eu, ralf@linux-mips.org, kyle@mcmartin.ca, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, chris@zankel.net, rusty@rustcorp.com.au, jens.axboe@oracle.com, davej@redhat.com, jeremy@xensource.com, linux-mm@kvack.org
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

Shouldn't the "volatile" go inside the DECLARE_PER_CPU() with the rest
of the type?  [Disclaimer: I haven't actually looked.]

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
