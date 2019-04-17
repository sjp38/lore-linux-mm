Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7C5C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EC6F21773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:36:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EC6F21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27A0B6B0008; Wed, 17 Apr 2019 04:36:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DB5B6B000A; Wed, 17 Apr 2019 04:36:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C94B6B000D; Wed, 17 Apr 2019 04:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id D7F6E6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:36:08 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id z5so4876305vsq.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:36:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :from:date:message-id:subject:to:cc;
        bh=YXb3tuOBC3WhISII3/sOzazk0QCm5WN4iE4HfshQ49Q=;
        b=HeDC84xMq/Nhvl6c+HxgoMFb+KXWL+tJMJJkI3Vu6u3bcpghY9TOEO9W498XvzAAHg
         kjOFcZfix4ncjc9EkNMOkNlgyMAQ2C/r++vFGNHAQbpwwgAWv+q011EmGj2sanKAzOWC
         hxI+yRgA2F6TClURQEoa8WDnBkG4ffY7z61hnQ0fEYOOf5wvItKafWpvNAXQQUWxYc1N
         YcmM1Hp3vXmLXOEB9mSlINrOPKkAQZNLYKJAqIlDKLdX2ES+lU3i4CNaL6q0ziIvD4kp
         +vhk/tM8soD3+RJuD+NQ8Pb68b17g9+nOGpJQv5UgGb2Lp5ToZ7yMNvJVS+mc6toZ9oz
         ZF1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXD7mfXUciZ26CpHKS2FX7gjtr5oLoAwR6CKS57/jTqIMpc6hLh
	r/ZvJSpChbiO0BoKKgatJzjzckfVXCvc4Z9rKCMPcpuvRuuKAN6o2QGspTR28y9n1WTZgkB6yBP
	Hu55nSbYFyf6HHuhgTiQIuEPNEVICU38Id9zwgN5QMcjPjjuuAsCwl1MI+gPmBe0GJA==
X-Received: by 2002:ac5:c2cb:: with SMTP id i11mr46191782vkk.51.1555490168508;
        Wed, 17 Apr 2019 01:36:08 -0700 (PDT)
X-Received: by 2002:ac5:c2cb:: with SMTP id i11mr46191763vkk.51.1555490167726;
        Wed, 17 Apr 2019 01:36:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490167; cv=none;
        d=google.com; s=arc-20160816;
        b=EHhWKbjjrgQaVMh51wJD8P1mpmZqSYJMSycZLXczHW7Hk9vkUdLCJSxkVoovD30iU9
         N0STn+Yp1/gBxkBv9KIdaXAq/4SXl/UtADsOx1poUltGHwxVfU4pIRnTmfjI9pp8uHxt
         QyALLFrClJaO5PGqTnqf11mjiUmedpbparPdOmwyKjSKz5d7binHeqxx4kkDQNKHwyq4
         miz8RGuFZqbZWQEzqvrpiHHNsjCcFFABX8mVDY12jguVjIcBjvaQgmXbIitGeoApqz9W
         IHCE16Dd9CUMiT2I9t4fzOMXML9X6cATFA1a0lLlYbZTpOlY7LFfaqJGqp/Penq6y7us
         q+0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version;
        bh=YXb3tuOBC3WhISII3/sOzazk0QCm5WN4iE4HfshQ49Q=;
        b=ix+RAzRRpzfkkOIN5hip8mCv/QPgKqiootMylu0em0/boxOftMDT/+ScszgG7srC1g
         3RhRkhoJNmAvyRnX7qHhz+ofmNYB4bzGfxW1In/Z+RWqFxQ1gVZroEU0rYTQIMkrJzOV
         jnoO8tVgVcbk3VW0rbwdC12Fgs0Kbw55d7ZiVrBymYomXNa+KdFWRcHYQeKc/SxxU0H5
         fX6LXKZ43mWGPo6PevSaJ/HE9K8PMF2jfpTFxRSEwyFEFP/Cv22pQOVtf4oxtP4P7xki
         /boJv2G40Gfc/9hHXPVUTwItLFY0SARXXoaBCIIePtcWbWARMFYwd4JDRtYZrn5D9K46
         gx1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j2sor22513328vkd.36.2019.04.17.01.36.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:36:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxFKNOLin2z8+f4TeJcA7EBlvvOpYwLzBF7zlkpdodN37BhXVt6/6WOgLrAI3D7UOhoWKQTRFNsumgH/ZWcEbA=
