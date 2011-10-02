Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A6BBA9000BD
	for <linux-mm@kvack.org>; Sun,  2 Oct 2011 08:55:42 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Sun, 2 Oct 2011 20:55:37 +0800
Subject: RE: [PATCH] slub: remove a minus instruction in get_partial_node
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A4@shsmsx502.ccr.corp.intel.com>
References: <1317290716.4188.1227.camel@debian>
 <alpine.DEB.2.00.1109290917300.9382@router.home>
In-Reply-To: <alpine.DEB.2.00.1109290917300.9382@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>



> -----Original Message-----
> From: Christoph Lameter [mailto:cl@gentwo.org]
> Sent: Thursday, September 29, 2011 10:19 PM
> To: Shi, Alex
> Cc: Pekka Enberg; linux-mm@kvack.org; Chen, Tim C; Huang, Ying
> Subject: Re: [PATCH] slub: remove a minus instruction in get_partial_node
>=20
> On Thu, 29 Sep 2011, Alex,Shi wrote:
>=20
> > Don't do a minus action in get_partial_node function here, since
> > it is always zero.
>=20
> A slab on the partial lists always has objects available. Why would it be
> zero?

Um, my mistaken. The reason should be: if code is here, the slab will be pe=
r cpu slab.
It is no chance to be in per cpu partial and no relationship with per cpu p=
artial. So=20
no reason to use this value as a criteria for filling per cpu partial.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
