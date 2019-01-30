Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 953AEC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:59:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B26020989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:59:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="LM47/x7c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B26020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83FFE8E001A; Wed, 30 Jan 2019 14:59:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EF6D8E0001; Wed, 30 Jan 2019 14:59:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B7D68E001A; Wed, 30 Jan 2019 14:59:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 130E38E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:59:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so246616edt.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:59:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=BIdbOgJABd7KLeI1CmjED8KrMVhfM8Q7l4vQzya/ACw=;
        b=SBiJlIkPUZxGYPWu5d+3mX0n9o8ZMG2EkmPRDekDwRBARsIc39cZkiKlb3LCxkKK+U
         KPxY3BLQSA7AlgVX91kF1yRbEf987TTh3ngR3rfKpqAkzRQ0dUK565pco0JVvQzWpn7W
         rU1tAeUPMwAwpae6C2OlTZZjcosO8oslP8rSAf6wD8Nu2fOgq3n64xCWkug7T5B9hL77
         /Y/Or2ah9yo0fo1XeLLGx/ugU1g+k+2x2BYTEMJ5seIsG/PYFosynUwd4amTgpUh7IoP
         H6sUOMVW4WQhJ64EUHb/Fm2t6JWHgbRJhjmAo9wLwmwB7ua0NohaBUn/2h3dRKKCO59h
         YuIg==
X-Gm-Message-State: AJcUukc/0gyqUgWKN9zRBTMjwDOpMbsl10GCG4ZbI2caWLfidaGUb3dP
	ryElqTbe4Z2KyV7YVZz0r8VrrQOmWTivLtwHGjf3JGHKlZMPIBk8ZwmcVRj0EfNIayZ8vTANlPP
	hBIOA1iBCA2Fc6GKHA73ni+UQ3J8dRv6E0SVjZ9cL/oYzeMjayqkpVrd0qiYt7hsmdA==
X-Received: by 2002:a50:940b:: with SMTP id p11mr30114735eda.135.1548878349607;
        Wed, 30 Jan 2019 11:59:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6yv3VTtp+5NM9KHU0P1/kaCgfgqhXeS3Kp3WD2R65n52EOEwx/UkJx5pgx9bJBHZJJcyrV
