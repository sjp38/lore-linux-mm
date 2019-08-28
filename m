Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B95A4C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:40:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B82322CED
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:40:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="MmMr419b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B82322CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15E946B000E; Wed, 28 Aug 2019 10:40:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10F656B0010; Wed, 28 Aug 2019 10:40:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F401B6B0269; Wed, 28 Aug 2019 10:40:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id D37886B000E
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:40:29 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 80D918150
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:40:29 +0000 (UTC)
X-FDA: 75872097378.07.toad06_21462ea16e826
X-HE-Tag: toad06_21462ea16e826
X-Filterd-Recvd-Size: 7295
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140070.outbound.protection.outlook.com [40.107.14.70])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:40:28 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=OkRO1UkM2QfgRz43U0yG2LQ8U7lXYH8MPLxMukBx4GseRbAZ7h8DI60HmTgEDcmb9HP6AKWeuClZ8n2pXE6s/14SC4X9Nxxx43r/+v9jnLeqf9FcDi4my7OfAC4HEanTQ6Wdl6+asDiOxNb2r2QeA+rhQ/xDczBrzLsv5a3qeXyL5TbIzhsU1sG0DVgzuApTHa8tlSIeOUJuOUU/UiV3MTah0YTxo03qmx1Df00Pz8VwAlZTF90eLEgrLhEzxXFfebN9eHwfpZrKK5DOKSySs0CiiTfVIhrLTP9nWTCnC6d9N00QMc/uHR4wcxWyYlk+7t7BNAR8yTAVacAnMNCaog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YZZI7TIhNJpTgpmQ3Ym9oRj66GBq3bIwhTuMAednhzk=;
 b=AxQ93Gt10N08eWQmhxVhoFsBvh9tEzTMUgE/ddKcidodSu9oc8L+CjNpycBzWWZ94gTGnCfkVHXMhAcsQ27Cjl1KvnXMm7yZTC4sjk4Blk+xx2ri6z0OOveUM75UXAZIvOKjKFn5xqFTzOBp9c9MxeZElQwum6bmdRz9HuWWTAWJfK5W8zYn4zPNBMLjB5raAwr5rhtYeLYjRN1qxMUvOrLfPhayVlf661B6MAg+m3p93WG7sBfIU7HPZDJ6ZSRsgqB9SolV8XVweL1csZViSwRc8v4QjLLVFNfcYmgMV+sfJW797nRU9warG2YQCzQ5yIM6nNAebWKkxqzVRzgKYw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YZZI7TIhNJpTgpmQ3Ym9oRj66GBq3bIwhTuMAednhzk=;
 b=MmMr419bfQPRTnvudqYdzRUSIuZdO0F2FE36dx+fttfoDjni8FMfIZWHKJuxHEA9DGPUWiK3elxq75kbK8RSpq84/vpJpn4VzvAsiL96wNTy0XRd+OP1g0lfaeZz8whu1UouTDsXCMOHbiezgwmiPMVDUVSvz4QmUC7h5u7UuD4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5246.eurprd05.prod.outlook.com (20.178.11.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Wed, 28 Aug 2019 14:40:25 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.021; Wed, 28 Aug 2019
 14:40:25 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "daniel@ffwll.ch" <daniel@ffwll.ch>
Subject: Re: [PATCH] mm: remove the __mmu_notifier_invalidate_range_start/end
 exports
Thread-Topic: [PATCH] mm: remove the __mmu_notifier_invalidate_range_start/end
 exports
Thread-Index: AQHVXavZqxXcfLyzmkeft6WFMi/zb6cQobAA
Date: Wed, 28 Aug 2019 14:40:25 +0000
Message-ID: <20190828144020.GI914@mellanox.com>
References: <20190828142109.29012-1-hch@lst.de>
In-Reply-To: <20190828142109.29012-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0036.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::49) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e9b0e95d-f896-4947-ddcd-08d72bc5a9b6
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5246;
x-ms-traffictypediagnostic: VI1PR05MB5246:
x-microsoft-antispam-prvs:
 <VI1PR05MB524688DFE20EED13B8873181CFA30@VI1PR05MB5246.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 014304E855
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(376002)(39860400002)(136003)(396003)(366004)(199004)(189003)(4326008)(446003)(486006)(476003)(6506007)(2616005)(11346002)(4744005)(6486002)(8936002)(6512007)(99286004)(81166006)(102836004)(186003)(26005)(6436002)(2906002)(386003)(316002)(66066001)(52116002)(5660300002)(81156014)(8676002)(478600001)(14454004)(305945005)(66446008)(64756008)(6116002)(54906003)(66556008)(66946007)(7736002)(229853002)(256004)(1076003)(6916009)(71190400001)(71200400001)(53936002)(76176011)(33656002)(25786009)(36756003)(3846002)(66476007)(6246003)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5246;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 eyNg4HLZ52LGAV0ouvh0lK+YUWuSz+vviASvTi6u4tyfRkS+6crc8iuHsljQ85TIlyyZ2x67UYnb4k+XdopeWbFkEGkqXgOxvsB9Ufc3q8V7xdpca3PlD6/O920ZuL6nACpYjRxCQm83QoQnJaFhYvi2wIIK3EFtmYaDp//b5swB1lHKRzPNPhhd5XyietoaGNUcXcHgTVPfMZPGkV0tuVkq35Ott32oLpI0CEOx5UX34FoNrTC/uwQhZTCWcjLJ4uJ47JyvTE5jMk4KsnY7SSfjYn0GceWcrR2sZl/5shBSBlp4SF42RVQygjf/urBmGf9mEDLHswSEXIGb5+3geGwoHkAO7U6h1M+QmZIuGFAXt/pP/na4omnpj/TmXi9wqlfwgOXy8wjq6nBLEAebiO4wJVpCMiRA7rzg6QhPGLk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C1EA082325B7104A864499B49ABCE3F5@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e9b0e95d-f896-4947-ddcd-08d72bc5a9b6
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Aug 2019 14:40:25.3928
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: paxkgAgF/TdQvDco2/uuuH66Km0esr3MC2D1DEP+cnOd7FeoGG30D6ipyiwCCcAe4NujhpWsU5QDviXZjvfESw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5246
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:21:09PM +0200, Christoph Hellwig wrote:
> Bo modular code uses these, which makes a lot of sense given the
> wrappers around them are only called by core mm code.

/Bo/No/

> Also remove the recently added __mmu_notifier_invalidate_range_start_map
> export for which the same applies.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  mm/mmu_notifier.c | 3 ---
>  1 file changed, 3 deletions(-)
>=20
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 690f1ea639d5..240f4e14d42e 100644
> +++ b/mm/mmu_notifier.c
> @@ -25,7 +25,6 @@ DEFINE_STATIC_SRCU(srcu);
>  struct lockdep_map __mmu_notifier_invalidate_range_start_map =3D {
>  	.name =3D "mmu_notifier_invalidate_range_start"
>  };
> -EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
>  #endif

I inlined this hunk into Daniel's patch from yesterday

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Applied to hmm.git..

What about:

EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);

elixir suggest this is not called outside mm/ either?

Jason

