Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E5E576B0089
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 03:37:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB88bJ9q008178
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Dec 2010 17:37:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC2E45DE4D
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:36:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 403C145DE8E
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:36:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3069CE08003
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:36:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7C3DE18006
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:36:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v4 5/7] add profile information for invalidated page reclaim
In-Reply-To: <AANLkTik4mtr8T6PddQopi4cwWGRmJ+-utykgjywGoxj+@mail.gmail.com>
References: <20101208165944.174D.A69D9226@jp.fujitsu.com> <AANLkTik4mtr8T6PddQopi4cwWGRmJ+-utykgjywGoxj+@mail.gmail.com>
Message-Id: <20101208173520.1759.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Wed,  8 Dec 2010 17:36:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> Hi KOSAKI,
>=20
> On Wed, Dec 8, 2010 at 5:02 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> This patch adds profile information about invalidated page reclaim.
> >> It's just for profiling for test so it would be discard when the serie=
s
> >> are merged.
> >>
> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Cc: Wu Fengguang <fengguang.wu@intel.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Nick Piggin <npiggin@kernel.dk>
> >> Cc: Mel Gorman <mel@csn.ul.ie>
> >> ---
> >> =A0include/linux/vmstat.h | =A0 =A04 ++--
> >> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
> >> =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +++
> >> =A03 files changed, 8 insertions(+), 2 deletions(-)
> >
> > Today, we have tracepoint. tracepoint has no overhead if it's unused.
> > but vmstat has a overhead even if unused.
> >
> > Then, all new vmstat proposal should be described why you think it is
> > frequently used from administrators.
>=20
> It's just for easy gathering the data when Ben will test.
> I never want to merge it in upstream and even mmtom.

Ok, I had not understand your intention. Thank you.



> If you don't like it for just testing, I am happy to change it with trace=
point.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
