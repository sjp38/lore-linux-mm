Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA3D6B0397
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 00:27:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x124so213953wmf.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 21:27:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18si27384252wry.54.2017.04.04.21.27.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 21:27:45 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Wed, 05 Apr 2017 14:27:02 +1000
Subject: Re: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.
In-Reply-To: <20170404071033.GA25855@infradead.org>
References: <871staffus.fsf@notabene.neil.brown.name> <20170404071033.GA25855@infradead.org>
Message-ID: <8760ijiind.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Apr 04 2017, Christoph Hellwig wrote:

> Looks fine,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
>
> But if you actually care about performance in any way I'd suggest
> to use the loop device in direct I/O mode..

The losetup on my test VM is too old to support that :-(
I guess it might be time to upgraded.

It seems that there is not "mount -o direct_loop" or similar, so you
have to do the losetup and the mount separately.  Any thoughts on
whether that should be changed ?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljkchYACgkQOeye3VZi
gbnNyA/8CYbI2TclJYsIDY6t3ChgU5qXSUw9k7WCj+Y1Je5xqxKiHDFkmTZIET+G
bmyzVT+J3I+sWSqX42ptGSYHSaxNJHazLsnBg2Gm/pChuNy5QlQm5EVclUEjWDJs
nU3eGbOQbFb4/uQpSdnonr91ODRGD9jFNS23NvTR5jkAORI6LS45Ex5Eg4zKiMH/
B/LcP4RKwHGKYHNoy/F5RyrObYM7kXsl0JNgNXPh/EZpkyXk0jSaqVpZ0a6P+z7e
nW8O9GbmxpmdEkS04nQ69BQ2Dq9Quf6GIuQRXUmeNWVUG2wnYTE1Ly7G50bWM+16
UKLpsCGHgKTAl1fdood4J+V+P8VFMMnsu5nbpMwkVq0nQw5B8g5M0pzl9ojF8bDe
w/3+yQoVfpu1waE+rqKsDEA+hszeq1T9qHAA2FZn/jAdDIUE4dnOT/e2rHmMN9P9
Tsfh92n5nFI0PvE61tEi7n/eHlw5e+nCGrBfxG/bHS/+eIDnP3zGborT31fa6C65
fV3VcwD244e9TVtM400qgHt6aUs2H3GzzedFDTt0TGE+4V5zON4DGdJ4gDwoyk4a
9NDpJoYWEkxyosxU8U9huKkeE1LIlEOJpGFi2f+KM0zNwVoU+m1R1dizQGLkb+/P
ANtntKix8d6qEYvgtfWB3pt61wFkd3wLWXPXpjFbwI2USfs68Oc=
=o4IH
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
