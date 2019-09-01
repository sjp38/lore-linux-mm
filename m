Return-Path: <SRS0=4eAG=W4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E112C3A5A8
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 19:36:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D89C2190F
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 19:36:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="rMTJ4Ebb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D89C2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 720B86B000D; Sun,  1 Sep 2019 15:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0A36B000E; Sun,  1 Sep 2019 15:36:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BF576B0010; Sun,  1 Sep 2019 15:36:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2A76B000D
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 15:36:08 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 97FD16D81
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 19:36:07 +0000 (UTC)
X-FDA: 75887357574.10.nut92_5276bd7fcf64b
X-HE-Tag: nut92_5276bd7fcf64b
X-Filterd-Recvd-Size: 8318
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150089.outbound.protection.outlook.com [40.107.15.89])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 19:36:06 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=IRx+xDt+QXpX15PkwJZXGu6XhaUEcMqgggJ5ZJ00B6ydMMaaP1UwyMifMsrPl+UU5dl7IaiHNcJrtgEVtXTz2gwDCsc+n1nFsEf9H20uVIa5Vgz8ZktrgkGOoVc+Gb8rRyVkF3Rg3dKJY0xSBBq4HvP4UQ0t51uESOzbP0iOcnQxwVLvsEZ4YeH29C+1JdZfvtMXT8G37DRGCYDJJUtfS1K6SSES9zwkh6P1IXbPZNBiNu3BSRT80/+ZZj6qzvUVtoTXUQDYRhmhoTyg58HC/iVmiECoNWcidBQ/tckrmOyleOdWHBPsSxzJjhWQnLkIi7LRSkmwJik9UgJr1+WbIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5GuMWTKasVdinIcBryJlCnAHqCnqXJdRbQDfdlcgBuQ=;
 b=X9X7aHkn1hbO2vYLEiwoDNzoJ/UYlHcYLT1eKmDQFB+CVK2upOd7+rAPays32wfvEwsnOAM7/VGvrMj4wraod/qBwpIye+W1WVDKWQHDcbessf6TV0tcEkXUDKHUXe7kpvhHfigORUH6hksUxI6axqgEjCdRGjfW6aDPYBkSQqE4MRf1cfnh0ehdgACj/UjnhzcXb53qDTIVAB7eo7Ui46NIVHVjyBtG2VsIQx4tP1Kg0nBRS1Q//oEBd/P44CQrSzBk4tWa5YG9FfYM/wFT1WMHaVgTNobj1g/BZiRHl4N9LreqmzEHm4MB7hX1kUKDzZZ+QeS3zeS4Bal9f30aQg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5GuMWTKasVdinIcBryJlCnAHqCnqXJdRbQDfdlcgBuQ=;
 b=rMTJ4EbbiO8BOY1nPBdL6HpvkT9U4Ie4gm0woMoxBjAO062yjy28cQl4ahYdtDOj9m6G4yhWND8RFi3Pti+PsI+0H61A2RferZa2qxa+f0P6Pis/jYp9Nl8IJY426qpyCKOxjhkr6x+HDflMHtJEi1TcW/veLYGb3afIOmm1e+M=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5407.eurprd05.prod.outlook.com (20.177.63.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.20; Sun, 1 Sep 2019 19:36:04 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f%7]) with mapi id 15.20.2220.020; Sun, 1 Sep 2019
 19:36:04 +0000
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
Thread-Index: AQHVXauzoOyMGt/Rm0+/Xu8LAWoHTqcXL4MAgAAOHoA=
Date: Sun, 1 Sep 2019 19:36:04 +0000
Message-ID: <20190901193601.GB5208@mellanox.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de> <20190901184530.GA18656@roeck-us.net>
In-Reply-To: <20190901184530.GA18656@roeck-us.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM4PR07CA0034.eurprd07.prod.outlook.com
 (2603:10a6:205:1::47) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [31.168.164.202]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b0e66951-a2b0-4fd6-683c-08d72f13a071
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5407;
x-ms-traffictypediagnostic: VI1PR05MB5407:
x-microsoft-antispam-prvs:
 <VI1PR05MB5407325816E8C3007A00F570CFBF0@VI1PR05MB5407.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:773;
x-forefront-prvs: 0147E151B5
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(376002)(396003)(136003)(366004)(346002)(189003)(199004)(25786009)(4326008)(6512007)(6436002)(6246003)(6486002)(1076003)(7416002)(53936002)(6916009)(33656002)(14444005)(36756003)(256004)(71190400001)(71200400001)(86362001)(64756008)(66556008)(66476007)(7736002)(8676002)(81166006)(81156014)(5660300002)(2906002)(66946007)(55236004)(66446008)(229853002)(99286004)(446003)(14454004)(11346002)(386003)(6506007)(186003)(6116002)(52116002)(26005)(102836004)(3846002)(76176011)(316002)(486006)(54906003)(305945005)(8936002)(66066001)(2616005)(476003)(478600001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5407;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 2H/j1oARbAJtKOVJKSQqJFFv+h6ipUsCvwwYYdm5zqVKw9Ez2G3SnEsBEpNA1CndH0AeiDkhf08CI4ehmWa0hZGrUEmrADuqazImYReADHhm1bEf4ZWEvhCnzq0CaEdJftpumTSwfzAizQN+wKB0rOGr7oa60gdVSk45kKHwARrgIM3wudPiMatpNUSnmgCsbyc5Rdjv9/rFrjyg0qY5sfO3SvBLZONOpZ6vEqP0e0k+lAXlwiARdFHKUIw2UPAftubwAJMZDS69tfI0iMLqvUXv0g/an5S/l/x0zoDgc0BlIpSxn2I8jZta3mOT5YOupE/U8P1WuCRKBfQ4LsRtjUiSOAiqrwCWVuWnbEOTsNVIhVgogjOC3I3+iKJGduedyxcmxTshXtNEmnXLsL7mcqAEEYpIyhy1s3P4mSPKosY=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <AC51C72B4393ED4E95D4C3B5363384DE@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b0e66951-a2b0-4fd6-683c-08d72f13a071
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Sep 2019 19:36:04.0184
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Rjv2JEheY8Wkh8x2OIbus5T2sUEVI1CMh3ek2LTXnsSK/pgZ67NLwEUsSdSdp+IY0O9IL3rR5B+IEKKscsrK6w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5407
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 01, 2019 at 11:45:30AM -0700, Guenter Roeck wrote:
> On Wed, Aug 28, 2019 at 04:19:54PM +0200, Christoph Hellwig wrote:
> > The mm_walk structure currently mixed data and code.  Split out the
> > operations vectors into a new mm_walk_ops structure, and while we
> > are changing the API also declare the mm_walk structure inside the
> > walk_page_range and walk_page_vma functions.
> >=20
> > Based on patch from Linus Torvalds.
> >=20
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
> > Reviewed-by: Steven Price <steven.price@arm.com>
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
>=20
> When building csky:defconfig:
>=20
> In file included from mm/madvise.c:30:
> mm/madvise.c: In function 'madvise_free_single_vma':
> arch/csky/include/asm/tlb.h:11:11: error:
> 	invalid type argument of '->' (have 'struct mmu_gather')

I belive the macros above are missing brackets.. Can you confirm the
below takes care of things? I'll add a patch if so

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

Thanks,
Jason

