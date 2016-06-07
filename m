Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCB546B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 22:34:47 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c127so443811063ywb.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 19:34:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p94si12780594qkp.93.2016.06.06.19.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 19:34:47 -0700 (PDT)
Message-ID: <1465266883.16365.154.camel@redhat.com>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
From: Rik van Riel <riel@redhat.com>
Date: Mon, 06 Jun 2016 22:34:43 -0400
In-Reply-To: <20160606194836.3624-8-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-8-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-OTIhPc09Uu/k0/RphPgr"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com


--=-OTIhPc09Uu/k0/RphPgr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> Currently, scan pressure between the anon and file LRU lists is
> balanced based on a mixture of reclaim efficiency and a somewhat
> vague
> notion of "value" of having certain pages in memory over others. That
> concept of value is problematic, because it has caused us to count
> any
> event that remotely makes one LRU list more or less preferrable for
> reclaim, even when these events are not directly comparable to each
> other and impose very different costs on the system - such as a
> referenced file page that we still deactivate and a referenced
> anonymous page that we actually rotate back to the head of the list.
>=20

Well, patches 7-10 answered my question on patch 6 :)

I like this design.

--=20
All Rights Reversed.


--=-OTIhPc09Uu/k0/RphPgr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXVjLDAAoJEM553pKExN6DBXoIALeVA87/FY4tr4DBuc8aMQXr
UFLEDZtJ0gfVDQ9l+Hmfuua/yhd9znZoDrcK9yMEAVd+U1Ow3wECq93Koltsif80
AY9/32yS45/vq3rtFKzW2LSSPGpKUdfcAe1pw4abZa8dOB4GwgnOdPZleZP/7xIa
icc8Wf3IGo+Fmmv9DSKAqjelnHI8OPSxA3eLYln0oAfMaxJJnniVt6cTJHujlunY
gJUoMTmbkCtHm+5Gt0Xqd5ICofw/jSdLqjAuBmzUeMfZDiVbUBcpfwOcliii+qDu
ORsoQ8UMIggzk/waEyqJAvu6qKVkzvqoq7Ntjlw2m4JGthdTx/c98lBwhK/eBXY=
=/u/A
-----END PGP SIGNATURE-----

--=-OTIhPc09Uu/k0/RphPgr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
