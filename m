Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FORGED_YAHOO_RCVD,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5469C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 07:41:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B5602075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 07:41:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="UFKkd+Hf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B5602075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=yahoo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B166C6B0003; Thu, 28 Mar 2019 03:41:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC5BC6B0006; Thu, 28 Mar 2019 03:41:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B4E36B0007; Thu, 28 Mar 2019 03:41:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 557316B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 03:41:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f1so15830238pgv.12
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 00:41:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:reply-to:to:message-id
         :subject:mime-version:references;
        bh=SrQHZ6RbZjGsSaaKpsXRIqDajh7EiALeMR36VlUR+as=;
        b=bk8JX3oWTgoFJ8huAKhXcqURwqzkOYoecRblRbcRfq46esfvdxDQpf+/wWnbkSWIPg
         p+LODYuvRnv5xCEbQnbAOsy5r8R5tTwedgALlSlWJP+q2Qtf6sqfkalznLqg6FnqaPbr
         6PKZ+sz44WOK9HYhhC8sSsy4DAhQmtYCszSjtZnUpKk2AJCdrLJ/WXup1clMg6pRIIwk
         g5OfZvkm8RChEshcn1MlfuLqrFZgi26W0kDDu1L78SKRZhuIq4dfmsvGnALVjGiA/g7o
         zJ0j7IO1BjnL6RiSuNC+gIjlP3yolFNeigAMmcGoUWwu153TliGqz2RVKZlVZw9TYuZG
         1BRg==
X-Gm-Message-State: APjAAAU9D3bAUpr1CssyvH/Q1lBeNB/okMmyLhpmB/mKap0cdC6CVd6J
	U/tv9CkzOTfsbN3s1ld/96I3e8R9iojadg+cqft/EuOE6ljDbAdk2aFz5r0ji4Ecwq0+YFuIOO6
	u4jknDlW890E0l46SxVHm9F9abrUwBQ2BlYS+XqME1BNhd8bEpqeKIVO5xKPfVmsdXA==
X-Received: by 2002:a65:5049:: with SMTP id k9mr25469276pgo.229.1553758897782;
        Thu, 28 Mar 2019 00:41:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx56G5XUZJrnG0rB7PjCzL4n2GGmCFFsqJ0vd4F32gRumnVYOg6We68KCicfxWGL6eNepEt
X-Received: by 2002:a65:5049:: with SMTP id k9mr25469233pgo.229.1553758896555;
        Thu, 28 Mar 2019 00:41:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553758896; cv=none;
        d=google.com; s=arc-20160816;
        b=uHmQr/99gmSUMcCZDHWBkhMJ/x6y+vCxyDOCN1mu7jQI5zWTJyUPtwQ6HwPrEn1poh
         VW5c3oDn0BrbzZypQGt38Fgcbm/4gFXdGCVV2j9ytbX9Z3JBTXO7t8yIUIZea4rjHegK
         xOcMxjjhhnzmCHWTs5j1FQjs8bRVas7VoYTKsn8IrRgBu1DLUqCS1KT7PH8At1GltuSt
         qcs/tksN8auMmArUr6hbB444fWH7SaOxxwb5J1+WzxPnHQVAaW0tiKTE4YPGu86jZRQh
         R86bJ/GphRvQ1srTOVisHZEU0jjzPGU/JyNzdCDs0qz9EnLICFpkloCE0Fg9YsqYhclV
         xWQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:mime-version:subject:message-id:to:reply-to:from:date
         :dkim-signature;
        bh=SrQHZ6RbZjGsSaaKpsXRIqDajh7EiALeMR36VlUR+as=;
        b=Ex1CvqNBNPdxpyIjBtOvm1aiSe5KlX4Lu2k/skVj3upzEzXGFQIGAP7NKtkEvet/jU
         Zrr78jk8XjsO+VzUHEh8tQeaqGKNZiOdFeMKUSJ+bwnAZtN2bbPGgp+jJd0k7Jmd04Dg
         CgwuzXBZYjO8zv1f44PfvKg/y6SJpR9pDBiKy35SZK86y8NdilMMdyktVfoDD9+NTnHD
         iGUDHpZG/lXP4WxqggENkBTJsabKIz0QITuem/MbPeXfKwseZ7UAy65JxbGok3EMhAw0
         CxM+3azUTKs8DoAx+OgHcCdl4+sLFy1C6qg7f1IVdOw/ICZuFpgN+KxnRxOPwyGW7fua
         3uOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=UFKkd+Hf;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.209 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
