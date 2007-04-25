Received: from  ([::ffff:212.65.3.74] HELO donald.sf-tec.de) (auth=eike-kernel@sf-tec.de)
	by mail.sf-mail.de (Qsmtpd 0.9) with (DHE-RSA-AES256-SHA encrypted) ESMTPSA
	for <linux-mm@kvack.org>; Wed, 25 Apr 2007 14:29:29 +0200
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Removing VM_LOCKED from user memory
Date: Wed, 25 Apr 2007 14:29:17 +0200
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4270414.IHIPDGtuYs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200704251429.26014.eike-kernel@sf-tec.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--nextPart4270414.IHIPDGtuYs
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I need some assistance handling a large memory segment of a user process.

The user calls the kernel with a address and a length of it's own memory. M=
y=20
driver will lock this memory using get_user_pages(). This memory is used as=
=20
DMA buffer directly from or to user processes.

Everything works fine that far: allocating, DMA mapping, DMA transfers. But=
 I=20
currently can't get rid of the buffer again. Which function would help me t=
o=20
get all pages unlocked once the buffer isn't needed anymore?

Is it enough to simply call sys_munlock() from the release and cleanup=20
functions?

There are no plans to share these mappings between different processes.

Greetings,

Eike

--nextPart4270414.IHIPDGtuYs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGL0mlXKSJPmm5/E4RAjdMAJ40t9quwChTbbi8dciplKENDCqUPgCfZ6t+
toI0Psg11rZY4naPV7Bui8w=
=QRMy
-----END PGP SIGNATURE-----

--nextPart4270414.IHIPDGtuYs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
