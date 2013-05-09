Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id F39D36B003B
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:43:46 -0400 (EDT)
Date: Thu, 9 May 2013 14:43:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 14/31] xfs: convert buftarg LRU to generic code
Message-ID: <20130509134343.GY11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-15-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1368079608-5611-15-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 09, 2013 at 10:06:31AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the buftarg LRU to use the new generic LRU list and take
> advantage of the functionality it supplies to make the buffer cache
> shrinker node aware.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> 
> Conflicts with 3b19034d4f:
> 	fs/xfs/xfs_buf.c

You can dump this Conflicts message

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
