Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 843E16B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:07:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so152941886pfw.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:07:12 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id d20si4287034plj.252.2017.02.07.07.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 07:07:11 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 204so12356887pge.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:07:11 -0800 (PST)
Date: Tue, 7 Feb 2017 23:07:08 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170207150708.GA31837@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170206152932.19e7947df487b96b8912e524@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <20170206152932.19e7947df487b96b8912e524@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 06, 2017 at 03:29:32PM -0800, Andrew Morton wrote:
>On Mon,  6 Feb 2017 23:43:14 +0800 Wei Yang <richard.weiyang@gmail.com> wr=
ote:
>
>> The whole memory space is divided into several zones and nodes may have =
no
>> page in some zones. In this case, the __absent_pages_in_range() would
>> return 0, since the range it is searching for is an empty range.
>>=20
>> Also this happens more often to those nodes with higher memory range when
>> there are more nodes, which is a trend for future architectures.
>>=20
>> This patch checks the zone range after clamp and adjustment, return 0 if
>> the range is an empty range.
>
>What are the user-visible runtime effects of this change?

Hmm, for users they may not "see" the effect, while it will save some time =
in
case there is no overlap between the zone and node.

--=20
Wei Yang
Help you, Help me

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYmeKcAAoJEKcLNpZP5cTdlecP/jig142NOblvsOOeW1QhjmuY
vajC3YHaGc1Vyj+otaaYliiPuFHzk1Sh7Tts/RZ08Qnzw5FfT47aAnxuowMt3sLD
r5TxYvEWSJOJTMO0MrlupTwe1nHpLALXOGYm6kHNdvkoX/vyK89ATjLCzVplkCiQ
p/jSvwdtkO9He1vCJjBJv+YgUxUeWtr+7EcI5HnM7oyc+EPpquczta0drLS5VLAA
H8bSJamP9QDqShpVME8U6hTplL8RfgRM/CpAp7ZTImvVIfv2TzpqNM/m8cHY5XQI
tsF2CMuZgLS8Tr0nXw0MC7il9djbDKAlmT9EDo0zU4XR8dhINiDzrFXR4eja8rlo
jFi6Ac8ow3jmH+Oz1x8j1Tc1bZEBNg2y/17B+rD+lXyA+bPdbson68bgi7VntBMB
Ro9rKgLoyOShT44QkJsZbtgq7ea8h1pzp3MYF1KgeRG600DaHE6wZFL+FJXxC4Wv
d8zAImwoMUhMY//EQD6DfuDmTPJrKvB4s4VeiiA6y1U/8LYPWS1/V0MH/mMrUPpk
LiZGe3MvUFGoUNQttAAyE6pfDNf1vJWZVBU+ltHg3JizR0/u+5vZiuK7paSu7B+e
5Jx2JS7YCi/uRUdaJVTLV1wfQ9xqxDZxUZ3l6GJAoDsgtpdym4pdF+biFcia+/AJ
tHTw7tbBT3nFKy88EDkk
=j7et
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
