From: Nigel Cunningham <ncunningham@cyclades.com>
Subject: Re: Lockless pagecache perhaps for 2.6.18?
Date: Mon, 27 Mar 2006 10:54:16 +1000
References: <20060323081100.GE26146@wotan.suse.de> <200603262021.46276.ncunningham@cyclades.com> <4427353A.6060905@yahoo.com.au>
In-Reply-To: <4427353A.6060905@yahoo.com.au>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1326753.93uEGe0Jv1";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200603271054.22272.ncunningham@cyclades.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

--nextPart1326753.93uEGe0Jv1
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Nick.

On Monday 27 March 2006 10:43, Nick Piggin wrote:
> Nigel Cunningham wrote:
> > Can I get a pointer to the patches and any docs please? Since I save the
> > page cache separately, I'd need a good understanding of the implications
> > of the changes.
>
> Hi Nigel,
>
> http://www.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.=
6.
>16-rc5/
>
> There are some patches... a lot of them, but only the last 5 in the series
> matter (the rest are pretty much in 2.6.16-head).
>
> There is also a small doc on the lockless radix-tree in that directory. I=
'm
> in the process of writing some documentation on the lockless pagecache
> itself...
>
> You probably don't need to worry too much unless you are testing
> page_count() under the tree_lock, held for writing, expecting that to
> stabilise page_count. In which case I could have a look at your code and
> see if it would be a problem.

Thanks.

I'm not far from head now, so guess I have no problems with the rest.

=46rom what you say about the other patches, I think I'm fine as far as the=
 rest=20
go too. I was mostly concerned that the modifications might make it possibl=
e=20
for the lru to start changing while the image is being written. It looks to=
=20
me now like I was being too paranoid (which isn't necessarily a bad thing, =
is=20
it?).

Regards,

Nigel

--nextPart1326753.93uEGe0Jv1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEJze+N0y+n1M3mo0RAtAXAKDZSvoxBvvhTMKSmS+bwXvkDlfxuACaAqyW
aIorYA1ncd/Wa5NqCLZ5tNM=
=rTQO
-----END PGP SIGNATURE-----

--nextPart1326753.93uEGe0Jv1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
