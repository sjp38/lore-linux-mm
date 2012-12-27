Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id DAD4A6B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 21:05:58 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id ds1so3543785wgb.2
        for <linux-mm@kvack.org>; Wed, 26 Dec 2012 18:05:57 -0800 (PST)
From: Michal Nazarewicz <mpn@google.com>
Subject: Re: [PATCH] cma: use unsigned type for count argument
In-Reply-To: <alpine.DEB.2.00.1212261755450.4150@chino.kir.corp.google.com>
References: <52fd3c7b677ff01f1cd6d54e38a567b463ec1294.1355938871.git.mina86@mina86.com> <20121220153525.97841100.akpm@linux-foundation.org> <alpine.DEB.2.00.1212201557270.13223@chino.kir.corp.google.com> <xa1tip7u14tq.fsf@mina86.com> <alpine.DEB.2.00.1212261755450.4150@chino.kir.corp.google.com>
Date: Thu, 27 Dec 2012 03:05:49 +0100
Message-ID: <xa1tzk10ntaa.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> On Sat, 22 Dec 2012, Michal Nazarewicz wrote:
>> So I think just adding the following, should be sufficient to make
>> everyone happy:
>>=20
>> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous=
.c
>> index e34e3e0..e91743b 100644
>> --- a/drivers/base/dma-contiguous.c
>> +++ b/drivers/base/dma-contiguous.c
>> @@ -320,7 +320,7 @@ struct page *dma_alloc_from_contiguous(struct device=
 *dev, unsigned int count,
>>  	pr_debug("%s(cma %p, count %u, align %u)\n", __func__, (void *)cma,
>>  		 count, align);
>>=20=20
>> -	if (!count)
>> +	if (!count || count > INT_MAX)
>>  		return NULL;
>>=20=20
>>  	mask =3D (1 << align) - 1;
>
On Thu, Dec 27 2012, David Rientjes <rientjes@google.com> wrote:
> How is this different than leaving the formal to have a signed type, i.e.=
=20
> drop your patch, and testing for count <=3D 0 instead?

Not much different I guess.  I don't have strong opinions to be honest,
except that I feel unsigned is the proper type to use, on top of which
I think bitmap_set() should use unsigned, so in case anyone ever bothers
to change it, CMA will be ready. :P

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ26z9AAoJECBgQBJQdR/0FLsP+wXrMoNqTvrzcm44rlE94pb9
J4dpiQH2rSHTWsR3xfdwmoupgrL2WnLb5PRz6tfvf69bdWRhlkmz5OTR1sld95Mi
pB/bwmhdaSknDx8qufJCoaqTAlMD328RBktU8vvpSxZwQZJbqA2sod2lHT4La+aT
38mGGfIWhOHEKNZlgqm91DLOkwptHn0NPCs4udfEMC3lWiTfpp78KOeFM7OPeb4W
GiiunyocX/Y2oez09X63JvFBVFopx0l3rtKbAKAiKW/QRnfgEsshDg/t4rWKnILY
3l+EZBTBsuYaWSaPcgtWZtu04fkOqVF6Dq8lrqw+HjfIvmh8x9X+M7srIwxhR773
rIENo0XVC6dbov0qvuMd9VlnMhQl1vf9n5UIFGTSnjIpY6rn8puOoXNHCUj8YahN
ZMrQxzK7pdJ+yroW/3iaqDjgOyqdNE9sbJ34dM5bGW64cuTxsr5o8iiPD6Vj1oa1
ShY0Xx8V2+J2LQGRHUGIywXu2E499JbIQv/LLDPKm0SWLdANRrGn6TfcD0644Qp2
PM/2cff5xC7PfOxpLipeagJ/RuZRmxZsGcu2gfgXG4wUZJ2ej43qSBmqQQ1Q5hjv
aXdqvgM5q0cHT/yjO2Oe0IwTjl4V1RTQJgrsGIzak3GnjVZaVYbcGcKmDU/gLVSK
3TRe56LEL6ILhJPJnxh2
=gJWR
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
