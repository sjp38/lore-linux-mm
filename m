Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 603BE6B0038
	for <linux-mm@kvack.org>; Sun, 11 May 2014 21:06:08 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so4131738eek.41
        for <linux-mm@kvack.org>; Sun, 11 May 2014 18:06:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si9208808eeu.199.2014.05.11.18.06.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 May 2014 18:06:07 -0700 (PDT)
Date: Mon, 12 May 2014 11:05:57 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Message-ID: <20140512110557.67f2028e@notabene.brown>
In-Reply-To: <20140506205418.GQ18281@fieldses.org>
References: <20140423022441.4725.89693.stgit@notabene.brown>
	<20140423024058.4725.38098.stgit@notabene.brown>
	<20140506205418.GQ18281@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_V4z.i1JTXug8PX71jSjKud"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/_V4z.i1JTXug8PX71jSjKud
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 6 May 2014 16:54:18 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Apr 23, 2014 at 12:40:58PM +1000, NeilBrown wrote:
> > PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> > and live-locks while writing to the page cache in a loop-back
> > NFS mount situation.
> >=20
> > It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> > situation.
> > We now know when a request came from the local-host so it could be a
> > loop-back mount.  We already know when we are handling write requests,
> > and when we are doing anything else.
> >=20
> > So combine those two to allow nfsd to still be throttled (like any
> > other process) in every situation except when it is known to be
> > problematic.
>=20
> Looks simple enough, ACK.--b.
>=20

Thanks.
I'll resend the bits need for just this.

The NFS side need to wait for wait_on_bit improvements which seem to be on a
slow path at the moment.

Thanks,
NeilBrown

--Sig_/_V4z.i1JTXug8PX71jSjKud
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU3AedTnsnt1WYoG5AQLtVQ//ca3F1FKgZ1bg4vldC4AC0h6yeS6OW2kb
71BlpBNF69xL/yY56j2JTOtxf/SDJxf/UGPjChxpaIpcf/npZPPT4mfUL+7AruNm
pBbLtenwSnU0GRvCuDednJwt33mZ33minfW7Gzhsc1Uj2s0Rd0yaUnio7DTNBpgI
KuIgcN/LKuEz+u+ItEpcQ3fCE0uOS8/W9prYPcyZvHH+DrwyLwpHFz2CV2WNsdRZ
zpwRb8aQNXTnJKuTDgUieZOIB9/eSK5+uznhzd7VwcRhdAU4edduI26gVNxjkgZb
zDggyM55TyNxtDK/hSTWpmHYybI9dznUDNkQs3FVzGyw/dGKxLHxY2X2FkNLleUr
yqpqMla309OOm4/gAL/vCaLUTVtyirOqJbyn6Qtv3qFccG2HnRp4qvk+YLMIZuyF
5cxg56+3KXGRvES08KJchzk+RP9lpShyhAuyUJEZV2DmyvAFDUbMrKakkVEyeUnj
F69+uEccPX3qZ3E0Z4Yo5ryaZGcndeevVYgFDTQn0GvKleLNK3oclVtIM+d68Duq
jzeh/Ejj0j2TGgzPs0clQ1EDLCC81ka/GHEeBkVLaejV0Yd9b/MovwxFf4UZQbkJ
8AqoHzmWrj4k3qe7uHwXRzi4AlzFBbt3/nqXy3ROkNJCdbMVblzJxsihv7bGX+tf
29nSQoHbuT4=
=epl8
-----END PGP SIGNATURE-----

--Sig_/_V4z.i1JTXug8PX71jSjKud--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
