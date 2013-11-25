Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 613266B008A
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 03:21:11 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so5032203pdi.33
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 00:21:11 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id z1si27060850pbn.301.2013.11.25.00.21.06
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 00:21:07 -0800 (PST)
Date: Mon, 25 Nov 2013 17:21:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 3/9] mm: shmem: save one radix tree lookup when
 truncating swapped pages
Message-ID: <20131125082152.GC4731@bbox>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385336308-27121-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Nov 24, 2013 at 06:38:22PM -0500, Johannes Weiner wrote:
> Page cache radix tree slots are usually stabilized by the page lock,
> but shmem's swap cookies have no such thing.  Because the overall
> truncation loop is lockless, the swap entry is currently confirmed by
> a tree lookup and then deleted by another tree lookup under the same
> tree lock region.
> 
> Use radix_tree_delete_item() instead, which does the verification and
> deletion with only one lookup.  This also allows removing the
> delete-only special case from shmem_radix_tree_replace().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Nice cleanup!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
