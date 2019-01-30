Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632DCC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:57:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1074B20989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:57:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="nwd/mVqG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1074B20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B804F8E000B; Wed, 30 Jan 2019 13:57:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D748E0001; Wed, 30 Jan 2019 13:57:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF928E000B; Wed, 30 Jan 2019 13:57:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38A3A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:57:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so199537ede.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:57:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=sAsLbJvqRKAMHlESUaU/IF1CHDloyaFofQ4JdwO+j/Q=;
        b=hK0wTQcMmKw2ay5KMdRNTE9Qs23MJz2h8TLWnYOOtw9CqZFPiU79EJa2nevWhQTiFh
         3SPpc7hHDdeB6CD+iWYBO0VpIEBzvdhRHkJ9G5YhCQ+/6uMlKn8vL7z6FwyH3zpl13AF
         Z/uZ/msPWri5Q4MOYtiDrSO39RJpxbJ+KJHi6l+5S6hkxFy2//f4baTLspxNw0Dm7LtO
         pZ6Fhq9famekeaV1r63x50O9j6ifhL8uUC7wrAL8xZHPdp4uhPk6G52KtSrfmZndhRPM
         UEO4NM26dTLqvdRKJ0pmt8YzCWEalN2Z/CkfFgbSroWS4R7+7OtWmrbePOfkzrqNvHFW
         4XqA==
X-Gm-Message-State: AJcUukdYb5QLtvAgdLlm1nBbU2DIwOlcneNOnRXdnaaFu6L5W7Qw1fh/
	9Ql/BrETfaH7NoZ8N/b5kPy1LH6L4c3ScFoYiZJPsyQtZ8o/DNen2QQUD6OPR4ywUZ8glCr0d5+
	Mk0HTbmAQ7GP5mHawjMjmdBi9Nh40huEM6Ss7yQMd7+LTQuJH4RV1T9i+2egercAtkw==
X-Received: by 2002:a17:906:2799:: with SMTP id j25mr25410713ejc.151.1548874622748;
        Wed, 30 Jan 2019 10:57:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7YctSNAgr7Pm10J4zR8t4Etu1/xEF7JpV5O3QqMI4Eyl2zNeM/CwUOJN7IUJJtG0Hx+DIa
X-Received: by 2002:a17:906:2799:: with SMTP id j25mr25410653ejc.151.1548874621634;
        Wed, 30 Jan 2019 10:57:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548874621; cv=none;
        d=google.com; s=arc-20160816;
        b=LlpME83Yxl/dDIlJzEgpqKDZew6aEpD7I02eBZVJ5Y0ztRK1+jUBKbLk+N25ohk/CT
         KpXZuTihmGAxyHtlxmjOvlRB/gS+ItSWlqetaf/B1rkLhq4Yla8QP4MYCNfg5/7AY+D5
         XkHL/vctagVNinE23356llj2r+wlOzyiVJOr/sLpXT7sPYtoqF3uclRLzcoYEDhXFcNA
         NorCFWUh+k/b/Nz8Pl/KMIEJB0fODIfe94cmnNlwopT17/hAxDMD4RIVfIYSF5AAqFew
         ce04VTkrt7CnFvubOHR1frF5uDXySfHCNVg3i7tMj+rwCNo3R+/DI0f8PdX8Nx4+Sys2
         wTAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=sAsLbJvqRKAMHlESUaU/IF1CHDloyaFofQ4JdwO+j/Q=;
        b=dW38mMNpAD1q+7MU4OFJWkEMtns0d3Pj6foLkN4ieXGk4uTquNSKZLMJyNuqHkIm4C
         EJU2s4VH8Lmqaqh4eBX0CX+IKOkQSDLvpbcunpVrBQbn7MzGkryA8us6LNnbGmKBC4tU
         eRwELteiwdKXraA7YtT0OFYIVLD/g+9HJFCPtJBVeNQt0VxQPCxvI7CkCLp5hqNjjpMR
         C1KwPAw/6f7uq0CMriDggi95Oj/h4swAhy1+lGbbvr3xWZ4t2h6gvMqWDDubMzzG1ah5
         Z5OCY1XbOfe9bqQ1yyBRJuMvNqqdTCCvExBPj/5urmynIJ1Y3hCe0wrCZJRIqyIs6WZ9
         exwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="nwd/mVqG";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20040.outbound.protection.outlook.com. [40.107.2.40])
        by mx.google.com with ESMTPS id x12si231066edh.28.2019.01.30.10.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 10:57:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.40 as permitted sender) client-ip=40.107.2.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="nwd/mVqG";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sAsLbJvqRKAMHlESUaU/IF1CHDloyaFofQ4JdwO+j/Q=;
 b=nwd/mVqGQA9Jjn46fjuEEcMgSAPxJvX53n3VdgPDMzL09QaaPEUUO6BchlmkzGauqhv9BRw18mntznyxbiUhJEIvmYVQ//COD494s5IX/6lhmv3SLCEy7JVT7q8Ym6tVid2qu2bs8fHoLwvYPaG0JwpjlFDvO6ik6yvwi1fTa4g=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6588.eurprd05.prod.outlook.com (20.179.44.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.21; Wed, 30 Jan 2019 18:57:00 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 18:56:59 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAANmWgIAAG8YA
