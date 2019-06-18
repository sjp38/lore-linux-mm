Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C6B9C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A956320873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="KqOu8QeU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A956320873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A3576B0003; Tue, 18 Jun 2019 17:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 355568E0002; Tue, 18 Jun 2019 17:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 269E18E0001; Tue, 18 Jun 2019 17:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02A156B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 17:43:08 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i196so13540094qke.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:43:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:content-transfer-encoding
         :mime-version:subject:message-id:date:cc:to;
        bh=NRmM4umgOyh1eQCe2Oecn8wVHqXbVjJOnebUYo1ErYU=;
        b=gjt40480dGnCbNgV1MlvQNz2rocq+pNEHNpa5/JMrPqTmm88xsDqkcre18rxiRXf7e
         rSXgUxJz2pUy76IMSlFa+4yA8IEeUtSicRT35OUmO6wjMUOyqkmg/X4gl48d6sXs9aTk
         GmbLk8VPz30UEzcyVPzVgW0Sl2+1EF4RSzvG79FACR8JYnbtKXfhv0mZINKexd5MGPLf
         zj6l2VRfUZX/8gbYrhaTYmD+eWesGMOrRFQTkdPlNP+X+LaNhuG7rL/EUh+7jn0SlcSa
         wJFXkPkdBKhHQGiygpHy996x9YdonF9eOw27eoDS491UTmGuKQd2vq/f8fDpzl0NFScd
         xA7A==
X-Gm-Message-State: APjAAAX+9QstulZbUVbcWiABxfdoFqkRS2q2GTXXRznKmSur9qqPo3kO
	+4ThDd937qozxQfATX2E8Y6o9NBMEbpJpSB7qu8uHZgBE6u3VHDstZYdKmnwajrKrJrA3Lu5ckp
	9KXCvE74bTwO0SrEmPX4QkL6BN5Jn8CiSyEkQTRP6nDOWcdrjfpcAHODAO7kWcdngVw==
X-Received: by 2002:a37:8904:: with SMTP id l4mr51124712qkd.260.1560894187716;
        Tue, 18 Jun 2019 14:43:07 -0700 (PDT)
X-Received: by 2002:a37:8904:: with SMTP id l4mr51124656qkd.260.1560894186822;
        Tue, 18 Jun 2019 14:43:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560894186; cv=none;
        d=google.com; s=arc-20160816;
        b=U+zpSjLVWHShAYt/wpReIqrxLNmpyXdXsUxexh4TA19OxuNuMeuATg+ypefTLDoQdT
         QzcE6uifKscHtRSNfPE9HLsGRh2e2To0QW7OC6TiWAw16FCht+xYJuWI6Pfh7COS2gJ1
         oqvODaGlUbqO3EvKACHPiRFGH9l8omW26VeC/YjrBNB4KBxDUMMuOfYhyvLFsD4NU6hx
         eGlmyCv7zkL1okQn7byIUBA5uxp6pdxzFQW6kleYdj+6UFCx+NLQ8Q99u+4tJ5PRBloy
         Fm5U32wBgIow/CM15bce+VGRHGTgFmGedN9k1c69l8BEEK4esB7RHvdJqBsa5HMC+mxK
         k6lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:from:dkim-signature;
        bh=NRmM4umgOyh1eQCe2Oecn8wVHqXbVjJOnebUYo1ErYU=;
        b=lpiWPr4LIo17zu/l71pOVFiPVxma6ImvdvIC8B7c7nFt/8M0S9HrxCVhlNNVXL3euM
         uAh/VCRe+r7HOfTNGruZa2eQrxk6eC7dbBThL4QJnnln3ncEQNAcEQxqGEZMoJTnIlGU
         BJUkG7znQFsJHKGqrV2UmJ/JyklNuAXDf6Y3CgJfVgBWzF6o6aOGdJ9P/TjDK9THvmRl
         9rosKEZCKcHWvPh/RDeEkMn522VdrAQLVIYG+ovuFpkbnRZ3/MAkQnwnaYA10kzGNXhn
         OMDAbri+DUWpxWqB1CRukeLfgs9jd1qBux90dQxRXbRwYrbDeJUxjx4TF3tzUAhCe3a1
         Km7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KqOu8QeU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z26sor22844194qta.30.2019.06.18.14.43.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 14:43:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KqOu8QeU;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:content-transfer-encoding:mime-version:subject:message-id:date
         :cc:to;
        bh=NRmM4umgOyh1eQCe2Oecn8wVHqXbVjJOnebUYo1ErYU=;
        b=KqOu8QeUNjItGMqRSw7/XmquWQubYyTFzKc+GcnZHLZKJ+PGPqR4O8xDaJDLvvdmSj
         wptLirp7ZuZUIdjYTEHR5NspRM9xIlo8YEuZuRLhXVIMHTLhkAW4YMdMwITmd+i+LKqR
         Is6NqcEYvoi6bIWwAMgm9tNSMG9pEJcIFsH32qyX9xMnU/1ph0avknUhOr3nMmDl5ukm
         +qURyBLNxYOzqPrWtvuf7u04gK7HWijEWLF8NyRBlo2fWxatapigeSg5ziEa+GBAZolx
         /eLVIbPPSy0JCRhTojvoEtl+FDkMqY23d/tG8WOIXwggZoc7X/Q70DepVJ3uWDuuXd/r
         JKMw==
