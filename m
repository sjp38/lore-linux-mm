Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 301A3C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B14EF218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="xjrVTduh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B14EF218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A70C8E0002; Wed, 30 Jan 2019 15:50:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57CD68E0001; Wed, 30 Jan 2019 15:50:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446EB8E0002; Wed, 30 Jan 2019 15:50:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 015DF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:50:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id x26so555943pgc.5
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:50:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=ukM+GfOJlhFO402vYkxSp1drM1ADaTz3gryXQC6v/A8=;
        b=N5mguZUtO4/+5zcyaldelj1Cd/I4yjEjTr3m18ycn08yYrrjGJ2swlUuobTQW4AXCs
         cY7NzSk/zaAJ5XFLV98kLsZzTmfANXMTvkwBq+8w2SI6To9m0ztlyscdjmSLTZL1v0ul
         oV1Ndd78f+sOLHWcsne6dURI84ug3D8MuFUYmIv+kYRMS/kibepWk+WvIi8Uf20T8QEf
         olvK7/hTXK5PTnvJMXLBFcdk5uCN4br66xME1HFTSk/hsT/uiBQENVIZ5iA6C+X1YECJ
         NsEYgohEVKp81kTZbMv1L47MvwMKGEfdzknDCCw5+uHw2359s5TXMFePWSrtRM6QNRXy
         y1yg==
X-Gm-Message-State: AJcUukf0krwqbRTxJWU+Past6u7QLCn3wbmp4sUUWmJ/ZVhg6EJN6BMZ
	3eRy/sUV7V/DiJmTWLc4ZFEWK3ZAqbu72DbKci4JQTuFtkzY1gXo1pvAm1ghCYhr1QejXyeex0W
	MVlQW3O4sDnAO29BMB4HK02d86tvS0w8Y93fGHvTlmsELsVc2jkG8tFUeZOH/Ayyk9A==
X-Received: by 2002:a63:de04:: with SMTP id f4mr28631592pgg.292.1548881405627;
        Wed, 30 Jan 2019 12:50:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4tXW8KAiSVcAlkhM2vL50Mwh6AjuqfqXRmRdoa1lSqD1RYlg2PDVoRPiXtfDw239dHSf2M