Date: Wed, 30 Jan 2019 18:56:59 +0000
Message-ID: <20190130185652.GB17080@mellanox.com>
References: <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
In-Reply-To: <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR0201CA0023.namprd02.prod.outlook.com
 (2603:10b6:301:74::36) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6588;6:wIiOV3+XQykijZwlFzhpj1cxN0rawntoo8s8I71A8AEKJqkgEfFnm+BXP+9w112YlRn9AJqEDWRbm5y2EoA9D8BLyQoRvM0GOFyunv2ycQWnnVhqZ9ygA9sKvAgwWtGAvvJHCE2lq1NlvXPNSw8NLzffi6YdJRWcvkUskS73J8JcivfTZplMQFnXVpzLFXesvvGMibEXcE5u0r1K7oAZhTjBy4Q873U7+nlA0s+RnqmRN3WBEzPJNGKpuTYr1HOi6k7HA1v7T6jbiX3viXWqgWWVneSzACzZJQbQeB8XXK1TRPCY1O4BDWEeiFkhXlbB255ZvEB0s6ZKy+YMa3MiuunwYqoTkbIhxYvUKhaZh49RTDmRn2Sbsw5c2wT0jSCN0NeUGHCZT1zCC7qEGYHImOFcnWPxHRaPxEIkvYk1hP8oplQtSgLRWyRDOBCtvWn1GyTYzvZNMhLI7jvxUVgOsQ==;5:kLnoR96kojFrXkX2i7PVIa4OYm2UGndMIJ987fT/h+re/4nVh4s0II5Egg2BBIBrWP6EdnVQ71eOiGSDwuxSUpSE2l/v9ueHb4R5YY4ALbelCSJpsP1f6XE1s3L/ncDWmL/hwBMquxNp4zvzEsGSVnpnVVnyIaLLqrxdTug52pwc+FRrMiALwxRhH8NhWh9XK8iJ7cju7r/7SJhKSlnxeA==;7:81IiBmz0idVcuPFhtYyY7qaPPQvQ6Ak1oaRBFiIIQuTrAWOo3UlGiUooBKL5KR+ShximYq9oUpK/4o45Dk3Kyg2TMkUS/pwyFD7UPU3ONXiQQjYOrMIrFC8wnrolMlxjpeD9sshCvo6HV0OaduqxVA==
