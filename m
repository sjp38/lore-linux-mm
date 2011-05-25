Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A72576B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 05:25:04 -0400 (EDT)
Received: by mail-bw0-f44.google.com with SMTP id 13so7416710bwz.31
        for <linux-mm@kvack.org>; Wed, 25 May 2011 02:25:02 -0700 (PDT)
Date: Wed, 25 May 2011 12:24:55 +0300
From: Felipe Balbi <balbi@ti.com>
Subject: Re: linux-next: build failure after merge of the final tree
Message-ID: <20110525092449.GJ14556@legolas.emea.dhcp.ti.com>
Reply-To: balbi@ti.com
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
 <BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
 <BANLkTine2kobQA8TkmtiuXdKL=07NCo2vA@mail.gmail.com>
 <BANLkTim-zRShhy49d7yn5WTJYzR6A2DtZQ@mail.gmail.com>
 <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CxDuMX1Cv2n9FQfo"
Content-Disposition: inline
In-Reply-To: <BANLkTi=U8ikZo65AoxGznCopGMTFOUXWhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, "Balbi, Felipe" <balbi@ti.com>


--CxDuMX1Cv2n9FQfo
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 24, 2011 at 01:10:42PM -0400, Mike Frysinger wrote:
> On Tue, May 24, 2011 at 00:10, Mike Frysinger wrote:
> > On Tue, May 24, 2011 at 00:01, Linus Torvalds wrote:
> >> On Mon, May 23, 2011 at 7:06 PM, Mike Frysinger wrote:
> >>>
> >>> more failures:
> >>
> >> Is this blackfin or something?
> >
> > let's go with "something" ...
> >
> >> I did an allyesconfig with a special x86 patch that should have caught
> >> everything that didn't have the proper prefetch.h include, but non-x86
> >> drivers would have passed that.
> >
> > the isp1362-hcd failure probably is before your
> > 268bb0ce3e87872cb9290c322b0d35bce230d88f. =A0i think i was reading a log
> > that is a few days old (ive been traveling and am playing catch up
> > atm). =A0i'll refresh and see what's what still.
> >
> > the common musb code only allows it to be built if the arch glue is
> > available, and there is no x86 glue. =A0so an allyesconfig on x86
> > wouldnt have picked up the failure. =A0it'll bomb though for any target
> > which does have the glue.

anyone with a PCI OPT card to help adding a PCI glue layer for MUSB ?

> latest tree seems to only fail for me now on the musb driver.  i can
> send out a patch later today if no one else has gotten to it yet.

please do send out, but what was the compile breakage with musb ?

--=20
balbi

--CxDuMX1Cv2n9FQfo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN3MrhAAoJEAv8Txj19kN13eUH/2sPqkGsBmMQwQoKZwX3haUA
PhugOZGGAlhYCmJgUr4p7AfXyzyol6ZRrnU5sPGu6kM+j9/KRWO5dQFhNHW/Tlg2
gfm9Gx8ikCCxIFIqfb/J9DB15h5RNlLMkl3iHsTr6z3a+cNyev6Cb+vq8DOflIou
Kv9yURY9N4xVUFPY45Rv3RXZqQD2+JoWAHaRiJk0FbEVKJ1ABi7Tm+iNxbSjnQon
LvgQSQP8MCUPUqZxeZPcLKXbkxrh9GdkxlpAIX1QglGDuifiG73mT8MvNovxlKQC
ReZfQiKXJv5LIrOLvaCs7QjIrIRu8qoQ02GPAs83y8sz5Lj7VOQ43H8ciS2ky8c=
=aMEA
-----END PGP SIGNATURE-----

--CxDuMX1Cv2n9FQfo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
