Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AC0606B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:18:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V1Ia4D030976
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 10:18:37 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B665645DE4E
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:18:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 987BE45DE4D
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:18:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8087BE08001
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:18:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 394F6E18001
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:18:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTi=NsY9T19rXuBWmeZ3Z2ayA=tHZ1+e=cEXuKVAt@mail.gmail.com>
References: <20100831095542.87CA.A69D9226@jp.fujitsu.com> <AANLkTi=NsY9T19rXuBWmeZ3Z2ayA=tHZ1+e=cEXuKVAt@mail.gmail.com>
Message-Id: <20100831101456.87D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 31 Aug 2010 10:18:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> Hi, KOSAKI.
>=20
> On Tue, Aug 31, 2010 at 9:56 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 1b145e6..0b8a3ce 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1747,7 +1747,7 @@ static void shrink_zone(int priority, struct zon=
e *zone,
> >> =A0 =A0 =A0 =A0 =A0* Even if we did not try to evict anon pages at all=
, we want to
> >> =A0 =A0 =A0 =A0 =A0* rebalance the anon lru active/inactive ratio.
> >> =A0 =A0 =A0 =A0 =A0*/
> >> - =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >> + =A0 =A0 =A0 if (nr_swap_pges > 0 && inactive_anon_is_low(zone, sc))
> >
> > Sorry, I don't find any difference. What is your intention?
> >
>=20
> My intention is that smart gcc can compile out inactive_anon_is_low
> call in case of non swap configurable system.

Do you really check it on your gcc? nr_swap_pages is not file scope variabl=
e, it's
global variable. afaik, current gcc's link time optimization is not so cool.

Do you have a disassemble list?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
