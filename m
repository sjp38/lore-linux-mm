Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B7C23900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:19:46 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2616956qwa.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 08:19:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428085816.GJ12437@cmpxchg.org>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<2b79bbf9ddceb73624f49bbe9477126147d875fd.1303833417.git.minchan.kim@gmail.com>
	<20110428085816.GJ12437@cmpxchg.org>
Date: Sat, 30 Apr 2011 00:19:44 +0900
Message-ID: <BANLkTi=iTvfrWQMnu2O-AvZhFgD0AfffDw@mail.gmail.com>
Subject: Re: [RFC 5/8] compaction: remove active list counting
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Apr 28, 2011 at 5:58 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Apr 27, 2011 at 01:25:22AM +0900, Minchan Kim wrote:
>> acct_isolated of compaction uses page_lru_base_type which returns only
>> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_=
FILE.
>> So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/compaction.c | =C2=A0 =C2=A04 ++--
>> =C2=A01 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 9f80b5a..653b02b 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -219,8 +219,8 @@ static void acct_isolated(struct zone *zone, struct =
compact_control *cc)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count[lru]++;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 cc->nr_anon =3D count[LRU_ACTIVE_ANON] + count[LRU_INACT=
IVE_ANON];
>> - =C2=A0 =C2=A0 cc->nr_file =3D count[LRU_ACTIVE_FILE] + count[LRU_INACT=
IVE_FILE];
>> + =C2=A0 =C2=A0 cc->nr_anon =3D count[LRU_INACTIVE_ANON];
>> + =C2=A0 =C2=A0 cc->nr_file =3D count[LRU_INACTIVE_FILE];
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->n=
r_anon);
>> =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->n=
r_file);
>> =C2=A0}
>
> I don't see anything using cc->nr_anon and cc->nr_file outside this
> code. =C2=A0Would it make sense to remove them completely?
>

Good idea.
I will remove it totally in next version.
Thanks, Hannes.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
