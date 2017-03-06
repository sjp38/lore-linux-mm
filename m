Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF1EA6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:59:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v190so65991511pfb.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:59:01 -0800 (PST)
Received: from mezzanine.sirena.org.uk (mezzanine.sirena.org.uk. [2400:8900::f03c:91ff:fedb:4f4])
        by mx.google.com with ESMTPS id a14si13248536pll.152.2017.03.06.02.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:59:01 -0800 (PST)
Date: Mon, 6 Mar 2017 11:58:05 +0100
From: Mark Brown <broonie@kernel.org>
Message-ID: <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
 <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7gbhuigre4oq4px2"
Content-Disposition: inline
In-Reply-To: <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org


--7gbhuigre4oq4px2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 06, 2017 at 11:40:41AM +0100, Daniel Vetter wrote:

> No one gave a thing about android in upstream, so Greg KH just dumped it
> all into staging/android/. We've discussed ION a bunch of times, recorded
> anything we'd like to fix in staging/android/TODO, and Laura's patch
> series here addresses a big chunk of that.

> This is pretty much the same approach we (gpu folks) used to de-stage the
> syncpt stuff.

Well, there's also the fact that quite a few people have issues with the
design (like Laurent).  It seems like a lot of them have either got more
comfortable with it over time, or at least not managed to come up with
any better ideas in the meantime.

--7gbhuigre4oq4px2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAli9QLwACgkQJNaLcl1U
h9AjFQf/SPP5WD/SamvFwR56oEgJCbFqFDKWSfrPtpOHcfR7yTxxJ4T07+f18Wgf
6ZGZlQd0SBUxP65VsmWrvg34rd9FNb/2YCqLRtjr0RmvUcHFNnbmP8nrbU8AQekQ
TRuF/QybJD2UiwSDgGnQsSmGCMc3HXpqIxurTBIkw9ylIN93inK4dYnuuc3DBMVt
jPWYJ84BS73hEecBqF8snoW+IRVPt7YNBDj0ADqQ8B1o2hZzD2UEuBKUDITFClnl
kkVw8Px8cq4yLMLkG8TgB19SGvI/XungEyp8lJ//p++h9UplUAGJq5csJJFFdpWn
RpzvwRx9VQZBi03EaziJ80ZgCzmF6A==
=SMXH
-----END PGP SIGNATURE-----

--7gbhuigre4oq4px2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
