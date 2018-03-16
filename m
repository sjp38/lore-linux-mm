Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4346B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 23:48:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w20-v6so3259086plp.13
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 20:48:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si4419350pgq.119.2018.03.15.20.48.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 20:48:01 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Fri, 16 Mar 2018 14:47:48 +1100
Subject: Re: mmotm 2018-03-14-16-24 uploaded (lustre)
In-Reply-To: <5c65e935-a6d9-2f80-18ac-470ed38ba439@infradead.org>
References: <20180314232442.rL_lhWQqT%akpm@linux-foundation.org> <5c65e935-a6d9-2f80-18ac-470ed38ba439@infradead.org>
Message-ID: <87605wbs0r.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, lustre-devel@lists.lustre.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 15 2018, Randy Dunlap wrote:

> On 03/14/2018 04:24 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2018-03-14-16-24 has been uploaded to
>>=20
>>    http://www.ozlabs.org/~akpm/mmotm/
>
> (not from the mmotm patches, but in its linux-next.patch)
>
> CONFIG_LUSTRE_FS=3Dy
> # CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is not set
>
>
> In file included from ../drivers/staging/lustre/include/linux/libcfs/libc=
fs.h:42:0,
>                  from ../drivers/staging/lustre/lustre/obdclass/lu_object=
.c:44:
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_co=
ntext_key_degister':
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1410:51: error: der=
eferencing pointer to incomplete type
>           __func__, key->lct_owner ? key->lct_owner->name : "",
>                                                    ^

Thanks for the report.
Arnd Bergmann posted a patch to fix this on Tuesday

Message-Id: <20180313130425.3975930-1-arnd@arndb.de>

http://lkml.kernel.org/r/<20180313130425.3975930-1-arnd@arndb.de>

so the error should disappear soon.

Thanks,
NeilBrown


> ../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: not=
e: in definition of macro '__CDEBUG'
>    libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
>                                          ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1409:3: note: in ex=
pansion of macro 'CDEBUG'
>    CDEBUG(D_INFO, "%s: \"%s\" %p, %d\n",
>    ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_co=
ntext_key_quiesce':
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1550:42: error: der=
eferencing pointer to incomplete type
>            key->lct_owner ? key->lct_owner->name : "",
>                                           ^
> ../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: not=
e: in definition of macro '__CDEBUG'
>    libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
>                                          ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1548:4: note: in ex=
pansion of macro 'CDEBUG'
>     CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
>     ^
>
>
>
> --=20
> ~Randy

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqrPmQACgkQOeye3VZi
gbnIgg/9H8TxMGQ0KLNoeEmN640Hw9FYzKHUWhYIWGFRHpNtHrpyVlvserEHIxjN
LshHyZOLxft9KbkYvzptmNLhAYYoN996HlTvXakH8brmKIQ8oCM5igCRXa0hBevG
Ziz4Fyx+yWix3wmxJhUiPlzrIMF/gZTjs0vmVERKDnTxPAgrzLdXdG501iD67SK9
Qid6hy5x1TvWHWW6WMlX9QJi5UvALYBwxYD3q7R+IKXnTdkUUXwxZ4u21/3Rb3ZI
Oozk8muX2VOK7T48wdVLva6r7g/NSbisuEV8pBQRyKUmib0tFa7MZP/QMspYfNdh
+126mirhrBGduRZ1VZJ1JR8lTQxkxlTFJPQS1JNvRxG6KR1CmEXjP3huH6/ubper
6/Y1K7TJlqRbMZveVPZUZtBNr5uy3OnGlKxlci9tSLUDqBvJxs6JqWo4+3hNNsVs
7NW74WMStXNfP0BUI1AZTEAheNGWdnMiM6vdfiz550n9tvsfoMQFF4Zi/2M0+dlv
qXk37eEwstNOs4vK63F0KQoogm71CUOivRuN4BY6noEAecznmY0VcaZteiIWYXKz
G4QflgvIKUQyBqruOYKkwzUsRlKZOIcb/ymIpSeUn5P+aRntGpZ3t19c6vnq9aON
pQc/N201hwlI+LkG6F4qSl7P9V9HNFG8eAksOEB+wPtDhRfzEjM=
=HgXN
-----END PGP SIGNATURE-----
--=-=-=--
