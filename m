Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 3BCB66B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:56:56 -0400 (EDT)
Received: by weys10 with SMTP id s10so1354265wey.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 05:56:54 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC v2] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <50486658.5000305@cn.fujitsu.com>
References: <1346900018-14759-1-git-send-email-minchan@kernel.org> <50485B7B.3030201@cn.fujitsu.com> <20120906081818.GC16231@bbox> <50486658.5000305@cn.fujitsu.com>
Date: Thu, 06 Sep 2012 14:56:45 +0200
Message-ID: <xa1tmx139unm.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wen Congyang <wency@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

>> +		pfn =3D page_to_pfn(page);
>> +		if (pfn >=3D end_pfn)
>> +			return false;
>> +		if (pfn >=3D start_pfn)
>> +			goto found;

On Thu, Sep 06 2012, Lai Jiangshan wrote:
> this test is wrong.
>
> use this:
>
> if ((pfn <=3D start_pfn) && (start_pfn < pfn + (1UL << page_order(page))))
> 	goto found;
>
> if (pfn > start_pfn)
> 	return false;

	if (pfn > start_pfn)
		return false;
	if (pfn + (1UL << page_order(page)) > start_pfn)
		goto found;

>> +	}
>> +	return false;
>> +
>> +	list_for_each_entry_continue(page, &isolated_pages, lru) {
>> +		if (page_to_pfn(page) !=3D next_pfn)
>> +			return false;

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
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQSJ2NAAoJECBgQBJQdR/0+1QQAIR5P9SLVdGeUtCVULOZJe5e
DSIL9hJ9CG5AQoANFaLvoe+EF1jiKsk8AyXnmOSX4yNi4M5cFVfc3Zr6i6t4cpLE
wbUxVjIFsZ41thzgFCwJrxK9daLAMs5Mxk8NnjJZLBzrLfbQTwzQgyeJhdufRnC4
+JPTeEmrtR621U/v1fyiBS3BFI+FhnChaApwytBdmgQFylVz2OFLCvYxVgr2RS+V
JCT0olf/EMo5GZasGzjAvCM2FLtV6r64lpTV2KtjLVX4NILtcpOYjd9rzqMabbR5
LLzG15eHVjBf28yONUJQNHjpUX1hYYkonyqdYVVSX3KFlSb+1mCyXD+n5U8hmk0S
oil8igzQQvX/JtuMl7RMgh92Up0GtbflcxU6tGU+WVqLMSvCP1pcdIWUr4GRf0dN
PgB8ZbZlYzZo6tPnFTr1ioFDl7vJ+LQXHGyzdQ7tTUg/xKCwDPddjWev1AfYNmma
zBgbgkjyMaJhX7TAEwE+MimADcHFEJntOmnwab1KOE81sX678B0v1zVQAkYP/+bf
1Gfcw3iRGXhJiZChILJRhSjM7MuJ6rfJs9SqxJ+hNXcwxfyHIN7iT7WxD+yMlvNY
PKA2enUkLVe83CMYcaisIUA/O5VAaP00jJv2W/RKGVMt3O3lVZ1XSrmW+Ljaxnb2
rn7FVmVzQTk26k7Sg/U0
=+qAP
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
