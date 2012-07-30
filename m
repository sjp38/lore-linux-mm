Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4EC9B6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 04:15:53 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 30 Jul 2012 09:15:51 +0100
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6U8FK7m2281566
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 09:15:20 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6U8FKBP008368
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 02:15:20 -0600
Date: Mon, 30 Jul 2012 10:15:18 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/2] add mm argument to lazy mmu mode hooks
Message-ID: <20120730101518.71130b33@de.ibm.com>
In-Reply-To: <20120727165749.GB7190@localhost.localdomain>
References: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
	<1343317634-13197-2-git-send-email-schwidefsky@de.ibm.com>
	<20120727165749.GB7190@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, Zachary Amsden <zach@vmware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, 27 Jul 2012 12:57:50 -0400
Konrad Rzeszutek Wilk <konrad@darnok.org> wrote:

> On Thu, Jul 26, 2012 at 05:47:13PM +0200, Martin Schwidefsky wrote:
> > To enable lazy TLB flush schemes with a scope limited to a single
> > mm_struct add the mm pointer as argument to the three lazy mmu mode
> > hooks.
> > 
> > diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> > index 0b47ddb..b097945 100644
> > --- a/arch/x86/include/asm/paravirt.h
> > +++ b/arch/x86/include/asm/paravirt.h
> > @@ -694,17 +694,17 @@ static inline void arch_end_context_switch(struct task_struct *next)
> >  }
> >  
> >  #define  __HAVE_ARCH_ENTER_LAZY_MMU_MODE
> > -static inline void arch_enter_lazy_mmu_mode(void)
> > +static inline void arch_enter_lazy_mmu_mode(struct mm_struct *mm)
> >  {
> >  	PVOP_VCALL0(pv_mmu_ops.lazy_mode.enter);
> 
> If you are doing that, you should probably also update the pvops call to
> pass in the 'struct mm_struct'?
> 

Seems reasonable, if we limit the lazy mmu flushing to a single mm then
that fact should be represented on the pvops calls as well.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
