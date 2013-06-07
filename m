Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 26E7B6B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:15:03 -0400 (EDT)
Date: Fri, 7 Jun 2013 16:15:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v10 00/35] kmemcg shrinkers
Message-ID: <20130607141500.GH8117@dhcp22.suse.cz>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <20130605160721.da995af82eb247ccf8f8537f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160721.da995af82eb247ccf8f8537f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>

On Wed 05-06-13 16:07:21, Andrew Morton wrote:
[...]
> This patchset is huge.

yes it is really huge which is made it lower on the todo list because
other things always preempted it.
 
> My overall take is that the patchset is massive and intrusive and scary
> :( I'd like to see more evidence that the memcg people (mhocko, hannes,
> kamezawa etc) have spent quality time reviewing and testing this code. 
> There really is a lot of it!

I only following discussions right now, and I wasn't even able to catch
up on those. I plan to review memcg parts soon, but cannot give any
estimate. I am sorry for that but the time doesn't allow me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
