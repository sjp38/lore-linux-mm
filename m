Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B47D26B00D8
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 09:03:37 -0400 (EDT)
Date: Tue, 30 Apr 2013 14:03:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 01/31] super: fix calculation of shrinkable objects
 for small numbers
Message-ID: <20130430130330.GA6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-2-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-2-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Sat, Apr 27, 2013 at 03:18:57AM +0400, Glauber Costa wrote:
> The sysctl knob sysctl_vfs_cache_pressure is used to determine which
> percentage of the shrinkable objects in our cache we should actively try
> to shrink.
> 
> It works great in situations in which we have many objects (at least
> more than 100), because the aproximation errors will be negligible. But
> if this is not the case, specially when total_objects < 100, we may end
> up concluding that we have no objects at all (total / 100 = 0,  if total
> < 100).
> 
> This is certainly not the biggest killer in the world, but may matter in
> very low kernel memory situations.
> 
> [ v2: fix it for all occurrences of sysctl_vfs_cache_pressure ]
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
