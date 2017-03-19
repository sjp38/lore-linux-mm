Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1399E6B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 11:03:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x125so71405623pgb.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 08:03:49 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id w24si5058177pgc.301.2017.03.19.08.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 08:03:48 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id b5so16246931pgg.1
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 08:03:48 -0700 (PDT)
Date: Sun, 19 Mar 2017 23:03:45 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use BITS_PER_LONG to unify the definition in
 page->flags
Message-ID: <20170319150345.GA34657@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170318003914.24839-1-richard.weiyang@gmail.com>
 <20170319143012.GB12414@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
In-Reply-To: <20170319143012.GB12414@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 19, 2017 at 10:30:13AM -0400, Michal Hocko wrote:
>On Sat 18-03-17 08:39:14, Wei Yang wrote:
>> The field page->flags is defined as unsigned long and is divided into
>> several parts to store different information of the page, like section,
>> node, zone. Which means all parts must sit in the one "unsigned
>> long".
>>=20
>> BITS_PER_LONG is used in several places to ensure this applies.
>>=20
>>     #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGE=
FLAGS
>>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <=3D BITS_PER_LONG - NR_P=
AGEFLAGS
>>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <=3D BI=
TS_PER_LONG - NR_PAGEFLAGS
>>=20
>> While we use "sizeof(unsigned long) * 8" in the definition of
>> SECTIONS_PGOFF
>>=20
>>     #define SECTIONS_PGOFF         ((sizeof(unsigned long)*8) - SECTIONS=
_WIDTH)
>>=20
>> This may not be that obvious for audience to catch the point.
>>=20
>> This patch replaces the "sizeof(unsigned long) * 8" with BITS_PER_LONG to
>> make all this consistent.
>
>I am not really sure this is an improvement. page::flags is unsigned
>long nad the current code reflects that type.
>

Hi, Michal

Glad to hear from you.

I think the purpose of definition BITS_PER_LONG is more easily to let audie=
nce
know it is the number of bits of type long. If it has no improvement, we do=
n't
need to define a specific macro .

And as you could see, several related macros use BITS_PER_LONG in their
definition. After this change, all of them will have a consistent definitio=
n.

After this change, code looks more neat :-)

So it looks more reasonable to use this.

--=20
Wei Yang
Help you, Help me

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYzp3RAAoJEKcLNpZP5cTdxbYP/RpUbx65gjcOMCdXuvTtxh8O
IXG/61Xeeiez8KkagRQ5Wo4kQxTTf2UNjJ5utFnC98GBCzFRXZe6P8/t1T+JcbYG
ULcl0UoSsoz+Xxhj9RGAnRMPg1Gz6ZosboDRysDwkZAti3fIX+yR9nOJZxlxZG3M
EP3cIRF4mGWc9otfYG15Kb5PIpE88HSlFc+mUC9sqAeMPCE714+bKooZeKh7YamG
EdjCUcxRevEcUq7qbFQjEx8CDszkGNTrEp8O6KYvF+cF1um3FprGH+AxXuD6tGer
Ej/R7udlzZKIUgD+Xrx/jIc8XVPBV4qXa++H91wzFrwiDe8CnXfLiW57iNZCAzif
XPKtl8pObY3FU/+pXh5TeMnKboQKy4sqOCszYqqKN+vfS/z7/Jw4RgGg+3/Fha1w
nRu48eWKn+lEhBCi+MDi+pyqOYnwmMtbCV9hPXwsy4+1afCr7eH2puj+XeSK6XbS
DSCAjZnDEU5rxL+YbHsW6hjD7WdxDHYVNIee73W1D5cdmBst5iCiSPjjrbs3nlUl
cS0YnHgIxEW6Efjo3LapRz3knJyJAMaGCsXPCoxc6TLqwUFMR4wBdcy4cgASEEjB
wWg5rFamHrmpP1YVAs56lYWDYj22D0nvJ4+ZLZuh0oYna3jt3XxeJ4vxn3Xv4KN+
8UxBP9JM+uBMUtqrhvMw
=TLID
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
