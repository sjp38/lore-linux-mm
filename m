Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 663D3C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:50:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA118218D2
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:50:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="A/86TZq6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA118218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0C658E0002; Wed, 30 Jan 2019 16:50:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B9FD8E0001; Wed, 30 Jan 2019 16:50:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8828C8E0002; Wed, 30 Jan 2019 16:50:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC178E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:50:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so347167edt.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:50:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=J5R9sqWOITm7dIyh8ey3iJowDVHZ5LzCc0tWGLQrbn0=;
        b=eBiAxvKT3rnYsajXwJjLEL2f3a2PkFqYGjGqCPG904ytOy67FWB33tGOAveLmqyoHL
         RcEFjJnulyeY5+X5eCUbw+wPnmhbZ/EhI5qack8Fcpb3vjm2GQIf5+Hzde5fcrGNWO1q
         MwALR8akomwN1GZ1c/xyNZ5x03kh0/OBqIrKwtTMwPL1Agx8MGcaIDYNyyX64VBLc1+l
         AsAE2JZhC2HZJU2Qlcv+65IPccZoF+v+3WoMYHjdXW3WGicADCXdDV0orrzFopfJtnne
         7tukADi6FCR7i0WX4YwZcXesIr1ZtN37EmPS72phvw5ZfLbcljHc+JDLFLVLuKcsZem9
         Yo+w==
X-Gm-Message-State: AJcUukexzbGFfcdd+GUlU5ETwmBzmEFKAyqtg++KKgL1GGjhgbAIN/kN
	0gEiUuA6GhnElSDWia63LukYrAbjPNO18CSYTp/y5rTMFlHQ4wPYsTiuKDP9E1NXwcjYk3Ztfjz
	ImIQDnNgB8/0hzaZ4NKcy8sQ4u+Cr/JRKRpv2aDa10W0iSM38jZJWQ/Od/sse7Yh7OQ==
X-Received: by 2002:aa7:d7cf:: with SMTP id e15mr30528542eds.69.1548885028632;
        Wed, 30 Jan 2019 13:50:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Hmhv+pEuVXQXLtUeRdtG6OCklaV2XZOoXkteI9ObB9NloR6S7Av4oIahyNn/O6Lb2yRA9
