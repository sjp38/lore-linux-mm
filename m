Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 6F9176B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 14:14:38 -0400 (EDT)
Date: Mon, 24 Sep 2012 20:16:50 +0200
From: Conny Seidel <conny.seidel@amd.com>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924201650.6574af64.conny.seidel@amd.com>
In-Reply-To: <20120924143609.GH22303@aftab.osrc.amd.com>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
	<20120924142305.GD12264@quack.suse.cz>
	<20120924143609.GH22303@aftab.osrc.amd.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
	boundary="Sig_/43nlnw0jZPor8M=ZYFfSof7";
	protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>

--Sig_/43nlnw0jZPor8M=ZYFfSof7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 24 Sep 2012 16:36:09 +0200
Borislav Petkov <bp@amd64.org> wrote:
>[ =E2=80=A6 ]
>
>Conny, would you test pls?

Sure thing.
Out of ~25 runs I only triggered it once, without the patch the
trigger-rate is higher.

[   55.098249] Broke affinity for irq 81
[   55.105108] smpboot: CPU 1 is now offline
[   55.311216] smpboot: Booting Node 0 Processor 1 APIC 0x11
[   55.333022] LVT offset 0 assigned for vector 0x400
[   55.545877] smpboot: CPU 2 is now offline
[   55.753050] smpboot: Booting Node 0 Processor 2 APIC 0x12
[   55.775582] LVT offset 0 assigned for vector 0x400
[   55.986747] smpboot: CPU 3 is now offline
[   56.193839] smpboot: Booting Node 0 Processor 3 APIC 0x13
[   56.212643] LVT offset 0 assigned for vector 0x400
[   56.423201] Got negative events: -25

The Divide error wasn't triggered with the patch applied.


--
Kind regards.

Conny Seidel

##################################################################
# Email : conny.seidel@amd.com            GnuPG-Key : 0xA6AB055D #
# Fingerprint: 17C4 5DB2 7C4C C1C7 1452 8148 F139 7C09 A6AB 055D #
##################################################################
# Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach      #
# General Managers: Alberto Bozzo                                #
# Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen #
#               HRB Nr. 43632                                    #
##################################################################

--Sig_/43nlnw0jZPor8M=ZYFfSof7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlBgo5MACgkQ8Tl8CaarBV3cIACfS8zIzyGd/CwVRbjaxJPGWaS6
DKgAn2p0sHybxD+L7HqOmxp59ejajOWd
=Z6fT
-----END PGP SIGNATURE-----

--Sig_/43nlnw0jZPor8M=ZYFfSof7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
