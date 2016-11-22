Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B36C46B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:16:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so1807457pfx.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:16:17 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id j82si25190452pfe.42.2016.11.21.16.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 16:16:16 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 3so203793pgd.0
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:16:16 -0800 (PST)
Subject: Re: [RESEND][v1 0/3] Support memory cgroup hotplug
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
 <20161121140340.GC18112@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <20dc8052-a622-e138-72f2-1a921095133b@gmail.com>
Date: Tue, 22 Nov 2016 11:16:10 +1100
MIME-Version: 1.0
In-Reply-To: <20161121140340.GC18112@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, vdavydov.dev@gmail.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>



On 22/11/16 01:03, Michal Hocko wrote:
> On Wed 16-11-16 10:44:58, Balbir Singh wrote:
>> In the absence of hotplug we use extra memory proportional to
>> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
>> to disable large consumption with large number of cgroups. This patch
>> adds hotplug support to memory cgroups and reverts the commit that
>> limited possible nodes to online nodes.
> 
> I didn't get to read patches yet (I am currently swamped by emails after
> longer vacation so bear with me) but this doesn't tell us _why_ we want
> this and how much we can actaully save. 

The motivation was 3af229f2071f
(powerpc/numa: Reset node_possible_map to only node_online_map)

In general being dynamic is more
> complex and most systems tend to have possible_nodes close to
> online_nodes in my experience (well at least on most reasonable
> architectures). I would also appreciate some highlevel description of
> the implications. E.g. how to we synchronize with the hotplug operations
> when iterating node specific data structures.

I agree dynamic is more complex, but I think we'll begin to see a lot
of more of it. The rules are not hard IMHO. From an implication perspective
it means that we need to get/put_online_mem_nodes in certain paths - specifically
mem_cgroup_alloc/free and mem_cgroup_init from what I can see so far

Thanks for the review!

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
