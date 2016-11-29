Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C10B36B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 19:09:33 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so391463480pgc.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:09:33 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id f5si57030297pgh.37.2016.11.28.16.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 16:09:32 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id p66so14477729pga.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:09:32 -0800 (PST)
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
 <20161123072543.GD2864@dhcp22.suse.cz>
 <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
 <20161123080744.GG2864@dhcp22.suse.cz>
 <61dc32fd-2802-6deb-24cf-fa11b5b31532@gmail.com>
 <20161123092830.GH2864@dhcp22.suse.cz>
 <962ac541-55c4-de09-59a3-4947c394eee6@gmail.com>
 <20161128211014.GB12143@htj.duckdns.org>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <fffa4fdc-8bb0-2891-d314-286d4ede305b@gmail.com>
Date: Tue, 29 Nov 2016 11:09:26 +1100
MIME-Version: 1.0
In-Reply-To: <20161128211014.GB12143@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>



On 29/11/16 08:10, Tejun Heo wrote:
> On Thu, Nov 24, 2016 at 12:05:12AM +1100, Balbir Singh wrote:
>> On my desktop NODES_SHIFT is 6, many distro kernels have it a 9. I've known
>> of solutions that use fake NUMA for partitioning and need as many nodes as
>> possible.
> 
> It was a crude kludge that people used before memcg.  If people still
> use it, that's fine but we don't want to optimize / make code
> complicated for it, so let's please put away this part of
> justification.

Are you suggesting those use cases can be ignored now?

> 
> It's understandable that some kernels want to have large NODES_SHIFT
> to support wide range of configurations but if that makes wastage too
> high, the simpler solution is updating the users to use the rumtime
> detected possible number / mask instead of the compile time
> NODES_SHIFT.  Note that we do exactly the same thing for per-cpu
> things - we configure high max but do all operations on what's
> possible on the system.
> 
> NUMA code already has possible detection.  Why not simply make memcg
> use those instead of MAX_NUMNODES like how we use nr_cpu_ids instead
> of NR_CPUS?
> 

nodes_possible_map is set to node_online_map at the moment for ppc64.
Which becomes a problem when hotplugging a node that was not already
online.

I am not sure what you mean by possible detection. node_possible_map
is set based on CONFIG_NODE_SHIFT and then can be adjusted by the
architecture (if desired). Are you suggesting firmware populate it
in?

Thanks,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
