Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 144AE6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:54:18 -0400 (EDT)
Date: Tue, 4 Sep 2012 16:54:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Message-ID: <20120904145414.GC15683@dhcp22.suse.cz>
References: <1346687211-31848-1-git-send-email-glommer@parallels.com>
 <20120903170806.GA21682@dhcp22.suse.cz>
 <5045BD25.10301@parallels.com>
 <20120904130905.GA15683@dhcp22.suse.cz>
 <504601B8.2050907@parallels.com>
 <20120904143552.GB15683@dhcp22.suse.cz>
 <50461241.5010300@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50461241.5010300@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Tue 04-09-12 18:37:53, Glauber Costa wrote:
> On 09/04/2012 06:35 PM, Michal Hocko wrote:
> > On Tue 04-09-12 17:27:20, Glauber Costa wrote:
> >> On 09/04/2012 05:09 PM, Michal Hocko wrote:
> >>> Not really. Do it slowly means that somebody actually _notices_ that
> >>> something is about to change and they have a lot of time for that. This
> >>> will be really hard with the config option saying N by default.  People
> >>> will ignore that until it's too late.
> >>> We are interested in those users who would keep the config default N and
> >>> they are (ab)using use_hierarchy=0 in a way which is hard/impossible to
> >>> fix. This is where distributions might help and they should IMHO but why
> >>> to put an additional code into upstream? Isn't it sufficient that those
> >>> who would like to help (and take the risk) would just take the patch?
> >>
> >> At least Fedora, seem to frown upon heavily at non-upstream patches.
> > 
> > OK, so what about the following approach instead? We won't change the
> > default but rather shout at people when they actually create subtrees
> > with use_hierarchy==0. This shouldn't make pointless noise. I do not
> > remember whether we have considered this previously so sorry if this was
> > shot down as well.
> 
> The warning is fine, but just shouting won't achieve nothing. 

I am not so sure about that. Users are usually quite sensitive to WARN
messages and I can put this kind of patch into older code bases as
well because it cannot introduce any regression. This could produce
a much bigger testing base. All we want to achieve at this stage is
to find out whether we can get rid of the knob and help people to use
use_hierarchy=1, right?

> I believe it would be really great to have a way to turn the default
> to 1 - and stop the shouting.

We already can. You can use /etc/cgconfig (if you are using libcgroup)
or do it manually.

> Even if you are doing it in OpenSUSE as a patch, an upstream patch means
> at least that every distribution is using the same patch, and those who
> rebase will just flip the config.
> 
> I'd personally believe merging both our patches together would achieve a
> good result.

I am still not sure we want to add a config option for something that is
meant to go away. But let's see what others think.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
