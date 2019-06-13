Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792CCC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:10:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A83F20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:10:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="puGmflYj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A83F20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FB318E0002; Thu, 13 Jun 2019 19:10:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AC566B0266; Thu, 13 Jun 2019 19:10:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874898E0002; Thu, 13 Jun 2019 19:10:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36B386B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:10:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so911560eds.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:10:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=739c5jQXQ0DYsV5q9yGUEJ3j5bapmAiM/he/yV381G8=;
        b=bYyA7qbkImikABD9pqKdf5BCbl9PbqMDzYETWYtOPlfxEQZDok7QqAbRORTxSoEJTX
         eXYYWLvN8xJJavvaLJkdlh88O9SBsdZgWb9wuksYmeRDJH5Yi0Cr3Rrm2xhHa1c1hoPy
         nm2jFU42PIbVe8X7JN6kW610S2B8EBFAuC/Jwk6WPMEGq2PfmDouUJPAkgBiyL5xo+0E
         2pbxA1uFdRTwzN0D1IzqXn/01Lga10+t8HFdJcaY1LvGE3hEEiJ4PWJ8dnLUhSMB38iU
         lSQuVfnEzZ8HoyoNozIQisQP6U1JtWI+Du105d6DbLjzp92w0++sBwt9/SapTEoDEZ3W
         fnRg==
X-Gm-Message-State: APjAAAUVOCotzMUbPi98+Hhshl/re3GgV11h7ePVU8Ir7mEeGjDb3JXq
	Oqul/trMNZvNye4wpAT540Z7t1QpTlNE3twHmE7AnhNsZX5639StSriW6blu34QUc9ZC2euETZR
	9TOCwuyFeqxvpoRKgWDtLRAy+F2JUiXx8Jk27ne1DUYA4KoZa0kxUk/QRfJVNU3LgAQ==
X-Received: by 2002:a50:a942:: with SMTP id m2mr46614998edc.73.1560467449802;
        Thu, 13 Jun 2019 16:10:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztAUbEoopPA1bpRQRdq+SkcpEF3G8pUjtIWk5pCz9tBNRnppcwArtNdKl0XTmb6lQ7Ssx8
X-Received: by 2002:a50:a942:: with SMTP id m2mr46614941edc.73.1560467448850;
        Thu, 13 Jun 2019 16:10:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560467448; cv=none;
        d=google.com; s=arc-20160816;
        b=nuFLw1rOWNLOJja4LKfD9BAx+m4rfK2W47G2Sbe0wBFnutfdVuHR/W0FeSb7sEzkBX
         feWWZ2fdWKYnXSv5SnhyDJXhKFgeNc00okZTPoBEZ8ELUmPC3x3c1Xd4EH9cWMH7p/nh
         8Op/J7XGUVxjPv6iUVwjkS+VioW+CrjxMjJ14QUTl+6b/DwpB/o7qgk/K/yVlA3ogVAl
         +Alk+5L8vjYWycGGaqJCMe47fh7FOJ3q5YYAN3SPS4eUnjOBAF38B+UWk+nkjM36jq5C
         aFQSsBRQuk8q/xBM0nRp0NowR4A4jnjxbCMmArHXkS3ejl3Clhll7eA7tvFhmNQ1aR3q
         S7UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=739c5jQXQ0DYsV5q9yGUEJ3j5bapmAiM/he/yV381G8=;
        b=HVIRB/95LR0J7Hva0djdDrx3ClYUOfDCQJW3eGkpdshqgdpY4ytd2QUqYDR1k7oy3R
         WBfdXPSkTLmCaoSx1F7gKw2pSiHfVGW8WOQ1ZWpgJ7rE4nVCKRoMUqHvS8F30lkhsbTy
         kA/HRPdOc8baD+7s+qnb/77P6woaXQdiEVTcZdP9YJJl6g56LYRt2+FNVTaufg4Z5xh4
         hs/Pu2L5F5ZU9TaekmzE7Je4OQ+wNU0Y73Pa+1xpbzjSg/O92h1GPoCaxM59PeJLMNcF
         Wunex2fwspVmAinMLxozCdJc7NoyeNudtdtGBDZFQ8pEgjfLzx1YNyGfW2qlen9eFWPU
         PRRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=puGmflYj;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.70 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30070.outbound.protection.outlook.com. [40.107.3.70])
        by mx.google.com with ESMTPS id b7si899759ejb.160.2019.06.13.16.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:10:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.70 as permitted sender) client-ip=40.107.3.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=puGmflYj;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.70 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=739c5jQXQ0DYsV5q9yGUEJ3j5bapmAiM/he/yV381G8=;
 b=puGmflYjZFCuMlHhWT3QE5twzlouftmMldP/seG3MfaVrk/szmnlBQwflcPwHA5qHBdvpNlr0Ehq1pu9NgbvTfObVG4KcDZE5q2/IUSvXbgRf/4j6Jza9jw82Fn8p9yrYP4L3YI7cXQvUgFCt7/Je5ZOTooBYEI8LKLE7m5GxvY=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5216.eurprd05.prod.outlook.com (20.178.12.93) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.13; Thu, 13 Jun 2019 23:10:45 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 23:10:45 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, Maling list
 - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Thread-Topic: dev_pagemap related cleanups
