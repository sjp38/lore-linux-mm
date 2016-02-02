Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 792C16B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 14:14:01 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id u30so22673249qge.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 11:14:01 -0800 (PST)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id 78si2300887qge.4.2016.02.02.11.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 11:14:00 -0800 (PST)
Subject: Re: [slab] a1fd55538c: WARNING: CPU: 0 PID: 0 at kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller()
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <20160201073422.6dd72721@canb.auug.org.au>
References: <56aa2b47.MwdlkrzZ08oDKqh8%fengguang.wu@intel.com> <20160128184749.7bdee246@redhat.com> <21684.1454137770@turing-police.cc.vt.edu> <20160130184646.6ea9c5f8@redhat.com> <20160131131506.4aad01b5@canb.auug.org.au> <20160131194048.6f7add16@redhat.com>
 <20160201073422.6dd72721@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1454440363_5025P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 02 Feb 2016 14:12:43 -0500
Message-ID: <21792.1454440363@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

--==_Exmh_1454440363_5025P
Content-Type: text/plain; charset=us-ascii

On Mon, 01 Feb 2016 07:34:22 +1100, Stephen Rothwell said:
> Hi Jesper,

> > [PATCH] mm: temporary fix for SLAB in linux-next
> >
> > From: Jesper Dangaard Brouer <brouer@redhat.com>
> >
> > This is only for linux-next, until AKPM pickup fixes two patches:
> >  base url: http://ozlabs.org/~akpm/mmots/broken-out/
> >  [1] mm-fault-inject-take-over-bootstrap-kmem_cache-check.patch
> >  [2] slab-use-slab_pre_alloc_hook-in-slab-allocator-shared-with-slub.patch

> Applied to linux-next today.

Confirming that next-2016201 doesn't throw the warning on my laptop, thanks...

--==_Exmh_1454440363_5025P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVrD/qwdmEQWDXROgAQJ+DBAAmi8urkNIoMf0aR3vXZkvDSzq83TE9Anl
oOyIM4/VhwDHA3KC8XrogEM9yhevdkg/8J64oZHktXxyDB/Hh9cCMMfFDT4DAFp+
SqGmToHzGkxIM+/ITVE147Xye8b4dEslzGPURT9+5niuIWzo2Eu5h4+JYRnq/AAH
fp3syjU79EVeOF1bSrlxsfZSL0rIzhwwd5U2KCbzJhI39cjGgadSxeXJhNHm9RzO
/wx0wt+5kLkNhjrkla2oVHUTQgPoN0RH7/ECI8ySKlApnZR12w5IlGy4V2szq5pR
Kb/HL98oR6pPdvdtkATDmIbBh3sbLuHk6dx55dBPISsnkHbjiIbUii2+UMd6+Bp6
Kk4PR9y7CCZNfGj/e57BFpvbQyaC+8UsCtgM0hiwbnatbeKWXKGSe3q+rZyw7kcf
gD3nEMlhrX4v0PGCr6UXlfJ4lXkV3Of9DLtzhn5Ir/y1CiVEEO8x0csz9rkYEU6x
eScWeO8rcqMe4/SoEhhPIiwn2aM0LRsroaHDFwlMa1azTgL08E6fBKRTHLGCu0cY
pSAmmNP8rtQdwtBZ/zV/W8Gsr9hr6b/ChMxx7o0IirMrKG2fNPlPBpl3WHrFnFgy
2RfIS3xDPzlw9mK2dQj/t1aiDjtxdClj1ErjrAKU4BacpOIMEbmLSwHEFUl6JS7j
2sNhazRzoVo=
=IGB6
-----END PGP SIGNATURE-----

--==_Exmh_1454440363_5025P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
