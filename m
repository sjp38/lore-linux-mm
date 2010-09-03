Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78B6C6B0047
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 02:33:11 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o836X7RB003127
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Sep 2010 15:33:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 92A7845DE53
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 15:33:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C9C145DE50
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 15:33:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3873A1DB8016
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 15:33:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB3B41DB8017
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 15:33:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: don't use return value trick when oom_killer_disabled
In-Reply-To: <AANLkTinNZYQ7WV_xu7_WE-ekPhHOjqsfr9xtnW3m9r1V@mail.gmail.com>
References: <201009022204.14661.rjw@sisk.pl> <AANLkTinNZYQ7WV_xu7_WE-ekPhHOjqsfr9xtnW3m9r1V@mail.gmail.com>
Message-Id: <20100903153234.3FCB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  3 Sep 2010 15:33:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> 2010/9/3 Rafael J. Wysocki <rjw@sisk.pl>:
> > On Thursday, September 02, 2010, Minchan Kim wrote:
> >> M. Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
> >> 32bit 3GB mem machine. (https://bugzilla.kernel.org/show_bug.cgi?id=3D=
16771)
> >> Also he was bisected first bad commit is below
> >>
> >> =A0 commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
> >> =A0 Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> =A0 Date: =A0 Fri Jun 4 14:15:05 2010 -0700
> >>
> >> =A0 =A0 =A0vmscan: fix do_try_to_free_pages() return value when priori=
ty=3D=3D0 reclaim failure
> >>
> >> At first impression, this seemed very strange because the above commit=
 only
> >> chenged function return value and hibernate_preallocate_memory() ignor=
e
> >> return value of shrink_all_memory(). But it's related.
> >>
> >> Now, page allocation from hibernation code may enter infinite loop if
> >> the system has highmem.
> >>
> >> The reasons are two. 1) hibernate_preallocate_memory() call
> >> alloc_pages() wrong order
> >
> > This isn't the case, as explained here: http://lkml.org/lkml/2010/9/1/3=
16 .
> >
> > The ordering of calls is correct, but it's better to check if there are=
 any
> > non-highmem pages to allocate from before the last call (for performanc=
e
> > reasons, but that also would eliminate the failure in question).
>=20
> I actually didn't look into the 1) problem detail.
> Just copy and paste from KOSAKI's description.
> As I look the thread, KOSAKI seem to admit the description is wrong.
> I will resend the patch removing phrase about 1) problem if KOSAKI don't =
mind.
> KOSAKI. Is it okay?

Yeah! please :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
