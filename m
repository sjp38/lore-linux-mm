Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 07E796B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 11:54:56 -0400 (EDT)
Date: Mon, 22 Apr 2013 17:54:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422155454.GH18286@dhcp22.suse.cz>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
 <20130422042445.GA25089@mtj.dyndns.org>
 <20130422153730.GG18286@dhcp22.suse.cz>
 <20130422154620.GB12543@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422154620.GB12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

On Mon 22-04-13 08:46:20, Tejun Heo wrote:
> Hey, Michal.
> 
> On Mon, Apr 22, 2013 at 05:37:30PM +0200, Michal Hocko wrote:
> > > In fact, I'm planning to disallow changing ownership of cgroup files
> > > when "sane_behavior" is specified. 
> > 
> > I would be wildly oposing this. Enabling user to play on its own ground
> > while above levels of the groups enforce the reasonable behavior is very
> > important use case.
> 
> We can continue this discussion on the original thread and I'm not too
> firm on this not because it's a sane use case but because it is an
> extra measure preventing root from shooting its feet which we
> traditionally allow.  That said, really, no good can come from
> delegating hierarchy to different security domains.  It's already
> discouraged by the userland best practices doc.  Just don't do it.

OK, I will go to the original mail thread and discuss my concerns there.

> > Tejun, stop this, finally! Current soft limit same as the reworked
> > version follow the basic nesting rule we use for the hard limit which
> > says that parent setting is always more strict than its children.
> > So if you parent says you are hitting the hardlimit (resp. over soft
> > limit) then children are reclaimed regardless their hard/soft limit
> > setting.
> 
> Okay, thanks for making it clear.  Then, apparently, the fine folks at
> google are hopelessly confused because at least Greg and Ying told me
> something which is the completely opposite of what you're saying.  You
> guys need to sort it out.
> 
> > It is you being confused and refuse to open the damn documentation and
> > read what the hack is soft limit and what it is used for. Read the patch
> > series I was talking about and you will hardly find anything regarding
> > _guarantee_.
> 
> Oh, if so, I'm happy.  Sorry about being brash on the thread; however,
> please talk with google memcg people.  They have very different
> interpretation of what "softlimit" is and are using it according to
> that interpretation.  If it *is* an actual soft limit, there is no
> inherent isolation coming from it and that should be clear to
> everyone.

We have discussed that for a long time. I will not speak for Greg & Ying
but from my POV we have agreed that the current implementation will work
for them with some (minor) changes in their layout.
As I have said already with a careful configuration (e.i. setting the
soft limit only where it matters - where it protects an important
memory which is usually in the leaf nodes) you can actually achieve
_high_ probability for not being reclaimed after the rework which was not
possible before because of the implementation which was ugly and
smelled.

> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
