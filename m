Message-ID: <48AB1817.8040100@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 21:59:35 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with	_RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost> <48AB1769.3040703@linux-foundation.org>
In-Reply-To: <48AB1769.3040703@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Eduard - Gabriel Munteanu wrote:
>> On Tue, Aug 19, 2008 at 01:14:01PM -0500, Christoph Lameter wrote:
>>> Eduard - Gabriel Munteanu wrote:
>>>
>>>>  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
>>>>  {
>>>> -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
>>>> +	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
>>>>  }
>>> Could you get rid of the casts by changing the type of parameter of slab_alloc()?
>> I just looked at it and it isn't a trivial change. slab_alloc() calls
>> other functions which expect a void ptr. Even if slab_alloc() were to
>> take an unsigned long and then cast it to a void ptr, other functions do
>> call slab_alloc() with void ptr arguments (so the casts would move
>> there).
>>
>> I'd rather have this merged as it is and change things later, so that
>> kmemtrace gets some testing from Pekka and others. 
>>
> 
> Well maybe this patch will do it then:
> 
> Subject: slub: Use _RET_IP and use "unsigned long" for kernel text addresses
> 
> Use _RET_IP_ instead of buildint_return_address() and make slub use unsigned long
> instead of void * for addresses.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Heh, heh. I'm happy to take your patch or alternatively you can ACK mine 
(which is slightly different):

http://lkml.org/lkml/2008/8/19/336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
