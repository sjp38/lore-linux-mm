Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 29B9F900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:57:46 -0400 (EDT)
Received: by vws4 with SMTP id 4so1436011vws.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:57:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110414093549.80539260.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110329101234.54d5d45a.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=pMapbVoUO6+7nUEg1bY4fb844-A@mail.gmail.com>
	<20110414092033.0809.A69D9226@jp.fujitsu.com>
	<20110414093549.80539260.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 09:57:42 +0900
Message-ID: <BANLkTikj9EcEQTmz6vDBAW6oGnqyhnCkSQ@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

Hi, KOSAKI and Kame.

On Thu, Apr 14, 2011 at 9:35 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 14 Apr 2011 09:20:41 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> Hi, Minchan, Kamezawa-san,
>>
>> > >> So whenever user push sysrq, older tasks would be killed and at las=
t,
>> > >> root forkbomb task would be killed.
>> > >>
>> > >
>> > > Maybe good for a single user system and it can send Sysrq.
>> > > But I myself not very excited with this new feature becasuse I need =
to
>> > > run to push Sysrq ....
>> > >
>> > > Please do as you like, I think the idea itself is interesting.
>> > > But I love some automatic ones. I do other jobs.
>> >
>> > Okay. Thanks for the comment, Kame.
>> >
>> > I hope Andrew or someone gives feedback forkbomb problem itself before
>> > diving into this.
>>
>> May I ask current status of this thread? I'm unhappy if our kernel keep
>> to have forkbomb weakness. ;)
>
> I've stopped updating but can restart at any time. (And I found a bug ;)
>
>> Can we consider to take either or both idea?
>>
> I think yes, both idea can be used.
> One idea is
> =C2=A0- kill all recent threads by Sysrq. The user can use Sysrq multiple=
 times
> =C2=A0 until forkbomb stops.
> Another(mine) is
> =C2=A0- kill all problematic in automatic. This adds some tracking costs =
but
> =C2=A0 can be configurable.
>
> Thanks,
> -Kame
>
>

Unfortunately, we didn't have a slot to discuss the oom and forkbomb.
So, personally, I talked it with some guys(who we know very well :) )
for a moment during lunch time at LSF/MM. It seems he doesn't feel
strongly we really need it and still I am not sure it, either.

Now most important thing is to listen other's opinions about we really
need it and  we need it in kernel.

And I have a idea to implement my one in automatic, too.  :)

Thanks for your interest.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
