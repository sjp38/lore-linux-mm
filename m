Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id BB4446B011C
	for <linux-mm@kvack.org>; Wed, 20 May 2015 10:12:19 -0400 (EDT)
Received: by wibt6 with SMTP id t6so61700214wib.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 07:12:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg1si9857323wjc.136.2015.05.20.07.12.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 07:12:18 -0700 (PDT)
Date: Wed, 20 May 2015 16:12:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150520141216.GD28678@dhcp22.suse.cz>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-3-git-send-email-mgorman@suse.de>
 <1432129666.15239.22.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432129666.15239.22.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>

[It seems Ben hasn't made it into the CC list - the thread starts here:
http://article.gmane.org/gmane.linux.kernel.cgroups/13345]

On Wed 20-05-15 06:47:46, Davidlohr Bueso wrote:
> On Wed, 2015-05-20 at 13:50 +0100, Mel Gorman wrote:
> > +config MEMCG_DEFAULT_ENABLED
> > +	bool "Automatically enable memory resource controller"
> > +	default y
> > +	depends on MEMCG
> > +	help
> > +	  The memory controller has some overhead even if idle as resource
> > +	  usage must be tracked in case a group is created and a process
> > +	  migrated. As users may not be aware of this and the cgroup_disable=
> > +	  option, this config option controls whether it is enabled by
> > +	  default. It is assumed that someone that requires the controller
> > +	  can find the cgroup_enable= switch.
> > +
> > +	  Say N if unsure. This is default Y to preserve oldconfig and
> > +	  historical behaviour.
> 
> Out of curiosity, how do you expect distros to handle this? I mean, this
> is a pretty general functionality and customers won't want to be
> changing kernels (they may or may not use memcg). iow, will this ever be
> disabled?

This was exactly my question during the previous iteration. Only those
distribution which either haven't enabled CONFIG_MEMCG at all and want
to start or those which have enabled it but have it runtime disabled
(e.g. Debian) would benefit from such a change. Ben has shown interest
in such a patch because he could drop Debian specific patch. But I am
not sure it still makes sense when the overal runtime overhead is quite
low even for microbenchmarks.

I would personally prefer to not take the patch because we have quite
some config options already but if Debian and potentially others insist
on their current (runtime disabled) policy then it has some merit
to merge it. The interface could be better I guess because cgroups
doesn't allow to enable/disable any other controllers so something like
swapaccount= (e.g. memcgaccount) would be more appropriate.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
