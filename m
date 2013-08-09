Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E21FB6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 18:53:11 -0400 (EDT)
Date: Fri, 9 Aug 2013 15:53:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v3
Message-Id: <20130809155309.71d93380425ef8e19c0ff44c@linux-foundation.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue,  6 Aug 2013 18:44:01 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> This series solves the problem by maintaining a history of pages
> evicted from the inactive list, enabling the VM to tell streaming IO
> from thrashing and rebalance the page cache lists when appropriate.

Looks nice. The lack of testing results is conspicuous ;)

It only really solves the problem in the case where

	size-of-inactive-list < size-of-working-set < size-of-total-memory

yes?  In fact less than that, because the active list presumably
doesn't get shrunk to zero (how far *can* it go?).  I wonder how many
workloads fit into those constraints in the real world.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
