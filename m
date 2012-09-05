Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A49BD6B00A8
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:41:55 -0400 (EDT)
Message-ID: <50471DA2.5010302@parallels.com>
Date: Wed, 5 Sep 2012 13:38:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C14 [00/14] Sl[auo]b: Common code for cgroups V13
References: <000001399388b97b-d8cf8122-411a-470d-8964-7d134bbf3c03-000000@email.amazonses.com> <CAOJsxLESTFPETQVeDM7RUw=EUOMJUYVcUrwY7ryqwaTDs8Kvxw@mail.gmail.com>
In-Reply-To: <CAOJsxLESTFPETQVeDM7RUw=EUOMJUYVcUrwY7ryqwaTDs8Kvxw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>

On 09/05/2012 01:20 PM, Pekka Enberg wrote:
> On Wed, Sep 5, 2012 at 2:06 AM, Christoph Lameter <cl@linux.com> wrote:
>> This is a series of patches that extracts common functionality from
>> slab allocators into a common code base. The intend is to standardize
>> as much as possible of the allocator behavior while keeping the
>> distinctive features of each allocator which are mostly due to their
>> storage format and serialization approaches.
>>
>> This patchset makes a beginning by extracting common functionality in
>> kmem_cache_create() and kmem_cache_destroy(). However, there are
>> numerous other areas where such work could be beneficial:
>>
>> 1. Extract the sysfs support from SLUB and make it common. That way
>>    all allocators have a common sysfs API and are handleable in the same
>>    way regardless of the allocator chose.
>>
>> 2. Extract the error reporting and checking from SLUB and make
>>    it available for all allocators. This means that all allocators
>>    will gain the resiliency and error handling capabilties.
>>
>> 3. Extract the memory hotplug and cpu hotplug handling. It seems that
>>    SLAB may be more sophisticated here. Having common code here will
>>    make it easier to maintain the special code.
>>
>> 4. Extract the aliasing capability of SLUB. This will enable fast
>>    slab creation without creating too many additional slab caches.
>>    The arrays of caches of varying sizes in numerous subsystems
>>    do not cause the creation of numerous slab caches. Storage
>>    density is increased and the cache footprint is reduced.
>>
>> Ultimately it is to be hoped that the special code for each allocator
>> shrinks to a mininum. This will also make it easier to make modification
>> to allocators.
>>
>> In the far future one could envision that the current allocators will
>> just become storage algorithms that can be chosen based on the need of
>> the subsystem. F.e.
>>
>> Cpu cache dependend performance         = Bonwick allocator (SLAB)
>> Minimal cycle count and cache footprint = SLUB
>> Maximum storage density                 = K&R allocator (SLOB)
> 
> I've created a 'slab/common-for-groups' branch for this and queued it
> for linux-next. I had to revert the sysfs patch because it caused
> warnings during boot:
> 
> https://github.com/penberg/linux/commit/aac3a1664aba429f47c70edfc76ee10fcd808471
> 
> I'd like to keep it append-only from now on please send incremental
> patches on top of the branch.
> 

Michal,

Would you merge this branch into your memcg-devel tree?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