X-Received: by 2002:a1f:860c:: with SMTP id i12mr48286196vkd.46.1555490167322;
 Wed, 17 Apr 2019 01:36:07 -0700 (PDT)
MIME-Version: 1.0
From: Li Wang <liwang@redhat.com>
Date: Wed, 17 Apr 2019 16:35:56 +0800
Message-ID: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
Subject: v5.1-rc5 s390x WARNING
To: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, 
	Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
Content-Type: multipart/alternative; boundary="000000000000e01d8a0586b5c69d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000e01d8a0586b5c69d
Content-Type: text/plain; charset="UTF-8"

Hi there,

I catched this warning on v5.1-rc5(s390x). It was trggiered in fork &
malloc & memset stress test, but the reproduced rate is very low. I'm
working on find a stable reproducer for it.

Anyone can have a look first?

[ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777
__alloc_pages_irect_compact+0x182/0x190
[ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4
dns_resolver
 nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390
des_s390 des_g
eneric sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
libcrc32c d
asd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm ccwgroup
fsm dm_mi
rror dm_region_hash dm_log dm_mod
[ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not
tainted 5.1.0-rc 5 #1
[ 1422.124089] Hardware name: IBM 2827 H43 400 (z/VM 6.4.0)
[ 1422.124092] Krnl PSW : 0704e00180000000 00000000002779ba
(__alloc_pages_direct_compact+0x182/0x190)
[ 1422.124096]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3
CC:2 PM:0 RI: 0 EA:3
[ 1422.124100] Krnl GPRS: 0000000000000000 000003e00226fc24
000003d081bdf200 000 0000000000001
[ 1422.124103]            000000000027789a 0000000000000000
0000000000000001 000 000000006ee03
[ 1422.124107]            000003e00226fc28 0000000000000cc0
0000000000000240 000 0000000000002
[ 1422.124156]            0000000000400000 0000000000753cb0
000000000027789a 000 003e00226fa28
[ 1422.124163] Krnl Code: 00000000002779ac: e320f0a80002        ltg
 %r2,168( %r15)
[ 1422.124163]            00000000002779b2: a784fff4            brc
 8,27799a
[ 1422.124163]           #00000000002779b6: a7f40001            brc
 15,2779b 8
[ 1422.124163]           >00000000002779ba: a7290000            lghi
 %r2,0
[ 1422.124163]            00000000002779be: a7f4fff0            brc
 15,27799 e
[ 1422.124163]            00000000002779c2: 0707                bcr
 0,%r7
[ 1422.124163]            00000000002779c4: 0707                bcr
 0,%r7
[ 1422.124163]            00000000002779c6: 0707                bcr
 0,%r7
[ 1422.124194] Call Trace:
[ 1422.124196] ([<000000000027789a>]
__alloc_pages_direct_compact+0x62/0x190)
[ 1422.124198]  [<0000000000278618>]
__alloc_pages_nodemask+0x728/0x1148
[ 1422.124201]  [<0000000000126bb2>] crst_table_alloc+0x32/0x68
[ 1422.124203]  [<0000000000135888>] mm_init+0x118/0x308
[ 1422.124204]  [<0000000000137e60>]
copy_process.part.49+0x1820/0x1d90
[ 1422.124205]  [<000000000013865c>] _do_fork+0x114/0x3b8
[ 1422.124206]  [<0000000000138aa4>] __s390x_sys_clone+0x44/0x58
[ 1422.124210]  [<0000000000739a90>] system_call+0x288/0x2a8
[ 1422.124210] Last Breaking-Event-Address:
[ 1422.124212]  [<00000000002779b6>]
__alloc_pages_direct_compact+0x17e/0x190
[ 1422.124213] ---[ end trace 36649eaa36968eaa ]---

-- 
Regards,
Li Wang

--000000000000e01d8a0586b5c69d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div dir=3D"ltr"><div class=3D"gmail_defa=
ult" style=3D"font-size:small"><pre style=3D"color:rgb(0,0,0);white-space:p=
re-wrap">Hi there,</pre><pre style=3D"color:rgb(0,0,0);white-space:pre-wrap=
">I catched this warning on v5.1-rc5(s390x). It was trggiered in fork &amp;=
 malloc &amp; memset stress test, but the reproduced rate is very low. I&#3=
9;m working on find a stable reproducer for it. </pre><pre style=3D"color:r=
gb(0,0,0);white-space:pre-wrap">Anyone can have a look first?</pre><pre sty=
le=3D"color:rgb(0,0,0);white-space:pre-wrap">[ 1422.124060] WARNING: CPU: 0=
 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190 =
                                                      =20
[ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_res=
olver=20
 nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390 =
des_g=20
eneric sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs libcrc=
32c d=20
asd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm ccwgroup fsm =
dm_mi=20
rror dm_region_hash dm_log dm_mod                                          =
     =20
[ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1=
.0-rc 5 #1                                                                 =
           =20
[ 1422.124089] Hardware name: IBM 2827 H43 400 (z/VM 6.4.0)                =
     =20
[ 1422.124092] Krnl PSW : 0704e00180000000 00000000002779ba (__alloc_pages_=
direct_compact+0x182/0x190)                                                =
          =20
[ 1422.124096]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:=
0 RI: 0 EA:3                                                               =
           =20
[ 1422.124100] Krnl GPRS: 0000000000000000 000003e00226fc24 000003d081bdf20=
0 000 0000000000001                                                        =
           =20
[ 1422.124103]            000000000027789a 0000000000000000 000000000000000=
1 000 000000006ee03                                                        =
           =20
[ 1422.124107]            000003e00226fc28 0000000000000cc0 000000000000024=
0 000 0000000000002                                                        =
           =20
[ 1422.124156]            0000000000400000 0000000000753cb0 000000000027789=
a 000 003e00226fa28                                                        =
           =20
[ 1422.124163] Krnl Code: 00000000002779ac: e320f0a80002        ltg     %r2=
,168( %r15)                                                                =
           =20
[ 1422.124163]            00000000002779b2: a784fff4            brc     8,2=
7799a                                                                      =
           =20
[ 1422.124163]           #00000000002779b6: a7f40001            brc     15,=
2779b 8                                                                    =
           =20
[ 1422.124163]           &gt;00000000002779ba: a7290000            lghi    =
%r2,0   =20
[ 1422.124163]            00000000002779be: a7f4fff0            brc     15,=
27799 e                                                                    =
           =20
[ 1422.124163]            00000000002779c2: 0707                bcr     0,%=
r7   =20
[ 1422.124163]            00000000002779c4: 0707                bcr     0,%=
r7   =20
[ 1422.124163]            00000000002779c6: 0707                bcr     0,%=
r7   =20
[ 1422.124194] Call Trace:                                                 =
     =20
[ 1422.124196] ([&lt;000000000027789a&gt;] __alloc_pages_direct_compact+0x6=
2/0x190)   =20
[ 1422.124198]  [&lt;0000000000278618&gt;] __alloc_pages_nodemask+0x728/0x1=
148        =20
[ 1422.124201]  [&lt;0000000000126bb2&gt;] crst_table_alloc+0x32/0x68      =
           =20
[ 1422.124203]  [&lt;0000000000135888&gt;] mm_init+0x118/0x308             =
           =20
[ 1422.124204]  [&lt;0000000000137e60&gt;] copy_process.part.49+0x1820/0x1d=
90         =20
[ 1422.124205]  [&lt;000000000013865c&gt;] _do_fork+0x114/0x3b8            =
           =20
[ 1422.124206]  [&lt;0000000000138aa4&gt;] __s390x_sys_clone+0x44/0x58     =
           =20
[ 1422.124210]  [&lt;0000000000739a90&gt;] system_call+0x288/0x2a8         =
           =20
[ 1422.124210] Last Breaking-Event-Address:                                =
     =20
[ 1422.124212]  [&lt;00000000002779b6&gt;] __alloc_pages_direct_compact+0x1=
7e/0x190   =20
[ 1422.124213] ---[ end trace 36649eaa36968eaa ]---                        =
      </pre></div>-- <br><div dir=3D"ltr" class=3D"gmail-m_-385576432560707=
8863m_-8588808027537372373m_-5863484564193501364gmail_signature"><div dir=
=3D"ltr"><div>Regards,<br></div><div>Li Wang<br></div></div></div></div></d=
iv></div>

--000000000000e01d8a0586b5c69d--

