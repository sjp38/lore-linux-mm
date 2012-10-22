Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 72FE06B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 11:10:33 -0400 (EDT)
Message-ID: <508561E0.5000406@parallels.com>
Date: Mon, 22 Oct 2012 19:10:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-3-git-send-email-glommer@parallels.com> <0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com>
In-Reply-To: <0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 10/22/2012 06:45 PM, Christoph Lameter wrote:
> On Mon, 22 Oct 2012, Glauber Costa wrote:
> 
>> + * kmem_cache_free - Deallocate an object
>> + * @cachep: The cache the allocation was from.
>> + * @objp: The previously allocated object.
>> + *
>> + * Free an object which was previously allocated from this
>> + * cache.
>> + */
>> +void kmem_cache_free(struct kmem_cache *s, void *x)
>> +{
>> +	__kmem_cache_free(s, x);
>> +	trace_kmem_cache_free(_RET_IP_, x);
>> +}
>> +EXPORT_SYMBOL(kmem_cache_free);
>> +
> 
> This results in an additional indirection if tracing is off. Wonder if
> there is a performance impact?
> 
if tracing is on, you mean?

Tracing already incurs overhead, not sure how much a function call would
add to the tracing overhead.

I would not be concerned with this, but I can measure, if you have any
specific workload in mind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
