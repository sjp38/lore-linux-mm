Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB3436B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 05:45:43 -0400 (EDT)
Date: Tue, 7 Sep 2010 11:45:38 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
Message-ID: <20100907114538.71fc2dcd@basil.nowhere.org>
In-Reply-To: <20100907180354.a8dd5669.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
	<87occa9fla.fsf@basil.nowhere.org>
	<20100907172559.496554d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20100907104635.2a02a1ca@basil.nowhere.org>
	<20100907180354.a8dd5669.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Sep 2010 18:03:54 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:


> Oh, I didn't consider that. Hmm. If x86 really wants to support 1GB
> page, MAX_ORDER should be raised. (I'm sorry if it was already
> disccused.)

That doesn't really work, it requires alignment of all the
zones to 1GB too (not practical) and has a lot of overhead.

Also for the normal case it wouldn't work anyways due to fragmentation.

> > One issue is also that it would be good to be able to decide
> > in advance if the OOM killer is likely triggered (and if yes
> > reject the allocation in the first place). 
> > 
> 
> Checking the amount of memory and swap before starts ? 
> It sounds nice. I'd like to add something.

That would be the simple variant, but perhaps it could 
even consider parallel traffic? (I guess that would
be difficult) Or perhaps bail out early if OOM is likely.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
