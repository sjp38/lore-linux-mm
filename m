Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B75366B0282
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 08:22:30 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so6638976wme.5
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 05:22:30 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id k141si2406847wmd.133.2016.11.23.05.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 05:22:29 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so1999758wme.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 05:22:29 -0800 (PST)
Date: Wed, 23 Nov 2016 14:22:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
Message-ID: <20161123132226.GL2864@dhcp22.suse.cz>
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
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 24-11-16 00:05:12, Balbir Singh wrote:
> 
> 
> On 23/11/16 20:28, Michal Hocko wrote:
[...]
> > I am more worried about synchronization with the hotplug which tends to
> > be a PITA in places were we were simply safe by definition until now. We
> > do not have all that many users of memcg->nodeinfo[nid] from what I can see
> > but are all of them safe to never race with the hotplug. A lack of
> > highlevel design description is less than encouraging.
> 
> As in explanation? The design is dictated by the notifier and the actions
> to take when the node comes online/offline.

Sure but how all the users of lruvec (for example) which is stored in
the nodeinfo AFAIR, are supposed to synchronize with the notifier.
Really if you are doing something dynamic then the first thing to
explain is the sychronization. There might be really good reasons why we
do not have to care about explicit synchr. for most code paths but my
past experience with many subtle hotplug related bugs just make me a bit
suspicious. So in other words, please make sure to document as much as
possible. This will make the review so much easier.

>  So please try to
> > spend some time describing how do we use nodeinfo currently and how is
> > the synchronization with the hotplug supposed to work and what
> > guarantees that no stale nodinfos can be ever used. This is just too
> > easy to get wrong...
> > 
> 
> OK.. I'll add that in the next cover letter

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
