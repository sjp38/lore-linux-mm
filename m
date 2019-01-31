Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 013F6C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B9D720881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:58:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="xt6nMu2V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B9D720881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF778E0002; Thu, 31 Jan 2019 14:58:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16E638E0001; Thu, 31 Jan 2019 14:58:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05EF58E0002; Thu, 31 Jan 2019 14:58:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0D08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:58:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so1797992ede.14
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:58:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=p7QQR3lOval8t8mi1Iy1sYHtvwDu1Oz9bkTNPNNjp+U=;
        b=R6TGExr2iERntjjDN/sxompwAe22WZgAeRTt9quuLvtBJn9WkO06YyfOKcIWfbFUhx
         cxH3NSgRQNJUSmwBZ4JX1uud1m81v7v/F/63Ib38MYa0b7R4AsGGyNa7zvJj09rFTiuv
         JZgKI1/jI66ECjMEBp9lmdvHG4s2xZV00b0NW8umnLBWf1ll/PwB+TAWmOA/UGNA8CKH
         O2Cf1f6Ki96xdISIHXAuYI1Vtora5fkA2+lqQxejn3uVe9NOTSV2HBET76RO++Qz6Bzs
         N0spzLvUgwlhNwfumZm1yL/Bb310ZUkKOSeA/AHFOoqlDisXWlprmKgBmvjNKvqrR0UE
         DTLg==
X-Gm-Message-State: AJcUukcysQiZJYUS7ZPsIt3ynQEuDIpE8e5H6+N1ty/XAIzx8b5w9LrL
	vK4yAtBDadZDpGYg158crOc3obCT2Y8iI8p5yCYp4SLBG9JpVnZhVuZ/sBJS1S5C/PEuEfglF3A
	vjlJc0LP/1XqaeFCch0kM+iXcdZrwTi26RVrCM72mK3M33l+XLaZtuxp+sY2lBJWayA==
X-Received: by 2002:a50:b536:: with SMTP id y51mr35204650edd.201.1548964687209;
        Thu, 31 Jan 2019 11:58:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4/Uxe9Qhqpvwz2p0Y2jSYHble6KJogjOEzmh9MzB0UQOhmgFSaXpy/BOOIiV7QcPYUAKOW
