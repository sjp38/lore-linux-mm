Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE4A6B005D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:13:57 -0400 (EDT)
Message-ID: <4A3A683B.7090304@kernel.org>
Date: Fri, 19 Jun 2009 01:15:55 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu operations
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org> <4A39ADBF.1000505@kernel.org> <alpine.DEB.1.10.0906181001420.15556@gentwo.org> <4A3A53C9.4030609@kernel.org> <alpine.DEB.1.10.0906181134440.26369@gentwo.org> <4A3A65F7.6070404@kernel.org>
In-Reply-To: <4A3A65F7.6070404@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Tejun Heo wrote:
> Functionally, there's no practical difference but it's just weird to
> use scalar as input/output parameter.  All the atomic and bitops
> operations are taking pointers.  In fact, there are only very few
> which take lvalue input and modify it, so I think it would be much
> better to take pointers like normal C functions and macros for the
> sake of consistency.

One notable exception tho is the get/put_user() macros.  In that these
percpu ops behave differently depending on input parameter size might
put them closer to get/put_user() than other atomic / bitops
operations.  Eh... I'm not so sure anymore.  It's purely interface
decision.  Ingo, Rusty, what do you guys think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
