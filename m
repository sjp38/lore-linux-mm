Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8AFAC9000BD
	for <linux-mm@kvack.org>; Sun,  2 Oct 2011 08:47:27 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Sun, 2 Oct 2011 20:47:21 +0800
Subject: RE: [PATCH] slub Discard slab page only when node partials >
 minimum setting
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A3@shsmsx502.ccr.corp.intel.com>
References: <1315188460.31737.5.camel@debian>
  <alpine.DEB.2.00.1109061914440.18646@router.home>
  <1315357399.31737.49.camel@debian>
  <alpine.DEB.2.00.1109062022100.20474@router.home>
  <4E671E5C.7010405@cs.helsinki.fi>
  <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
  <alpine.DEB.2.00.1109071003240.9406@router.home>
  <1315442639.31737.224.camel@debian>
  <alpine.DEB.2.00.1109081336320.14787@router.home>
  <1315557944.31737.782.camel@debian> <1315902583.31737.848.camel@debian>
  <CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>
  <1316050363.8425.483.camel@debian>
  <CALmdxiMrDNDvhAmi88-0-1KBdyTwExZPy3Fh9_5TxB+XhK7vjw@mail.gmail.com>
  <1316052031.8425.491.camel@debian> <1316765880.4188.34.camel@debian>
  <alpine.DEB.2.00.1109231500580.15559@router.home>
 <1317290032.4188.1223.camel@debian>
 <alpine.DEB.2.00.1109290927590.9848@router.home>
In-Reply-To: <alpine.DEB.2.00.1109290927590.9848@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>"Huang, Ying" <ying.huang@intel.com>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > I am tested aim9/netperf, both of them was said related to memory
> > allocation, but didn't find performance change with/without PCP. Seems
> > only hackbench sensitive on this. As to aim9, whichever with ourself
> > configuration, or with Mel Gorman's aim9 configuration from his
> > mmtest, both of them has no clear performance change for PCP slub.
>=20
> AIM9 tests are usually single threaded so I would not expect any differen=
ces.
> Try AIM7? And concurrent netperfs?

I used aim7+aim9 patch, and setup 2000 process run concurrently. But aim9=20
can't have big press on slab in fact.=20
As to concurrent netperf, I'd like try it after vacation, if you can wait. =
:)=20
>=20
> The PCP patch helps only if there is node lock contention. Meaning
> simultaneous allocations/frees from multiple processor from the same cach=
e.
>=20
> > Checking the kernel function call graphic via perf record/perf report,
> > slab function only be used much in hackbench benchmark.
>=20
> Then the question arises if its worthwhile merging if it only affects thi=
s
> benchmark.
>=20

>From my viewpoint, the patch is still helpful on server machines, while no =
clear=20
regression finding on desktop machine. So it useful.=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
