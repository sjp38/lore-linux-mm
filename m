Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0AC76B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 15:32:28 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id jt9so35183404obc.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:32:28 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id r2si2947242ioe.209.2016.06.02.12.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 12:32:27 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id z123so4056251itg.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:32:27 -0700 (PDT)
Subject: Re: [BUG] Possible silent data corruption in filesystems/page cache
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_68E92C72-20C3-403F-934E-1D7434E515E0"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <842E055448A75D44BEB94DEB9E5166E91877AAF1@irsmsx110.ger.corp.intel.com>
Date: Thu, 2 Jun 2016 13:32:21 -0600
Message-Id: <A9F4ECA5-24EF-4785-BC8B-ECFE63F9B026@dilger.ca>
References: <842E055448A75D44BEB94DEB9E5166E91877AAF1@irsmsx110.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Barczak, Mariusz" <mariusz.barczak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wysoczanski, Michal" <michal.wysoczanski@intel.com>, "Baldyga, Robert" <robert.baldyga@intel.com>, "Roman, Agnieszka" <agnieszka.roman@intel.com>


--Apple-Mail=_68E92C72-20C3-403F-934E-1D7434E515E0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 1, 2016, at 3:51 AM, Barczak, Mariusz <mariusz.barczak@intel.com> =
wrote:
>=20
> We run data validation test for buffered workload on filesystems:
> ext3, ext4, and XFS.
> In context of flushing page cache block device driver returned IO =
error.
> After dropping page cache our validation tool reported data =
corruption.

Hi Mariusz,
it isn't clear what you expect to happen here?  If there is an IO error
then the data is not written to disk and cannot be correct when read.

The expected behaviour is the IO error will either be returned =
immediately
at write() time (this used to be more common with older filesystems), or =
it
will be returned when calling sync() on the file to flush cached data to =
disk.

> We provided a simple patch in order to inject IO error in device =
mapper.
> We run test to verify md5sum of file during IO error.
> Test shows checksum mismatch.
>=20
> Attachments:
> 0001-drivers-md-dm-add-error-injection.patch - device mapper patch

There is already the dm-flakey module that allows injecting errors into
the IO path.

Cheers, Andreas






--Apple-Mail=_68E92C72-20C3-403F-934E-1D7434E515E0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBV1CJx3Kl2rkXzB/gAQjdcg//VzwicbUGWXfZmm4H1QX7Novkz3opADK3
Fydyq4IoKkyD4H7R0WIMtmKlu3WnRPZ14l9RvC7gfCSIOLh1BoYso4AEHxjPs9tS
LvIfWVw89jIeQpFXNW/GUJ1KgXGthxY6a2d6LOu2iQ7bX5CtD9h4rJdNfCpRybZW
ihjV/TRJ/udgslroNyZtpbV0PQRlaknLWvRFu+H4dyrFbIGoHuiYAczte0HyMjhD
fQhOFxtCiRk0UyfhKySQOuSSq4NWN2CzOzzQBEZG4kcRAaXEYjof3xEjdHCUY6OF
aJWsRl6slR/7dZqm+c9ZH/zM/xryFK8n532KE1vtMFpuEWP6v2aVJ/kdA7fvg0jk
nht1cj0DOx3Cqr/ZSZZmK07PpzOeKy1eAV2bougEjh1+vyvJyuxSthot0R/YJ3wX
MmOBnfZawijP9HBs3YIMK68LasUKcb0FFX59Ghno7UJ4fsVHzM0DMlF+B+88lvO7
SDof+tztms8fhSseptfHhrqk+D++Zdq0ljiFMXjEHfm6EMtJTUdbMZaQTYIE/apO
TARno4ZfoIB/ftvrBfnGkrgKWUX01twINhGnQ1xy27GIkT1bYp2qT6p3IuejrPqI
Tig9jnw7p9bo4OIHFkWkQqIc1kJqs8jeM6zRhBfJcJKqqUxRoNlszI2PLf3spji7
30mYBQOkS6A=
=z+dy
-----END PGP SIGNATURE-----

--Apple-Mail=_68E92C72-20C3-403F-934E-1D7434E515E0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
