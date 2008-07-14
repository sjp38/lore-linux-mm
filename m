Message-ID: <487B7F99.4060004@linux-foundation.org>
Date: Mon, 14 Jul 2008 11:32:25 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemtrace: SLAB hooks.
References: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>	 <1215889471-5734-1-git-send-email-eduard.munteanu@linux360.ro> <1216052893.6762.3.camel@penberg-laptop>
In-Reply-To: <1216052893.6762.3.camel@penberg-laptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi Eduard-Gabriel,
> 
> On Sat, 2008-07-12 at 22:04 +0300, Eduard - Gabriel Munteanu wrote:
>> This adds hooks for the SLAB allocator, to allow tracing with kmemtrace.
>>
>> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
>> @@ -28,8 +29,20 @@ extern struct cache_sizes malloc_sizes[];
>>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>>  void *__kmalloc(size_t size, gfp_t flags);
>>  
>> +#ifdef CONFIG_KMEMTRACE
>> +extern void *__kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags);
>> +#else
>> +static inline void *__kmem_cache_alloc(struct kmem_cache *cachep,
>> +				       gfp_t flags)
>> +{
>> +	return __kmem_cache_alloc(cachep, flags);
> 
> Looks as if the function calls itself i>>?recursively?
> 

Code not tested? Are you sure you configured for slab?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
