Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFC64C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7928C21BF6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:42:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="mKYy+2iH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7928C21BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D45D26B0007; Wed,  7 Aug 2019 07:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCE996B0008; Wed,  7 Aug 2019 07:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97376B000A; Wed,  7 Aug 2019 07:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 522356B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:42:09 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id h13so2154541lfm.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:42:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=aL+citF68CAxs6Y8RXNOO5t8vu7g/fcgeL4uoy5a6ZE=;
        b=MtVF/WlmRReo9IB9CWO30QlBOc9U7HVf7BLIIsmHS2lBGOOxszGiVtI/kx3+N2iALO
         cJrNgptr7PlLadSk9UOyPwfdIuQHoD0AiV6cEz9dRveKdhfowLjGz5u1fHFuSXP6Z7tq
         A+4HDWZ/bm43M0j3j+oV+SagA67ZnkVWGBWAP00u2+UoMhRQVdnJc1vYOfTHwklRcn1+
         4V2gkozi1QqPIZAceWEjKSki5KwN9jsOl0nGae58pEOY5yg4/cCDj1/k11uQjLYnziO3
         fVM4upROO5Z4J7D9g7SQB3xe09wKKfX+8f/mbZMQUgIo0DdtdkQJttCew1ecE9ywq5Om
         Ke+g==
X-Gm-Message-State: APjAAAXVgjy4e8gWcUZeZlHTQRrw7dXpz3ZrXR7mTimPYbTnHVsMvZgc
	pcWZVIJVfB3eOUZClYu2JdIICCtzJMq2GCievX9rnE7F9sX4CnaC8lQ/itp0lEHofzlKedVsLDJ
	fJhNfxR8Wd8qR8AeeRz9lwWf2ZbQVSWatZg22AQT+cPc360OyDLf0sAfvefnc34inWQ==
X-Received: by 2002:a2e:b0e6:: with SMTP id h6mr4343104ljl.18.1565178128630;
        Wed, 07 Aug 2019 04:42:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFedsH3nYZNqk3OIxj220i2Z5Xt4izRTLC7h1JEWu0aXw/P5jP4CkZ48aR0+ik2qY1sTy4
X-Received: by 2002:a2e:b0e6:: with SMTP id h6mr4343057ljl.18.1565178127614;
        Wed, 07 Aug 2019 04:42:07 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565178127; cv=pass;
        d=google.com; s=arc-20160816;
        b=ZvKxoqjRL07cHLO6xs6RV6vI+PtB7ODDknjimuKJkEsQe1QKu4X3VzHuGdE2uGoKcY
         EuNSX3t4RTzfVO18gQkoA6EAc7+4/WCMdOaJQEXKut63JFKz5GAhlJQ7+jRbUte6R1vt
         lamAIUzdsSoaKEx/bgGEe5b5Ehar+8ndviBNh4mS3EUwRmav8JWDHDOANuq5rT11roG5
         K+Y4o+GwDJi2YrWHdbWsTyuMBchHC+58lzyORsg5CZh/KSdWhSAtPdaHhfHgn16by1tZ
         mOkaB4hA0i37erw7yjRZcJmAdWa2v+b2XkE9jn5C0iJ24tsKboh8CjLAzdyxy6IN1pIb
         W7Pw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=aL+citF68CAxs6Y8RXNOO5t8vu7g/fcgeL4uoy5a6ZE=;
        b=yHXzl0oT7EvpHkF3efnamhEMtuw2KjKMFypzDSEsIp8NrCXU7HtTx4vViXI9qw+kuu
         kmSZ5mOQig7FEBNhYtLGec4Y1VBCQdT0xfdl84UHKVuepg4WJgNmdnB45+XZokNz43eh
         2fgaPS+oP3lrBIXnIQ2z1JZj8UPbbMGbRvJDP+PEGELIU2jAGf3u9I0NzZ0g6FKRIheO
         7YnBNQnfrDl5giQH1lpTbW94LKd4E8ghe+MqvXKoUzQkbTSRF7N3uDYJsq1dkrx3yMqu
         k6ZyrtyknR30UKTtbro7nyNib/DSdZ/yPBxkeb8UFOHSFoY4ThoTRUSiKHGSTw90QhtJ
         oUhA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=mKYy+2iH;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.88 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140088.outbound.protection.outlook.com. [40.107.14.88])
        by mx.google.com with ESMTPS id i124si11790596lfd.13.2019.08.07.04.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 04:42:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.88 as permitted sender) client-ip=40.107.14.88;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=mKYy+2iH;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.88 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ZVr3jfMo76HyKmLduAUrKb8WFb6ymaUtSVWaW1IhKEtpy+EnHcFtfOwM3BEjFy3nmrloTq+dGyxZ3TxU+xix8ehL5gleoF6nfuJc7krGZNNbYw7kB7xSttsSej+ZppUJk5glVGhyHgLAiBzAdijUrdsFlwqH60QHJxaM4CT4xR1Ye8X4TYrngu74IXmCqpiK87picL0qIwdISMpM5OnWFAImnIeEcgKuboRP/zL4nMZYacgfg2RsSaYzlan20Dld9vTLp1WvxgvH4XHc8P/LWmWDhehP2ICeYZpW976YC7Jo6mbk8bvLnCFYT6p+/+urIY91h4uG6zzb4C0RS6sW1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aL+citF68CAxs6Y8RXNOO5t8vu7g/fcgeL4uoy5a6ZE=;
 b=IszXDIPi99jN2PerFFVxuRT76q/+SWjdvGDhsl4K/S3g4elKx9DYWt6gGMCtFLMEnQ8Iz7qZ8vtbZ3MD0XRYOqrqsFPKujEd6/Km3buCJR3m17CcT6kllPwO/5QH/KsiZIcmmGa+7lTQuU5wThPvkLUrgvqJcBHB2pT09p6XDO+oOsXHKNumg1c8t3GerfoCIB0CVv8eHPVuTn+LXctEqALLCASxMDzY4LrYn4YNEQZG4FvyU/yuZ3UiyqAFVYA5IHq+R3SXyyGLIw2RUv/cQ20XTMf/pzuU3nMN7tYUWt1zIn5OtnvOio65y1lqXI7QVsWV1DPCMQATnUz50ltTpA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aL+citF68CAxs6Y8RXNOO5t8vu7g/fcgeL4uoy5a6ZE=;
 b=mKYy+2iHsozehJuxnw2Y8sf/QMwxnQla+qM2hpFCgrK84l2hGEG7x8dV1TShUhZACyb8JgBO40qZOXA6fAM9GJTdhr8DWRuLBCmDYb0HkiDsVzSp2YBcLWOjz3N0B6FqRu1UDADmhKFMWLxeluH+jJrbtMgf0N0p3EZLy+M7doY=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4224.eurprd05.prod.outlook.com (52.133.12.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.14; Wed, 7 Aug 2019 11:42:05 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 11:42:05 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>, John Hubbard
	<jhubbard@nvidia.com>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, "Zhou, David(ChunMing)" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v3 hmm 10/11] drm/amdkfd: use mmu_notifier_put
