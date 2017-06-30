Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32DED2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 07:43:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c18so51483349qkb.10
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:43:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j65si1812362qkf.286.2017.06.30.04.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 04:43:10 -0700 (PDT)
Subject: Re: [PATCH] mm/zsmalloc: simplify zs_max_alloc_size handling
References: <20170628081420.26898-1-jmarchan@redhat.com>
 <20170630012436.GA24520@bbox>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <ef7e596a-84c2-3eaf-0702-d7e5de7dd957@redhat.com>
Date: Fri, 30 Jun 2017 13:43:02 +0200
MIME-Version: 1.0
In-Reply-To: <20170630012436.GA24520@bbox>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6AmdaNKWH3dSHuaCANCd9pS7ER1IsnF6B"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6AmdaNKWH3dSHuaCANCd9pS7ER1IsnF6B
Content-Type: multipart/mixed; boundary="8SJO4hWcIW9AbbMLqdxjMcHGjFkkkBrNn";
 protected-headers="v1"
From: Jerome Marchand <jmarchan@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Message-ID: <ef7e596a-84c2-3eaf-0702-d7e5de7dd957@redhat.com>
Subject: Re: [PATCH] mm/zsmalloc: simplify zs_max_alloc_size handling
References: <20170628081420.26898-1-jmarchan@redhat.com>
 <20170630012436.GA24520@bbox>
In-Reply-To: <20170630012436.GA24520@bbox>

--8SJO4hWcIW9AbbMLqdxjMcHGjFkkkBrNn
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 06/30/2017 03:24 AM, Minchan Kim wrote:
>> @@ -137,6 +142,8 @@
>>   *  (reason above)
>>   */
>>  #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
>> +#define ZS_SIZE_CLASSES	DIV_ROUND_UP(ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC=
_SIZE, \
>> +				     ZS_SIZE_CLASS_DELTA)
>=20
> #define ZS_SIZE_CLASSES	(DIV_ROUND_UP(ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_=
SIZE, \
> 				     ZS_SIZE_CLASS_DELTA) + 1)
>=20
>=20
> I think it should add +1 to cover ZS_MIN_ALLOC_SIZE.

Yes, obviously. Sorry about that.

> Otherwise, looks good to me.
>=20
> Thanks.
>=20



--8SJO4hWcIW9AbbMLqdxjMcHGjFkkkBrNn--

--6AmdaNKWH3dSHuaCANCd9pS7ER1IsnF6B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJZVjlGAAoJEHTzHJCtsuoCkXIH/0ZHgdvBG5DIx/+re7i5hl3w
+Z3H9tfLpmKgoQB1RuVHd1PTEF36B6viXqNV0fQdIYVpciV4WJWW53lO7mQy10DO
3XqJHGjbjSp37lnfcUv3XbanT2TqKi4QZjSW1QIYIHl7sVzsG/hSjgI5cRTKNHcx
W17iRqv3dUIjIwBMtubLIZeSOw14P4U6EHXVZLEt4HGhuxgKW++6HfWRBbS1eOPP
lQRwppD48MoD/SPD2jQBQXqiqkUCJbj40NwOflbkRCnJq3RItuxjew85dWO3KkgT
8fjS3JDC8iCF2B3j4/NFIiVAR1ssVs/P6KUltqqjPcVz3qlSI2I4MeakCXsQu/g=
=sQOR
-----END PGP SIGNATURE-----

--6AmdaNKWH3dSHuaCANCd9pS7ER1IsnF6B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
