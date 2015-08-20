Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 104216B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 13:03:13 -0400 (EDT)
Received: by qkep139 with SMTP id p139so18591873qke.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 10:03:12 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id 133si1894320qhw.59.2015.08.20.10.03.11
        for <linux-mm@kvack.org>;
        Thu, 20 Aug 2015 10:03:12 -0700 (PDT)
Date: Thu, 20 Aug 2015 13:03:09 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150820170309.GA11557@akamai.com>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20150820075611.GD4780@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 20 Aug 2015, Michal Hocko wrote:

> On Wed 19-08-15 17:33:45, Eric B Munson wrote:
> [...]
> > The group which asked for this feature here
> > wants the ability to distinguish between LOCKED and LOCKONFAULT regions
> > and without the VMA flag there isn't a way to do that.
>=20
> Could you be more specific on why this is needed?

They want to keep metrics on the amount of memory used in a LOCKONFAULT
region versus the address space of the region.

>=20
> > Do we know that these last two open flags are needed right now or is
> > this speculation that they will be and that none of the other VMA flags
> > can be reclaimed?
>=20
> I do not think they are needed by anybody right now but that is not a
> reason why it should be used without a really strong justification.
> If the discoverability is really needed then fair enough but I haven't
> seen any justification for that yet.

To be completely clear you believe that if the metrics collection is
not a strong enough justification, it is better to expand the mm_struct
by another unsigned long than to use one of these bits right?


--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV1ghMAAoJELbVsDOpoOa9h6gP/0wZmVsmQn0ULZ2icCgHa60d
Uiij9pmZvI0gmFD0D8Erh4dtHd6xtWts+1N/h7O37ryNlLRTe1EmWuyKBPuzn3+b
B4R39SjJNmpRgey4/s3jB6538QZWYO9lKfrbaosv1nEAoNzjmb9vRjZ+zfExGjiQ
ILODj7ILv1OJhiKfvlZbl6dkJq719YTi5kAaWbFQ/BFTnSt2PPZUxH3oG2RrNgaS
8R08qH5zyjreWnYVVq2N0FM2p0pAIwOkPTSe7DbNu/W9AThv6TdXeczRMoCWamTi
m4xV+j61p6PqrGnCk1bCa2RWxbEV4gxGtNBwZVZOFDnYtWl+5HTqL99oKL3lIvCe
adMdBRlY4Q++znx6u0aAghQ1N8EzBEFPCpOyzgyfNKMKz8mxVZGJs2p4LzJ4ETpg
+EybJmhNufjzwHXnnD1jZM3h/elEIrdB1mcyRs2w1CYwF7Q3IckUZ1dcz7+Ze2yw
sP4MtYfw+24MHvsokdqU8qPbZm2+iqPN1W5UCZOjKo3w5O1FAWJAwpLGiz1mR2L8
k1MKecp4Xc9iFRnFSQ2lUpKS1aOG353wdSC9n8YCNNg5XAg/6LPuFR1A9eQHSfEg
evtUcqZHC3aVWfTaEu6JjJQJitQmTSFWEX1jb1vL53ZTFJPwBjJOVAwDm9GVDeiu
SKfq8OykFeQNnd6k3HQI
=+u4S
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
