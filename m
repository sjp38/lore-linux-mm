Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A566BC3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 10:50:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32A1621881
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 10:50:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="LStOEI5q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32A1621881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D376B0003; Mon,  2 Sep 2019 06:50:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DDAE6B0006; Mon,  2 Sep 2019 06:50:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D9A6B0007; Mon,  2 Sep 2019 06:50:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 507116B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 06:50:04 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DD0AD689F
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:50:03 +0000 (UTC)
X-FDA: 75889660686.04.bean40_3a93b8f442453
X-HE-Tag: bean40_3a93b8f442453
X-Filterd-Recvd-Size: 7824
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10074.outbound.protection.outlook.com [40.107.1.74])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:50:02 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=cOSaw6d5v4TJKE3QcmR6vQCM0LCKSmwHqA2EJu6FDTlzl6emgs1E5ssnc7roHwEJ4X6ABwL6UHelRl+H4/t7dYKEliBbSmKiYCiCH47qjrsZ6vu1N9hz9vkHXD9+gszi7v2JEpzRDi7n5fzo2TV5c9Z2O488HgIDwVu77jEDFCOvhmGT4OuuxRCNP5SjWqOxc3y6STIo6rEQO240ingnxPU77+3GcyKIHTv2uLIP5+ICOtCq+qDagCxV7sQbc6iWQeqNtliZA5jen2IA61aoQuMkH3t0U1oNTL+WSjiSXWuTCeAmT32lmjUk0e0CZD2Oz9Ta/or1og0Zeog8O8Z/Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NuhtYnzfhusV9OxQzs2EJk2b74vyp3IHqOmQDca5lIU=;
 b=MYG6+QkVdsaw/9TPUGPPMXnrJkttxymtyy7B4DOEhAg8cm6/hN7snWPvsHQjSOD+cK0g5+iDj+rJ9DkSYZS7is9oOPsqEs3Po+KXBGFSF6OxWdyL0b8falvrirT5CXuV0thtqIvZQSbIlo6gfhc/RMXa4H+M94vAjjBvNIfjaVgdEJYToXaW5nOGP74PPRvK+bfGTgfDWoUUOl+ToC7Ex9Yv8YyaTJi1NMzPnhSDqal0ykLomuuIf+MPiYlDCccnbxuUbZubKpLb5kcuQkz1oe2djCMBu3xG1GWhLorOFnzQCWc2wV6aexWwC+nBKzGGpOdStnGGkc+vch+55u/+/w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NuhtYnzfhusV9OxQzs2EJk2b74vyp3IHqOmQDca5lIU=;
 b=LStOEI5qrkwACLMAvFu3m/mIYvoWYZfd286tcwYqSgtrMHjxRteNlFYjkQVCPD9rlqXiaGoyG6Il1ok7yP2VxH9eFmXG5PQYanag5CG6H6YwERnLswecZ1+OPvBz543Fag4XHEs+6KpGcveiZbAIxmoHMO2jDpJ5Mru2mEH9xOE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4895.eurprd05.prod.outlook.com (20.177.51.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.21; Mon, 2 Sep 2019 10:49:58 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f%7]) with mapi id 15.20.2220.020; Mon, 2 Sep 2019
 10:49:58 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Guenter Roeck <linux@roeck-us.net>, Linus Torvalds
	<torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@shipmail.org>, Jerome Glisse
	<jglisse@redhat.com>, Steven Price <steven.price@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Topic: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Index:
 AQHVXauzoOyMGt/Rm0+/Xu8LAWoHTqcXL4MAgAAOHoCAABCOAIAAm4cAgAAjgICAAC/DAA==
Date: Mon, 2 Sep 2019 10:49:58 +0000
Message-ID: <20190902104955.GB20@mellanox.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de> <20190901184530.GA18656@roeck-us.net>
 <20190901193601.GB5208@mellanox.com>
 <b26ac5ae-a90c-7db5-a26c-3ace2f1530c7@roeck-us.net>
 <20190902055156.GA24116@mellanox.com> <20190902075859.GA29137@lst.de>
