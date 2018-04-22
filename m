Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37EF36B0007
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 08:46:53 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g7-v6so5217950wrb.19
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 05:46:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si646512edb.112.2018.04.22.05.46.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Apr 2018 05:46:52 -0700 (PDT)
Date: Sun, 22 Apr 2018 06:46:48 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: per-NUMA memory limits in mem cgroup?
Message-ID: <20180422124648.GD17484@dhcp22.suse.cz>
References: <5ADA26AB.6080209@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ADA26AB.6080209@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri 20-04-18 11:43:07, Chris Friesen wrote:
> Hi,
> 
> I'm aware of the ability to use the memory controller to limit how much
> memory a group of tasks can consume.
> 
> Is there any way to limit how much memory a group of tasks can consume *per
> NUMA node*?

Not really. We have all or nothing via cpusets but nothing really fine
grained for the amount of memory.

> The specific scenario I'm considering is that of a hypervisor host.  I have
> system management stuff running on the host that may need more than one
> core, and currently these host tasks might be affined to cores from multiple
> NUMA nodes.  I'd like to put a cap on how much memory the host tasks can
> allocate from each NUMA node in order to ensure that there is a guaranteed
> amount of memory available for VMs on each NUMA node.
> 
> Is this possible, or are the knobs just not there?

Not possible right now. What would be the policy when you reach the
limit on one node? Fallback to other nodes? What if those hit the limit
as well? OOM killer or an allocation failure?
-- 
Michal Hocko
SUSE Labs
