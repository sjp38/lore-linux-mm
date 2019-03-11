Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC598C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31E7C2075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="hwV4GC5S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31E7C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A862B8E000C; Mon, 11 Mar 2019 08:21:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A37F78E0002; Mon, 11 Mar 2019 08:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926158E000C; Mon, 11 Mar 2019 08:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEF18E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:21:09 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t190so638910wmt.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=oZxeVsP88EDa5tTFZGWkUZL6SMNS5qnzeBxJN4yAP5U=;
        b=jVsYAsxnrC8RfZgu0jaVuXuAR9mCHjHWEGSYQTyGGwuYGUh5nwOVlE3LzM6NObn649
         BWa2yEgHzzY1Z/oOu/oW6rlrd3PYyyTPoQRQ49ZSpiM+yXfBmGhmvJAVlgoEpAuCw0Mh
         Ef/4xaSbvR4yVGOrChuHcYMRKVQKknDHZoZo9015yMDSfECEqkvUTM6EtB+PoNAfWknE
         rlgzqi13sKuOQGsB/SRxPzSH3idLIhyd7m0HJ/Flwc1KxerygxAjcGU0vQ2jralwsMiY
         0MDJRK7O8or23Bu22ZiDapY4aGByAKvBTunNWFNC4JKdss/so7W9US8stteF3w8yfNiW
         89qg==
X-Gm-Message-State: APjAAAVJoc+9zIesfNYFEYhn8ZXrVqExHmZ271Oz4BQfT/o9DYcYCmZc
	LkSQXjiFTJXQ6LJHgRIEWFL6Vm+4lQAluLSnCPiI+cm1C4/Kyv+55GDcsWOeoUK7GFXbYTk/lfO
	7Ic1Xsg1BApaG0tp8RpCYvBfL46AWcVVX6sST+sZdnjThHrOhOxtBS4YqvUvEi0jwZQ==
X-Received: by 2002:adf:cd87:: with SMTP id q7mr21254453wrj.92.1552306868645;
        Mon, 11 Mar 2019 05:21:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUhlluV/7Y+aH7n8L7FbcC8wHFts8/aLSSBp2K4b5B4z3JeB3xGsYi5ZC+rVD1ocqFocHF
X-Received: by 2002:adf:cd87:: with SMTP id q7mr21254392wrj.92.1552306867482;
        Mon, 11 Mar 2019 05:21:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552306867; cv=none;
        d=google.com; s=arc-20160816;
        b=rvWkYW99fAcm8DjoK1nCe9JT/EkmVem7EpvzZ1zimZhhLg2SJ+/B5EP2pc4DXeCRBj
         UHJwjInkge1yzgdi9YPt5DE4y8nm8xpgTIZHPvTRQbDlNnGxiAWytXbgJTN9tV2lZJel
         I6PiaVT9HxBVlUIdLNq2SjpNmKC29KtAbTH/Lv66TnkbANKowCftYcMAIlY+LeKQyNOA
         qp9oStw7TuJInaPdgAMvhtFvfDZp5iWLSq323DtnIyElvGtyxBGSQG4FxCE3mgpIC86D
         VYcJsYVqsqCwT4Ww65oxiM6XEre3scUsDMw8y0TrkxKPxGgC5iQbSSO7PiXckkRoyGcb
         L0LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:to:from:dkim-signature;
        bh=oZxeVsP88EDa5tTFZGWkUZL6SMNS5qnzeBxJN4yAP5U=;
        b=bEugSeihVj8Sg5BbYxvJyuVZG54Vx5Lm7sWxrkZJG7dCspUygxr3YtzaueLm/13QW8
         /7Ry/UTJnb6ezgvHmN7LcpjsVeEGhWMbozpECHrEtBHw1iGoQ9HWLyAYajOK1NHPf6aS
         tWIZqIbwF2TT4vocEx5JB5eCGhBwjsJvI2NldINgo2UjfVosaUu1D65GfS4L06RARflj
         ENm+4/72r23G/S0bA7NmaHa/CSWKpxeCGFjsfm1ErtpA0GUowibU/2JgK5RFlwB5VMWy
         RCV7fn6qGf/ZDZ/cH2CskCJEMCOy7z8fzJG/JKBtPjL6lrd07OKsklHvZehcTv2mAUNu
         cwPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=hwV4GC5S;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.55 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70055.outbound.protection.outlook.com. [40.107.7.55])
        by mx.google.com with ESMTPS id h7si3205910wru.58.2019.03.11.05.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 05:21:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.55 as permitted sender) client-ip=40.107.7.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=hwV4GC5S;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.55 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oZxeVsP88EDa5tTFZGWkUZL6SMNS5qnzeBxJN4yAP5U=;
 b=hwV4GC5Scv+/hH7H0vP8K4s7M7j3FKlYht+qXytQ8Qs/d+JRb42njxM92mST+JNE8MsTAKYscvqvtFmfkTSryQlXR45GjUMyDV6Tnue/b58OJPmcrlesAjfEkYGSq7/zT2WnT3cI3qVGofRJ4V86281EcqYud8l6eOfwDYL6Fbg=
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com (20.179.44.81) by
 DBBPR05MB6297.eurprd05.prod.outlook.com (20.179.40.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.19; Mon, 11 Mar 2019 12:21:05 +0000
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f]) by DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 12:21:05 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Qian Cai <cai@lca.pw>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Thread-Topic: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Thread-Index: AQHU129qkdpyS6s9ikO3HiiIZ0g4PKYFzm+AgACMeAA=
Date: Mon, 11 Mar 2019 12:21:05 +0000
Message-ID: <20190311122100.GF22862@mellanox.com>
References: <20190310183051.87303-1-cai@lca.pw>
 <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
