Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53C006B02ED
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:47:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so69296037pfx.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:47:31 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i68si28671323pgc.178.2016.11.15.15.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:47:30 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id e9so12622406pgc.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:47:30 -0800 (PST)
Subject: Re: [v1 0/3] Support memory cgroup hotplug
References: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
 <20161115154219.GA28262@htj.duckdns.org>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ac99835c-ae55-f1e2-f449-cd1bd9585806@gmail.com>
Date: Wed, 16 Nov 2016 10:47:26 +1100
MIME-Version: 1.0
In-Reply-To: <20161115154219.GA28262@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, akpm@linux-foundation.org



On 16/11/16 02:42, Tejun Heo wrote:
> Hello, Balbir.
> 
> On Tue, Nov 15, 2016 at 10:44:02AM +1100, Balbir Singh wrote:
>> In the absence of hotplug we use extra memory proportional to
>> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
>> to disable large consumption with large number of cgroups. This patch
>> adds hotplug support to memory cgroups and reverts the commit that
>> limited possible nodes to online nodes.
>>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> Can you please cc memcg maintainers?  Johannes Weiner
> <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org> and Vladimir
> Davydov <vdavydov.dev@gmail.com>.
> 
> Thanks.
> 

My bad - resent with copies to the recommended maintainers.

Thanks,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
