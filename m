Received: by yx-out-1718.google.com with SMTP id 36so68063yxh.26
        for <linux-mm@kvack.org>; Wed, 05 Nov 2008 09:46:10 -0800 (PST)
Message-ID: <4911DCEF.80904@gmail.com>
Date: Wed, 05 Nov 2008 19:50:39 +0200
From: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>
MIME-Version: 1.0
Subject: Re: mmap: is default non-populating behavior stable?
References: <490F73CD.4010705@gmail.com> <1225752083.7803.1644.camel@twins> <490F8005.9020708@redhat.com> <491070B5.2060209@nortel.com> <1225814820.7803.1672.camel@twins> <20081104162820.644b1487@lxorguk.ukuu.org.uk> <49107D98.9080201@gmail.com> <Pine.LNX.4.64.0811051613400.21353@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0811051613400.21353@blonde.site>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1779C908F458D7278E2B3061"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Peter Zijlstra <peterz@infradead.org>, Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1779C908F458D7278E2B3061
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hugh Dickins wrote:
>> Thanks to all for answers. I have made the conclusion that doing "open=
() new
>> file, truncate(<big size>), mmap(<the same big size>), write/read some=
 memory
>> pages" should not populate other, untouched by write/read pages (until=

>> MAP_POPULATE given), right?
[snip]
> For a start, it depends on the filesystem: I believe that vfat, for
> example, does not support the concept of sparse files (files with holes=

> in), so its truncate(<big size>) will allocate the whole of that big
> size initially.
For my case vfat is not an option fortunately.

> I'm not sure what you mean by "populate": in mm, as in MAP_POPULATE,
> we're thinking of prefaulting pages into the user address space; but
> you're probably thinking of whether the blocks are allocated on disk?
Yes.

>>From time to time we toy with prefaulting adjacent pages when a fault
> occurs (though IIRC tests have proved disappointing in the past): we'd
> like to keep that option open, but it would go against your guidelines
> above to some extent.
It depends how is "adjacent" would count :) If several pages, probably no=
t. If
millions or similar, that would be a problem. It's very convenient to use=
 such
"open+truncate+mmap+write/read" behavior to make self-growing-on-demand c=
ache
in memory with disk as back-end without remaps.

Thanks for descriptive answer.

--=20
Eugene V. Lyubimkin aka JackYF


--------------enig1779C908F458D7278E2B3061
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkkR3PAACgkQchorMMFUmYz9cgCcDDqMGI69huraAJHBt+ssF2N7
UxYAn1JFAEi761G9t6NsfAreONhKoMis
=apcv
-----END PGP SIGNATURE-----

--------------enig1779C908F458D7278E2B3061--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
