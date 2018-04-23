Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB996B0008
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:29:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d13so10726014pfn.21
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:29:33 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id t25si10935715pfh.101.2018.04.23.08.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:29:32 -0700 (PDT)
Message-ID: <5ADDFBD1.7010009@windriver.com>
Date: Mon, 23 Apr 2018 11:29:21 -0400
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: per-NUMA memory limits in mem cgroup?
References: <5ADA26AB.6080209@windriver.com> <20180422124648.GD17484@dhcp22.suse.cz>
In-Reply-To: <20180422124648.GD17484@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 04/22/2018 08:46 AM, Michal Hocko wrote:
> On Fri 20-04-18 11:43:07, Chris Friesen wrote:

>> The specific scenario I'm considering is that of a hypervisor host.  I have
>> system management stuff running on the host that may need more than one
>> core, and currently these host tasks might be affined to cores from multiple
>> NUMA nodes.  I'd like to put a cap on how much memory the host tasks can
>> allocate from each NUMA node in order to ensure that there is a guaranteed
>> amount of memory available for VMs on each NUMA node.
>>
>> Is this possible, or are the knobs just not there?
>
> Not possible right now. What would be the policy when you reach the
> limit on one node? Fallback to other nodes? What if those hit the limit
> as well? OOM killer or an allocation failure?

I'd envision it working exactly the same as the current memory cgroup, but with 
the ability to specify optional per-NUMA-node limits in addition to system-wide.

Chris
