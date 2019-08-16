Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0666C3A589
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:41:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F6A32086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="FhCr1UIV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F6A32086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A81E56B0003; Thu, 15 Aug 2019 20:41:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A31FB6B0005; Thu, 15 Aug 2019 20:41:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F9266B0007; Thu, 15 Aug 2019 20:41:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 682AA6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:41:04 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 110DA181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:41:04 +0000 (UTC)
X-FDA: 75826436448.11.leg04_930a5fc1f538
X-HE-Tag: leg04_930a5fc1f538
X-Filterd-Recvd-Size: 9066
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130047.outbound.protection.outlook.com [40.107.13.47])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:41:03 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=e5p5CyHIUzCSSrJeO5uAsNtQcuzopr5mlYvO7SaFWLvj6XNGZKgKTGE48KfCEa2N4D4o7mR9bOrSURSTzT1KqB/O6QGXOmAbCDOjDRTw6l8IFa10o+RpoRaACg1sLe8BCXVATQR9w1/ZrXvjgyJj5RbliEgffVwzmfyLN9sHjygqHlKDClDuD9V2v5LjTXz6EvnOHwR547dLVoQoyh/c4wmZBdP1an7Rv1vX4/CY7GvEXL4atH7EIINkcthLlMwKqlHcFYiilLBdmLzsqF/oiHz/mKIstTRlxZG1ar1hgjPCkTuYwt9tLwZViN6efTPZKAwrhzjGNk5Q9+EFEJ8YIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+DCteYehywwepGi3ED0xAnMez/BPDSTPzccywWA4yww=;
 b=AvYD0vXWJKfOs4T6CeuPKuKH7ZV0RwheCUdDIS3L/FfBFOj40xPRRwzekasiJV7w3WcoptO9PuWaRvCeaP0aBVbPeDDLzHhOOkyf6yBg7x1J9Ia64bf5EoUAYaxnzMDq5WEKPSZVJD1UHnpQrqJzin8dv89KT34eGkqbh9LK49gE0eV0LOakUs+pAiA1NruXLOwVRzWwtRY6PMhF3y6jSWVOnIpq7HtFc5gZPWZjMlvRShvUPC3UsU4roPLB33QADoQ9JBr4ZztQdQ3m4AVhzHDwi3UhTXG7IzXx2W2cYf7q1b8U1h38IcaOt0m13vBphM1nbF8m/sCXKYO2MUunEA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+DCteYehywwepGi3ED0xAnMez/BPDSTPzccywWA4yww=;
 b=FhCr1UIV3ufrdsOmXQHr4EkLsItfBSUflgC7s3Kfy/I74C6KhwTGF3qfnc+n/idaSUS4kqmjHgf4+JLBzBHgNvHNTNxyiJyeF2iz3MB1jsMRK9hKwC311p3QfGRHyH5+VpRQa/S9UknfO5KkPZZMy91RENGDuLiZKFLkYu0KqXc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3279.eurprd05.prod.outlook.com (10.170.238.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 16 Aug 2019 00:40:59 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 00:40:59 +0000
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
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABojAIAAAd6AgAAIBgCAAAXLAIAAAlcAgAABmgCAAEFKgA==
Date: Fri, 16 Aug 2019 00:40:59 +0000
Message-ID: <20190816004053.GB9929@mellanox.com>
References: <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com>
 <CAPcyv4j_Mxbw+T+yXTMdkrMoS_uxg+TXXgTM_EPBJ8XfXKxytA@mail.gmail.com>
In-Reply-To:
 <CAPcyv4j_Mxbw+T+yXTMdkrMoS_uxg+TXXgTM_EPBJ8XfXKxytA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0025.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::38) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 48ab5d75-3260-47fe-b49d-08d721e2687c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3279;
