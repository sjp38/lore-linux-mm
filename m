Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78442C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:49:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A009420820
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:49:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="BBf28Ja+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A009420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C99A76B026B; Thu,  5 Sep 2019 10:49:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4A796B026D; Thu,  5 Sep 2019 10:49:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B38F66B026E; Thu,  5 Sep 2019 10:49:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93A0A6B026B
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:49:53 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3D2F5824CA20
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:49:53 +0000 (UTC)
X-FDA: 75901151466.22.fifth79_9066f21a90e34
X-HE-Tag: fifth79_9066f21a90e34
X-Filterd-Recvd-Size: 6999
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70040.outbound.protection.outlook.com [40.107.7.40])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:49:52 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=EIylbdGE1EVlj9wu9nwaCJuRrI707OhvwBGnTgTIhnv/HFDWfKAaUsUBUwlrHMJ0KG0TBtpO3ElbGXMW9+FrZuF5TDS/VffHLW/0uyrqZi0Kt2MImW4agCHKkAJrDdu5ebG5JQ7mrQVigrnGOyB9rCiwWEuHOzUX3+P6A56MPvIHY8+jCAq01ZOd9MsW70LfQVNh6pU10TH/GrDHjSbUjj/KQ1tlTxJH1oaWTdIvF2b1NBd2Sa52Zzb6LG80a5WrjJ9X3fI8UJwgv5iDiSJvy7hHePg9nqaD3vmIODQ/TIa4iVv+i9TYZIb1iRN9vxryicEmK0GLeThTzvOTqorZ+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4CGgpiMxwsL6igR7+QqgBRYU93mG2jYhT5ek8gk7QPE=;
 b=Bfp3h+z6XMc1f1IKxjdCpuQSTlOwmjqPVKBtxiP1IzNE0bvEDV18HKww3ioDv3ySbkA+HxYEopNFZN3UR/JbhQ2Z+s/J+aMT0qw04avZQHp22bChGjcJyq+2cfW6oB+R4Ea+d0gUc/cQ84l/xLYXrKkJEJ7lZrlLR6fL+6deFhKhLskRXOFWE6PO6gIJY7MnzgVf3uUD0dIFYhncOGgQILFHUPPuxsEnbhmH0oM03aPB0im41KqzSJ42iU1NyvmMyRp3qxXOEoyvYqIOvaqdiyAf57bNHqK0byiWjD2vIPMq8g5D1KtU1TECUWeIGHw/51L5uBmxO/cyVc5yKsBvsQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4CGgpiMxwsL6igR7+QqgBRYU93mG2jYhT5ek8gk7QPE=;
 b=BBf28Ja+0dNr9KWmHIa2SU1e/zf8LROnAapoZjHUyUVlJ+ZqqGqO4UNL36G1FIx4Hp4lQecePb9nUKdsE8BG/mBdJxAVcipod4qUaqvHl7hhadTGAQBXARWgk0R+imwOTDY04L7CfFHCmwHcXsWD4ooSB3ZC3AfYrHoulYcFxUw=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4256.eurprd05.prod.outlook.com (52.133.12.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.14; Thu, 5 Sep 2019 14:49:49 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f%7]) with mapi id 15.20.2220.022; Thu, 5 Sep 2019
 14:49:49 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
CC: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, DRI
 Development <dri-devel@lists.freedesktop.org>
Subject: Re: [PATCH 0/5] mmu notifer debug annotations
Thread-Topic: [PATCH 0/5] mmu notifer debug annotations
Thread-Index: AQHVY/kqS7drW7tYS0OaX2gILgkMmw==
Date: Thu, 5 Sep 2019 14:49:49 +0000
Message-ID: <20190905144946.GA22237@mellanox.com>
References: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
In-Reply-To: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0425.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a0::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bd59b6ed-9733-4cb9-93a1-08d732104cd9
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4256;
x-ms-traffictypediagnostic: VI1PR05MB4256:
x-microsoft-antispam-prvs:
 <VI1PR05MB4256562AB84B0844F93239FCCFBB0@VI1PR05MB4256.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 015114592F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(366004)(39860400002)(136003)(376002)(199004)(53754006)(189003)(8676002)(8936002)(386003)(3846002)(81156014)(76176011)(54906003)(53936002)(86362001)(102836004)(6246003)(6116002)(7736002)(2906002)(6506007)(305945005)(52116002)(316002)(81166006)(6916009)(25786009)(6486002)(229853002)(99286004)(26005)(4326008)(66946007)(5660300002)(6512007)(33656002)(36756003)(66476007)(1076003)(486006)(66446008)(64756008)(66556008)(71190400001)(71200400001)(66066001)(6436002)(14454004)(4744005)(446003)(256004)(478600001)(2616005)(11346002)(476003)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4256;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 geCeaHgd+mTKJRfX0h8gvuKXdvU/D8ZbTSHB4mhrm2Me8VcHwpHYJc+wlFsXtVITXFTkDADEQrLgVkhX3xvCrSBvJ4rLeopOBUEB02R6wacHlBME4CxFnlLj0TvdU0KaOL0QrZUegiIoukQmR/BoFLvdD+EJL8/6Q7pOGI1ZZ9wVZzgWrMm54CdPLVO5zjqQCYhrrNm6FjMhexWllbWaOVjSlHjqiFJeHDrmiqdTRsB3/29e8Pzxhiw9ZjvUj503cIlB4EHlebiG3W5EEbQDbKE6Fq7HhiPBz19wGhhpOnc1U2s3iCJKzTm+l3pCMwMtTRET8T6YBI4AsKsTSkV0Qp1+9t+xwSwD1U/aMXpTkTs7TEYJUQvtqy8OzP9DRdCgqo6kQY6MweqwH+HzYgMidcUmsDmg5MPqEdgIyMn7cH8=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <04647BF6CC7E11449F589A453BE4B4E0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bd59b6ed-9733-4cb9-93a1-08d732104cd9
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Sep 2019 14:49:49.6232
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: nIf7WPDv3hzOOYMebUEEqA6sns02aoy3i+7TzAv8K6XpVea92/6MStbqsC3FkWMLN9kpmF/pokNlZ7rRT63uWw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4256
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 10:14:20PM +0200, Daniel Vetter wrote:
> Hi all,
>=20
> Next round. Changes:
>=20
> - I kept the two lockdep annotations patches since when I rebased this
>   before retesting linux-next didn't yet have them. Otherwise unchanged
>   except for a trivial conflict.
>=20
> - Ack from Peter Z. on the kernel.h patch.
>=20
> - Added annotations for non_block to invalidate_range_end. I can't test
>   that readily since i915 doesn't use it.
>=20
> - Added might_sleep annotations to also make sure the mm side keeps up
>   it's side of the contract here around what's allowed and what's not.
>=20
> Comments, feedback, review as usual very much appreciated.
>=20
>=20
> Daniel Vetter (5):
>   kernel.h: Add non_block_start/end()
>   mm, notifier: Catch sleeping/blocking for !blockable

These two applied to hmm.git, with the small check patch edit, thanks!

Jason

