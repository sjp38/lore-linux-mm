Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9E1DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 05:42:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 650F221773
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 05:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="FCliAyXZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 650F221773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDF8E6B0007; Fri, 29 Mar 2019 01:42:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D90256B0008; Fri, 29 Mar 2019 01:42:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2F896B000C; Fri, 29 Mar 2019 01:42:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85DD36B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:42:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i23so753753pfa.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:42:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=qqaMuUXOQnUbaJUSlGOoW+SpHQyfrAdRMA0bz+bYUck=;
        b=X6y4Snog9ivAbhlZkKnzWSCGGCe9RTH+4rqpozrtvLhaXOZa7mhOZ4f6KQJngO8fFz
         CjYg9H1lJuJZios/lfwx3SvFB7uLCdTQbatVkZrl6E1nYtJ5O6T6kK1rit1bWzEkoze0
         535Y9LqRNfD+I7LcACi3KpOFYCXzkIYqI46nVU9lMTJ1WkEyHKeWl8XGguBMEiP8Z1xM
         XYu3ZpKFuPsm+VqklEQ6rNyCPDZ+5t0VCEwuvIwNdfAPpJ7jDdpYwkZrrfwSMFMpBUwI
         YIBBGqbtX+CcL0Hg3yv738laxP6XvWp4lSNkWK8GpF6Dp6QkrDFsrmA1ingLdbJTpmab
         9KOQ==
X-Gm-Message-State: APjAAAX60s/wQwPL8L9PQ7T1ujYY752qLOqErK5K5IXdUTcPQcHcj9bD
	ZnrjtlIhxQ22Ynu/LASE+Y6Jey/THxYm7Cq6iSMTCkgvioordZcG+YIZA/XRZrNu9wxa/d7zUE9
	xnPDb3ANwMhsS0wvtFWdq6wQugVi7rl70cqgs7V+Mn+94vHw74+RDeZ19bmBnLO15hg==
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr47126040pln.117.1553838136075;
        Thu, 28 Mar 2019 22:42:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwneYhTWnntvZwNHp0ooJChxshw+C8yjOUim0ApQytLBPCB9d3lFpa29kljIWLmimupBNf+
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr47126000pln.117.1553838135261;
        Thu, 28 Mar 2019 22:42:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553838135; cv=none;
        d=google.com; s=arc-20160816;
        b=RJegwr/Vkzg9L52mT/I46l3lL8u5Ejmrg7u0yX1oZTuT1/ftODBJydyv2Vzmlqnjpj
         bL+9bKCRvrMZo3k7PXXZh5/NNb2pHTvQao+gaOKPfPSiO+T8q3A4n2udr1nhPF/sPbIY
         UW0YN1AM5q+S/e5AC6+amdD+9Y4ZFvKU8apCefoCG/I9Bp2A2Mo+as5rIhjv+FbK+QO6
         LaW4ryoHoVfY2Dv0TJio7aMEYxxUsGUGW4xVbbbZBpIoyLUSkP2c8UJY6FTLT5JZsr6H
         mixriDw+yGHeNDMOTVGs8cXjAIIN9Vda71DGqmapjNsumaKufIp15eZ+GpxRZrtFF2bx
         6szQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:to:from:dkim-signature;
        bh=qqaMuUXOQnUbaJUSlGOoW+SpHQyfrAdRMA0bz+bYUck=;
        b=JpeK+JEq0I+C3mGpAAxtgBW03JJyhBacq7GJVjhysgBru4sGlHU7+pV54kdwobn2cA
         RKmMdQy++sL3zE3Nz4Y1mhL7Ur+6canCcXorEQO4/mKEHDoumG1c1BtZk9J+9f35lKBA
         vHkkB6eJzdTZBCBZdkP6LFUavBQ3rs1NI4Cz+mfoZBURNOeIEKmTsleTr82vHN/peSmq
         E+o3eQuYUnoaVO29/F4MIobItDwfY30ObYKgiwpIE9Z9IZzZjbyKwiPfjr+2GXnyXvCR
         FuTnBu6U0Z0LAKgS5Qsjyb0ajPNGsZggebUCKcLrSLTL+CVrIkdu3OrAfiAZBbdO7JGJ
         nk+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=FCliAyXZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320053.outbound.protection.outlook.com. [40.107.132.53])
        by mx.google.com with ESMTPS id 91si1116696ple.299.2019.03.28.22.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 22:42:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.53 as permitted sender) client-ip=40.107.132.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=FCliAyXZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qqaMuUXOQnUbaJUSlGOoW+SpHQyfrAdRMA0bz+bYUck=;
 b=FCliAyXZ7bB22dRhP5aB31ORAbu2y0bifYNFQ7Y88hlfEDrVZ1+aGj6YFHebTWEfV6ebhoNHXEEIPdmzcVa0hAWTaDIEKf0qh8wQHFNzwJYB3UYF/tQGeDBdHHVep7iRgiWwLpvJ0kyPezLKf/SwdoC1AEVzZml/9k+WHscZ2HY=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3483.apcprd02.prod.outlook.com (20.177.83.211) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Fri, 29 Mar 2019 05:42:11 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Fri, 29 Mar 2019
 05:42:11 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Page-allocation-failure
