Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 94C646B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:14:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so360853dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:54 -0700 (PDT)
Date: Tue, 26 Jun 2012 12:14:50 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120626191450.GT3869@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626185542.GE27816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626185542.GE27816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

Hello, Johannes.

On Tue, Jun 26, 2012 at 08:55:42PM +0200, Johannes Weiner wrote:
> > 2. Mark flat hierarchy deprecated and produce a warning message if
> >    memcg is mounted w/o hierarchy option for a year or two.
> 
> I think most of us assume that the common case is either not nesting
> directories or still working with hierarchy support actually enabled.

How do we know that?  At least from what I see from blkcg usage,
people do crazy stuff when given crazy interface and we've been
providing completely crazy interface for years.  We cannot switch that
implicitly - the changed default behavior is drastically different and
even could be difficult to chase down.  Transitions towards good
behavior are good but they have to be explicit.

> I would hate if people had to jump through hoops to get the only
> behaviour we want to end up supporting and to not get yelled at, it
> sends all the wrong signals.

It is inconvenient but that's the price that we have to pay for having
been stupid.  Kernel flipping behavior implicitly is far worse than
any such inconvenience.

These default behavior flips are something is better handled by
distros / admins than kernel itself.  They can orchestrate the
userland infrastructure and handle and communicate these flips far
better than kernel alone can do.  We can't send out mails to flat
hierarchy users after all.  That's the reason why I'm suggesting mount
option which can't be flipped (sans remount but that's going away too)
once the system is configured by the distro or admin.

The kernel should nudge mainline users towards new behavior while
providing distros / admins a way to move to the new behavior.  The
kernel itself can't flip it like that.

> > 3. After the existing users had enough chance to move away from flat
> >    hierarchy, rip out flat hierarchy code and error if hierarchy
> >    option is not specified.
> 
> This description sounds much more sane than what we are actually
> trying to ban, which is not a flat structure, but treating groups with
> nested directories as equal siblings.

Ah... yeah, flat hierarchy probably is the wrong way to describe it.
I don't know.  Superficial hierarchy?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
