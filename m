Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 36B856B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:42:50 -0400 (EDT)
Date: Thu, 9 May 2013 14:42:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 11/31] list_lru: per-node list infrastructure
Message-ID: <20130509134246.GX11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-12-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368079608-5611-12-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 09, 2013 at 10:06:28AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that we have an LRU list API, we can start to enhance the
> implementation.  This splits the single LRU list into per-node lists
> and locks to enhance scalability. Items are placed on lists
> according to the node the memory belongs to. To make scanning the
> lists efficient, also track whether the per-node lists have entries
> in them in a active nodemask.
> 
> [ glommer: fixed warnings ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>

You've committed to addressing the problem of the size of struct
list_lru so

Acked-by: Mel Gorman <mgorman@suse.de>

It would still be nice though if the size problem was highlighted with
either a comment and/or a changelog entry describing the problem and how
you plan to address it in case it takes a long time to get fixed. If the
problem persists and we get a bug report about allocation warnings at
mount time then the notes will be available.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
