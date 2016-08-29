Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F47583102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:02:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so100978244lfb.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:02:31 -0700 (PDT)
Received: from mo6-p00-ob.smtp.rzone.de (mo6-p00-ob.smtp.rzone.de. [2a01:238:20a:202:5300::6])
        by mx.google.com with ESMTPS id es13si32737979wjb.44.2016.08.29.09.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 09:02:30 -0700 (PDT)
Date: Mon, 29 Aug 2016 17:59:56 +0200
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160829155956.GA31614@aepfle.de>
References: <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <20160825071103.GC4230@dhcp22.suse.cz>
 <20160825071728.GA3169@aepfle.de>
 <20160829145203.GA30660@aepfle.de>
 <20160829150703.GH2968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sdtB3X0nJg68CQEu"
Content-Disposition: inline
In-Reply-To: <20160829150703.GH2968@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Mon, Aug 29, Michal Hocko wrote:

> On Mon 29-08-16 16:52:03, Olaf Hering wrote:
> > I ran rc3 for a few hours on Friday amd FireFox was not killed.
> > Now rc3 is running for a day with the usual workload and FireFox is
> > still running.
> Is the patch
> (http://lkml.kernel.org/r/20160823074339.GB23577@dhcp22.suse.cz) applied?

Yes.

Tested-by: Olaf Hering <olaf@aepfle.de>

Olaf

--sdtB3X0nJg68CQEu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlfEW/YACgkQXUKg+qaYNn4yVwCfWomaLpB0Rmm0AASZNzIAWTVj
LjkAoOuVsFQhkSMaI3Mhs5JHWjX9UMKz
=moh7
-----END PGP SIGNATURE-----

--sdtB3X0nJg68CQEu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
