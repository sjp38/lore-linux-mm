Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D65C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BE0E22DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Bbwtb1ol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BE0E22DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FEF86B030D; Wed, 21 Aug 2019 12:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AFFE6B030E; Wed, 21 Aug 2019 12:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8516B6B030F; Wed, 21 Aug 2019 12:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 5F68C6B030D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:24:32 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0B18BAF9A
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:24:32 +0000 (UTC)
X-FDA: 75846957984.04.base76_619ca3771b435
X-HE-Tag: base76_619ca3771b435
X-Filterd-Recvd-Size: 8119
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10089.outbound.protection.outlook.com [40.107.1.89])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:24:30 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=MP860+niw5WSQa1uxYkKXLdU1l8p7IAGj42PFVNVx+XMBur2My1piaReK7HLmO7FclvYTb1rLafuoO/nHxW03Cx4+Wf0ILtx1c0llObRvFTad3YwFj2oeUbyG9EASBNiq86PbadfHj2+d4Yx5IZudfMF7YaTV10GsllSwueyH68SBj7UXyO6nmwabaoax8KKHi1b+4dwrbbBmm5lls+QdJZmdiWHYVVCsKQYVftJnTlkET8DZ3YwhYf+fRz+f8Df8dhUSB72AtbIgdkAjCYVgkNBwBjNfjhy/P8FEmmGQitWOONVtaiNw+S+N837AgA/c8W59ZuWwqZsFfgZCyJrEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dkL4XNf6jJxRmskhxeRBEAlUUpTj1OlKGnikQYdmJVc=;
 b=bX/3sIc5yjodspouCVCvmjCLL5nkU0gL5fdoRQv3vLwDNdnHZ8ffFABPjymjUMPsAWNGYaJ+Rp6r2THmUaOQeo0IEzSt/JrZrVGZcWPnYDV+jrQ5UxeiqobhW96WowMa48C4bqnJ2xDUawG/rlDe8HiZN3USPbaYL0OBAAy6grebgYwYrGMvcgSHFt2P0+X/HKxXanoQCfyU59xxdOlE2vS/xU6eqDGUWkIFRcORSUkBd9/vYgkeganlOL9FEttCyUVpolKLzO7eTMKpmevdrBStxLNpliV/qTteLOR6sjP/06z14Lf69S+hvgXTljwBC5URSPu896sSa2ih6VMe7w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dkL4XNf6jJxRmskhxeRBEAlUUpTj1OlKGnikQYdmJVc=;
 b=Bbwtb1olEb5vJzGasymPYmiz0rntm+RwmqrgtBlStBltMGG7718E97gC9z4rLSjZczTQp10Yu3gMtrpwC+vKorDQlhRlII9tz32q5p0YecJx61y9IFeX1WZxh4WSGyE90Jd635odrqnl2dYUpCnLCLOcTuzZX61kAAmP+IYqtEo=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6623.eurprd05.prod.outlook.com (20.178.126.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Wed, 21 Aug 2019 16:24:25 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.018; Wed, 21 Aug 2019
 16:24:24 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>, Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Topic: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Index: AQHVVaUUhGk4jDl8B02XMFt421bWy6cDRjIAgADEW4CAAOK+AIAA4TAA
Date: Wed, 21 Aug 2019 16:24:24 +0000
Message-ID: <20190821162420.GI8667@mellanox.com>
References: <20190818090557.17853-1-hch@lst.de>
 <20190818090557.17853-3-hch@lst.de>
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com>
 <20190820132649.GD29225@mellanox.com>
 <CAPcyv4hfowyD4L0W3eTJrrPK5rfrmU6G29_vBVV+ea54eoJenA@mail.gmail.com>
In-Reply-To:
 <CAPcyv4hfowyD4L0W3eTJrrPK5rfrmU6G29_vBVV+ea54eoJenA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0023.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::36) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e5f61116-56cc-4f5b-df6f-08d7265407ba
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6623;
x-ms-traffictypediagnostic: VI1PR05MB6623:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB6623079A171D2E9C109DA26CCFAA0@VI1PR05MB6623.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(39860400002)(366004)(136003)(396003)(189003)(199004)(476003)(76176011)(966005)(6436002)(1076003)(14444005)(256004)(86362001)(66946007)(66446008)(64756008)(66556008)(66476007)(14454004)(6486002)(53936002)(52116002)(478600001)(8676002)(81166006)(8936002)(6512007)(36756003)(6306002)(81156014)(25786009)(33656002)(2616005)(26005)(102836004)(5660300002)(486006)(71190400001)(71200400001)(316002)(54906003)(4326008)(229853002)(305945005)(99286004)(7736002)(6916009)(6246003)(446003)(66066001)(186003)(11346002)(6116002)(2906002)(3846002)(386003)(6506007)(53546011);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6623;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 pgUSY1mT+cHNF5lCkxnSO+sR24Zmh3xKsXOca9UEfDg4jk1mEJvGvVz39guQlP2nJkSX6uPO7BXihTDrCjagWRmVcLUZEljeJqS6NTnHdXBV24dY6mDAT2X8HYX5HiEuCpICDukiae3gmIXDEegm/67+eDO39waLFW1JWvgZvmUj/8eeDhah7WhIyzO3fhVI8zO/JmuIrjqeWKisyYKqxLZd/b6PX68HfgP8Z3Qd7YPpxu6rtIbUt4dIYOnJlywQuHEVbawDdALwFZvMplDh61MAjD8bEWVAebALqV6jvkULmcRptSxkm1CrIhVfEGDhAfoGpJvJlFOVgkap0GytieD2rfDvRe5KwWNs4+cre4BjaFKs3Itib/1lnu9mQmoUmJxKNjDKePYxN4pUIyGOxrSb+2C+7M6icyVCkXr6yXA=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5046CBEEB2C5E343BA411C811C48C867@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e5f61116-56cc-4f5b-df6f-08d7265407ba
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 16:24:24.8558
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: PxqoA5jfRvt3TLgTl4HOtLD41jEG6OaMWs9S1UeK4wzusFkZA2zJ9ll2M6evmld0GZcxsGiTLS+g+rOuJYkY/A==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6623
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 07:58:22PM -0700, Dan Williams wrote:
> On Tue, Aug 20, 2019 at 6:27 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> >
> > On Mon, Aug 19, 2019 at 06:44:02PM -0700, Dan Williams wrote:
> > > On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrote:
> > > >
> > > > The dev field in struct dev_pagemap is only used to print dev_name =
in
> > > > two places, which are at best nice to have.  Just remove the field
> > > > and thus the name in those two messages.
> > > >
> > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > >
> > > Needs the below as well.
> > >
> > > /me goes to check if he ever merged the fix to make the unit test
> > > stuff get built by default with COMPILE_TEST [1]. Argh! Nope, didn't
> > > submit it for 5.3-rc1, sorry for the thrash.
> > >
> > > You can otherwise add:
> > >
> > > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > [1]: https://lore.kernel.org/lkml/156097224232.1086847.94638619246833=
72741.stgit@dwillia2-desk3.amr.corp.intel.com/
> >
> > Can you get this merged? Do you want it to go with this series?
>=20
> Yeah, makes some sense to let you merge it so that you can get
> kbuild-robot reports about any follow-on memremap_pages() work that
> may trip up the build. Otherwise let me know and I'll get it queued
> with the other v5.4 libnvdimm pending bits.

Done, I used it already to test build the last series from CH..

Jason

