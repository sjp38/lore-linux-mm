Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E03006B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 21:45:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a72so103609508pge.10
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 18:45:00 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id o5si2667894pgk.339.2017.04.08.18.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 18:45:00 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id n11so5026099pfg.2
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 18:44:59 -0700 (PDT)
Date: Sun, 9 Apr 2017 09:44:57 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] calc_memmap_size() isn't accurate and one suggestion to
 improve
Message-ID: <20170409014457.GA24681@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170328011137.GA8655@WeideMacBook-Pro.local>
 <20170403091818.GI24661@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <20170403091818.GI24661@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mgorman@techsingularity.net, jiang.liu@linux.intel.com, akpm@linux-foundation.org, tj@kernel.org, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 03, 2017 at 11:18:19AM +0200, Michal Hocko wrote:
>On Tue 28-03-17 09:11:37, Wei Yang wrote:
>> Hi, masters,
>>=20
>> # What I found
>>=20
>> I found the function calc_memmap_size() may not be that accurate to get =
the
>> pages for memmap.
>>=20
>> The reason is:
>>=20
>> > memmap is allocated on a node base,
>> > while the calculation is on a zone base
>>=20
>> This applies both to SPARSEMEM and FLATMEM.
>>=20
>> For example, on my laptop with 6G memory, all the memmap space is alloca=
ted
>> from ZONE_NORMAL.
>
>Please try to be more specific. Why is this a problem? Are you trying to
>fix some bad behavior or you want to make it more optimal?
>
>I am sorry I didn't look closer into your proposal but I am quite busy
>and other people are probably in a similar situation. If you want to get
>a proper feedback please try to state the problem and be explicit if it
>is user observable.

Michal

Glad to hear from you.

Sure, let me do more investigation on this and try some experiment to see
whether this change is observable.

Have a nice day~

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY6ZIZAAoJEKcLNpZP5cTd+IQP+wWiO+ewscdHWxBJkLaoaL7w
NWym36GE1vARSpDgTUU9k6WcTWVFz0XnNDB5h3jSPmbD25R8vQao1MEt3eWxbiUB
jRQevU6S/l5ng+aJvjjSyuRNSFzJr/iDWZpjJaLemVNDhFlNNFcVgS5ilVNOxtfr
OgT4qB0olfoHwQMjq+4xSxDgpzWTeA8TAQPlKjvQLrYEBUu9yAJ3ZwqYks70a0Th
27/gWGso+O5MJ2xSPjl0sbpGWy3UDPf/zr1xHqmiMxU8WJtAXP1IYr98KCKZ+PQA
SDudRvRa5CHZmIKM2dY4TAeg30lgO+aqKtXWpD9S8L+UiL6wSbgDuB0UcqVPg49e
uQy4fqDoZasHjOhZ41QtOwOgNlMDGyL9Fo2kMX5Jn42hawdxsL8/LWt3ZQ7yLsSN
Yz5luQ7zyT6gM8vItdgWH7qc9j4cazZjLnujiegD2c42GI3gkl/RQd+2kJl9CXwU
uTJHPIBwKV89ow38PtfiGgmPnb7x+RNw79saQRfMGBxs6Jyz4CMAWFfb8X5tBl+V
hlZBM4Su4G6SQ9/emEfgHA5hp0rSOMf6nCfVtHH9/38za6ev6g4jPmMyxLeQIZ2R
kyiziwvXF9DuhcJmlugkrQdY+2xauzuMTGYhg+VOqwvu/oLWE8RYONbhREB63vzY
wEfttHQB1hazhK1TpeNw
=b96m
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