X-Google-Smtp-Source: APXvYqwg9rrr9m167SC/m6cDxxIIx+ciBq0ip7//uUyaZgisDjgFiCIWgUB8t6Ihao8udYszNGtRAQ==
X-Received: by 2002:ac8:32e9:: with SMTP id a38mr104947222qtb.245.1560894186383;
        Tue, 18 Jun 2019 14:43:06 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id q29sm9397623qkq.77.2019.06.18.14.43.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 14:43:05 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: "mm: reparent slab memory on cgroup removal" series triggers
 SLUB_DEBUG errors
Message-Id: <65CAEF0C-F2A3-4337-BAFB-895D7B470624@lca.pw>
Date: Tue, 18 Jun 2019 17:43:04 -0400
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Booting linux-next on both arm64 and powerpc triggers SLUB_DEBUG errors =
below. Reverted the whole series =E2=80=9Cmm: reparent slab memory on =
cgroup removal=E2=80=9D [1] fixed the issue.

[1] https://lore.kernel.org/lkml/20190611231813.3148843-1-guro@fb.com/

[  151.773224][ T1650] BUG kmem_cache (Tainted: G    B   W        ): =
Poison overwritten
[  151.780969][ T1650] =
--------------------------------------------------------------------------=
---
[  151.780969][ T1650]=20
[  151.792016][ T1650] INFO: 0x000000001fd6fdef-0x0000000007f6bb36. =
First byte 0x0 instead of 0x6b
[  151.800726][ T1650] INFO: Allocated in create_cache+0x6c/0x1bc =
age=3D24301 cpu=3D97 pid=3D1444
[  151.808821][ T1650] 	kmem_cache_alloc+0x514/0x568
[  151.813527][ T1650] 	create_cache+0x6c/0x1bc
[  151.817800][ T1650] 	memcg_create_kmem_cache+0xfc/0x11c
[  151.823028][ T1650] 	memcg_kmem_cache_create_func+0x40/0x170
[  151.828691][ T1650] 	process_one_work+0x4e0/0xa54
[  151.833398][ T1650] 	worker_thread+0x498/0x650
[  151.837843][ T1650] 	kthread+0x1b8/0x1d4
[  151.841770][ T1650] 	ret_from_fork+0x10/0x18
[  151.846046][ T1650] INFO: Freed in slab_kmem_cache_release+0x3c/0x48 =
age=3D23341 cpu=3D28 pid=3D1480
[  151.854659][ T1650] 	slab_kmem_cache_release+0x3c/0x48
[  151.859799][ T1650] 	kmem_cache_release+0x1c/0x28
[  151.864507][ T1650] 	kobject_cleanup+0x134/0x288
[  151.869127][ T1650] 	kobject_put+0x5c/0x68
[  151.873226][ T1650] 	sysfs_slab_release+0x2c/0x38
[  151.877931][ T1650] 	shutdown_cache+0x198/0x23c
[  151.882464][ T1650] 	kmemcg_cache_shutdown_fn+0x1c/0x34
[  151.887691][ T1650] 	kmemcg_workfn+0x44/0x68
[  151.891963][ T1650] 	process_one_work+0x4e0/0xa54
[  151.896668][ T1650] 	worker_thread+0x498/0x650
[  151.901113][ T1650] 	kthread+0x1b8/0x1d4
[  151.905037][ T1650] 	ret_from_fork+0x10/0x18
[  151.909324][ T1650] INFO: Slab 0x00000000406d65a6 objects=3D64 =
used=3D64 fp=3D0x000000004d988e71 flags=3D0x7ffffffc000200
[  151.919596][ T1650] INFO: Object 0x0000000040f4b79e =
@offset=3D15420325124116637824 fp=3D0x00000000e038adbf
[  151.919596][ T1650]=20
[  151.931079][ T1650] Redzone 00000000fc4c04f0: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.941168][ T1650] Redzone 000000009a25c019: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.951256][ T1650] Redzone 000000000b05c7cc: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.961345][ T1650] Redzone 00000000a08ae38b: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.971433][ T1650] Redzone 00000000e0eccd41: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.981520][ T1650] Redzone 0000000016ee2661: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  151.991608][ T1650] Redzone 000000009364e729: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  152.001695][ T1650] Redzone 00000000f2202456: bb bb bb bb bb bb bb bb =
bb bb bb bb bb bb bb bb  ................
[  152.011784][ T1650] Object 0000000040f4b79e: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.021783][ T1650] Object 000000002df21fec: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.031779][ T1650] Object 0000000041cf0887: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.041775][ T1650] Object 00000000bfb91e8f: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.051770][ T1650] Object 00000000da315b1c: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.061765][ T1650] Object 00000000b362de78: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.071761][ T1650] Object 00000000ad4f72bf: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.081756][ T1650] Object 00000000aa32d346: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.091751][ T1650] Object 00000000ad1cf22c: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.101746][ T1650] Object 000000001cee47e4: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.111741][ T1650] Object 00000000418720ed: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.121736][ T1650] Object 00000000dee1c3f2: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.131731][ T1650] Object 00000000a23397c1: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.141727][ T1650] Object 000000002ed01641: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.151721][ T1650] Object 00000000915ec720: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.161716][ T1650] Object 00000000915988c1: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.171711][ T1650] Object 000000004a0cc60f: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.181707][ T1650] Object 0000000054a294c9: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.191701][ T1650] Object 0000000054f61682: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.201697][ T1650] Object 0000000018d04328: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.211692][ T1650] Object 00000000703cf2c7: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.221687][ T1650] Object 000000004d3ac5d5: 6b 6b 6b 6b 6b 6b 6b 6b =
00 00 00 00 00 00 00 00  kkkkkkkk........
[  152.231682][ T1650] Object 00000000726ce587: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.241676][ T1650] Object 00000000c709b64e: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.251672][ T1650] Object 0000000044d6a5c6: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.261667][ T1650] Object 000000009c76a6a2: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.271662][ T1650] Object 0000000033d01d12: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.281657][ T1650] Object 00000000c50ff26f: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.291652][ T1650] Object 00000000ebc3aaae: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.301647][ T1650] Object 00000000a2072fe3: 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  152.311641][ T1650] Object 000000003d5911a3: 6b 6b 6b 6b 6b 6b 6b a5  =
                        kkkkkkk.
