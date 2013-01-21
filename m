Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 429B76B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 11:08:38 -0500 (EST)
Message-ID: <50FD6815.90900@parallels.com>
Date: Mon, 21 Jan 2013 20:08:53 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Johannes Weiner <hannes@cmpxchg.org>

On 11/28/2012 03:14 AM, Dave Chinner wrote:
> [PATCH 09/19] list_lru: per-node list infrastructure
> 
> This makes the generic LRU list much more scalable by changing it to
> a {list,lock,count} tuple per node. There are no external API
> changes to this changeover, so is transparent to current users.
> 
> [PATCH 10/19] shrinker: add node awareness
> [PATCH 11/19] fs: convert inode and dentry shrinking to be node
> 
> Adds a nodemask to the struct shrink_control for callers of
> shrink_slab to set appropriately for their reclaim context. This
> nodemask is then passed by the inode and dentry cache reclaim code
> to the generic LRU list code to implement node aware shrinking.

I have a follow up question that popped up from a discussion between me
and my very American friend Johnny Wheeler, also known as Johannes
Weiner (CC'd). I actually remember we discussing this, but don't fully
remember the outcome. And since I can't find it anywhere, it must have
been in a media other than e-mail. So I thought it would do no harm in
at least documenting it...

Why are we doing this per-node, instead of per-zone?

It seems to me that the goal is to collapse all zones of a node into a
single list, but since the number of zones is not terribly larger than
the number of nodes, and zones is where the pressure comes from, what do
we really gain from this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
