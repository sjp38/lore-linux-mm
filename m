Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE9506B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 12:14:07 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id j35so67359847qge.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 09:14:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y98si6431168qge.38.2016.04.07.09.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 09:14:07 -0700 (PDT)
Message-ID: <1460045640.30063.3.camel@redhat.com>
Subject: Re: [Lsf-pc] [Lsf] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
From: Rik van Riel <riel@redhat.com>
Date: Thu, 07 Apr 2016 12:14:00 -0400
In-Reply-To: <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
	 <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-UsUylZjyd8DzUzsJ2NSn"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Lever <chuck.lever@oracle.com>, Christoph Hellwig <hch@infradead.org>
Cc: lsf@lists.linux-foundation.org, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>


--=-UsUylZjyd8DzUzsJ2NSn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-07 at 08:48 -0700, Chuck Lever wrote:
> >=20
> > On Apr 7, 2016, at 7:38 AM, Christoph Hellwig <hch@infradead.org>
> > wrote:
> >=20
> > This is also very interesting for storage targets, which face the
> > same
> > issue.=C2=A0=C2=A0SCST has a mode where it caches some fully constructe=
d
> > SGLs,
> > which is probably very similar to what NICs want to do.
> +1 for NFS server.

I have swapped around my slot (into the MM track)
with Jesper's slot (now a plenary session), since
there seems to be a fair amount of interest in
Jesper's proposal from IO and FS people, and my
topic is more MM specific.

--=20
All Rights Reversed.


--=-UsUylZjyd8DzUzsJ2NSn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXBodIAAoJEM553pKExN6D454IALC5jqiIbLVMGRBwiOvNBus+
1dylF98TNkuiHOqurG/X5ipRmisWO61uhls/64+jWBz6GhwWCPw456rM7WGoNEK6
ewEuVuspKTJqkTDcek5bLUE3a3QznfZMO2NnIVi2s+VNfIL+23fWNxDO2S5YN08P
x0Ru6FDzqAm6pqmddIgka+463utaKS7OMpbC6ak0aFNGh/LDmEHXb5Ap6OZ6gHKY
OgF8Ce7Acd51ISRRa6wgIR3PYjgYBhJidSPmbbDtYkYjr/7N7tqVa9gnz0wa45yK
oj2MpG2WBr4fhGMD0C3f+sZS2KqcOs6Pl1hB7tkce/XMXi6n7FsPPOwtywsHIaA=
=lFk5
-----END PGP SIGNATURE-----

--=-UsUylZjyd8DzUzsJ2NSn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
