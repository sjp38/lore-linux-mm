Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2474DC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFC5E22CE3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:51:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="D+HMEZzb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFC5E22CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C4C56B02BF; Wed, 21 Aug 2019 19:51:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7768E6B02C0; Wed, 21 Aug 2019 19:51:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6660C6B02C1; Wed, 21 Aug 2019 19:51:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4440E6B02BF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:51:06 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EE36C8134
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:51:05 +0000 (UTC)
X-FDA: 75848083290.26.oil62_43a69e4b3394c
X-HE-Tag: oil62_43a69e4b3394c
X-Filterd-Recvd-Size: 8483
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150080.outbound.protection.outlook.com [40.107.15.80])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:51:04 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=EaGTxjEj+CwSG/XNx0WVf6F7/XvgOywqnqprTk+X54g+n7yml1T/WTHVMWQtTsoh5lET1IHys7yS2VQNA/9m6kG8shtOcjnpnpU/0iqodpBd0+8wrnPv1p7IvD5PUgOzw+5Fw1PH6vK+vi/in8OiHRki1hH8CrZADsI6W15d32oYem2rdDLXU+b4wcYbDx9YSL/ljpxHU2FRAjn4SN5jztpg1HWb0lLCzIhhP3Lir6k+eIm0GSkynXTEtm7DP0M6cnRhk6AHPrikTuYH5mP6O5tL1cFhbDsSQFK+AdlSdiuxWCf3oN1H1NvfRwdRQvlizqtGMIVgU/sit40PYgC5+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BD99CBVwfWfplQFNyhx/dmJLkrR1Rdt/Q/30tc6QT8o=;
 b=BS4cZNVfKE06QXqVVG/MCeuydoH78OlWOF/X/X9JybWHcCP+V2stnYz440lHN+8YhRP1nanzJQTK66bzIdbm+4uhPw9cNNF/lxgcG/p8mrMIqQFT8ZfGXm2x2HAD2ZNQErW8mBuOJge2VcCi7yM8tAFyCHOSjyBFiak55a+r/xcX8yw9ERsr+lsqsSiJRdIgw++tk9j6f2wmPpUaPnAZRroY5HRE5y5Dsuaaa5XgkmkHNIeEbTxDBKVg/iswM7OU6bL/2DsuVCYD+Cf6afjBy8nBv1Nv8m88aE67Gfw8hCj6LFy5x9ET+v75r+wUgluTYgIYaIiLLSeScn6WpplQBg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BD99CBVwfWfplQFNyhx/dmJLkrR1Rdt/Q/30tc6QT8o=;
 b=D+HMEZzbkKXskCwej8+htiGn6+Gajl9dCXTDoe+m3ZQXNat5BUweS+Gni3IVmyzCMAnQbRJi2uyqBP75wGzxjzCmN6EHgI9LFifDG9ucBOXIwxAMmBRjGkg/2clAOoXHAHQaaBx+3onZr5Oy3ZIWnAxJlBfKnAqGDKRyYa5m8gI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3405.eurprd05.prod.outlook.com (10.170.238.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Wed, 21 Aug 2019 23:51:01 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.020; Wed, 21 Aug 2019
 23:51:01 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>, Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Topic: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Index: AQHVVaUUhGk4jDl8B02XMFt421bWy6cDRjIAgADEW4CAAOK+AIAA4TAAgAB8xoA=
Date: Wed, 21 Aug 2019 23:51:01 +0000
Message-ID: <20190821235055.GQ8667@mellanox.com>
References: <20190818090557.17853-1-hch@lst.de>
 <20190818090557.17853-3-hch@lst.de>
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com>
 <20190820132649.GD29225@mellanox.com>
 <CAPcyv4hfowyD4L0W3eTJrrPK5rfrmU6G29_vBVV+ea54eoJenA@mail.gmail.com>
 <20190821162420.GI8667@mellanox.com>
In-Reply-To: <20190821162420.GI8667@mellanox.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0011.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::24) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ff7de4e9-222d-439a-2e07-08d726926be3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB3405;
x-ms-traffictypediagnostic: VI1PR05MB3405:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB3405C0BEDAE45C180F2B0520CFAA0@VI1PR05MB3405.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(979002)(4636009)(136003)(346002)(366004)(396003)(376002)(39860400002)(199004)(189003)(8676002)(81156014)(99286004)(81166006)(316002)(229853002)(66446008)(54906003)(66946007)(64756008)(66556008)(66476007)(7736002)(305945005)(52116002)(36756003)(26005)(66066001)(6116002)(3846002)(76176011)(2906002)(53546011)(6506007)(386003)(6486002)(8936002)(53936002)(102836004)(6916009)(71190400001)(966005)(71200400001)(14444005)(33656002)(256004)(4326008)(14454004)(6246003)(25786009)(6436002)(186003)(11346002)(446003)(478600001)(1076003)(86362001)(486006)(6306002)(5660300002)(476003)(2616005)(6512007)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3405;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 slGrQeYkySAxa73xEYqN4ELA/jv+A3z+GlBl0VtF+hmNWnPZztSuW1C49EPLKPdwUphLosHoVkD335T3BNKVRLTHUJ3BdZORtQWzgfNPWw7Qn3N0nB/dd7YG/eyLw3RSzwt9FKeLBtSsLMyDSI6VeWbVfglU3GMSonGgQr5bwfeNhbhj37aaoJNRMW2pm94yHYjRuwNSvg9ZZWP2p5Qn+2fUqp3iC5wT554nR3W+oCn3juxV0wZmL7c4RSUL0wHMbiyxFGb18Caxpooqns6RZCiZMZCLDT8CWiTOwiHqduGp9SGVcAItGtbqUcDr0QIeL2y30ArKjQh4iHYdKmGshX8Vq6xCYnTrSCK4VoYMM8EOnwM44eAuaw48cEkCIT/h3EcppX88pc//0n7c0ECnDqZP+KVizyPUeEdjUGz/8J0=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BA840F552473C345840D4DC31B1DBDC6@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ff7de4e9-222d-439a-2e07-08d726926be3
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 23:51:01.5744
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: OG0Q51siNn889gtpqWijjlXqfQEuaoX+J5YF1xxqvnEZWPVwJ2e5q3hcJxqvfIswSZxjYs3kVbHIsXo64hjjCg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3405
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 01:24:20PM -0300, Jason Gunthorpe wrote:
> On Tue, Aug 20, 2019 at 07:58:22PM -0700, Dan Williams wrote:
> > On Tue, Aug 20, 2019 at 6:27 AM Jason Gunthorpe <jgg@mellanox.com> wrot=
e:
> > >
> > > On Mon, Aug 19, 2019 at 06:44:02PM -0700, Dan Williams wrote:
> > > > On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrot=
e:
> > > > >
> > > > > The dev field in struct dev_pagemap is only used to print dev_nam=
e in
> > > > > two places, which are at best nice to have.  Just remove the fiel=
d
> > > > > and thus the name in those two messages.
> > > > >
> > > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > > >
> > > > Needs the below as well.
> > > >
> > > > /me goes to check if he ever merged the fix to make the unit test
> > > > stuff get built by default with COMPILE_TEST [1]. Argh! Nope, didn'=
t
> > > > submit it for 5.3-rc1, sorry for the thrash.
> > > >
> > > > You can otherwise add:
> > > >
> > > > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > > >
> > > > [1]: https://lore.kernel.org/lkml/156097224232.1086847.946386192468=
3372741.stgit@dwillia2-desk3.amr.corp.intel.com/
> > >
> > > Can you get this merged? Do you want it to go with this series?
> >=20
> > Yeah, makes some sense to let you merge it so that you can get
> > kbuild-robot reports about any follow-on memremap_pages() work that
> > may trip up the build. Otherwise let me know and I'll get it queued
> > with the other v5.4 libnvdimm pending bits.
>=20
> Done, I used it already to test build the last series from CH..

It failed 0-day, I'm guessing some missing kconfig stuff

For now I dropped it, but, if you send a v2 I can forward it toward
0-day again!

Thanks,
Jason

