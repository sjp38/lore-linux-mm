Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E991C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:34:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E0FB2083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:34:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="hmctAENh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E0FB2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A51A06B0008; Thu, 15 Aug 2019 16:34:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A00086B000C; Thu, 15 Aug 2019 16:34:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C9156B026A; Thu, 15 Aug 2019 16:34:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id 700006B0008
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:34:51 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0F61F349B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:34:51 +0000 (UTC)
X-FDA: 75825815982.27.jump64_2a399c3a4e31e
X-HE-Tag: jump64_2a399c3a4e31e
X-Filterd-Recvd-Size: 7182
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150054.outbound.protection.outlook.com [40.107.15.54])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:34:50 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=kRa6q31LDqZL6+tCevlXecnT6fKD8wLTSr5vuVyWW5tzsXl8ahllymrLx3wTQc8vCtLUAzMfQTj+smQvlekaPRtptWBewuBtSNF+zmTtC1+fJncDRrPS++0lRDYik8yA6HPS4zr3xtUhLJ4XaEjdoumIMTTQ3RlPle1egKTSJvUx0OxEPkWUG+szjRP2jbcbgzIT8zq5RiXYN3s9uyRQvmYW3vW45aefPugIXjOTfc5/9JXD2sYVufxHLKky9BG8wRGcJ6gVYOtfb/Nbu5yC8eVttUqbCFYvGrFhYQHIyvKWV/9y7NFHLk0n+83Rt+0MrcPngI4NtVvkK9beI8H5tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FQyufbc/ZASxyUi2IklmT0cvAfmIb/x7sKeo69iD8hE=;
 b=DE2h8wwm3rpLU9DML4NKc49QHZ+0d5Odkr+rbCuSNnhpe6A1WsTC539lRSlfANHLj7hI5BbcAb5bFANPt26Sm2uJnVg1FgifOTZ/9X4IxJB15jh934kQ87e93zX/wEXIJPBHSuiDKtTj7EE0Pg02bN/Q+ka2fwFCDRkqIjmmtCR55eSbr17xxPcGatJv3LMVai+WWrqtHcSlpfv4orhyohSqtA7LrI9snaL4z8kWHVFiCrr/Lq4KWB7cYKULcngDV0H7qYUa00/Wwl2KjykdPdE39fLgESf9puB9a031w5dK/KWdWSIoqxc4ckQqNwLLVnVYPiGfySpSjSFmbxVzBA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FQyufbc/ZASxyUi2IklmT0cvAfmIb/x7sKeo69iD8hE=;
 b=hmctAENhS7xCC9zAyysr9cahd0nQvWs6t+k3u3WVqW8C7owniTO9br/DS09i1uaqliHMHogRpKm6wShwEJjs6SreaMqyMdUXH0fRyCNT3oQW+9L940eqmBGI8/mqvIhsSdv30trqhKj5XzVT52EsUa+qVrvDPPY9lHZqW1z8y+g=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4190.eurprd05.prod.outlook.com (10.171.183.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Thu, 15 Aug 2019 20:34:47 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Thu, 15 Aug 2019
 20:34:47 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH v3 hmm 00/11] Add mmu_notifier_get/put for managing mmu
 notifier registrations
Thread-Topic: [PATCH v3 hmm 00/11] Add mmu_notifier_get/put for managing mmu
 notifier registrations
Thread-Index: AQHVTKz2XY1M3ESMzEuB6+4Ezmt3zKb7Xk0AgAFaFoA=
Date: Thu, 15 Aug 2019 20:34:47 +0000
Message-ID: <20190815203443.GH22970@mellanox.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <5c836cd9-3c20-aaea-8e98-e6d92e6879d9@nvidia.com>
In-Reply-To: <5c836cd9-3c20-aaea-8e98-e6d92e6879d9@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0018.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::31) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 39464a5b-0b98-414f-4469-08d721c00375
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4190;
x-ms-traffictypediagnostic: VI1PR05MB4190:
x-microsoft-antispam-prvs:
 <VI1PR05MB4190C70A5995A6F4901E6A72CFAC0@VI1PR05MB4190.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(346002)(39860400002)(376002)(366004)(136003)(199004)(189003)(8676002)(386003)(476003)(25786009)(2906002)(2616005)(1076003)(6246003)(6116002)(446003)(11346002)(3846002)(76176011)(33656002)(53936002)(36756003)(102836004)(4326008)(86362001)(99286004)(186003)(6512007)(81156014)(81166006)(6506007)(256004)(14454004)(4744005)(64756008)(66446008)(66556008)(6916009)(66066001)(71190400001)(26005)(66476007)(5660300002)(6486002)(229853002)(8936002)(486006)(71200400001)(6436002)(52116002)(66946007)(478600001)(316002)(7736002)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4190;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 u2CCpqTcP0zab0OH3MHHcQCDYduFjVzgw7t4X5nwceoZc+uv0UNsP9CVC/OYK/s/hvrRqjDq09akIfs4qqpVVcwq+Wos6hrKArbae5LmZMnYNy7/zT0NqBfIsBr80Ht9Ga6q/dAXm4KevUp12vRB7GoFYu+H4HPFV8FCpkD1ZkLRsf6D9fKW19OvFXdUu05GwpiwGSSEzqE3kC2unruWmyfBg1f8e0e7B/9XQnLpwYKmof/zjtF0WP9ivHoqkFdrxeoPobAstLwXdx1+n1pApuuuORmi2dPwKjRguWwDHtJPAdSCl8WFMM55fbXm9AUUfB4BiZ4pSK3vmurvsKS/hYUy2f/A9BwzTpK1uF4ilOiw8maZWmHMCrjfnNSH5K0h2zKoAPABAROdyLfPbVMNcNG7dTdrLvrE1GWlQmoz1lE=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <690E2CA4A383984195AC05EBB43B399E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 39464a5b-0b98-414f-4469-08d721c00375
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 20:34:47.3068
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: rgJf2X6C/WwMsY9G3nT2XPucXYHSwhEbCUOxki05OFy+qHGR8oVEanFv1zh1ryCHw/Rl2FlqRn/oVCZhjW46qg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4190
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001150, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 04:56:02PM -0700, Ralph Campbell wrote:
> >=20
> > Jason Gunthorpe (11):
> >    mm/mmu_notifiers: hoist do_mmu_notifier_register down_write to the
> >      caller
> >    mm/mmu_notifiers: do not speculatively allocate a mmu_notifier_mm
> >    mm/mmu_notifiers: add a get/put scheme for the registration
> >    misc/sgi-gru: use mmu_notifier_get/put for struct gru_mm_struct
> >    hmm: use mmu_notifier_get/put for 'struct hmm'
> >    RDMA/odp: use mmu_notifier_get/put for 'struct ib_ucontext_per_mm'
> >    RDMA/odp: remove ib_ucontext from ib_umem
> >    drm/radeon: use mmu_notifier_get/put for struct radeon_mn
> >    drm/amdkfd: fix a use after free race with mmu_notifer unregister
> >    drm/amdkfd: use mmu_notifier_put
> >    mm/mmu_notifiers: remove unregister_no_release
>=20
> For the core MM, HMM, and nouveau changes you can add:
> Tested-by: Ralph Campbell <rcampbell@nvidia.com>

Great, thank you again.

I think I will send this series to linux-next tomorrow

Regards,
Jason

