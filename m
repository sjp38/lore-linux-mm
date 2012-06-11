Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9A4816B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 17:40:13 -0400 (EDT)
Date: Mon, 11 Jun 2012 14:40:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: clean up __count_immobile_pages
Message-Id: <20120611144011.60fd76c8.akpm@linux-foundation.org>
In-Reply-To: <1339380442-1137-1-git-send-email-minchan@kernel.org>
References: <1339380442-1137-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 11 Jun 2012 11:07:22 +0900
Minchan Kim <minchan@kernel.org> wrote:

> __count_immobile_pages naming is rather awkward.
> This patch clean up the function and add comment.

This conflicts with
mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
and its fixes.

> + * This function can race in PageLRU and MIGRATE_MOVABLE can have unmovable
> + * pages so that it might be not exact.

I don't understand this.  Functions race against other functions, not
against a page flag.  Can we have another attempt at this description
please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
