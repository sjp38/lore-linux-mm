Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 668C86B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 16:38:06 -0400 (EDT)
Date: Fri, 17 May 2013 16:37:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/5] mm: pagevec: Defer deciding what LRU to add a page
 to until pagevec drain time
Message-ID: <20130517203744.GA15721@cmpxchg.org>
References: <1368784087-956-1-git-send-email-mgorman@suse.de>
 <1368784087-956-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368784087-956-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Fri, May 17, 2013 at 10:48:04AM +0100, Mel Gorman wrote:
> mark_page_accessed cannot activate an inactive page that is located on
> an inactive LRU pagevec. Hints from filesystems may be ignored as a
> result. In preparation for fixing that problem, this patch removes the
> per-LRU pagevecs and leaves just one pagevec. The final LRU the page is
> added to is deferred until the pagevec is drained.
> 
> This means that fewer pagevecs are available and potentially there is
> greater contention on the LRU lock. However, this only applies in the case
> where there is an almost perfect mix of file, anon, active and inactive
> pages being added to the LRU. In practice I expect that we are adding
> stream of pages of a particular time and that the changes in contention
> will barely be measurable.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
