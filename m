Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F08166B0003
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:32:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x7-v6so4392833wrn.13
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 08:32:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19-v6si691003edz.48.2018.04.30.08.32.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Apr 2018 08:32:19 -0700 (PDT)
Subject: Re: [PATCH] mm: don't show nr_indirectly_reclaimable in /proc/vmstat
References: <20180425191422.9159-1-guro@fb.com>
 <20180426200331.GZ17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804261453460.238822@chino.kir.corp.google.com>
 <99208563-1171-b7e7-a0d7-b47b6c5e2307@suse.cz>
 <alpine.DEB.2.21.1804271139500.152082@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <da797c29-129c-1591-bb85-79817dafd912@suse.cz>
Date: Mon, 30 Apr 2018 17:30:17 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1804271139500.152082@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, kernel-team@fb.com, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>

On 04/27/2018 08:41 PM, David Rientjes wrote:
> On Fri, 27 Apr 2018, Vlastimil Babka wrote:
> 
>> It was in the original thread, see e.g.
>> <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
>>
>> However it will take some time to get that in mainline, and meanwhile
>> the current implementation does prevent a DOS. So I doubt it can be
>> fully reverted - as a compromise I just didn't want the counter to
>> become ABI. TBH though, other people at LSF/MM didn't seem concerned
>> that /proc/vmstat is an ABI that we can't change (i.e. counters have
>> been presumably removed in the past already).
>>
> 
> What prevents this from being a simple atomic_t that gets added to in 
> __d_alloc(), subtracted from in __d_free_external_name(), and read in 
> si_mem_available() and __vm_enough_memory()?

The counter is already in mainline, so I think it's easier to simply
just stop printing it now than trying to replace its implementation with
one that can cause cache ping pongs.
