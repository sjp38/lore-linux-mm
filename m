Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F338EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 07:42:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B5482173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 07:42:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="hpvK4fzB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B5482173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399B96B0003; Thu, 28 Mar 2019 03:42:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 349C56B0006; Thu, 28 Mar 2019 03:42:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 213896B0007; Thu, 28 Mar 2019 03:42:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4CCD6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 03:42:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e5so15893547pfi.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 00:42:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=Dg+VucJV0wWS2whYNvvsHoPrOk7N0c+siET1Nd3Pblg=;
        b=P21ftP7Kpg9Ua8Jc1rjyG1wW3NvPPMzLwqj8HNU0byamFxOYboKA80dV6ucVqCIWd3
         srZo800/QimfkoFNnpsSiAHUM1E4ACCSK9PDo0RrQZAabrGWsequMfkE2RxTyQBTTORz
         svwRgVyRhhn+wr7GN8Ne9cf2QvGXt28YJ/Ouh8kniocqxR8QR4f+2or3N+jNqs0Xz9bb
         PiGMu4ivC3fRkHlSw8mXR40Slx5lKV1+9ruPC6459suHgIZBimS/LDMlhQVgqEw1czjV
         4Z1YHqo2lkU1sS/QzXOuJ5SV9trjm0Kdb6d4pbyUnGD5QikmjLzhaNmjPPqNVoUnjjZ9
         btgA==
X-Gm-Message-State: APjAAAVwQAwMbeJIh82jctuaVdlYcUrJtLzA+Wwz5M3EE2/NhckBqpfy
	IceNAq6cxAnEKMFqXBfFnoXEfISBTux93TKamoPLy2JfN4YZVcRdtL+1UJWd9XREMICDC4lePNm
	SATWfdnqIOzTmdDrt9t/Pwxlc29XS9++5aO5FNhKNyY8p6Z6hc+w9k13dhRoXhHRvUg==
X-Received: by 2002:a63:c10b:: with SMTP id w11mr38994168pgf.39.1553758974468;
        Thu, 28 Mar 2019 00:42:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNRFq2GmPP3ngI/zpZ8A8uwnHBxboaB0FWZznCoyYE9da91GjWmCjgiaEXJKnbtrq4MbMK
X-Received: by 2002:a63:c10b:: with SMTP id w11mr38994131pgf.39.1553758973687;
        Thu, 28 Mar 2019 00:42:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553758973; cv=none;
        d=google.com; s=arc-20160816;
        b=FxZQ7Ol4fcWTrZC7cF+Sg1FcKazv70ylUYhPYnru8EGDNOKGiRAixi0lXuxSYmknf1
         GzKtA/WACjJynze29pUX+NyJbuMWixprHd42y7xuv/pl7f9O+IsPL4VNhPOddRJfZyze
         /odHn1IKF8/hsti+57fi4WvL90iYti/tGiZXqAy0YFlORt+SbvUlc3EY2KXCC4wj1gbU
         oF6HJMJMm4FtY8Ri82IwtgDo8umVgIBO8r8P+XjxwcBM/lvqs1GEKGQ6tjE4fa4NXKQk
         VUBYnLuBetPHXKGutzttVJABLqDh7j9QQrCWwi1aAkLD9G58BXFwzZ1/7qXXdxnEj8PN
         F6wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=Dg+VucJV0wWS2whYNvvsHoPrOk7N0c+siET1Nd3Pblg=;
        b=m94Pvao4W4rkVH/o6nL0NlSAqnHfuW9NUUKokO2Dg6CfpJPzh285IOnEdr/14T8MzE
         ryhWU+UTAA2HpW2m15281CQh4drZaKReGE4+3je1vOzKcIImSqhUhavqGpJ4YU2+7vQK
         PF9LBJGQpCH7fZQh52ZoN8U7RF280GPROTM49ofop3sPyf5OrMuA/Q43spwpuY3dDHoH
         wl5+htRFRBZcwcKnKXmit5XJPlsOql+TI7XDc4nsKOgtWd2QaXYI+5ycCwTTuUAV62o4
         Yc3U6PPaHW2nNSzqbOHWITMsN7GACrJ1JmTF5sDi2URrGu8w+ncIXSwJxP3mrr7bfdHl
         u8LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=hpvK4fzB;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.55 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320055.outbound.protection.outlook.com. [40.107.132.55])
        by mx.google.com with ESMTPS id p15si6134544pli.414.2019.03.28.00.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 00:42:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.55 as permitted sender) client-ip=40.107.132.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=hpvK4fzB;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.55 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Dg+VucJV0wWS2whYNvvsHoPrOk7N0c+siET1Nd3Pblg=;
 b=hpvK4fzBVJuCgOGw7mPPidsr16Uu8eqBte70WAT78kEwWUhKlU547hhPWuzFC85hgody1ZDjtFpVGuRlm7PouvPMBQg0zUCTbfHmIozgzKlxf+rRvZ7R91YQoZxjWLyeOekv0ZpI/6VnAPCANKqChTepD60/tvr+2Z6YwqXOJrY=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB2715.apcprd02.prod.outlook.com (20.177.86.203) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Thu, 28 Mar 2019 07:42:50 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Thu, 28 Mar 2019
 07:42:50 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Page-allocation-failure
Thread-Topic: Page-allocation-failure
Thread-Index: AQHU5TnT8N2n2QVx4UqTmvmwHUsWlA==
Date: Thu, 28 Mar 2019 07:42:50 +0000
Message-ID:
 <SG2PR02MB30984D7E43467F178C6EF7A2E8590@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0e9d2f5e-8fcd-4fca-eba2-08d6b350faf3
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB2715;
x-ms-traffictypediagnostic: SG2PR02MB2715:|SG2PR02MB2715:
x-microsoft-antispam-prvs:
 <SG2PR02MB271594FCA0C39BE633A5ED43E8590@SG2PR02MB2715.apcprd02.prod.outlook.com>
