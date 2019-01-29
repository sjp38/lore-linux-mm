Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42022C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D691B21848
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:02:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Y9s1WZWe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D691B21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A8478E0004; Tue, 29 Jan 2019 18:02:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77F2C8E0001; Tue, 29 Jan 2019 18:02:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66EFF8E0004; Tue, 29 Jan 2019 18:02:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6398E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:02:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so8464269edr.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:02:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=FRCEhY1aVU7aCRk7gwI5XUlpl7fXWIkzBIjSfI9zNgc=;
        b=QH7VulGaZcfYldnHpb6CvZ4/o8APpCkuZ6JolYfYkO2McuLxWSFQ83yVZ2GnGAfkyI
         3qagryuxn95kdR0GuZI+2UQf8472qna2cfFil5XkWJF2NO6wQ62d9WHv5aRoBMUGFY2k
         lddAA4nvZPa6eK/qbbXMjHX7srNNS3KvwLsfPnsgfJYWIrwUGqSn1mQFzqGN6d8dyhXG
         zi0khLO6PC41rNnXVTzMDPj6raI+96Oh79SwaB/35GFAB2Zg8j8PbFoqcXoKOHkPFwg9
         /gah+jiTbb5BOB+84lZ7e7dYhQMpIY4ZmxNQpLtBRzrhWHXI6ymWiGS3BlQZf0re+DqH
         QcUg==
X-Gm-Message-State: AJcUukdz+xFw6AsprjHD1GUuss4Dlr11La5FfUb+e248SqFS0QpcRjYh
	BwWLx23C3SOfTaSY/jPushnX4LgwXOowGL8wLSbijEjkiveoJ6to9nLFLf4nQrlYYeM2aGtOYFK
	YjuN5FTqLyj7sVqgFn7uYVXsR9wSTUhG1YCelEqxl2iZljXiWz3gAchkheUIbBBKNuQ==
X-Received: by 2002:a50:cc04:: with SMTP id m4mr27791306edi.171.1548802947500;
        Tue, 29 Jan 2019 15:02:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7xKXcXcC/w0tKk82IrAREMW6j/9JSKhE+9npqMVeTsiVUdbW3NN673kZdkyxXO7HpmDP6c
X-Received: by 2002:a50:cc04:: with SMTP id m4mr27791259edi.171.1548802946694;
        Tue, 29 Jan 2019 15:02:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548802946; cv=none;
        d=google.com; s=arc-20160816;
        b=SEoC2O6HTHRLLbDidXnQGShoa2qDTHiRca8AI4XrJZmAbRsdvLQbuoxjGbgn4guRW3
         8csRuGGVgnba8wl0/jkEnIi1FhRUTeP5gLvc+dFykxY7+Wcjsshm9Qh92PYUE1aetb02
         H8E9PRBfq/wod76+Ngvkp0lj7hBsz7jDPtwJ/jhCEgYIIDjAqdajNGwnldFzj5IF6Kq0
         uQec0bZS78/rHrLVDNmU903ViUM1sb3aB+qXy7Cn32BdP8yZoe214TJvzi9OWA8LhM/y
         XD1TH2XT3AcGfA/dGZP1TDEscgFznDEWA8eu2Eg94B89lkbqYgGmfnpgeDxLyJ16fiK+
         nm0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=FRCEhY1aVU7aCRk7gwI5XUlpl7fXWIkzBIjSfI9zNgc=;
        b=eUurYqpTaZYLYW8zjjYUslPRd4JGzSE2g0kI21UEGQ9dByTC4oQjKBY76+3EwlLogB
         /Enr6TnyVTdokpQ3Ga2SPMJvLhihe/vqKINzLQodKfF4VrYhdJjVJL1ti5l3yTpeQbRt
         B+qolEc5HYr0lIVw9Mmvv7NqkIRDW3j9O6APXplWEGBFUwMW5Xvbz5e7AnPk5EyOw7La
         sT2Jm9Zm46LjQHvcj/CVdH+KGiB8w2HFMjdjleAUr0//itgJTnQrMLuoTV5kuMe+wHSU
         DoYPRqfZIOl0itCjf9+TBH7D8P3d6B0evVFfh+Z5UBA77T61ZlCB0OZu4Y3xBg+D4MMA
         yfGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Y9s1WZWe;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130044.outbound.protection.outlook.com. [40.107.13.44])
        by mx.google.com with ESMTPS id j16si88810ejq.208.2019.01.29.15.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:02:26 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.13.44 as permitted sender) client-ip=40.107.13.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Y9s1WZWe;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FRCEhY1aVU7aCRk7gwI5XUlpl7fXWIkzBIjSfI9zNgc=;
 b=Y9s1WZWeFidSPQoPs8EySuRkQyoFVSXWCyVpjyUbeb5XlMbk1aZWnfsH8WELw8JmAj7ti8Nascx2OjJNNPGhd5MGxir6F+n4Ln5SJQ2JpTelV5aSet3v2IrS1dzQ2bZ+HqNmgmGQ1WIfYtr9mvuD7cDg+WyCAqbjgaqyKmlL2hk=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6587.eurprd05.prod.outlook.com (20.179.44.86) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.21; Tue, 29 Jan 2019 23:02:25 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Tue, 29 Jan 2019
 23:02:25 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAABQ6AgAAJYICAAAV0AIAAIHwA
