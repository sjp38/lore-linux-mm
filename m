Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3215A8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 02:10:34 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p1H7ARD3004641
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 23:10:31 -0800
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by kpbe17.cbf.corp.google.com with ESMTP id p1H7A2IL008871
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 23:10:26 -0800
Received: by qwj9 with SMTP id 9so2479848qwj.22
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 23:10:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110217144116.58d71a7d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1297920842-17299-1-git-send-email-gthelen@google.com>
 <1297920842-17299-2-git-send-email-gthelen@google.com> <20110217143315.858dd090.kamezawa.hiroyu@jp.fujitsu.com>
 <20110217144116.58d71a7d.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 16 Feb 2011 23:10:03 -0800
Message-ID: <AANLkTi=UG3HcuvS0VEgUt27EX9rYguzmhRk4NtNeXfci@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] memcg: break out event counters from other stats
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 16, 2011 at 9:41 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 17 Feb 2011 14:33:15 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Wed, 16 Feb 2011 21:34:01 -0800
>> Greg Thelen <gthelen@google.com> wrote:
>>
>> > From: Johannes Weiner <hannes@cmpxchg.org>
>> >
>> > For increasing and decreasing per-cpu cgroup usage counters it makes
>> > sense to use signed types, as single per-cpu values might go negative
>> > during updates. =A0But this is not the case for only-ever-increasing
>> > event counters.
>> >
>> > All the counters have been signed 64-bit so far, which was enough to
>> > count events even with the sign bit wasted.
>> >
>> > The next patch narrows the usage counters type (on 32-bit CPUs, that
>> > is), though, so break out the event counters and make them unsigned
>> > words as they should have been from the start.
>> >
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > Signed-off-by: Greg Thelen <gthelen@google.com>
>>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>
> Hmm..but not mentioning the change "s64 -> unsigned long(may 32bit)" clea=
rly
> isn't good behavior.
>
> Could you clarify both of changes in patch description as
> =3D=3D
> This patch
> =A0- devides counters to signed and unsigned ones(increase only).
> =A0- makes unsigned one to be 'unsigned long' rather than 'u64'
> and
> =A0- then next patch will make 'signed' part to be 'long'
> =3D=3D
> for changelog ?
>
> Thanks,
> -Kame

Thanks for the review.

I will resent patches with the enhanced description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
