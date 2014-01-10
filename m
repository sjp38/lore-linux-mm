Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id B5E2A6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:26:23 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so2086550eek.10
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 10:26:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si11508355eew.243.2014.01.10.10.26.22
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 10:26:22 -0800 (PST)
Message-ID: <52D03B13.60401@redhat.com>
Date: Fri, 10 Jan 2014 13:25:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mm: shmem: save one radix tree lookup when truncating
 swapped pages
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org> <1389377443-11755-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/10/2014 01:10 PM, Johannes Weiner wrote:
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
> Reviewed-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