x-ms-traffictypediagnostic: VI1PR05MB3279:
x-microsoft-antispam-prvs:
 <VI1PR05MB32794213CD975963896AA3DACFAF0@VI1PR05MB3279.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(136003)(39850400004)(366004)(396003)(189003)(199004)(66446008)(486006)(99286004)(2616005)(53936002)(25786009)(186003)(446003)(14444005)(4326008)(26005)(66066001)(8936002)(8676002)(81166006)(476003)(2906002)(102836004)(64756008)(66556008)(3846002)(478600001)(14454004)(11346002)(229853002)(81156014)(66476007)(76176011)(6506007)(6116002)(66946007)(53546011)(6246003)(386003)(52116002)(5660300002)(36756003)(305945005)(256004)(7416002)(54906003)(316002)(6486002)(71200400001)(6512007)(33656002)(71190400001)(1076003)(7736002)(6916009)(86362001)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3279;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 jfEAVKwFz/MvuL5Yv2GDjifxERHWFDe6gBLNd+J25D5NpBSauEkNA8yNv4+MZirIFoblvGPuYn4Tj5CKr/9wH56+TsRiDCS++jbNgzdHuf357I27fFnBrQlui1i+ZiNhrFE4fvNtJT1NlRR8F/yWkowfXOCFSzblkkTvM6JMD0r92xWAB6RjDAX1tBeu4wsqDwFeQ6pSE79u156F8mt73M2y94dnmaHCgTqAu4z3DPfek136evzwu71yvJ1KKqFhRX3OkSEjponHiIRCFySkio5z/xhWjCYnmSXpt+3DR3awLSLc4nDT5DvKK4x73NoWr4bajLE6hGukcf7Yp7WpuJNVgwO5FD/eq7ea2lkCE5Lc2EO4CCW/KQWJ7TS0YYGrH1HgKCSifuF6PdAx3+Ag3rKwnvT/f5y7T5iB0E9KB8c=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3D79975E0C234F4AAD41952D46D8C404@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 48ab5d75-3260-47fe-b49d-08d721e2687c
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 00:40:59.7212
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: hUbQDpyF0WzOBvhLO6eBjmGh091kuoW/E+52nuO+owpipVj1DklJhY16uuhLK4mHl/TqiQWO6ZuwNFRShD370A==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3279
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 01:47:12PM -0700, Dan Williams wrote:
> On Thu, Aug 15, 2019 at 1:41 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
> >
> > On Thu, Aug 15, 2019 at 04:33:06PM -0400, Jerome Glisse wrote:
> >
> > > So nor HMM nor driver should dereference the struct page (i do not
> > > think any iommu driver would either),
> >
> > Er, they do technically deref the struct page:
> >
> > nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
> >                          struct hmm_range *range)
> >                 struct page *page;
> >                 page =3D hmm_pfn_to_page(range, range->pfns[i]);
> >                 if (!nouveau_dmem_page(drm, page)) {
> >
> >
> > nouveau_dmem_page(struct nouveau_drm *drm, struct page *page)
> > {
> >         return is_device_private_page(page) && drm->dmem =3D=3D page_to=
_dmem(page)
> >
> >
> > Which does touch 'page->pgmap'
> >
> > Is this OK without having a get_dev_pagemap() ?
> >
> > Noting that the collision-retry scheme doesn't protect anything here
> > as we can have a concurrent invalidation while doing the above deref.
>=20
> As long take_driver_page_table_lock() in Jerome's flow can replace
> percpu_ref_tryget_live() on the pagemap reference. It seems
> nouveau_dmem_convert_pfn() happens after:
>
>                         mutex_lock(&svmm->mutex);
>                         if (!nouveau_range_done(&range)) {
>=20
> ...so I would expect that to be functionally equivalent to validating
> the reference count.

Yes, OK, that makes sense, I was mostly surprised by the statement the
driver doesn't touch the struct page..=20

I suppose "doesn't touch the struct page out of the driver lock" is
the case.

However, this means we cannot do any processing of ZONE_DEVICE pages
outside the driver lock, so eg, doing any DMA map that might rely on
MEMORY_DEVICE_PCI_P2PDMA has to be done in the driver lock, which is
a bit unfortunate.

Jason

