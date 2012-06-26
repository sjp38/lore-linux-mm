Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id EC22D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:32:56 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so524128pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:32:56 -0700 (PDT)
Date: Tue, 26 Jun 2012 11:32:52 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
Message-ID: <20120626183252.GS3869@google.com>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
 <20120626181209.GR3869@google.com>
 <4FE9FDCC.80000@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9FDCC.80000@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Jun 26, 2012 at 10:22:04PM +0400, Glauber Costa wrote:
> I would agree with you if we were changing a fundamental algorithm,
> with no way to resort back to a default setup. We are not removing any
> functionality whatsoever here.
> 
> I would agree with you if we were actually documenting explicitly
> that this is an expected default behavior.
> 
> But we never made the claim that use_hierarchy would default to 0.
> 
> Well, we seldom make claims about default values of any tunables. We
> just expect them to be reasonable values, and we seem to agree that
> this is, indeed, reasonable.

No, we can't change behavior in this major way silently.  Any change
of this scale must be explicit.  The behavior change is not only major
but also subtle at the same time.  If a user is using flat hierarchy
and then boot a new kernel, the user suddenly gets hierarchical
accounting which may or may not cause noticeable problem immediately
and would be difficult like hell to chase down and diagnose.

I don't mind how global switch is implemented but the flip should be
explicit no matter what.  This is something we simply CAN NOT do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
