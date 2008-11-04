Received: by nf-out-0910.google.com with SMTP id c10so1594103nfd.6
        for <linux-mm@kvack.org>; Tue, 04 Nov 2008 08:47:26 -0800 (PST)
Message-ID: <49107D98.9080201@gmail.com>
Date: Tue, 04 Nov 2008 18:51:36 +0200
From: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>
MIME-Version: 1.0
Subject: Re: mmap: is default non-populating behavior stable?
References: <490F73CD.4010705@gmail.com>	<1225752083.7803.1644.camel@twins>	<490F8005.9020708@redhat.com>	<491070B5.2060209@nortel.com>	<1225814820.7803.1672.camel@twins> <20081104162820.644b1487@lxorguk.ukuu.org.uk>
In-Reply-To: <20081104162820.644b1487@lxorguk.ukuu.org.uk>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD117098E412C7926C3D55A1A"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Peter Zijlstra <peterz@infradead.org>, Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD117098E412C7926C3D55A1A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Alan Cox wrote:
> On Tue, 04 Nov 2008 17:07:00 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
>> [snip]
>> I'm not sure how POSIX speaks of this.
>>
>> I think Linux does the expected thing.
>=20
> I believe our behaviour is correct for mmap/mumap/truncate and it
> certainly used to be and was tested.
>=20
> At the point you do anything involving mremap (which is non posix) our
> behaviour becomes rather bizarre.

Thanks to all for answers. I have made the conclusion that doing "open() =
new
file, truncate(<big size>), mmap(<the same big size>), write/read some me=
mory
pages" should not populate other, untouched by write/read pages (until
MAP_POPULATE given), right?

--=20
Eugene V. Lyubimkin aka JackYF


--------------enigD117098E412C7926C3D55A1A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkkQfZ4ACgkQchorMMFUmYxbqgCfUXKdc7I7juZHEBsyPsVVtwiu
zYwAn3cPA8yySpv583SYEUxTmcPALVQm
=mfAu
-----END PGP SIGNATURE-----

--------------enigD117098E412C7926C3D55A1A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
