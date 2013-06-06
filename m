Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 16D276B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 19:42:15 -0400 (EDT)
Date: Fri, 7 Jun 2013 09:42:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 03/35] dcache: convert dentry_stat.nr_unused to
 per-cpu counters
Message-ID: <20130606234204.GF29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-4-git-send-email-glommer@openvz.org>
 <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org>
 <20130606014509.GN29338@dastard>
 <20130605194801.f9b25abf.akpm@linux-foundation.org>
 <51B0834A.8020606@parallels.com>
 <20130606152546.52f614d852da32d28a0b460f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606152546.52f614d852da32d28a0b460f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Thu, Jun 06, 2013 at 03:25:46PM -0700, Andrew Morton wrote:
> On Thu, 6 Jun 2013 16:40:42 +0400 Glauber Costa <glommer@parallels.com> wrote:
> 
> > +/*
> > + * Here we resort to our own counters instead of using generic per-cpu counters
> > + * for consistency with what the vfs inode code does. We are expected to harvest
> > + * better code and performance by having our own specialized counters.
> > + *
> > + * Please note that the loop is done over all possible CPUs, not over all online
> > + * CPUs. The reason for this is that we don't want to play games with CPUs going
> > + * on and off. If one of them goes off, we will just keep their counters.
> > + *
> > + * glommer: See cffbc8a for details, and if you ever intend to change this,
> > + * please update all vfs counters to match.
> 
> Handling CPU hotplug is really quite simple - see lib/percpu_counter.c

Yes, it is - you're preaching to the choir, Andrew.

But, well, if you want us to add notifiers to optimise the summation
to just the active CPUs, then lets just covert the code to use the
generic per-cpu counters and stop wasting time rehashing tired old
arguments.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
