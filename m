Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 993346B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 15:56:53 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so832945pad.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 12:56:52 -0700 (PDT)
Date: Wed, 26 Sep 2012 12:56:48 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120926195648.GA20342@google.com>
References: <1347977050-29476-5-git-send-email-glommer@parallels.com>
 <20120926140347.GD15801@dhcp22.suse.cz>
 <20120926163648.GO16296@google.com>
 <50633D24.6020002@parallels.com>
 <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
 <50634105.8060302@parallels.com>
 <20120926180124.GA12544@google.com>
 <50634FC9.4090609@parallels.com>
 <20120926193417.GJ12544@google.com>
 <50635B9D.8020205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50635B9D.8020205@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Wed, Sep 26, 2012 at 11:46:37PM +0400, Glauber Costa wrote:
> Besides not being part of cgroup core, and respecting very much both
> cgroups' and basic sanity properties, kmem is an actual feature that
> some people want, and some people don't. There is no reason to believe
> that applications that want will live in the same environment with ones
> that don't want.

I don't know.  It definitely is less crazy than .use_hierarchy but I
wouldn't say it's an inherently different thing.  I mean, what does it
even mean to have u+k limit on one subtree and not on another branch?
And we worry about things like what if parent doesn't enable it but
its chlidren do.

This is a feature which adds complexity.  If the feature is necessary
and justified, sure.  If not, let's please not and let's err on the
side of conservativeness.  We can always add it later but the other
direction is much harder.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