X-Received: by 2002:aa7:d7cf:: with SMTP id e15mr30528505eds.69.1548885027776;
        Wed, 30 Jan 2019 13:50:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548885027; cv=none;
        d=google.com; s=arc-20160816;
        b=a1jmFfrcdO6WMBMGuO5C6ftPZIY6WZSYjEL6/NEEBZjJAEd8fkuc7kZlf8ggr9bQDu
         WpOo8FbaZ/BpLyX/UHTJs1ASueJn/xFTgXZsNLtaLcO4mhfS7FsGt0hMsVpfu/FICxKH
         cuRAoURkbbcSm5goysp3TeRNsAhWhUz32LMxSuUMX9CR1Yp7Xga8H1GEA6ClvpTr31bz
         Hs3gEIyViGjIdxbucApNkHcyoQ/LGlvk/nYjxMFN1PHNkJ0sPCfTGAy7G/S0YLk8gTGw
         eZWcBJYhctcdZQaNBA7KaF7wEKw9kCiuXt38TEzJNN4Fs514LL+1hylbqTQy3QbGC29z
         YCdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=J5R9sqWOITm7dIyh8ey3iJowDVHZ5LzCc0tWGLQrbn0=;
        b=fyVnPYIuIJrZHrfIxe530iFI4gIDgdYC/tUIIwblpxF6ypTJ2Btlpq6N9GD2kF4eNT
         goxSo62iUfHVxQM7+kCxDLSvKfYWPPE2WB6LSMWMHDvzKH5CPmxPDXhw3q2MLpoVEn6Q
         v3DBJpiGLlG4ZdPj7KNO4RZ6pXAEyYvr/JEIBZK23GKY41Nd080kSG4VCe7dbI+e1eGx
         SE5X+2yccoWoz1nruqecio6eZzUUSKUMKvwIIlk6iSdEznV1GCIavFNL35Hyvbnaoo4V
         21zvfryR468sfq/AYrIachYVoQr1ZIWPiuCfhkb64wI01g11ISAfs4KpWXw5Y7wbJr/p
         t1ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="A/86TZq6";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140040.outbound.protection.outlook.com. [40.107.14.40])
        by mx.google.com with ESMTPS id n5si1328002ejx.308.2019.01.30.13.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 13:50:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.40 as permitted sender) client-ip=40.107.14.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="A/86TZq6";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J5R9sqWOITm7dIyh8ey3iJowDVHZ5LzCc0tWGLQrbn0=;
 b=A/86TZq6JplZ6MHYUWyKqLPZuJ6Fpp3KMm7qQbApZVYQ6fvdvllytD6K/yhphmrwHCVsYqQx8UVJJX3dIoJCktg4T/7nllNbrLLxT0Bi7txoy6+A9RUQL4ZXGtnNl0yfO4dx2EzP9YsWj9qRuTmDqK2jfKTMFpxKD76vuw1ho+Q=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6554.eurprd05.prod.outlook.com (20.179.44.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Wed, 30 Jan 2019 21:50:25 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 21:50:25 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Logan Gunthorpe <logang@deltatee.com>
CC: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Marek Szyprowski
	<m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel
	<jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAAD3dAIAAukqAgAAK3wCAAAOzAIAAEXyAgAANnoA=
Date: Wed, 30 Jan 2019 21:50:25 +0000
Message-ID: <20190130215019.GL17080@mellanox.com>
References: <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
In-Reply-To: <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR0201CA0082.namprd02.prod.outlook.com
 (2603:10b6:301:75::23) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6554;6:lF5SEsb64Df0LE8YFuXf4y4OBgNnsukVHdYOSH2Lc2RMjFEe6VdNuTHQjkeVmt/czO/NeJF5pjYEUni8zVCtlafoaX2HCu2WCpDiAOhCddwAR8KFVQH/PuFDBwniVn9vR7kODSQM+GBXHDLBSwXCUpEqRjOl9EfHWXAmQmjhCv4+cDVRRUS1wLUGLvRAfnvvMTxPjkaAZi7p9VEuIWqRAVgIz9UL48rGTdQhjFYeddtiGCMf6hUQS5lXbmbmp7R3KjPehvUNzei+09r3+s9czlS7i8km8fd8H7vjKYRBrTVbIOfOb9mEFDSSINvM0AX46d5FLWPMD5g0qTtjof1EoS01agqiMeXpyggOE5P/C3wEjjNgQKDKpHrGyGBi/XhWhUB6kSt1Tq5nB7BPAqY2qi3ctd5XPwvrjeUI7EhBOZ/FwlE7jz3FSRxc/7gC09JoyMfF/jJzLXQz83dlhlHT7g==;5:sihb7+NhE+g0a2mp78iwoP9gIPXafpWnZy63+WIKKb5AoN3//C1jxr6p5SuGVsQBpJIbGodc5avE8qMe09Zv5eIRROiEQldCC0N35wac/6ajo+x0qWktxTVz2zPHk2vWD6M2L6B98nDumZZS+L5pmJb3zVOslPQ5e2bLs8alHexYaJOfxq3h3jHeTthyXs5kNpzbnTrqQC6c7DcVEjA1Ag==;7:kWEf8/PqEyRDBjPtSqBgYtOUn58c3iQSWzpVfRltaoqgNECRLtK5wgEB8wS6MaPJ4avyfrYtIHQPg0UjkypeT4yWKFKuPtYEXUGzt5j02BdhgMzUrb/Xxo4rsWfdYxGqp2x0EQZMZMryRvOLUq4azw==
x-ms-office365-filtering-correlation-id: b37cf5ca-620e-4554-d3c3-08d686fcf0cc
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6554;
x-ms-traffictypediagnostic: DBBPR05MB6554:
x-microsoft-antispam-prvs:
 <DBBPR05MB6554425514EA090623BD3B5ACF900@DBBPR05MB6554.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(39860400002)(366004)(136003)(189003)(199004)(36756003)(4326008)(305945005)(33656002)(186003)(71190400001)(71200400001)(217873002)(93886005)(3846002)(6116002)(7736002)(14444005)(86362001)(8936002)(229853002)(66066001)(6436002)(6486002)(1076003)(256004)(2616005)(81166006)(81156014)(11346002)(8676002)(99286004)(6916009)(446003)(105586002)(97736004)(6512007)(106356001)(25786009)(7416002)(478600001)(14454004)(68736007)(386003)(316002)(6506007)(76176011)(26005)(102836004)(6246003)(52116002)(53936002)(486006)(476003)(2906002)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6554;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 icMs6LNg3KpTqcAW+YiwqLE6NzY93sFIGgVBLIVvSjthgEyYhwaQoh6HN4jkEHjFtbjh804K9TxQmTdu48czF+WXUaMTLqzD6RqOG0O43g41+0IWIPcYEduMC1Ta707BltDlJSVjh23+SREFcTpBqY0fa3EozrjhIr/OHmAMcFfuG3wsnpVKnxUDbYia65pa7FKG+MZD4RFV4NKG4+I9HzpR0rwt3I66knXBGs1/BTHUkT/7v823Y6oUqhd6ycqgC0bC71e86X6gIV7eq4AxyU9AU5lk9fld+zpf26ij+vwKuPkrdrbJGCaB/GAGiAZLfM09QnEhXIjcE+wS2R0Gvsr5hx2IQeyPmcalczaQsKMhJ5xiZc+NQ9aPWc0zdwdZ3ht52zxQh7kImi7YLdEc7R/EbXOfLn4yG80NUZCpEhY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <22458AAABB3536449FE7EBE58980F139@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b37cf5ca-620e-4554-d3c3-08d686fcf0cc
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 21:50:24.9309
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6554
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 02:01:35PM -0700, Logan Gunthorpe wrote:

> And I feel the GUP->SGL->DMA flow should still be what we are aiming
> for. Even if we need a special GUP for special pages, and a special DMA
> map; and the SGL still has to be homogenous....

*shrug* so what if the special GUP called a VMA op instead of
traversing the VMA PTEs today? Why does it really matter? It could
easily change to a struct page flow tomorrow..

> > So, I see Jerome solving the GUP problem by replacing GUP entirely
> > using an API that is more suited to what these sorts of drivers
> > actually need.
>=20
> Yes, this is what I'm expecting and what I want. Not bypassing the whole
> thing by doing special things with VMAs.

IMHO struct page is a big pain for this application, and if we can
build flows that don't actually need it then we shouldn't require it
just because the old flows needed it.

HMM mirror is a new flow that doesn't need struct page.

Would you feel better if this also came along with a:

  struct dma_sg_table *sgl_dma_map_user(struct device *dma_device,=20
             void __user *prt, size_t len)

flow which returns a *DMA MAPPED* sgl that does not have struct page
pointers as another interface?

We can certainly call an API like this from RDMA for non-ODP MRs.

Eliminating the page pointers also eliminates the __iomem
problem. However this sgl object is not copyable or accessible from
the CPU, so the caller must be sure it doesn't need CPU access when
using this API.=20

For RDMA I'd include some flag in the struct ib_device if the driver
requires CPU accessible SGLs and call the right API. Maybe the block
layer could do the same trick for O_DIRECT?

This would also directly solve the P2P problem with hfi1/qib/rxe, as
I'd likely also say that pci_p2pdma_map_sg() returns the same DMA only
sgl thing.

Jason

