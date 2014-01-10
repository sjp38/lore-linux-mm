Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE1AC6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:59:35 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l18so3627959wgh.5
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:59:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z2si1923968wix.53.2014.01.10.11.59.34
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 11:59:35 -0800 (PST)
Message-ID: <52D0488B.9080806@redhat.com>
Date: Fri, 10 Jan 2014 14:22:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 4/9] mm: filemap: move radix tree hole searching here
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org> <1389377443-11755-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-5-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/10/2014 01:10 PM, Johannes Weiner wrote:
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

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
