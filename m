Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7F16B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 13:35:08 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n3-v6so1322495otk.7
        for <linux-mm@kvack.org>; Thu, 24 May 2018 10:35:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p126-v6sor10498388oia.31.2018.05.24.10.35.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 May 2018 10:35:06 -0700 (PDT)
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
References: <20180524110011.1940-1-vbabka@suse.cz>
 <20180524121347.GA10763@castle.DHCP.thefacebook.com>
 <fea26519-2b5f-b404-872d-47afabcd3393@suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <01cbee1d-e5cf-8de1-6610-3043a2c5d5ca@redhat.com>
Date: Thu, 24 May 2018 10:35:03 -0700
MIME-Version: 1.0
In-Reply-To: <fea26519-2b5f-b404-872d-47afabcd3393@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On 05/24/2018 08:52 AM, Vlastimil Babka wrote:
> On 05/24/2018 02:13 PM, Roman Gushchin wrote:
>> On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
>>> Hi,
>>>
>>> - I haven't find any other obvious users for reclaimable kmalloc (yet)
>>
>> As I remember, ION memory allocator was discussed related to this theme:
>> https://lkml.org/lkml/2018/4/24/1288
> 
> +CC Laura
> 
> Yeah ION added the NR_INDIRECTLY_RECLAIMABLE_BYTES handling, which is
> adjusted to page granularity in patch 4. I'm not sure if it should use
> kmalloc as it seems to be allocating order-X pages, where kmalloc/slab
> just means extra overhead. But maybe if it doesn't allocate/free too
> frequently, it could work?
> 

The page pool allocation is supposed to be a slow path but it's
one I'd rather not have too much overhead. It also just looks really odd
to be allocating higher order pages via kmalloc imho.
  
>>> I did a superset as IIRC somebody suggested that in the older threads or at LSF.
>>
>> This looks nice to me!
>>
>> Thanks!
>>
> 