In-Reply-To: <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0045.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::22) To DBBPR05MB6570.eurprd05.prod.outlook.com
 (2603:10a6:10:d1::17)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [24.137.65.181]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b2be0e62-1792-46b8-83f9-08d6a61c0885
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6297;
x-ms-traffictypediagnostic: DBBPR05MB6297:
x-microsoft-exchange-diagnostics:
 =?us-ascii?Q?1;DBBPR05MB6297;23:P7xtHHClqt/GURYNk801RMY3na87eOmiGEzkdXw0t?=
 =?us-ascii?Q?uP8Z+jzqUyzexocaV2u3jZRvIdUGajYf6HZByDCSSpd6coRVeP078dKbfw6v?=
 =?us-ascii?Q?3wcxre1191tqqknZxGB5or8N0JNG+S/jGqHQ+jMSGo8Xdp0FqsgpZ+5B+3D7?=
 =?us-ascii?Q?zNje7eQZOF7HeRV72ORwazxkyZM0IfRdwxb3guTEACqrn2Nl9opV208LxX2/?=
 =?us-ascii?Q?Y8y9145icm1PgxJ33a5ZuvRqwOhHqSoP0fFlfsNcqtVeVJ0pRt4h35EvW3XY?=
 =?us-ascii?Q?Dyc7fLpTBrxmNSeUUr7abtyXTGxqfzAmoeYf0A+uflDkLXqFZzv00rTn6sq5?=
 =?us-ascii?Q?5OIxrPj37SLou4h8e26D7/dYlDdYDMxUTvTcjrCRPvQ6cq5Uc9ZXh5rNOV6B?=
 =?us-ascii?Q?67cRKQa30Bn4uv7AaVbX8EcdoDppcMNFEx+XA+l9zKcFUB9WMmghzt8iSZz7?=
 =?us-ascii?Q?zxjzQdySCasO7jMLkkrDtDN/dEaO0dxWI6cWU4a2t17X7H0EP+j4Dqzg+3Ua?=
 =?us-ascii?Q?klI9X+JWMFnIbuomS3I815SNG9Ile79hGhED/GtaVy/7Kdu5j0tYDsgbckaU?=
 =?us-ascii?Q?gLj4e3Ts386YjkLoyBlKf7ht1ae93nm9jh/6Myan67QQVdtNzMpBD9nHNPYY?=
 =?us-ascii?Q?H2w8gth8Iy6d2NSdaLHctuRqn2RbEGqi6/WboDaWtAUmpIDfdiFFahKI2QNe?=
 =?us-ascii?Q?42av1Sbe67ixAHAmdy8HU8FlxfduLmk96kjpABgIJj+lIleN32vbS+x13YHk?=
 =?us-ascii?Q?cr3uy/QqkhWZ9+4Lns7vX13ubdFHpEe+8AKxxV51E6jO9Akrs61vGdCL2uU0?=
 =?us-ascii?Q?kgaJWwngis6/Xu7xdt8eA3WYzTJrtcWsmToelRJrbDe/egzE0XHdErfeWQAK?=
 =?us-ascii?Q?Nm463adNRIG3rGlVEtRNjfa68KhqJsoPtXeHXuZw5yzuVY25wwOF+sCMBcM5?=
 =?us-ascii?Q?RGACAmswddF6HnzmRFt5dGOya1AY+5HXoVM8UnE9PCSxtZql3KIxDBpv7h+V?=
 =?us-ascii?Q?fCyiolniawCe414RgCJSH5cnltLieqiPdxofgxf99r1Q/dbfJu7qx40hzsMD?=
 =?us-ascii?Q?XMTJHDB4GovdtkeIEI7ZZwuCU/Lu3U5neh39AdUzrCtyfjCCrwR+/YjKLh90?=
 =?us-ascii?Q?GP/sJK7joBnVWty3CgKETYNlCWSxze1jeB7a4XXFTwAHiZvHu39nrb89DJZs?=
 =?us-ascii?Q?DR2ucy+aXGz3vQbhBettUK5XUoqhF4v+IQB9Ipvwsvv/I3Q9RVE4/zM4zGMw?=
 =?us-ascii?Q?bZQ3uO70XmnytjdNJtWuhvdtJEj7U5NqhhFRmqAkt3GDOvSgaBNSNL/BrkNg?=
 =?us-ascii?B?UT09?=
