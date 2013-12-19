Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id CB3EC6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 05:06:18 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so360788eaj.9
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 02:06:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m44si3621848eeo.58.2013.12.19.02.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 02:06:17 -0800 (PST)
Date: Thu, 19 Dec 2013 11:06:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/6] memcg, slab: RCU protect memcg_params for root caches
Message-ID: <20131219100615.GD10855@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <be8f2fede0fbc45496c06f7bc6cc2272b9b81cc4.1387372122.git.vdavydov@parallels.com>
 <20131219092836.GH9331@dhcp22.suse.cz>
 <52B2BE2A.2080509@parallels.com>
 <20131219094333.GB10855@dhcp22.suse.cz>
 <52B2C0B5.9010602@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B2C0B5.9010602@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 19-12-13 13:47:33, Vladimir Davydov wrote:
[...]
> Yeah, you're right, this longs for a documentation. I'm going to check

We desparately need a documentation for the life cycle of all involved
objects and description of which locks are used at which stage. 

> this code a bit more and try to write a good comment about it (although
> I'm rather poor at writing comments :-( )

A nice diagram would do as well...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
