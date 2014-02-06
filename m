Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 179406B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:23:18 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id f8so327081wiw.13
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:23:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1si630008wjb.33.2014.02.06.06.07.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 06:07:38 -0800 (PST)
Date: Thu, 6 Feb 2014 15:07:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
Message-ID: <20140206140707.GF20269@dhcp22.suse.cz>
References: <cover.1391356789.git.vdavydov@parallels.com>
 <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com>
 <20140204145210.GH4890@dhcp22.suse.cz>
 <52F1004B.90307@parallels.com>
 <20140204151145.GI4890@dhcp22.suse.cz>
 <52F106D7.3060802@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F106D7.3060802@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Tue 04-02-14 19:27:19, Vladimir Davydov wrote:
[...]
> What does this patch change? Actually, it introduces no functional
> changes - it only remove the code trying to find an alias for a memcg
> cache, because it will fail anyway. So this is rather a cleanup.

But this also means that two different memcgs might share the same cache
and so the pages for that cache, no? Actually it would depend on timing
because a new page would be chaged for the current allocator.

cachep->memcg_params->memcg == memcg would prevent from such a merge
previously AFAICS, or am I still confused?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
