Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 89FDE8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:37:32 -0500 (EST)
Received: by iyj17 with SMTP id 17so2442701iyj.14
        for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:37:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128172438.6c49d4ea.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
	<20110128172438.6c49d4ea.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 28 Jan 2011 17:37:29 +0900
Message-ID: <AANLkTimmOhbWKMek+9UgTZOU7-17A3H3pMZF-pGQ5v7P@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for hugepage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 5:24 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 28 Jan 2011 17:04:16 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Kame,
>>
>> On Fri, Jan 28, 2011 at 1:58 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > How about this ?
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > Current memory cgroup's code tends to assume page_size =3D=3D PAGE_SIZ=
E
>> > and arrangement for THP is not enough yet.
>> >
>> > This is one of fixes for supporing THP. This adds
>> > mem_cgroup_check_margin() and checks whether there are required amount=
 of
>> > free resource after memory reclaim. By this, THP page allocation
>> > can know whether it really succeeded or not and avoid infinite-loop
>> > and hangup.
>> >
>> > Total fixes for do_charge()/reclaim memory will follow this patch.
>>
>> If this patch is only related to THP, I think patch order isn't good.
>> Before applying [2/4], huge page allocation will retry without
>> reclaiming and loop forever by below part.
>>
>> @@ -1854,9 +1858,6 @@ static int __mem_cgroup_do_charge(struct
>> =C2=A0 =C2=A0 =C2=A0 } else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_over_limit =3D mem_=
cgroup_from_res_counter(fail_res, res);
>>
>> - =C2=A0 =C2=A0 if (csize > PAGE_SIZE) /* change csize and retry */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return CHARGE_RETRY;
>> -
>> =C2=A0 =C2=A0 =C2=A0 if (!(gfp_mask & __GFP_WAIT))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return CHARGE_WOULDBLOC=
K;
>>
>> Am I missing something?
>>
>
> You're right. But
> =C2=A0- This patch oder doesn't affect bi-sect of the bug. because
> =C2=A0 2 bugs seems to be the same.
> =C2=A0- This patch implements a leaf function for the real fix.
>
> Then, I think patch order is not problem here.
>
> Thank you for pointing out.

Okay. I understand Hannes and your opinion.
In my opinion, my suggestion can enhance the patch readability in this
series as just only my viewpoint. :)
Anyway, I don't mind it.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks!!

>
> Thanks,
> -Kame
>
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
