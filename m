Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4D496B04FA
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 09:03:44 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so40170519wmf.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:03:44 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id x69si13669768wme.157.2016.11.21.06.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 06:03:43 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g23so2295312wme.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:03:43 -0800 (PST)
Date: Mon, 21 Nov 2016 15:03:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND][v1 0/3] Support memory cgroup hotplug
Message-ID: <20161121140340.GC18112@dhcp22.suse.cz>
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, vdavydov.dev@gmail.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 16-11-16 10:44:58, Balbir Singh wrote:
> In the absence of hotplug we use extra memory proportional to
> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
> to disable large consumption with large number of cgroups. This patch
> adds hotplug support to memory cgroups and reverts the commit that
> limited possible nodes to online nodes.

I didn't get to read patches yet (I am currently swamped by emails after
longer vacation so bear with me) but this doesn't tell us _why_ we want
this and how much we can actaully save. In general being dynamic is more
complex and most systems tend to have possible_nodes close to
online_nodes in my experience (well at least on most reasonable
architectures). I would also appreciate some highlevel description of
the implications. E.g. how to we synchronize with the hotplug operations
when iterating node specific data structures.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
