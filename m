Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85FF9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:01:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3584E21019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:01:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="CI6X4c5+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3584E21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA5D88E0004; Wed, 13 Mar 2019 14:01:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2CF48E0001; Wed, 13 Mar 2019 14:01:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF3ED8E0004; Wed, 13 Mar 2019 14:01:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5452A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:01:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 29so1261017eds.12
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:01:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=bui4y6cUdhlgn0tx/U3KOjV3erH9xFwzkKyA1einVHM=;
        b=SqLmKvvLhClg2raieXFto3w268qqw0sLjwcjl1/5iRVU2V7FVftlqNjPhkB6kHJuIv
         mnQaFOdtT7PvKyyC7WYJQMbAB8Io0n0FlJ6pozB4ZUurTD7cOy2pyuaXVwmkzTqnpGz7
         5HT1Xyk9AFzNVAAcBYbyXQXOIK0ur4Jcj/1eb+nWeGZ8G6lyFHRYIVJlSFal2MANVWsE
         x9eEaDC/WvvdZ5q9e7c/zaFkpFPOVjqE7qVdhW6ocZmlQ3fDGNsz/mmrPlITN1TV+TQ3
         DYK82xGiC2vT+nYxkasBpDxjkpYsfG1sOxUvOEeShg7TYqBFO/RWX4OLhrEJTPIafCtZ
         E31g==
X-Gm-Message-State: APjAAAVsL39IhfbagN0b4rAD44mRDYsIn6KHToey1A/MrlNnY2NB2lr9
	DlpqsCkMH8FN3Lls41Hq9sK24fqme72mptpIy3gDHQvGaALmNz81oLPYDXvpdXwBMQatav3N3Nh
	xcAut8p29gaKWkYPo1ivcWvr9onJybAKM1JxHSct05c0TCrDlEsFy9LRyU/PuerseAg==
X-Received: by 2002:aa7:db14:: with SMTP id t20mr8560722eds.231.1552500096816;
        Wed, 13 Mar 2019 11:01:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw90JGSbloadYZ8U7nPsIxMiKwZ6aylBlXAGi98tTgIbykq2UfrONXpvHEf6EXchIWa/N0x
X-Received: by 2002:aa7:db14:: with SMTP id t20mr8560681eds.231.1552500095918;
        Wed, 13 Mar 2019 11:01:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552500095; cv=none;
        d=google.com; s=arc-20160816;
        b=eXC/a0d4p9IxYbNBrZMI7l1MgSEK8lMLyp5ouA3Nhw+1aE/UAkyQFXLFDl5AEHkLtB
         om3RITxKjfzOiNWG1KPMiAHlvoc52wQdE5aHRtEjqaZ5VuL7ENBZ1JaeztuW8NFRYUXg
         o+AoSpy9Hyp3xFBf4NVQwneDrvzWi+7Bwu0Q8zBg+xW8PUavsfsi3ifs5mhYipika+sW
         5gv6nIvMg2TfyWXbLb0oMVxKK8+Rxjeo0iHuGw2G8S8nbi9iyDkQ+shgRcDI2RtMn6Yo
         gC+VP90wVLpgyMjhQFgb4su/3uGTU7x+pvYgn1J2oAibrL/I/Qg6eTJaqxQenkihgMlt
         ws4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=bui4y6cUdhlgn0tx/U3KOjV3erH9xFwzkKyA1einVHM=;
        b=E/FGYPu4e3DNmEs+zcvgRD1eOz3qX1eag9q83CT/yY6tUb9sglkULiMInkq6+Yy9rP
         08RzHUSxsUoTBS5F7mlwZvi+96t+K6Lz3cPQUdZq0PxiZbFR7930E5rsCwyjUWtjoDa+
         S/rDuQT3LfAGVc59iBAovjgH4pomYGoPc1p6V5nBtf/llHMRQjhQ0VHZEP1Eh1FdYjFm
         L7/NhfbLjQFdyIqAxhME+U4bvD5sKn7mmVImnFIm5lJ258vQxf1mJL+xye/OAE+Wpnrs
         S9PgKLNxq5kE1wavimIpVwz17pNHusowVbrRphF+311ujf9BUGoUjoWhLkCx43zIjAD1
         hkQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=CI6X4c5+;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50089.outbound.protection.outlook.com. [40.107.5.89])
        by mx.google.com with ESMTPS id j13si345922edj.347.2019.03.13.11.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 11:01:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) client-ip=40.107.5.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=CI6X4c5+;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bui4y6cUdhlgn0tx/U3KOjV3erH9xFwzkKyA1einVHM=;
 b=CI6X4c5+MHvzWre9bVqXZ8hzmF6ekWBQBzg3dYNZcsM+vMBerR46VvFjFaz38oqar5LLOIkt3HN0W0QAIKAdghQAFla00ZWTwC8897UxF9N/Q9N+2er6/uLnAWgXk7iQdQRwYMSlN/xWLYH4abhrK7ucxcrT6Xr9TN4zcV5axuM=
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com (20.179.44.81) by
 DBBPR05MB6490.eurprd05.prod.outlook.com (20.179.43.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Wed, 13 Mar 2019 18:01:33 +0000
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f]) by DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f%2]) with mapi id 15.20.1709.011; Wed, 13 Mar 2019
 18:01:33 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>,
	=?iso-8859-1?Q?Christian_K=F6nig?= <christian.koenig@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Dan Williams
	<dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Thread-Topic: [PATCH 00/10] HMM updates for 5.1
