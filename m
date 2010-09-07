Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 029106B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 03:29:30 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 07 Sep 2010 09:29:21 +0200
In-Reply-To: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Tue, 7 Sep 2010 11:45:05 +0900")
Message-ID: <87occa9fla.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> This is a page allcoator based on memory migration/hotplug code.
> passed some small tests, and maybe easier to read than previous one.

Maybe I'm missing context here, but what is the use case for this?

If this works well enough the 1GB page code for x86, which currently
only supports allocating at boot time due to the MAX_ORDER problem,
could be moved over to runtime allocation. This would make
GB pages a lot nicer to use.

I think it would still need declaring a large moveable
area at boot right? (but moveable area is better than
prereserved memory)

On the other hand I'm not sure the VM is really up to speed
in managing such large areas.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
