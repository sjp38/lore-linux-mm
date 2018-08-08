Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53D256B000A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 21:06:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m25-v6so235784pgv.22
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 18:06:06 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id s27-v6si3154253pfd.231.2018.08.07.18.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Aug 2018 18:06:05 -0700 (PDT)
Date: Wed, 8 Aug 2018 11:05:42 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180808110542.6df3f48f@canb.auug.org.au>
In-Reply-To: <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
	<153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/IP8rFemfHJulIaL8/xLQERN"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--Sig_/IP8rFemfHJulIaL8/xLQERN
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Kirill,

On Tue, 07 Aug 2018 18:37:36 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrot=
e:
>
> This patch kills all CONFIG_SRCU defines and
> the code under !CONFIG_SRCU.
>=20
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  drivers/base/core.c                                |   42 --------------=
------
>  include/linux/device.h                             |    2 -
>  include/linux/rcutiny.h                            |    4 --
>  include/linux/srcu.h                               |    5 --
>  kernel/notifier.c                                  |    3 -
>  kernel/rcu/Kconfig                                 |   12 +-----
>  kernel/rcu/tree.h                                  |    5 --
>  kernel/rcu/update.c                                |    4 --
>  .../selftests/rcutorture/doc/TREE_RCU-kconfig.txt  |    5 --
>  9 files changed, 3 insertions(+), 79 deletions(-)

You left quite a few "select SRCU" statements scattered across Kconfig
files:

$ git grep -l 'select SRCU' '*Kconfig*'
arch/arm/kvm/Kconfig
arch/arm64/kvm/Kconfig
arch/mips/kvm/Kconfig
arch/powerpc/kvm/Kconfig
arch/s390/kvm/Kconfig
arch/x86/Kconfig
arch/x86/kvm/Kconfig
block/Kconfig
drivers/clk/Kconfig
drivers/cpufreq/Kconfig
drivers/dax/Kconfig
drivers/devfreq/Kconfig
drivers/hwtracing/stm/Kconfig
drivers/md/Kconfig
drivers/net/Kconfig
drivers/opp/Kconfig
fs/btrfs/Kconfig
fs/notify/Kconfig
fs/quota/Kconfig
init/Kconfig
kernel/rcu/Kconfig
kernel/rcu/Kconfig.debug
mm/Kconfig
security/tomoyo/Kconfig

--=20
Cheers,
Stephen Rothwell

--Sig_/IP8rFemfHJulIaL8/xLQERN
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltqQeYACgkQAVBC80lX
0GzCAggAjky/YInwyHf0hhdtGhlsTa7vvLGJcP+elKvroDO5mdb3+Fpb6n+Qa7GN
YCDuTYv5Y8ZMGvn9FDcjy/KK9gpWyp/mvWXQ8+a7ZVCd4SqFMjk7FMNOiI2jotw8
bL3d0blzZoJGI6HCWSvGhLIVkXGZUizd+dGfDABj7AyuMZTbcs65PyeqwbrBGeHj
STNVtyYKb7zHpNwt2JEOqHOKnenOdvpKLzZK6S39IYxXvIzmlIFr/QdZRTY4j3jZ
xZKIKLhOixM6giSj0A8pP0m/KAUEcRaSCGuQh8DbBWQOUIix/4oeuwIwZ0yyS5Wr
unjIxdFN3gUGCchbuvecCCVE/y1p5A==
=hXsZ
-----END PGP SIGNATURE-----

--Sig_/IP8rFemfHJulIaL8/xLQERN--
