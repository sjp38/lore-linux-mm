Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0036B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:52:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e15-v6so1528361wmh.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:52:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l22-v6si980617edb.177.2018.05.24.08.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 08:52:28 -0700 (PDT)
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
References: <20180524110011.1940-1-vbabka@suse.cz>
 <20180524121347.GA10763@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fea26519-2b5f-b404-872d-47afabcd3393@suse.cz>
Date: Thu, 24 May 2018 17:52:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180524121347.GA10763@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>

On 05/24/2018 02:13 PM, Roman Gushchin wrote:
> On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
>> Hi,
>>
>> - I haven't find any other obvious users for reclaimable kmalloc (yet)
> 
> As I remember, ION memory allocator was discussed related to this theme:
> https://lkml.org/lkml/2018/4/24/1288

+CC Laura

Yeah ION added the NR_INDIRECTLY_RECLAIMABLE_BYTES handling, which is
adjusted to page granularity in patch 4. I'm not sure if it should use
kmalloc as it seems to be allocating order-X pages, where kmalloc/slab
just means extra overhead. But maybe if it doesn't allocate/free too
frequently, it could work?

>> I did a superset as IIRC somebody suggested that in the older threads or at LSF.
> 
> This looks nice to me!
> 
> Thanks!
> 
