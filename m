Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC6B6B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 05:51:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so152110325wmg.3
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 02:51:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy6si10144911wjb.192.2016.10.05.02.51.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Oct 2016 02:51:28 -0700 (PDT)
Subject: Re: [PATCH] oom: print nodemask in the oom report
References: <20160930214146.28600-1-mhocko@kernel.org>
 <65c637df-a9a3-777d-f6d3-322033980f86@suse.cz>
 <20161004141607.GC32214@dhcp22.suse.cz>
 <6fc2bb5f-a91c-f4e8-8d3c-029e2bdb3526@suse.cz>
 <20161004151258.GD32214@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56a3bdb2-2aa2-2624-b556-5169bf46559c@suse.cz>
Date: Wed, 5 Oct 2016 11:51:27 +0200
MIME-Version: 1.0
In-Reply-To: <20161004151258.GD32214@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Sellami Abdelkader <abdelkader.sellami@sap.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/04/2016 05:12 PM, Michal Hocko wrote:
>>
>> Ah, I wasn't clear. What I questioned is the fallback to cpusets for NULL
>> nodemask:
>>
>> nodemask_t *nm = (oc->nodemask) ? oc->nodemask :
>> &cpuset_current_mems_allowed;
>
> Well no nodemask means there is no mempolicy so either all nodes can be
> used or they are restricted by the cpuset. cpuset_current_mems_allowed is
> node_states[N_MEMORY] if there is no cpuset so I believe we are printing
> the correct information. An alternative would be either not print
> anything if there is no nodemask or print node_states[N_MEMORY]
> regardless the cpusets. The first one is quite ugly while the later
> might be confusing I guess.

So I thought it would be useful to distinguish that mempolicy/nodemask 
had no restriction (e.g. NULL), vs restriction that happens to be the 
very same as cpuset_current_mems_allowed. With your patch we can just 
guess, if both are printed as the same sets. But I guess there's not 
much value in that and the most important point is that we can determine 
the resulting combination (intersection) of both kinds of restrictions 
from the report, which indeed we can after your patch.

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
