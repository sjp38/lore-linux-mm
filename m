Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EA5A16B0328
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 08:18:08 -0400 (EDT)
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20100820054533.GB11847@localhost>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
	 <AANLkTi=WkoxjwZbt6Vd0VhbuA7_k2WM-NUXZnrmzOOPy@mail.gmail.com>
	 <1282159872.8540.96.camel@heimdal.trondhjem.org>
	 <20100820054533.GB11847@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 20 Aug 2010 08:17:08 -0400
Message-ID: <1282306628.3927.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ram Pai <ram.n.pai@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-20 at 13:45 +0800, Wu Fengguang wrote:
> > Hi Ram,
> >=20
> > I was seeing it on NFS until I put in the following kswapd-specific hac=
k
> > into nfs_release_page():
> >=20
> > 	/* Only do I/O if gfp is a superset of GFP_KERNEL */
> > 	if (mapping && (gfp & GFP_KERNEL) =3D=3D GFP_KERNEL) {
> > 		int how =3D FLUSH_SYNC;
> >=20
> > 		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> > 		if (current_is_kswapd())
> > 			how =3D 0;
>=20
> So the patch can remove the above workaround together, and add comment
> that NFS exploits the gfp mask to avoid complex operations involving
> recursive memory allocation and hence deadlock?

I thought I'd send that as a separate patch, but yes, that is my
intention next.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