[  152.320942][ T1650] Redzone 000000009a2feac1: bb bb bb bb bb bb bb bb =
                         ........
[  152.330330][ T1650] Padding 00000000c1b3cb8b: 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  152.340412][ T1650] Padding 000000003715421a: 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  152.350493][ T1650] Padding 0000000066b51ba7: 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  152.360575][ T1650] Padding 00000000ca240306: 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  152.370657][ T1650] Padding 0000000014a2af5d: 5a 5a 5a 5a 5a 5a 5a 5a =
                         ZZZZZZZZ
[  152.380048][ T1650] CPU: 82 PID: 1650 Comm: kworker/82:1 Tainted: G   =
 B   W         5.2.0-rc5-next-20190617 #18
[  152.390216][ T1650] Hardware name: HPE Apollo 70             =
/C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
[  152.400741][ T1650] Workqueue: memcg_kmem_cache =
memcg_kmem_cache_create_func
[  152.407786][ T1650] Call trace:
[  152.410926][ T1650]  dump_backtrace+0x0/0x268
[  152.415280][ T1650]  show_stack+0x20/0x2c
[  152.419287][ T1650]  dump_stack+0xb4/0x108
[  152.423384][ T1650]  print_trailer+0x274/0x298
[  152.427825][ T1650]  check_bytes_and_report+0xc4/0x118
[  152.432959][ T1650]  check_object+0x2fc/0x36c
[  152.437312][ T1650]  alloc_debug_processing+0x154/0x240
[  152.442532][ T1650]  ___slab_alloc+0x710/0xa68
[  152.446972][ T1650]  kmem_cache_alloc+0x514/0x568
[  152.451672][ T1650]  create_cache+0x6c/0x1bc
[  152.455938][ T1650]  memcg_create_kmem_cache+0xfc/0x11c
[  152.461158][ T1650]  memcg_kmem_cache_create_func+0x40/0x170
[  152.466814][ T1650]  process_one_work+0x4e0/0xa54
[  152.471515][ T1650]  worker_thread+0x498/0x650
[  152.475953][ T1650]  kthread+0x1b8/0x1d4
[  152.479872][ T1650]  ret_from_fork+0x10/0x18
[  152.484139][ T1650] FIX kmem_cache: Restoring =
0x000000001fd6fdef-0x0000000007f6bb36=3D0x6b
[  152.484139][ T1650]=20
[  152.494395][ T1650] FIX kmem_cache: Marking all objects used=

