Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 27 Nov 2018 20:50:08 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181127195008.GA20692@amd>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline
In-Reply-To: <20181105165558.11698-2-daniel.m.jordan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz
List-ID: <linux-mm.kvack.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> Motivates and explains the ktask API for kernel clients.
>=20
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  Documentation/core-api/index.rst |   1 +
>  Documentation/core-api/ktask.rst | 213 +++++++++++++++++++++++++++++++
>  2 files changed, 214 insertions(+)
>  create mode 100644 Documentation/core-api/ktask.rst
>=20
> diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/in=
dex.rst
> index 3adee82be311..c143a280a5b1 100644
> --- a/Documentation/core-api/index.rst
> +++ b/Documentation/core-api/index.rst
> @@ -18,6 +18,7 @@ Core utilities
>     refcount-vs-atomic
>     cpu_hotplug
>     idr
> +   ktask
>     local_ops
>     workqueue
>     genericirq
> diff --git a/Documentation/core-api/ktask.rst b/Documentation/core-api/kt=
ask.rst
> new file mode 100644
> index 000000000000..c3c00e1f802f
> --- /dev/null
> +++ b/Documentation/core-api/ktask.rst
> @@ -0,0 +1,213 @@
> +.. SPDX-License-Identifier: GPL-2.0+
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +ktask: parallelize CPU-intensive kernel work
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +:Date: November, 2018
> +:Author: Daniel Jordan <daniel.m.jordan@oracle.com>


> +For example, consider the task of clearing a gigantic page.  This used t=
o be
> +done in a single thread with a for loop that calls a page clearing funct=
ion for
> +each constituent base page.  To parallelize with ktask, the client first=
 moves
> +the for loop to the thread function, adapting it to operate on the range=
 passed
> +to the function.  In this simple case, the thread function's start and e=
nd
> +arguments are just addresses delimiting the portion of the gigantic page=
 to
> +clear.  Then, where the for loop used to be, the client calls into ktask=
 with
> +the start address of the gigantic page, the total size of the gigantic p=
age,
> +and the thread function.  Internally, ktask will divide the address rang=
e into
> +an appropriate number of chunks and start an appropriate number of threa=
ds to
> +complete these chunks.

Great, so my little task is bound to CPUs 1-4 and uses gigantic
pages. Kernel clears them for me.

a) Do all the CPUs work for me, or just CPUs I was assigned to?

b) Will my time my_little_task show the system time including the
worker threads?

Best regards,
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlv9n/AACgkQMOfwapXb+vIOfACfQSkhNEr/CWOuRXE0/1FDKN3N
MY8AoMRyDsvjNrgfDTZdc+KV+OpDRgiY
=/Efn
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
