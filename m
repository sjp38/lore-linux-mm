Date: Fri, 21 Mar 2008 20:02:58 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
	IA64 and x86
Message-ID: <20080321190258.GF6571@elte.hu>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net> <20080321083952.GA20454@elte.hu> <Pine.LNX.4.64.0803211032390.18671@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803211032390.18671@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 21 Mar 2008, Ingo Molnar wrote:
> 
> > another thing is that this patchset includes KERNEL_STACK_SIZE_ORDER 
> > which has been NACK-ed before on x86 by several people and i'm 
> > nacking this "configurable stack size" aspect of it again.
> 
> Huh? Nothing of that nature is in this patchset.

your patch indeed does not introduce it here, but 
KERNEL_STACK_SIZE_ORDER shows up in the x86 portion of your patch and 
you refer to multi-order stack allocations in your 0/14 mail :-)

> -#define alloc_task_struct()	((struct task_struct *)__get_free_pages(GFP_KERNEL | __GFP_COMP, KERNEL_STACK_SIZE_ORDER))
> -#define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
> +#define alloc_task_struct()	((struct task_struct *)__alloc_vcompound( \
> +			GFP_KERNEL, KERNEL_STACK_SIZE_ORDER))

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
