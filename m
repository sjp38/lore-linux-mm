Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CD409000BD
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 12:58:16 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-7-git-send-email-glommer@parallels.com>
Date: Sat, 24 Sep 2011 09:58:14 -0700
In-Reply-To: <1316393805-3005-7-git-send-email-glommer@parallels.com> (Glauber
	Costa's message of "Sun, 18 Sep 2011 21:56:44 -0300")
Message-ID: <m24o01khcp.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

Glauber Costa <glommer@parallels.com> writes:

> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
>
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.

I noticed that some other OS known by bash seem to have a rlimit per
process for this. Would that make sense too? Not sure how difficult
your infrastructure would be to extend to that.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