X-Received: by 2002:a50:940b:: with SMTP id p11mr30114695eda.135.1548878348781;
        Wed, 30 Jan 2019 11:59:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548878348; cv=none;
        d=google.com; s=arc-20160816;
        b=1BjShkzg+UYNHB9W+spRMDx02SnDmpt/tgJp14aYUhXcD+LTTZMfttSxc4lFdr5fC6
         CHmdfwNdGikMnb+lrpPVw/V84nWNQ/auXdDL2tT4+Xu9id50ZwojU2HqRcWrKfdUtpzS
         c0jybVcaq5NLMwlKL+q0e+ZL0xTZYZAAic5v3BQKxaaKngwsXP92LJkbmeW6a5GUTxB5
         BO9ErxNtGFUgMhjMTG4Qwfm13UP1p2iPecNl60/ECHDUS6d57oWelCRC8T1wF+ot99DK
         ctzEU0n2pzvjJM8qKEyzdamvIwIyzwXwqWRsbphkSRC0SpXaqZl418qnsUcf4YumVrtE
         6+Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=BIdbOgJABd7KLeI1CmjED8KrMVhfM8Q7l4vQzya/ACw=;
        b=C/uvej3EoQJc6lr4gshnSPoILe6Li//PNT0cLA+WrYul2y0n81B2O9PUvDtFaS10c3
         KkIzrSZVDCc0ewPmSUNkj6yiE6Qy3aP9wtmi24qn46jh/a2SdgavXV958tjb5tKhqj6I
         BBqWWgbdE3hC0Hr6GVHFcoKI2yUbhYsEwnyFiWlSfXx31aH7ULbsAhVe9bFO56Veh10R
         8Lev6n+0kuD94sV63rJIKFhuX6iPK0FIu5Iernwdl2u8yXIlWnuUhJU6fqi9WgXz6YtM
         xkIwbiPUDM00wq8eQM5xHc8AiAptZg5n+xa8B60cTtIyz3F0Cr3REOo2SdsO5ac1QKqF
         7KbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="LM47/x7c";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20084.outbound.protection.outlook.com. [40.107.2.84])
        by mx.google.com with ESMTPS id k11-v6si1200651ejb.269.2019.01.30.11.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 11:59:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.84 as permitted sender) client-ip=40.107.2.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="LM47/x7c";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BIdbOgJABd7KLeI1CmjED8KrMVhfM8Q7l4vQzya/ACw=;
 b=LM47/x7c8NPDcrO/8ilxdcoxfBmd1DDT98cI1EwEqyM4Ee127D/sCSZqKl7q/7UhID4Q1yqLkd2Jh4U3FS3oTt65RunJbwqgnXAPxz3pYatehSieQp+f6tGK3zyg6lXTVReV7+D26Ih9M5YPuXmYmwrtGnf3VFeY4fsWFYkoDQI=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6299.eurprd05.prod.outlook.com (20.179.40.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Wed, 30 Jan 2019 19:59:05 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 19:59:05 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAAD3dAIAAukqAgAAK3wCAAAOzAA==
Date: Wed, 30 Jan 2019 19:59:05 +0000
Message-ID: <20190130195900.GG17080@mellanox.com>
References: <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
In-Reply-To: <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR05CA0091.namprd05.prod.outlook.com
 (2603:10b6:104:1::17) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6299;6:dWaIwtpfvMT1n8d8go0E38bYF8m4oeW/q5wvQE0PDLG7d5739Ic2u5+Bm+CHql4QKxsqqnXVRWcQiDqHXY16rolSJxjZK/ONK2UtUWI1ba/Wl80+k+biwagYEGPfMlYAYKTdtTyTv2bnDcjkZLlPX02Q2g1zJGNDnJup26K/rXtJXCYpjcBV2Nw3IUJrVRxQmqI99DobJpfAv72VCqIpUHzDwVqCrqluSRKSWUYjcbsH/DxVep7Dk86hnSGg9BrrBvWnG08aTlC+JMnQ9edlPEktJI8hINdlROKPihIAm7Cr42UKqJniBLGPia5cUlym0gR7AgiQnJZjuUBCabShsUtMhlqHxUmfBKDyR6s0xupim9YL0J6q7G+q0CN34AmVDr6JONuNHXhKx7JxIaQKG8GK2wDliVM/QcU+xGS6l1qlB/7CBix8YCcW6Tg/N1cfJ+5wcOzImgtG9I+gEe6eOA==;5:uh8XZd16uOJEPg9j1IBqo6RU6lEK0mJPOQRARIVeBdBlj02U+4O6JxmBH6eWMwYAl7jpcsEw3Y1+wID+J7YgRpMXdWj1hM3lScP3+w4/pd5iuNuN2iaeoGn/tTO+5HYOjWIuy8ir+abWGSUMPz4eiu+LQtKb6EjeyTvxMU8GsAxMl2+D0XMOT+HRAFAVbL9CyMNsWNKSKknDX+/SsvXokw==;7:95BftNDrIfkiOVpkyAoN8E9WWz+SSQMSBjIz9z+a+k3/cLLsldRmZhKtNBIz1QKuLVDX6bSjCWK6LcDD44ieeLPAKZHr3rYdRWUq3zsmklIXXrc+gvXgKydBjTTUDzMKVkcZIpdh/xFBVPIlozdVjQ==
x-ms-office365-filtering-correlation-id: a5d0ff03-7000-466f-1ede-08d686ed637c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6299;
x-ms-traffictypediagnostic: DBBPR05MB6299:
x-microsoft-antispam-prvs:
 <DBBPR05MB629918774783D976D95FA311CF900@DBBPR05MB6299.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(39860400002)(346002)(366004)(396003)(376002)(199004)(189003)(4326008)(305945005)(33656002)(102836004)(106356001)(14454004)(6486002)(105586002)(6116002)(3846002)(386003)(6506007)(54906003)(53546011)(186003)(6246003)(1076003)(7736002)(316002)(217873002)(26005)(229853002)(36756003)(7416002)(81166006)(8676002)(81156014)(25786009)(6436002)(93886005)(71190400001)(66066001)(2906002)(8936002)(6512007)(256004)(6916009)(2616005)(71200400001)(76176011)(446003)(97736004)(68736007)(486006)(86362001)(11346002)(476003)(478600001)(53936002)(99286004)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6299;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 AlJVLgDqBTdS7eQNfzBsoru0CLpYTzaLxiQLvoKgHwb7z6poB7cdJE3qGBz9hKyHHwybk7gIezRAjdyFRrYUJ+b/ZRC7Hr1tRxQX+XbljLMasl+VqTMbzqTiOF7MY/81zmpF5DNDaGbQ5Rn0f/IvcHWkHPI9WXiBamTqXL2vDvy7Q1kPxLjbAzmX/xW8d8Jge4BKmfANtPV5Id23m5pKiUIiadNvfJJltLlhrXx7I/OXo/1lQQD6uHdt7xTRmojRwPIGX++BXCoo+h26EmKJz4jYWhetjZ6U4CWYiuyehRVNNYNA1ZLzBvpMiO64Cyix6+ncdlbaLRdYZlqsPNRWHrr0t2Bx2lrxCift+syEino5wjSXobrTtheEMYA+o8wKA7PliC5k0+xjz3zKk3tpHdK4AO+FbYkU3hXX5Fd1ZyY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <178449172A1D534BBB231D50EE6C616B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a5d0ff03-7000-466f-1ede-08d686ed637c
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 19:59:05.3923
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6299
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 12:45:46PM -0700, Logan Gunthorpe wrote:
>=20
>=20
> On 2019-01-30 12:06 p.m., Jason Gunthorpe wrote:
> >> Way less problems than not having struct page for doing anything
> >> non-trivial.  If you map the BAR to userspace with remap_pfn_range
> >> and friends the mapping is indeed very simple.  But any operation
> >> that expects a page structure, which is at least everything using
> >> get_user_pages won't work.
> >=20
> > GUP doesn't work anyhow today, and won't work with BAR struct pages in
> > the forseeable future (Logan has sent attempts on this before).
>=20
> I don't recall ever attempting that... But patching GUP for special
> pages or VMAS; or working around by not calling it in some cases seems
> like the thing that's going to need to be done one way or another.

Remember, the long discussion we had about how to get the IOMEM
annotation into SGL? That is a necessary pre-condition to doing
anything with GUP in DMA using drivers as GUP -> SGL -> DMA map is
pretty much the standard flow.
=20
> > Jerome made the HMM mirror API use this flow, so afer his patch to
> > switch the ODP MR to use HMM, and to switch GPU drivers, it will work
> > for those cases. Which is more than the zero cases than we have today
> > :)
>=20
> But we're getting the same bait and switch here... If you are using HMM
> you are using struct pages, but we're told we need this special VMA hack
> for cases that don't use HMM and thus don't have struct pages...

Well, I don't know much about HMM, but the HMM mirror API looks like a
version of MMU notifiers that offloads a bunch of dreck to the HMM
code core instead of drivers. The RDMA code got hundreds of lines
shorter by using it.

Some of that dreck is obtaining a DMA address for the user VMAs,
including using multiple paths to get them. A driver using HMM mirror
doesn't seem to call GUP at all, HMM mirror handles that, along with
various special cases, including calling out to these new VMA ops.

I don't really know how mirror relates to other parts of HMM, like the
bits that use struct pages. Maybe it also knows about more special
cases created by other parts of HMM?

So, I see Jerome solving the GUP problem by replacing GUP entirely
using an API that is more suited to what these sorts of drivers
actually need.

Jason

