Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7523E6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 17:15:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n189so680690733pga.4
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 14:15:21 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id o71si28663127pfi.157.2016.12.30.14.15.19
        for <linux-mm@kvack.org>;
        Fri, 30 Dec 2016 14:15:20 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
In-Reply-To: <xa1ta8bd7uy7.fsf@mina86.com>
References: <20161229023131.506-1-eric@anholt.net> <20161229091256.GF29208@dhcp22.suse.cz> <87wpeitzld.fsf@eliezer.anholt.net> <xa1td1ga74v7.fsf@mina86.com> <8737h65nr5.fsf@eliezer.anholt.net> <xa1ta8bd7uy7.fsf@mina86.com>
Date: Fri, 30 Dec 2016 12:25:00 -0800
Message-ID: <87bmvtxizn.fsf@eliezer.anholt.net>
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
>> Michal Nazarewicz <mina86@mina86.com> writes:
>>
>>> On Thu, Dec 29 2016, Eric Anholt wrote:
>>>> Michal Hocko <mhocko@kernel.org> writes:
>>>>
>>>>> This has been already brought up
>>>>> http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz and th=
ere
>>>>> was a proposed patch for that which ratelimited the output
>>>>> http://lkml.kernel.org/r/20161130132848.GG18432@dhcp22.suse.cz resp.
>>>>> http://lkml.kernel.org/r/robbat2-20161130T195244-998539995Z@orbis-ter=
rarum.net
>>>>>
>>>>> then the email thread just died out because the issue turned out to b=
e a
>>>>> configuration issue. Michal indicated that the message might be useful
>>>>> so dropping it completely seems like a bad idea. I do agree that
>>>>> something has to be done about that though. Can we reconsider the
>>>>> ratelimit thing?
>>>>
>>>> I agree that the rate of the message has gone up during 4.9 -- it used
>>>> to be a few per second.
>>>
>>> Sounds like a regression which should be fixed.
>>>
>>> This is why I don=E2=80=99t think removing the message is a good idea. =
 If you
>>> suddenly see a lot of those messages, something changed for the worse.
>>> If you remove this message, you will never know.
>>>
>>>> However, if this is an expected path during normal operation,
>>>
>>> This depends on your definition of =E2=80=98expected=E2=80=99 and =E2=
=80=98normal=E2=80=99.
>>>
>>> In general, I would argue that the fact those ever happen is a bug
>>> somewhere in the kernel =E2=80=93 if memory is allocated as movable, it=
 should
>>> be movable damn it!
>>
>> I was taking "expected" from dae803e165a11bc88ca8dbc07a11077caf97bbcb --
>> if this is a actually a bug, how do we go about debugging it?
>
> That=E2=80=99s why I=E2=80=99ve pointed out that this depends on the defi=
nition.  In my
> opinion it=E2=80=99s a design bug which is now nearly impossible to fix in
> efficient way.

OK, so the design is bad.  When you said bug, I definitely thought you
were saying that the message shouldn't happen in the design.

Given CMA's current design, should everyone using CMA see their logs
slowly growing with this message that is an secret code for "CMA's
design hasn't yet changed"?  If you want to have people be able to track
how often this is happening, let's make a perf event for it or something
instead.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlhmwpwACgkQtdYpNtH8
nujh/xAArfUZW+F7uX/TMkYR+XCNon6ZYMObQe3HsNKYW6g5ij32hR0HSO7OnTNY
WKdVMeTx6XvNMx7xGYmCHg/EFGJWSnEPR1A34/on5M1hCeJQQhl/ZZ7gOaQv2NMA
igwr6X509/+WAY/wnKaBhDscnbGaBBXwcrS6E2fJdpmDBAOUD6Lf/js3ucqf5FVV
uU9TQSH+KQaACLIvsEoMFSjAD+Q4UpDKFTQsYHOTspP3tX/+s2FsB2NU6QUfk511
lVxx1ltN8hI1yYkEFkMQGm4PJfHTo1N5ikdWnorGjd4pQnRn2DGJWOpv1i0WrsGZ
53Wv9ehPrHBWLrWmw8sH8YK/sypDpvANQhJaQr96/OOKjLHHrBZOhhJBWebcnyh9
B4uxD3Gwby54wWK6krLUlddfV2uPn9b3KKQn9gw/PeWi0GByMcYkw+H6ctsw2Nu0
HJpVpTOpMZjFQ7tDxNBrh9qJuQa2XQRgndYgkgoF6RoPCCBbhO0sntzSxLAd8MWa
Xv0TUgY+mtC92sdtshocyHWZYbm5rgJFQ+vVqKXU5rIi213tkaD//XwvCVclR7JF
egW2WQQ8sLKUmmOzgnyZ9A4lzjrJ8MtCkKx3ydLa+XeC2wDK3231xjjq1PWL28JB
g8IRTpcSyo4lZ+E9ewyexA3UHwfZeWn5INP2RDgyElIKJF9PJLM=
=+U63
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
