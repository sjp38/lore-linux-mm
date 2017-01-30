Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD706B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 05:21:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so449769960pgd.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 02:21:54 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id a204si12220336pfa.101.2017.01.30.02.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 02:21:53 -0800 (PST)
Date: Mon, 30 Jan 2017 12:21:55 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 5/9] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170130102155.GK6005@mtr-leonro.local>
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="LNKrWK8T5LDJo+fl"
Content-Disposition: inline
In-Reply-To: <20170130094940.13546-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Yishai Hadas <yishaih@mellanox.com>, Oleg Drokin <oleg.drokin@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org


--LNKrWK8T5LDJo+fl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 30, 2017 at 10:49:36AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests <= 32kB (with 4kB pages) are basically never failing and invoke
> OOM killer to satisfy the allocation. This sounds too disruptive for
> something that has a reasonable fallback - the vmalloc. On the other
> hand those requests might fallback to vmalloc even when the memory
> allocator would succeed after several more reclaim/compaction attempts
> previously. There is no guarantee something like that happens though.
>
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>
> Changes since v1
> - add kvmalloc_array - this might silently fix some overflow issues
>   because most users simply didn't check the overflow for the vmalloc
>   fallback.
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: "Yan, Zheng" <zyan@redhat.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: netdev@vger.kernel.org
> Acked-by: Andreas Dilger <andreas.dilger@intel.com> # Lustre
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com> # Xen bits
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com> # KVM/s390
> Acked-by: Dan Williams <dan.j.williams@intel.com> # nvdim
> Acked-by: David Sterba <dsterba@suse.com> # btrfs
> Acked-by: Ilya Dryomov <idryomov@gmail.com> # Ceph
> Acked-by: Tariq Toukan <tariqt@mellanox.com> # mlx4
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Leon Romanovsky <leonro@mellanox.com> # mlx5

--LNKrWK8T5LDJo+fl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliPE8MACgkQ5GN7iDZy
WKfJfg//VOxtLjgK0HaPkAHu0w0PVT1lOHx8xasYvbhQVtdUGdmspMrgIhcAvkNt
MN4/sLUPfm86tvwUlHqp36jmcXHXnauAZTUL/HYcwmEsLeAD65JlpR+KG2sz9ijb
47FBDOd5nPzfIO0k7iXB8kSiEdp8H9SwTedV2MgiFfeHM180gTv2q2QzMCJry644
eq/efEIcfvzhrSpzLboQ1b7p19HkuKhWRqZdSZB+PL8lp7WZoFL8jdUd6PeXAek7
9TCrMZJvuyCgJgTRgijPJlcgERJ9rn2ri7k+YLuHdig8GV6D6LyxHICrPZvwsdLr
Y+lyLWLAUwW3P3k1oa41CIo/f2HeKITYgfU4rdVLmzi0iXUFpl2A3PZDfxA6eYzk
wMG+GHuwDsLYmbBE6XOMToL07MHh5GlZXchykRNit1bS4pACKfj9Jk9gqJLVd3gn
Xte0WTaBVoqNB3uW6VH1ViwlmjKLD7y6aBMKwdFZIIuDLlYOk/ir6LZMb+qfvnU9
CHZ221XyJhr2RgaynmaHiC8nOXIwVn1HJm/etDHWM05ohbyep8Rr3+Mk/OmZfDS/
TQu9J9zono//KblkmaBY39Bcuw4bmncmKmT5dnT/0jPKtwFQL8vQ1OSDFk4b/GgL
WnYF9bqB1XA2ZKmvTI0ye167CTCuBfsE5MGpOgds5FUjMg/QKDw=
=qAIc
-----END PGP SIGNATURE-----

--LNKrWK8T5LDJo+fl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
