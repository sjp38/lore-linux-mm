Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A3B06B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 10:39:02 -0500 (EST)
Received: by iyj17 with SMTP id 17so19226241iyj.14
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 07:39:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110108221635.GB23189@cmpxchg.org>
References: <cover.1293982522.git.minchan.kim@gmail.com>
	<39f5e90f69d523d7f69f8ba283e318def6538307.1293982522.git.minchan.kim@gmail.com>
	<20110108221635.GB23189@cmpxchg.org>
Date: Tue, 11 Jan 2011 00:39:00 +0900
Message-ID: <AANLkTi=tkOgiPUSqo3OLVNJrSUrp97sdhQ1Jn0tLhi9Y@mail.gmail.com>
Subject: Re: [PATCH v2 1/7] Introduce delete_from_page_cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 9, 2011 at 7:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Mon, Jan 03, 2011 at 12:44:30AM +0900, Minchan Kim wrote:
>> This function works as just wrapper remove_from_page_cache.
>> The difference is that it decreases page references in itself.
>> So caller have to make sure it has a page reference before calling.
>>
>> This patch is ready for removing remove_from_page_cache.
>>
>> Cc: Christoph Hellwig <hch@infradead.org>
>> Acked-by: Hugh Dickins <hughd@google.com>
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =A0include/linux/pagemap.h | =A0 =A01 +
>> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 +++++++++++++++++
>> =A02 files changed, 18 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 9c66e99..7a1cb49 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *page, struct =
address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff_t inde=
x, gfp_t gfp_mask);
>> =A0extern void remove_from_page_cache(struct page *page);
>> =A0extern void __remove_from_page_cache(struct page *page);
>> +extern void delete_from_page_cache(struct page *page);
>>
>> =A0/*
>> =A0 * Like add_to_page_cache_locked, but used to add newly allocated pag=
es:
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 095c393..1ca7475 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -166,6 +166,23 @@ void remove_from_page_cache(struct page *page)
>> =A0}
>> =A0EXPORT_SYMBOL(remove_from_page_cache);
>>
>> +/**
>> + * delete_from_page_cache - delete page from page cache
>> + *
>
> This empty line is invalid kerneldoc, the argument descriptions must
> follow the short function description line immediately.

Thanks, Hannes.
Will fix.

>
> Otherwise,
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