x-ms-office365-filtering-correlation-id: 16ed2920-6eaa-4ab6-1122-08d686e4b6b3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6588;
x-ms-traffictypediagnostic: DBBPR05MB6588:
x-microsoft-antispam-prvs:
 <DBBPR05MB658802F63D4F24D94EFC3412CF900@DBBPR05MB6588.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(346002)(376002)(396003)(366004)(189003)(199004)(6436002)(7736002)(4326008)(305945005)(102836004)(7416002)(53546011)(6246003)(386003)(6506007)(53936002)(2906002)(26005)(81166006)(11346002)(2616005)(446003)(81156014)(6512007)(8936002)(486006)(8676002)(476003)(93886005)(229853002)(6486002)(6916009)(186003)(25786009)(316002)(33656002)(54906003)(71190400001)(71200400001)(36756003)(66066001)(52116002)(217873002)(14444005)(478600001)(106356001)(105586002)(68736007)(86362001)(97736004)(3846002)(99286004)(256004)(6116002)(14454004)(1076003)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6588;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 TovT0yk2P4qIQIbZSaqyL3mj23l7X2/W8kzyn0bmx6bPT8mY97uLGwQqYfaKtPq386CRPm85fgD+FkGZvcrxDXrOTjLP1vNz4xMilW1k07DgKvCKi+ADVlscxak3FxowpYoi8C9ZK6xNV/JZyFJruT5q69VG8fsXsNJe2H36/XUd+zErv6Ns7eJ0kJCN8aqPcgAevtDrjhmTqyPzDjSxPC/5NsjuY7p1MARtyv8q3a7xSCWO8I4meV1C620JQl+eC5HGK3A7wZxAGdmpCVo0G8dafDg3d6UVnPClvvpJJ2RGmLCFS9RPhKx9Vgv+nWvDl98KvcW0kLy/tCLF/H6g8KI+74NkvZN+7+dikrbz+NwAaV8qsWCKogMK5QLQH0wmwkXfVekgUwzfiA7v4RwspCM6QgI0ALFJlGzEplvSv3Y=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1BE0E9896BD5F9418A483EBA3D393F33@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 16ed2920-6eaa-4ab6-1122-08d686e4b6b3
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 18:56:59.5337
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6588
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:17:27AM -0700, Logan Gunthorpe wrote:
>=20
>=20
> On 2019-01-29 9:18 p.m., Jason Gunthorpe wrote:
> > Every attempt to give BAR memory to struct page has run into major
> > trouble, IMHO, so I like that this approach avoids that.
> >=20
> > And if you don't have struct page then the only kernel object left to
> > hang meta data off is the VMA itself.
> >=20
> > It seems very similar to the existing P2P work between in-kernel
> > consumers, just that VMA is now mediating a general user space driven
> > discovery process instead of being hard wired into a driver.
>=20
> But the kernel now has P2P bars backed by struct pages and it works
> well.=20

I don't think it works that well..

We ended up with a 'sgl' that is not really a sgl, and doesn't work
with many of the common SGL patterns. sg_copy_buffer doesn't work,
dma_map, doesn't work, sg_page doesn't work quite right, etc.

Only nvme and rdma got the special hacks to make them understand these
p2p-sgls, and I'm still not convinced some of the RDMA drivers that
want access to CPU addresses from the SGL (rxe, usnic, hfi, qib) don't
break in this scenario.

Since the SGLs become broken, it pretty much means there is no path to
make GUP work generically, we have to go through and make everything
safe to use with p2p-sgls before allowing GUP. Which, frankly, sounds
impossible with all the competing objections.

But GPU seems to have a problem unrelated to this - what Jerome wants
is to have two faulting domains for VMA's - visible-to-cpu and
visible-to-dma. The new op is essentially faulting the pages into the
visible-to-dma category and leaving them invisible-to-cpu.

So that duality would still have to exists, and I think p2p_map/unmap
is a much simpler implementation than trying to create some kind of
special PTE in the VMA..

At least for RDMA, struct page or not doesn't really matter.=20

We can make struct pages for the BAR the same way NVMe does.  GPU is
probably the same, just with more mememory at stake? =20

And maybe this should be the first implementation. The p2p_map VMA
operation should return a SGL and the caller should do the existing
pci_p2pdma_map_sg() flow..=20

Worry about optimizing away the struct page overhead later?

Jason

