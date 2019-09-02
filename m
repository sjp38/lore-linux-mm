Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB79C3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 05:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E00821897
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 05:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="YptSjpp2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E00821897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 948756B0003; Mon,  2 Sep 2019 01:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9CF6B0006; Mon,  2 Sep 2019 01:52:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C0D16B0007; Mon,  2 Sep 2019 01:52:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 54ACB6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 01:52:04 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E942B181AC9B6
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:52:03 +0000 (UTC)
X-FDA: 75888909726.06.beam55_4c1575b6f2111
X-HE-Tag: beam55_4c1575b6f2111
X-Filterd-Recvd-Size: 8596
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70053.outbound.protection.outlook.com [40.107.7.53])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:52:02 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=XyJqA0ZCSB9I91xfQur/LXrawn5+e0BBiWz0tb3GI6KF8AQkf5r0VTCH3wQqoy+MIxIY925oeSvYloWIGnmedrirZ7Ab1azuLJMkjDfjEWMhC0G8bOnwlOCr8hDKaxufaug1OD1iTTiBNPCOSTs/GNugYAAXB3skql0cvPTzJwHboZ8rA5gsDtsMYrNE8OA12/glhqYIkjh6NMelL/G6bFLdlbes/beEuKXKj/x/xeCrInc4INBI28d6RtFN0fUI7zJp6ao+Za3E+gDDL1YFzE+sg2nZVrszsFgFEsCI6l4zSefgSelF3de+uqjkMbVjPBeFUaU8BUAD3BoEwjq9jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3YpW+m5iJT03m2/HaZIr+pQumPBsZ7WrQOgbG+uLwmc=;
 b=YT629KHSbJ7Zor60WB7KiX4tqVwpkBSuplC7jIhVQEw8Xznit1PD/BoSKT/FN6p8F1YzdmxEbr9mi4nFCgGpbm4CxE+kRYcTlV94S4YWCSpijJ9q38tg3jLGhxVN98hUlAfalrggk5GT68kntm0DHmwDrIwSbbeEgqZm+vjO/jGQSz5rOc2aiMfd+14nw/14tEyhpcobob931pq5pTXpyjN8W6r28wA53tP5OdJ+5MlmRAvo/lboG3b8qS+fXzk11lE0kNuadGoJQmnkOgwPzQGIOwit3Wpt3EfVoM7R9lxDqmXBFCDfSn+khYjDU7aGBrrys1pT24rdK3DePCB5Uw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3YpW+m5iJT03m2/HaZIr+pQumPBsZ7WrQOgbG+uLwmc=;
 b=YptSjpp2ID9UBlUxfbAJIM13nm4cRCQWi8eCSanBH9zIPW3pNc5vgBSHqy83A6HxHIiBXAilySbFTHeP4jbpWVM361ZMbtuk7CaGlqYI5pJgI2Nx5myhrtTrB02Lc++ujaIcTIosH9EdHBXOnxsOPuweL9TEkBbh2tYamED2/q8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5278.eurprd05.prod.outlook.com (20.178.11.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.21; Mon, 2 Sep 2019 05:51:58 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f%7]) with mapi id 15.20.2220.020; Mon, 2 Sep 2019
 05:51:58 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Guenter Roeck <linux@roeck-us.net>
CC: Christoph Hellwig <hch@lst.de>, Linus Torvalds
	<torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@shipmail.org>, Jerome Glisse
	<jglisse@redhat.com>, Steven Price <steven.price@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Topic: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Index: AQHVXauzoOyMGt/Rm0+/Xu8LAWoHTqcXL4MAgAAOHoCAABCOAIAAm4cA
Date: Mon, 2 Sep 2019 05:51:58 +0000
Message-ID: <20190902055156.GA24116@mellanox.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de> <20190901184530.GA18656@roeck-us.net>
 <20190901193601.GB5208@mellanox.com>
 <b26ac5ae-a90c-7db5-a26c-3ace2f1530c7@roeck-us.net>
