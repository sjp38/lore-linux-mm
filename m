Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 772CF6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 18:49:45 -0400 (EDT)
Date: Fri, 9 Aug 2013 15:49:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 8/9] mm: thrash detection-based file cache sizing
Message-Id: <20130809154943.1663e5f04999e1979886246c@linux-foundation.org>
In-Reply-To: <1375829050-12654-9-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
	<1375829050-12654-9-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue,  6 Aug 2013 18:44:09 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> To accomplish this, a per-zone counter is increased every time a page
> is evicted and a snapshot of that counter is stored as shadow entry in
> the page's now empty page cache radix tree slot.

How do you handle wraparound of that counter on 32-bit machines?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
