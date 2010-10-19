Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3C35A6B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:21:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J1LZQa010419
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:21:35 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 722F745DE4E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:21:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 425D245DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:21:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 26745E08001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:21:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBC131DB803A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:21:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
In-Reply-To: <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
References: <20101019095144.A1B0.A69D9226@jp.fujitsu.com> <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
Message-Id: <20101019102114.A1B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 19 Oct 2010 10:21:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 19, 2010 at 9:57 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > I think there are two bugs here.
> >> > The raid1 bug that Torsten mentions is certainly real (and has been =
around
> >> > for an embarrassingly long time).
> >> > The bug that I identified in too_many_isolated is also a real bug an=
d can be
> >> > triggered without md/raid1 in the mix.
> >> > So this is not a 'full fix' for every bug in the kernel :-), but it =
could
> >> > well be a full fix for this particular bug.
> >> >
> >>
> >> Can we just delete the too_many_isolated() logic? =A0(Crappy comment
> >> describes what the code does but not why it does it).
> >
> > if my remember is correct, we got bug report that LTP may makes misteri=
ous
> > OOM killer invocation about 1-2 years ago. because, if too many paroces=
s are in
> > reclaim path, all of reclaimable pages can be isolated and last reclaim=
er found
> > the system don't have any reclaimable pages and lead to invoke OOM kill=
er.
> > We have strong motivation to avoid false positive oom. then, some discu=
sstion
> > made this patch.
> >
> > if my remember is incorrect, I hope Wu or Rik fix me.
>=20
> AFAIR, it's right.
>=20
> How about this?
>=20
> It's rather aggressive throttling than old(ie, it considers not lru
> type granularity but zone )
> But I think it can prevent unnecessary OOM problem and solve deadlock pro=
blem.

Can you please elaborate your intention? Do you think Wu's approach is wron=
g?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
