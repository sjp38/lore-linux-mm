Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0CD76B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:38:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V1cD5p003082
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 10:38:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E20D745DE4F
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:38:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBB5845DE5D
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:38:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98BFE1DB8038
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:38:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B42E38001
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:38:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
In-Reply-To: <AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
References: <20100831095140.87C7.A69D9226@jp.fujitsu.com> <AANLkTin4-NomOoNFYCKgi7oE+MCUiC0o0ftAkOwLKez_@mail.gmail.com>
Message-Id: <20100831102557.87D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 31 Aug 2010 10:38:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> > I think both Ying's and Minchan's opnion are right and makes sense. =A0=
however I _personally_
> > like Ying version because 1) this version is simpler 2) swap full is ve=
ry rarely event 3)
> > no swap mounting is very common on HPC. so this version could have a ch=
ance to
> > improvement hpc workload too.
>=20
> I agree.
>=20
> >
> > In the other word, both avoiding unnecessary TLB flush and keeping prop=
er page aging are
> > performance matter. so when we are talking performance, we always need =
to think frequency
> > of the event.
>=20
> Ying's one and mine both has a same effect.
> Only difference happens swap is full. My version maintains old
> behavior but Ying's one changes the behavior. I admit swap full is
> rare event but I hoped not changed old behavior if we doesn't find any
> problem.
> If kswapd does aging when swap full happens, is it a problem?
> We have been used to it from 2.6.28.
>=20
> If we regard a code consistency is more important than _unexpected_
> result, Okay. I don't mind it. :)

To be honest, I don't mind the difference between you and Ying's version. b=
ecause
_practically_ swap full occur mean the application has a bug. so, proper pa=
ge aging
doesn't help so much. That's the reason why I said I prefer simper. I don't=
 have=20
strong opinion. I think it's not big matter.


> But at least we should do more thing to make the patch to compile out
> for non-swap configurable system.

Yes, It makes embedded happy :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
