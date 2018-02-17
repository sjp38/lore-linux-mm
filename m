Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 485746B0005
	for <linux-mm@kvack.org>; Sat, 17 Feb 2018 16:17:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i143so2734692wmf.2
        for <linux-mm@kvack.org>; Sat, 17 Feb 2018 13:17:18 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id i130si11342515wmf.178.2018.02.17.13.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Feb 2018 13:17:16 -0800 (PST)
Date: Sat, 17 Feb 2018 22:17:25 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC 2/2] Page order diagnostics
Message-ID: <20180217211725.GA9640@amd>
References: <20180216160110.641666320@linux.com>
 <20180216160121.583566579@linux.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline
In-Reply-To: <20180216160121.583566579@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> @@ -1289,6 +1289,52 @@ const char * const vmstat_text[] =3D {
>  	"swap_ra",
>  	"swap_ra_hit",
>  #endif
> +#ifdef CONFIG_ORDER_STATS
> +	"order0_failure",
> +	"order1_failure",
> +	"order2_failure",
> +	"order3_failure",
> +	"order4_failure",
> +	"order5_failure",
> +	"order6_failure",
> +	"order7_failure",
> +	"order8_failure",
> +	"order9_failure",
> +	"order10_failure",
> +#ifdef CONFIG_FORCE_MAX_ZONEORDER
> +#if MAX_ORDER > 11
> +	"order11_failure"
> +#endif
> +#if MAX_ORDER > 12
> +	"order12_failure"
> +#endif
> +#if MAX_ORDER > 13
> +	"order13_failure"
> +#endif
> +#if MAX_ORDER > 14
> +	"order14_failure"
> +#endif
> +#if MAX_ORDER > 15
> +	"order15_failure"
> +#endif
> +#if MAX_ORDER > 16
> +	"order16_failure"
> +#endif
> +#if MAX_ORDER > 17
> +	"order17_failure"
> +#endif
> +#if MAX_ORDER > 18
> +	"order18_failure"
> +#endif
> +#if MAX_ORDER > 19
> +	"order19_failure"
> +#endif

I don't think this does what you want it to do. Commas are missing.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlqIm+UACgkQMOfwapXb+vKJdQCdH7guQtlyHyWkIpEQCQp9Xb6j
wcMAoLef0VPOAoaaG2ac5C1EMuQU6hgD
=bP1b
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
