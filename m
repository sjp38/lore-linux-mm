Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 45FD76B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:37:36 -0400 (EDT)
Received: by iwn1 with SMTP id 1so1986279iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:32:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019102114.A1B9.A69D9226@jp.fujitsu.com>
References: <20101019095144.A1B0.A69D9226@jp.fujitsu.com>
	<AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
	<20101019102114.A1B9.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 10:32:27 +0900
Message-ID: <AANLkTinU9qHEGgK5NDLi-zBSXJZmRDoZEnyLOHRYe8rd@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:21 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, Oct 19, 2010 at 9:57 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> > I think there are two bugs here.
>> >> > The raid1 bug that Torsten mentions is certainly real (and has been=
 around
>> >> > for an embarrassingly long time).
>> >> > The bug that I identified in too_many_isolated is also a real bug a=
nd can be
>> >> > triggered without md/raid1 in the mix.
>> >> > So this is not a 'full fix' for every bug in the kernel :-), but it=
 could
>> >> > well be a full fix for this particular bug.
>> >> >
>> >>
>> >> Can we just delete the too_many_isolated() logic? =A0(Crappy comment
>> >> describes what the code does but not why it does it).
>> >
>> > if my remember is correct, we got bug report that LTP may makes mister=
ious
>> > OOM killer invocation about 1-2 years ago. because, if too many paroce=
ss are in
>> > reclaim path, all of reclaimable pages can be isolated and last reclai=
mer found
>> > the system don't have any reclaimable pages and lead to invoke OOM kil=
ler.
>> > We have strong motivation to avoid false positive oom. then, some disc=
usstion
>> > made this patch.
>> >
>> > if my remember is incorrect, I hope Wu or Rik fix me.
>>
>> AFAIR, it's right.
>>
>> How about this?
>>
>> It's rather aggressive throttling than old(ie, it considers not lru
>> type granularity but zone )
>> But I think it can prevent unnecessary OOM problem and solve deadlock pr=
oblem.
>
> Can you please elaborate your intention? Do you think Wu's approach is wr=
ong?

No. I think Wu's patch may work well. But I agree Andrew.
Couldn't we remove the too_many_isolated logic? If it is, we can solve
the problem simply.
But If we remove the logic, we will meet long time ago problem, again.
So my patch's intention is to prevent OOM and deadlock problem with
simple patch without adding new heuristic in too_many_isolated.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
