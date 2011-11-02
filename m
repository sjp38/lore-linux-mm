Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF6A06B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 12:36:08 -0400 (EDT)
Date: Wed, 2 Nov 2011 17:35:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] vmscan: promote shared file mapped pages
Message-ID: <20111102163527.GK19965@cmpxchg.org>
References: <20110808110658.31053.55013.stgit@localhost6>
 <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
 <4E3FD403.6000400@parallels.com>
 <20111102163056.GG19965@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111102163056.GG19965@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Wed, Nov 02, 2011 at 05:30:56PM +0100, Johannes Weiner wrote:
> Tipping the balance for inactive list rotation has been there from the
> beginning, but I don't quite understand why.  It probably was not a
> problem as the conditions for inactive cycling applied to both file
> and anon equally, but with used-once detection for file and deferred
> file writeback from direct reclaim, we tend to cycle more file pages
> on the inactive list than anonymous ones.  Those rotated pages should
> be a signal to favor file reclaim, though.

[...] should NOT be a signal [...]

obviously.  Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
