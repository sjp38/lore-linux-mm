Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7996B0006
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 07:20:58 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id y64-v6so2025049yba.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:20:58 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n64-v6si1207122yba.153.2018.03.22.04.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 04:20:57 -0700 (PDT)
Subject: Re: [RFC PATCH v2 0/4] Eliminate zone->lock contention for
 will-it-scale/page_fault1 and parallel free
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <1dfd4b33-6eff-160e-52fd-994d9bcbffed@oracle.com>
 <20180322013049.GA4056@intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <5fa1b7f6-4614-c0d9-9f85-007cdd049a5b@oracle.com>
Date: Thu, 22 Mar 2018 07:20:14 -0400
MIME-Version: 1.0
In-Reply-To: <20180322013049.GA4056@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On 03/21/2018 09:30 PM, Aaron Lu wrote:
> On Wed, Mar 21, 2018 at 01:44:25PM -0400, Daniel Jordan wrote:
>> On 03/20/2018 04:54 AM, Aaron Lu wrote:
>> ...snip...
>>> reduced zone->lock contention on free path from 35% to 1.1%. Also, it
>>> shows good result on parallel free(*) workload by reducing zone->lock
>>> contention from 90% to almost zero(lru lock increased from almost 0 to
>>> 90% though).
>>
>> Hi Aaron, I'm looking through your series now.  Just wanted to mention that I'm seeing the same interaction between zone->lock and lru_lock in my own testing.  IOW, it's not enough to fix just one or the other: both need attention to get good performance on a big system, at least in this microbenchmark we've both been using.
> 
> Agree.
> 
>>
>> There's anti-scaling at high core counts where overall system page faults per second actually decrease with more CPUs added to the test.  This happens when either zone->lock or lru_lock contention are completely removed, but the anti-scaling goes away when both locks are fixed.
>>
>> Anyway, I'll post some actual data on this stuff soon.
> 
> Looking forward to that, thanks.
> 
> In the meantime, I'll also try your lru_lock optimization work on top of
> this patchset to see if the lock contention shifts back to zone->lock.

The lru_lock series I posted is pretty outdated by now, and I've got a 
totally new approach I plan to post soon, so it might make sense to wait 
for that.
