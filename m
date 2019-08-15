Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 478EDC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FFB20656
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:34:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="XxhpK68j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FFB20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96C736B026B; Thu, 15 Aug 2019 15:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F5096B027A; Thu, 15 Aug 2019 15:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794D26B0281; Thu, 15 Aug 2019 15:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 5198C6B026B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:34:49 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 00B5B181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:34:49 +0000 (UTC)
X-FDA: 75825664698.10.screw73_641c37b012349
X-HE-Tag: screw73_641c37b012349
X-Filterd-Recvd-Size: 6682
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70045.outbound.protection.outlook.com [40.107.7.45])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:34:47 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=VYq9w+eYqDE79CiMfWFu+fTgjeHAK9swl3xLeaDLX/0Npi0n4vNtl6L4hZpzP1376bd9B8y7AlbGDJ6AOSk8gJuuKPtM0Vjj+HHF9+CHP4ZWCObxV0P/Ub5xTO9mGtfJ3Zh42zpdW68KmTMtwd7tAo0kWKzo0G5JhW2f2V7YulAf5H88/0cMNWfRoAOtJBL6YuTKas1EnQVaUghRztf/ZR7YM1E/zpm3APSV1gkwG52DU5uhSi2LeQt5A16v53YBtgz5gzhbGhZwg7k+o3JMCUUO0q7wzAU7lBh9pH5h77/N3vf+BL9OPv6eEE3QHYJHlri46giIOQYdAajOmZoIhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j1jpZ2hdS9SHCq4J1882bSGlT4MKKMMrNAjddOBVlaM=;
 b=G6dS8TiWr9HPFcOtNBZIIMbx39fCPqiO3Hl9l68hCeFZNxyQlUeageY3DH+B+gfmTBbCzUcepVVNQgNuqHPFDkW1w4MFamrqJhgDKFAc5J5HFSlvrOMR3kP85PMkFG02d4wGnMbU1YvLaEwaGu9EC1pJGqvbooAAEGIS/3vDOKkQGWzfLp2TjzIw7nNNCvKfR863qDBd7C8U262uIR99F+Y7msc8lYSq38I55IRGEA4nj6O2ZJwBY87Sihh6A/IHCpPxgK2fUSJ03TuUVQ5/LM1TpsPo+9jsbgF6qjfmMfad9YPaX/XamKRBTtM519eeVy66MqrsJK0NwztZ/CGKwg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j1jpZ2hdS9SHCq4J1882bSGlT4MKKMMrNAjddOBVlaM=;
 b=XxhpK68j85mc+R7x55edM92mVXqrCfCc+hsvB2rWdcjr/Uzz8XP9nySsSQS2ErcwvPpiuKg2cOIY7F9Je5DOHEQej9ZxBk+qfKuhn2BxN/8vityg1fR3PNrK3zpzeQnNrYcYTQDL7NnPGh7/zAnC/ph0TKvrE9XMO8avJonzMCE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4302.eurprd05.prod.outlook.com (52.133.12.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Thu, 15 Aug 2019 19:34:45 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Thu, 15 Aug 2019
 19:34:45 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dimitri Sivanich <sivanich@hpe.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH v3 hmm 04/11] misc/sgi-gru: use mmu_notifier_get/put for
 struct gru_mm_struct
Thread-Topic: [PATCH v3 hmm 04/11] misc/sgi-gru: use mmu_notifier_get/put for
 struct gru_mm_struct
Thread-Index: AQHVTKz0H8HKrXog20KnkgLCdHpVKKbxDfkAgAnK6ACAABY+AIABuHuA
Date: Thu, 15 Aug 2019 19:34:45 +0000
Message-ID: <20190815193439.GE22970@mellanox.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-5-jgg@ziepe.ca> <20190808102556.GB648@lst.de>
 <20190814155830.GO13756@mellanox.com> <20190814171806.GA14680@hpe.com>
In-Reply-To: <20190814171806.GA14680@hpe.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0005.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:15::18) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a148438e-ed8e-4448-32e6-08d721b7a085
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4302;
x-ms-traffictypediagnostic: VI1PR05MB4302:
x-microsoft-antispam-prvs:
 <VI1PR05MB43028675D17D2E8AA38E282DCFAC0@VI1PR05MB4302.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1360;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(39860400002)(136003)(346002)(396003)(199004)(189003)(186003)(476003)(86362001)(229853002)(5660300002)(11346002)(8936002)(14454004)(3846002)(6512007)(7736002)(2616005)(296002)(4744005)(446003)(53936002)(81156014)(2906002)(316002)(36756003)(26005)(6246003)(25786009)(256004)(66066001)(81166006)(6506007)(102836004)(6916009)(99286004)(71200400001)(66946007)(478600001)(6436002)(66476007)(386003)(8676002)(4326008)(71190400001)(64756008)(66556008)(66446008)(76176011)(1076003)(52116002)(6116002)(486006)(305945005)(33656002)(6486002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4302;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 no2aJNbMf5QC15SknRfF+aUmgMe9pd0CMnisXDUyZf3aJevox9G0tsSM1CrxkT29/wICxSqR93lZGU2IOZm1MbSK14Up5ZotWdP0TG6AwO0nWbzKCGpFZu+cpK/d4UJNIejyDTWe/k19HRpTziCWFXwr7X+c0WARNI+C6MU4IvcLPMolt4jVQk7Sq/dk573Fq2Ca+wAU2IdplYMmAjQeqrhoeqej66wE5e3iADd3qVgarYwrSpxraO1+BI6un/tiYrSMLlkanVN6A5s/WHAuWbyyN9KzbZmnjRrJrDhDuLtEtDtkytJRwGEPL7l7qbqtteg1NYor9xk2GfKp0Q5PiHx6EJbouQgCqHyujr0g8wcL33vaX0waSvS6oWTcwTV7WALn4WvBSnSLtW7FO8CGz64GIgwde2VqeYSQSgAuods=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <111C9DA53B491F4D887535489230A7EF@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a148438e-ed8e-4448-32e6-08d721b7a085
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 19:34:45.4368
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: SffzKkRSZKieUZKjav6Yw5MAiqE211QrkEs8mgcBnbcYZjVZnHtAqFzcapW1l9oP3CRonLWmw1gXRs0MT6amqw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4302
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001025, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 12:18:06PM -0500, Dimitri Sivanich wrote:
> On Wed, Aug 14, 2019 at 03:58:34PM +0000, Jason Gunthorpe wrote:
> > On Thu, Aug 08, 2019 at 12:25:56PM +0200, Christoph Hellwig wrote:
> > > Looks good,
> > >=20
> > > Reviewed-by: Christoph Hellwig <hch@lst.de>
> >=20
> > Dimitri, are you OK with this patch?
> >
>=20
> I think this looks OK.
>=20
> Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>

Thanks!

Jason

