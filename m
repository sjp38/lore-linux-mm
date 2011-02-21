Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D5A038D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 09:14:43 -0500 (EST)
Received: by iyf13 with SMTP id 13so2779744iyf.14
        for <linux-mm@kvack.org>; Mon, 21 Feb 2011 06:14:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110221130431.GF25382@cmpxchg.org>
References: <cover.1298214672.git.minchan.kim@gmail.com>
	<b691a7be970d6aafcd12ccc32ba812ce39fcf027.1298214672.git.minchan.kim@gmail.com>
	<20110221130431.GF25382@cmpxchg.org>
Date: Mon, 21 Feb 2011 23:14:40 +0900
Message-ID: <AANLkTintsg+5wm7EOr40zUqcmhO3Qend=KeYV09zeOAE@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] memcg: remove unnecessary BUG_ON
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Mon, Feb 21, 2011 at 10:04 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> On Mon, Feb 21, 2011 at 12:17:17AM +0900, Minchan Kim wrote:
>> Now memcg in unmap_and_move checks BUG_ON of charge.
>> But mem_cgroup_prepare_migration returns either 0 or -ENOMEM.
>> If it returns -ENOMEM, it jumps out unlock without the check.
>> If it returns 0, it can pass BUG_ON. So it's meaningless.
>> Let's remove it.
>>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/migrate.c | =C2=A0 =C2=A01 -
>> =C2=A01 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index eb083a6..2abc9c9 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -683,7 +683,6 @@ static int unmap_and_move(new_page_t get_new_page, u=
nsigned long private,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D -ENOMEM;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 BUG_ON(charge);
>
> You remove this assertion of the mem_cgroup_prepare_migration() return
> value but only add a comment about the expectations in the next patch.
>
> Could you write a full-blown kerneldoc on mem_cgroup_prepare_migration
> and remove this BUG_ON() in the same patch?
>

Okay. I could.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
