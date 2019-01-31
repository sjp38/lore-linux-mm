Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B9CCC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:55:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E59D920881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="qupO14Rc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E59D920881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 850F48E0002; Thu, 31 Jan 2019 14:55:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D9F88E0001; Thu, 31 Jan 2019 14:55:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67BAE8E0002; Thu, 31 Jan 2019 14:55:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7888E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:55:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so1773342edf.17
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:55:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=4L3aEF8KGt5ebSlrF0Grkmew6Cb/Utd2G7BT2PIUE2A=;
        b=ZdpKweUuA3Jss+O21ysS0ZOYmtfYJyvSoUW3+bOSmZ9/oOUGfArXYr6RdssKJJEXXl
         u19BOwl9ev4tedy85AFKflXBAWVwBGWU19/3H0KS1KDND3cezzEvEBm38UuAd1Bx5Xa7
         VkFNuihS25QUoG4UDIutGgisSDBdi+0wZsPu8RaevgkPjXzySEHSMx+z6KMZw1I91IA2
         Vq8t6Pa41hi7hGUvORlhckBcld6q9WZibRrqsCTlwVD9/gvMZyOMVBa60YTUr3CqpvlD
         MH9OT0nNl+rSTMMIEDwltTNkH9MPC8UxE8cyzMKN8D95PJihldsDHzSf6kSD6Csa0OMM
         sTHA==
X-Gm-Message-State: AJcUukc0Of0EzNuQF0Lba5Lan1DVJXyaZldVIjYRS7yIyfL37mlKNWHi
	CMg3Ywn8RWnUPxc+9EP66i2kByoK4N6A3U86C3PpPR3hoYmW3X1NFbJZhIWlmYqMn4lXe4GRSV5
	HuUOY3OQF9cXT6F/YNJCcQTYnqiJa85nl7QzxpFIioxFT3HGMXyTGS1bNzxFRNH9W9w==
X-Received: by 2002:aa7:d602:: with SMTP id c2mr35299406edr.203.1548964502467;
        Thu, 31 Jan 2019 11:55:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4McO8DV9aE5DMmSA1cXnJP7X+sB2JSVksY/hRQsW7Hbek8dgv+JdQ6sntELkqBJVhVaJkl
