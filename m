Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 347446B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:09:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b16so4262008pfi.5
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 01:09:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si4573040pgs.516.2018.04.20.01.09.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 01:09:53 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:09:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180420080948.GV17484@dhcp22.suse.cz>
References: <20180418022912.248417-1-minchan@kernel.org>
 <20180418072002.GN17484@dhcp22.suse.cz>
 <20180418074117.GA210164@rodete-desktop-imager.corp.google.com>
 <20180418075437.GP17484@dhcp22.suse.cz>
 <20180418132328.GB210164@rodete-desktop-imager.corp.google.com>
 <20180418132715.GD17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181152240.227784@chino.kir.corp.google.com>
 <20180419064005.GL17484@dhcp22.suse.cz>
 <20180420054239.GA221997@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420054239.GA221997@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri 20-04-18 14:42:39, Minchan Kim wrote:
[...]
> When I see replies of this thread, it's arguble to add such one-line
> warn so if you want it strongly, could you handle by yourself?

I do not feel strongly about it to argue as well. So the patch Andrew
added with a better explanation is sufficient from my POV.
-- 
Michal Hocko
SUSE Labs
