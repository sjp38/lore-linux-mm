Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 19 Nov 2018 14:16:53 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v1 7/8] PM / Hibernate: use pfn_to_online_page()
Message-ID: <20181119131653.GA27556@amd>
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Content-Disposition: inline
In-Reply-To: <20181119101616.8901-8-david@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>
List-ID: <linux-mm.kvack.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-11-19 11:16:15, David Hildenbrand wrote:
> Let's use pfn_to_online_page() instead of pfn_to_page() when checking
> for saveable pages to not save/restore offline memory sections.
>=20
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>

Acked-by: Pavel Machek <pavel@ucw.cz>

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvyt8UACgkQMOfwapXb+vKC6ACeIzp6Bg+hmUwQWwjh+ih57//k
JAoAoJFh/JwjaBISFtEww2yg/SP3hHMv
=Xcas
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
