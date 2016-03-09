Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 72AB86B007E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 14:38:56 -0500 (EST)
Received: by mail-qk0-f173.google.com with SMTP id s68so24880026qkh.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 11:38:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f125si109709qkb.95.2016.03.09.11.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 11:38:55 -0800 (PST)
Message-ID: <1457552332.17933.24.camel@redhat.com>
Subject: Re: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
From: Rik van Riel <riel@redhat.com>
Date: Wed, 09 Mar 2016 14:38:52 -0500
In-Reply-To: <20160309170438.GB9715@rkaganb.sw.ru>
References: 
	<F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
	 <20160304102346.GB2479@rkaganb.sw.ru>
	 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
	 <20160304163246-mutt-send-email-mst@redhat.com>
	 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
	 <20160305214748-mutt-send-email-mst@redhat.com>
	 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
	 <20160307110852-mutt-send-email-mst@redhat.com>
	 <20160309142851.GA9715@rkaganb.sw.ru>
	 <20160309173017-mutt-send-email-mst@redhat.com>
	 <20160309170438.GB9715@rkaganb.sw.ru>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-K0YSfgd+pCgmIgaD1fae"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Li, Liang Z" <liang.z.li@intel.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>


--=-K0YSfgd+pCgmIgaD1fae
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-09 at 20:04 +0300, Roman Kagan wrote:
> On Wed, Mar 09, 2016 at 05:41:39PM +0200, Michael S. Tsirkin wrote:
> > On Wed, Mar 09, 2016 at 05:28:54PM +0300, Roman Kagan wrote:
> > > For (1) I've been trying to make a point that skipping clean
> > > pages is
> > > much more likely to result in noticable benefit than free pages
> > > only.
> >=20
> > I guess when you say clean you mean zero?
>=20
> No I meant clean, i.e. those that could be evicted from RAM without
> causing I/O.
>=20

Programs in the guest may have that memory mmapped.
This could include things like libraries and executables.

How do you deal with the guest page cache containing
references to now non-existent memory?

How do you re-populate the memory on the destination
host?

--=C2=A0
All rights reversed

--=-K0YSfgd+pCgmIgaD1fae
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJW4HvMAAoJEM553pKExN6D5J8IAMBmqwQi+Hyqk1yRWjNTf7pD
W9QbhicpkmXTphpgbwLoxlasBetwFhFkr7fg2bADCefMdP5UN/osupn6S9UXGudi
ga1vaW6A3X/C1qaZ7iS8rulSNgJoQBBbCe2D7it5VZVsCCjQfw9XnqSDT6eoK/cG
6MfuZBGZpN+W7TbyM1xYaJ2xYQjGzV2zbfV/rQw2y0B8uOlTNFGToeTf7q4z2d7Q
ZIoJPFwuPUUQlQzrKRXu3qEjsVgyIJLleaaejpgGScN0WkAKZ58gD2UyQWUiCge7
P8r3BFFBMoZukQS0/3UAH7psGOCvBX4EFK5M9FtDTghY1m8syJH8MGa0ALYY1Ng=
=hi8W
-----END PGP SIGNATURE-----

--=-K0YSfgd+pCgmIgaD1fae--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