Date: Tue, 29 Jan 2019 23:02:25 +0000
Message-ID: <20190129224016.GD4713@mellanox.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <20190129195055.GH3176@redhat.com> <20190129202429.GL10108@mellanox.com>
 <20190129204359.GM3176@redhat.com>
In-Reply-To: <20190129204359.GM3176@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR02CA0028.namprd02.prod.outlook.com
 (2603:10b6:301:60::17) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [64.141.16.251]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6587;6:WtWYP2bPjOw7uCYqevyGXvuXPqGrqF+j+zhPWiYSF5nTPElvy+YBHxIOmi1rgYGZb6S8tYOhZd14g1MdGuHhL16eCPE7n15EG676EVmdUXPrxdbL9SA3wUSTUqYFtEweep1x0rC3MXVa6TmbznAgBS4C8AI0CMmHt20nngy9fMKAqCslvqkzJMk0mBc9j+WrgTDX0xPGQBk3/vQSKjK7lZa+J6D5qcBBf2sbPUQu84ErkhfHhBlE4lvVAFyKM3GTE12O62R94j9pYwlm7XtWKauyQwjUUZqnQAphM2fYkzllCtwWb7X2dqZGFI/giAfqaN8HEMBDnH4Mzm0HX8QAbSbEbmafxRCjiwjh1E2y7aa+5DTpu25ifCXx+bEpjI9Pd/sgV6Rqki7SJJCfZnhpzEpRi1eo4fsLkf00mFhfIUiVfnxk7CWv7BEXk4zvvutqW0QnNiHV+r/4NOmSyQ/MuQ==;5:76jjAcaKJ4Hp3sr6+v/a1r3aAdRDS78F/qxqk6J9Y1D+EEFlxlEoi4HxG8R/r6/edwkLXBb9tilQzVJgbdfDcJhKn6W7p3TliaUtQcWsnFv6YwZ3uF123tmnjLHPTonbLYAJZjJ7STwrNiR9nVQsglz/edKO6Bvs6jeovRZ46GV6jWZCGoSLyU8E5vPds8GY64C8IhxWUBaI3eQjeBF8OQ==;7:zqulXEzKuHiKOxER43Qo6Ae/lkRzjrjsqrzA5bnFASp0o4lYGwb/6aaAFejrR9lK3JQq9oFeAy3xYUE5aNctkbkIFOB/LGNnhL+eqljFmJ+fXpWG/mcImjsYFGq6b+VElkiTqAcnr4iv8szU97OgaA==
