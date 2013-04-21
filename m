Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 496D56B0005
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 21:53:18 -0400 (EDT)
Received: by mail-da0-f52.google.com with SMTP id j17so206849dan.25
        for <linux-mm@kvack.org>; Sat, 20 Apr 2013 18:53:17 -0700 (PDT)
Date: Sat, 20 Apr 2013 18:53:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130421015312.GD19097@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
 <20130420004221.GB17179@mtj.dyndns.org>
 <CAHH2K0aeNke1NzcnyeeyHH1XvGLGxFG0_fXKAi3JH+HMtYjV=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0aeNke1NzcnyeeyHH1XvGLGxFG0_fXKAi3JH+HMtYjV=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>

Hey, Greg.

On Fri, Apr 19, 2013 at 08:35:12PM -0700, Greg Thelen wrote:
> > As for how actually to clean up this yet another mess in memcg, I
> > don't know.  Maybe introduce completely new knobs - say,
> > oom_threshold, reclaim_threshold, and reclaim_trigger - and alias
> > hardlimit to oom_threshold and softlimit to recalim_trigger?  BTW,
> > "softlimit" should default to 0.  Nothing else makes any sense.
> 
> I agree that the hard limit could be called the oom_threshold.
> 
> The meaning of the term reclaim_threshold is not obvious to me.  I'd
> prefer to call the soft limit a reclaim_target.  System global
> pressure can steal memory from a cgroup until its usage drops to the
> soft limit (aka reclaim_target).  Pressure will try to avoid stealing
> memory below the reclaim target.  The soft limit (reclaim_target) is
> not checked until global pressure exists.  Currently we do not have a
> knob to set a reclaim_threshold, such that when usage exceeds the
> reclaim_threshold async reclaim is queued.  We are not discussing
> triggering anything when soft limit is exceeded.

Yeah, reclaim_target seems like a better name for it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
