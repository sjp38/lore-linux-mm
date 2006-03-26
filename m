From: Nigel Cunningham <ncunningham@cyclades.com>
Subject: Re: Lockless pagecache perhaps for 2.6.18?
Date: Sun, 26 Mar 2006 20:21:40 +1000
References: <20060323081100.GE26146@wotan.suse.de>
In-Reply-To: <20060323081100.GE26146@wotan.suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1568995.tqgjAY3qyE";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200603262021.46276.ncunningham@cyclades.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

--nextPart1568995.tqgjAY3qyE
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Nick.

On Thursday 23 March 2006 18:11, Nick Piggin wrote:
> Hi,
>
> Would there be any objection to having my lockless pagecache patches
> merged into -mm, for a possible mainline merge after 2.6.17 (ie. if/
> when the mm hackers feel comfortable with it).
>
> There are now just 3 patches: 15 files, 312 insertions, 81 deletions
> for the core changes, including RCU radix-tree. (not counting those
> last two I just sent you Andrew (VM_BUG_ON, find_trylock_page))
>
> It is fairly well commented, and not overly complex (IMO) compared
> with other lockless stuff in the tree now.
>
> My main motivation is to get more testing and more serious reviews,
> rather than trying to clear a fast path into mainline.
>
> Nick

Can I get a pointer to the patches and any docs please? Since I save the pa=
ge=20
cache separately, I'd need a good understanding of the implications of the=
=20
changes.

Regards,

Nigel

--nextPart1568995.tqgjAY3qyE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEJms6N0y+n1M3mo0RAn9MAJ9RvlVVnPkcVz9p36uXW58JjULgkACbBSoL
17R0oxCV0C4tw9wbSTX7Q4k=
=to0l
-----END PGP SIGNATURE-----

--nextPart1568995.tqgjAY3qyE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
