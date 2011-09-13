Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E6685900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 09:39:31 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Tue, 13 Sep 2011 21:38:53 +0800
Subject: RE: [PATCH 1/2] slub: remove obsolete code path in __slab_free()
 for per cpu partial
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B5D99D7A40E@shsmsx502.ccr.corp.intel.com>
References: <1315558961.31737.790.camel@debian>
 <1315559166.31737.793.camel@debian>
 <alpine.DEB.2.00.1109121024070.15509@router.home>
In-Reply-To: <alpine.DEB.2.00.1109121024070.15509@router.home>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

>=20
> > On Fri, 2011-09-09 at 17:02 +0800, Alex,Shi wrote:
> > > If there are still some objects left in slab, the slab page will be p=
ut
> > > to per cpu partial list. So remove the obsolete code path.
>=20
> Did you run this with debugging on? I think the code is needed then.

Um, yes, debug_on will pass here. Sorry for missing this.=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
