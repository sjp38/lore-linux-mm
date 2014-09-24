Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id EBFED6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:10:49 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id o8so3591575qcw.6
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:10:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e14si16226408qaa.39.2014.09.24.08.10.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:10:49 -0700 (PDT)
Message-ID: <5422DEDE.1060004@redhat.com>
Date: Wed, 24 Sep 2014 17:10:22 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>	<1411344191-2842-5-git-send-email-minchan@kernel.org>	<20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>	<20140923045602.GC8325@bbox> <20140923141755.b7854bae484cfe434797be02@linux-foundation.org>
In-Reply-To: <20140923141755.b7854bae484cfe434797be02@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="EmHDdKerlwaUAa7w9h7n2fPu1bvmAkW9v"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EmHDdKerlwaUAa7w9h7n2fPu1bvmAkW9v
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/23/2014 11:17 PM, Andrew Morton wrote:
> On Tue, 23 Sep 2014 13:56:02 +0900 Minchan Kim <minchan@kernel.org> wro=
te:
>=20
>>>
>>>> +#define ZRAM_FULLNESS_PERCENT 80
>>>
>>> We've had problems in the past where 1% is just too large an incremen=
t
>>> for large systems.
>>
>> So, do you want fullness_bytes like dirty_bytes?
>=20
> Firstly I'd like you to think about whether we're ever likely to have
> similar granularity problems with this tunable.  If not then forget
> about it.
>=20
> If yes then we should do something.  I don't like the "bytes" thing
> much because it requires that the operator know the pool size
> beforehand, and any time that changes, the "bytes" needs hanging too.=20
> Ratios are nice but percent is too coarse.  Maybe kernel should start
> using "ppm" for ratios, parts per million.  hrm.

An other possibility is to use decimal fractions. AFAIK, lustre fs uses
them already for its procfs entries.

>=20
>>>> @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram,=
 bool reset_capacity)
>>>>  	down_write(&zram->init_lock);
>>>> =20
>>>>  	zram->limit_pages =3D 0;
>>>> +	atomic_set(&zram->alloc_fail, 0);
>>>> =20
>>>>  	if (!init_done(zram)) {
>>>>  		up_write(&zram->init_lock);
>>>> @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_d=
evice *bdev,
>>>>  	return 0;
>>>>  }
>>>> =20
>>>> +static int zram_full(struct block_device *bdev, void *arg)
>>>
>>> This could return a bool.  That implies that zram_swap_hint should
>>> return bool too, but as we haven't been told what the zram_swap_hint
>>> return value does, I'm a bit stumped.
>>
>> Hmm, currently, SWAP_FREE doesn't use return and SWAP_FULL uses return=

>> as bool so in the end, we can change it as bool but I want to remain i=
t
>> as int for the future. At least, we might use it as propagating error
>> in future. Instead, I will use *arg to return the result instead of
>> return val. But I'm not strong so if you want to remove return val,
>> I will do it. For clarifictaion, please tell me again if you want.
>=20
> I'm easy, as long as it makes sense, is understandable by people other
> than he-who-wrote-it and doesn't use argument names such as "arg".
>=20
>=20



--EmHDdKerlwaUAa7w9h7n2fPu1bvmAkW9v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUIt7eAAoJEHTzHJCtsuoCc1gH+QGCqyId6qZj+DM0/AunjLCs
ufVK4Prb7RPScj6TTYK1XA2BDuiy3Qdkcef6ZJzJp+qQHWOkcL6GTr+C+xNt3Zd+
V+EDc7pSd55l/Ej9NpxhbOBOX3opT4OkuOSjp8Y6zuvLKHaa2ffjMQcBruwuQySB
o4bQ1RE96OfeVXBeLXkzZCzmF8RHwIQnMNSAvhbxq7aONwD6CGPt++YkJXSPS9/k
ZYAPbKFnEpb8VqkpXE5BZ9dxUMXB9UZTuIfOXDDmtqLc9oXUozCjXK0habgoieBP
ldyKjnxS/l9QHFRjiy2SaQxNBKtjLAsdmLOWIjH8xjdHhbzOGFsoPYBcLfwbgT0=
=VF1L
-----END PGP SIGNATURE-----

--EmHDdKerlwaUAa7w9h7n2fPu1bvmAkW9v--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
