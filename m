Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD8B6B0037
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:34:25 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so4462168eek.34
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:34:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si59101916eeh.213.2014.04.22.03.34.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:34:23 -0700 (PDT)
Date: Tue, 22 Apr 2014 12:34:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in
 mem_cgroup_iter()
Message-ID: <20140422103420.GI29311@dhcp22.suse.cz>
References: <1397861935-31595-1-git-send-email-nasa4836@gmail.com>
 <20140422094759.GC29311@dhcp22.suse.cz>
 <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 22-04-14 18:17:09, Jianyu Zhan wrote:
> On Tue, Apr 22, 2014 at 5:47 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > What about
> >   3. last_visited == last_node in the tree
> >
> > __mem_cgroup_iter_next returns NULL and the iterator would return
> > without visiting anything.
> 
> Hi,  Michal,
> 
> yep,  if 3 last_visited == last_node, then this means we have done a round-trip,
> thus __mem_cgroup_iter_next returns NULL, in turn mem_cgroup_iter() return NULL.

Sorry, I should have been more specific that I was talking about
mem_cgroup_reclaim_cookie path where the iteration for this particular
zone and priority ended at the last node without finishing the full
roundtrip last time. This new iteration (prev==NULL) wants to continue
and it should start a new roundtrip.

Makes sense?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
