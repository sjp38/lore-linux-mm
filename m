Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3415444088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:17:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u20so3602930pgb.10
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:17:51 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id c195si3723618pga.622.2017.08.24.17.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 17:17:49 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t3so1392438pgt.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:17:49 -0700 (PDT)
Date: Fri, 25 Aug 2017 08:18:10 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v2 1/2] nfit: Fix the abuse of
 COMPLETION_INITIALIZER_ONSTACK()
Message-ID: <20170825001810.GN11771@tardis>
References: <20170823152542.5150-2-boqun.feng@gmail.com>
 <20170824142239.15178-1-boqun.feng@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="fDERRRNgB4on1jOB"
Content-Disposition: inline
In-Reply-To: <20170824142239.15178-1-boqun.feng@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, walken@google.com, Byungchul Park <byungchul.park@lge.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org


--fDERRRNgB4on1jOB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 24, 2017 at 10:22:36PM +0800, Boqun Feng wrote:
> COMPLETION_INITIALIZER_ONSTACK() is supposed to used as an initializer,
> in other words, it should only be used in assignment expressions or
> compound literals. So the usage in drivers/acpi/nfit/core.c:
>=20
> 	COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
>=20
> , is inappropriate.
>=20
> Besides, this usage could also break compilations for another fix to
> reduce stack sizes caused by COMPLETION_INITIALIZER_ONSTACK(), because
> that fix changes COMPLETION_INITIALIZER_ONSTACK() from rvalue to lvalue,
> and usage as above will report error:
>=20
> 	drivers/acpi/nfit/core.c: In function 'acpi_nfit_flush_probe':
> 	include/linux/completion.h:77:3: error: value computed is not used [-Wer=
ror=3Dunused-value]
> 	  (*({ init_completion(&work); &work; }))
>=20
> This patch fixes this by replacing COMPLETION_INITIALIZER_ONSTACK() with
> init_completion() in acpi_nfit_flush_probe(), which does the same
> initialization without any other problem.
>=20
> Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
> ---

Sorry, forget to metion:

v1 --> v2:
	Improve the commit log, based on Dan, Thomas and Arnd's
	comments.

Only V2 of this patch #1 is updated.=20

Regards,
Boqun

>  drivers/acpi/nfit/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
> index 19182d091587..1893e416e7c0 100644
> --- a/drivers/acpi/nfit/core.c
> +++ b/drivers/acpi/nfit/core.c
> @@ -2884,7 +2884,7 @@ static int acpi_nfit_flush_probe(struct nvdimm_bus_=
descriptor *nd_desc)
>  	 * need to be interruptible while waiting.
>  	 */
>  	INIT_WORK_ONSTACK(&flush.work, flush_probe);
> -	COMPLETION_INITIALIZER_ONSTACK(flush.cmp);
> +	init_completion(&flush.cmp);
>  	queue_work(nfit_wq, &flush.work);
>  	mutex_unlock(&acpi_desc->init_mutex);
> =20
> --=20
> 2.14.1
>=20

--fDERRRNgB4on1jOB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlmfbL4ACgkQSXnow7UH
+rjH9gf/Rbn4gfb/z0Kw0VFlgUqko7luFjTmSX663B1wCNdvdbb9WCeZ1k8Pmsjp
7ck7/3OxHj0AVBiF6zhVDbeHUFNiyUQFjl4N4fcvoVkA0AiRpLrgIlU/CSmlHO5m
4eyPglHcdWtHzW5bKFm4cpt815FS0cpqoBIKEWNJ7IuBPrZ1G4d9kC/MVfSUKsBR
UzkMogpvwjaQTJaeNNdrt3lPpTqBhNe/UaNzrxcE+YFzKHC+QGbxLC2TKtOe0oYP
EnW4eGfTkW1D1oeTbZ3V2Lrd+Q+sWyA228zdkJNMVz2V5KfRCnKr7TinNJsjSyu3
xin26t5dPxOMWhjPW1wiCLgi0Ln9FQ==
=/GOJ
-----END PGP SIGNATURE-----

--fDERRRNgB4on1jOB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
