Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2CF906B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 15:39:28 -0400 (EDT)
Date: Wed, 26 Jun 2013 12:39:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: vmscan: Avoid direct reclaim scanning at
 maximum priority
Message-Id: <20130626123925.6a15ce3874fa4b0cc8390a0a@linux-foundation.org>
In-Reply-To: <1372250364-20640-2-git-send-email-mgorman@suse.de>
References: <1372250364-20640-1-git-send-email-mgorman@suse.de>
	<1372250364-20640-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 26 Jun 2013 13:39:23 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Page reclaim at priority 0 will scan the entire LRU as priority 0 is
> considered to be a near OOM condition. Direct reclaim can reach this
> priority while still making reclaim progress. This patch avoids
> reclaiming at priority 0 unless no reclaim progress was made and
> the page allocator would consider firing the OOM killer. The
> user-visible impact is that direct reclaim will not easily reach
> priority 0 and start swapping prematurely.

That's a bandaid.

Priority 0 should be a pretty darn rare condition.  How often is it
occurring, and do you know why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
