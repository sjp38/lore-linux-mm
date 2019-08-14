Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26B88C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 13:27:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEDF5206C1
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 13:27:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="REGzqX53"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEDF5206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 541206B0003; Wed, 14 Aug 2019 09:27:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9806B0005; Wed, 14 Aug 2019 09:27:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 369706B0006; Wed, 14 Aug 2019 09:27:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id 05BD66B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:27:55 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9FC4A33C4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:27:55 +0000 (UTC)
X-FDA: 75821111310.04.cream67_27f5f3410d95c
X-HE-Tag: cream67_27f5f3410d95c
X-Filterd-Recvd-Size: 9987
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130075.outbound.protection.outlook.com [40.107.13.75])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:27:54 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=R0dhX0lPYPL82ZsdcaXS7JDcikD9zKYnnxrRdomTvS6hIdmWyd0AAligDJxWX2BacpOWdKWn8a/KgTVSdeJC38wi15eTfH0N9v00nk2FDLI1772jpB483qdORm6jjoLYUAvSEFUR8VC7rYoIH7K41j42JwldzeKUdOcTKBZfB2+Eisvpo+xqQQshzWJipxd2DtO//sdBsRtMiMjw10q59xsNHFsa7YCsVQGtNAkYWogRyLkKKt66fXkRkX9cKNVer0zajNDVho8+HqbIkF4xsEpPXnRliuSn+/cgUirK5H3If3LikoqWer/xJ96SrHR7tWbilmjctejvIbWkK8k/1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aXtUnfBm/RmYoAdAhMp7g7aP3a+4ZFnCVZuMBoG+XJA=;
 b=faW9BtYTMouOQOLJ0ZOzoc2bXUx/NPgHX+Bwgx5sXGA0dABPzMA46LModighAG4WNJU5CN8CdPo5RFoSfVwVkKNLy4Ak34cAtIkxE24Mc006excaj2d/ydRrA+yGs7vetWdVprykgtyrVpY/yAAzdQJvix+TAKcs08XsxuNghnYQPkmG0DuSadeE/3bCtS46GHtl5bOmjsBIJETJ6NTSrqx24acSKihkkC+Z27Fuu3CKwf31ZVS1lvk2PZNy8I81dkvIw7PUvAQxcgo+jzwtPelg/hcspcTyK2GEy1NVjOIDrB194Z54Kbet/zrvZN8ANv2Fv0Q2TjTYvHduhHLXXQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aXtUnfBm/RmYoAdAhMp7g7aP3a+4ZFnCVZuMBoG+XJA=;
 b=REGzqX535jrPExQjR5xop/jXEm/IxuOijqgwwc6zKwXToowceUci3aqLFuamW3LKc5fuXmgXx7d4HKFSCMjRshfW1mIexxsZmXS/+/RHMyqI0LSrzEuhcVTONQSyBo4gt1cH9naEiTOXcyN4tF9J+rNFx7ieP/xDF5aZOIxvUU0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4543.eurprd05.prod.outlook.com (20.176.3.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Wed, 14 Aug 2019 13:27:51 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Wed, 14 Aug 2019
 13:27:51 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Thread-Topic: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Thread-Index:
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AA==
Date: Wed, 14 Aug 2019 13:27:50 +0000
Message-ID: <20190814132746.GE13756@mellanox.com>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-5-hch@lst.de> <20190807174548.GJ1571@mellanox.com>
 <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de>
In-Reply-To: <20190814073854.GA27249@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0025.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::38) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4cc061f5-56ad-4773-7c58-08d720bb3481
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4543;
x-ms-traffictypediagnostic: VI1PR05MB4543:
x-microsoft-antispam-prvs:
 <VI1PR05MB4543101E2F4E883967CA67AACFAD0@VI1PR05MB4543.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 01294F875B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(376002)(396003)(39860400002)(136003)(346002)(189003)(199004)(6116002)(33656002)(7416002)(86362001)(11346002)(6916009)(2616005)(5660300002)(8676002)(476003)(14454004)(6246003)(7736002)(25786009)(54906003)(1076003)(26005)(102836004)(3846002)(66066001)(316002)(186003)(8936002)(305945005)(81166006)(2906002)(478600001)(52116002)(6512007)(76176011)(99286004)(71190400001)(6436002)(229853002)(71200400001)(256004)(446003)(66446008)(66556008)(386003)(6486002)(6506007)(66476007)(64756008)(486006)(36756003)(4326008)(81156014)(66946007)(53936002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4543;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Vs9ITQhDo95Y04P7vJSqSGZG48VlfvfPENlCo1dwgbyOptbvw1pd2E1mK3POI+WEgDsqmUBS4RMZInyDX3g62MvJ16dEjM+owZnp17xkqnaVeKjELYMDp0KjC7FTz+1/xPuOF5qdDQiRHBBkcTBvl3bPKQGJHWkOGSICXO3U41R+fsyeueZt4AF/iVe9KGEh0B1WnyYvp3NNJGE1Jc4rFHAUK0uexqgFjSt/RtrBRXiaTfDoNZ2i3mR2GxGhND+T7rH/3P+RptLFNJtizlvJ+NzM+nRyKAaL5ii04o9jSIu+QNPEKqd6F+Qe6O1wSgaWM6Sz/eAeeLMvhLnh+gfKuTU8jVQ775LxRCSTRTxrWXGDXvu0o5tzQI2BKBW7YP6DtNfNJrMs8A2j+PCaBvHcUN7bDO1EAdnJAKQaypE2Zps=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <EF42566A523CE142A2EFF155B9958285@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4cc061f5-56ad-4773-7c58-08d720bb3481
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Aug 2019 13:27:50.9468
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: IMnZjJw4rXdPNRe7707GHxiF1SFEJxFKOQBVTYGk2VFuwM9F8tUpkMTyYxiO1iPafyZWUOCAlqhQrz4SzCWVzg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4543
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote:
> On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > Section alignment constraints somewhat save us here. The only example
> > I can think of a PMD not containing a uniform pgmap association for
> > each pte is the case when the pgmap overlaps normal dram, i.e. shares
> > the same 'struct memory_section' for a given span. Otherwise, distinct
> > pgmaps arrange to manage their own exclusive sections (and now
> > subsections as of v5.3). Otherwise the implementation could not
> > guarantee different mapping lifetimes.
> >=20
> > That said, this seems to want a better mechanism to determine "pfn is
> > ZONE_DEVICE".
>=20
> So I guess this patch is fine for now, and once you provide a better
> mechanism we can switch over to it?

What about the version I sent to just get rid of all the strange
put_dev_pagemaps while scanning? Odds are good we will work with only
a single pagemap, so it makes some sense to cache it once we find it?

diff --git a/mm/hmm.c b/mm/hmm.c
index 9a908902e4cc38..4e30128c23a505 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -497,10 +497,6 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 		}
 		pfns[i] =3D hmm_device_entry_from_pfn(range, pfn) | cpu_flags;
 	}
