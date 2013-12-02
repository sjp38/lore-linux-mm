Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 73B236B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 17:25:18 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id u57so7114426wes.9
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:25:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id kb10si29956410wjc.152.2013.12.02.14.25.17
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 14:25:17 -0800 (PST)
Message-ID: <529D0896.2090707@redhat.com>
Date: Mon, 02 Dec 2013 17:24:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/9] lib: radix-tree: radix_tree_delete_item()
References: <1386012108-21006-1-git-send-email-hannes@cmpxchg.org> <1386012108-21006-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1386012108-21006-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 12/02/2013 02:21 PM, Johannes Weiner wrote:
> Provide a function that does not just delete an entry at a given
> index, but also allows passing in an expected item.  Delete only if
> that item is still located at the specified index.
> 
> This is handy when lockless tree traversals want to delete entries as
> well because they don't have to do an second, locked lookup to verify
> the slot has not changed under them before deleting the entry.
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
