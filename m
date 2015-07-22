Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 53D339003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:05:06 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so110888874qkf.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:05:06 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id f82si1770413qkf.18.2015.07.22.07.05.02
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:05:04 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:05:02 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall
 system calls
Message-ID: <20150722140502.GB2859@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-3-git-send-email-emunson@akamai.com>
 <55AF5F5A.3000707@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Content-Disposition: inline
In-Reply-To: <55AF5F5A.3000707@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Vlastimil Babka wrote:

> On 07/21/2015 09:59 PM, Eric B Munson wrote:
> >With the refactored mlock code, introduce new system calls for mlock,
> >munlock, and munlockall.  The new calls will allow the user to specify
> >what lock states are being added or cleared.  mlock2 and munlock2 are
> >trivial at the moment, but a follow on patch will add a new mlock state
> >making them useful.
> >
> >munlock2 addresses a limitation of the current implementation.  If a
>=20
>   ^ munlockall2?

Fixed, thanks.


--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVr6MOAAoJELbVsDOpoOa9s9sP/A7izRQp4uVnMpOwD0MxlFeD
XcaKq8V5n3o7/BMR992hOIWBEl5/HUrJR3sRtfi42uPUYK930Ofy+mckUN6D4iiH
EyIKyjBq6DIBcChWmlXqNBh86cb1gvkx1gTNjjOSXVIFkrjvstCRomfHd7FtDmBq
u37dhRe0VJLAVWRRn+GvV5IEJzv20RnEgdfSw8kf+M4nO9g/59z8qe+IC3g2xLD2
q8D1rEwwnDOeYZVSkP+dt7EVkoR/hHbDdgijEocWwpKTNih4NcH0xgfcfYFbT3j+
MNNt3EeYAjmgZNZOL/YRbxWbnol84EdQUAZ9lfkjL/n5Pd4A4/yKduK1692DAtzD
RDPGJ5xP9g8JHM6+xvMk66ZEMFfZpnGioXfrV+2emLq8q4P+N2zJ6PREPk7r00tO
cbFFd/RNnVLBcCjj/1aIHG2txHVB9GVkUzj7MbHID019oC2IcQU+vFfUJcs5gexr
ntuWehXpnANwZY+kUKZWPevnUNqWsll4ITtbG7/6L20NbBADB8EXRnIyj4MzdLMN
x/aAITZB0qq1ad9H1pH4eXp7tnzX2b3T3HZN8+PWWhhPNBFenRFiOC4VnNT6J4aS
pZ/DMiXv5h6h17dEX3UQK4aMUurZw7Ptaj/N16MOsxTWM0jIm4De79+TfARt58Zs
xqZ6XgkcJBiIIcnJXw4D
=NAcA
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
