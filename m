Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 605116B000D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 21:08:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so362593pfi.10
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 18:08:31 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id g9-v6si2336233plb.107.2018.08.07.18.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Aug 2018 18:08:30 -0700 (PDT)
Date: Wed, 8 Aug 2018 11:08:27 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180808110827.65631461@canb.auug.org.au>
In-Reply-To: <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
	<153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//wODAd0V11DVLAu0Qy+Ta_s"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--Sig_//wODAd0V11DVLAu0Qy+Ta_s
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

So what sort of overheads (in terms of code size and performance) are
we adding by having SRCU enabled where it used not to be?

--=20
Cheers,
Stephen Rothwell

--Sig_//wODAd0V11DVLAu0Qy+Ta_s
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltqQosACgkQAVBC80lX
0GxHGwgAjVnIoT20e4JSYycGiEqHHa55yGjv5LKngiTucYPHmJ31bMFrkK3RVd7s
r6M6RVXSQVA21k/Vy8hPV0q+sHChA38xfCx0ZebSrsGfpzy3x/5lgGBUNLZmEoW1
bsYT5/XV6AUM1bWbmO+llnIC4LSL4dN+RMYngElcto8++M6E5YG+5YGCNs+wcrKu
Xg5jSShO/G2U0nRMENEeXexcMeRfShGpAeejrZScad23wkkx+TJ+O1lw1ln6afdv
c2PRz3pEYmWINiCjZNEwOz1NGsjmHh8IgWnfP3rNID4iq1Gw+3cxO5L+cfX9vCzv
jhofBYIo7A5Yf3dmGUvsKTqx7SsuLA==
=4lXj
-----END PGP SIGNATURE-----

--Sig_//wODAd0V11DVLAu0Qy+Ta_s--
