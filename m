Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C7E106B01D2
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:40:44 -0400 (EDT)
Received: by gxk20 with SMTP id 20so2517772gxk.14
        for <linux-mm@kvack.org>; Thu, 14 May 2009 07:39:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0905140727j5ba02b07t94826f57dd99839c@mail.gmail.com>
References: <20090514231555.f52c81eb.minchan.kim@gmail.com>
	 <2f11576a0905140727j5ba02b07t94826f57dd99839c@mail.gmail.com>
Date: Thu, 14 May 2009 23:39:49 +0900
Message-ID: <44c63dc40905140739n271d3d2w2e0cc364c0012d71@mail.gmail.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case
	of no swap space V3
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 11:27 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 2f9d555..621708f 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1577,7 +1577,7 @@ static void shrink_zone(int priority, struct zone =
*zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Even if we did not try to evict anon pages=
 at all, we want to
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * rebalance the anon lru active/inactive rat=
io.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> - =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc))
>> + =C2=A0 =C2=A0 =C2=A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pag=
es > 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_active_lis=
t(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>
>
> =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages > 0 && inactive_anon_is_low(zone, =
sc))
>
> is better?
> compiler can't swap evaluate order around &&.

If GCC optimizes away that branch with CONFIG_SWAP=3Dn as Rik mentioned,
we don't have a concern.

--=20
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
