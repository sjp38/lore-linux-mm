Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id AF1D66B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 14:28:47 -0500 (EST)
Received: by widex7 with SMTP id ex7so33163625wid.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 11:28:47 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id fu13si2577699wic.47.2015.03.04.11.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 11:28:39 -0800 (PST)
Received: by wggx12 with SMTP id x12so48855711wgg.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 11:28:38 -0800 (PST)
Date: Wed, 4 Mar 2015 20:28:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Message-ID: <20150304192836.GA952@dhcp22.suse.cz>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
 <20150304190635.GC21350@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304190635.GC21350@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

[Forgot to CC Balbir - sorry - the thread starts here:
http://marc.info/?l=linux-mm&m=142549243725564&w=2]

On Wed 04-03-15 14:06:35, Johannes Weiner wrote:
> On Wed, Mar 04, 2015 at 07:07:08PM +0100, Michal Hocko wrote:
> > CONFIG_MEMCG might be currently enabled also for !MMU architectures
> > which was probably an omission because Balbir had this on the TODO
> > list section (https://lkml.org/lkml/2008/3/16/59)
> > "
> > Only when CONFIG_MMU is enabled, is the virtual address space control
> > enabled. Should we do this for nommu cases as well? My suspicion is
> > that we don't have to.
> > "
> > I do not see any traces for !MMU requests after then. The code compiles
> > with !MMU but I haven't heard about anybody using it in the real life
> > so it is not clear to me whether it works and it is usable at all
> > considering how !MMU configuration is restricted.
> > 
> > Let's make CONFIG_MEMCG depend on CONFIG_MMU to make our support
> > explicit and also to get rid of few ifdefs in the code base.
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Sorry about the misunderstanding, I actually acked Chen's patch.  As I
> said, there is nothing inherent in memcg that would prevent using it
> on NOMMU systems except for this charges-follow-tasks feature, so I'd
> rather fix the compiler warning than adding this dependency.

Does it really make sense to do this minor tweaks when the configuration
is barely usable and we are not aware of anybody actually using it in
the real life?

Sure there is nothing inherently depending on MMU but just considering
this wasn't working since ages for anon mappings and who knows what else
doesn't work.

The point is, once somebody really needs this configuration we should go
over all the missing parts and implement them but this half baked state
with random fixes to shut the compiler up is really suboptimal IMO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
