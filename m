Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38B856B0088
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 03:20:21 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so5185934pbc.38
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 00:20:20 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id yg5si27023714pbc.356.2013.11.25.00.20.16
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 00:20:17 -0800 (PST)
Date: Mon, 25 Nov 2013 17:21:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 2/9] lib: radix-tree: radix_tree_delete_item()
Message-ID: <20131125082102.GB4731@bbox>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385336308-27121-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Nov 24, 2013 at 06:38:21PM -0500, Johannes Weiner wrote:
> Provide a function that does not just delete an entry at a given
> index, but also allows passing in an expected item.  Delete only if
> that item is still located at the specified index.
> 
> This is handy when lockless tree traversals want to delete entries as
> well because they don't have to do an second, locked lookup to verify
> the slot has not changed under them before deleting the entry.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
