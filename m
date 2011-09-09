Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 18F35900138
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 05:18:23 -0400 (EDT)
References: <4E69A496.9040707@profihost.ag>
In-Reply-To: <4E69A496.9040707@profihost.ag>
Mime-Version: 1.0 (iPhone Mail 8H7)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <0A5D57A3-50CB-4AE2-90DE-EF6C9D8F0C55@profihost.ag>
From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: system freezing with 3.0.4
Date: Fri, 9 Sep 2011 11:18:15 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "efault@gmx.de" <efault@gmx.de>

Hi,

here a better sysrq w trigger output.

http://pastebin.com/JWjrbrh4

> Hi list,
>=20
> here's an updated post of my one yesterday.
>=20
> We've updated some systems from 2.6.32 to 3.0.4 vanilla kernel. Since then=
 we're expecting freezes every now and then. All in memory apps are still wo=
rking but nothing which reads or writes from or to disk (at least it seems l=
ike that).
>=20
> If you're already conncted via ssh and running top suddenly idle is 99-100=
% and loads goes up to 500. I then cannot write to disk anymore. I've seen t=
his for now on 2-5 of 20 servers i've updated. I can't believe they are all d=
amaged. Also every night there comes another one where the same happens. Als=
o running them on 2.6.32 again works fine.
>=20
> Luckily i was able to trigger a sysrq on one machine fast enough:
> echo t >/proc/sysrq-trigger
>=20
> sysrq output is attached
>=20
> I hope somebody can help.
>=20
> Please CC me i'm not on list.
>=20
> Stefan
>=20
> <sysrqtrigger.txt>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
