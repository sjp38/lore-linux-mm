Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5DB6B0010
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 21:12:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g13-v6so253767pgv.11
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 18:12:29 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p15-v6si2834922pgh.281.2018.08.07.18.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Aug 2018 18:12:28 -0700 (PDT)
Date: Wed, 8 Aug 2018 11:12:24 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH RFC 00/10] Introduce lockless shrink_slab()
Message-ID: <20180808111224.52a451d9@canb.auug.org.au>
In-Reply-To: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/yFMBaxGy2JljibeAimkhX54"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--Sig_/yFMBaxGy2JljibeAimkhX54
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Kirill,

On Tue, 07 Aug 2018 18:37:19 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrot=
e:
>
> After bitmaps of not-empty memcg shrinkers were implemented
> (see "[PATCH v9 00/17] Improve shrink_slab() scalability..."
> series, which is already in mm tree), all the evil in perf
> trace has moved from shrink_slab() to down_read_trylock().
> As reported by Shakeel Butt:
>=20
>      > I created 255 memcgs, 255 ext4 mounts and made each memcg create a
>      > file containing few KiBs on corresponding mount. Then in a separate
>      > memcg of 200 MiB limit ran a fork-bomb.
>      >
>      > I ran the "perf record -ag -- sleep 60" and below are the results:
>      > +  47.49%            fb.sh  [kernel.kallsyms]    [k] down_read_try=
lock
>      > +  30.72%            fb.sh  [kernel.kallsyms]    [k] up_read
>      > +   9.51%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_it=
er
>      > +   1.69%            fb.sh  [kernel.kallsyms]    [k] shrink_node_m=
emcg
>      > +   1.35%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_pr=
otected
>      > +   1.05%            fb.sh  [kernel.kallsyms]    [k] queued_spin_l=
ock_slowpath
>      > +   0.85%            fb.sh  [kernel.kallsyms]    [k] _raw_spin_lock
>      > +   0.78%            fb.sh  [kernel.kallsyms]    [k] lruvec_lru_si=
ze
>      > +   0.57%            fb.sh  [kernel.kallsyms]    [k] shrink_node
>      > +   0.54%            fb.sh  [kernel.kallsyms]    [k] queue_work_on
>      > +   0.46%            fb.sh  [kernel.kallsyms]    [k] shrink_slab_m=
emcg =20
>=20
> The patchset continues to improve shrink_slab() scalability and makes
> it lockless completely. Here are several steps for that:

So do you have any numbers for after theses changes?

--=20
Cheers,
Stephen Rothwell

--Sig_/yFMBaxGy2JljibeAimkhX54
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltqQ3gACgkQAVBC80lX
0GxavQf9EKFejil3+n6vL60fNlHSHDQnmX05ed6HsGTXza/1bbyxBdOOk6PkbbkR
Am2K5yPPUShKvsfwpy8pwJCzt8xxPcGSwtEg17G/JKGTEnd4zs8zEC8+z1RtZgzn
XtytDz87/XRfM9dX7thRhY2z6tUpNu5ZcuKOgJ912XJ8riurODEOb212V+vc/G9G
8g0Q4J1Pb99/sgoEljl+iQL5ZsFqCADCBaFwmYL0zLfNgs9zrUimflnNWOBQUYbQ
bzxrY5qbdaWRCmVh6f5FSrzXoxoOk+WJ+Ekoq//mTTceZWFuZdNvh9qXWy8S+dN2
KqisepOQ0+Dh+0GGXSanG+jFbPyFzg==
=26Fb
-----END PGP SIGNATURE-----

--Sig_/yFMBaxGy2JljibeAimkhX54--
