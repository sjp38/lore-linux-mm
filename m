Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9583C6B0037
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:07:40 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:07:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 04/35] dentry: move to per-sb LRU locks
Message-Id: <20130605160738.fe46654369044b6d94eadd1b@linux-foundation.org>
In-Reply-To: <1370287804-3481-5-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-5-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon,  3 Jun 2013 23:29:33 +0400 Glauber Costa <glommer@openvz.org> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> With the dentry LRUs being per-sb structures, there is no real need
> for a global dentry_lru_lock. The locking can be made more
> fine-grained by moving to a per-sb LRU lock, isolating the LRU
> operations of different filesytsems completely from each other.

What's the point to this patch?  Is it to enable some additional
development, or is it a standalone performance tweak?

If the latter then the patch obviously makes this dentry code bloatier
and straight-line slower.  So we're assuming that the multiprocessor
contention-avoidance benefits will outweigh that cost.  Got any proof
of this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
