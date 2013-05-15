Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id E3E7E6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 13:22:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <76ac8597-9be3-44fd-a3d5-39c6130a171a@default>
Date: Wed, 15 May 2013 10:22:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] Fixes, cleanups, compile warning fixes, and documentation
 update for Xen tmem driver (v2).
References: <<1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>>
In-Reply-To: <<1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@kernel.org>, bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com

> From: Konrad Rzeszutek [mailto:ketuzsezr@gmail.com] On Behalf Of Konrad R=
zeszutek Wilk
> Sent: Tuesday, May 14, 2013 12:09 PM
> To: bob.liu@oracle.com; dan.magenheimer@oracle.com; linux-kernel@vger.ker=
nel.org; akpm@linux-
> foundation.org; linux-mm@kvack.org; xen-devel@lists.xensource.com
> Subject: [PATCH] Fixes, cleanups, compile warning fixes, and documentatio=
n update for Xen tmem driver
> (v2).
>=20
> Heya,
>=20
> These nine patches fix the tmem driver to:
>  - not emit a compile warning anymore (reported by 0 day test compile too=
l)
>  - remove the various nofrontswap, nocleancache, noselfshrinking, noselfb=
allooning,
>    selfballooning, selfshrinking bootup options.
>  - said options are now folded in the tmem driver as module options and a=
re
>    much shorter (and also there are only four of them now).
>  - add documentation to explain these parameters in kernel-parameters.txt
>  - And lastly add some logic to not enable selfshrinking and selfballooni=
ng
>    if frontswap functionality is off.
>=20
> That is it. Tested and ready to go. If nobody objects will put on my queu=
e
> for Linus on Monday.

FWIW, I've scanned all of these and they look sane and good.  So consider a=
ll:

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
=20
>  Documentation/kernel-parameters.txt |   21 ++++++++
>  drivers/xen/Kconfig                 |    7 +--
>  drivers/xen/tmem.c                  |   87 ++++++++++++++++-------------=
------
>  drivers/xen/xen-selfballoon.c       |   47 ++----------------
>  4 files changed, 69 insertions(+), 93 deletions(-)
>=20
> (oh nice, more deletions!)
>=20
> Konrad Rzeszutek Wilk (9):
>       xen/tmem: Cleanup. Remove the parts that say temporary.
>       xen/tmem: Move all of the boot and module parameters to the top of =
the file.
>       xen/tmem: Split out the different module/boot options.
>       xen/tmem: Fix compile warning.
>       xen/tmem: s/disable_// and change the logic.
>       xen/tmem: Remove the boot options and fold them in the tmem.X param=
eters.
>       xen/tmem: Remove the usage of 'noselfshrink' and use 'tmem.selfshri=
nk' bool instead.
>       xen/tmem: Remove the usage of '[no|]selfballoon' and use 'tmem.self=
ballooning' bool instead.
>       xen/tmem: Don't use self[ballooning|shrinking] if frontswap is off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
