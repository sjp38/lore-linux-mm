Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7E8276B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 12:01:17 -0400 (EDT)
Received: by mail-da0-f46.google.com with SMTP id y19so3204616dan.19
        for <linux-mm@kvack.org>; Mon, 22 Apr 2013 09:01:16 -0700 (PDT)
Date: Mon, 22 Apr 2013 09:01:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130422160112.GE12543@htj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <CANN689GuN_5QdgPBjr7h6paVmPeCvLHYfLWNLsJMWib9V9G_Fw@mail.gmail.com>
 <20130422042445.GA25089@mtj.dyndns.org>
 <20130422153730.GG18286@dhcp22.suse.cz>
 <20130422154620.GB12543@htj.dyndns.org>
 <20130422155454.GH18286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130422155454.GH18286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Greg Thelen <gthelen@google.com>

Hey,

On Mon, Apr 22, 2013 at 05:54:54PM +0200, Michal Hocko wrote:
> > Oh, if so, I'm happy.  Sorry about being brash on the thread; however,
> > please talk with google memcg people.  They have very different
> > interpretation of what "softlimit" is and are using it according to
> > that interpretation.  If it *is* an actual soft limit, there is no
> > inherent isolation coming from it and that should be clear to
> > everyone.
> 
> We have discussed that for a long time. I will not speak for Greg & Ying
> but from my POV we have agreed that the current implementation will work
> for them with some (minor) changes in their layout.
> As I have said already with a careful configuration (e.i. setting the
> soft limit only where it matters - where it protects an important
> memory which is usually in the leaf nodes) you can actually achieve
> _high_ probability for not being reclaimed after the rework which was not
> possible before because of the implementation which was ugly and
> smelled.

I don't know.  I'm not sure this is a good idea.  It's still
encouraging abuse of the knob even if that's not the intention and
once the usage sticks you end up with something you can't revert
afterwards.  I think it'd be better to make it *very* clear that
"softlimit" can't be used for isolation in any reliable way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
