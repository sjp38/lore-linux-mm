Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D384600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 18:47:31 -0400 (EDT)
Received: by iwn2 with SMTP id 2so3733595iwn.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:47:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1007261136160.5438@router.home>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
Date: Tue, 27 Jul 2010 07:47:26 +0900
Message-ID: <AANLkTikMMMWcT5Uvv5+80yeGP-uYbW7awQsHL7A7NXmw@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Kukjin Kim <kgene.kim@samsung.com>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, Jul 27, 2010 at 1:40 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Tue, 27 Jul 2010, Minchan Kim wrote:
>
>> This patch registers address of mem_section to memmap itself's page struct's
>> pg->private field. This means the page is used for memmap of the section.
>> Otherwise, the page is used for other purpose and memmap has a hole.
>
> What if page->private just happens to be the value of the page struct?
> Even if that is not possible today, someday someone may add new
> functionality to the kernel where page->pivage == page is used for some
> reason.

I agree.

>
> Checking for PG_reserved wont work?

Okay. It would be better to consider page point itself with PG_reserved.
I will reflect your opinion next version. :)

Thanks, Christoph.




-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
