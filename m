Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC3656B0260
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:50:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so12268725pgq.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:50:51 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id v79si32528928pfk.125.2016.11.22.23.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 23:50:51 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id e9so516687pgc.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:50:51 -0800 (PST)
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
 <20161123072543.GD2864@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <342ebcca-b54c-4bc6-906b-653042caae06@gmail.com>
Date: Wed, 23 Nov 2016 18:50:42 +1100
MIME-Version: 1.0
In-Reply-To: <20161123072543.GD2864@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>



On 23/11/16 18:25, Michal Hocko wrote:
> On Wed 23-11-16 15:36:51, Balbir Singh wrote:
>> In the absence of hotplug we use extra memory proportional to
>> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
>> to disable large consumption with large number of cgroups. This patch
>> adds hotplug support to memory cgroups and reverts the commit that
>> limited possible nodes to online nodes.
> 
> Balbir,
> I have asked this in the previous version but there still seems to be a
> lack of information of _why_ do we want this, _how_ much do we save on
> the memory overhead on most systems and _why_ the additional complexity
> is really worth it. Please make sure to add all this in the cover
> letter.
> 

The data is in the patch referred to in patch 3. The order of waste was
200MB for 400 cgroup directories enough for us to restrict possible_map
to online_map. These patches allow us to have a larger possible map and
allow onlining nodes not in the online_map, which is currently a restriction
on ppc64.

A typical system that I use has about 100-150 directories, depending on the
number of users/docker instances/configuration/virtual machines. These numbers
will only grow as we pack more of these instances on them.

>From a complexity view point, the patches are quite straight forward.

> I still didn't get to look into those patches because I am swamped with
> other things but to be honest I do not really see a strong justification
> to make it high priority for me.
> 

I am OK if you need more time to review them, but I've been pushing them
to fix the cases I've mentioned above.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
