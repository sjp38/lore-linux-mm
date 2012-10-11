Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 545916B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:20:03 -0400 (EDT)
Subject: Re: kswapd0: wxcessive CPU usage
In-Reply-To: Your message of "Thu, 11 Oct 2012 19:59:33 +0200."
             <50770905.5070904@suse.cz>
From: Valdis.Kletnieks@vt.edu
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu>
            <50770905.5070904@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1349979570_1985P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Oct 2012 14:19:30 -0400
Message-ID: <119175.1349979570@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

--==_Exmh_1349979570_1985P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <119168.1349979570.1@turing-police.cc.vt.edu>

On Thu, 11 Oct 2012 19:59:33 +0200, Jiri Slaby said:
> On 10/11/2012 07:56 PM, Valdis.Kletnieks@vt.edu wrote:
> > On Thu, 11 Oct 2012 17:34:24 +0200, Jiri Slaby said:
> >> On 10/11/2012 03:44 PM, Valdis.Kletnieks@vt.edu wrote:
> >>> So at least we know we're not hallucinating. :)
> >>
> >> Just a thought? Do you have raid?
> >
> > Nope, just a 160G laptop spinning hard drive. Filesystems are ext4
> > on LVM on a cryptoLUKS partition on /dev/sda2.
>
> Ok, it's maybe compaction. Do you have CONFIG_COMPACTION=y?

# zgrep COMPAC /proc/config.gz
CONFIG_COMPACTION=y

Hope that tells you something useful.



--==_Exmh_1349979570_1985P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUHcNsgdmEQWDXROgAQKPxxAAi/iFROmawBnICQaf90Mxx3QxFj7Wunob
uYgQ+31FZ2txxUvTD/X3CNBhrQMUo9RKProRG1YrmzqP21q6JAUkYyce8dT7F/XS
bQO7Z31Qe0zm3OJNVou1HVtOnjoqGvdiG0W6eQfHUwrEQ1Pv12xgYb3nONDkqm+/
OpSOPJ7QuRkQMvgGWdXuwZgVn196IloXaicPHb/oZS9pwLEck6dWMG9tCM4LP1lN
8IfYja7p7jXySaoC7N9E6ZU9ZjtdtnnADLK9EHLt1uvTZT3DIu54hXPL/q4pwZBj
6tVSc+5fpMeDEkDZra6xOMvysCOMi0DmmZx38UHc0BKWUhOsfTXZgQl4+IbkCEP4
7p7rb1Y69dHTNeB1Q6+AXW1vdy/gPjicsgh+4lGeqqn16qtARl8uJTtS69YFXs/D
pMhnCMORoVrqDnRk4NkwQALmVaux1xUkEltRhLH8O4lVmA87F3v16OSi+OOwT0cb
sARzr/6ZRFpeMf2A/lLn1JPjYvIIffBg0no51MElExIZpq/qobn1k8V5oBVTXebr
ZP3J2RFavlY/rRqmwlRwUUA6ZsF4fNYHSF02jrgS0E+qDkgrXE8bVpLAOm5w1/nP
LULidsf9Xr5K1W81JLQZX533NrFEIj/ZRwWJlOivO0jcDUxorMYs5C4+g3PgnnsC
5kYiU0eGqWo=
=7uB1
-----END PGP SIGNATURE-----

--==_Exmh_1349979570_1985P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
