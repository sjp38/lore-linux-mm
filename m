Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12ED36B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 03:30:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h81-v6so6399506wmf.6
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:30:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20-v6si7130631edq.282.2018.06.19.00.30.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 00:30:05 -0700 (PDT)
Subject: Re: [PATCH v2 6/7] mm, proc: add KReclaimable to /proc/meminfo
References: <20180618091808.4419-1-vbabka@suse.cz>
 <20180618091808.4419-7-vbabka@suse.cz>
 <20180618143317.eb8f5d7b6c667784343ef902@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <650c3fab-3137-4fe6-272a-f4ec104855a7@suse.cz>
Date: Tue, 19 Jun 2018 09:30:03 +0200
MIME-Version: 1.0
In-Reply-To: <20180618143317.eb8f5d7b6c667784343ef902@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 06/18/2018 11:33 PM, Andrew Morton wrote:
> On Mon, 18 Jun 2018 11:18:07 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> The vmstat NR_KERNEL_MISC_RECLAIMABLE counter is for kernel non-slab
>> allocations that can be reclaimed via shrinker. In /proc/meminfo, we can show
>> the sum of all reclaimable kernel allocations (including slab) as
>> "KReclaimable". Add the same counter also to per-node meminfo under /sys
> 
> Why do you consider this useful enough to justify adding it to
> /pro/meminfo?  How will people use it, what benefit will they see, etc?

Let's add this:

With this counter, users will have more complete information about
kernel memory usage. Non-slab reclaimable pages (currently just the ION
allocator) will not be missing from /proc/meminfo, making users wonder
where part of their memory went. More precisely, they already appear in
MemAvailable, but without the new counter, it's not obvious why the
value in MemAvailable doesn't fully correspond with the sum of other
counters participating in it.

> Maybe you've undersold this whole patchset, but I'm struggling a bit to
> see what the end-user benefits are.  What would be wrong with just
> sticking with what we have now?

Fair enough, I will add more info in reply to the cover letter.
