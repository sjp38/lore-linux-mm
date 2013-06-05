Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id D479D6B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:58:53 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id wp1so858536pac.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 01:58:53 -0700 (PDT)
Date: Wed, 5 Jun 2013 01:58:49 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130605085849.GB7990@mtj.dyndns.org>
References: <1370254735-13012-1-git-send-email-mhocko@suse.cz>
 <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
 <20130605073728.GC15997@dhcp22.suse.cz>
 <20130605080545.GF7303@mtj.dyndns.org>
 <20130605085239.GF15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605085239.GF15997@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Hey, Michal.

On Wed, Jun 05, 2013 at 10:52:39AM +0200, Michal Hocko wrote:
> > One of the core jobs of being a maintainer is ensuring the code stays
> > in readable and maintainable state.
> 
> As you might know I am playing the maintainer role for around year and a
> half and there were many improvemtns merged since then (and some faults
> as well of course).
> There is a lot of space for improvements and I work at areas as time
> permits focusing more at reviews for other people are willing to do.

I see.  Yeah, maybe I was attributing too many things to you.  Sorry
about that.

> [...]
> 
> Please stop distracting from the main purpose of this discussion with
> side tracks and personal things.

I'm not really trying to distract you.  I suppose my points are.

* Let's please pay more attention to each change which goes in.

* Let's prioritize cleanups over new features because, whatever the
  history, memcg needs quite some cleanups.

I really don't have personal vandetta against you.  I'm mostly just
very frustrated about memcg.  Maybe you're too.

Anyways, so you aren't gonna try the skipping thing?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
