Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 55BC56B0250
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 08:02:01 -0500 (EST)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Tue, 13 Dec 2011 21:01:53 +0800
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B672997EA57@shsmsx502.ccr.corp.intel.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
 <alpine.DEB.2.00.1112020842280.10975@router.home>
 <1323419402.16790.6105.camel@debian>
 <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>, David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

> > > -       if (tail =3D=3D DEACTIVATE_TO_TAIL)
> > > +       if (tail =3D=3D DEACTIVATE_TO_TAIL ||
> > > +               page->inuse > page->objects /2)
> > >                 list_add_tail(&page->lru, &n->partial);
> > >         else
> > >                 list_add(&page->lru, &n->partial);
> > >

> > with the statistics patch above?  I typically run with CONFIG_SLUB_STAT=
S
> > disabled since it impacts performance so heavily and I'm not sure what
> > information you're looking for with regards to those stats.
>=20
> NO, when you collect data, please close SLUB_STAT in kernel config.  _to_=
head
> statistics collection patch just tell you, I collected the statistics not=
 include
> add_partial in early_kmem_cache_node_alloc(). And other places of
> add_partial were covered. Of course, the kernel with statistic can not be=
 used
> to measure performance.

David, Did you have time to give a try? =20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
