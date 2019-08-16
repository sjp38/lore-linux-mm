Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36041C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBA3F20644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:24:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="nCS9yH6R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBA3F20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 871416B000A; Fri, 16 Aug 2019 08:24:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 823196B000C; Fri, 16 Aug 2019 08:24:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 711666B000D; Fri, 16 Aug 2019 08:24:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5586B000A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:24:29 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id F17AA2825
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:24:28 +0000 (UTC)
X-FDA: 75828209016.21.drum03_2709a39ede512
X-HE-Tag: drum03_2709a39ede512
X-Filterd-Recvd-Size: 8130
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150040.outbound.protection.outlook.com [40.107.15.40])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:24:28 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=idY1cyXaUHBt1HWm5F512v9X+MSs7CDkVZwMy93Ftnm+UXINrGS/jHsKvzBBYqMpKKoq/A06i5RSxZXhJZi3y934iyIbDQov6M0YunnmHDwy6nEEw9IYqHgVdtq0AFxXn8vHa+e9F06Jr2xA8fxjsnVgXT5zTfN8hyt6ORXXr7MPh7Irl6+7Fq+3oJtNjIxf5Ylt78YrcZIDIPq1kYjxatG43KwTAoXNw6wResGyo0/eL5m/pmTFA6z9re3pMwPwtrv062pmxlhA3F2auLP+oZklGISbjej4zhSvU1u/Z9jXbeUvgf5BjwGNxyDqCZUybQtHM3rRpYzom9shsyx8fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cJYIOE5xJym+70NFJ7KIu6ayqkfMtXmLpVUuEXah5/w=;
 b=VG08dlcKcXO/Qi42XyZ0xpALa4cGJuV5y8CnM2akeQN75jUiF9+AGpR5xcRYv95+8RXtJYJZj7AYhxGhKeJ/gCW6uMLx2fpF7KcuhvSReh7Kwh0LMEVyHk7ohfEl5JpKmxhlvusv8G7PJ+EmxoZiBxP+qNzINEfFPtXebTVHzLeykImelFIhm988dBl918+ZHw7d3yHRwIIN4Vc+IZQcmaRfpYP7H75LuykmzHj08kO0j65OIw1/DQGJwLNRPJqxao3eTiO+Us7uztTVUZu+Jo91OYm/bxu9ljhi3sqQbfo6bg130ena+2iE65zP3/PWTe9c5gzLqswtp2CXBh+Rtw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cJYIOE5xJym+70NFJ7KIu6ayqkfMtXmLpVUuEXah5/w=;
 b=nCS9yH6R06H9jKAK563o7ttlvecERk82fYLTPybQtdSlsj6+xe9ltE5PDwDHt39aje1zcudua4MNiEGrcJcQrSf1dTu7m8frYyQ5ir57kAFrnPE2Du06emvb7UGwh71U9MeIoE00h9WyFmlTg0Tpi3mZepahPXn56h2rlza8fxQ=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5616.eurprd05.prod.outlook.com (20.177.203.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Fri, 16 Aug 2019 12:24:25 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 12:24:25 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Ben
 Skeggs <bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph
 Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Thread-Topic: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Thread-Index:
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABojAIAAAd6AgAAIBgCAAAXLAIAAAlcAgAABmgCAAEFKgIAANiwAgACOWAA=
Date: Fri, 16 Aug 2019 12:24:25 +0000
Message-ID: <20190816122414.GC5412@mellanox.com>
References:
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com>
 <CAPcyv4j_Mxbw+T+yXTMdkrMoS_uxg+TXXgTM_EPBJ8XfXKxytA@mail.gmail.com>
 <20190816004053.GB9929@mellanox.com>
 <CAPcyv4gMPVmY59aQAT64jQf9qXrACKOuV=DfVs4sNySCXJhkdA@mail.gmail.com>
In-Reply-To:
 <CAPcyv4gMPVmY59aQAT64jQf9qXrACKOuV=DfVs4sNySCXJhkdA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0007.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::20) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b3c6da16-b7de-485f-133b-08d72244acd8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5616;
x-ms-traffictypediagnostic: VI1PR05MB5616:
x-microsoft-antispam-prvs:
 <VI1PR05MB5616D7ED42010F9241692F0ECFAF0@VI1PR05MB5616.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(376002)(39860400002)(396003)(366004)(136003)(189003)(199004)(2616005)(86362001)(6512007)(7736002)(6506007)(386003)(305945005)(2906002)(229853002)(66066001)(14454004)(71190400001)(71200400001)(66446008)(6436002)(5660300002)(66476007)(66556008)(64756008)(6486002)(66946007)(1076003)(36756003)(4744005)(25786009)(186003)(4326008)(26005)(6246003)(316002)(6916009)(7416002)(102836004)(53936002)(6116002)(52116002)(54906003)(3846002)(33656002)(81156014)(478600001)(81166006)(76176011)(256004)(476003)(8676002)(14444005)(11346002)(8936002)(99286004)(446003)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5616;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 aZkmehug+5+JEN4NslXVQoRL/lddKLVuZ56xnkoNM3mlRRM1iDYg8giyqCQ+rqsv3+JshkTMAS3W9U5LeI0HRqKsl1S43Zr3qE/O8ZBVVejOdMMq/D3Fu7xar2O05Yd1rredEABw5axv05P68WM9dv4EMVs7jJTKAe75+OuQ3yM+9MdtMXLOxrWnVry1XlsQZK/kmixAE7cq8G8XEkeHvtrHxSowtp7jwHb5bzLjoCcZTXZZjY67/P8Z74kO5Eo8LDfrECJeDuSh/RMnHNAEI1SkSuUUx+oRLLawpH9cUmYYJ91CfY+SriVH1DF7yMLtxf/WW/h6JKE2U/rpBCnAZ0Gg1V/xfW6MKCaqjHbeJZ/Fh9nbRdaknFcai1YxdKW0bzIGXnhfU9lp4+qaaE6DUb1fRfiEh6HP5HnadKjK//A=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <43A39A5E1EC938439754F1B9A3ACBE6E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b3c6da16-b7de-485f-133b-08d72244acd8
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 12:24:25.0995
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: YUpYwR+jJSKkQAfrI6Lp3gtkUg6E4Ru4V3xRN9XHkNq4GC0s2myrtBg/xfBZTdyh6DDEyWa6d1rPzxxK5bG/5w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5616
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 08:54:46PM -0700, Dan Williams wrote:

> > However, this means we cannot do any processing of ZONE_DEVICE pages
> > outside the driver lock, so eg, doing any DMA map that might rely on
> > MEMORY_DEVICE_PCI_P2PDMA has to be done in the driver lock, which is
> > a bit unfortunate.
>=20
> Wouldn't P2PDMA use page pins? Not needing to hold a lock over
> ZONE_DEVICE page operations was one of the motivations for plumbing
> get_dev_pagemap() with a percpu-ref.

hmm_range_fault() doesn't use page pins at all, so if a ZONE_DEVICE
page comes out of it then it needs to use another locking pattern.

If I follow it all right:

We can do a get_dev_pagemap inside the page_walk and touch the pgmap,
or we can do the 'device mutex && retry' pattern and touch the pgmap
in the driver, under that lock.

However in all cases the current get_dev_pagemap()'s in the page walk
are not necessary, and we can delete them.

?

Jason

