Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D528E6B0062
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:46:55 -0400 (EDT)
Message-ID: <4A3A540D.1020007@kernel.org>
Date: Thu, 18 Jun 2009 23:49:49 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 02/19] Introduce this_cpu_ptr() and generic this_cpu_*
 operations
References: <20090617203337.399182817@gentwo.org> <20090617203443.173725344@gentwo.org> <4A399D52.9040801@kernel.org> <4A39A680.5070405@kernel.org> <alpine.DEB.1.10.0906180953040.15556@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0906180953040.15556@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 18 Jun 2009, Tejun Heo wrote:
> 
>> Oops, one problem.  this_cpu_ptr() should evaluate to the same type
>> pointer as input but it currently evaulates to unsigned long.
> 
> this_cpu_ptr is uses SHIFT_PERCPU_PTR which preserves the type.

Yeap, I was passing in the pointer variable instead of lvalue and was
getting type mismatch warnings.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
