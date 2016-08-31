Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5B66B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:08:39 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id c67so18630799ywe.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:08:39 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id d68si1379687qkb.79.2016.08.31.14.08.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:08:38 -0700 (PDT)
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double locking object's lock in __delete_object
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1472677706_2066P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 31 Aug 2016 17:08:26 -0400
Message-ID: <33981.1472677706@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Nicholas Krause <xerofoify@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1472677706_2066P
Content-Type: text/plain; charset=us-ascii

On Wed, 31 Aug 2016 08:54:21 +0100, Catalin Marinas said:
> On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
> > This fixes a issue in the current locking logic of the function,
> > __delete_object where we are trying to attempt to lock the passed
> > object structure's spinlock again after being previously held
> > elsewhere by the kmemleak code. Fix this by instead of assuming
> > we are the only one contending for the object's lock their are
> > possible other users and create two branches, one where we get
> > the lock when calling spin_trylock_irqsave on the object's lock
> > and the other when the lock is held else where by kmemleak.
>
> Have you actually got a deadlock that requires this fix?

Almost certainly not, but that's never stopped Nicholas before.  He's a well-known
submitter of bad patches, usually totally incorrect, not even compile tested.

He's infamous enough that he's not allowed to post to any list hosted at vger.

--==_Exmh_1472677706_2066P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV8dHSgdmEQWDXROgAQIHSg/+NVg6jIsWvrJ9rciYZHHN1kDWgTIpKMf5
/k+QfaQFwjbVez/0xyThM/yBhovrPWztg2ki9zdA3wqoAKRm2QhrzhWFDYx/COzW
DTizXCbtbRkFdqXqGLRvYB+jruGPP2A7hzydNmPYRsg+PaTb7xwlr8lrhzJPqknA
jNVvWclbZbXNoMDQVnyxJB/mGg82SfrosFzgymJ3A4ghy6nFT2OqGUEI+dlFJ4dJ
MHnrXtOaWHLGroD6jOakyyXY6vxeU9woJSbde1dzNtLabQcVOcCW8wuE0lzRjEYB
U6MfokZeO2eFj8xt8VeNaRzuv54R6H04IyY7GYirAEDzlVJ7vF73OcedVkdpCWaL
Fo6v4uU6gnEx5reJ8ERucKbAoZrHcNObHnaAOruWwdItWn270N7p+KSThDpd1sWJ
SJjQKb7EDSWvctgKYxFND64hNbKki8LH35jZtbu9Xz6oqXt6pT2zLSeCBJ6HSc4H
2OVs1Js0l0i6XxCExqJufLK+GZ0WCD53znUJ/UlO+gBZjLTdSRJZ2ZVmcGSZm1yh
Hk9nyHaMTxI0o+d+jyc0f6CvkBAntwctZw7VmBy7nFpcmbl+b9/heVl2VFko6kWc
j1YNNS6UBwpPQYTCNW77N6S/xmUMsveHluldyXoYu/mi+79hXvShBmKV70gY6UR4
sfDHud3xCJI=
=8Wg2
-----END PGP SIGNATURE-----

--==_Exmh_1472677706_2066P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
