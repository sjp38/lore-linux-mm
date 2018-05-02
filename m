Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B11156B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 09:36:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o8-v6so9862006wra.12
        for <linux-mm@kvack.org>; Wed, 02 May 2018 06:36:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a13-v6si761339edk.364.2018.05.02.06.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 06:36:46 -0700 (PDT)
Date: Wed, 2 May 2018 09:38:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180502133832.GA18204@cmpxchg.org>
References: <20180423123610.27988-1-guro@fb.com>
 <20180424123002.utwbm54mu46q6aqs@esperanza>
 <20180424135409.GA28080@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424135409.GA28080@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>

On Tue, Apr 24, 2018 at 02:54:15PM +0100, Roman Gushchin wrote:
> From: Roman Gushchin <guro@fb.com>
> Date: Tue, 24 Apr 2018 14:44:14 +0100
> Subject: [PATCH] mm: ignore memory.min of abandoned memory cgroups
> 
> If a cgroup has no associated tasks, invoking the OOM killer
> won't help release any memory, so respecting the memory.min
> can lead to an infinite OOM loop or system stall.
> 
> Let's ignore memory.min of unpopulated cgroups.

Good point, this makes sense.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -2549,8 +2549,11 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  				/*
>  				 * Hard protection.
>  				 * If there is no reclaimable memory, OOM.
> +				 * Abandoned cgroups are loosing protection,

                                                         losing
