Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 072896B0047
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:12:30 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:12:21 -0400 (EDT)
Message-Id: <20111013.161221.1969725742975317077.davem@davemloft.net>
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
From: David Miller <davem@davemloft.net>
In-Reply-To: <4E9744A6.5010101@parallels.com>
References: <1318511382-31051-1-git-send-email-glommer@parallels.com>
	<20111013.160031.605700447623532119.davem@davemloft.net>
	<4E9744A6.5010101@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 14 Oct 2011 00:05:58 +0400

> Also, I kind of dispute the affirmation that !cgroup will encompass
> the majority of users, since cgroups is being enabled by default by
> most vendors. All systemd based systems use it extensively, for
> instance.

I will definitely advise people against this, since the cost of having
this on by default is absolutely non-trivial.

People keep asking every few releases "where the heck has my performance
gone" and it's because of creeping features like this.  This socket
cgroup feature is a prime example of where that kind of stuff comes
from.

I really get irritated when people go "oh, it's just one indirect
function call" and "oh, it's just one more pointer in struct sock"

We work really hard to _remove_ elements from structures and make them
smaller, and to remove expensive operations from the fast paths.

It might take someone weeks if not months to find a way to make a
patch which compensates for the extra overhead your patches are adding.

And I don't think you fully appreciate that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
