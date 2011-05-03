Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CE0406B0022
	for <linux-mm@kvack.org>; Mon,  2 May 2011 20:30:37 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4198613qwa.14
        for <linux-mm@kvack.org>; Mon, 02 May 2011 17:30:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DBEC65B.4010201@redhat.com>
References: <cover.1304261567.git.minchan.kim@gmail.com>
	<dc54a5771cf1f580a91d16816100d4a2bcf2cdf5.1304261567.git.minchan.kim@gmail.com>
	<4DBEC65B.4010201@redhat.com>
Date: Tue, 3 May 2011 09:30:36 +0900
Message-ID: <BANLkTimNLcFVH=7kFSuLtzfYFewag7-hoA@mail.gmail.com>
Subject: Re: [PATCH 2/2] Filter unevictable page out in deactivate_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>

Hi Rik,

On Mon, May 2, 2011 at 11:57 PM, Rik van Riel <riel@redhat.com> wrote:
> On 05/01/2011 11:03 AM, Minchan Kim wrote:
>>
>> It's pointless that deactive_page's pagevec operation about
>> unevictable page as it's nop.
>> This patch removes unnecessary overhead which might be a bit problem
>> in case that there are many unevictable page in system(ex, mprotect
>> workload)
>>
>> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/swap.c | =C2=A0 =C2=A09 +++++++++
>> =C2=A01 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 2e9656d..b707694 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -511,6 +511,15 @@ static void drain_cpu_pagevecs(int cpu)
>> =C2=A0 */
>> =C2=A0void deactivate_page(struct page *page)
>> =C2=A0{
>> +
>> + =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* In workload which system has many unevict=
able page(ex,
>> mprotect),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* unevictalge page deactivation for acceler=
ating reclaim
>
> Typo.

My bad. I will resend after work.
Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
