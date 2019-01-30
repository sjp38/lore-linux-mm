Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6301DC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAC8218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:11:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="D7I9jHaI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAC8218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A586F8E0004; Wed, 30 Jan 2019 15:11:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A08638E0001; Wed, 30 Jan 2019 15:11:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7E28E0004; Wed, 30 Jan 2019 15:11:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39F418E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:11:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so278058edd.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:11:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=z/d4iWFDvqxqaPKHJn/2sW6NH6J6175ArJyoM+4mbM0=;
        b=FxNMcluUR6uvyRT0P8EOhaF5FgvzeEytEB4rrL71yi3G9UYRnz6TD5pPWes0qp72D5
         CFq6mQ2dvl143dQmC8FO1e2kyjqMPzMSBzbwPRefMFPhcekRwq9bNs21KSLG7Fsub6Ds
         CjG5k/Ndv8CLUqIHm+HtO6/8X+RFeLVJfpz4Kfam8+6Wo2uRaSqTPednI3Ba8dxoYgia
         IOPbWdsv2VVPTG2j5YRphJ/A2EvJ2rPAWlUSUsX1MVoSSvHDyVl91MC0uE8wojKXOR8r
         QjYFLfqQLej3SAPqg5Ph/zK/8596dde7lI9uTzaNRAmmzKHCVjWj1kbz+yJirXZ0GHM6
         cm6Q==