In-Reply-To: <20190902075859.GA29137@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM0PR01CA0036.eurprd01.prod.exchangelabs.com
 (2603:10a6:208:69::49) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 53469947-dbde-4e13-b9a6-08d72f934c4a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4895;
x-ms-traffictypediagnostic: VI1PR05MB4895:
x-microsoft-antispam-prvs:
 <VI1PR05MB489527A66C2397AAEF7ECBABCFBE0@VI1PR05MB4895.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5797;
x-forefront-prvs: 01480965DA
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(346002)(376002)(39860400002)(396003)(366004)(199004)(189003)(86362001)(186003)(4326008)(478600001)(8936002)(36756003)(7736002)(305945005)(71190400001)(71200400001)(256004)(6512007)(14454004)(6436002)(81166006)(81156014)(8676002)(53936002)(316002)(26005)(102836004)(14444005)(33656002)(2906002)(6246003)(76176011)(54906003)(6506007)(386003)(66476007)(66556008)(64756008)(66446008)(6116002)(66946007)(3846002)(52116002)(11346002)(476003)(2616005)(486006)(25786009)(446003)(7416002)(229853002)(6486002)(1076003)(6916009)(66066001)(99286004)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4895;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 u3yP2zgBzHURzB9tJhA+7SX5ivEUZ0RwAuvSIBwod6Bd4lLddC4gbzx0hy6BMQ0J95S7RoGfD0g3pLQr2JC/bRymEarJ8YJNgSORJfdff/McSAcw9b9WGBNZfWssEbXPHpkp9dhdEJK13FAFjAZ/+dEvcrwm9/q9T53DX52cJxyNl+Zf3dTbut0QBcrQzdeqe8Swh0hYsA7pBVna8gGdrcXTLx7HcSIpICLuqhhnFluxAQFgiogiebCNpqA0z0DDRdAHgpdW7496NDEIxLYpG3g2kRbn9S/Wfw9PJVKRz4r6C8GwnrCSUpulA+z90xoQCks/SisPGGGWUt9bWxYrGIaU1vgTYg6vH3CPaHZ+6BxSYrtA6oI8T84CH659PiWsYNNyEb1pFhJGXnHJyrExflI8ahMKyQMy2UpG38+GUkQ=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <0E3FE41A0CB6E74EA4443B039BEC2BBA@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 53469947-dbde-4e13-b9a6-08d72f934c4a
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Sep 2019 10:49:58.5176
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: RTe3Biu3LyLvl9twoKSud2kxcqiUkNu2AhofwoPNFB8QguKsCxVLpcMVPik5vMe3ojKyoPMtKKtBFh6I85bq9A==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4895
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 09:58:59AM +0200, Christoph Hellwig wrote:
> On Mon, Sep 02, 2019 at 05:51:58AM +0000, Jason Gunthorpe wrote:
> > On Sun, Sep 01, 2019 at 01:35:16PM -0700, Guenter Roeck wrote:
> > > > I belive the macros above are missing brackets.. Can you confirm th=
e
> > > > below takes care of things? I'll add a patch if so
> > > >=20
> > >=20
> > > Good catch. Yes, that fixes the build problem.
> >=20
> > I added this to the hmm tree to fix it:
>=20
> This looks good.  Although I still haven't figure out how this is
> related to the pagewalk changes to start with..

It is this hunk:

@@ -481,7 +461,10 @@ static int madvise_free_single_vma(struct
vm_area_struct *vma,
 	       update_hiwater_rss(mm);
=20
	mmu_notifier_invalidate_range_start(&range);
-	madvise_free_page_range(&tlb, vma, range.start, range.end);
+	tlb_start_vma(&tlb, vma);
+	walk_page_range(vma->vm_mm, range.start, range.end,
+                       &madvise_free_walk_ops, &tlb);
+			tlb_end_vma(&tlb, vma);

&tlb does not expand properly in the csky tlb_start_vma macro, and
previously it was just tlb

Jason