Received: from sonic304-19.consmr.mail.sg3.yahoo.com (sonic304-19.consmr.mail.sg3.yahoo.com. [106.10.242.209])
        by mx.google.com with ESMTPS id 16si541460pfh.244.2019.03.28.00.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 00:41:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.209 as permitted sender) client-ip=106.10.242.209;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yahoo.com header.s=s2048 header.b=UFKkd+Hf;
       spf=pass (google.com: domain of suryawanshipankaj@yahoo.com designates 106.10.242.209 as permitted sender) smtp.mailfrom=suryawanshipankaj@yahoo.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=yahoo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1553758894; bh=SrQHZ6RbZjGsSaaKpsXRIqDajh7EiALeMR36VlUR+as=; h=Date:From:Reply-To:To:Subject:References:From:Subject; b=UFKkd+HfYmA7v5aVoBrI9Kbug0IGmt4jBo9PA0AhEYfZB7UuTqIStI1W9vBlsN2eMIdlIjyGI+9Cy5D7Fmh6uitx3FVRLL2BuT0GhxWy+D/e12bVDJANduPPC+3vTXKD+DijJk+/p9y+J3zN9/GncnxToGGvkZfE3GNydZ4DlAqyX05mIa+n0RLwCUvU40Wz1i5K4mimKVOqjooLde3Tw01eO3ECcfZidBGg/HTnWUw/WT29DnB8iG+RpmuKMScbZGh6aEJ+18a1ntCMJaGBMPHAs8xw+bDBTAU4U05sGlTFWf5gCc/602eujlIHOteMfFiBIpRlAxIlB20hJT5U6Q==
X-YMail-OSG: laoxTCsVM1la7df64UyuOjh4hUkG9BqlCxkiSp5Jrkpkzd2oRArftSBoN8F644w
 WToXZtovS3DzpdnRXU2zxf92nwQqTzboPyUNGWnNeBiov7AgMuGvLYWbUEK5JzO9q80imu6B56um
 LBuFTNOR1DZ8y4yc0cxOLNWWJrEAdplsKcXpVTxDixYerkQiSM4mzak8dRfVNgBmQWJ0fFiC2CxY
 mnI8CJudd6UddIfIR17qdMbST.8Jto_CeijRog7jJ8m_uRKz23UbJwrdsGhADzy_jhQ1sw4KtzHG
 8Wpg9oMjK.T1qbwnsO7Q2r1slwTKWPEXJRnqrxwrL7udR03WD.ssxj9lLWN3NTq.AkpgdDjHWwVd
 30r1Q7548_AgG4QXm4D0MxKUaxzRZdNP6.OM__OEormwI9UXTqB5uLPNv3NhS7MNtJfR_9oSVQzo
 gxvwgeGmFxA0v9caYXnycP_zy3vA_armS06s9ZV8r9UkDoRAc3HwbEPeUTW0._LgtfxcwWJrTpST
 zEqK4rq4mt11NW_suvubJL2rWPKsFhZRrvwP_rK78Saz.DSX2MPzRI6rV_IGBmOwxsbKT7rR4Y4w
 MF2sXcrUbIpw6zZNBiqvwQ.mqx8P2XLxuKgVSdLYwESLPQVmYnAYV5s7ZRh5cxosUKkLtPp1iChZ
 1WpcoAW_g7UkvZyidiZ1v4j.FEo6PZBz118aLwXHSlFKkDhPrDPJJCD4trKRs72EKSud1ZvRvGDT
 5S_ounIEJO8CFX1g8I7nJljZWnmKrGJEIgtiPShBJfFZ0H_AUf7oxctq8Ly7utMKGnWYDh06ot_M
 5evYkI0uf4w6HjgQqmmxRnJY4mR25q0x6HHq9aNTgAZq1nETO5cS3tfrHC.MXKokAJsmaFLD.N7G
 0d7U9ug8ZVhywXy8lSkCCKCfU8uJ1KS2jbWKNYw1h8MNKQCDDq5b2XZTvrcKj0B56LlMUjHCsi.v
 fkVxRqp6NfK23tdI6PnbVW6wS78eBhQv0p.k1VjN_NjKp4Sl7Nj7aMR15PnWWbcWumRS987mc9Sf
 JTEC2rNNKdsu2DFECH8kPsiNsn_ZxRvhyqtKvVn2lGAsoPqSD3g--
