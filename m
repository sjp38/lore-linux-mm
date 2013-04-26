Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id C9CD66B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 07:51:24 -0400 (EDT)
Date: Fri, 26 Apr 2013 13:51:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: softlimit on internal nodes
Message-ID: <20130426115120.GG31157@dhcp22.suse.cz>
References: <20130420031611.GA4695@dhcp22.suse.cz>
 <20130421022321.GE19097@mtj.dyndns.org>
 <20130421124554.GA8473@dhcp22.suse.cz>
 <20130422043939.GB25089@mtj.dyndns.org>
 <20130422151908.GF18286@dhcp22.suse.cz>
 <20130422155703.GC12543@htj.dyndns.org>
 <20130422162012.GI18286@dhcp22.suse.cz>
 <20130422183020.GF12543@htj.dyndns.org>
 <20130423092944.GA8001@dhcp22.suse.cz>
 <20130423170900.GH12543@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423170900.GH12543@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>

On Tue 23-04-13 10:09:00, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Apr 23, 2013 at 11:29:56AM +0200, Michal Hocko wrote:
> > Ohh, well and we are back in the circle again. Nobody is proposing
> > overloading soft reclaim for any bottom-up (if that is what you mean by
> > your opposite direction) pressure handling.
> > 
> > > You're making it a point control rather than range one.
> > 
> > Be more specific here, please?
> > 
> > > Maybe you can define some twisted rules serving certain specific use
> > > case, but it's gonna be confusing / broken for different use cases.
> > 
> > Tejun, your argumentation is really hand wavy here. Which use cases will
> > be broken and which one will be confusing. Name one for an illustration.
> > 
> > > You're so confused that you don't even know you're confused.
> > 
> > Yes, you keep repeating that. But you haven't pointed out any single
> > confusing use case so far. Please please stop this, it is not productive.
> > We are still talking about using soft limit to control overcommit
> > situation as gracefully as possible. I hope we are on the same page
> > about that at least.
> 
> Hmmm... I think I was at least somewhat clear on my points.  I'll try
> again.  Let's see if I can at least make you understand what my point
> is.  Maybe some diagrams will help.

Maybe I should have been more explicit about this but _yes I do agree_
that a separate limit would work as well. I just do not want to
introduce yet-another-limit unless it is _really_ necessary. We have up
to 4 of them depending on the configuration which is a lot already. And
the new knob would certainly become a guarantee what ever words we use
with more expectations than soft limit and I am afraid that won't be
that easy (unless we provide a poison pill for emergency cases).

My rework was based on the soft limit semantic which we had for quite
some time and tried to enhance it to be more useful. I do understand
your concerns about the cleanness of the interface I just objected that
the new meaning doesn't add any guarantee. The implementation just tries
to be clever who to reclaim to handle an external pressure (for which
the soft limit has been introduced in the first place) while using hints
from the limit as much as possible .

Anyway, I will think about cons and pros of the new limit. I think we
shouldn't block the first 3 patches in the series which keep the current
semantic and just change the internals to do the same thing. Do you
agree?

We can discuss single vs. new knob in the mean time of course.

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
