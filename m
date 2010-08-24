Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 04FC360080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:20:00 -0400 (EDT)
Received: by iwn33 with SMTP id 33so5061800iwn.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 18:19:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1008231217100.9840@router.home>
References: <1282580114-2136-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1008231140320.9496@router.home>
	<20100823170610.GB2304@barrios-desktop>
	<alpine.DEB.2.00.1008231217100.9840@router.home>
Date: Tue, 24 Aug 2010 10:19:59 +0900
Message-ID: <AANLkTi=bbRHJ1Wzmm9FTiYzDyKj6PFGWmFqCZNHTNgEb@mail.gmail.com>
Subject: Re: [PATCH] compaction: fix COMPACTPAGEFAILED counting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 2:17 AM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 24 Aug 2010, Minchan Kim wrote:
>
>> On Mon, Aug 23, 2010 at 11:41:49AM -0500, Christoph Lameter wrote:
>> > On Tue, 24 Aug 2010, Minchan Kim wrote
>> >
>> > > This patch introude new argument 'cleanup' to migrate_pages.
>> > > Only if we set 1 to 'cleanup', migrate_page will clean up the lists.
>> > > Otherwise, caller need to clean up the lists so it has a chance to postprocess
>> > > the pages.
>> >
>> > Could we simply make migrate_pages simply not do any cleanup?
>> > Caller has to call putback_lru_pages()?
>> >
>> Hmm. maybe I misunderstood your point.
>> Your point is that let's make whole caller of migrate_pagse has a responsibility
>> of clean up the list?
>
> Yes. All callers would be responsible for cleanup.

Yes. I hoped it but try to maintain API semantics.
But if you agree to change it, I will do it.
Will repost.
Thanks, Christoph.



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
