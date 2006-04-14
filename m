From: Nigel Cunningham <ncunningham@cyclades.com>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture independent manner V2
Date: Sat, 15 Apr 2006 09:17:04 +1000
References: <20060412232036.18862.84118.sendpatchset@skynet>
In-Reply-To: <20060412232036.18862.84118.sendpatchset@skynet>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5114347.xFTveIS9QW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200604150917.10596.ncunningham@cyclades.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, tony.luck@intel.com, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart5114347.xFTveIS9QW
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Mel.

It looks to me like this code could be used by the software suspend code in=
=20
our determinations of what pages to save, particularly in the context of=20
memory hotplug support. Just some food for thought at the moment; I'll see =
if=20
I can come up with a patch when I have some time, but it might help justify=
=20
getting this merged.

Regards,

Nigel

--nextPart5114347.xFTveIS9QW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEQC12N0y+n1M3mo0RAmFYAJ9a9Oz/cpEM/HR9N+6tkCaM9M8ckACgwZhq
qzMYheL6j+4zC3D1vEv6gWM=
=wz0/
-----END PGP SIGNATURE-----

--nextPart5114347.xFTveIS9QW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
