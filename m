Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 697526B0083
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 02:28:49 -0500 (EST)
Date: Thu, 15 Nov 2012 09:29:55 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 00/11] Introduce huge zero page
Message-ID: <20121115072955.GA9387@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
In-Reply-To: <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 01:33:42PM -0800, Andrew Morton wrote:
> On Wed,  7 Nov 2012 17:00:52 +0200
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>=20
> > Andrew, here's updated huge zero page patchset.
>=20
> There is still a distinct lack of reviewed-by's and acked-by's on this
> patchset.
>=20
> On 13 Sep, Andrea did indicate that he "reviewed the whole patchset and
> it looks fine to me".  But that information failed to make it into the
> changelogs, which is bad.

As I said before, I had to drop Andrea's reviewed-by on rebase to
v3.7-rc1. I had to solve few not-that-trivial conflicts and I was not sure
if the reviewed-by is still applicable.

> I grabbed the patchset.  I might hold it over until 3.9 depending on
> additional review/test feedback and upon whether Andrea can be
> persuaded to take another look at it all.
>=20
> I'm still a bit concerned over the possibility that some workloads will
> cause a high-frequency free/alloc/memset cycle on that huge zero page.=20
> We'll see how it goes...
>=20
> For this reason and for general ease-of-testing: can and should we add
> a knob which will enable users to disable the feature at runtime?  That
> way if it causes problems or if we suspect it's causing problems, we
> can easily verify the theory and offer users a temporary fix.
>=20
> Such a knob could be a boot-time option, but a post-boot /proc thing
> would be much nicer.

Okay, I'll add sysfs knob.

BTW, we already have build time knob: just revert last two patches in the
series. It will bring lazy allocation instead of refcounting.

--=20
 Kirill A. Shutemov

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpJnzAAoJEAd+omnVudOMtwwQAL/CCVFGb7j5GyMcGl5/3L2M
jfRl+hyN+y3mjcl7N1naMpwNASUiWGJU9Vea/5isc25j+YLZmn8dKqn+BBuvP9gl
VUBnoKRzkn3mLhSQT6cVkDjeg3tFkwMG5HAkeLhfJsEqYv+C+TOsu8qdO0Pep2vK
lCx+tvyjHG3/cqIMu+zd1b9gZnLqJaQwJMYllidAJ1NvPotvLxFSdbkzc0GHsdUF
iVLAaqYrLUUHosnNin2Qw6JUZS+zLFXX9jnxD2ggAMfLTz092fAIPCZtkyyVK40g
WDMg+sQScqGX8o8fN/68TDbL4DRNqHbiO7H7TUwA38KM0l8vThZib42kAmJDQjVn
wcaPnGsqVIk4ijxd+d1z/OqHLx8h4eC0etA5034egiIrqFImGC+kyaqaA5sIyfpQ
f7gRlxRxEs2Brx+E7oUfTX8cJUVwxGA2kmQYMrc29lAJ80RaBxPUfAHyeJtJJOEZ
Ron7Pufo571fXO/DA5PQ1xRcB1xLvkYL3Dj3sbJuUkAw+STkK0oNXmrnLvsrHKAX
WlrvLJxfxYmUaoc1nKY5NpjiIlSv/Mi2zSHOuiAIoe6eVfV5ceLzseeaPei9UyNt
Y5Bm3py4yJGJceNzW3kJegPZa3ywPStaRw+iUqRtFPfiBN+nfHeIjv1SOBk31DVB
NdZGcXORE/BhqFr5qjUm
=6V53
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
