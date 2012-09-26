Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 139276B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:16:34 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so2742698pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 13:16:33 -0700 (PDT)
Date: Wed, 26 Sep 2012 13:16:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120926201629.GB20342@google.com>
References: <20120926163648.GO16296@google.com>
 <50633D24.6020002@parallels.com>
 <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com>
 <50634105.8060302@parallels.com>
 <20120926180124.GA12544@google.com>
 <50634FC9.4090609@parallels.com>
 <20120926193417.GJ12544@google.com>
 <50635B9D.8020205@parallels.com>
 <20120926195648.GA20342@google.com>
 <50635F46.7000700@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50635F46.7000700@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Sep 27, 2012 at 12:02:14AM +0400, Glauber Costa wrote:
> But think in terms of functionality: This thing here is a lot more
> similar to swap than use_hierarchy. Would you argue that memsw should be
> per-root ?

I'm fairly sure you can make about the same argument about
use_hierarchy.  There is a choice to make here and one is simpler than
the other.  I want the additional complexity justified by actual use
cases which isn't too much to ask for especially when the complexity
is something visible to userland.

So let's please stop arguing semantics.  If this is definitely
necessary for some use cases, sure let's have it.  If not, let's
consider it later.  I'll stop responding on "inherent differences."  I
don't think we'll get anywhere with that.

Michal, Johannes, Kamezawa, what are your thoughts?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
