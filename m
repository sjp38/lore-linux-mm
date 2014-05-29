Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 940876B005A
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:53:13 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so5115252wib.10
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:53:13 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ub4si34509721wjc.56.2014.05.29.00.53.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 00:53:09 -0700 (PDT)
Date: Thu, 29 May 2014 09:52:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/4] virtio_ring: unify direct/indirect code paths.
Message-ID: <20140529075256.GZ30445@twins.programming.kicks-ass.net>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
 <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="98nrjS+sEG4ki7TP"
Content-Disposition: inline
In-Reply-To: <1401348405-18614-5-git-send-email-rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>


--98nrjS+sEG4ki7TP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 29, 2014 at 04:56:45PM +0930, Rusty Russell wrote:
> virtqueue_add() populates the virtqueue descriptor table from the sgs
> given.  If it uses an indirect descriptor table, then it puts a single
> descriptor in the descriptor table pointing to the kmalloc'ed indirect
> table where the sg is populated.
>=20
> Previously vring_add_indirect() did the allocation and the simple
> linear layout.  We replace that with alloc_indirect() which allocates
> the indirect table then chains it like the normal descriptor table so
> we can reuse the core logic.
>=20
> Before:
> 	gcc 4.8.2: virtio_blk: stack used =3D 392
> 	gcc 4.6.4: virtio_blk: stack used =3D 480
>=20
> After:
> 	gcc 4.8.2: virtio_blk: stack used =3D 408
> 	gcc 4.6.4: virtio_blk: stack used =3D 432

Is it worth it to make the good compiler worse? People are going to use
the newer GCC more as time goes on anyhow.

--98nrjS+sEG4ki7TP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJThudUAAoJEHZH4aRLwOS6Uk0P/ijNpnrDzVTexcI8vvssaATg
v1BdjLwmuJwmJhD/pCxQTyaseLMDtj4isHPmKfM/7jXzNdIaf6rKOsrCN2TLNyDw
7hXoG9OS8m7ceqcB+W/suEcUnzv4bCnvsi1ZqHa+h63P+E5yGAWBL7cYtK7yMVjZ
pRpKXMbl0WXJTGuRMK/to26B+45jQFp+8PcVM44gb9eSjy+/SwSpoqu3x4Wa/8+o
wQ+wNATrNrt57XtFcsIZbY93JFFdxIH4+7Fb/55oGrWbXB2w5+gGuaNqLljepI6v
wPDKZpWSHZLJAeY/th2bseaew+PFxZEECOIWPf9iMdSHUCUqEiuNekJRvobIEdcg
/ohmvWEyzwlKAuuEa9FSjKCVHmOU8C/JozL4rEhwUHPhHQm5jMi4enX0vrB3+9u8
wZM3o/96u0WklK+OoY9Q2K53MTUp0AyLAVqMgJ9K/mw4yZUxw6JT4Ka1UpGzLta0
TSEuZRSorUfIyQ7tNV3lVF9fq93HGn4T9Y5W1aKKD8RXtwKimjvIp3lmslgrF7gn
DkmGGWx5ajnekWmm7d3mMGVqHtTcH5/HLoTq5z2dphCBrKcF/26jm4YmaQI57ptX
cPnfhg7ag6evGxmZ/uYRQ/liEAJLS0ln5S9WnmuoyAB5cWOEbsvRn68nkTDLXQbd
ITz+S5knQ16SPGVDPDqW
=rEPW
-----END PGP SIGNATURE-----

--98nrjS+sEG4ki7TP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
