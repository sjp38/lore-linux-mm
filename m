Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 551AC6B02C2
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:10:16 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id t125so145619902ywc.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:10:16 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id x4si15222520ywf.219.2016.11.28.13.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 13:10:15 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id s68so10901378ywg.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:10:15 -0800 (PST)
Date: Mon, 28 Nov 2016 16:10:14 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
Message-ID: <20161128211014.GB12143@htj.duckdns.org>
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
 <20161123072543.GD2864@dhcp22.suse.cz>
 <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
 <20161123080744.GG2864@dhcp22.suse.cz>
 <61dc32fd-2802-6deb-24cf-fa11b5b31532@gmail.com>
 <20161123092830.GH2864@dhcp22.suse.cz>
 <962ac541-55c4-de09-59a3-4947c394eee6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <962ac541-55c4-de09-59a3-4947c394eee6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu, Nov 24, 2016 at 12:05:12AM +1100, Balbir Singh wrote:
> On my desktop NODES_SHIFT is 6, many distro kernels have it a 9. I've known
> of solutions that use fake NUMA for partitioning and need as many nodes as
> possible.

It was a crude kludge that people used before memcg.  If people still
use it, that's fine but we don't want to optimize / make code
complicated for it, so let's please put away this part of
justification.

It's understandable that some kernels want to have large NODES_SHIFT
to support wide range of configurations but if that makes wastage too
high, the simpler solution is updating the users to use the rumtime
detected possible number / mask instead of the compile time
NODES_SHIFT.  Note that we do exactly the same thing for per-cpu
things - we configure high max but do all operations on what's
possible on the system.

NUMA code already has possible detection.  Why not simply make memcg
use those instead of MAX_NUMNODES like how we use nr_cpu_ids instead
of NR_CPUS?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
