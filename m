Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBBB46B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 21:36:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e131so249015324pfh.7
        for <linux-mm@kvack.org>; Thu, 25 May 2017 18:36:40 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id h184si29965210pfg.177.2017.05.25.18.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 18:36:40 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id f27so42548616pfe.0
        for <linux-mm@kvack.org>; Thu, 25 May 2017 18:36:40 -0700 (PDT)
Date: Fri, 26 May 2017 09:36:39 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in
 __insert_vmap_area()
Message-ID: <20170526013639.GA10727@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
 <592649CC.8090702@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <592649CC.8090702@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 25, 2017 at 11:04:44AM +0800, zhong jiang wrote:
>I hit the overlap issue, but it  is hard to reproduced. if you think it is safe. and the situation
>is not happen. AFAIC, it is no need to add the code.
>
>if you insist on the point. Maybe VM_WARN_ON is a choice.
>

Do you have some log to show the overlap happens?

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZJ4anAAoJEKcLNpZP5cTdyxMP/R+BmCYvT4taaUp6yM2/y9U1
uyaf/GPO8VPtbOFcNtNJbn+gqsniFfS53+e49lhL3upBWoWvGG4NpYoqje2EmZHM
fePgtFd2+3z6m0opd6Ha5J+Izn5CmWQuJgcza8iU9QD4594FsVZO/2059KfqIdbh
cefe/YLkxJqIsdgGdBiQBgBehq9uI1LksBcRxIFSALwvhrS1rD9EDnbyePhtBvpA
tNTIaAZVFK3vjMgQXXWLvhLUhqFJXwhfzbdCd5HmZyTyxKHQE/iBMLvnilKXAb8G
bwmSmpSN2sRN1rAEzEG8w0eEHaUQ7O+cGgkuSsczwJGDaYW4NXG/vOtaXEqgWvAE
wR3hTiRwUs4Mkz+4SPjts7gYEQ4ohrK0ngN1Sp+0ZjtB4snLJauttVa/DBK56w8A
RYuZwd0WyK78PnhuUFCl0W8y/Lrp4rzWcS0xjEzZiOFAcYUJMIq8tZeIBacM/0iL
M9RR5154QPV/wRfexJIb77yc9rbzg/3c/7CX4HZMOI7vrLMRWpaSKn2QwQAEfkMh
sz8wq0am9CJTGFBTdoPZwDvEdFC3wyTAMqKGpleOwIy5PqFm6Jf2BzkMqrrNtur1
rlm9RG+XZvezueO3jHmiTm5sV9iey8QhISbu/48TS0IBSRpo8LjI9a+l79fwAYvU
vD4rPw39xIo0rWoTrX/D
=z15s
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