x-ms-office365-filtering-correlation-id: ed2da41e-f6b3-4b49-da30-08d6863dd560
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6587;
x-ms-traffictypediagnostic: DBBPR05MB6587:
x-microsoft-antispam-prvs:
 <DBBPR05MB6587E91B6D6812D5D308805ACF970@DBBPR05MB6587.eurprd05.prod.outlook.com>
x-forefront-prvs: 093290AD39
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(346002)(376002)(39860400002)(366004)(136003)(189003)(199004)(14454004)(54906003)(99286004)(93886005)(6512007)(6486002)(105586002)(106356001)(97736004)(3846002)(66066001)(76176011)(52116002)(7416002)(6436002)(316002)(6116002)(2906002)(256004)(86362001)(36756003)(217873002)(33656002)(6246003)(7736002)(53936002)(4326008)(6916009)(305945005)(8676002)(81156014)(8936002)(81166006)(229853002)(478600001)(2616005)(186003)(486006)(11346002)(386003)(1076003)(476003)(446003)(6506007)(26005)(25786009)(68736007)(71200400001)(71190400001)(102836004);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6587;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 QnhCELgnzfgkudITzWw8uj1nwD/JAsk4OgZeB8+0Zh1dK8nsbeBJ6IjY5OYb73NGXQkaiZzHbXD92B5vh+5Y59AX6EAczoRyr4oO5gQ/g3+FoWn4ObTm/kN7sp6q474g5XoDW62ExCYqqi9UdhJN5Ryrs9h14f6kEbTrdQZdB0/vpkLOWvzdjueFyJ0VC8Wkm7+vJoz8Ojmu2Fq51OymegoanfCW+VjLIljBap+Gs5MEJkyDaJT4qTzL8OtaYhpjIdTe1BTGo8a+MNNiELuf+znQjHMkGrDpJPelL3iPbPjYM7IvGESuk5EvWnnyosNiBXJVPMnaPpV2/kj+yd4Y/GeXaH2izP24BbeyZlCoxJeYXJ8uKHnjLS++JprB2Yl76fm82HWc7A9E8Wts+JHQRHUuLIgfXfUDuptgVk1mHww=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <80A32BC881EDF545A23BE7BA9D3E7E68@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ed2da41e-f6b3-4b49-da30-08d6863dd560
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Jan 2019 23:02:25.0505
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6587
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:44:00PM -0500, Jerome Glisse wrote:

> > But this API doesn't seem to offer any control - I thought that
> > control was all coming from the mm/hmm notifiers triggering p2p_unmaps?
>=20
> The control is within the driver implementation of those callbacks.=20

Seems like what you mean by control is 'the exporter gets to choose
the physical address at the instant of map' - which seems reasonable
for GPU.


> will only allow p2p map to succeed for objects that have been tagged by t=
he
> userspace in some way ie the userspace application is in control of what
> can be map to peer device.

I would have thought this means the VMA for the object is created
without the map/unmap ops? Or are GPU objects and VMAs unrelated?

> For moving things around after a successful p2p_map yes the exporting
> device have to call for instance zap_vma_ptes() or something
> similar.

Okay, great, RDMA needs this flow for hotplug - we zap the VMA's when
unplugging the PCI device and we can delay the PCI unplug completion
until all the p2p_unmaps are called...

But in this case a future p2p_map will have to fail as the BAR no
longer exists. How to handle this?

> > I would think that the importing driver can assume the BAR page is
> > kept alive until it calls unmap (presumably triggered by notifiers)?
> >=20
> > ie the exporting driver sees the BAR page as pinned until unmap.
>=20
> The intention with this patchset is that it is not pin ie the importer
> device _must_ abide by all mmu notifier invalidations and they can
> happen at anytime. The importing device can however re-p2p_map the
> same range after an invalidation.
>
> I would like to restrict this to importer that can invalidate for
> now because i believe all the first device to use can support the
> invalidation.

This seems reasonable (and sort of says importers not getting this
from HMM need careful checking), was this in the comment above the
ops?

Jason

