Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0696B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 02:33:41 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu operations
Date: Fri, 19 Jun 2009 15:11:49 +0930
References: <20090617203337.399182817@gentwo.org> <alpine.DEB.1.10.0906181134440.26369@gentwo.org> <4A3A65F7.6070404@kernel.org>
In-Reply-To: <4A3A65F7.6070404@kernel.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200906191511.50690.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jun 2009 01:36:15 am Tejun Heo wrote:
> Christoph Lameter wrote:
> > On Thu, 18 Jun 2009, Tejun Heo wrote:
> >> Ah... okay, so it's supposed to take a lvalue.  I think it would be
> >> better to make it take pointer.  lvalue parameter is just weird when
> >> dynamic percpu variables are involved.  The old percpu accessors
> >> taking lvalue has more to do with the way percpu variables were
> >> defined in the beginning than anything else and are inconsistent with
> >> other similar accessors in the kernel.  As the new accessors are gonna
> >> replace the old ones eventually and maybe leave only the most often
> >> used ones as wrapper around pointer based ones, I think it would be
> >> better to make the transition while introducing new accessors.
> >
> > The main purpose of these operations is to increment counters. Passing a
> > pointer would mean adding the & operator in all locations. Is there any
> > benefit through the use of the & operator?
> >
> > lvalues of structs in the form of my_struct->field is a natural form of
> > referring to scalars.
> >
> > The operation occurs on the object not on the pointer.
> >
> > The special feature is that the address of the object is taken and its
> > address is relocated so that the current processors instance of the
> > object is used.
>
> Functionally, there's no practical difference but it's just weird to
> use scalar as input/output parameter.  All the atomic and bitops
> operations are taking pointers.  In fact, there are only very few
> which take lvalue input and modify it, so I think it would be much
> better to take pointers like normal C functions and macros for the
> sake of consistency.

Absolutely agreed here; C is pass by value and any use of macros to violate 
that is abhorrent.  Let's not spread the horro of cpus_* or local_irq_save()!

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
