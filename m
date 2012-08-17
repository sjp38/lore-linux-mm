Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 63D706B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:26:35 -0400 (EDT)
Message-ID: <502DD54F.3010800@parallels.com>
Date: Fri, 17 Aug 2012 09:23:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/6] memcg: shrink slab during memcg reclaim
References: <1345150459-31170-1-git-send-email-yinghan@google.com>
In-Reply-To: <1345150459-31170-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 08/17/2012 12:54 AM, Ying Han wrote:
> This patch makes target reclaim shrinks slabs in addition to userpages.
> 
> Slab shrinkers determine the amount of pressure to put on slabs based on how
> many pages are on lru (inversely proportional relationship). Calculate the
> lru_pages correctly based on memcg lru lists instead of global lru lists.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

This seems fine from where I stand.

So imagining for an instant we apply this patch, and this patch only.
The behavior we get is that when memcg gets pressure, it will shrink
globally, but it will at least shrink anything.

It is needless to say this is not enough. But I wonder if this isn't
better than no shrinking at all ? Maybe this could be put ontop of the
slab series and be the temporary default while we sort out the whole
shrinkers problem?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