-	if (hmm_vma_walk->pgmap) {
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap =3D NULL;
-	}
 	hmm_vma_walk->last =3D end;
 	return 0;
 #else
@@ -604,10 +600,6 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, un=
signed long addr,
 	return 0;
=20
 fault:
-	if (hmm_vma_walk->pgmap) {
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap =3D NULL;
-	}
 	pte_unmap(ptep);
 	/* Fault any virtual address we were asked to fault */
 	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
@@ -690,16 +682,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			return r;
 		}
 	}
-	if (hmm_vma_walk->pgmap) {
-		/*
-		 * We do put_dev_pagemap() here and not in hmm_vma_handle_pte()
-		 * so that we can leverage get_dev_pagemap() optimization which
-		 * will not re-take a reference on a pgmap if we already have
-		 * one.
-		 */
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap =3D NULL;
-	}
 	pte_unmap(ptep - 1);
=20
 	hmm_vma_walk->last =3D addr;
@@ -751,10 +733,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 			pfns[i] =3D hmm_device_entry_from_pfn(range, pfn) |
 				  cpu_flags;
 		}
-		if (hmm_vma_walk->pgmap) {
-			put_dev_pagemap(hmm_vma_walk->pgmap);
-			hmm_vma_walk->pgmap =3D NULL;
-		}
 		hmm_vma_walk->last =3D end;
 		return 0;
 	}
@@ -1026,6 +1004,14 @@ long hmm_range_fault(struct hmm_range *range, unsign=
ed int flags)
 			/* Keep trying while the range is valid. */
 		} while (ret =3D=3D -EBUSY && range->valid);
=20
+		/*
+		 * We do put_dev_pagemap() here so that we can leverage
+		 * get_dev_pagemap() optimization which will not re-take a
+		 * reference on a pgmap if we already have one.
+		 */
+		if (hmm_vma_walk->pgmap)
+			put_dev_pagemap(hmm_vma_walk->pgmap);
+
 		if (ret) {
 			unsigned long i;
=20