Thread-Topic: Page-allocation-failure
Thread-Index: AQHU5TnT8N2n2QVx4UqTmvmwHUsWlKYgqix9gAFuUpM=
Date: Fri, 29 Mar 2019 05:42:11 +0000
Message-ID:
 <SG2PR02MB3098DCA9FE80FFF40B469E1FE85A0@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB30984D7E43467F178C6EF7A2E8590@SG2PR02MB3098.apcprd02.prod.outlook.com>,<SG2PR02MB3098F5EECE82FD5352E47184E8590@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB3098F5EECE82FD5352E47184E8590@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8958369b-f79c-4f76-d65e-08d6b4094a2d
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3483;
x-ms-traffictypediagnostic: SG2PR02MB3483:|SG2PR02MB3483:
x-microsoft-antispam-prvs:
 <SG2PR02MB3483ADB19BF44A54A268AD20E85A0@SG2PR02MB3483.apcprd02.prod.outlook.com>
x-forefront-prvs: 0991CAB7B3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(366004)(39840400004)(136003)(396003)(376002)(199004)(189003)(105586002)(71190400001)(26005)(14444005)(5024004)(55016002)(256004)(78486014)(3480700005)(9686003)(2501003)(2906002)(110136005)(71200400001)(229853002)(53936002)(486006)(476003)(3846002)(25786009)(6436002)(11346002)(446003)(6116002)(86362001)(186003)(52536014)(76176011)(8936002)(53546011)(55236004)(6506007)(81156014)(81166006)(8676002)(44832011)(97736004)(66574012)(99286004)(14454004)(66066001)(102836004)(33656002)(5660300002)(7696005)(7736002)(305945005)(316002)(478600001)(6246003)(74316002)(68736007)(106356001)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3483;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 4TdIPieUITNsmLlcSCC77A39FfXYknMD1RT5+KMeuDBPzKuldHNJL54VkjK8Pn5X1NZ3WXi0BfKiU315S44vUtU7O3Qmnv4+yCBo+SDcOBMNuqXk86Oo04qw9gnn5tXUoW4LxEqfRUSmBQQXSKMbHVAAQpQNktEAZQVwDkbezTXnKZcB1KaWLclzmhMPYEHNekctLFmOvohYQ+jTiFpW2tmtCh41+U1bQSUS2KE91OevG4Exd/wOg8GGakUYsJBfna9CtJ91c9LBbJYf2k0pWlXkv/HTr357kY7fLDiXrN1KfGrfSmaMD1ylMfrkqm6rAwRxjycIBqwVETHh/Uh8YWxMEsuqYW3B6HzdzFuWBJrdvYqD4d5ipuluQDUUYR7f0B0WcHqkVBiQvt3gtuytDmOsVSX7Y9Yy1SjhYYmSGyI=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8958369b-f79c-4f76-d65e-08d6b4094a2d
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Mar 2019 05:42:11.1266
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3483
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Pankaj Suryawanshi
Sent: 28 March 2019 13:17
To: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: Page-allocation-failure


________________________________________
From: Pankaj Suryawanshi
Sent: 28 March 2019 13:12
To: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Page-allocation-failure

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


[   44.966861] Mem-Info:
[   44.966872] active_anon:106078 inactive_anon:142 isolated_anon:0
[   44.966872]  active_file:39117 inactive_file:34254 isolated_file:101
[   44.966872]  unevictable:597 dirty:157 writeback:0 unstable:0
[   44.966872]  slab_reclaimable:4967 slab_unreclaimable:9288
[   44.966872]  mapped:60971 shmem:185 pagetables:5905 bounce:0
[   44.966872]  free:2363 free_pcp:334 free_cma:0
[   44.966879] Node 0 active_anon:424312kB inactive_anon:568kB active_file:=
156468kB inactive_file:137016kB unevictable:2388kB isolated(anon):0kB isola=
ted(file):404kB mapped:243884kB dirty:628kB writeback:0kB shmem:740kB write=
back_tmp:0kB unstable:0kB all_unreclaimable? no
[   44.966889] DMA free:9348kB min:3772kB low:15684kB high:16624kB active_a=
non:420592kB inactive_anon:284kB active_file:155116kB inactive_file:135724k=
B unevictable:1592kB writepending:628kB present:928768kB managed:892508kB m=
locked:1592kB kernel_stack:9304kB pagetables:23440kB bounce:0kB free_pcp:13=
36kB local_pcp:672kB free_cma:0kB
[   44.966890] lowmem_reserve[]: 0 0 8 8
[   44.966903] HighMem free:104kB min:128kB low:236kB high:244kB active_ano=
n:2632kB inactive_anon:284kB active_file:1912kB inactive_file:1732kB unevic=
table:796kB writepending:0kB present:1056768kB managed:8192kB mlocked:796kB=
 kernel_stack:0kB pagetables:180kB bounce:0kB free_pcp:0kB local_pcp:0kB fr=
ee_cma:0kB
[   44.966904] lowmem_reserve[]: 0 0 0 0
[   44.966909] DMA: 148*4kB (UMH) 52*8kB (UMH) 30*16kB (UMH) 19*32kB (MH) 7=
*64kB (MH) 4*128kB (H) 5*256kB (H) 0*512kB 0*1024kB 1*2048kB (H) 1*4096kB (=
H) 0*8192kB 0*16384kB =3D 10480kB
[   44.966936] HighMem: 2*4kB (UM) 2*8kB (UM) 1*16kB (U) 0*32kB 1*64kB (U) =
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB =3D 1=
04kB
[   44.966958] 74134 total pagecache pages
[   44.966961] 0 pages in swap cache
[   44.966963] Swap cache stats: add 0, delete 0, find 0/0
[   44.966965] Free swap  =3D 0kB
[   44.966966] Total swap =3D 0kB
[   44.966967] 496384 pages RAM
[   44.966969] 264192 pages HighMem/MovableOnly
[   44.966972] 271209 pages reserved
[   44.966975] 262144 pages cma reserved

/proc/sys/vm/min_free_kbytes =3D 3774
Can increasing this value will solved this issue ?

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

