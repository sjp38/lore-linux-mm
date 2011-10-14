Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AF2286B0034
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 22:12:30 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
References: <1318511382-31051-1-git-send-email-glommer@parallels.com>
	<20111013.160031.605700447623532119.davem@davemloft.net>
Date: Thu, 13 Oct 2011 19:12:29 -0700
In-Reply-To: <20111013.160031.605700447623532119.davem@davemloft.net> (David
	Miller's message of "Thu, 13 Oct 2011 16:00:31 -0400 (EDT)")
Message-ID: <m2d3e01fua.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

David Miller <davem@davemloft.net> writes:
>
> Make this evaluate into exactly the same exact code stream we have
> now when the memory cgroup feature is not in use, which will be the
> majority of users.

One possible way may be to guard it with static_branch() for 
no limit per cgroup set. That should be as near as practically
possible to the original code.

BTW the thing that usually worries me more is the cache line behaviour
when the feature is in use. In the past some of the namespace patches
have created some extremly hot global cache lines, that hurt on larger
systems (for example the Unix socket regression from uid namespaces that
is still not completly fixed). It would be good to double check that all
important state is distributed properly.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