x-forefront-prvs: 0990C54589
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39850400004)(396003)(376002)(136003)(346002)(199004)(189003)(81156014)(81166006)(102836004)(8676002)(2501003)(53936002)(2906002)(476003)(52536014)(106356001)(6436002)(86362001)(7736002)(486006)(78486014)(305945005)(3480700005)(97736004)(99286004)(74316002)(44832011)(105586002)(316002)(6116002)(3846002)(33656002)(186003)(26005)(66066001)(14454004)(71190400001)(5024004)(25786009)(66574012)(110136005)(5660300002)(8936002)(55016002)(7696005)(478600001)(6506007)(9686003)(68736007)(55236004)(14444005)(71200400001)(256004);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB2715;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 rjajeezr7AjW+C4AYvToFB3w3BhEREjmpkskl+4XGtExrkU6TuT5uPB3qAGKc47XxUGCvHAMPkAZV6PNN8a0tOWfIoZacu9EWreI+idDVTXxjAXpqOeqUTyCv/42V/j3SNYSZyYJdHNdZbKZf6FoscmHlJPEgeenBER9Yrpkd6F2qwXmPVyE+8c92LWh8Ay+MHY9FwNz8TOiYe2BFGRBFtujfIlmEJ+6tXGcwtavw/QC+QS1dTdzYxl1a5aPS/I+0HAZqNn6iZYCKDl5sXpUTkhdB3h91rfHjJRyJYBogUfMqinBgmblTND6ix04zN1QNtjAx3zgFmUaAnkoVHBnvikT6ChpBvx79UIIy0LgBCLSiANqzD/MVV0Qy7Y8qggfMmDthZtJvifVo9Up+EgeJ2FLsNUG9cLJ9qdVGc9fR2Y=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0e9d2f5e-8fcd-4fca-eba2-08d6b350faf3
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Mar 2019 07:42:50.7858
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB2715
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello ,

I am facing issue related to page allocation failure.

If anyone is familiar with this issue, let me know what is the issue?
How to solved/debug it.

Failure logs -:

---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
---
[   45.073877] kswapd0: page allocation failure: order:0, mode:0x1080020(GF=
P_ATOMIC), nodemask=3D(null)
[   45.073897] CPU: 1 PID: 716 Comm: kswapd0 Tainted: P           O    4.14=
.65 #3
[   45.073899] Hardware name: Android (Flattened Device Tree)
[   45.073901] Backtrace:
[   45.073915] [<8020dbec>] (dump_backtrace) from [<8020ded0>] (show_stack+=
0x18/0x1c)
[   45.073920]  r6:600f0093 r5:8141bd5c r4:00000000 r3:3abdc664
[   45.073928] [<8020deb8>] (show_stack) from [<80ba5e30>] (dump_stack+0x94=
/0xa8)
[   45.073936] [<80ba5d9c>] (dump_stack) from [<80350610>] (warn_alloc+0xe0=
/0x194)
[   45.073940]  r6:80e090cc r5:00000000 r4:81216588 r3:3abdc664
[   45.073946] [<80350534>] (warn_alloc) from [<803514e0>] (__alloc_pages_n=
odemask+0xd70/0x124c)
[   45.073949]  r3:00000000 r2:80e090cc
[   45.073952]  r6:00000001 r5:00000000 r4:8121696c
[   45.073959] [<80350770>] (__alloc_pages_nodemask) from [<803a6c20>] (all=
ocate_slab+0x364/0x3e4)
[   45.073964]  r10:00000080 r9:00000000 r8:01081220 r7:ffffffff r6:0000000=
0 r5:01080020
[   45.073966]  r4:bd00d180
[   45.073971] [<803a68bc>] (allocate_slab) from [<803a8c98>] (___slab_allo=
c.constprop.6+0x420/0x4b8)
[   45.073977]  r10:00000000 r9:00000000 r8:bd00d180 r7:01080020 r6:8121658=
8 r5:be586360
[   45.073978]  r4:00000000
[   45.073984] [<803a8878>] (___slab_alloc.constprop.6) from [<803a8d54>] (=
__slab_alloc.constprop.5+0x24/0x2c)
[   45.073989]  r10:0004e299 r9:bd00d180 r8:01080020 r7:8147b954 r6:bd6e5a6=
8 r5:00000000
[   45.073991]  r4:600f0093
[   45.073996] [<803a8d30>] (__slab_alloc.constprop.5) from [<803a9058>] (k=
mem_cache_alloc+0x16c/0x2d0)
[   45.073999]  r4:bd00d180 r3:be586360
---------------------------------------------------------------------------=
---------------------------------------------------------------------------=
-----

Regards,
Pankaj
***************************************************************************=
***************************************************************************=
******* eInfochips Business Disclaimer: This e-mail message and all attachm=
ents transmitted with it are intended solely for the use of the addressee a=
nd may contain legally privileged and confidential information. If the read=
er of this message is not the intended recipient, or an employee or agent r=
esponsible for delivering this message to the intended recipient, you are h=
ereby notified that any dissemination, distribution, copying, or other use =
of this message or its attachments is strictly prohibited. If you have rece=
ived this message in error, please notify the sender immediately by replyin=
g to this message and please delete it from your computer. Any views expres=
sed in this message are those of the individual sender unless otherwise sta=
ted. Company has taken enough precautions to prevent the spread of viruses.=
 However the company accepts no liability for any damage caused by any viru=
s transmitted by this email. **********************************************=
***************************************************************************=
************************************

