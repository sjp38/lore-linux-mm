Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 11AD06B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 16:13:19 -0500 (EST)
Received: by wggx13 with SMTP id x13so2109206wgg.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 13:13:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u8si31682095wiv.18.2015.03.04.13.13.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 13:13:17 -0800 (PST)
Date: Wed, 4 Mar 2015 16:13:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Message-ID: <20150304211301.GA22626@phnom.home.cmpxchg.org>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
 <20150304190635.GC21350@phnom.home.cmpxchg.org>
 <20150304192836.GA952@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304192836.GA952@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, Mar 04, 2015 at 08:28:36PM +0100, Michal Hocko wrote:
> > Sorry about the misunderstanding, I actually acked Chen's patch.  As I
> > said, there is nothing inherent in memcg that would prevent using it
> > on NOMMU systems except for this charges-follow-tasks feature, so I'd
> > rather fix the compiler warning than adding this dependency.
> 
> Does it really make sense to do this minor tweaks when the configuration
> is barely usable and we are not aware of anybody actually using it in
> the real life?
> 
> Sure there is nothing inherently depending on MMU

How is this even controversial?  We are not adding dependencies just
because we're not sure how we feel about the opposite.  We declare a
dependency when we know it truly exists.

> but just considering
> this wasn't working since ages for anon mappings and who knows what else
> doesn't work.

NOMMU people know that too, they don't expect to have significant test
coverage.  If they run into issues, they can still add the dependency.
This is much better than them wanting to use a feature, running into
the dependency declaration, going through all the code, scratching
their heads about why this code would have that dependency, finally
writing us an email, and then us going "ah yeah, there is nothing
INHERENTLY depending on MMU, we just weren't sure about it."

I don't even care about NOMMU, this is just wrong on principle.  And
obviously so.  NAK to your patch from me.

> The point is, once somebody really needs this configuration we should go
> over all the missing parts and implement them but this half baked state
> with random fixes to shut the compiler up is really suboptimal IMO.

Disagreed, for the above-mentioned reasons.  Chen's patch is obvious
and self-contained and doesn't at all indicate an endless stream of
future patches in that direction.  It also improves code organization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