X-Received: by 2002:a63:de04:: with SMTP id f4mr28631553pgg.292.1548881404845;
        Wed, 30 Jan 2019 12:50:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548881404; cv=none;
        d=google.com; s=arc-20160816;
        b=YZJZcMEDwNgVUX5Hgvv/MpaLvUNz7NTdu2LIJZX8/EJWdYDvziLFLhd/FSKx3FIkQl
         N4CUe161HNzvH0hMmlIeUQ4kPZwK2HQKUDHy8A7aOSr1SyrkxJAn5U5w9/oDWoYfQGDg
         GWXPk3cgCN+XBP+zOs6B6PpeP1ol00WGv50zNj0rzoccTP/bdZBj+Li/BxH9wKLbDt1E
         CmUO05pxJAcVuligy+JT+QDWEj/8nIvgmT9gsbDQAkqTQ+L2TEgYR+fqjMADLt5yyXtS
         vxZBTHbjvSkrAxOdRS9laIRR4leUQ85/H1zQy2IDxQEPLuTAiHoruWI0zoXCd6eK1DoR
         +6/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ukM+GfOJlhFO402vYkxSp1drM1ADaTz3gryXQC6v/A8=;
        b=tpjeNiajzf/P8oRzHADkHvnW5S5HczybW+eTlSzGIM33gw+0stf3IwDVnjXbKzUL6e
         IWU+JgHysrh6qLlFEeNoT8dMnXOzEe4ZPN5ln6bQ3Hhlj07qTQmw7jWkRkXTpIO0cOsM
         XLIYrrq8TJD3Z4KKWLJWCFPlW+gnHv6nJ7iAXoaJPDYvNI4k/w9whjNlAIMWa8qhCAL5
         br1c499AvznEIWqAr2F4SLXoBiw4CDqnqGuEpWBU4js4NUbLB2FYQYRHqJXsh5O6Xl0h
         hltafO8XvnBeBwhvdcwtp7g6V+JDmkW2WqBZQesAVtR+46G39iEu+yJwH+TswaSARX9S
         t+xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=xjrVTduh;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60086.outbound.protection.outlook.com. [40.107.6.86])
        by mx.google.com with ESMTPS id o13si2123218pgp.540.2019.01.30.12.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 12:50:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.6.86 as permitted sender) client-ip=40.107.6.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=xjrVTduh;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ukM+GfOJlhFO402vYkxSp1drM1ADaTz3gryXQC6v/A8=;
 b=xjrVTduhTNVPS37/wUS/I/RDJIt7+GfUOAh2W7gCvCaQaOGw9QrcRL+xr8eQXrjeaNPJNP0xA19qhMi0izTGtIHn/X0DYEV3eGTMLs+hhi5t52OsCsFFgWwAe3qsFx4J/f6rvVM1N8NUctrQdUru60Dab+u4H37PcJbokaAESKA=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6364.eurprd05.prod.outlook.com (20.179.41.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.16; Wed, 30 Jan 2019 20:50:00 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 20:50:00 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Logan Gunthorpe <logang@deltatee.com>, "linux-mm@kvack.org"
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAANmWgIAAG8YAgAAHLwCAAAROgIAABioAgAADIQCAAAkGAIAAAccA
Date: Wed, 30 Jan 2019 20:50:00 +0000
Message-ID: <20190130204954.GI17080@mellanox.com>
References: <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com> <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com> <20190130204332.GF5061@redhat.com>
In-Reply-To: <20190130204332.GF5061@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR22CA0042.namprd22.prod.outlook.com
 (2603:10b6:300:69::28) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6364;6:45iwF2MyI8HvFCyFYG/4MKjkKDDFxIydf/ewovgftAaPLE5NcP4GAKNzPUtx2Jdz6+XgDBpjsGA1IBB4zpz1mWFqdj1LC/C91WDymUSPKiomnTVGtoh9hDOHaQaAjfaCPDcvuK7oDOliaGpWsZ65W99sgYs9MORmXUdl0UEKDnXdx9Gj4LwsDNhYDNAbT3rgwOZCA0A1b6Z6SwPdLssnacdnGhXzLuDskK0yXqiZybGrpEr7B1aC1XACHhqIJaWGN32+e0sbr36OGnPawr0Q2KziNFHy+6tMzgyQ/LHu4Wil4QYf3pb4uksioxhs/APdae2W9l8fr2Io4r7tLDQo1iylzUA2uorFBlBztX08B3Lv4xXooCf6KA23iuo2DgfARXfSlvFY70HV8P2SywhDwcU28XMKerxZ4doXccBAoUvAaQ6mDkul1M5UFwAOM8Xpvbld1XuFvmKdcCnAkbKEDA==;5:W5+l8CUYjGrBFcNURPWDvm8mz+i7pm1SDg4sO5+/tBA6/9CHuYYwOfzRA83QxAke37yQboSZzwnQFa2eVOS0hTOtTRY6V/b7mfzUzLDfvr4+uO3YxQ4sCheg+zytzFapc83JDwHM65AbgDIG1Yf5Zi9++pqDMRTLAndnibZ7Y4krRroSwURFCpjlfYBmlyeu5sRWJrV/UM1p09iwB2Q0Kg==;7:IZweDm6srMYohxalZ8pdlPaov6P8jZyKWnB2bWeZMOjm5m4qGmH88T17SCyP2u56Gfe395RfqHEwC/gFPTifdWEj9uj2MSRKKi294OU9m2OdzXoT9MIP1i5ykSlPjT7eFBH9Oc5JVKs/+0RgN6wvIw==
x-ms-office365-filtering-correlation-id: c4c99d73-c147-413b-3088-08d686f4807d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6364;
x-ms-traffictypediagnostic: DBBPR05MB6364:
x-microsoft-antispam-prvs:
 <DBBPR05MB63643DFF81382BAF3BAA1305CF900@DBBPR05MB6364.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(136003)(39860400002)(396003)(346002)(199004)(189003)(8936002)(1076003)(305945005)(316002)(68736007)(86362001)(26005)(81156014)(7736002)(53936002)(93886005)(478600001)(6506007)(81166006)(6512007)(7416002)(229853002)(14454004)(386003)(54906003)(8676002)(36756003)(71200400001)(71190400001)(102836004)(6916009)(66066001)(4326008)(97736004)(14444005)(256004)(6486002)(217873002)(99286004)(6436002)(11346002)(486006)(186003)(2906002)(446003)(476003)(105586002)(76176011)(2616005)(106356001)(3846002)(6116002)(6246003)(52116002)(25786009)(33656002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6364;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 pTIPAPloGX8Fdepj1af5kHbQyHbt1qki7SR8aUDvaF8I54SvSOymycX3jVDnE+da9fHmp7JTla7P3IBh3QnG8O2CL6G5edLiKeptIFXneFd8hUFp22exMRELY8Ee4s7Tknrlb3LDfT4QZNOHRGl2Xfuv5Ukzgb/6NHuQungXkdtiaeZ/8u62vVGMxGF67VSfZKbExGeBB5adfNU6tnY9J8C09hIuhcdWjyxehhlbut4F68EGRaZMcfo0uwAENL4yCKmECmziJdfMl+H+o3OKfJZ7meQDHg5Kq/yaiEUZt7+DUHQa3peOC5lNWGKbRnwvhpSnLjXonhRKwqhPOl6ODUovs2DCgp1ISMcys1bIsfEUp4RhpWNDMmXgJol5hxbf2S7ZPaQcHp8xMsPP//MBo1604YYwyDD1hPw/q4aqzgQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5026D2D732A5D3409D2B6B23F246B7D1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c4c99d73-c147-413b-3088-08d686f4807d
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 20:50:00.5304
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6364
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 03:43:32PM -0500, Jerome Glisse wrote:
> On Wed, Jan 30, 2019 at 08:11:19PM +0000, Jason Gunthorpe wrote:
> > On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:
> >=20
> > > We never changed SGLs. We still use them to pass p2pdma pages, only w=
e
> > > need to be a bit careful where we send the entire SGL. I see no reaso=
n
> > > why we can't continue to be careful once their in userspace if there'=
s
> > > something in GUP to deny them.
> > >=20
> > > It would be nice to have heterogeneous SGLs and it is something we
> > > should work toward but in practice they aren't really necessary at th=
e
> > > moment.
> >=20
> > RDMA generally cannot cope well with an API that requires homogeneous
> > SGLs.. User space can construct complex MRs (particularly with the
> > proposed SGL MR flow) and we must marshal that into a single SGL or
> > the drivers fall apart.
> >=20
> > Jerome explained that GPU is worse, a single VMA may have a random mix
> > of CPU or device pages..
> >=20
> > This is a pretty big blocker that would have to somehow be fixed.
>=20
> Note that HMM takes care of that RDMA ODP with my ODP to HMM patch,
> so what you get for an ODP umem is just a list of dma address you
> can program your device to. The aim is to avoid the driver to care
> about that. The access policy when the UMEM object is created by
> userspace through verbs API should however ascertain that for mmap
> of device file it is only creating a UMEM that is fully covered by
> one and only one vma. GPU device driver will have one vma per logical
> GPU object. I expect other kind of device do that same so that they
> can match a vma to a unique object in their driver.

A one VMA rule is not really workable.

With ODP VMA boundaries can move around across the lifetime of the MR
and we have no obvious way to fail anything if userpace puts a VMA
boundary in the middle of an existing ODP MR address range.

I think the HMM mirror API really needs to deal with this for the
driver somehow.

Jason

