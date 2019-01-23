Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 580F58E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 11:50:38 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id x26so1850541pgc.5
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 08:50:38 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x128si6588679pfb.128.2019.01.23.08.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 08:50:37 -0800 (PST)
Message-ID: <7d8a6120ea335d74c41a5fba3754518ea60e936e.camel@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/3] treewide: Lift switch variables
 out of switches
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Date: Wed, 23 Jan 2019 08:51:38 -0800
In-Reply-To: <20190123110349.35882-2-keescook@chromium.org>
References: <20190123110349.35882-1-keescook@chromium.org>
	 <20190123110349.35882-2-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ckUn9AFZsnGNoWsnxDog"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com, intel-wired-lan@lists.osuosl.org, linux-fsdevel@vger.kernel.org, xen-devel@lists.xenproject.org, Laura Abbott <labbott@redhat.com>, linux-kbuild@vger.kernel.org, Alexander Popov <alex.popov@linux.com>


--=-ckUn9AFZsnGNoWsnxDog
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-01-23 at 03:03 -0800, Kees Cook wrote:
> Variables declared in a switch statement before any case statements
> cannot be initialized, so move all instances out of the switches.
> After this, future always-initialized stack variables will work
> and not throw warnings like this:
>=20
> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> fs/fcntl.c:738:13: warning: statement will never be executed [-
> Wswitch-unreachable]
>    siginfo_t si;
>              ^~
>=20
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

For the e1000 changes.

> ---
>  arch/x86/xen/enlighten_pv.c                   |  7 ++++---
>  drivers/char/pcmcia/cm4000_cs.c               |  2 +-
>  drivers/char/ppdev.c                          | 20 ++++++++---------
> --
>  drivers/gpu/drm/drm_edid.c                    |  4 ++--
>  drivers/gpu/drm/i915/intel_display.c          |  2 +-
>  drivers/gpu/drm/i915/intel_pm.c               |  4 ++--
>  drivers/net/ethernet/intel/e1000/e1000_main.c |  3 ++-
>  drivers/tty/n_tty.c                           |  3 +--
>  drivers/usb/gadget/udc/net2280.c              |  5 ++---
>  fs/fcntl.c                                    |  3 ++-
>  mm/shmem.c                                    |  5 +++--
>  net/core/skbuff.c                             |  4 ++--
>  net/ipv6/ip6_gre.c                            |  4 ++--
>  net/ipv6/ip6_tunnel.c                         |  4 ++--
>  net/openvswitch/flow_netlink.c                |  7 +++----
>  security/tomoyo/common.c                      |  3 ++-
>  security/tomoyo/condition.c                   |  7 ++++---
>  security/tomoyo/util.c                        |  4 ++--
>  18 files changed, 45 insertions(+), 46 deletions(-)


--=-ckUn9AFZsnGNoWsnxDog
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlxIm5oACgkQ5W/vlVpL
7c6nHA/+I5AUD+yELZtkueGqZrZ0E/i+TX7+2pxKNRieTprDcNtILryQEfP4XrvX
r7X4QwfM9Rfmrlr1WcZrQW2LVn+uuflivdbtCmE0ZX4iBnIhAoeguyZ6+hInlbDY
oN+TzAFm96uYB70bOnyqutGVBKfMkazDXiVtqzbu+7HAMWFnQFFzKX6/o+eL0/Np
1qBQP1okUj2dM/ujfQKLxWQu8IupAI5nDeucqFsscZO1Yh/g9IjOyClDUGSXAyBO
Xr67/lCCAt1/Z0GkqN+HElzbtjokp0xitLFF9MyOkmrHiHKcvD62I4OJ97OXlFuF
YXvwIg6/9NfVhGgh/k8z6xAAB9JDIZ0rb5yezcdu1FqSYVrAyzI4tmD+l3fS7zyr
AnHaQ4tTzsmj0T70bz1wooR2oOnyA2MhVhGUfPXNER24TaApApki5eqydsVPpsMk
3gukrduJogzBL2AVMTp780UAj2WnHYsJhso62fYOPT0huDhAsIWaqcuVi5Fs0o94
b9t84vtQG5NHFEBmaaaVdFhB9+Tw3sOHh+nglVzHm3UZNHcFi+lEgxjtV6cTcm0C
1oIX6J17KkZPxkOf0ENU8Cj/gnvNRF/ZhkDPe0r1bMYnL8w0WxB/rCSPQfWD/F5r
bdTuBQbV5MKBc4evjKtB1mFUYD9WrOMIbPjMo9pkJ0XQuttdthc=
=MB+1
-----END PGP SIGNATURE-----

--=-ckUn9AFZsnGNoWsnxDog--
