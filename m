Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F43E8308B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:14:29 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id c6so91333490qga.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 20:14:29 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id q77si288825qkl.244.2016.04.20.20.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 20:14:28 -0700 (PDT)
Subject: Re: linux-next crash during very early boot
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <58269.1460729433@turing-police.cc.vt.edu>
References: <3689.1460593786@turing-police.cc.vt.edu> <20160414013546.GA9198@js1304-P5Q-DELUXE>
 <58269.1460729433@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461208466_7324P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2016 23:14:26 -0400
Message-ID: <18440.1461208466@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1461208466_7324P
Content-Type: text/plain; charset=us-ascii

On Fri, 15 Apr 2016 10:10:33 -0400, Valdis.Kletnieks@vt.edu said:
> On Thu, 14 Apr 2016 10:35:47 +0900, Joonsoo Kim said:
> > On Wed, Apr 13, 2016 at 08:29:46PM -0400, Valdis Kletnieks wrote:
> > > I'm seeing my laptop crash/wedge up/something during very early
> > > boot - before it can write anything to the console.  Nothing in pstore,
> > > need to hold down the power button for 6 seconds and reboot.
> > >
> > > git bisect points at:
> > >
> > > commit 7a6bacb133752beacb76775797fd550417e9d3a2
> > > Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > Date:   Thu Apr 7 13:59:39 2016 +1000
> > >
> > >     mm/slab: factor out kmem_cache_node initialization code
> > >
> > >     It can be reused on other place, so factor out it.  Following patch will
> > >     use it.
> > >
> > >
> > > Not sure what the problem is - the logic *looks* ok at first read.  The
> > > patch *does* remove a spin_lock_irq() - but I find it difficult to
> > > believe that with it gone, my laptop is able to hit the race condition
> > > the spinlock protects against *every single boot*.
> > >
> > > The only other thing I see is that n->free_limit used to be assigned
> > > every time, and now it's only assigned at initial creation.
> >
> > Hello,
> >
> > My fault. It should be assgined every time. Please test below patch.
> > I will send it with proper SOB after you confirm the problem disappear.
> > Thanks for report and analysis!
>
> Following up - I verified that it was your patch series and not a bad bisect
> by starting with a clean next-20160413 and reverting that series - and the
> resulting kernel boots fine.

Following up some more - next-20160420 seems to work just fine, even with
no sign in 'git log -- mm/slab.c' of the fix-patch....

I'm obviously having a very bad "things that go bump in the night" with
kernels lately - this makes 3 different "makes no sense" things I've posted
in the last 6 hours... :)

--==_Exmh_1461208466_7324P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVxhFkgdmEQWDXROgAQJwGw/7BV8/GM2P5HTzd9P850EWuiTLc7rjjeGQ
GG3p23BjpGPZkmzMOd1BC6urNv6YH3y11umdpd76P7eK8+fiRE4DsoxFSGqRZqGX
um1ccR28RnFG/1b73FjZMga+To/s85hMi0guD7rGIVmYen0xZkc6Isldk6El9rv+
YcCbs5I2ldwkIpg6fSEHcnFwWk+oyk4aPYnv0kOQZVf/RmjFBhusWZVDnQQaZpwU
SAxwL9odaAuFOh6gdLUVPkqgVbZ4EpR1HOu25+zlq8D+NtUWz4tNvxp9HLO5Nmu8
hV7mXU/7ErEWFwIFr9+6kXoWS7Lz3x9iezk48CL5PpDVRjBAvukWkHDkFcX/yfne
JAUCOwkd01hxoe3I9RkCHQhaswYTtVMkY4KyXXNLcQ/1qHX/DLDK/1NAxODogkjd
YNuxo7Gzxhq1ZOXE28cnoeG1zDg6iPt+6I4guVLZRWzlDtCWj3MmwrSXVR2DsoJg
LapolImmkHLwcYpOTpJj0znSS1jV1HYHr1gUT3xFtOFoFt/VJwJeeJ1xgnWs28gm
PWH14cK8yUuCcnmJVqsNk5zp40u8tA2Viu0x3YJ+PIeYmuOusx9p8Xn4WQe/TvO8
btmXpNVGwqdCzBRrEvdEHyfYOmBEGxJyCcxYUN60LoOl2OpUwvzEwoPRmqpSY+ST
GMugqoVpc7o=
=5KeX
-----END PGP SIGNATURE-----

--==_Exmh_1461208466_7324P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