In-Reply-To: <b26ac5ae-a90c-7db5-a26c-3ace2f1530c7@roeck-us.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0418.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a0::22) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3155ef9c-6c0b-4e99-3c89-08d72f69ab28
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5278;
x-ms-traffictypediagnostic: VI1PR05MB5278:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB5278D5E0FCB6450E511108A5CFBE0@VI1PR05MB5278.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 01480965DA
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(136003)(346002)(376002)(396003)(199004)(189003)(11346002)(7736002)(25786009)(6436002)(478600001)(102836004)(66066001)(1076003)(64756008)(6916009)(66446008)(2906002)(99286004)(5660300002)(4326008)(33656002)(71200400001)(71190400001)(66946007)(446003)(6512007)(53936002)(66476007)(66556008)(76176011)(386003)(53546011)(6506007)(966005)(26005)(86362001)(186003)(36756003)(8676002)(6246003)(14454004)(229853002)(486006)(6306002)(6486002)(476003)(305945005)(7416002)(81166006)(81156014)(8936002)(3846002)(316002)(52116002)(54906003)(14444005)(256004)(2616005)(6116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5278;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 g6JO3kBvtgZxbcJjg57ba+LaBoSaZxouJ4xCd+ajdI3+nEYSorJjVj7kQ0XGBgvJiJjSU2jJrS7ZaAE01oACh08wOXzto1v7YfyzMD8JI+8kGONhzM+WXWqur+95h5+6K3e8BhlsQtweQfLpTkK8OGbykFk/fZpradsYfMdbDB8SKMzin1gsOxVgfRXcfUeWfzMnsMxQKA1p4Ks4W43piElJA3P86PGtdtCGLnXRIOeuEOxeCcvB7Pt9nsHaWfWbDrpWcQa9m2rl9aHWpGKuNMiM+1tV97SpkEbBDXURe0xpyrrShCh8Hf/CRw04mWlYhVQb+63tZ7JIAroQ14/8+VL4LOzy2SdyBZfL+e8wEbaKBbPBmyrbgzPjPy62DWAFDklC7MU4ST7odckmkecdyEBaXRMqzA+FObjyr4ccm0c=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <95F200D0B68A014B94DC2DE38EBA9207@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3155ef9c-6c0b-4e99-3c89-08d72f69ab28
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Sep 2019 05:51:58.7046
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Lop4Pj6n2+1ioW7qTX/lXOF+ZFzhPKqFIA+ItWCZ7rZ9Tb4Rsh8EJ+o68pYtDaZvDkyxcqW6YQH/MQC61ip0DA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5278
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 01, 2019 at 01:35:16PM -0700, Guenter Roeck wrote:
> > I belive the macros above are missing brackets.. Can you confirm the
> > below takes care of things? I'll add a patch if so
> >=20
>=20
> Good catch. Yes, that fixes the build problem.

I added this to the hmm tree to fix it:

From 6a7e550e0f1c1eeab75e0e2c7ffe5e9e9ae649ba Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Mon, 2 Sep 2019 02:47:05 -0300
Subject: [PATCH] csky: add missing brackets in a macro for tlb.h

As an earlier patch made the macro argument more complicated, compilation
now fails with:

 In file included from mm/madvise.c:30:
 mm/madvise.c: In function 'madvise_free_single_vma':
 arch/csky/include/asm/tlb.h:11:11: error:
     invalid type argument of '->' (have 'struct mmu_gather')

Link: https://lore.kernel.org/r/20190901193601.GB5208@mellanox.com
Fixes: 923bfc561e75 ("pagewalk: separate function pointers from iterator da=
ta")
Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 arch/csky/include/asm/tlb.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/csky/include/asm/tlb.h b/arch/csky/include/asm/tlb.h
index 8c7cc097666f04..fdff9b8d70c811 100644
--- a/arch/csky/include/asm/tlb.h
+++ b/arch/csky/include/asm/tlb.h
@@ -8,14 +8,14 @@
=20
 #define tlb_start_vma(tlb, vma) \
 	do { \
-		if (!tlb->fullmm) \
-			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
+		if (!(tlb)->fullmm) \
+			flush_cache_range(vma, (vma)->vm_start, (vma)->vm_end); \
 	}  while (0)
=20
 #define tlb_end_vma(tlb, vma) \
 	do { \
-		if (!tlb->fullmm) \
-			flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
+		if (!(tlb)->fullmm) \
+			flush_tlb_range(vma, (vma)->vm_start, (vma)->vm_end); \
 	}  while (0)
=20
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
--=20
2.23.0