Thread-Index: AQHUt/NUbGfMj/dYmUKscdo97gNJJKYJB9YAgAD2swCAAB8gAA==
Date: Wed, 13 Mar 2019 18:01:33 +0000
Message-ID: <20190313180128.GV19891@mellanox.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
In-Reply-To: <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0025.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::38) To DBBPR05MB6570.eurprd05.prod.outlook.com
 (2603:10a6:10:d1::17)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [24.137.65.181]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a97e40f5-0dbc-4a95-33ac-08d6a7dded59
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6490;
x-ms-traffictypediagnostic: DBBPR05MB6490:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <DBBPR05MB6490A45DA2E1DF7FD01B11F3CF4A0@DBBPR05MB6490.eurprd05.prod.outlook.com>
x-forefront-prvs: 09752BC779
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(39860400002)(366004)(136003)(199004)(189003)(81166006)(86362001)(81156014)(1076003)(66066001)(386003)(25786009)(6486002)(4744005)(6506007)(486006)(476003)(6346003)(99286004)(3846002)(52116002)(316002)(6116002)(14454004)(256004)(186003)(26005)(4326008)(478600001)(106356001)(6916009)(6436002)(8936002)(105586002)(68736007)(2616005)(76176011)(7736002)(6246003)(102836004)(71200400001)(71190400001)(11346002)(305945005)(33656002)(53936002)(36756003)(54906003)(97736004)(6306002)(5660300002)(6512007)(966005)(2906002)(229853002)(446003)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6490;H:DBBPR05MB6570.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0PXsCFSIDI+UlkaRWtKtwu1Vfx3ZB8OMQsNDTdL3Ip2bSbOacsiEJWYGrNpEoh6y7wu/N6KNa1c7+oRNrsWmFoM9+7MtJCe0I/DuiUVVZnC9E90xp2x720KqodvXoJFlgPF1l2C3S6nQ1WAuZTPWtXgW987KJs5mgticawjUNN+lHvSKqJl1x1OUSXzYmpYRFD4cmrBlL8mVYbKTZ/c1fjMdX51pAa25NKXFXAwJyVpmtK+OeYjmoK0vcp7Dpu1gR3wDvjjS82rth2yrsQooyiXLFqKfQi2UVvfKXSvnv5j5O2ZBl5V4jAEevP4z7agcdbLUBv7Vhqv573AdrNgL1zZDt3ePYao/oDzdwnw2ByEfRh7aloXGKG092lxwa8avwKGh4nPgGd22s5Md12Is3xDJZdkX6m/ltlu+w76unQI=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <6D1EB43616A9974BBFE6D51BAB60AD43@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a97e40f5-0dbc-4a95-33ac-08d6a7dded59
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Mar 2019 18:01:33.6344
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6490
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wro=
te:
>=20
> > Andrew you will not be pushing this patchset in 5.1 ?
>=20
> I'd like to.  It sounds like we're converging on a plan.
>=20
> It would be good to hear more from the driver developers who will be
> consuming these new features - links to patchsets, review feedback,
> etc.  Which individuals should we be asking?  Felix, Christian and
> Jason, perhaps?

At least the Mellanox driver patch looks like a good improvement:

https://patchwork.kernel.org/patch/10786625/
 5 files changed, 202 insertions(+), 452 deletions(-)

In fact it hollows out the 'umem_odp' driver abstraction we already
had in the RDMA core.

So, I fully expect to see this API used in mlx5 and RDMA-core after it
is merged.

We've done some testing now, and there are still some outstanding
questions on the driver parts, but I haven't seen anything
fundamentally wrong with HMM mirror come up.

Jason

