Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E85936B0037
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 06:10:20 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so3743467pab.6
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 03:10:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id j15si4402102pdm.442.2014.07.14.03.10.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jul 2014 03:10:18 -0700 (PDT)
Date: Mon, 14 Jul 2014 12:10:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
Message-ID: <20140714101007.GR9918@twins.programming.kicks-ass.net>
References: <53BECBA4.3010508@oracle.com>
 <alpine.LSU.2.11.1407101033280.18934@eggly.anvils>
 <53BED7F6.4090502@oracle.com>
 <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
 <53BEE345.4090203@oracle.com>
 <20140711082500.GB20603@laptop.programming.kicks-ass.net>
 <53BFD708.1040305@oracle.com>
 <alpine.LSU.2.11.1407110745430.2054@eggly.anvils>
 <20140711155958.GR20603@laptop.programming.kicks-ass.net>
 <53C2FD71.7090102@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XG0jWBK27HhJN4nS"
Content-Disposition: inline
In-Reply-To: <53C2FD71.7090102@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--XG0jWBK27HhJN4nS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jul 13, 2014 at 05:43:13PM -0400, Sasha Levin wrote:
> On 07/11/2014 11:59 AM, Peter Zijlstra wrote:
> >>> I agree with you that "The call trace is very clear on it that its no=
t", but
> >>> > > when you have 500 call traces you really want something better th=
an going
> >>> > > through it one call trace at a time.
> >> >=20
> >> > Points well made, and I strongly agree with Vlastimil and Sasha.
> >> > There is a world of difference between a lock wanted and a lock held,
> >> > and for the display of locks "held" to conceal that difference is un=
helpful.
> >> > It just needs one greppable word to distinguish the cases.
> > So for the actual locking scenario it doesn't make a difference one way
> > or another. These threads all can/could/will acquire the lock
> > (eventually), so all their locking chains should be considered.
>=20
> I think that the difference here is that we're not actually debugging a l=
ocking
> issue, we're merely using lockdep to help with figuring out a non-locking
> related bug and finding it difficult because lockdep's list of "held lock=
s"
> is really a lie :)

OK, so I suppose we could document that the top lock might not actually
be held (yet). But then who will ever read said document ;-)

The problem with 'fixing' this is that we don't exactly have spare
storage in struct held_lock, and lock_acquired() is only enabled for
CONFIG_LOCK_STAT.

I just don't think its worth it.

--XG0jWBK27HhJN4nS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTw6x/AAoJEHZH4aRLwOS6CYUQAIW8h8abNG2/pBv2zXprnqX9
pXhRM+8UOsRQnVkUEurpx6Ga5FjZWSYNDXovIwlFvDYvLkl6AKefC5N3WG7Ck3vb
Piklhx1Oe/vF9XN8dfSgm2v4eXYFagEU9rT6T4yWC3hm9L3aafwNxtfg9zeTt753
dxWO5nXRvJRXNn7sUW1XZzDU7QKIFeTA6F761HQToe7yrf+67ytTTGQw2asiQYdb
xqnMMV9dcYPuVDIiIy6TnMHNYhez97mkwimysIMW0lpaKD39KrIxUFzN3NR//VLB
NfwbyhBpDvndY1gYzfMYAynONTBl8Pw+dLb4rrGWYQlIQm3+L/wOPVCTWYbmIIeq
Q1gfQTjR4etFqR8mrGsK4ouuFB5Ecbph8LzHOSY87jt8R6gTNFtqLcSDdTMlHHcJ
n3L2i2FwQIcTp9rPjGkqAVz+pl9VIzYH49qxOWkawedn0uJwBJ91sejFeIOlKzqy
FOK6XWANdg0TlEdURzXIZMP0d0jpNihOc36ddo+xYXK6gYUBGPW8bXtGTF1ckEe0
ofh6ubNZ20Cp3uN/9jbUWc5Jk+hqseVvLt9l0eFpoLeQsXs40hlGLxez7+3onD0V
uBtHn31EKP1sCW+QgBNB0/Stzz+4WsvJZ1VQfI26tOmfrI5/92cam8q3cJnV7pI/
ueX3xqERq5Md3ek6lgz1
=FjA0
-----END PGP SIGNATURE-----

--XG0jWBK27HhJN4nS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
