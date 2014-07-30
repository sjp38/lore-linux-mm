Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4906A6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 06:19:35 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so1285501pad.13
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 03:19:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ci1si941978pdb.302.2014.07.30.03.19.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 03:19:34 -0700 (PDT)
Date: Wed, 30 Jul 2014 12:19:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/2] new API to allocate buffer-cache for superblock in
 non-movable area
Message-ID: <20140730101920.GI19379@twins.programming.kicks-ass.net>
References: <53CDF437.4090306@lge.com>
 <20140722073005.GT3935@laptop>
 <20140722093838.GA22331@quack.suse.cz>
 <53D8A258.7010904@lge.com>
 <20140730101143.GB19205@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="l9eMEW72KrFG5Pxz"
Content-Disposition: inline
In-Reply-To: <20140730101143.GB19205@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Gioh Kim <gioh.kim@lge.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>


--l9eMEW72KrFG5Pxz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 30, 2014 at 12:11:43PM +0200, Jan Kara wrote:
> > sb_bread allocates page from movable area but it is not movable until the
> > reference counter of the buffer-head becomes zero.
> > There is no lock for the buffer but the reference counter acts like lock.
>   OK, but why do you care about a single page (of at most handful if you
> have more filesystems) which isn't movable? That shouldn't make a big
> difference to compaction...

The thing is, CMA _must_ be able to clear all the pages in its range,
otherwise its broken.

So placing nonmovable pages in a movable block utterly wrecks that.

Now, Ted said that there's more effectively pinned stuff from
filesystems (and I imagine those would be things like the root inode
etc.) and those would equally wreck this..

But Gioh didn't mention any of that.. he should I suppose.

--l9eMEW72KrFG5Pxz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT2MaoAAoJEHZH4aRLwOS6GNgQALZnfGN7cB0xynAZh2C6mLUk
j9DG7H3LZAc8uA0cAG6wTia/y2TbJWSIhpiUo2j2z7Y1UiDYFx6qXvvXU2oS3Vs4
qC07XEgv9r2IkEN30PYYcz+V6I4USTj8Q6AImm09qIprB+7w/K38KCq01DHHxIwQ
Q8lyqqCr9Iwwrwp2a170vKo/gxZD56h1t7cauFqw0aGnnchqrZjbBEX2hBC1f1/1
TS/Lv5OJ/ULsoqnh6tC4wnMx4juAqbxpM3o+0QjpCkYzf9QfJwlKqgB0TUNPL+RK
aGLo45TPEd/op227dOAxypYIPyXBLUOQkJIWFsWAL7iEszJcnK+w2j/+rihfeILp
QGD2YYYVylAe3e0jI0331ZJe+14E4SKk5/WaNYr5dcbO3f9yIYVilNYj9XAETjAN
AT1l4oghDHCu30WkX3nYGXtVIHqycB4s+X5DJY8P/MjC4Xv4hayBuOA7K1M9AThj
VslMtXWBiqdvhtxQfuP8SjEUfEUgGIXzzkwNnaaSAi+4UmMjArEQy7WAseI8izDO
J/QcYLBc+h/fulIlknkFVZpdhJcp85q9YKD4a2Jzyk9X1A35heMgYNWusPwuW71M
E9eIj5K7Mgkj7mty5B+wQbjMtLOIGlM5goKn8ChTYwhMOR+CUuXNIGLuCufP5coB
0tLDCub4+a/SFEEa7aIE
=nSKD
-----END PGP SIGNATURE-----

--l9eMEW72KrFG5Pxz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
