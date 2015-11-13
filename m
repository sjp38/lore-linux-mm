Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id B5F496B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:13:22 -0500 (EST)
Received: by ioc74 with SMTP id 74so90550082ioc.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 00:13:22 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id k4si3881992igt.5.2015.11.13.00.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 00:13:22 -0800 (PST)
Received: by igcph11 with SMTP id ph11so10972875igc.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 00:13:22 -0800 (PST)
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com> <20151113061511.GB5235@bbox>
 <56458056.8020105@gmail.com> <20151113063802.GF5235@bbox>
 <56458720.4010400@gmail.com> <20151113070356.GG5235@bbox>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <56459B9A.7080501@gmail.com>
Date: Fri, 13 Nov 2015 03:13:14 -0500
MIME-Version: 1.0
In-Reply-To: <20151113070356.GG5235@bbox>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ecsUtC3W8kFJ8SxDviaGGgFSqHrMGNiT1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ecsUtC3W8kFJ8SxDviaGGgFSqHrMGNiT1
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 13/11/15 02:03 AM, Minchan Kim wrote:
> On Fri, Nov 13, 2015 at 01:45:52AM -0500, Daniel Micay wrote:
>>> And now I am thinking if we use access bit, we could implment MADV_FR=
EE_UNDO
>>> easily when we need it. Maybe, that's what you want. Right?
>>
>> Yes, but why the access bit instead of the dirty bit for that? It coul=
d
>> always be made more strict (i.e. access bit) in the future, while goin=
g
>> the other way won't be possible. So I think the dirty bit is really th=
e
>> more conservative choice since if it turns out to be a mistake it can =
be
>> fixed without a backwards incompatible change.
>=20
> Absolutely true. That's why I insist on dirty bit until now although
> I didn't tell the reason. But I thought you wanted to change for using
> access bit for the future, too. It seems MADV_FREE start to bloat
> over and over again before knowing real problems and usecases.
> It's almost same situation with volatile ranges so I really want to
> stop at proper point which maintainer should decide, I hope.
> Without it, we will make the feature a lot heavy by just brain storming=

> and then causes lots of churn in MM code without real bebenfit
> It would be very painful for us.

Well, I don't think you need more than a good API and an implementation
with no known bugs, kernel security concerns or backwards compatibility
issues. Configuration and API extensions are something for later (i.e.
land a baseline, then submit stuff like sysctl tunables). Just my take
on it though...


--ecsUtC3W8kFJ8SxDviaGGgFSqHrMGNiT1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWRZuaAAoJEPnnEuWa9fIqlKwP/RMTaGkNLQ9TdIGkFDZTbPG5
zOLwhzEg751X4CA+4b25bVAKoVq39rhLrnQD2BDyPbptDKXPCQ0f8Z++0lnk5qZg
tybT+TJLs9SK3CA9pCHQjWtc9Dy1ekqTYkrNY0P4rcCPbxVDYaqKSwnf+O+7SZss
w6jnMjLEu23zjQamBcU5dwTrvmQRXwX4Gw0jCKcRzmhECOZvKfstBEnfIDBc9glJ
vytE/lXER5B3rTnp5k7NSrgE9EfNv/TTXrtbYVVAUatEhq0MBtHQ8LQdmTSgU3EA
3vk1/pXDvMa1atOw7eQdgkmDcD/dxhHFT5jsEfAV452JdVdpnRsPQYTU62rqXru+
Tnl6sej264zgSQMEWTLPbUvpPC6y9CFRIqYHLjNF5Uni8c08R7dtWaf+39r2cPXA
j4gISD6Y7KxhXdewbmVnDPJEBsnM7C9AKgcs3qrOlBK824p0VqhJNF2xaryBzrF2
xfOrsg5rJuS9nJRBx254WiUa1atHhgUx8kyNx3pZLKBrsVe1pL3MbZMED73j8bv7
cyfOzYcElo3OknSsMRkkLERGD9lC+OOEADfbQGKt7NgZlf2Uxv6HR2GIOaWG9i/P
T6Hk884xMmKQLl59+6s699XcYpMYJ4Tt5IdZLxghmZvBTb2/IpOn0IZI0At6dlzd
hoR8O/tiXi4hxoMMW4x4
=31Tg
-----END PGP SIGNATURE-----

--ecsUtC3W8kFJ8SxDviaGGgFSqHrMGNiT1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
