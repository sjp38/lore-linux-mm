Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 971356B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:04:21 -0400 (EDT)
Received: by qyk30 with SMTP id 30so4670475qyk.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 02:04:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDB711B.8010408@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD6207E.1070300@jp.fujitsu.com>
	<BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>
	<4DDB0FB2.9050300@jp.fujitsu.com>
	<BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>
	<4DDB711B.8010408@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:04:19 +0900
Message-ID: <BANLkTik5tXv+k9tk2egXgmBRzcBD5Avjkw@mail.gmail.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

On Tue, May 24, 2011 at 5:49 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> (2011/05/24 17:46), Minchan Kim wrote:
>> On Tue, May 24, 2011 at 10:53 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>>>> + =C2=A0 =C2=A0 =C2=A0 /*
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* chosen_point=3D=3D1 may be a sign that=
 root privilege bonus is too
>>>>> large
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* and we choose wrong task. Let's recalc=
ulate oom score without
>>>>> the
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* dubious bonus.
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>>>> + =C2=A0 =C2=A0 =C2=A0 if (protect_root&& =C2=A0(chosen_points =3D=3D=
 1)) {
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 protect_root =3D 0=
;
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto retry;
>>>>> + =C2=A0 =C2=A0 =C2=A0 }
>>>>
>>>> The idea is good to me.
>>>> But once we meet it, should we give up protecting root privileged
>>>> processes?
>>>> How about decaying bonus point?
>>>
>>> After applying my patch, unprivileged process never get score-1. (note,
>>> mapping
>>> anon pages naturally makes to increase nr_ptes)
>>
>> Hmm, If I understand your code correctly, unprivileged process can get
>> a score 1 by 3% bonus.
>
> 3% bonus is for privileged process. :)

OMG. Typo.
Anyway, my point is following as.
If chose_point is 1, it means root bonus is rather big. Right?
If is is, your patch does second loop with completely ignore of bonus
for root privileged process.
My point is that let's not ignore bonus completely. Instead of it,
let's recalculate 1.5% for example.

But I don't insist on my idea.
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
