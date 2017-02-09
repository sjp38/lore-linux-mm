Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5EF56B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:12:30 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id c7so38539026wjb.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:12:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p75si5377638wmd.68.2017.02.09.01.12.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 01:12:29 -0800 (PST)
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
References: <20170203181008.24898-1-vbabka@suse.cz>
 <201702080139.e2GzXRQt%fengguang.wu@intel.com>
 <20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org>
 <d3a1f708-efdd-98c3-9c26-dab600501679@suse.cz>
 <20170208135404.fa003c62eb6b75cefbe13d49@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <54e80303-b814-4232-66d4-95b34d3eb9d0@suse.cz>
Date: Thu, 9 Feb 2017 10:12:24 +0100
MIME-Version: 1.0
In-Reply-To: <20170208135404.fa003c62eb6b75cefbe13d49@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>

On 02/08/2017 10:54 PM, Andrew Morton wrote:
> On Wed, 8 Feb 2017 10:12:13 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Thanks for the fix.
>> 
>> I was going to implement Christoph's suggestion and export the whole structure
>> in mm/slab.h, but gcc was complaining that I'm redefining it, until I created a
>> typedef first. Is it worth the trouble? Below is how it would look like.
>> 
>> ...
>>
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -71,6 +71,13 @@ extern struct list_head slab_caches;
>>  /* The slab cache that manages slab cache information */
>>  extern struct kmem_cache *kmem_cache;
>>  
>> +/* A table of kmalloc cache names and sizes */
>> +typedef struct {
>> +	const char *name;
>> +	unsigned long size;
>> +} kmalloc_info_t;
>> +extern const kmalloc_info_t kmalloc_info[];
> 
> Why is the typedef needed?  Can't we use something like

Duh, right, I can't C. Thanks.

----8<----
