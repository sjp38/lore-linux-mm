Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 381146B00A3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:15:09 -0400 (EDT)
Received: by gxk27 with SMTP id 27so978215gxk.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:15:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019095144.A1B0.A69D9226@jp.fujitsu.com>
References: <20101019093142.509d6947@notabene>
	<20101018154137.90f5325f.akpm@linux-foundation.org>
	<20101019095144.A1B0.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 10:15:06 +0900
Message-ID: <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 9:57 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > I think there are two bugs here.
>> > The raid1 bug that Torsten mentions is certainly real (and has been ar=
ound
>> > for an embarrassingly long time).
>> > The bug that I identified in too_many_isolated is also a real bug and =
can be
>> > triggered without md/raid1 in the mix.
>> > So this is not a 'full fix' for every bug in the kernel :-), but it co=
uld
>> > well be a full fix for this particular bug.
>> >
>>
>> Can we just delete the too_many_isolated() logic? =A0(Crappy comment
>> describes what the code does but not why it does it).
>
> if my remember is correct, we got bug report that LTP may makes misteriou=
s
> OOM killer invocation about 1-2 years ago. because, if too many parocess =
are in
> reclaim path, all of reclaimable pages can be isolated and last reclaimer=
 found
> the system don't have any reclaimable pages and lead to invoke OOM killer=
