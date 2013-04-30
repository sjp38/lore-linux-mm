Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 94E116B00E7
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 10:49:54 -0400 (EDT)
Date: Tue, 30 Apr 2013 15:49:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 07/31] shrinker: convert superblock shrinkers to new
 API
Message-ID: <20130430144950.GG6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-8-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-8-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:03AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert superblock shrinker to use the new count/scan API, and
> propagate the API changes through to the filesystem callouts. The
> filesystem callouts already use a count/scan API, so it's just
> changing counters to longs to match the VM API.
> 
> This requires the dentry and inode shrinker callouts to be converted
> to the count/scan API. This is mainly a mechanical change.
> 
> [ glommer: use mult_frac for fractional proportions, build fixes ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>

It's slightly clearer on seeing this patch why you went with long instead
of unsigned long in the previous patch. It matched closer to what the
shrinkers were already doing with their counters and of course they
already understood -1 but as the API is being churned anyway, it would
not hurt to use unsigned long for counters and ULONG_MAX for errors.

I spotted no specific problem with this patch itself and there is some
nice tidy-ups in there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