Received: from sonic.gate.mail.ne1.yahoo.com by sonic304.consmr.mail.sg3.yahoo.com with HTTP; Thu, 28 Mar 2019 07:41:34 +0000
Date: Thu, 28 Mar 2019 07:41:30 +0000 (UTC)
From: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
Reply-To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
To: LKML <linux-kernel@vger.kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Message-ID: <60090134.11615235.1553758890791@mail.yahoo.com>
Subject: page-allocation-failure
MIME-Version: 1.0
Content-Type: multipart/alternative; 
	boundary="----=_Part_11615234_2052929298.1553758890789"
References: <60090134.11615235.1553758890791.ref@mail.yahoo.com>
X-Mailer: WebService/1.1.13212 YahooMailNeo Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

------=_Part_11615234_2052929298.1553758890789
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello ,
I am facing issue related to page allocation failure.
If anyone is familiar with this issue, let me know what is the issue?How to=
 solved it.

Failure logs -:
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---
[=C2=A0=C2=A0 45.073877] kswapd0: page allocation failure: order:0, mode:0x=
1080020(GFP_ATOMIC), nodemask=3D(null)
[=C2=A0=C2=A0 45.073897] CPU: 1 PID: 716 Comm: kswapd0 Tainted: P=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 O=C2=A0=C2=A0=C2=A0 4.1=
4.65 #3
[=C2=A0=C2=A0 45.073899] Hardware name: Android (Flattened Device Tree)
[=C2=A0=C2=A0 45.073901] Backtrace:
[=C2=A0=C2=A0 45.073915] [<8020dbec>] (dump_backtrace) from [<8020ded0>] (s=
how_stack+0x18/0x1c)
[=C2=A0=C2=A0 45.073920]=C2=A0 r6:600f0093 r5:8141bd5c r4:00000000 r3:3abdc=
664
[=C2=A0=C2=A0 45.073928] [<8020deb8>] (show_stack) from [<80ba5e30>] (dump_=
stack+0x94/0xa8)
[=C2=A0=C2=A0 45.073936] [<80ba5d9c>] (dump_stack) from [<80350610>] (warn_=
alloc+0xe0/0x194)
[=C2=A0=C2=A0 45.073940]=C2=A0 r6:80e090cc r5:00000000 r4:81216588 r3:3abdc=
664
[=C2=A0=C2=A0 45.073946] [<80350534>] (warn_alloc) from [<803514e0>] (__all=
oc_pages_nodemask+0xd70/0x124c)
[=C2=A0=C2=A0 45.073949]=C2=A0 r3:00000000 r2:80e090cc
[=C2=A0=C2=A0 45.073952]=C2=A0 r6:00000001 r5:00000000 r4:8121696c
[=C2=A0=C2=A0 45.073959] [<80350770>] (__alloc_pages_nodemask) from [<803a6=
c20>] (allocate_slab+0x364/0x3e4)
[=C2=A0=C2=A0 45.073964]=C2=A0 r10:00000080 r9:00000000 r8:01081220 r7:ffff=
ffff r6:00000000 r5:01080020
[=C2=A0=C2=A0 45.073966]=C2=A0 r4:bd00d180
[=C2=A0=C2=A0 45.073971] [<803a68bc>] (allocate_slab) from [<803a8c98>] (__=
_slab_alloc.constprop.6+0x420/0x4b8)
[=C2=A0=C2=A0 45.073977]=C2=A0 r10:00000000 r9:00000000 r8:bd00d180 r7:0108=
0020 r6:81216588 r5:be586360
[=C2=A0=C2=A0 45.073978]=C2=A0 r4:00000000
[=C2=A0=C2=A0 45.073984] [<803a8878>] (___slab_alloc.constprop.6) from [<80=
3a8d54>] (__slab_alloc.constprop.5+0x24/0x2c)
[=C2=A0=C2=A0 45.073989]=C2=A0 r10:0004e299 r9:bd00d180 r8:01080020 r7:8147=
b954 r6:bd6e5a68 r5:00000000
[=C2=A0=C2=A0 45.073991]=C2=A0 r4:600f0093
[=C2=A0=C2=A0 45.073996] [<803a8d30>] (__slab_alloc.constprop.5) from [<803=
a9058>] (kmem_cache_alloc+0x16c/0x2d0)
[=C2=A0=C2=A0 45.073999]=C2=A0 r4:bd00d180 r3:be586360
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
-----
Regards,Pankaj

