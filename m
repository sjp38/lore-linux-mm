Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 75C8F8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:26:00 -0500 (EST)
Received: by iwn40 with SMTP id 40so2990938iwn.14
        for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:25:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128081723.GD2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
	<20110128081723.GD2213@cmpxchg.org>
Date: Fri, 28 Jan 2011 17:25:58 +0900
Message-ID: <AANLkTinikUM09bXbLZ5zU1gdgfdPZSQmbycbbeSyGk59@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for hugepage
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Hannes,

On Fri, Jan 28, 2011 at 5:17 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Jan 28, 2011 at 05:04:16PM +0900, Minchan Kim wrote:
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
>
> No, you are correct. =C2=A0But I am not sure the order really matters in
> theory: you have two endless loops that need independent fixing.

That's why I ask a question.
Two endless loop?

One is what I mentioned. The other is what?
Maybe this patch solve the other.
But I can't guess it by only this description. Stupid..

Please open my eyes.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
