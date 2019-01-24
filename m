Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1213B8E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:23:34 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id w18so1185674ybm.17
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 10:23:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66sor10213984ybr.73.2019.01.24.10.23.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 10:23:30 -0800 (PST)
Date: Thu, 24 Jan 2019 13:23:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190124182328.GA10820@cmpxchg.org>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124170117.GS4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Jan 24, 2019 at 06:01:17PM +0100, Michal Hocko wrote:
> On Thu 24-01-19 11:00:10, Johannes Weiner wrote:
> [...]
> > We cannot fully eliminate a risk for regression, but it strikes me as
> > highly unlikely, given the extremely young age of cgroup2-based system
> > management and surrounding tooling.
> 
> I am not really sure what you consider young but this interface is 4.0+
> IIRC and the cgroup v2 is considered stable since 4.5 unless I
> missrememeber and that is not a short time period in my book.

If you read my sentence again, I'm not talking about the kernel but
the surrounding infrastructure that consumes this data. The risk is
not dependent on the age of the interface age, but on its adoption.

> Changing interfaces now represents a non-trivial risk and so far I
> haven't heard any actual usecase where the current semantic is
> actually wrong.  Inconsistency on its own is not a sufficient
> justification IMO.

It can be seen either way, and in isolation it wouldn't be wrong to
count events on the local level. But we made that decision for the
entire interface, and this file is the odd one out now. From that
comprehensive perspective, yes, the behavior is wrong. It really
confuses people who are trying to use it, because they *do* expect it
to behave recursively.

I'm really having a hard time believing there are existing cgroup2
users with specific expectations for the non-recursive behavior...
