Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 697306B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:47:17 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so53874463pdb.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:47:17 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id h9si9647554pat.186.2015.05.13.07.47.16
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 07:47:16 -0700 (PDT)
Date: Wed, 13 May 2015 10:47:15 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH 2/2] mmap2: clarify MAP_POPULATE
Message-ID: <20150513144715.GE1227@akamai.com>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-3-git-send-email-miso@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a+b56+3nqLzpiR9O"
Content-Disposition: inline
In-Reply-To: <1431527892-2996-3-git-send-email-miso@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>


--a+b56+3nqLzpiR9O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 13 May 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
>=20
> David Rientjes has noticed that MAP_POPULATE wording might promise much
> more than the kernel actually provides and intend to provide. The
> primary usage of the flag is to pre-fault the range. There is no
> guarantee that no major faults will happen later on. The pages might
> have been reclaimed by the time the process tries to access them.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Eric B Munson <emunson@akamai.com>

--a+b56+3nqLzpiR9O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVU2PzAAoJELbVsDOpoOa9MfUQAJTJ/HrT0MkSGYeicZsd/fPv
Rr/bJn9eQ+kYCXs5UqSpseRznLOt297Yt0aA45cbk2CGXe/s1FMxlr+OqZJaq5b+
kJXcJ0vorN/29AFSyqHUHs+3Dfkmcop6k1PomDItwVx8p9tVi7dSdE8laYufx1fJ
smsw/jm+vecBLuriss1RmtnYkGwOdbwB9HDzte30x6DAOKRC6y/gZeBlLTJ+cdUB
FyH8kLtOkm8O9x1bR6TbBswo1tVn1LmCQHyNxZH9i41FuZVciTkpu6SrGpfn4j0Z
jtQoNXVukruRQjZyIrBdiuxZWV/HFSTS3G0DUORpm/uupLG4VcBf904VH7jEgAkU
3h/ky8TMvXN3IOxy9GENsJ6GKhIjXSJuYQp6iUQfcHLTKNnkOfSJJnpy75wvmJCu
kIGHunZXd6ocCA2vBPqiOHx46scOy9E58Vurdtz5SnwVVV6crznvIQ7jzewpVkFs
0EIU0xf0FOb9iGYmvRetb2Ut6rwS4/i/VkGbHbl7nLaGBcJtX1zP/f26X2NrnCAy
iauzQ/ullPiji0JufVB+G2v+RBR7fRpnYB/CUF5p+ubzKHpSjjC4jWhjOW8jQc+W
coZUJiXBQE6LfeqOSh+MPIVFoyBmEN8HnQ9vQxpvlopfJ1D+jVjOBnFIvzdwre7R
jVUo3LatpKU4Z796F6xS
=yYNO
-----END PGP SIGNATURE-----

--a+b56+3nqLzpiR9O--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
