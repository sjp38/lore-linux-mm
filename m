Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 2424E6B0062
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 15:34:22 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so2689954pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 12:34:21 -0700 (PDT)
Date: Wed, 26 Sep 2012 12:34:17 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120926193417.GJ12544@google.com>
References: <1347977050-29476-1-git-send-email-glommer@parallels.com>
 <1347977050-29476-5-git-send-email-glommer@parallels.com>
 <20120926140347.GD15801@dhcp22.suse.cz>
 <20120926163648.GO16296@google.com>
 <50633D24.6020002@parallels.com>
 <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
 <50634105.8060302@parallels.com>
 <20120926180124.GA12544@google.com>
 <50634FC9.4090609@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50634FC9.4090609@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Wed, Sep 26, 2012 at 10:56:09PM +0400, Glauber Costa wrote:
> For me, it is the other way around: it makes perfect sense to have a
> per-subtree selection of features where it doesn't hurt us, provided it
> is hierarchical. For the mere fact that not every application is
> interested in this (Michal is the one that is being so far more vocal
> about this not being needed in some use cases), and it is perfectly
> valid to imagine such applications would coexist.
> 
> So given the flexibility it brings, the real question is, as I said,
> backwards: what is it necessary to make it a global switch ?

Because it hurts my head and it's better to keep things simple.  We're
planning to retire .use_hierarhcy in sub hierarchies and I'd really
like to prevent another fiasco like that unless there absolutely is no
way around it.  Flexibility where necessary is fine but let's please
try our best to avoid over-designing things.  We've been far too good
at getting lost in flexbility maze.  Michal, care to chime in?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
