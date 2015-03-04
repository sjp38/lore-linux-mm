Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 809C76B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 13:00:34 -0500 (EST)
Received: by widem10 with SMTP id em10so30715528wid.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 10:00:33 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ch4si1987522wib.24.2015.03.04.10.00.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 10:00:32 -0800 (PST)
Received: by wibhm9 with SMTP id hm9so9568057wib.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 10:00:28 -0800 (PST)
Date: Wed, 4 Mar 2015 19:00:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol: Let mem_cgroup_move_account() have
 effect only if MMU enabled
Message-ID: <20150304180024.GA26741@dhcp22.suse.cz>
References: <54F4E739.6040805@qq.com>
 <20150303134524.GE2409@dhcp22.suse.cz>
 <20150304174056.GA20376@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304174056.GA20376@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chen Gang <762976180@qq.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 04-03-15 12:40:56, Johannes Weiner wrote:
> On Tue, Mar 03, 2015 at 02:45:24PM +0100, Michal Hocko wrote:
> > On Tue 03-03-15 06:42:01, Chen Gang wrote:
> > > When !MMU, it will report warning. The related warning with allmodconfig
> > > under c6x:
> > 
> > Does it even make any sense to enable CONFIG_MEMCG when !CONFIG_MMU?
> > Is anybody using this configuration and is it actually usable? My
> > knowledge about CONFIG_MMU is close to zero so I might be missing
> > something but I do not see a point into fixing compile warnings when
> > the whole subsystem is not usable in the first place.
> 
> It's very limited, and anonymous memory is not even charged right now,
> even though it could be -- see nommu.c::do_mmap_private().  But there
> is nothing inherent in the memcg functionality that would require an
> MMU I guess, except for these ridiculous charge moving pte walkers.
> 
> > > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, I will post the patch to Andrew.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
