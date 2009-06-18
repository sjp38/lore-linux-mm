Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8D2AE6B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 11:38:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C8A4282C247
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 11:55:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zzuqHaa3f9ez for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 11:55:45 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9F53D82C25C
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 11:55:39 -0400 (EDT)
Date: Thu, 18 Jun 2009 11:39:07 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu
 operations
In-Reply-To: <4A3A53C9.4030609@kernel.org>
Message-ID: <alpine.DEB.1.10.0906181134440.26369@gentwo.org>
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org> <4A39ADBF.1000505@kernel.org> <alpine.DEB.1.10.0906181001420.15556@gentwo.org> <4A3A53C9.4030609@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Tejun Heo wrote:

> Ah... okay, so it's supposed to take a lvalue.  I think it would be
> better to make it take pointer.  lvalue parameter is just weird when
> dynamic percpu variables are involved.  The old percpu accessors
> taking lvalue has more to do with the way percpu variables were
> defined in the beginning than anything else and are inconsistent with
> other similar accessors in the kernel.  As the new accessors are gonna
> replace the old ones eventually and maybe leave only the most often
> used ones as wrapper around pointer based ones, I think it would be
> better to make the transition while introducing new accessors.

The main purpose of these operations is to increment counters. Passing a
pointer would mean adding the & operator in all locations. Is there any
benefit through the use of the & operator?

lvalues of structs in the form of my_struct->field is a natural form of
referring to scalars.

The operation occurs on the object not on the pointer.

The special feature is that the address of the object is taken and its
address is relocated so that the current processors instance of the object
is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
