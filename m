Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 350746B00A7
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:51:08 -0500 (EST)
Date: Thu, 15 Nov 2012 10:51:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Message-ID: <20121115095103.GB11990@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <1352820639-13521-3-git-send-email-mhocko@suse.cz>
 <20121113161442.GA18227@mtj.dyndns.org>
 <20121114085129.GC17111@dhcp22.suse.cz>
 <20121114185245.GF21185@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121114185245.GF21185@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>

On Wed 14-11-12 10:52:45, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Nov 14, 2012 at 09:51:29AM +0100, Michal Hocko wrote:
> > > 	reclaim(root);
> > > 	for_each_descendent_pre()
> > > 		reclaim(descendant);
> > 
> > We cannot do for_each_descendent_pre here because we do not iterate
> > through the whole hierarchy all the time. Check shrink_zone.
> 
> I'm a bit confused.  Why would that make any difference?  Shouldn't it
> be just able to test the condition and continue?

Ohh, I misunderstood your proposal. So what you are suggesting is
to put all the logic we have in mem_cgroup_iter inside what you call
reclaim here + mem_cgroup_iter_break inside the loop, right?

I do not see how this would help us much. mem_cgroup_iter is not the
nicest piece of code but it handles quite a complex requirements that we
have currently (css reference count, multiple reclaimers racing). So I
would rather keep it this way. Further simplifications are welcome of
course.

Is there any reason why you are not happy about direct using of
cgroup_next_descendant_pre?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
