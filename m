Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 280EE6B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 12:32:28 -0500 (EST)
Received: by yxe10 with SMTP id 10so5983506yxe.12
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 09:32:14 -0800 (PST)
Message-ID: <4AF06911.6040200@gmail.com>
Date: Tue, 03 Nov 2009 12:32:01 -0500
From: Gregory Haskins <gregory.haskins@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv7 2/3] mm: export use_mm/unuse_mm to modules
References: <cover.1257267892.git.mst@redhat.com> <20091103172411.GC5591@redhat.com>
In-Reply-To: <20091103172411.GC5591@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig598D640FFD0D66019E041E55"
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig598D640FFD0D66019E041E55
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> vhost net module wants to do copy to/from user from a kernel thread,
> which needs use_mm. Export it to modules.
>=20
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

I need this too:

Acked-by: Gregory Haskins <ghaskins@novell.com>

> ---
>  mm/mmu_context.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index ded9081..0777654 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -5,6 +5,7 @@
> =20
>  #include <linux/mm.h>
>  #include <linux/mmu_context.h>
> +#include <linux/module.h>
>  #include <linux/sched.h>
> =20
>  #include <asm/mmu_context.h>
> @@ -37,6 +38,7 @@ void use_mm(struct mm_struct *mm)
>  	if (active_mm !=3D mm)
>  		mmdrop(active_mm);
>  }
> +EXPORT_SYMBOL_GPL(use_mm);
> =20
>  /*
>   * unuse_mm
> @@ -56,3 +58,4 @@ void unuse_mm(struct mm_struct *mm)
>  	enter_lazy_tlb(mm, tsk);
>  	task_unlock(tsk);
>  }
> +EXPORT_SYMBOL_GPL(unuse_mm);



--------------enig598D640FFD0D66019E041E55
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrwaRIACgkQP5K2CMvXmqGMiACeN0+/nU4v8+3SYnFHbPpWW7yY
+YMAoIolyA+MA43fNvoJCMg/0hjy8eFS
=oNu+
-----END PGP SIGNATURE-----

--------------enig598D640FFD0D66019E041E55--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
