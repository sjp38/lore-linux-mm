Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 149246B0089
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 13:05:28 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AF0CC82C3DA
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 13:21:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xZ4s+lLWLfQz for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 13:21:56 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8BADA82C3DC
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 13:21:50 -0400 (EDT)
Date: Thu, 18 Jun 2009 13:05:17 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu
 operations
In-Reply-To: <4A3A65F7.6070404@kernel.org>
Message-ID: <alpine.DEB.1.10.0906181302010.29957@gentwo.org>
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org> <4A39ADBF.1000505@kernel.org> <alpine.DEB.1.10.0906181001420.15556@gentwo.org> <4A3A53C9.4030609@kernel.org> <alpine.DEB.1.10.0906181134440.26369@gentwo.org>
 <4A3A65F7.6070404@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jun 2009, Tejun Heo wrote:

> Functionally, there's no practical difference but it's just weird to
> use scalar as input/output parameter.  All the atomic and bitops
> operations are taking pointers.  In fact, there are only very few
> which take lvalue input and modify it, so I think it would be much
> better to take pointers like normal C functions and macros for the
> sake of consistency.

The atomic operators take an atomic_t or so type as a parameter. Those
operations actually can be handled like functions.

this_cpu and per cpuoperations can operate on an arbitrary type and
dynamically generate code adequate for the size of the variable involved.

Taking the address of a per cpu static or dynamically allocated variable
is not meaningful. The address must be relocated using the per cpu offset
for the desired processor in order to point to an instance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