Thread-Topic: [PATCH v3 hmm 10/11] drm/amdkfd: use mmu_notifier_put
Thread-Index: AQHVTKz0LjDSzhEB4EaA22+m0WS24abuyVUAgADHj4A=
Date: Wed, 7 Aug 2019 11:42:05 +0000
Message-ID: <20190807114159.GA1571@mellanox.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-11-jgg@ziepe.ca>
 <d58a1a8f-f80c-edfe-4b57-6fde9c0ca180@amd.com>
In-Reply-To: <d58a1a8f-f80c-edfe-4b57-6fde9c0ca180@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YT1PR01CA0007.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::20)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1087a58d-cdab-450f-eed7-08d71b2c4559
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB4224;
x-ms-traffictypediagnostic: VI1PR05MB4224:
x-microsoft-antispam-prvs:
 <VI1PR05MB42240F0964A805F21C3C18CECFD40@VI1PR05MB4224.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(346002)(376002)(396003)(366004)(136003)(199004)(189003)(186003)(446003)(478600001)(11346002)(7736002)(14444005)(316002)(6246003)(33656002)(2616005)(476003)(71200400001)(71190400001)(4326008)(8676002)(256004)(2906002)(486006)(386003)(8936002)(6916009)(7416002)(102836004)(6486002)(68736007)(99286004)(52116002)(305945005)(229853002)(26005)(54906003)(6506007)(53546011)(3846002)(6116002)(81156014)(6512007)(66556008)(14454004)(36756003)(66066001)(1076003)(53936002)(81166006)(66476007)(76176011)(25786009)(5660300002)(6436002)(64756008)(66446008)(86362001)(66946007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4224;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 IgSPmRJlcx5V/wGT4V9R6qOKgkgatfYgsL3FNjghYwzUEfezLy17OMRBs0OLS1AEpzQMLrIeMb4FmHDcS6BVivZf99xzE08ks276NRr4Z2vz7zSyVNi/dibZowxwQPcXCs3/1DH7tyLjc53VdBy+Vq30x1L+pT/WopWnLZxOIFgTLShW/o/kN9FSSqckMwK5jVKt28X34Z/T/oRe3CXyYFgXq1u+kQP0vr4KorDAIXQQKQ43kmQvmDtY8xVzn4+77l54rLKVRcmWfLJ1JcwxDtXTq45K9fOY7cjlA6Qh5+nvCQkLYc4I/hMSr1oWxVwJluom/aQvzZaqYEk2rfws6uGHlc24pD74d8UvjGQEcF3pU5ZdQxmHs3AEQBpgJ/uDKBFDuAynhLq+kBCGkJK1whhSyI+3j+qC0V5XDgb3iNM=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <FEC4B53D5BFE794F897559B0282A7946@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1087a58d-cdab-450f-eed7-08d71b2c4559
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 11:42:05.4715
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4224
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:47:44PM +0000, Kuehling, Felix wrote:
> On 2019-08-06 19:15, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >
> > The sequence of mmu_notifier_unregister_no_release(),
> > mmu_notifier_call_srcu() is identical to mmu_notifier_put() with the
> > free_notifier callback.
> >
> > As this is the last user of those APIs, converting it means we can drop
> > them.
> >
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>=20
> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
>=20
> >   drivers/gpu/drm/amd/amdkfd/kfd_priv.h    |  3 ---
> >   drivers/gpu/drm/amd/amdkfd/kfd_process.c | 10 ++++------
> >   2 files changed, 4 insertions(+), 9 deletions(-)
> >
> > I'm really not sure what this is doing, but it is very strange to have =
a
> > release with no other callback. It would be good if this would change t=
o use
> > get as well.
> KFD uses the MMU notifier to detect process termination and free all the=
=20
> resources associated with the process. This was first added for APUs=20
> where the IOMMUv2 is set up to perform address translations using the=20
> CPU page table for device memory access. That's where the association of=
=20
> KFD process resources with the lifetime of the mm_struct comes from.

When all the HW objects that could do DMA to this process are
destroyed then the mmu notififer should be torn down. The module
should remain locked until the DMA objects are destroyed.

I'm still unclear why this is needed, the IOMMU for PASID already has
notififers, and already blocks access when the mm_struct goes away,
why add a second layer of tracking?

Jason

