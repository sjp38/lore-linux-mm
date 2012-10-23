Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9D5BC6B009D
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 20:48:20 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so3693540obc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 17:48:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508561E0.5000406@parallels.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com>
	<1350914737-4097-3-git-send-email-glommer@parallels.com>
	<0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com>
	<508561E0.5000406@parallels.com>
Date: Tue, 23 Oct 2012 09:48:19 +0900
Message-ID: <CAAmzW4PJkDbLJBKZ1zPNDw+dHPcgzX_25tMw3rWoX0ybpXACSQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Hello, Glauber.

2012/10/23 Glauber Costa <glommer@parallels.com>:
> On 10/22/2012 06:45 PM, Christoph Lameter wrote:
>> On Mon, 22 Oct 2012, Glauber Costa wrote:
>>
>>> + * kmem_cache_free - Deallocate an object
>>> + * @cachep: The cache the allocation was from.
>>> + * @objp: The previously allocated object.
>>> + *
>>> + * Free an object which was previously allocated from this
>>> + * cache.
>>> + */
>>> +void kmem_cache_free(struct kmem_cache *s, void *x)
>>> +{
>>> +    __kmem_cache_free(s, x);
>>> +    trace_kmem_cache_free(_RET_IP_, x);
>>> +}
>>> +EXPORT_SYMBOL(kmem_cache_free);
>>> +
>>
>> This results in an additional indirection if tracing is off. Wonder if
>> there is a performance impact?
>>
> if tracing is on, you mean?
>
> Tracing already incurs overhead, not sure how much a function call would
> add to the tracing overhead.
>
> I would not be concerned with this, but I can measure, if you have any
> specific workload in mind.

With this patch, kmem_cache_free() invokes __kmem_cache_free(),
that is, it add one more "call instruction" than before.

I think that Christoph's comment means above fact.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
