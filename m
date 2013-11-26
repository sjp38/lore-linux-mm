Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 02B406B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 19:57:32 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so6645531pdj.11
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:57:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ru9si29220370pbc.48.2013.11.25.16.57.30
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 16:57:31 -0800 (PST)
Date: Mon, 25 Nov 2013 16:57:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v6
Message-Id: <20131125165729.3ad409506fb6db058d88c258@linux-foundation.org>
In-Reply-To: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 24 Nov 2013 18:38:19 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> This series solves the problem by maintaining a history of pages
> evicted from the inactive list, enabling the VM to detect frequently
> used pages regardless of inactive list size and facilitate working set
> transitions.

It's a very readable patchset - thanks for taking the time to do that.

> 31 files changed, 1253 insertions(+), 401 deletions(-)

It's also a *ton* of stuff.  More code complexity, larger kernel data
structures.  All to address a quite narrow class of workloads on a
relatively small window of machine sizes.  How on earth do we decide
whether it's worth doing?

Also, what's the memcg angle?  This is presently a global thing - do
you think we're likely to want to make it per-memcg in the future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
