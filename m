Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 138726B0268
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:17:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so27710635wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:17:43 -0700 (PDT)
Received: from mo6-p00-ob.smtp.rzone.de (mo6-p00-ob.smtp.rzone.de. [2a01:238:20a:202:5300::7])
        by mx.google.com with ESMTPS id on9si12454660wjc.179.2016.08.25.00.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 00:17:41 -0700 (PDT)
Date: Thu, 25 Aug 2016 09:17:28 +0200
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160825071728.GA3169@aepfle.de>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <20160825071103.GC4230@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <20160825071103.GC4230@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Aug 25, Michal Hocko wrote:

> Any luck with the testing of this patch?

Not this week, sorry.

Olaf

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAle+m4QACgkQXUKg+qaYNn7J2QCfYGWwD+iOdRbSCZd82hTLWktl
YFQAoJ8RMmvgISM8+QJMDauS3/P5cbYY
=ey3U
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
