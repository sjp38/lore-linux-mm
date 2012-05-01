Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C53356B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 15:08:22 -0400 (EDT)
Date: Tue, 1 May 2012 12:08:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/5] refault distance-based file cache sizing
Message-Id: <20120501120819.0af1e54b.akpm@linux-foundation.org>
In-Reply-To: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue,  1 May 2012 10:41:48 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> This series stores file cache eviction information in the vacated page
> cache radix tree slots and uses it on refault to see if the pages
> currently on the active list need to have their status challenged.

So we no longer free the radix-tree node when everything under it has
been reclaimed?  One could create workloads which would result in a
tremendous amount of memory used by radix_tree_node_cachep objects.

So I assume these things get thrown away at some point.  Some
discussion about the life-cycle here would be useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
