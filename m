Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFDC6B038A
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 12:05:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x125so73756988pgb.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:05:05 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id x21si4787407pfa.103.2017.03.19.09.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 09:05:04 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id g2so16317055pge.2
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 09:05:04 -0700 (PDT)
Date: Mon, 20 Mar 2017 00:05:01 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use BITS_PER_LONG to unify the definition in
 page->flags
Message-ID: <20170319160501.GB1187@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170318003914.24839-1-richard.weiyang@gmail.com>
 <20170319143012.GB12414@dhcp22.suse.cz>
 <20170319150345.GA34657@WeideMacBook-Pro.local>
 <20170319150822.GC12414@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="bCsyhTFzCvuiizWE"
Content-Disposition: inline
In-Reply-To: <20170319150822.GC12414@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 19, 2017 at 11:08:22AM -0400, Michal Hocko wrote:
>On Sun 19-03-17 23:03:45, Wei Yang wrote:
>> On Sun, Mar 19, 2017 at 10:30:13AM -0400, Michal Hocko wrote:
>> >On Sat 18-03-17 08:39:14, Wei Yang wrote:
>> >> The field page->flags is defined as unsigned long and is divided into
>> >> several parts to store different information of the page, like sectio=
n,
>> >> node, zone. Which means all parts must sit in the one "unsigned
>> >> long".
>> >>=20
>> >> BITS_PER_LONG is used in several places to ensure this applies.
>> >>=20
>> >>     #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_P=
AGEFLAGS
>> >>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <=3D BITS_PER_LONG - N=
R_PAGEFLAGS
>> >>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <=3D=
 BITS_PER_LONG - NR_PAGEFLAGS
>> >>=20
>> >> While we use "sizeof(unsigned long) * 8" in the definition of
>> >> SECTIONS_PGOFF
>> >>=20
>> >>     #define SECTIONS_PGOFF         ((sizeof(unsigned long)*8) - SECTI=
ONS_WIDTH)
>> >>=20
>> >> This may not be that obvious for audience to catch the point.
>> >>=20
>> >> This patch replaces the "sizeof(unsigned long) * 8" with BITS_PER_LON=
G to
>> >> make all this consistent.
>> >
>> >I am not really sure this is an improvement. page::flags is unsigned
>> >long nad the current code reflects that type.
>> >
>>=20
>> Hi, Michal
>>=20
>> Glad to hear from you.
>>=20
>> I think the purpose of definition BITS_PER_LONG is more easily to let au=
dience
>> know it is the number of bits of type long. If it has no improvement, we=
 don't
>> need to define a specific macro .
>>=20
>> And as you could see, several related macros use BITS_PER_LONG in their
>> definition. After this change, all of them will have a consistent defini=
tion.
>>=20
>> After this change, code looks more neat :-)
>>=20
>> So it looks more reasonable to use this.
>
>I do not think that this is sufficient to justify the change.
>

Fine~ Thanks for comments~

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--bCsyhTFzCvuiizWE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIbBAEBCAAGBQJYzqwtAAoJEKcLNpZP5cTdphwP9juG3BaAYBNgXUHSNQuUA6KL
LgvM9Nn5I9OeB5VM8RjS3u+DsLmo7GwY7U54qDrQFHB3ek2/4mYF35hNbpO/gDS9
n8RRYytWDvlSKxzcjeRVKIrBOwVPlKtBhy2rxTsIOr9vchBSwdxvu6PkC0Y9TIiy
PZOQrAuEgkqkHpLOedvsMdfsZimJgj4Pstgs0rRhKNDGQs5q5eIQlVzCMhZZE1Km
GluKeCAxNlhWxKSODhH91IBD1Jk8mefhFrVtK+KzAoEM/hz6yjiknY+mwJnterJ/
vnQYlra8LLqjaQG+/nEJ1iCG2rurUYP+uoxVnH0gee1mbHHiQuRblSxnXbabX2JQ
yXaYt+tqpbVkDqHZZbgzGdmoipYjkO2ffiIYG5kLgtV0iNapV9waNt+05l+oUeKY
yBW7dfJPmhqpNbUZ2OUhhw01gMkcOacGlmLJf3q4TCMpOuMJji+J64HNoaFraNBA
rFrzB3tQArAcOgT+BUgJqxebk93T7ajAH481JS81qSSqiEqXOuLiPUzZz2eLY0Pn
9YZ+tGuSciElI/cHykCLBtAjwn6GWGewjhcjCjd5cv9BAxKPj+vCYjpXlxMxWbio
E2spDvrR6HQkj+RpMESmYNBH6aH1DiDFWaq4QrgAlbfmjNPSctLJb1+Qdc279m9e
J0msXEDGvYyHl5lQstM=
=C5Ko
-----END PGP SIGNATURE-----

--bCsyhTFzCvuiizWE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
