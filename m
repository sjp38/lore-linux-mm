Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E15136B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:10:19 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7436373iwn.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:10:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100831095542.87CA.A69D9226@jp.fujitsu.com>
References: <AANLkTinqm0o=AfmgFy+SpZ1mrdekRnjeXvs_7=OcLii8@mail.gmail.com>
	<AANLkTikbs9sUVLhE4sWWVw8uEqY=v6SCdJ_6FLhXY6HW@mail.gmail.com>
	<20100831095542.87CA.A69D9226@jp.fujitsu.com>
Date: Tue, 31 Aug 2010 10:10:17 +0900
Message-ID: <AANLkTi=NsY9T19rXuBWmeZ3Z2ayA=tHZ1+e=cEXuKVAt@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi, KOSAKI.

On Tue, Aug 31, 2010 at 9:56 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 1b145e6..0b8a3ce 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1747,7 +1747,7 @@ static void shrink_zone(int priority, struct zone =
*zone,
>> =A0 =A0 =A0 =A0 =A0* Even if we did not try to evict anon pages at all, =
we want to
>> =A0 =A0 =A0 =A0 =A0* rebalance the anon lru active/inactive ratio.
>> =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
>> + =A0 =A0 =A0 if (nr_swap_pges > 0 && inactive_anon_is_low(zone, sc))
>
> Sorry, I don't find any difference. What is your intention?
>

My intention is that smart gcc can compile out inactive_anon_is_low
call in case of non swap configurable system.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
