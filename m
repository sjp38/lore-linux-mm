Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54B4D6B0266
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 04:27:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 11so10454059pge.4
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 01:27:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y79sor404196pfb.57.2017.09.21.01.27.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 01:27:31 -0700 (PDT)
Date: Thu, 21 Sep 2017 01:27:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170920222403.GA4729@castle>
Message-ID: <alpine.DEB.2.10.1709210125150.10026@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <20170913215607.GA19259@castle> <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz> <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz> <20170915152301.GA29379@castle> <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com> <20170915210807.GA5238@castle> <alpine.DEB.2.10.1709191351330.7458@chino.kir.corp.google.com>
 <20170920222403.GA4729@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 20 Sep 2017, Roman Gushchin wrote:

> > It's actually much more complex because in our environment we'd need an 
> > "activity manager" with CAP_SYS_RESOURCE to control oom priorities of user 
> > subcontainers when today it need only be concerned with top-level memory 
> > cgroups.  Users can create their own hierarchies with their own oom 
> > priorities at will, it doesn't alter the selection heuristic for another 
> > other user running on the same system and gives them full control over the 
> > selection in their own subtree.  We shouldn't need to have a system-wide 
> > daemon with CAP_SYS_RESOURCE be required to manage subcontainers when 
> > nothing else requires it.  I believe it's also much easier to document: 
> > oom_priority is considered for all sibling cgroups at each level of the 
> > hierarchy and the cgroup with the lowest priority value gets iterated.
> 
> I do agree actually. System-wide OOM priorities make no sense.
> 
> Always compare sibling cgroups, either by priority or size, seems to be
> simple, clear and powerful enough for all reasonable use cases. Am I right,
> that it's exactly what you've used internally? This is a perfect confirmation,
> I believe.
> 

We've used it for at least four years, I added my Tested-by to your patch, 
we would convert to your implementation if it is merged upstream, and I 
would enthusiastically support your patch if you would integrate it back 
into your series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
