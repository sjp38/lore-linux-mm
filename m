Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B36DF6B00A5
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 20:51:32 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so5001831pad.13
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 17:51:32 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id dv3si3763171pdb.496.2014.07.24.17.51.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 17:51:31 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so4957961pab.6
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 17:51:30 -0700 (PDT)
Message-ID: <53D1A9FC.7090202@gmail.com>
Date: Fri, 25 Jul 2014 08:51:08 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: trivial comment cleanup in slab.c
References: <53CE11C1.1030306@gmail.com> <alpine.DEB.2.02.1407221457010.5814@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407221457010.5814@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org



On 2014a1'07ae??23ae?JPY 05:57, David Rientjes wrote:
> On Tue, 22 Jul 2014, Wang Sheng-Hui wrote:
> 
>>
>> Current struct kmem_cache has no 'lock' field, and slab page is
>> managed by struct kmem_cache_node, which has 'list_lock' field.
>>
>> Clean up the related comment.
>>
> 
> I think this is fine, but not sure if the s/slab/slab page/ change makes 
> anything clearer and is unmentioned in the changelog.
> 

David,

I used "slab page" to mention the pages used for slab.
Hope that won't introduce any confusion/misunderstanding.

Regards,
Sheng-Hui


>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>> ---
>>  mm/slab.c | 9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 3070b92..8f7170f 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -1724,7 +1724,8 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
>>  }
>>
>>  /*
>> - * Interface to system's page allocator. No need to hold the cache-lock.
>> + * Interface to system's page allocator. No need to hold the
>> + * kmem_cache_node ->list_lock.
>>   *
>>   * If we requested dmaable memory, we will get it. Even if we
>>   * did not request dmaable memory, we might get it, but that
>> @@ -2026,9 +2027,9 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
>>   * @cachep: cache pointer being destroyed
>>   * @page: page pointer being destroyed
>>   *
>> - * Destroy all the objs in a slab, and release the mem back to the system.
>> - * Before calling the slab must have been unlinked from the cache.  The
>> - * cache-lock is not held/needed.
>> + * Destroy all the objs in a slab page, and release the mem back to the system.
>> + * Before calling the slab page must have been unlinked from the cache. The
>> + * kmem_cache_node ->list_lock is not held/needed.
>>   */
>>  static void slab_destroy(struct kmem_cache *cachep, struct page *page)
>>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
