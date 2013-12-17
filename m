Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 166ED6B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:12:04 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so2286356eek.27
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 00:12:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si2754025eep.141.2013.12.17.00.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 00:12:04 -0800 (PST)
Date: Tue, 17 Dec 2013 09:12:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: fix memcg_size() calculation
Message-ID: <20131217081202.GA26640@dhcp22.suse.cz>
References: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
 <20131216164730.GD26797@dhcp22.suse.cz>
 <CAA6-i6rX7-F9UO2DO3gwC2SHNuSv2Fn48eLb1BZmc3HjCkbuvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA6-i6rX7-F9UO2DO3gwC2SHNuSv2Fn48eLb1BZmc3HjCkbuvQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 17-12-13 11:48:20, Glauber Costa wrote:
> On Mon, Dec 16, 2013 at 8:47 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Sat 14-12-13 12:15:33, Vladimir Davydov wrote:
> >> The mem_cgroup structure contains nr_node_ids pointers to
> >> mem_cgroup_per_node objects, not the objects themselves.
> >
> > Ouch! This is 2k per node which is wasted. What a shame I haven't
> > noticed this back then when reviewing 45cf7ebd5a033 (memcg: reduce the
> > size of struct memcg 244-fold)
> >
> IIRC, they weren't pointers back then. I think they were embedded in
> the structure, and I let
> them embedded.
> My mind may be tricking me, but I think I recall that Johannes changed
> them to pointers
> in a later time. No ?

It was wrapped by mem_cgroup_lru_info back then but the memcg_size
hasn't changed after 54f72fe022d9 (memcg: clean up memcg->nodeinfo) so
the missing * was there since 45cf7ebd5a033

> In any case, this is correct.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
