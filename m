Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52B8F6B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 03:07:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so3536896wmu.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:07:48 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id d128si1271611wmf.100.2016.11.23.00.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 00:07:47 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id f8so438923wje.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:07:46 -0800 (PST)
Date: Wed, 23 Nov 2016 09:07:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
Message-ID: <20161123080744.GG2864@dhcp22.suse.cz>
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
 <20161123072543.GD2864@dhcp22.suse.cz>
 <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 23-11-16 18:50:42, Balbir Singh wrote:
> 
> 
> On 23/11/16 18:25, Michal Hocko wrote:
> > On Wed 23-11-16 15:36:51, Balbir Singh wrote:
> >> In the absence of hotplug we use extra memory proportional to
> >> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
> >> to disable large consumption with large number of cgroups. This patch
> >> adds hotplug support to memory cgroups and reverts the commit that
> >> limited possible nodes to online nodes.
> > 
> > Balbir,
> > I have asked this in the previous version but there still seems to be a
> > lack of information of _why_ do we want this, _how_ much do we save on
> > the memory overhead on most systems and _why_ the additional complexity
> > is really worth it. Please make sure to add all this in the cover
> > letter.
> > 
> 
> The data is in the patch referred to in patch 3. The order of waste was
> 200MB for 400 cgroup directories enough for us to restrict possible_map
> to online_map. These patches allow us to have a larger possible map and
> allow onlining nodes not in the online_map, which is currently a restriction
> on ppc64.

How common is to have possible_map >> online_map? If this is ppc64 then
what is the downside of keeping the current restriction instead?

> A typical system that I use has about 100-150 directories, depending on the
> number of users/docker instances/configuration/virtual machines. These numbers
> will only grow as we pack more of these instances on them.
> 
> From a complexity view point, the patches are quite straight forward.

Well, I would like to hear more about that. {get,put}_online_memory
at random places doesn't sound all that straightforward to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
