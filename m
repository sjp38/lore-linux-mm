Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B5C6F6B005A
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 23:41:21 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/6] memcg: vfs isolation in memory cgroup
References: <1345150417-30856-1-git-send-email-yinghan@google.com>
	<502D61E1.8040704@redhat.com> <20120816234157.GB2776@devil.redhat.com>
	<502DD35F.7080009@parallels.com>
	<CALWz4iw444F+odvnbrS_zfN_cNr0g+n3QBBTBtDGwZ8iJ89ujA@mail.gmail.com>
Date: Sat, 18 Aug 2012 20:41:20 -0700
In-Reply-To: <CALWz4iw444F+odvnbrS_zfN_cNr0g+n3QBBTBtDGwZ8iJ89ujA@mail.gmail.com>
	(Ying Han's message of "Thu, 16 Aug 2012 22:40:02 -0700")
Message-ID: <m2vcgf8s67.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Ying Han <yinghan@google.com> writes:
>
> I haven't thought about the NUMA and node awareness for the shrinkers,
> and that sounds like something
> beyond than the problem I am trying to solve here. I might need to
> think a bit more of how that fits into the problem you described.

The memory failure code would also benefit from more directed slab
(especially d/icache) freeing method. Right now if it wants to hard/soft
offline a slab page it has to take the big hammer and free as much as it
can, just in the hope to free that one page.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
