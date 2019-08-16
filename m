Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 892DCC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 11:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 113472064A
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 11:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="MDd9Z0b2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 113472064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BAFD6B0005; Fri, 16 Aug 2019 07:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66B836B0006; Fri, 16 Aug 2019 07:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 531BC6B0007; Fri, 16 Aug 2019 07:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0089.hostedemail.com [216.40.44.89])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFEC6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:45:06 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8E014180AD7C3
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:45:05 +0000 (UTC)
X-FDA: 75828109770.21.stem56_83a3f58084830
X-HE-Tag: stem56_83a3f58084830
X-Filterd-Recvd-Size: 7043
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20081.outbound.protection.outlook.com [40.107.2.81])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:45:04 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=g4IeIlm99VnHyrRkma3OM8a3OAvEPAxcb6L9I9xYrA+yAK9Lo3+A/1ZwiNqmp4PGA1W2vj2LPyiguoxz+HQ8yBiAzGG0arUAJvnZraJreMlGk11EirJeutL/CPG0iTnW17RJb7LtgPS8WR9GOU1qoaDDRvDupRDYkHUBDWzLy1Rp60JOd6ktV5ARD8S7PkEdXwX0aamDNCHz2FPrMiuPVQw8wxKJrhEiss6h/9ndr0CMj4lUUW/juattb9CihbPekwTewrCfHDC62Nc0tfL+mhvSInKpTVExLotD74mmEyvKkfshL5QwFV8jhUtxHUHFDh1LWM4b4QOd6c8eJZw0Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mPBZNCf9vnpj8wIEk0OHp6ePXH7dpW8IIMSrKIT6mtM=;
 b=m40X+vY4UzG7foDsgpbVVzuyr9YZscBHZfBMBcwg+QSzcKFfgOpKZS8MeZuX4oqS6swIOtboee/b1HzH0konUbw//+1+i1KNpwhiEHZEb6V39f4KaS2bqtD5Cv52snkAs2UNTkl2Z5g3IadRhMxgARMtRAbENAsELLyrjVe74tnh0Yp3T6GfMuGSK7xEexdRaOxtXDT41nK2AZNO2BIQoZMGxtyoy7w/yUbMDlU+qpAsSaafStIA6yTrZ4+sCRM/gihWWV5ViXYzF+TvhDCGxGiyhP76kjWf1keOclyP+kQWxM9HETieCF2tXw3vlik+cBLh9OhJLIV6LgvOopBQmQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mPBZNCf9vnpj8wIEk0OHp6ePXH7dpW8IIMSrKIT6mtM=;
 b=MDd9Z0b2Gn0AJt0rcnsaNVa/5ubSUqqGeX1WePHlOGea663EEgPlaGEJU5q304ye6I/R102BH2w0cAMkUjOQUrJrDrDbxRxXd3wFe44dGY/XORfJy8RB0ixitUmVeOPjbiXtZj1My2N/5R6ozkEpE2sOCD8YmJHO1AgEREUFF7w=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4622.eurprd05.prod.outlook.com (20.176.3.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 16 Aug 2019 11:45:02 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 11:45:02 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: turn hmm migrate_vma upside down v3
Thread-Topic: turn hmm migrate_vma upside down v3
Thread-Index: AQHVUnY3o2YuKC2GgEGP76ylqL0JqKb9WTGAgABR7wA=
Date: Fri, 16 Aug 2019 11:45:02 +0000
Message-ID: <20190816114456.GA5412@mellanox.com>
References: <20190814075928.23766-1-hch@lst.de> <20190816065141.GA6996@lst.de>
In-Reply-To: <20190816065141.GA6996@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5b9ccf3e-223e-4af3-1f97-08d7223f2c5e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB4622;
x-ms-traffictypediagnostic: VI1PR05MB4622:
x-microsoft-antispam-prvs:
 <VI1PR05MB462228F09AA77A9AF8FE7D8ACFAF0@VI1PR05MB4622.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(376002)(396003)(346002)(39850400004)(189003)(199004)(256004)(36756003)(25786009)(99286004)(6486002)(4326008)(53936002)(14444005)(386003)(86362001)(6506007)(6246003)(478600001)(66066001)(229853002)(71200400001)(71190400001)(186003)(14454004)(446003)(52116002)(6512007)(11346002)(6916009)(33656002)(102836004)(26005)(76176011)(6436002)(54906003)(2616005)(1076003)(7736002)(476003)(7416002)(486006)(6116002)(305945005)(3846002)(8676002)(4744005)(316002)(81166006)(81156014)(66946007)(2906002)(66476007)(66556008)(64756008)(66446008)(8936002)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4622;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 1x3bpZwsR/KyuuJFWck4tH0cucsiGxRaz18JmfgueCHzfAqLYaMEqJ4K2FBdO+jUxH4V34SbbSUAPOWq1MU3SI/tEPG9Xss/KJvUpIFGLZ9aGkWEVQyQzoPLnwo8sp96pne/EckyZbwq9uwK6o4xZZAPS3qdGwH5zjJS/aytTuJdO5DRzkdQvAl+n1ER86fdUCiFoqd6SH0pEROs73aJYmKJ20eiYNA9gw6hxjOMu1Ai/zDc2A4YmN0TPFT1eGB0MHUBbj1lNxGiBGOhps+W2nkuWZH1j1cwRsCbjyysGXXb74HwpCCV6L6ePIR7yI2qPcte4EXzyDCuTfsP+CTKZ7Fihz+NYFwlkTTYUlpGJejqbU/RtS2ne4OcNPpvXFz3YrjYfrDbzMD4BWt6e2axooc/f6ecDQlYKDP/fJ8PiFk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <81AC2B318B8E8841A42EB8D34486FD1F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5b9ccf3e-223e-4af3-1f97-08d7223f2c5e
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 11:45:02.0833
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: gjtM27Pn5Un0dhFUEVsUgIrpGaDwUJh2vgPlD0ZIfiirELFmB+yLaOjS6wwTYImEYOe7sNRxGyivG5fIMKQY+Q==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4622
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 08:51:41AM +0200, Christoph Hellwig wrote:
> Jason,
>=20
> are you going to look into picking this up?  Unfortunately there is
> a hole pile in this area still pending, including the kvmppc secure
> memory driver from Bharata that depends on the work.
>=20
> mm folks:  migrate.c is mostly a classic MM file except for the hmm
> additions.  Do you want to also look over this or just let it pass?

Yes, after you explained the functions were hmm ones, it seems OK to
go to hmm.git.

I was waiting for the dust to settle, I see Ralph tested-by, are we
good now?

Jason

