Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Thu, 15 Nov 2018 08:48:10 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 6/6] PM / Hibernate: exclude all PageOffline() pages
Message-ID: <20181115074810.GA9055@amd>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-7-david@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Content-Disposition: inline
In-Reply-To: <20181114211704.6381-7-david@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>
List-ID: <linux-mm.kvack.org>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2018-11-14 22:17:04, David Hildenbrand wrote:
> The content of pages that are marked PG_offline is not of interest
> (e.g. inflated by a balloon driver), let's skip these pages.
>=20
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>

Acked-by: Pavel Machek <pavel@ucw.cz>

> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index b0308a2c6000..01db1d13481a 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1222,7 +1222,7 @@ static struct page *saveable_highmem_page(struct zo=
ne *zone, unsigned long pfn)
>  	BUG_ON(!PageHighMem(page));
> =20
>  	if (swsusp_page_is_forbidden(page) ||  swsusp_page_is_free(page) ||
> -	    PageReserved(page))
> +	    PageReserved(page) || PageOffline(page))
>  		return NULL;
> =20
>  	if (page_is_guard(page))
> @@ -1286,6 +1286,9 @@ static struct page *saveable_page(struct zone *zone=
, unsigned long pfn)
>  	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
>  		return NULL;
> =20
> +	if (PageOffline(page))
> +		return NULL;
> +
>  	if (PageReserved(page)
>  	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
>  		return NULL;

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvtJLoACgkQMOfwapXb+vIKwQCgqMCGJ4BEWmMsp5gihD0MR/cx
lFwAnAqKSOIHgjFwhl+uKuaItXeOXj2x
=TTZ/
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
