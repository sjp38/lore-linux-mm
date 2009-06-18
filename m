Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4F55E6B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 22:28:42 -0400 (EDT)
Message-ID: <4A39A680.5070405@kernel.org>
Date: Thu, 18 Jun 2009 11:29:20 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 02/19] Introduce this_cpu_ptr() and generic this_cpu_*
 operations
References: <20090617203337.399182817@gentwo.org> <20090617203443.173725344@gentwo.org> <4A399D52.9040801@kernel.org>
In-Reply-To: <4A399D52.9040801@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Tejun Heo wrote:
> cl@linux-foundation.org wrote:
>> this_cpu_ptr
>> ------------
>>
>> this_cpu_ptr(xx) = per_cpu_ptr(xx, smp_processor_id).
>>
>> The problem with per_cpu_ptr(x, smp_processor_id) is that it requires
>> an array lookup to find the offset for the cpu. Processors typically
>> have the offset for the current cpu area in some kind of (arch dependent)
>> efficiently accessible register or memory location.
> ...
>> cc: David Howells <dhowells@redhat.com>
>> cc: Tejun Heo <tj@kernel.org>
>> cc: Ingo Molnar <mingo@elte.hu>
>> cc: Rusty Russell <rusty@rustcorp.com.au>
>> cc: Eric Dumazet <dada1@cosmosbay.com>
>> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 

Oops, one problem.  this_cpu_ptr() should evaluate to the same type
pointer as input but it currently evaulates to unsigned long.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
