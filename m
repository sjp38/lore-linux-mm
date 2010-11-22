Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DC3E26B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:49:33 -0500 (EST)
Received: by iwn33 with SMTP id 33so2704459iwn.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:49:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CE95FD7.1060805@redhat.com>
References: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>
	<4CE95FD7.1060805@redhat.com>
Date: Mon, 22 Nov 2010 09:49:32 +0900
Message-ID: <AANLkTimSE2j71uFPCZWBFdau4NE_hmTtTMvUOBWOdMhF@mail.gmail.com>
Subject: Re: [PATCH] vmscan: Make move_active_pages_to_lru more generic
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 3:07 AM, Rik van Riel <riel@redhat.com> wrote:
> On 11/21/2010 09:24 AM, Minchan Kim wrote:
>>
>> Now move_active_pages_to_lru can move pages into active or inactive.
>> if it moves the pages into inactive, it itself can clear PG_acive.
>> It makes the function more generic.
>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index aa4f1cb..bd408b3 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1457,6 +1457,10 @@ static void move_active_pages_to_lru(struct zone
>> *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageLRU(page);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we are de-activating */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is_active_lru(lru))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageActive(page);
>> +
>
> Does that mean we also want code to ensure that pages have
> the PG_active bit set when we add them to an active list?

Yes. the function name is move_"active"_pages_to_lru.
So  caller have to make sure pages have PG_active.

>
> --
> All rights reversed
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
