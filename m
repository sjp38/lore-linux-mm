Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B89A08D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:29:38 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF0TaZ8001841
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 09:29:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 20A8F45DE6F
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:29:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C1A45DE4D
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:29:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A0D001DB803E
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:29:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36C441DB8040
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:29:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <AANLkTi=xPYe6KVVNM7y+tnDAWcVOMb_6jKo5Hq8QNSC8@mail.gmail.com>
References: <20101114161059.BED5.A69D9226@jp.fujitsu.com> <AANLkTi=xPYe6KVVNM7y+tnDAWcVOMb_6jKo5Hq8QNSC8@mail.gmail.com>
Message-Id: <20101115092918.BEFA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 15 Nov 2010 09:29:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Sat, Nov 13, 2010 at 11:10 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Thu, Oct 21, 2010 at 11:00 AM, Christoph Lameter <cl@linux.com> wro=
te:
> >> > @@ -218,6 +218,7 @@ unsigned long shrink_slab(unsigned long
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long total_scan;
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long max_pass;
> >> >
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->node =3D node;
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_pass =3D (*shrinker->shrink)(shri=
nker, 0, gfp_mask);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta =3D (4 * scanned) / shrinker->s=
eeks;
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta *=3D max_pass;
> >>
> >> Apologies for coming late to the party, but I have to ask - is there
> >> anything protecting shrinker->node from concurrent modification if
> >> several threads are trying to reclaim memory at once ?
> >
> > shrinker_rwsem? :)
>=20
> Doesn't work - it protects shrink_slab() from concurrent modifications
> of the shrinker_list in register_shrinker() or unregister_shrinker(),
> but several shirnk_slab() calls can still execute in parallel since
> they only grab shrinker_rwsem in shared (read) mode.

Oops, my fault.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