------=_Part_11615234_2052929298.1553758890789
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div style=3D"color:#000; background-color:#fff; f=
ont-family:Helvetica Neue, Helvetica, Arial, Lucida Grande, sans-serif;font=
-size:16px"><div id=3D"yiv1387592317"><div id=3D"yui_3_16_0_ym19_1_15537587=
84255_2515"><div style=3D"color:#000;background-color:#fff;font-family:Helv=
etica Neue, Helvetica, Arial, Lucida Grande, sans-serif;font-size:16px;" id=
=3D"yui_3_16_0_ym19_1_1553758784255_2514"><div id=3D"yiv1387592317"><div id=
=3D"yiv1387592317yui_3_16_0_ym19_1_1553756571666_2145"><div class=3D"yiv138=
7592317ydpdbdbf9cbyahoo-style-wrap" style=3D"font-family:Helvetica Neue, He=
lvetica, Arial, sans-serif;font-size:16px;" id=3D"yiv1387592317yui_3_16_0_y=
m19_1_1553756571666_2144"><div id=3D"yiv1387592317yui_3_16_0_ym19_1_1553756=
571666_2235">Hello ,</div><div id=3D"yiv1387592317yui_3_16_0_ym19_1_1553756=
571666_2198"><br></div><div id=3D"yiv1387592317yui_3_16_0_ym19_1_1553756571=
666_2197"><div id=3D"yiv1387592317yui_3_16_0_ym19_1_1553756571666_2683">I a=
m facing issue related to page allocation failure.</div><div id=3D"yiv13875=
92317yui_3_16_0_ym19_1_1553756571666_2543"><br></div><div id=3D"yiv13875923=
17yui_3_16_0_ym19_1_1553756571666_2557"><div id=3D"yui_3_16_0_ym19_1_155375=
8784255_2674">If anyone is familiar with this issue, let me know what is th=
e issue?</div><div>How to solved it.<br></div></div></div><div id=3D"yiv138=
7592317yui_3_16_0_ym19_1_1553756571666_2192"><br></div><div id=3D"yiv138759=
2317yui_3_16_0_ym19_1_1553756571666_2191">Failure logs -:</div><div id=3D"y=
iv1387592317yui_3_16_0_ym19_1_1553756571666_2189"><div id=3D"yui_3_16_0_ym1=
9_1_1553758784255_2718"><br></div><div id=3D"yui_3_16_0_ym19_1_155375878425=
5_2719">-------------------------------------------------------------------=
---------------------------------------------------------------------------=
-----------<br></div></div><div id=3D"yiv1387592317yui_3_16_0_ym19_1_155375=
6571666_2143"><span id=3D"yiv1387592317yui_3_16_0_ym19_1_1553756571666_2142=
">[&nbsp;&nbsp; 45.073877] kswapd0: page allocation failure: order:0, mode:=
0x1080020(GFP_ATOMIC), nodemask=3D(null)<br>[&nbsp;&nbsp; 45.073897] CPU: 1=
 PID: 716 Comm: kswapd0 Tainted: P&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; O&nbsp;&nbsp;&nbsp; 4.14.65 #3<br>[&nbsp;&nbsp; 45.0738=
