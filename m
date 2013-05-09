Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 93C7B6B003C
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:53:33 -0400 (EDT)
Date: Thu, 9 May 2013 14:53:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 20/31] shrinker: Kill old ->shrink API.
Message-ID: <20130509135329.GA11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-21-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368079608-5611-21-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 09, 2013 at 10:06:37AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> There are no more users of this API, so kill it dead, dead, dead and
> quietly bury the corpse in a shallow, unmarked grave in a dark
> forest deep in the hills...
> 
> [ glommer: added flowers to the grave ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
