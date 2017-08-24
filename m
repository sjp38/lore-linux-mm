Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72B3E440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:27:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l189so3245811pga.7
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:27:37 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 102si2001508pld.196.2017.08.24.06.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 06:27:36 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id p14so3931005pgd.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:27:36 -0700 (PDT)
Date: Thu, 24 Aug 2017 21:28:01 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH 1/2] nfit: Use init_completion() in
 acpi_nfit_flush_probe()
Message-ID: <20170824132801.GM11771@tardis>
References: <20170823152542.5150-1-boqun.feng@gmail.com>
 <20170823152542.5150-2-boqun.feng@gmail.com>
 <alpine.DEB.2.20.1708241507160.1860@nanos>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="yiup30KVCQiHUZFC"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1708241507160.1860@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org


--yiup30KVCQiHUZFC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 24, 2017 at 03:07:42PM +0200, Thomas Gleixner wrote:
> On Wed, 23 Aug 2017, Boqun Feng wrote:
>=20
> > There is no need to use COMPLETION_INITIALIZER_ONSTACK() in
> > acpi_nfit_flush_probe(), replace it with init_completion().
>=20
> You completely fail to explain WHY.
>=20

I thought COMPLETION_INITIALIZER_ONSTACK() should only use in assigment
or compound literals, so the usage here is obviously wrong, but seems
I was wrong?

Ingo,

Is the usage of COMPLETION_INITIALIZER_ONSTACK() correct? If not,
I could rephrase my commit log saying this is a fix for wrong usage of
COMPLETION_INITIALIZER_ONSTACK(), otherwise, I will rewrite the commit
indicating this patch is a necessary dependency for patch #2. Thanks!

Regards,
Boqun

> Thanks,
>=20
> 	tglx
>=20
> =20
> > Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
> > ---
> >  drivers/acpi/nfit/core.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
> > index 19182d091587..1893e416e7c0 100644
> > --- a/drivers/acpi/nfit/core.c
> > +++ b/drivers/acpi/nfit/core.c
> > @@ -2884,7 +2884,7 @@ static int acpi_nfit_flush_probe(struct nvdimm_bu=
s_descriptor *nd_desc)
> >  	 * need to be interruptible while waiting.
> >  	 */
> >  	INIT_WORK_ONSTACK(&flush.work, flush_probe);
> > -	COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
> > +	init_completion(&flush.cmp);
> >  	queue_work(nfit_wq, &flush.work);
> >  	mutex_unlock(&acpi_desc->init_mutex);
> > =20
> > --=20
> > 2.14.1
> >=20
> >=20

--yiup30KVCQiHUZFC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlme1F4ACgkQSXnow7UH
+riYqgf5AW2ZDU/nzQsIVp6pflQHE+Vmeo+9XJ8X5xi91KucmViBHiISKjAVAOud
rd0FKnQ47izCMLtq59xMIX264pCXMUubJCZt0z5cx1qkdKqnV6rlHcSuBKNaymtN
8K8Ltc4sHyb0exHHm0qEZG3Xn9WWkTALD/ycIe9vEQLyJYnMzMyXuQSMhzEitJTv
nuiRjwK3RRxAeO7u+YM0WErwPxJaSBLmvEvfWhJ/ix+zL9znUamzN1SPPgoDKM2i
5etOuF0yRsnfRv/VYEL8g89EV71614l+90O6bX4Goe/VoKWeuSLzdeuJAhhPZxLT
Uag5q2+b3h8uLp+WtkKNgnmeBW/N7A==
=O+8J
-----END PGP SIGNATURE-----

--yiup30KVCQiHUZFC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
