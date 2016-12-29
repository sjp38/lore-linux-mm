Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565E46B0038
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 18:17:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so603812479pfb.6
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 15:17:27 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id z5si52062742pgn.297.2016.12.29.15.17.26
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 15:17:26 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <xa1td1ga74v7.fsf@mina86.com>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net> <xa1td1ga74v7.fsf@mina86.com>
Date: Thu, 29 Dec 2016 15:17:18 -0800
Message-ID: <8737h65nr5.fsf@eliezer.anholt.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-stable <stable@vger.kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>, Vlastimil Babka <vbabka@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Michal Nazarewicz <mina86@mina86.com> writes:

> On Thu, Dec 29 2016, Eric Anholt wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>>
>>> This has been already brought up
>>> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and there
>>> was a proposed patch for that which ratelimited the output
>>> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
>>> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-terra=
rum.net
>>>
>>> then the email thread just died out because the issue turned out to be a
>>> configuration issue. Michal indicated that the message might be useful
>>> so dropping it completely seems like a bad idea. I do agree that
>>> something has to be done about that though. Can we reconsider the
>>> ratelimit thing?
>>
>> I agree that the rate of the message has gone up during 4.9 -- it used
>> to be a few per second.
>
> Sounds like a regression which should be fixed.
>
> This is why I don=E2=80=99t think removing the message is a good idea.  I=
f you
> suddenly see a lot of those messages, something changed for the worse.
> If you remove this message, you will never know.
>
>> However, if this is an expected path during normal operation,
>
> This depends on your definition of =E2=80=98expected=E2=80=99 and =E2=80=
=98normal=E2=80=99.
>
> In general, I would argue that the fact those ever happen is a bug
> somewhere in the kernel =E2=80=93 if memory is allocated as movable, it s=
hould
> be movable damn it!

I was taking "expected" from dae803e165a11bc88ca8dbc07a11077caf97bbcb --
if this is a actually a bug, how do we go about debugging it?

I've had Raspbian carrying a patch downstream to remove the error
message for 2 years now, and I either need to get this fixed or get this
patch merged to Fedora and Debian as well, now that they're shipping
some support for Raspberry Pi.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlhlmX4ACgkQtdYpNtH8
nujYAQ//Uz1sXRG4z6A5yxnSxFL+ZHZa2txfHU2J6RifCjBIve+7MdAeE8tIT0Re
JWAIymb7N8UwInnXQiqg6URyQTknIU5k7MOy3m4027ViL5B6224wl3rSQeNSt5kU
CMxxGirja/QWJsjpAqFaFkChouF9VlC0NUizG5C3xKF4yd7rfby5kd+mACtUwtYY
iqVheV/hR2/2Td1fpjCLIAwj1ht+0dp07A22g3zossOomzUWrcianHWgGAauEstf
epfoAWXbGV0hnyfFUi0C+bOycBLxlKEqeqqZlwDQ/3AfeidERKozhCveKR0y68Zj
AOomCly0rx3ypen3VZhqi/LczwpN2aOBNiLY4vNW3ER+/h2acfl8YssijNPgHYyJ
jWznhp+C9nY52+sAr1kIo1yL0bJrfCkY9haEcUvA9RNpU0VGD/zjyWPmbZHEg+KY
ONyYB5hdnbjRsKkFmnS63tmun+dA9ud94fEoyJdx8xSB0Cs9voxhTBa70bKzwSAL
Y/Vhzj6Zu+UftV0Oj5i/NJqzF3ztrp/DRAHqzJ9rwueHDDENCYzINYtviC9oNfmj
ZdinQ7ZavTC3t5eQHAfChjiNEN6pZQKxNgZeGW3zLWxaNUu8n9XoHoPal6ZsW2uy
I/bm4CNfJWZQ36wOZPz0RFVgAzKVp0/s3N0GyGbfJ3dnU1AC9xY=
=2Gix
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
