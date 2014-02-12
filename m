Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE156B0037
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 06:16:38 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so5681960wes.41
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 03:16:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ll10si10946314wjb.24.2014.02.12.03.16.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 03:16:36 -0800 (PST)
Date: Wed, 12 Feb 2014 11:16:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 05/10] mm: filemap: move radix tree hole searching here
Message-ID: <20140212111631.GS6732@suse.de>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
 <1391475222-1169-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1391475222-1169-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 03, 2014 at 07:53:37PM -0500, Johannes Weiner wrote:
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
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Minchan Kim <minchan@kernel.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
