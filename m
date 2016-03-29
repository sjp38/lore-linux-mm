Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 42B6A6B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 14:32:45 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n5so21428548pfn.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 11:32:45 -0700 (PDT)
Received: from mail.crc.id.au (mail.crc.id.au. [203.56.246.92])
        by mx.google.com with ESMTP id t9si60223pfa.9.2016.03.29.11.32.43
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 11:32:44 -0700 (PDT)
Received: from [10.1.1.197] (dhcp-10-1-1-197.lan.crc.id.au [10.1.1.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.crc.id.au (Postfix) with ESMTPSA id 591FD3A0063
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 05:32:40 +1100 (AEDT)
Subject: Re: 4.4: INFO: rcu_sched self-detected stall on CPU
References: <56F4A816.3050505@crc.id.au> <56F52DBF.5080006@oracle.com>
 <56F545B1.8080609@crc.id.au> <56F54EE0.6030004@oracle.com>
 <56F56172.9020805@crc.id.au> <56F5653B.1090700@oracle.com>
 <56F5A87A.8000903@crc.id.au> <56FA4336.2030301@crc.id.au>
 <56FA8DDD.7070406@oracle.com> <56FABF17.7090608@crc.id.au>
 <56FAC3AC.9050802@crc.id.au>
From: Steven Haigh <netwiz@crc.id.au>
Message-ID: <56FACA47.3050904@crc.id.au>
Date: Wed, 30 Mar 2016 05:32:39 +1100
MIME-Version: 1.0
In-Reply-To: <56FAC3AC.9050802@crc.id.au>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="WCC2A9TtQLfd42otdl3uLxKDxn1WBgqNd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WCC2A9TtQLfd42otdl3uLxKDxn1WBgqNd
Content-Type: multipart/mixed; boundary="0xAtvMgUD3cva9pEDf3cht7RXptSRtdaj"
From: Steven Haigh <netwiz@crc.id.au>
To: linux-mm@kvack.org
Message-ID: <56FACA47.3050904@crc.id.au>
Subject: Re: 4.4: INFO: rcu_sched self-detected stall on CPU
References: <56F4A816.3050505@crc.id.au> <56F52DBF.5080006@oracle.com>
 <56F545B1.8080609@crc.id.au> <56F54EE0.6030004@oracle.com>
 <56F56172.9020805@crc.id.au> <56F5653B.1090700@oracle.com>
 <56F5A87A.8000903@crc.id.au> <56FA4336.2030301@crc.id.au>
 <56FA8DDD.7070406@oracle.com> <56FABF17.7090608@crc.id.au>
 <56FAC3AC.9050802@crc.id.au>
In-Reply-To: <56FAC3AC.9050802@crc.id.au>

--0xAtvMgUD3cva9pEDf3cht7RXptSRtdaj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

After talking to Greg KH, I believe that this should be best directed to
this list. Please feel free to give me pointers if I'm wrong here.

On 30/03/2016 5:04 AM, Steven Haigh wrote:
> Greg, please see below - this is probably more for you...
>=20
> On 03/29/2016 04:56 AM, Steven Haigh wrote:
>>
>> Interestingly enough, this just happened again - but on a different
>> virtual machine. I'm starting to wonder if this may have something to =
do
>> with the uptime of the machine - as the system that this seems to happ=
en
>> to is always different.
>>
>> Destroying it and monitoring it again has so far come up blank.
>>
>> I've thrown the latest lot of kernel messages here:
>>      http://paste.fedoraproject.org/346802/59241532
>=20
> So I just did a bit of digging via the almighty Google.
>=20
> I started hunting for these lines, as they happen just before the stall=
:
> BUG: Bad rss-counter state mm:ffff88007b7db480 idx:2 val:-1
> BUG: Bad rss-counter state mm:ffff880079c638c0 idx:0 val:-1
> BUG: Bad rss-counter state mm:ffff880079c638c0 idx:2 val:-1
>=20
> I stumbled across this post on the lkml:
>     http://marc.info/?l=3Dlinux-kernel&m=3D145141546409607
>=20
> The patch attached seems to reference the following change in
> unmap_mapping_range in mm/memory.c:
>> -	struct zap_details details;
>> +	struct zap_details details =3D { };
>=20
> When I browse the GIT tree for 4.4.6:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tr=
ee/mm/memory.c?id=3Drefs/tags/v4.4.6
>=20
> I see at line 2411:
> struct zap_details details;
>=20
> Is this something that has been missed being merged into the 4.4 tree?
> I'll admit my kernel knowledge is not enough to understand what the cod=
e
> actually does - but the similarities here seem uncanny.
>=20
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20

--=20
Steven Haigh

Email: netwiz@crc.id.au
Web: https://www.crc.id.au
Phone: (03) 9001 6090 - 0412 935 897


--0xAtvMgUD3cva9pEDf3cht7RXptSRtdaj--

--WCC2A9TtQLfd42otdl3uLxKDxn1WBgqNd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW+spHAAoJEEGvNdV6fTHcsPgP/07YHX6lE2/M+vp89G34ZIXR
YWTXL67YUk0iyKOG97mIWoWPEhO9Xx2eobIcs23B5ReVcngfu553e6lQsv5SmP59
nRrYLW1Gm4TfHq3WR2BL/tsW853vxX/LaYgXMHcKIzdNKm6+kYwZ5hqtu7GuLgDt
TmSRvlHB+ceS6ez5YzPyZ92B3p2UeRaMBkqBOX/zM1/n5rSoR3gX3hFdQKCb3DRs
3vFQQAczSD43EdP7Hi8dATOG4hV+Xwck4Vxag6K4FghCcPFQgZ0kzo6A+xEMpxsQ
pfZoB8jy9jYe966855u7iF3IuNFIWxYZ6KYnRvlU/cqsse0GFlYEkh6exr6hutEh
oYueH7I334FclPwrrcz/MbjUod9HlOweN21D3ALRhYa8S/eq0OFaskN7aq3rGvke
Y7aJOZiqsDV3Pl29+S1AI9R77PPizfO0KHKt7K5WECP54/wqLBOLi4l2skocWuaR
VFo0/Fd2VcJ7MOj2J/6v2HQHI/W7lx5CZuJXPes8oSCdRRbLeLneT4XdUINAcwq4
Jyuj4VyKVGSLN/CpJ7RtOo3fIkuCvbp8mlPiHwHLHYiCfrr+YD3smLgq1/v0tEij
seJ55jin9KJH5S6+KewSuS2TLlG9UFvu3Bd9j7MJnuYMPYWCS/SuNdj88HYP/1n3
CTdvFBtPGi33AgQ5dnnm
=SY6G
-----END PGP SIGNATURE-----

--WCC2A9TtQLfd42otdl3uLxKDxn1WBgqNd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
