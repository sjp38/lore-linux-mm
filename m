Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 212696B0186
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 19:21:35 -0400 (EDT)
Subject: Re: possible slab deadlock while doing ifenslave
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 14 Oct 2011 01:21:14 +0200
In-Reply-To: <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
References: <201110121019.53100.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
	 <201110131019.58397.hans@schillstrom.com>
	 <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1318548074.2374.0.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Thu, 2011-10-13 at 16:03 -0700, David Rientjes wrote:

> Ok, I think this may be related to what Sitsofe reported in the "lockdep=
=20
> recursive locking detected" thread on LKML (see=20
> http://marc.info/?l=3Dlinux-kernel&m=3D131805699106560).
>=20
> Peter and Christoph hypothesized that 056c62418cc6 ("slab: fix lockdep=
=20
> warnings") may not have had full coverage when setting lockdep classes fo=
r=20
> kmem_list3 locks that may be called inside of each other because of=20
> off-slab metadata.
>=20
> I think it's safe to say there is no deadlock possibility here or we woul=
d=20
> have seen it since 2006 and this is just a matter of lockdep annotation=
=20
> that needs to be done.  So don't worry too much about the warning even=
=20
> though I know it's annoying and it suppresses future lockdep output (even=
=20
> more annoying!).
>=20
> I'm not sure if there's a patch to address that yet, I think one was in=
=20
> the works.  If not, I'll take a look at rewriting that lockdep annotation=
.

Urgh, I so totally forgot about that.. :-/ So no, no patch yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
