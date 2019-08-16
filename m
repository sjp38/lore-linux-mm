Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85285C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A3F520644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="O3bneAOe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A3F520644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3DC86B0003; Fri, 16 Aug 2019 08:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEE8A6B0005; Fri, 16 Aug 2019 08:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADDD56B000A; Fri, 16 Aug 2019 08:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id 8CBEF6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:30:45 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3CC1C8248ABE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:30:45 +0000 (UTC)
X-FDA: 75828224850.21.lead29_5dc976dab1804
X-HE-Tag: lead29_5dc976dab1804
X-Filterd-Recvd-Size: 8946
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60040.outbound.protection.outlook.com [40.107.6.40])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:30:44 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=JVbY7LfEyIJdNeTxiVNpjg8soOzSULsiAsikfD2l9OvWPAPsJ+0oVzFJS1cftDW2qA/mpSDSNxpgvjOOijtLml+HPTH31EfZ4mc8iw13JdEenpQuEBTtjTCZlOTV4sv9him9yJrDj+SYStL+0jf9Ys1StooogyeNzy09GmpA1pcEIL6A8+3YJskgae7cIXqsBytpp0zYwXRWvUCvwb24KWu1el/beKF+uCCO1BmSQihKSVXYmIhf2q1dyh4QEQGb3saUz/JEBPOmkgDGAZrhYO8bz9XP3i0syB1b7kshOuBmtjNJnCi00pO5QBHVaGde/4Xx32KJqIRhSg3lmB05bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bOGQZa/y6vCI+3l18H11F+wGAQN87ScMAfVMnpsg3nY=;
 b=CjsaRoVKF6Tz9MC3LDWUHGJMPgbQVHINFVqPvlNkWW4nytdQR+CAJVNX0fNuHZs6eUj2VMAGtDbe6dz+quCOdGf4Uj+wGh47FD25Jz7coR125O2c85OBbdBhHPqHCor+KU2ZB7X97kYmg3XWwIJavs6Ewne9o1duASuQJIveHhVDw5+Sutituh0HDzllKJW9Kn3f6aPReZ4iRzaluXqIQJ72aOoeVsLqONOsr68Up7DhPBu+uVk/oZSYCGmQJSH0jbJoDVquyd0uZKWjy+Sao2vOCoFYgjYKGcsvh9LDuyyImOHTKVDQkCt0iPqsbuM66rpGBBMdZ0HKW13HA3nETQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bOGQZa/y6vCI+3l18H11F+wGAQN87ScMAfVMnpsg3nY=;
 b=O3bneAOeqve822q6KQopRBAWXIgXfNrmGaioNsKSR37L+suIVuhdDthAlZZ1p+CZB/c6gaK725QSZkgAONJA7EOLUw6/0SuiDRwuDs9Z1Ag0LpYEQhV1+tIQveTx/onjPKfZfwtUZzH3IchxAvVcDOSfr6eOXzLqLSSaLjAbwxw=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5566.eurprd05.prod.outlook.com (20.177.202.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 16 Aug 2019 12:30:41 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 12:30:41 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Jerome Glisse <jglisse@redhat.com>, Dan Williams
	<dan.j.williams@intel.com>, Ben Skeggs <bskeggs@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Thread-Topic: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Thread-Index:
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABojAIAAAd6AgAAIBgCAAAXLAIAAAlcAgAAC0YCAAECugIAAQ4sAgACCJQA=
Date: Fri, 16 Aug 2019 12:30:41 +0000
Message-ID: <20190816123036.GD5412@mellanox.com>
References:
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com>
 <20190815205132.GC25517@redhat.com> <20190816004303.GC9929@mellanox.com>
 <20190816044448.GB4093@lst.de>
In-Reply-To: <20190816044448.GB4093@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0090.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::19) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8bd5ef0b-5722-4093-39be-08d722458d03
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5566;
x-ms-traffictypediagnostic: VI1PR05MB5566:
x-microsoft-antispam-prvs:
 <VI1PR05MB5566068077F360917124F224CFAF0@VI1PR05MB5566.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(396003)(376002)(346002)(39860400002)(189003)(199004)(2616005)(102836004)(8936002)(53936002)(305945005)(14454004)(81166006)(476003)(256004)(81156014)(14444005)(446003)(11346002)(3846002)(54906003)(86362001)(6116002)(486006)(4326008)(71190400001)(7736002)(6512007)(316002)(6246003)(6486002)(8676002)(99286004)(33656002)(66476007)(6436002)(66946007)(64756008)(71200400001)(229853002)(66446008)(66556008)(25786009)(1076003)(6916009)(52116002)(2906002)(66066001)(7416002)(5660300002)(6506007)(386003)(186003)(26005)(76176011)(478600001)(36756003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5566;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 cbtMLOKDHkHplr6hhrcZtSKlLmDw2akKVeqDRfj5uRjQzXoig2As00fytb5enTFhX6Yor0HdVC5wWEf/xvz+2PeKnFWUI86NvQd/nIldKd+KvZQG20/oX8Xx3L+QTX1fLSUJwkZ8sz9pZQrs7bj9t9B2T9sF2StUegHZV7lor5IRYr+JyLbUJbUsR+RUX01lszcr5XxGN/ap/HyvAAobJsurcn2YF3LkoVymgpQZiFPxC/4qkkw/QHpoQokG1RUpPMp/An8DV2or1XspigrHqgoh76c+YnLeaC7LTpyxEg/tgMHkcL+O/jFlWTSVZ9MR9CtEpM3bqrIOXJtWL4KZaAYxS5F87a34M5foGo3/ed3Ql/DpkwxylVQMorR6a6aKeCXC5ktQCam8uCHPnFlv7vj3qQfoPiwwxdLgmgdfiT4=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <33BCB3B7F7923B46ACF944F8B7CA2B32@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8bd5ef0b-5722-4093-39be-08d722458d03
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 12:30:41.4268
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: V9JmvKbt/kiXAfkWhaUpDGrDmw4f2snpJK6AOcCsuJYW96hp+dl/L+IFDSr26v1DhPdnRx+tWPtbIbbsl39fKg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5566
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 06:44:48AM +0200, Christoph Hellwig wrote:
> On Fri, Aug 16, 2019 at 12:43:07AM +0000, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 04:51:33PM -0400, Jerome Glisse wrote:
> >=20
> > > struct page. In this case any way we can update the
> > > nouveau_dmem_page() to check that page page->pgmap =3D=3D the
> > > expected pgmap.
> >=20
> > I was also wondering if that is a problem.. just blindly doing a
> > container_of on the page->pgmap does seem like it assumes that only
> > this driver is using DEVICE_PRIVATE.
> >=20
> > It seems like something missing in hmm_range_fault, it should be told
> > what DEVICE_PRIVATE is acceptable to trigger HMM_PFN_DEVICE_PRIVATE
> > and fault all others?
>=20
> The whole device private handling in hmm and migrate_vma seems pretty
> broken as far as I can tell, and I have some WIP patches.  Basically we
> should not touch (or possibly eventually call migrate to ram eventually
> in the future) device private pages not owned by the caller, where I
> try to defined the caller by the dev_pagemap_ops instance. =20

I think it needs to be more elaborate.

For instance, a system may have multiple DEVICE_PRIVATE map's owned by
the same driver - but multiple physical devices using that driver.

Each physical device's driver should only ever get DEVICE_PRIVATE
pages for it's own on-device memory. Never a DEVICE_PRIVATE for
another device's memory.

The dev_pagemap_ops would not be unique enough, right?

Probably also clusters of same-driver struct device can share a
DEVICE_PRIVATE, at least high end GPU's now have private memory
coherency busses between their devices.

Since we want to trigger migration to CPU on incompatible
DEVICE_PRIVATE pages, it seems best to sort this out in the
hmm_range_fault?

Maybe some sort of unique ID inside the page->pgmap and passed as
input?

Jason

