Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B50836B02F3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 23:07:46 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s23so41726609pgo.15
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:07:46 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id u20si3821902pfg.24.2017.06.05.20.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 20:07:46 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v18so8372449pgb.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:07:46 -0700 (PDT)
Date: Tue, 6 Jun 2017 11:07:43 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Trivial typo fix.
Message-ID: <20170606030743.GC2259@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170605014350.1973-1-richard.weiyang@gmail.com>
 <20170605062248.GC9248@dhcp22.suse.cz>
 <20170605152905.3bf55d05ecdb91224b460197@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="+nBD6E3TurpgldQp"
Content-Disposition: inline
In-Reply-To: <20170605152905.3bf55d05ecdb91224b460197@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, linux-mm@kvack.org


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 05, 2017 at 03:29:05PM -0700, Andrew Morton wrote:
>On Mon, 5 Jun 2017 08:22:48 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>
>> On Mon 05-06-17 09:43:50, Wei Yang wrote:
>> > Looks there is no word "blamo", and it should be "blame".
>> >=20
>> > This patch just fix the typo.
>>=20
>> Well, I do not think this is a typo. blamo has a slang meaning which I
>> believe was intentional.
>
>It should be "blammo".
>
>> Besides that, why would you want to fix this
>> anyway. Is this something that you would grep for?
>
>Yup.  I wouldn't object to an incidental fix if someone was altering
>something else nearby or as part of a file-wide "clean up comments"
>patch, but it doesn't seem worth an entire commit.

Sure, maybe I can keep this when I have other related patches. :-)

--=20
Wei Yang
Help you, Help me

--+nBD6E3TurpgldQp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZNhx/AAoJEKcLNpZP5cTdUV8QAKjwsx0Sy5RHfNz8JsyLvA4y
UpfBSgCrjY5cS/FuzwTuMTDKqynEOOqZUt2RVRF9PAvtTGrZywFsnFyDgq5XArpr
gnIgMLr6yYWkItsx3T6E4I0xDPkXXCcOiFrDJEM9ptUDPbzznUzg838hiBlzbjn2
3jIPye4HA49ARqjIQJcYnsQtDB7jko25oS+GzgUM5DG96PnsXegACvc1PiHz7lrw
eFF+YJjjrHqyGqdfkHRZ5u8vLFO4SbxJHw83Lnv7mwSGgDVgKAusEXF4Bh0/g+tS
ZiKyj4gY9Adtq5sE8UfcZAerSg8CfLUHqtDRe0ctqBdkfwCA1i2GYD4HBDtO1C0C
aAzyn7tLZgaWziIXD+SCugVOoZQ59kA9W8hxy/thzLiig0Nu+95keNiXtbHJflB8
+3fr1iHHhgI4wPU6DmN6I7L0sQx8uwikg5ZIDP2Qy9PbxuYNfYJoqCWhiJ+Um2qF
oU/ZorbNUQDVMnTETpB47qfSDivOl56gYeZqFntYjL+nbE+yYvzZaAMuZMPaDNea
ALq0wQ+Sx7EfINfOj9CK6BjGB+90CBDV6r3CRPpeAQ7NYb0M0i2tcCPd6QvjqLbS
+44EihicF8LSNmsoaeOHKMxhEhh6fD243OY0R6shHUc3j9VS4eg2ROhzDqKEMa/B
Vaiit6vmj8bZf5N+ex3b
=b2jw
-----END PGP SIGNATURE-----

--+nBD6E3TurpgldQp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