99] Hardware name: Android (Flattened Device Tree)<br>[&nbsp;&nbsp; 45.0739=
01] Backtrace:<br>[&nbsp;&nbsp; 45.073915] [&lt;8020dbec&gt;] (dump_backtra=
ce) from [&lt;8020ded0&gt;] (show_stack+0x18/0x1c)<br>[&nbsp;&nbsp; 45.0739=
20]&nbsp; r6:600f0093 r5:8141bd5c r4:00000000 r3:3abdc664<br>[&nbsp;&nbsp; =
45.073928] [&lt;8020deb8&gt;] (show_stack) from [&lt;80ba5e30&gt;] (dump_st=
ack+0x94/0xa8)<br>[&nbsp;&nbsp; 45.073936] [&lt;80ba5d9c&gt;] (dump_stack) =
from [&lt;80350610&gt;] (warn_alloc+0xe0/0x194)<br>[&nbsp;&nbsp; 45.073940]=
&nbsp; r6:80e090cc r5:00000000 r4:81216588 r3:3abdc664<br>[&nbsp;&nbsp; 45.=
073946] [&lt;80350534&gt;] (warn_alloc) from [&lt;803514e0&gt;] (__alloc_pa=
ges_nodemask+0xd70/0x124c)<br>[&nbsp;&nbsp; 45.073949]&nbsp; r3:00000000 r2=
:80e090cc<br>[&nbsp;&nbsp; 45.073952]&nbsp; r6:00000001 r5:00000000 r4:8121=
696c<br>[&nbsp;&nbsp; 45.073959] [&lt;80350770&gt;] (__alloc_pages_nodemask=
) from [&lt;803a6c20&gt;] (allocate_slab+0x364/0x3e4)<br>[&nbsp;&nbsp; 45.0=
73964]&nbsp; r10:00000080 r9:00000000 r8:01081220 r7:ffffffff r6:00000000 r=
5:01080020<br>[&nbsp;&nbsp; 45.073966]&nbsp; r4:bd00d180<br>[&nbsp;&nbsp; 4=
5.073971] [&lt;803a68bc&gt;] (allocate_slab) from [&lt;803a8c98&gt;] (___sl=
ab_alloc.constprop.6+0x420/0x4b8)<br>[&nbsp;&nbsp; 45.073977]&nbsp; r10:000=
00000 r9:00000000 r8:bd00d180 r7:01080020 r6:81216588 r5:be586360<br>[&nbsp=
;&nbsp; 45.073978]&nbsp; r4:00000000<br>[&nbsp;&nbsp; 45.073984] [&lt;803a8=
878&gt;] (___slab_alloc.constprop.6) from [&lt;803a8d54&gt;] (__slab_alloc.=
constprop.5+0x24/0x2c)<br>[&nbsp;&nbsp; 45.073989]&nbsp; r10:0004e299 r9:bd=
00d180 r8:01080020 r7:8147b954 r6:bd6e5a68 r5:00000000<br>[&nbsp;&nbsp; 45.=
073991]&nbsp; r4:600f0093<br>[&nbsp;&nbsp; 45.073996] [&lt;803a8d30&gt;] (_=
_slab_alloc.constprop.5) from [&lt;803a9058&gt;] (kmem_cache_alloc+0x16c/0x=
2d0)<br>[&nbsp;&nbsp; 45.073999]&nbsp; r4:bd00d180 r3:be586360<br></span><d=
iv id=3D"yui_3_16_0_ym19_1_1553758784255_2732">----------------------------=
---------------------------------------------------------------------------=
----------------------------------------------------</div><div id=3D"yui_3_=
16_0_ym19_1_1553758784255_2733"><br></div><div id=3D"yui_3_16_0_ym19_1_1553=
758784255_2734">Regards,</div><div id=3D"yui_3_16_0_ym19_1_1553758784255_27=
35">Pankaj<br></div></div></div></div></div></div></div></div></div></body>=
</html>
------=_Part_11615234_2052929298.1553758890789--

