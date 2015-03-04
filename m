Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEBB6B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:41:33 -0500 (EST)
Received: by wghb13 with SMTP id b13so48243743wgh.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:41:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s5si4068457wiy.105.2015.03.04.09.41.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 09:41:31 -0800 (PST)
Date: Wed, 4 Mar 2015 12:40:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: Let mem_cgroup_move_account() have
 effect only if MMU enabled
Message-ID: <20150304174056.GA20376@phnom.home.cmpxchg.org>
References: <54F4E739.6040805@qq.com>
 <20150303134524.GE2409@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150303134524.GE2409@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Chen Gang <762976180@qq.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Mar 03, 2015 at 02:45:24PM +0100, Michal Hocko wrote:
> On Tue 03-03-15 06:42:01, Chen Gang wrote:
> > When !MMU, it will report warning. The related warning with allmodconfig
> > under c6x:
> 
> Does it even make any sense to enable CONFIG_MEMCG when !CONFIG_MMU?
> Is anybody using this configuration and is it actually usable? My
> knowledge about CONFIG_MMU is close to zero so I might be missing
> something but I do not see a point into fixing compile warnings when
> the whole subsystem is not usable in the first place.

It's very limited, and anonymous memory is not even charged right now,
even though it could be -- see nommu.c::do_mmap_private().  But there
is nothing inherent in the memcg functionality that would require an
MMU I guess, except for these ridiculous charge moving pte walkers.

> > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
