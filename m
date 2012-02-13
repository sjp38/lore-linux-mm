Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9DE136B13F2
	for <linux-mm@kvack.org>; Sun, 12 Feb 2012 19:22:04 -0500 (EST)
Date: Mon, 13 Feb 2012 11:21:45 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PULL REQUEST] DMA-mapping framework redesign preparation
 patches
Message-Id: <20120213112145.4b8990c739d297cd30714d52@canb.auug.org.au>
In-Reply-To: <1328898737-15854-1-git-send-email-m.szyprowski@samsung.com>
References: <1328898737-15854-1-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__13_Feb_2012_11_21_45_+1100_8oMlxM5sQu=KHg4V"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

--Signature=_Mon__13_Feb_2012_11_21_45_+1100_8oMlxM5sQu=KHg4V
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marek,

On Fri, 10 Feb 2012 19:32:17 +0100 Marek Szyprowski <m.szyprowski@samsung.c=
om> wrote:
>
> Our patches with DMA-mapping framework redesign proposal have been
> hanging for over a month with just a few comments. We would like to go
> further in the development, but first I would like to ask You to give
> them a try in the linux-next kernel.
>=20
> For everyone interested in this patch series, here is the relevant
> thread: https://lkml.org/lkml/2011/12/23/97
>=20
> If there are any problems with our git tree, please contact Marek=20
> Szyprowski <m.szyprowski@samsung.com> or alternatively Kyungmin Park
> <kyungmin.park@samsung.com>.
>=20
> The following changes since commit 62aa2b537c6f5957afd98e29f96897419ed5eb=
ab:
>=20
>   Linux 3.3-rc2 (2012-01-31 13:31:54 -0800)
>=20
> are available in the git repository at:
>   git://git.infradead.org/users/kmpark/linux-samsung dma-mapping-next

I have added this from today.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Mon__13_Feb_2012_11_21_45_+1100_8oMlxM5sQu=KHg4V
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPOFeZAAoJEECxmPOUX5FEGasQAJRfELGvaG157f04fLOp5cZ+
BExY8MINAksS9ksXnf+o7emW9FWZFTLZT3pJ7Gnx8j/Po+kYnITOStRQLl6K8h3Y
+cZmYubikIrZyPJCVYBZUTH0Gi/5VrTCx/rbolS2ai67WicKa7qzPOJ5D/oaeCdY
CiOWMIgyaNbESpoR/l32Ta4XMJG0aDIV6bWlBpmKZVSzmpOFh40StsbQ3Ej6UUfo
b+lo7IhOegjvNWITbiuIRDe9bAk5ONW2UU1z5sOWq/aELytRbSw1bNifvJlQF1VG
AD+VNjEMrYNKg9soRpaZaIqAN1wb8a+I3//iaSL9kVstPo+D5uJLjAIEWBsgUO+N
Duu3l8/GNL9tb1EvDXrt4d+H8zaow9P11rGHb2e6x9ndLZDmijjcYLQa1R/ektxo
Z7kZIJNvi6rGlAurojo+q5gjnIP4aDDjZNMJ4pCayn5+YCLfDvu6jcK7od5S5dEM
fbmVkAAysd8ajciJdN0Yj9Vv/oZ2/ARaQjAMVZtOBNTj5JR/WdRPeYZ0y71a4hSX
RYNdeiQC3AhYufvXe5YCP7e+MvzMRHW336Rjyd+AMNjYx/cs6JZSOVgz6qKTWX6H
oWde9Tl8A70eoN3/LtS7kC+WX228gPd9qPn5sHxyiKVV87OxwNaDP3kZqS1k3b3r
4gyxILj3Uf7TanB2Wbsh
=mWBa
-----END PGP SIGNATURE-----

--Signature=_Mon__13_Feb_2012_11_21_45_+1100_8oMlxM5sQu=KHg4V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
