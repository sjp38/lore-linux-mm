Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 31E7E6B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 10:45:05 -0400 (EDT)
Message-ID: <502E58DF.4000809@redhat.com>
Date: Fri, 17 Aug 2012 10:44:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
References: <1345150417-30856-1-git-send-email-yinghan@google.com> <502D61E1.8040704@redhat.com> <20120816234157.GB2776@devil.redhat.com> <502DD35F.7080009@parallels.com> <20120817075440.GD2776@devil.redhat.com>
In-Reply-To: <20120817075440.GD2776@devil.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@parallels.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 03:54 AM, Dave Chinner wrote:

> IOWs, it's still the same count/scan shrinker interface, just with
> all the LRU and shrinker bits abstracted and implemented in common
> code. The generic LRU abstraction is that it only knows about the
> list-head in the structure that is passed to it, and it passes that
> listhead to the per-object callbacks for the subsystem to do the
> specific work that is needed.

This will make it very easy to iterate over the slab object
LRUs in my "reclaim from the highest score LRU" patch set.

That in turn will allow us to properly balance pressure between
cgroup and non-cgroup object LRUs, between the LRUs of various
superblocks, etc...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
