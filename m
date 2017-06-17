Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBB3F6B02F3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 22:55:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e187so58934516pgc.7
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 19:55:53 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i127si1082777pgc.170.2017.06.16.19.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 19:55:53 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u62so2977905pgb.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 19:55:52 -0700 (PDT)
Date: Sat, 17 Jun 2017 10:55:49 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm/memory_hotplug: remove duplicate call for
 set_page_links
Message-ID: <20170617025549.GA7538@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170616092335.5177-1-richard.weiyang@gmail.com>
 <20170616092335.5177-2-richard.weiyang@gmail.com>
 <20170616103350.e065a9838bb50c2dc70a41d8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Content-Disposition: inline
In-Reply-To: <20170616103350.e065a9838bb50c2dc70a41d8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@kernel.org, linux-mm@kvack.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 16, 2017 at 10:33:50AM -0700, Andrew Morton wrote:
>On Fri, 16 Jun 2017 17:23:35 +0800 Wei Yang <richard.weiyang@gmail.com> wr=
ote:
>
>> In function move_pfn_range_to_zone(), memmap_init_zone() will call
>> set_page_links for each page.
>
>Well, no.  There are several types of pfn's for which
>memmap_init_zone() will not call
>__init_single_page()->set_page_links().  Probably the code is OK, as
>those are pretty screwy pfn types.  But I'd like to see some
>confirmation that this patch is OK for all such pfns, now and in the
>future?
>

Hmm... when memmap_init_zone() is called during hotplug, this means=20
(context !=3D MEMMAP_EARLY).  So it will jump to the end and call
__init_single_page().

Is my understanding corrent?

>> This means we don't need to call it on each
>> page explicitly.
>>=20
>> This patch just removes the loop.
>>=20
>> ...
>>
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -914,10 +914,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
>>  	 * are reserved so nobody should be touching them so we should be safe
>>  	 */
>>  	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTP=
LUG);
>> -	for (i =3D 0; i < nr_pages; i++) {
>> -		unsigned long pfn =3D start_pfn + i;
>> -		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
>> -	}
>> =20
>>  	set_zone_contiguous(zone);
>>  }

--=20
Wei Yang
Help you, Help me

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZRJo1AAoJEKcLNpZP5cTdGaAP/3woBTIvmTzfFxEPaOyTVz7u
c8eS6rv4MaH78r0hJUPey2x7WYEVxNVuZP4jp2MmgpmQn3yhHSt3ssef0frkFouL
oiICdQEwu/5lgJ7ZOEHL8So+Tvb/a4h6NPJ3BhgnvXkaOMz5kwqXSZAtZo0xehiK
H/Vitt9Cr3aYZ9jbVl6oq2EQBIhJqzErmgI6Xe9xedS7qzLx0yA4AYFMFv6zL9/C
etzLCNOsXubrnXUpzFeYsTjNyvE7i9NztPmZ8S7iIYhcC6JNIQqUFgEskp5zoKC4
NMngRRmgcqiiMTTLO0QtFW3Om1HHBxihzreOrP6dNpsjw3l3RiARtztgIGmufNEr
Jn1OFji2vSrtdYXx6Hk7spafKofdTDTt6M4iTRItO6tR1V8nkZJZERQBW/VKoPXA
ml1kJ37vwpUYFl7Bcq5niV4n44YpvyMTmmgbGaObc3pr05S7Na0fek6n2dPQhORk
0EJ80Rq0PGXlBOYJcXRmOD9Uw6/lTKDSewNzEzMngK0hCK9CYrgNcz3cRa8jkJL7
Uk5NqYb+WZSoH5z2EgHlyaiXPnVFGUj6a5vJTzQEbX47ldzc6Rd4IkGXx5WX0FuO
gqE5HHK4UTP7TtK9Fpl1GA0XgX/oMMeHCtjE7vGuiSqNKLrjo5ju/mDZ5PykYtDs
E7XiPC/iINre09IqCFU5
=8Xvk
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
