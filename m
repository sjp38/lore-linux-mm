Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7B6DC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:22:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 693A62084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:22:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="CKnq2pWf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 693A62084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FAF06B0281; Thu, 15 Aug 2019 15:22:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ABF86B0282; Thu, 15 Aug 2019 15:22:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09C7D6B0284; Thu, 15 Aug 2019 15:22:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id DBE366B0281
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:22:07 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4D0C0181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:22:07 +0000 (UTC)
X-FDA: 75825632694.26.crack57_86d27b5960e1f
X-HE-Tag: crack57_86d27b5960e1f
X-Filterd-Recvd-Size: 8888
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150042.outbound.protection.outlook.com [40.107.15.42])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:22:06 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=eEMVp3IIsC/6+RlDi6BW1b7S/KaSDST+fT/09/JqlDCNGOOqCuaRu8TJLriY1KPSZvwHnupvuH8LnqmHCApl14yLf/CLayEqjojJfK+d6mIGAn7TWquxbtRFy0E5CGWgrkDNlKFKxr9tY4Dcd1kULiwN/1BW00yPp22B1ecUZLYjn15dG4FI3hCIQe6Maw6s9iToiE3bonZH5fVpKbq2W6OR90tqGaIFCBaRylGEJF/N1wKeZOxiB0uejAeqJpU5vsx5WXP+uVt7hF+uedgRdyujCtf38VbPikU/7pc0C9/c+TdCp1s69/kUiib6KAI9l6TGCAe8wxdWYOyxJC50nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=C+Nsz8JNQsDfD+B9cwVgtusZSzpn1jdQQMMPk9A1PfE=;
 b=BIlnRDgl0Vusv3dNMyk2Vw9FsM6qqX2p9SLuxjY2W7TbR/SE3Nwrsfgoou6+MroWAuNde4aC7nuYk1PiZS2MUAoPJleut0s6Ez0SO/9mFg1XNZKQzC6LnD5fVRlLvc6Dv47MkcHJotb4cJepsfeZ+ynCJrBgG2gAmCXre0lbSvnYTYFvmbo7Ilyf0JCUUKomFGTRIJqjmv70DHIsHcVU7yeXZDcOTfSEAt2kNxkz4GV0fAnP4G/3eEduP7LbnycyEn7Zn6YFZKa5/T3EwdRzCp++Bw5n+lgzi08tCXGW+7zXj6nejbVosz6zmQoPbyCCAKuMNkvpmCiCr3gxzbnTJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=C+Nsz8JNQsDfD+B9cwVgtusZSzpn1jdQQMMPk9A1PfE=;
 b=CKnq2pWfwkJWkxrvw7vLKijTlbzNmf2PVV+ALVhA736j4aYd+Vfo3z5l2o3NWQ1vFShmzG5p3YeIPT37d27NLHlGpVNhZx/2Dz9ZBxwAaig/vTwLbHV2nPWeuBwMnjToIybbXPE651rU2/0K5t45823U5xIkKXdE1O+9PAEIXgA=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6207.eurprd05.prod.outlook.com (20.178.123.218) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.23; Thu, 15 Aug 2019 19:22:03 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Thu, 15 Aug 2019
 19:22:02 +0000
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
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABXxgA==
Date: Thu, 15 Aug 2019 19:22:02 +0000
Message-ID: <20190815192157.GB22970@mellanox.com>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-5-hch@lst.de> <20190807174548.GJ1571@mellanox.com>
 <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de> <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
In-Reply-To: <20190815180325.GA4920@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0035.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::48) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e8e868ce-1e09-4fe7-c19f-08d721b5da06
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6207;
x-ms-traffictypediagnostic: VI1PR05MB6207:
x-microsoft-antispam-prvs:
 <VI1PR05MB62073BCAE334CC1F11F8D415CFAC0@VI1PR05MB6207.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(376002)(136003)(366004)(346002)(396003)(189003)(199004)(66066001)(25786009)(6246003)(8676002)(14454004)(478600001)(6916009)(7736002)(76176011)(81166006)(102836004)(386003)(186003)(26005)(53546011)(6506007)(71200400001)(256004)(305945005)(52116002)(8936002)(71190400001)(64756008)(66446008)(5660300002)(99286004)(66946007)(446003)(486006)(476003)(2616005)(66476007)(316002)(81156014)(66556008)(54906003)(11346002)(2906002)(33656002)(53936002)(86362001)(1076003)(6116002)(7416002)(4326008)(6512007)(6436002)(6486002)(229853002)(36756003)(3846002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6207;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 SvLJ8MxOIqnPXh5qm0c3ngH3VI+0afAR4OX2IzZmLgTZd6sx8zPtyffMvRGo6FEFrYLx7iEcja8FIYDlOwDF+qIyWavv7QWQi9ioqw14T7+ftmpo59w+ZbNxx4WclurmTcCVgQrQ80JUZvSB9KUBj/ka7vKvIhFD4g4hPKbPx2urMgUWafmstjr36Tbw9Y87opcmjdyFTwgN+Kg9pT2YmtJela/1FI/Gy0YWbl43sDgiVR1GJQDs/JKt+W6rnkp5v99+7y4wOq4ujJZ7o75SfnzlgoOd1W5sxL8H22K6fFkNbZaHcQSZmgsGbJuOnnhOra0dmm7uNvN5Vu++DOoLP8HXswJ3R/Sadhh3NtUYM2vyuQaSeZ0nLEbceAhlfM4219VhdBHHZXpbv9JRyBK399dR9z7bgqkdmzWfE36wCao=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <45C50639B74BC0449B53AC8E6F4A6DDB@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e8e868ce-1e09-4fe7-c19f-08d721b5da06
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 19:22:02.9196
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 2vFTB0+yKuq5On5J5G9lbqd9I2G6xXxCbN/18vAq7tme5oNNCFMxgV8VNc2bYgLIod3sA7R5ZR0XiZlpqMy0Xw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6207
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 02:03:25PM -0400, Jerome Glisse wrote:
> On Wed, Aug 14, 2019 at 07:48:28AM -0700, Dan Williams wrote:
> > On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.com> wrot=
e:
> > >
> > > On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote:
> > > > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > > > > Section alignment constraints somewhat save us here. The only exa=
mple
> > > > > I can think of a PMD not containing a uniform pgmap association f=
or
> > > > > each pte is the case when the pgmap overlaps normal dram, i.e. sh=
ares
> > > > > the same 'struct memory_section' for a given span. Otherwise, dis=
tinct
> > > > > pgmaps arrange to manage their own exclusive sections (and now
> > > > > subsections as of v5.3). Otherwise the implementation could not
> > > > > guarantee different mapping lifetimes.
> > > > >
> > > > > That said, this seems to want a better mechanism to determine "pf=
n is
> > > > > ZONE_DEVICE".
> > > >
> > > > So I guess this patch is fine for now, and once you provide a bette=
r
> > > > mechanism we can switch over to it?
> > >
> > > What about the version I sent to just get rid of all the strange
> > > put_dev_pagemaps while scanning? Odds are good we will work with only
> > > a single pagemap, so it makes some sense to cache it once we find it?
> >=20
> > Yes, if the scan is over a single pmd then caching it makes sense.
>=20
> Quite frankly an easier an better solution is to remove the pagemap
> lookup as HMM user abide by mmu notifier it means we will not make
> use or dereference the struct page so that we are safe from any
> racing hotunplug of dax memory (as long as device driver using hmm
> do not have a bug).

Yes, I also would prefer to drop the confusing checks entirely -
Christoph can you resend this patch?

Thanks,
Jason=20

