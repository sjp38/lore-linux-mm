Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 43BAB6B0036
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:41:00 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id w62so4450880wes.6
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:40:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u49si1653826eep.190.2014.01.10.11.40.59
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 11:40:59 -0800 (PST)
Message-ID: <52D04C8D.60701@redhat.com>
Date: Fri, 10 Jan 2014 14:39:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 5/9] mm + fs: prepare for non-page entries in page cache
 radix trees
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org> <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-6-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/10/2014 01:10 PM, Johannes Weiner wrote:
> shmem mappings already contain exceptional entries where swap slot
> information is remembered.
> 
> To be able to store eviction information for regular page cache,
> prepare every site dealing with the radix trees directly to handle
> entries other than pages.
> 
> The common lookup functions will filter out non-page entries and
> return NULL for page cache holes, just as before.  But provide a raw
> version of the API which returns non-page entries as well, and switch
> shmem over to use it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