X-Received: by 2002:aa7:d602:: with SMTP id c2mr35299368edr.203.1548964501500;
        Thu, 31 Jan 2019 11:55:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548964501; cv=none;
        d=google.com; s=arc-20160816;
        b=IGNNq/w+9hOluRnyOblqruGKxut1zsY+BNDFdqlnb3trhGiZTni4u6xlWUlNLbezih
         ePLK+9WgYVCUt0dSdnb6cHfsjv4KL4ue/HpLRAonwA27vj9uMD37KLIE0cBcAQlJRRq9
         F6JFQDcJD2zY1loxMIYw2Glp8gKSsNDP77IdqXipxn8l5/8J1v17HvIjWbJi9su24LFV
         FMA7QwMcgxM1G9O6x0/GRMCIvfvlv7aSUVTwDYDRH07juGYqjRlIc1s6Wrg6DHLZ47Ca
         NgKt53m6G6mLCLqpKthK2g10QgNV3lQSOn04pJTv8dTTtXuPIQ4vUDgiREx8hBbEMIhF
         5+IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=4L3aEF8KGt5ebSlrF0Grkmew6Cb/Utd2G7BT2PIUE2A=;
        b=XLXdbX6Ym8bFnG6PDQ0VIF+n73cvl1HrPx7fqgSKsym/hsHv7Xq+Rg2ib0FnFSin8F
         gR9Irp3y4oE/73l9wW7Bl+JvkoN09qa7rqiw3t6HX3FMJZnMvwL5swZ7spE6FqgHZ1d1
         LpFteiNsERlo67qhnN/noHcK9iDFuRgQd23w2xzouyrPNNChCvAgqz9CBc4UgowmxAtR
         K43fQCYF8BX0WOpAQkeKqM4/e8+mvhAtRHlBFvcdRlAzcSg6/jyvZ0FnwwhDhJkTOijj
         kWmS6WWs0Esh3nDMKZFQE9aDDD0ySsIHPXx92lRmORfxwNHur9IRFOXbFrm5teeApBlL
         X/DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=qupO14Rc;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30061.outbound.protection.outlook.com. [40.107.3.61])
        by mx.google.com with ESMTPS id o4-v6si1426712eje.73.2019.01.31.11.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 11:55:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.61 as permitted sender) client-ip=40.107.3.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=qupO14Rc;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4L3aEF8KGt5ebSlrF0Grkmew6Cb/Utd2G7BT2PIUE2A=;
 b=qupO14RcjWHG/2gjR9Nthc9cl5BKQbDU+qwtOldQ5NUPOyLxHEYxrsDgAdEA3IEC1+L19Zk1XRKC7++MHavLfiTIOBVBQC5JMqleRmYLOnEHtA9tDBm4QnC7KDbiah8C9XFW5VL8wZHiAVzH+tjX5e5DNe/nX+qspJ53LIdm4/g=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6538.eurprd05.prod.outlook.com (20.179.43.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Thu, 31 Jan 2019 19:54:59 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Thu, 31 Jan 2019
 19:54:59 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAAD3dAIAAukqAgAAK3wCAAAOzAIAAEXyAgAANnoCAABFLgIAAnPCAgAC1FQCAAATigIAACeKA
Date: Thu, 31 Jan 2019 19:54:59 +0000
Message-ID: <20190131195453.GE7548@mellanox.com>
References: <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de> <20190131190202.GC7548@mellanox.com>
 <e4fd743f-61cb-a443-bc53-9a1c036ebe8c@deltatee.com>
In-Reply-To: <e4fd743f-61cb-a443-bc53-9a1c036ebe8c@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR15CA0047.namprd15.prod.outlook.com
 (2603:10b6:300:ad::33) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6538;6:kIapYD9pRMMtOltM8UsCrgNS5TK4Hcmo57gmQANKSQmzNiD8mv+1eUBhn71sWYqvN5Mnn7Gt7sIe51N5QXD/kWU5PerEcc4/tF0WCuAiH+g697tP0+1aoWorS+V2YDvhHtIB6keVht+njr3exuZTsRGrBwyFCmBVde9b4GgpT/1vaA2TaBNbCv70qdVyR23spjwsWWMdu2+5Kc3nj3ALcM5VraSvtzR9A1qCYpg7JRQ2SrX93qa5O3WF/bKKXUJBVcTU73Pp/tcvZ6DVQs8BUNLoHvLZgJL1hYyur2nHEai9FeBicXMORLlNITbPzNlKYMeoTTUhJf9kWZx6NhKH7ZVrNH3A1yF+2T42ERDgPeBQtG0j33Y/fI5Uc8TV+1Wpeuz696aCH7JMTJMQsu0YCX9Vp7gw+XseCeWNRNCHwIaYJF2tKPaBO286mAY5PdgSzfOBsdlxiaUzUutoCIQm6Q==;5:zp829Chukjpc/dmb3wsLoUVkEda2Y/Fz1kBEuLTFGja957sOy/28OEp1umctS9rLH7ExUCfp92ux7nSM5dwlVqscUuaq3+ifgPx3SaZ9ydQrcX5rE24D5SAY/V8GnVT67xwL0S4xOd7DjMbTm6JD2SkOjom0YHmM6u+7koSej+00LL6t+gbxDUbXl4+YgnAoOQFAwZFZEv+d7MyUm8h3GQ==;7:xXdu+z+rFdqAXTgU0TY/MLv7xKzp4VjQJP0a0d81KGHznfVLV5+E8oijAW/l2fRa7vTQnabkyMLa40ChKTfXFRyRSffm4tqiZ60nSFk7z9KKLhKCDGat3Mj+B5thzGNLQzWmLHrLJU9Wbv19ppJXSg==
x-ms-office365-filtering-correlation-id: 457401f2-83d9-483e-d36e-08d687b5fb41
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6538;
x-ms-traffictypediagnostic: DBBPR05MB6538:
x-microsoft-antispam-prvs:
 <DBBPR05MB6538830010A5167680BC8A63CF910@DBBPR05MB6538.eurprd05.prod.outlook.com>
x-forefront-prvs: 09347618C4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(376002)(136003)(396003)(346002)(189003)(199004)(97736004)(6916009)(2906002)(76176011)(66066001)(93886005)(26005)(316002)(4326008)(33656002)(1076003)(53936002)(217873002)(36756003)(6246003)(52116002)(6116002)(3846002)(256004)(14444005)(86362001)(7416002)(71190400001)(71200400001)(6436002)(7736002)(478600001)(106356001)(476003)(229853002)(6506007)(2616005)(25786009)(11346002)(446003)(6486002)(54906003)(53546011)(68736007)(99286004)(186003)(486006)(81156014)(81166006)(14454004)(8676002)(102836004)(105586002)(8936002)(386003)(6512007)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6538;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 wCWPMAz7RJ//53pPp8RHOUzbX4cRmPez8Ni7a5uPkvB9uoC+4oNzB2aZ4NR7R9WtFeEs9HnWhFR+HCBkWf2FR1Lrq0z1nsaGl1VoW5SKBCOD2G/tC6Kan/1bUEncuGLZApgQkeJbKM22Qpa6OzQ7AuNLOBNkXTNitpOHfzicD5Eiv/dw9aFAla8iDiBVpGuOKrjSZY6e8PYFv+3cZfsG+A/bNQ5pxwy07ZpkzdxJVfphyBb/t/u7Bg3mc71ZuVI/AhuflrJQrnttwT63nRQmX7GiobSiK1ocxOkoWwO0C4s/XyPMhDyuPSUk6aXSLHxdnoXc6jq9WSlqc2eEZPCa+ubHKzRVK6RSOgfQlI8nT1yZDKlYioidnJzs7SDZtnRuw0XyIyEKE7tqGfseXZk2pSkzPfSm4GYVD09+rbSVf3E=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <01E72E6BF04AD94ABCA85A4BF90D23C0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 457401f2-83d9-483e-d36e-08d687b5fb41
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jan 2019 19:54:59.3709
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6538
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 12:19:31PM -0700, Logan Gunthorpe wrote:
>=20
>=20
> On 2019-01-31 12:02 p.m., Jason Gunthorpe wrote:
> > I still think the right direction is to build on what Logan has done -
> > realize that he created a DMA-only SGL - make that a formal type of
> > the kernel and provide the right set of APIs to work with this type,
> > without being forced to expose struct page.
>=20
> > Basically invert the API flow - the DMA map would be done close to
> > GUP, not buried in the driver. This absolutely doesn't work for every
> > flow we have, but it does enable the ones that people seem to care
> > about when talking about P2P.
> > It also does present a path to solve some cases of the O_DIRECT
> > problems if the block stack can develop some way to know if an IO will
> > go down a DMA-only IO path or not... This seems less challenging that
> > auditing every SGL user for iomem safety??
>=20
>=20
> The DMA-only SGL will work for some use cases, but I think it's going to
> be a challenge for others. We care most about NVMe and, therefore, the
> block layer.

The exercise here is not to enable O_DIRECT for P2P, it is to allow
certain much simpler users to use P2P. We should not be saying that
someone has to solve these complicated problems in the entire block
stack just to make RDMA work. :(

If the block stack can use a 'dma sgl' or not, I don't know.

However, it does look like it fits these RDMA, GPU and VFIO cases
fairly well, and looks better than the hacky
sgl-but-really-special-p2p hack we have in RDMA today.

Jason

