Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB2716B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 01:46:38 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5383764iwn.14
        for <linux-mm@kvack.org>; Mon, 05 Jul 2010 22:46:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100706093529.CCD1.A69D9226@jp.fujitsu.com>
References: <20100702125155.69c02f85.akpm@linux-foundation.org>
	<20100705134949.GC13780@csn.ul.ie>
	<20100706093529.CCD1.A69D9226@jp.fujitsu.com>
Date: Tue, 6 Jul 2010 14:46:37 +0900
Message-ID: <AANLkTimk6SwmljTWpIgp_OI_eLP6w8BCWKf-VRUFQ65H@mail.gmail.com>
Subject: Re: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 6, 2010 at 9:36 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hello,
>
>> Ok, that's reasonable as I'm still working on that patch. For example, the
>> patch disabled anonymous page writeback which is unnecessary as the stack
>> usage for anon writeback is less than file writeback.
>
> How do we examine swap-on-file?

bool is_swap_on_file(struct page *page)
{
    struct swap_info_struct *p;
    swp_entry_entry entry;
    entry.val = page_private(page);
    p = swap_info_get(entry);
    return !(p->flags & SWP_BLKDEV)
}

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
