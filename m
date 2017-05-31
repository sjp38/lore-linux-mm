Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1386B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 14:26:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c6so21005892pfj.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 11:26:30 -0700 (PDT)
Received: from mezzanine.sirena.org.uk (mezzanine.sirena.org.uk. [2400:8900::f03c:91ff:fedb:4f4])
        by mx.google.com with ESMTPS id m5si48008967pln.48.2017.05.31.11.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 11:26:29 -0700 (PDT)
Date: Wed, 31 May 2017 19:26:13 +0100
From: Mark Brown <broonie@kernel.org>
Message-ID: <20170531182613.sagvoniu53nehath@sirena.org.uk>
References: <alpine.DEB.2.10.1705241400510.49680@chino.kir.corp.google.com>
 <20170524212229.GR141096@google.com>
 <20170524143205.cae1a02ab2ad7348c1a59e0c@linux-foundation.org>
 <CAD=FV=XjC3M=EWC=rtcbTUR6e1F2cfuYvqL53F9H7tdMAOALNw@mail.gmail.com>
 <alpine.DEB.2.10.1705301704370.10695@chino.kir.corp.google.com>
 <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3wa3rjd5clmu4ver"
Content-Disposition: inline
In-Reply-To: <CAD=FV=Xi7NjDjsdwGP=GGS9p=uUpqZa7S=irNOFmhfD1F3kWZQ@mail.gmail.com>
Subject: Re: [patch] compiler, clang: suppress warning for unused static
 inline functions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Anderson <dianders@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matthias Kaehlcke <mka@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>


--3wa3rjd5clmu4ver
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 31, 2017 at 08:53:40AM -0700, Doug Anderson wrote:

> It is certainly possible that something like this could be done (I
> think Coverity works something like this), but I'm not sure there are
> any volunteers.  Doing this would require a person to setup and
> monitor a clang builder and then setup a list of false positives.  For
> each new warning this person would need to analyze the warning and
> either send a patch or add it to the list of false positives.

It also means setting up some mechanism for distributing the blacklist
or that that every individual person or group doing clang stuff would
need to replicate the work.

--3wa3rjd5clmu4ver
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlkvCsQACgkQJNaLcl1U
h9CyXQf+Miqtli5gWrZ7JkYinD2igBpzMPjpA7FJbw2bQ+O6pi1tNwBTsP3g0qw1
Wbzw7OAM9f/pmA+qrI7SY5L9hRwf+R7bbyNPJatZfKy+pz54OWLgznf9J+OW6s1g
zhcnbnGkPiuFQdzh+HYfLdRnbmQovGdXKeJJurWVaW4qoBlfJx7IKwMzdnIrB0H/
yBFCgxm5OP/lXrsIyr6U4/G+ymuWwzbdMLGkm/t26mhFGB2OYoT6Kw/FJ3est1xe
6Td1JienqGboVCdjC3cFqPAgc0UBA6L+i0amzE/QJc1kJPdmHWo4LKWGC2EWfRx2
jOTYXx1Zz21xwfeDc+AuZRr0T/9INw==
=+glf
-----END PGP SIGNATURE-----

--3wa3rjd5clmu4ver--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
