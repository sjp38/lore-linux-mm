Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 455926B00AC
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 21:27:53 -0500 (EST)
Received: by iwn40 with SMTP id 40so2790796iwn.14
        for <linux-mm@kvack.org>; Sun, 19 Dec 2010 18:27:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101220112227.E566.A69D9226@jp.fujitsu.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
	<20101220112227.E566.A69D9226@jp.fujitsu.com>
Date: Mon, 20 Dec 2010 11:27:48 +0900
Message-ID: <AANLkTimaW7X6w2e=4SvynHQHO-Kv3wXGv4_NCKDsuYRR@mail.gmail.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2010 at 11:21 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> This patch series changes remove_from_page_cache's page ref counting
>> rule. page cache ref count is decreased in remove_from_page_cache.
>> So we don't need call again in caller context.
>>
>> Cc: Nick Piggin <npiggin@suse.de>
>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =A0mm/truncate.c | =A0 =A01 -
>> =A01 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index 9ee5673..8decb93 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mapping=
, struct page *page)
>> =A0 =A0 =A0 =A0* calls cleancache_put_page (and note page->mapping is no=
w NULL)
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 cleancache_flush_page(mapping, page);
>> - =A0 =A0 page_cache_release(page); =A0 =A0 =A0 /* pagecache ref */
>> =A0 =A0 =A0 return 0;
>
> Do we _always_ have stable page reference here? IOW, I can assume

I think so.
Because the page is locked so caller have to hold a ref to unlock it.

> cleancache_flush_page() doesn't cause NULL deref?
>
>
>
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
