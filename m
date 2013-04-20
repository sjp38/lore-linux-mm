Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B566B6B0002
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 20:42:31 -0400 (EDT)
Received: by mail-ia0-f180.google.com with SMTP id t29so769438iag.11
        for <linux-mm@kvack.org>; Fri, 19 Apr 2013 17:42:31 -0700 (PDT)
Date: Fri, 19 Apr 2013 17:42:21 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130420004221.GB17179@mtj.dyndns.org>
References: <20130420002620.GA17179@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130420002620.GA17179@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Fri, Apr 19, 2013 at 05:26:20PM -0700, Tejun Heo wrote:
> If such actual soft limit is desired (I don't know, it just seems like
> a very fundamental / logical feature to me), please don't try to
> somehow overload "softlimit".  They are two fundamentally different
> knobs, both make sense in their own ways, and when you stop confusing
> the two, there's nothing ambiguous about what what each knob means in
> hierarchical situations.  This goes the same for the "untrusted" flag
> Ying told me, which seems like another confused way to overload two
> meanings onto "softlimit".  Don't overload!

As for how actually to clean up this yet another mess in memcg, I
don't know.  Maybe introduce completely new knobs - say,
oom_threshold, reclaim_threshold, and reclaim_trigger - and alias
hardlimit to oom_threshold and softlimit to recalim_trigger?  BTW,
"softlimit" should default to 0.  Nothing else makes any sense.

Maybe you can gate it with "sane_behavior" flag or something.  I don't
know.  It's your mess to clean up.  :P

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
