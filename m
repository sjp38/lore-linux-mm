Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 595166B00C5
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 07:23:16 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so2815562wib.8
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 04:23:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <xa1tehm8yfmb.fsf@mina86.com>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
	<xa1tehm8yfmb.fsf@mina86.com>
Date: Tue, 11 Sep 2012 20:23:14 +0900
Message-ID: <CAH9JG2V-ATcfe5_YkH6sMmm5UZFHt2SYBWnCNSpfsncGFU96mg@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous allocation
 instead of migration
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On 9/11/12, Michal Nazarewicz <mina86@mina86.com> wrote:
>
> On Tue, Sep 11 2012, Minchan Kim wrote:
>> This patch drops clean cache pages instead of migration during
>> alloc_contig_range() to minimise allocation latency by reducing the
>> amount
>> of migration is necessary. It's useful for CMA because latency of
>> migration
>> is more important than evicting the background processes working set.
>> In addition, as pages are reclaimed then fewer free pages for migration
>> targets are required so it avoids memory reclaiming to get free pages,
>> which is a contributory factor to increased latency.
>>
>> * from v1
>>   * drop migrate_mode_t
>>   * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support =
-
>> Mel
>>
>> I measured elapsed time of __alloc_contig_migrate_range which migrates
>> 10M in 40M movable zone in QEMU machine.
>>
>> Before - 146ms, After - 7ms
>>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
Tested-by: Kyungmin Park <kyungmin.park@samsung.com>
>
> Thanks!
>
> --
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
> ..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz =
   (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
