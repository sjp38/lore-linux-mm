Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 682E56B003B
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:09:05 -0400 (EDT)
Date: Thu, 13 Oct 2011 16:08:54 -0400 (EDT)
Message-Id: <20111013.160854.1765661520007592071.davem@davemloft.net>
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

> On 10/14/2011 12:00 AM, David Miller wrote:
>> That imposes a new non-trivial cost, in fast paths, even when people
>> do not use your feature.
> Well, there is a cost, but all past submissions included round trip
> benchmarks.
> In none of them I could see any significant slowdown.

Did you try millions of sockets doing all kinds of different accesses?

Did you check the nanosecond latency of operations over loopback so
that the real cost of you change can be isolated and thus measured
properly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
