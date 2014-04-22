Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id C2CEE6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 07:48:44 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so4501719eek.16
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 04:48:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g47si59372868eet.324.2014.04.22.04.48.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 04:48:43 -0700 (PDT)
Date: Tue, 22 Apr 2014 13:48:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in
 mem_cgroup_iter()
Message-ID: <20140422114838.GK29311@dhcp22.suse.cz>
References: <1397861935-31595-1-git-send-email-nasa4836@gmail.com>
 <20140422094759.GC29311@dhcp22.suse.cz>
 <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
 <20140422103420.GI29311@dhcp22.suse.cz>
 <CAHz2CGUZyv-dvUUoSi2Vk_vgPAMqRN4yEg4F4XsKQ8udHeo2bQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHz2CGUZyv-dvUUoSi2Vk_vgPAMqRN4yEg4F4XsKQ8udHeo2bQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 22-04-14 18:58:11, Jianyu Zhan wrote:
[...]
> This reminds me of my draft edition of this patch, I specifically handle
> this case as:
> 
> if (reclaim) {
>                if (!memcg ) {
>                               iter->generation++;
>                               if (!prev) {
>                                     memcg = root;
>                                     mem_cgroup_iter_update(iter, NULL, memcg, root,  seq);
>                                     goto out_unlock:
>                               }
>               }
>               mem_cgroup_iter_update(iter, last_visited, memcg, root,
>                                 seq);
>               if (!prev && memcg)
>                         reclaim->generation = iter->generation;
> }
> 
> This is literally manual unwinding the second while loop, and thus omit
> the while loop,
> to save a   mem_cgroup_iter_update() and a mem_cgroup_iter_update()
> 
> But it maybe a bit hard to read.

Dunno, this particular case is more explicit but it is also uglier so I
do not think this is an overall improvement. I would rather keep the
current state unless the change either simplifies the generated code
or it is much better to read.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
