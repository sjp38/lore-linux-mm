Received: from 218-101-109-95.dialup.clear.net.nz
 (218-101-109-95.dialup.clear.net.nz [218.101.109.95])
 by smtp2.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HRY00G0XUI7WY@smtp2.clear.net.nz> for linux-mm@kvack.org; Sat,
 24 Jan 2004 12:27:45 +1300 (NZDT)
Date: Sat, 24 Jan 2004 12:30:29 +1300
From: Nigel Cunningham <ncunningham@users.sourceforge.net>
Subject: Re: Can a page be HighMem without having the HighMem flag set?
In-reply-to: <1074828647.12774.212.camel@laptop-linux>
Reply-to: ncunningham@users.sourceforge.net
Message-id: <1074900629.2024.44.camel@laptop-linux>
MIME-version: 1.0
Content-type: multipart/signed; boundary="=-4VKfnMSQv2iyorJObNVr";
 protocol="application/pgp-signature"; micalg=pgp-sha1
References: <1074824487.12774.185.camel@laptop-linux>
 <20040123022617.GY1016@holomorphy.com>
 <1074828647.12774.212.camel@laptop-linux>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-4VKfnMSQv2iyorJObNVr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi all.

At boot I get:

<4> BIOS-e820: 0000000000000000 - 000000000009e000 (usable)
<4> BIOS-e820: 000000000009e000 - 00000000000a0000 (reserved)
<4> BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
<4> BIOS-e820: 0000000000100000 - 00000000efff6500 (usable)
<4> BIOS-e820: 00000000efff6500 - 00000000f0000000 (ACPI data)
<4> BIOS-e820: 00000000fffb0000 - 0000000100000000 (reserved)
<4> BIOS-e820: 0000000100000000 - 0000000400000000 (usable)

It's the pages efff6000- which are causing me grief. if I understand
things correctly, page_is_ram is returning 0 for those pages, and as a
result they get marked reserved and not HighMem by one_highpage_init.

I suppose, then, that I need to check for and ignore pages >
highstart_pfn where PageHighMem is not set/Reserved is set. (Either
okay?).

Regards,

Nigel
--=20
My work on Software Suspend is graciously brought to you by
LinuxFund.org.

--=-4VKfnMSQv2iyorJObNVr
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAEa6VVfpQGcyBBWkRAq8NAJ45nDbYvq/9p7pxcEq8FCRSGdtrPgCfegp8
U88h8bA2bdiBpFNxMA3YK+Y=
=R222
-----END PGP SIGNATURE-----

--=-4VKfnMSQv2iyorJObNVr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
