Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCA4B6B0269
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 20:36:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w18-v6so290241plp.3
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 17:36:54 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p123-v6si368579pfg.281.2018.08.01.17.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 Aug 2018 17:36:53 -0700 (PDT)
Date: Thu, 2 Aug 2018 10:36:48 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v2 1/3] mm: introduce mem_cgroup_put() helper
Message-ID: <20180802103648.3d9f8e6d@canb.auug.org.au>
In-Reply-To: <20180802003201.817-2-guro@fb.com>
References: <20180802003201.817-1-guro@fb.com>
	<20180802003201.817-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Agfn7mIH_ICKtkxGZ9s+SbR"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

--Sig_/Agfn7mIH_ICKtkxGZ9s+SbR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Roman,

On Wed, 1 Aug 2018 17:31:59 -0700 Roman Gushchin <guro@fb.com> wrote:
>
> Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
>=20
> Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

I have no idea why my Signed-off-by is attached to this patch (or
Andrew's for that matter) ...

--=20
Cheers,
Stephen Rothwell

--Sig_/Agfn7mIH_ICKtkxGZ9s+SbR
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltiUiEACgkQAVBC80lX
0GxAyAf/TXDnyXATwzRiwgVQOOa8KP0UhK5pDewWcq4gK17X8rrf7jyuJjWWm4Q7
6lEANDfpnRcZ5WXPuksEHLGO0Ff4NtW4fGHxBshx7ai0CPow6Pp8wBTj1CKuE79M
MVyRLjhWDiGZAUm/PX3mX6FY8OQoNP/DCzHRG1tPgX8IewkBfO33um6w6eL2sGal
R8ihlwAg4O3vdIhv3TvcXvblLaEo25foMj9p7fs3o1QF7TGBb4hZtu6nb9X1KVNQ
EVgy7q2BL8R2iZ7F60bAEkviWmsVoTXBXHTc8pbRHxPy3DG9+LUuj3WH5dxTUU/Z
kfWX/U3YZYWMb+lThia/mQwbhuScXg==
=y4OD
-----END PGP SIGNATURE-----

--Sig_/Agfn7mIH_ICKtkxGZ9s+SbR--
