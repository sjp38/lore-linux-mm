Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 218A36B0082
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 04:33:53 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so7737104pab.32
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 01:33:52 -0800 (PST)
Received: from ponies.io (ponies.io. [2600:3c01::f03c:91ff:fe6e:5e45])
        by mx.google.com with ESMTP id pl6si16406367pdb.123.2014.11.23.01.33.50
        for <linux-mm@kvack.org>;
        Sun, 23 Nov 2014 01:33:51 -0800 (PST)
Received: from cucumber.localdomain (58-6-54-190.dyn.iinet.net.au [58.6.54.190])
	by ponies.io (Postfix) with ESMTPSA id 8C2A4A145
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 09:33:50 +0000 (UTC)
Date: Sun, 23 Nov 2014 20:33:48 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141123093348.GA16954@cucumber.anchor.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Content-Disposition: inline
In-Reply-To: <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's an update:

Tried running 3.18.0-rc5 over the weekend to no avail. A load spike through
Ceph brings no perceived improvement over the chassis running 3.10 kernels.

Here is a graph of *system* cpu time (not user), note that 3.18 was a005.block:

http://ponies.io/raw/cluster.png

It is perhaps faring a little better that those chassis running the 3.10 in
that it did not have min_free_kbytes raised to 2GB as the others did, instead
it was sitting around 90MB.

The perf recording did look a little different. Not sure if this was just the
luck of the draw in how the fractal rendering works:

http://ponies.io/raw/perf-3.10.png

Any pointers on how we can track this down? There's at least three of us
following at this now so we should have plenty of area to test.

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUcan8AAoJEMHZnoZn5OShpfYP/jfEf+/MH1Tzik/dZ7ThIOVb
+Iq1SCHHnOqZ2zhPSshFNJX1AG33sR/8aWcEQl2ugkxr9FvRvbSh7EgNKMQ6hIX3
2lTLD3n84GYIESLj2xoERTYkD0c1LXmxvu1naOOUcxPQMK7AyPxZpxKx5FPFDCaA
V/SNjSMunSkDn9xAoccohvEd9sRMtwYEkeJMZ17p4BuJaB/LQeuMVZOx0mcXUiBo
2TAGQ9/k1QgzaBl/Nj2AU4lTqmVWvxrhASFhHZ57U+Ni5xqb99SqI8r/osTHqcAZ
55bY+mi7mrAa069T2jgm7pTqzoP2CvCtFFCCvjiD0enLQibuxfHrV4LPFZ+TmV55
QEZFVHl1xdqEeyHXcxzuxyr2VCnP47guQD+VufnjrfDFeVStZ/wTU+Qftr/kxsQy
pqZp9ojs7Nponvf4iVMRx7Aqh+jP//KPDlQwqA6wSGvmyc6s7w1Hmduf3oTqwVin
qgKhg0fjmzGJVNreRt89JkMbeyGEzW/atty3iXy+6Io84O16n0uNBTgU64vBhvdg
+zUy5lFje6GGDRSroN110M+7qFdqrEcWPGlULcs/so4j0cSKoZR9b94RejOGKyPm
3ZdbBFPLn5idlZOxk9eFBuiJmttxsvBjOq2sxvMdK+qur/d2aIlL6R7hjIohCesr
fUqp5j0iIPwl8rqSTnmx
=QVnh
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
