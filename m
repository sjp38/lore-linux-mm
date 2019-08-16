Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69AA4C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29B8E206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:23:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="DU4dUVjk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29B8E206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBDC86B0007; Fri, 16 Aug 2019 11:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6E676B0008; Fri, 16 Aug 2019 11:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5E916B000A; Fri, 16 Aug 2019 11:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0190.hostedemail.com [216.40.44.190])
	by kanga.kvack.org (Postfix) with ESMTP id 82D8B6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:23:21 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 372947580
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:23:21 +0000 (UTC)
X-FDA: 75828659802.28.show25_663108732e
X-HE-Tag: show25_663108732e
X-Filterd-Recvd-Size: 7030
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00073.outbound.protection.outlook.com [40.107.0.73])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:23:20 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=g9yCuMmIa9f/kdv0lr2Z5X84QAU3Zjf4qwY2bQJ8FDddObWqengMjMGUlQy38x5+MDnssNhos98bJPWiKKNc1mg5VsRknKY+dGeGSIIxxlxk1bSMEJfZrrKf0L5QQP8dVOkbBnnBCVu8T5u1Xn0bZqQ1dGcBxMfMWjq5YZt0hpMXCHvAeIBClj1P35I6YXJLM+oPyyGZx69pkwaYGP0FdN9hQA023nKnvRBtDcYrF0rhOnktDe0tkBFo9gKisXSfO6CvFS5DAhLBPL6S4XGFpn2IH/dyHIL4aGjWDQxYytA5bo1gkhYso25bw4krmPYlO6vf18ERLihtGxXapIUlYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FLj0+5s8J4sPOjNLh2U7YQGSIRaX9TNUBlVpzIo7nrE=;
 b=LryzlOrjBeaQ5p5tZF/R7GoMcr3VU+zTb+Stzh8zb/EmhwGyUaGBdl+vZiOiC1g0BD357sUvxARKqj30unbLq3srW0t4Gi/4A7GvtsO9KzaEG6GFW2yaoBmwwrQjbyxJ5/obA3+tQXy2jdty1sqQ4bptOtp1hL61dAs5J0rv8B3pzJAEVa/OXWRh2h1DV3IuuJ/M3VVnhe35MQpJ23KOL+7nB8kEzRbf8vtRgrZ8oemfJ+gZiscy0Y2YTSKkAaF+qszbs1UV1fW9TQdnFgeIIAsWtl2CTqaG9FUG7zoyA6SascHFztBRjYu9UkFfuttEygOo2HdBHcaIO32nd5Ed1A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FLj0+5s8J4sPOjNLh2U7YQGSIRaX9TNUBlVpzIo7nrE=;
 b=DU4dUVjkfM/n2QsXl5K9QmD6eAymwjgkoDA5Rp5poek10h0GfrTdSWlbb4D4TXhOgmW2v/9uOpSjSnv0R4WcINftQrgjdKyEVFMau3ZZLYhVDCp/WgKTs5cRBpybz0JV4fEFimrDaO+u5QVk9eu0mwCAyFlyQxNVwd6Wpu1PlP0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5806.eurprd05.prod.outlook.com (20.178.122.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 16 Aug 2019 15:23:17 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 15:23:17 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm: remove the unused MIGRATE_PFN_DEVICE flag
Thread-Topic: [PATCH 09/10] mm: remove the unused MIGRATE_PFN_DEVICE flag
Thread-Index: AQHVUnZHuPYLs17X5ES78msdznuF1ab96BsA
Date: Fri, 16 Aug 2019 15:23:17 +0000
Message-ID: <20190816152312.GJ5412@mellanox.com>
References: <20190814075928.23766-1-hch@lst.de>
 <20190814075928.23766-10-hch@lst.de>
In-Reply-To: <20190814075928.23766-10-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0012.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::25) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a3a52c03-835c-4fea-8361-08d7225da9fb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5806;
x-ms-traffictypediagnostic: VI1PR05MB5806:
x-microsoft-antispam-prvs:
 <VI1PR05MB580694E32408ABDF5E1F20E3CFAF0@VI1PR05MB5806.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:989;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(376002)(396003)(39860400002)(346002)(189003)(199004)(25786009)(3846002)(316002)(66556008)(99286004)(6512007)(486006)(54906003)(476003)(76176011)(446003)(256004)(2616005)(36756003)(6486002)(6436002)(8936002)(4326008)(71190400001)(6116002)(2906002)(478600001)(66066001)(229853002)(33656002)(11346002)(6916009)(102836004)(1076003)(6246003)(7416002)(386003)(71200400001)(186003)(4744005)(52116002)(66476007)(6506007)(53936002)(81156014)(86362001)(7736002)(305945005)(5660300002)(8676002)(14454004)(81166006)(66946007)(66446008)(64756008)(26005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5806;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 O0hU/8wSHSywervEfRcqYXbmdilbl3ug6l6GV7LAsWtd0dYKf+qW6SgBQTVj2ilV6btto2PSuNmwHB8DP2K7o8SsWlru1LEdyucz4P7GWOV4qBZ+zRiyRQzOFEYUMl+TJDV9VtXmXenPLT0iriafXWcgCbuhVBW/mQv0fxYvPfI3MpS6C7OwpqteVXNoFJUmKGejn1WXP3Sx2kIQ7SvBAOtgjJjyO9QgDGjHdsa0PCDZOnimBifYdLDQxvUDEbbVNqAFICIeOFj+BVFrEtJrR5WkAEBYbZX2XPpMe1LBt3YyAA4K9sM88gGPKGcXKedXpkSgbzSnVCpCxDkyiRifmuhm5VnnlkYSnZGZJUQ+ir3Ixtx2+dIO2sRXC6Gv81gTe44NCO4QIpnJhd/CCAv01Oh29BrU8mXNCjhqCZaJqEk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <3EB9395C750F37448F03B7FC8F9B531F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a3a52c03-835c-4fea-8361-08d7225da9fb
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 15:23:17.6119
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: GzK5fNV+K9WuO7Kuped3qoX9mXDcuyVmPFlH2li/ySQFL8J+V6Skf05PZDux1MNgAsJ0DniWqbk3ATrTl5/7MQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5806
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:59:27AM +0200, Christoph Hellwig wrote:
> No one ever checks this flag, and we could easily get that information
> from the page if needed.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
>  drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 +--
>  include/linux/migrate.h                | 1 -
>  mm/migrate.c                           | 4 ++--
>  3 files changed, 3 insertions(+), 5 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

