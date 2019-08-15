Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1D8BC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:41:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 511062083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:41:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="bRgOETsH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 511062083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE4716B0003; Thu, 15 Aug 2019 16:41:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C934B6B0008; Thu, 15 Aug 2019 16:41:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B82DB6B000A; Thu, 15 Aug 2019 16:41:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id 98ADB6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:41:38 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 33032181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:41:38 +0000 (UTC)
X-FDA: 75825833076.11.lunch07_656f7aaf0ce5b
X-HE-Tag: lunch07_656f7aaf0ce5b
X-Filterd-Recvd-Size: 7852
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00075.outbound.protection.outlook.com [40.107.0.75])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:41:36 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=N61BRXdMrJbs+iAB67hvB7sBjTxDzxU5S+YJ+XThKFMxoXFxlKVMwkj8UU5L33blgwVQrugodymtKRAJZFljrp210LDdILJ8aXgizmnGdJn9gmLeVYESNPypX+iwpqSCSBL4ev+zxH8YFkQC+0JeHsyAHXVzisKhWUoG3tTJ/crgVz/AknkYSNmzYMKCnFMICexSlc8ygoAkV8We2U3LfFIDETC6Z1qVjzYBpZLbSrG14M1jzOgxfM+IrBc3Bw20j4CQmzlVWO6ebBzyvDEM643ZNzJ0tQtFJQpq5ep0QlDPhZjtZXbMenaOot8xJFyD7g6YDNOYhBuQqcnwCNVw8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8J6vbzMCny0M9Y2WhM22XSfEOXaGP5rhwsX2c6YCsnE=;
 b=CovEG8nrMPTu8cae/9fVq7tbHvVXNcfMkcWjTJouwLeV8mde9KKvAz7bVV51LGSWmyIwfP2+vcXvzeD5hNoJU30SuItBJ6PM8TdNQ+jqQ/UA1UXaOhcOiL3ngOLJIbc5ekU+Jisxzo7FL2F5AU/WeuG8SmxvEoPfZOU6BPY8raAfoeK6EQVIMo9+KdN9xv0JonHIY4oYrSVXxSn1bX1fHEJVld9jOxj7QMLucHON5hf1ykp/3AD5TlHcWSHKBuMjUyw/jtzZ4chAoDZBPbQXXKGwHxxPcFFES9i5ekEL3lPowNxxq1YiuCFQdsADEH5QzcjEhNTmIplxj8wfHT5y1A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8J6vbzMCny0M9Y2WhM22XSfEOXaGP5rhwsX2c6YCsnE=;
 b=bRgOETsHmSCoYVqwf0dsz7VCCTSo2XHxVmPz3n5KUil5Ul15pbEAEfX/s1O7vYk5gGoGK5ZgZ+yqKUTQGkyg1g/vP8I0yoBfsrIHM6norBKuUheP1P1MXR9ZW13xksXwjNT/WbZhUWdjBZhYcY8quGU/syePyCe/DlH1+bQ7lKU=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4222.eurprd05.prod.outlook.com (52.133.12.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Thu, 15 Aug 2019 20:41:33 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Thu, 15 Aug 2019
 20:41:33 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Thread-Topic: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Thread-Index:
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABojAIAAAd6AgAAIBgCAAAXLAIAAAlcA
Date: Thu, 15 Aug 2019 20:41:33 +0000
Message-ID: <20190815204128.GI22970@mellanox.com>
References: <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de> <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com>
In-Reply-To: <20190815203306.GB25517@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0022.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::35) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1b2b123c-9b15-45c8-9bad-08d721c0f58e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4222;
x-ms-traffictypediagnostic: VI1PR05MB4222:
x-microsoft-antispam-prvs:
 <VI1PR05MB422243F481B0B7473E440DA4CFAC0@VI1PR05MB4222.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(376002)(136003)(366004)(346002)(39860400002)(199004)(189003)(86362001)(52116002)(305945005)(7736002)(76176011)(11346002)(2616005)(99286004)(446003)(486006)(6512007)(5660300002)(8936002)(7416002)(386003)(81156014)(81166006)(8676002)(6486002)(6506007)(66066001)(6436002)(229853002)(36756003)(6116002)(3846002)(71190400001)(71200400001)(66946007)(25786009)(66476007)(64756008)(66556008)(66446008)(256004)(53936002)(4744005)(476003)(186003)(14454004)(316002)(102836004)(2906002)(26005)(478600001)(54906003)(33656002)(4326008)(6916009)(1076003)(6246003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4222;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Hn9/f4jS1oreK6D9lcEE8F7owNFeu4pqFf5CCTXuTktZGHxtcpDmViZiustVo9MEza3PWPAYhkb0dwchQdTeJDODdQBGzXH1DdvIKO922nM6c8agb7tYoXMKRoB2d45Fb5yCKU03ZsEjgmqHyiGgykA/8EYvnHQZE6tV7bxueZPJlLLL2+mm+upD8ly7Vf5uQYHG+yS2vtMPGU5sc7JCMhhiu9D7eCuL4GwZYw/x1zB5LsWz3BYmFER+gBx4rE5uRQrdEVJAG41MfEjR2/RoUgF5uhf38a7KA/qyFcubU74bcFfGpL0sivGM3h1JoK6iqqWcSjt8VBHnrqfuaYLawN4JVmJm3w90GfAIzp9zmHJv8LCjX9IawnXyivcgUeUC1AoXufaVKfp502vvgAvKk4KtZIo2kfLGXmvR6Sb09wo=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <83C67FC496A7AF4DAD50FF0383D8AADD@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1b2b123c-9b15-45c8-9bad-08d721c0f58e
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 20:41:33.6094
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: R+VcSZJEpHLkhAxuqrdKAUeR8g8CXJNpnFS8GoIvcGHWg2nIDsMdHldgmhSvr4CEeb7LBr1ZLYVypM4oYNX10g==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4222
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:33:06PM -0400, Jerome Glisse wrote:

> So nor HMM nor driver should dereference the struct page (i do not
> think any iommu driver would either),

Er, they do technically deref the struct page:

nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
			 struct hmm_range *range)
		struct page *page;
		page =3D hmm_pfn_to_page(range, range->pfns[i]);
		if (!nouveau_dmem_page(drm, page)) {


nouveau_dmem_page(struct nouveau_drm *drm, struct page *page)
{
	return is_device_private_page(page) && drm->dmem =3D=3D page_to_dmem(page)


Which does touch 'page->pgmap'

Is this OK without having a get_dev_pagemap() ?

Noting that the collision-retry scheme doesn't protect anything here
as we can have a concurrent invalidation while doing the above deref.

Jason

