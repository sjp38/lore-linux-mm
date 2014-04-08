Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A532B6B008A
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 04:56:32 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so7491932wib.3
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 01:56:30 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id o10si429678wiy.97.2014.04.08.01.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 01:56:30 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id hm4so924393wib.2
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 01:56:28 -0700 (PDT)
From: David CHANIAL <david.chanial@gmail.com>
Content-Type: multipart/signed; boundary="Apple-Mail=_5EC7D185-1E36-490F-8D2B-F29DCB40DCEA"; protocol="application/pgp-signature"; micalg=pgp-sha512
Date: Tue, 8 Apr 2014 10:56:24 +0200
Subject: The scan_unevictable_pages sysctl/node-interface has been disabled for lack of a legitimate use case
Message-Id: <E73F499E-8B54-4E32-A60B-59F2BB2023B2@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--Apple-Mail=_5EC7D185-1E36-490F-8D2B-F29DCB40DCEA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Hi,

I=92ve seen this message on my dmesg. What i have to care about ?

# dmesg -c
[27035732.129884] sysctl: The scan_unevictable_pages =
sysctl/node-interface has been disabled for lack of a legitimate use =
case.  If you have one, please send an email to linux-mm@kvack.org.

Best regards,
=97=20
David CHANIAL


--Apple-Mail=_5EC7D185-1E36-490F-8D2B-F29DCB40DCEA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAEBCgAGBQJTQ7m5AAoJEAofkXNv2UygRHMP/A6RzSP5JUykvoRQryecJUAp
tmVIkLbFFMbdNVjQnkYtrA902JkMGTsjstXPUFMDVFTVACnpFl4+oS/WhiVImHvV
6b5JHp3/i9KRih3lWKOMociYuLhACYaxDD8wz25Dw9eIUMDgzmrw0NkhQRm0jrQE
Kyv+0ehE4i+6sKh9UE3VnpVzIlGDrUvEOZsV4xpW7qZIvuzi+TmeE+RUv4ws7jbl
1GK+LK0kb7UQZK7OVBgIXBLshQ2nunedZk2ELaBzKEKVY3Ka/LML/PQPIgMLVFbd
oaxiERamSgy9aMssilNqlSMY8tAaik9M8J/XoA60NxgOrbPxUwXKS2z8WXlBftEA
yVK5DMltngFI5Cy6mpk/FIZcDKjRgs/V+eyL0rUHKgMGDnIQc6k/O2nxn17ojsKg
im8visyHNBAyfHk5I5agVqTdooAuRcu7J72c7CV4Lfqfxl4vpta/ucsCBYfj86vM
Rkgdfm3MybK2oyiZb9bhjIK4BHj5r4C4Iks6RtL+F7fwl/zsjizbYPFF3l+Z7uv0
tUjrZrxB7AeMpBGScYx0HGGPCSlMUW2OgsMTgchFFQp9QgjW4qOnEFsV/xxWzd8Y
Zhkcms7q0qn98ZlC8AwyLCbgG74lpJzpHgBHDeELRFQPVeKkvrNmKOScXV3unadK
lZFq9qKg8X0TkZx89ndn
=azea
-----END PGP SIGNATURE-----

--Apple-Mail=_5EC7D185-1E36-490F-8D2B-F29DCB40DCEA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
