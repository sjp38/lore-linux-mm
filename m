Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 6439B6B0131
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:39:54 -0400 (EDT)
Date: Tue, 30 Apr 2013 18:39:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 13/31] fs: convert inode and dentry shrinking to be
 node aware
Message-ID: <20130430173947.GM6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-14-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-14-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Sat, Apr 27, 2013 at 03:19:09AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that the shrinker is passing a nodemask in the scan control
> structure, we can pass this to the the generic LRU list code to
> isolate reclaim to the lists on matching nodes.
> 
> This requires a small amount of refactoring of the LRU list API,
> which might be best split out into a separate patch.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

Signed-off missing but otherwise

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
