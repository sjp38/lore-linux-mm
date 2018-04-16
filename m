Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 029B86B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:59:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b16so9981669pfi.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:59:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f12si10062305pgo.64.2018.04.16.12.59.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 12:59:49 -0700 (PDT)
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz> <20180413143716.GA5378@cmpxchg.org>
 <20180416114144.GK17484@dhcp22.suse.cz>
 <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
 <20180416122747.GM17484@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a6413098-b37c-a6b8-45cb-ce273ff16c29@suse.cz>
Date: Mon, 16 Apr 2018 21:57:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180416122747.GM17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, lsf-pc@lists.linux-foundation.org

On 04/16/2018 02:27 PM, Michal Hocko wrote:
> On Mon 16-04-18 14:06:21, Vlastimil Babka wrote:
>>
>> For example the percpu (and other) array caches...
>>
>>> maybe it will turn out that such a large
>>> portion of the chache would need to duplicate the state that a
>>> completely new cache would be more reasonable.
>>
>> I'm afraid that's the case, yes.
>>
>>> Is this worth exploring
>>> at least? I mean something like this should help with the fragmentation
>>> already AFAIU. Accounting would be just free on top.
>>
>> Yep. It could be also CONFIG_urable so smaller systems don't need to
>> deal with the memory overhead of this.
>>
>> So do we put it on LSF/MM agenda?
> 
> If you volunteer to lead the discussion, then I do not have any
> objections.

Sure, let's add the topic of SLAB_MINIMIZE_WASTE [1] as well.

Something like "Supporting reclaimable kmalloc caches and large
non-buddy-sized objects in slab allocators" ?

[1] https://marc.info/?l=linux-mm&m=152156671614796&w=2