X-Received: by 2002:a50:b536:: with SMTP id y51mr35204614edd.201.1548964686383;
        Thu, 31 Jan 2019 11:58:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548964686; cv=none;
        d=google.com; s=arc-20160816;
        b=zBeiodtI8QfeGfsBeIUwx8OXqxabeNV/UtS3KtJ79w2fcJSidWT+8iXw6DB2pZEcQ+
         6CGaANWww17RphUzxgHs9REtZ782HtnIGrCdDlPlK+ZaefKmmPQoAR3XFSlYJ5RrU4OG
         Gu2baSWbrn4zWFFctFrmalNG+awtJojpeknoLyF5Sl816qcEkLfPZ7+li3JrneM2fI7V
         7aWvjG4cVDAYi+L5myG65Flh6cdunXAZbz+hAx7bcHmi6Z/ud26JpcWdStKgntRs4H/1
         EhDn7Qz7iQr4orBe2r8/2PlzLnDazxunrFZnHJEHFZkx65RjSjj0Yq31H4L7A+GJxbts
         IGAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=p7QQR3lOval8t8mi1Iy1sYHtvwDu1Oz9bkTNPNNjp+U=;
        b=F6+c1ptcmCJeYQVKIJP8nqDmkju2+vRvQ6gf1brv/T/GwQEwLl3mpO4v/EKHiIlJ57
         iQVwwlzT2UZavazx7fCU/2yfYa52v3aKKQ0DjJ26HCX5m26+E6z0o3yueElj76Me/IEk
         4ucqBoSZ6KOsakeq6TnoI+RT/KVpKr6wq7ijFPk7c3fUS5jejSWu1lvbsMeM7kUJ3fGq
         JOq/0jQ16djk0Xh+VY1qLU5vs8gpaGRWXesXoq063Ljydk6yUVNkJbA07pkMujVOe/TN
         ZAVMw+hGWP5fcbzanRNFNqatZU+BhIxNd45x7XY4hvLueKzbeL0TYGAXfj7MqcA8W5Mi
         gGtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=xt6nMu2V;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.88 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30088.outbound.protection.outlook.com. [40.107.3.88])
        by mx.google.com with ESMTPS id i18si3144066edg.44.2019.01.31.11.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 11:58:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.88 as permitted sender) client-ip=40.107.3.88;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=xt6nMu2V;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.88 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=p7QQR3lOval8t8mi1Iy1sYHtvwDu1Oz9bkTNPNNjp+U=;
 b=xt6nMu2VTEWg4e1vF3c9JnqyzY4DzzqHHUNUnDSc3mFKPdDH8ykzqlQbUJmrKC93nkSWjlSinHHK0pw6KK9oBzk9z6XLzGrrcR1aKKCL1EZstVKIg40XuZO2V9jdgpZG09Iy3Hw/XkWmjzQf4rVb+66oyhcB6eFHtHTaKQvX1NQ=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6538.eurprd05.prod.outlook.com (20.179.43.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Thu, 31 Jan 2019 19:58:05 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Thu, 31 Jan 2019
 19:58:05 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>,
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAAD3dAIAAukqAgAAK3wCAAAOzAIAAEXyAgAANnoCAABFLgIAAnPCAgAC1FQCAAAlHAIAABluA
Date: Thu, 31 Jan 2019 19:58:05 +0000
Message-ID: <20190131195759.GF7548@mellanox.com>
References: <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de> <20190131190202.GC7548@mellanox.com>
 <20190131193513.GC16593@redhat.com>
In-Reply-To: <20190131193513.GC16593@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR04CA0200.namprd04.prod.outlook.com
 (2603:10b6:104:5::30) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6538;6:emXo7VDo8e4JXSMA0pMHUck9ow4onMJqUSZp9e59FL3XeTCSUl40BjmQWyTehu31c4Un0e7DsDZRCWOFQPW5nj/YGh7uXjKcryp6fRpZjJqDqZiWw3070J3Nr7F+KBwjTiUOUii93TPmwteo/Y//UCc+s7kHUeY+RCd3RNttQh9hPtXbkU5VQF+KCOHXxgHOLtf3Bx0G72oKgzMl13CPjpVJ8gkxl2QD8G1WG/mxk2Tpu8C6JKBrsrM8NrIVMYCbvarw7w2X1Xxo9QTtcoyFZDu8nPMLx4mqvTl2y0SmGY2my3YYzkyhzfpMB/iT2LDuZTGdrPQNBi1eHA0Br59HunzjIFVWpoB75FckCSZMzZGCWr+ncGx256xhuJub47xdXo0aH/bfSRr8KnzepGtqvF2bvjupDzx0dVqASxKfvpm8hWxIhC5hP8bJKZugnnUvR/Z3ZS3y9z+8VT0NDhCdtg==;5:fDO5gWmtrEPdiefLbaSnpsQdjYdhsblgLkqJwzzO8+gAH1k5Uum+3Md8bqo4Ztz9U//jWpPdgr7P2LbxwdzdgfBnLuYM4eORApNG+r6wyw4V46OojS3OnpmfQxAneUxctX4Rl7IXwGntjfwqfg+A5TPcZv6K52Cik0nI+Q2XgOrrvD0yTuVt5k6JBj7ZC/PAL9CCeMcvN+A4xm+0dHkoCQ==;7:XCh1wvXuCHkf+iVmrQ2Orfk2v3OwM0ObdW/tBeC5uttyIWShDNW88QLUwOzz/Dma7o1lY4C1Mih3IsuPKwt3Hlpw1x0UX1LWeoStjhCjFV8swnvSAxFu8W8KRdiQohAsGP3mTF46CEShK49Hr+OoDg==
x-ms-office365-filtering-correlation-id: 40acb946-c78f-4d62-d5db-08d687b669f7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6538;
x-ms-traffictypediagnostic: DBBPR05MB6538:
x-microsoft-antispam-prvs:
 <DBBPR05MB65386A123D9FBB1664E69FA2CF910@DBBPR05MB6538.eurprd05.prod.outlook.com>
x-forefront-prvs: 09347618C4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(376002)(136003)(396003)(346002)(189003)(199004)(97736004)(6916009)(2906002)(76176011)(66066001)(93886005)(26005)(316002)(4326008)(33656002)(1076003)(53936002)(217873002)(36756003)(6246003)(52116002)(6116002)(3846002)(256004)(14444005)(86362001)(7416002)(71190400001)(71200400001)(6436002)(7736002)(478600001)(106356001)(476003)(229853002)(6506007)(2616005)(25786009)(11346002)(446003)(6486002)(54906003)(68736007)(99286004)(186003)(486006)(81156014)(81166006)(14454004)(8676002)(102836004)(105586002)(8936002)(386003)(6512007)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6538;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 /h7vM6jCrY+s60IYJuxncVW2a2w8E6E5t7tI64sI2JkH6SDG+MBxte4QtueocRq6W4RwiovBzclytnmnrqxzWKlIWsMaO2hZLlul+zhg55LagS9vYSa0zWaUajS/eygwVgRMSo8jlIA2sMqt/Izyky83Gav3BEsZuZo1aTmcQsrbO+DFhip1/b5zuCDbOVQHoO3tf/3++iOQptBHLSR6y2lQZX+p7i3XZqYQLzLJ1O2vu2gRbXXBONV4wOrNsnvEUtCb2IlTCQdJIQT3v9foI7NCDrJaUBF/PLtIUiVsrymE3mjD/Gookh3LdFOcr0LJbRe1WdcdyT22+CalIC3387wERSJD5vVtJ9HBHAgQ4ZHhC6LNikruzT5rRt2DBPJPEBJdo0WHsfY/ki9ZKJbqldFrnxU3YNQ+n5us6+xPg8s=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <899A3F71B570B941926CEF47667C9170@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 40acb946-c78f-4d62-d5db-08d687b669f7
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jan 2019 19:58:05.1131
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

On Thu, Jan 31, 2019 at 02:35:14PM -0500, Jerome Glisse wrote:

> > Basically invert the API flow - the DMA map would be done close to
> > GUP, not buried in the driver. This absolutely doesn't work for every
> > flow we have, but it does enable the ones that people seem to care
> > about when talking about P2P.
>=20
> This does not work for GPU really i do not want to have to rewrite GPU
> driver for this. Struct page is a burden and it does not bring anything
> to the table. I rather provide an all in one stop for driver to use
> this without having to worry between regular vma and special vma.

I'm talking about almost exactly what you've done in here - make a
'sgl' that is dma addresses only.=20

In these VMA patches you used a simple array of physical addreses -
I'm only talking about moving that array into a 'dma sgl'.

The flow is still basically the same - the driver directly gets DMA
physical addresses with no possibility to get a struct page or CPU
memory.

And then we can build more stuff around the 'dma sgl', including
the in-kernel users Logan is worrying about.

Jason