Thread-Index: AQHVIcx5DdVrUhs/HUiF5V2FmmsvzKaZ58OAgAAlLoCAAAtCgIAAHqKA
Date: Thu, 13 Jun 2019 23:10:45 +0000
Message-ID: <20190613231039.GE22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <20190613204043.GD22062@mellanox.com> <20190613212101.GA27174@lst.de>
In-Reply-To: <20190613212101.GA27174@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0005.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::18) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6deefc2c-1cfe-42b4-a481-08d6f0545d5a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5216;
x-ms-traffictypediagnostic: VI1PR05MB5216:
x-microsoft-antispam-prvs:
 <VI1PR05MB52161DFBA773BE4F896E6107CFEF0@VI1PR05MB5216.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(376002)(39860400002)(346002)(366004)(136003)(199004)(189003)(66446008)(64756008)(66476007)(66946007)(1076003)(7416002)(66556008)(73956011)(5660300002)(2906002)(8936002)(81156014)(26005)(8676002)(71200400001)(71190400001)(102836004)(256004)(6506007)(386003)(76176011)(86362001)(52116002)(486006)(99286004)(11346002)(446003)(4744005)(7116003)(2616005)(476003)(66066001)(6246003)(305945005)(33656002)(14454004)(25786009)(7736002)(6116002)(3846002)(4326008)(478600001)(54906003)(6916009)(36756003)(68736007)(6512007)(186003)(81166006)(6436002)(6486002)(316002)(53936002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5216;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 IxerV2Ues/JSOcb8GLs2M1W5creYR/hSc2Ld7NaDx5lom/4gPQHVuDzz+iegaHaiak68YoBo1qmhTmWqPMNuSkxTUbVDMXKuD+y0MYQ+s148o+lJXY45QaReW0xTCbwj4fTWzHYpaVgpzyOI2uJGjuwe8zltTJyKEO+MbJPVH952uN+EGFGVWkIU0VwBnwdLoi/L7zVf4zyvko2537aRaFOVkWfyl2VO9zl8rGK2luIOihGZ8nCEfxFwMA3a3fs9GSSPfKJWGaMt2M06AQU/jZvaIfQtev7Y7HJI6lt7AVU7FDor+VuW5RzO0wnekKZou8W3toLRY+zBldGHKLLUUoWpjJihE6y4qwY2VvpWwKCfX/0BM5glNwMu0BPr3g1xu7K7ivPeEJiAMRgbFvD52ghJtJEYdA1bBTbY/VbQzx8=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9DD504E2832E244190B09BBD35CAF05D@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6deefc2c-1cfe-42b4-a481-08d6f0545d5a
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 23:10:45.6882
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5216
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:21:01PM +0200, Christoph Hellwig wrote:
> On Thu, Jun 13, 2019 at 08:40:46PM +0000, Jason Gunthorpe wrote:
> > > Perhaps we should pull those out and resend them through hmm.git?
> >=20
> > It could be done - but how bad is the conflict resolution?
>=20
> Trivial.  All but one patch just apply using git-am, and the other one
> just has a few lines of offsets.

Okay, NP then, trivial ones are OK to send to Linus..

If Andrew gets them into -rc5 then I will get rc5 into hmm.git next
week.

Thanks,
Jason

