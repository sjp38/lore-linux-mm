Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2F1C6B028C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:42:21 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id d187so319554192ywe.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:42:21 -0800 (PST)
Received: from mail-yb0-x244.google.com (mail-yb0-x244.google.com. [2607:f8b0:4002:c09::244])
        by mx.google.com with ESMTPS id x184si6922832ywg.222.2016.11.15.07.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 07:42:21 -0800 (PST)
Received: by mail-yb0-x244.google.com with SMTP id v78so4066433ybe.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:42:21 -0800 (PST)
Date: Tue, 15 Nov 2016 10:42:19 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [v1 0/3] Support memory cgroup hotplug
Message-ID: <20161115154219.GA28262@htj.duckdns.org>
References: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, akpm@linux-foundation.org

Hello, Balbir.

On Tue, Nov 15, 2016 at 10:44:02AM +1100, Balbir Singh wrote:
> In the absence of hotplug we use extra memory proportional to
> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
> to disable large consumption with large number of cgroups. This patch
> adds hotplug support to memory cgroups and reverts the commit that
> limited possible nodes to online nodes.
> 
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Can you please cc memcg maintainers?  Johannes Weiner
<hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org> and Vladimir
Davydov <vdavydov.dev@gmail.com>.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