x-microsoft-antispam-prvs:
 <DBBPR05MB6297EEE29F45807BFDE934B6CF480@DBBPR05MB6297.eurprd05.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(136003)(346002)(39860400002)(366004)(396003)(189003)(199004)(5660300002)(478600001)(6486002)(36756003)(6436002)(68736007)(486006)(8936002)(1076003)(6506007)(186003)(6512007)(99286004)(2906002)(105586002)(71190400001)(106356001)(2501003)(110136005)(8676002)(2616005)(6246003)(316002)(6116002)(66066001)(71200400001)(86362001)(76176011)(6346003)(52116002)(11346002)(3846002)(476003)(386003)(33656002)(7736002)(14444005)(305945005)(256004)(26005)(102836004)(97736004)(81166006)(25786009)(14454004)(2201001)(446003)(53936002)(81156014)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6297;H:DBBPR05MB6570.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sp9gzXRPK1KsVsaILHbhwfGN5eRzAIjeLVTM0rwJdjdG5O8TM+rXf0kMRwsNL8MWh2oZc6ZSEsiGX+TEbmnsicQJWWaRDIwTOb8/9OLoXygcycrpSeDlLmA42YyBUiVo6+N7cmG+5VdkMthBO+LgmmfSTtC0GLgSu76ZSYD0v7iorFKx5nAcUcf0TqHiG79Rv2LRHUJtTOZzEoWpg9DQQTm1ZQHAb55VYUtpmoL30djzpJwfhazA08SFmtyne8cGsDryT7MBlKPo+Y1EteMLjMJYUSWIPWlliT2ohsnh7rtYh8TD644mbLLDf0cwwQnkbNnbc6HWhGQIdqQpkRWBl/erUTeCHN368A1olkBN5VHcgCPGl2ojg//p02QCOsojuhoW0c5qEGumK951Vp0m9EgB1Rr+n6yx7iJfla1pWSE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6E5A9794289BF749B57BA2804F2A7859@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b2be0e62-1792-46b8-83f9-08d6a61c0885
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 12:21:05.3928
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6297
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> On Sun, 10 Mar 2019, Qian Cai wrote:
>=20
> > atomic64_read() on ppc64le returns "long int", so fix the same way as
> > the commit d549f545e690 ("drm/virtio: use %llu format string form
> > atomic64_t") by adding a cast to u64, which makes it work on all arches=
.
> >=20
> > In file included from ./include/linux/printk.h:7,
> >                 from ./include/linux/kernel.h:15,
> >                 from mm/debug.c:9:
> > mm/debug.c: In function 'dump_mm':
> > ./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
> > argument of type 'long long unsigned int', but argument 19 has type
> > 'long int' [-Wformat=3D]
> > #define KERN_SOH "\001"  /* ASCII Start Of Header */
> >                  ^~~~~~
> > ./include/linux/kern_levels.h:8:20: note: in expansion of macro
> > 'KERN_SOH'
> > #define KERN_EMERG KERN_SOH "0" /* system is unusable */
> >                    ^~~~~~~~
> > ./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG=
'
> >  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
> >         ^~~~~~~~~~
> > mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
> >  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
> >  ^~~~~~~~
> > mm/debug.c:140:17: note: format string is defined here
> >   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
> >              ~~~^
> >              %lx
> >=20
> > Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
> > Signed-off-by: Qian Cai <cai@lca.pw>
>=20
> Acked-by: Davidlohr Bueso <dbueso@suse.de>

Not saying this patch shouldn't go ahead..

But is there a special reason the atomic64*'s on ppc don't use the u64
type like other archs? Seems like a better thing to fix than adding
casts all over the place.

Jason