X-Gm-Message-State: AJcUukclV2W/VMlZWRQxG+4adQDqtM57JXQM/3O+WO+vE5r7dXUsSp86
	fIvO33DDoZykv8UInqnjFNWBBS5xn1DVOID6rHomCp+5PDTvgQEbI7NzXW1zsW1WQF3TnsJ0C+b
	3Tz/sZaq75wo30N4Gvvc9txlswoJlJJAP7Dl8m0E6WXxc/cxNuqLU4QGmCYlbVY//Xw==
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr27786951ejr.244.1548879082739;
        Wed, 30 Jan 2019 12:11:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7g15hc7XbyaE37NqjEhPiQ+JAv297g0YfkdYhhiicDdpdo3+8uX7X9otDgeuS71ucDiWhZ
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr27786914ejr.244.1548879081879;
        Wed, 30 Jan 2019 12:11:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548879081; cv=none;
        d=google.com; s=arc-20160816;
        b=BXyjm1hP2UkIagUm0+ggqbu/GtMYiy6jkaiHL+Or7zYmEm+LgR7LlTDo6Psrhjouhu
         48AYvI8xfr8MpgJoNvwE/w/EG1keoyADYTE+d1QzdshlEJJ0SNmNrOiDZNibyuSDHDrO
         7m/7eAG8qqyxPfGFUMv80Z0o6f0um3V/NWstT4qqY2Iw9ZlK4SK9kncT34nRKlwnLWQ+
         xKM9sx/PSOPfW34PZSs9uKQGeLIuFc6ewWcOc8ZsC3Nxsf5mbKTOctsgdecXdB0oYlAX
         5qCjCbAKgyC/nJWPvQHJbFsMdjWKx7A4NmJniJPrITrq+F6V2ghmJPXMr+gYcM8A8iUJ
         Z75w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=z/d4iWFDvqxqaPKHJn/2sW6NH6J6175ArJyoM+4mbM0=;
        b=VlB8vxNw7GWtcTkXVKxY5hXaotFh2uhvur6fbPKplWSbWD/K+KSbbkimv4aQtdFwO4
         4zIvWmnNVbI81+5bbOEXQkznRlbuMKyLuKOLN/1sJzgngeX/0pkkcOnPDb+jGDIw6Kew
         CadzqLGmE1ZBM+ZTi3b/5W3Vwrpe8/zy5pdaPuk919tSGgLdTjOuwJeYmfF8fCY+yAXi
         imIDpH+6FFWbEIb9346gZRpI9DCXbijjPnCcnm8QZoAPAG+b8ZkSm4qolrLgBN1OTDhU
         QwgFmTfuSkfErjzDsO+AEmt3zSksFim8jnhIGMIaXIzx/pAIn3eCxXaQ4leDX2USkNtQ
         Ei0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=D7I9jHaI;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50061.outbound.protection.outlook.com. [40.107.5.61])
        by mx.google.com with ESMTPS id k11-v6si1211413ejb.269.2019.01.30.12.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 12:11:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.61 as permitted sender) client-ip=40.107.5.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=D7I9jHaI;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=z/d4iWFDvqxqaPKHJn/2sW6NH6J6175ArJyoM+4mbM0=;
 b=D7I9jHaI3NCw0GEkjda4NjPmlORlalKVDzuoenMAhNXntmX2r9fqvQs/nEjYwmptnvlztTlPxSt8lGr1xAiW2Vj+fKjdDu8N0bqLmaRHA6U5BS1TIVKhzPFevjiz5eKOI/8xYq5QnTmayV17KH6u4+S0Gfmiy7xmEmwyMYIEj7s=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6361.eurprd05.prod.outlook.com (20.179.41.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Wed, 30 Jan 2019 20:11:19 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 20:11:19 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Logan Gunthorpe <logang@deltatee.com>
CC: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAANmWgIAAG8YAgAAHLwCAAAROgIAABioAgAADIQA=
Date: Wed, 30 Jan 2019 20:11:19 +0000
Message-ID: <20190130201114.GB17915@mellanox.com>
References: <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com> <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
In-Reply-To: <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR04CA0124.namprd04.prod.outlook.com
 (2603:10b6:104:7::26) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6361;6:q3s3M782hLDrroygxK1QdL8JgvtOb2ovBfVLRyNVEdeo8F+j3LBQMtXhrHY9hC5yBKYakn1tJiwEtVA490ni8lsNcM+I2+rrd3myN/yQi/NEu7haP47/fIQ8qiNBg6LGxS4KJFlCezthLVj7mq+tVICXV2SPjlApmdJXdH4kIM5nTi4yaMUzzEL6R+DEZfx94gT3M01E7PeqPJbPqa3T4bK2V0AF+VDXNC+gHI2foLeBjfZ91MSuU2IiCctysHRTy1coI8Pm2BA/FMWQrpVgLjoEjDTm6UlXlW/NL1kjr2PI9rpNdrZMgqLmi/aNHFZ/xgoW+qzBqbMfx5EHRKo8fnMTu58Z1TSEnscXLa+eV9IGUWbHkcSkA3IC5mjXkaaDvzvZJIZ8TmL8eFTJ7kS1IUyp8V69pPgtc0GK7MCrT0t5/wwJMrtVLSYmQaarGl13Bbp9DqHc3muiuAFRgn7dbg==;5:McnnPWHU21mEfNwQhFhiX4yFo4qfJuC313Uu4NkFFZBm4KZmYdIVwHGL0ZS8+7ApfVWp5PkO4VYTbgBKcbdIfGLda7zhw8OEXktmSVBtuvPHL29JWQSqJaQjEBJx2OGfGWb1IM7KHz9n2mTxuIC+lWn8LpO+WKBZZSk2wwpso3Swi4OX/Gjsv7owQubBJ9T1r1yUM907M1jF5TVANns5Uw==;7:5fOJhDjEv9CjOZ8Dmm9/SrNhFa+yDQmrp39zdSfBoQdtAC/vW+FGHLAZ6+yUmnVL1BzwW3e1FcCmnFM6twATPBPHaFQnvNu+N29bQ2CUWlcCVu8ocPoFj/4Qnimp4y+9HURs6o/h6iUTrr2b+R3bhg==
x-ms-office365-filtering-correlation-id: 2207f1b2-408e-490f-d669-08d686ef18cd
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6361;
x-ms-traffictypediagnostic: DBBPR05MB6361:
x-microsoft-antispam-prvs:
 <DBBPR05MB63618885D8E355AFC9403F41CF900@DBBPR05MB6361.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(346002)(376002)(39860400002)(366004)(189003)(199004)(105586002)(106356001)(476003)(99286004)(66066001)(25786009)(2616005)(6506007)(486006)(386003)(33656002)(217873002)(7416002)(4326008)(6512007)(93886005)(2906002)(446003)(11346002)(186003)(36756003)(6436002)(256004)(71200400001)(6916009)(6116002)(8936002)(54906003)(102836004)(81156014)(26005)(97736004)(76176011)(52116002)(316002)(7736002)(53936002)(86362001)(3846002)(229853002)(68736007)(305945005)(1076003)(478600001)(6486002)(71190400001)(6246003)(8676002)(81166006)(14454004);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6361;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0zN5CTWraRYIsQnw7ZFo6j+WCoIOOBIC6WfvLGY4EVz3idYXhWd+OAp+c5xDeX8wAcpOdKAVIBhrPKQzYv5qkAki5KOJgsQKfHvsdD+yIrnKGhtMEW++qSBtVCt+yv13BhHBYUD50+5c0HNBlFD2+f5kJp1oqtnE1cr9ZavSJAJJyxSZwpSQjpLwQhp5mRKm6Vu99Cv7uwMOBjyFNVE3TjqB81IdDNFBWjXmowN9qurBGAkjV0AxtT7t2R8l0kG+zyWo/weJKdetun3zetsGICe5h8PXiN/WEEyVaQ/Wm+TUDKaTltfLrMkOIJ2I0uxt3JJNDNixcChsEJCfvjiwsphHJv4EPw10SZRT9h5gy7ePsa6HDsqWofqA6Ux0SP7Zi0waJB+OM82jtU/jy3Nq9Lb96mVYEBi0lvTCkEQ1/FA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1D7345561BF5804A8CD6EDF49CF98303@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2207f1b2-408e-490f-d669-08d686ef18cd
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 20:11:19.0932
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6361
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:

> We never changed SGLs. We still use them to pass p2pdma pages, only we
> need to be a bit careful where we send the entire SGL. I see no reason
> why we can't continue to be careful once their in userspace if there's
> something in GUP to deny them.
>=20
> It would be nice to have heterogeneous SGLs and it is something we
> should work toward but in practice they aren't really necessary at the
> moment.

RDMA generally cannot cope well with an API that requires homogeneous
SGLs.. User space can construct complex MRs (particularly with the
proposed SGL MR flow) and we must marshal that into a single SGL or
the drivers fall apart.

Jerome explained that GPU is worse, a single VMA may have a random mix
of CPU or device pages..

This is a pretty big blocker that would have to somehow be fixed.

> That doesn't even necessarily need to be the case. For HMM, I
> understand, struct pages may not point to any accessible memory and the
> memory that backs it (or not) may change over the life time of it. So
> they don't have to be strictly tied to BARs addresses. p2pdma pages are
> strictly tied to BAR addresses though.

No idea, but at least for this case I don't think we need magic HMM
pages to make simple VMA ops p2p_map/umap work..

Jason

