Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D79A76B0037
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 20:24:29 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7053581pab.29
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 17:24:29 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ng9si14087702pbc.166.2014.01.12.17.24.27
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 17:24:28 -0800 (PST)
Date: Mon, 13 Jan 2014 10:25:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 4/9] mm: filemap: move radix tree hole searching here
Message-ID: <20140113012506.GN1992@bbox>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389377443-11755-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 01:10:38PM -0500, Johannes Weiner wrote:
> The radix tree hole searching code is only used for page cache, for
> example the readahead code trying to get a a picture of the area
> surrounding a fault.
> 
> It sufficed to rely on the radix tree definition of holes, which is
> "empty tree slot".  But this is about to change, though, as shadow
> page descriptors will be stored in the page cache after the actual
> pages get evicted from memory.
> 
> Move the functions over to mm/filemap.c and make them native page
> cache operations, where they can later be adapted to handle the new
> definition of "page cache hole".
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
