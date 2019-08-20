Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B92BBC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:26:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70416214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:26:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="D1ie3cVo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70416214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EA7C6B026E; Tue, 20 Aug 2019 09:26:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 173A36B026F; Tue, 20 Aug 2019 09:26:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013A06B0270; Tue, 20 Aug 2019 09:26:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id CCCED6B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:26:33 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7B3C78248AB1
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:26:33 +0000 (UTC)
X-FDA: 75842880666.22.knee58_56356d612353e
X-HE-Tag: knee58_56356d612353e
X-Filterd-Recvd-Size: 7116
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00076.outbound.protection.outlook.com [40.107.0.76])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:26:32 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CAsnVhtmw+MBIxeMXra9Ty1DoNAfr4GJWNBPlUc70Zuau6mPGh+SRp9MYEjapsniysHnxXDLa6BnSZtxtYxaUUk0FWOZB8dJqUhGQW/NrgPQfzeiddbLjFJ3hvlnVjZGgP5Qgei/ClzHcL8H4XraZVEMS9UssfwQK9L9Tgn2yuykVtIhF3iHp/GMxBicprceB6ErMMBsIlxa/O63Lwwr1v+9d4D8ohdaFGG4j6wFLO4CySOBsVFXq8A2MtpnY7/j7oQIG3TzqUn9n3y+zZQr5pfXrONvAk85hr9RIRMDSU0L7D++XgRNZynlYJX7W/KfkilbtTg/v6WYQm5K0yXPZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yM/yg4H+CNyOZASWU61u/O47Fjy0hAn2A/Rl+Bhb2VI=;
 b=Sn4Bd/gl+z6aje9jYakqkz6OPsf8RVeWVLHf7Jtpeqm4W7dfdobNrGnXqXhEFx0GeEtJk/9AVmLubfW1YINECAAQZPrSCpDzcnD8wOIRq4xWptrpA81H4Eo68WshjBMdxWTX3JQ4cAwtDo2ByCp5q2xp2b212M2g3LGLf/KFRdhS0kVniCfpHNhI8aAJci6qfXfz0l404kOdlcmk4MEwOL9sRcctZ70evJg24+M37W9tyWwiBVCXvb8rP2kLNTxtyMSEaXuI+WtWFVtdbQHmIHJLcudC54RQtn/TkdyNFEzkXIM8R3C5xD56Hw1JNad1LqiWVTKTdYGvjneTJHjBQA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yM/yg4H+CNyOZASWU61u/O47Fjy0hAn2A/Rl+Bhb2VI=;
 b=D1ie3cVooZY7Xlk16/Y1cI275q0Rm2AzThZv6yZIobLSrX6hxarUkKcscCS5DnfWWuFvfffTiJ8qHt6lBI5QyzQqofB6ul8dVcS0svtwmYAhpXE2JG6+qsxvb9X2B4JVweq2SOHYqTNlEukn0CIvzbOQnwcs/f+hqaYPd5IDLMM=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4832.eurprd05.prod.outlook.com (20.177.50.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Tue, 20 Aug 2019 13:26:29 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.018; Tue, 20 Aug 2019
 13:26:29 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>
Subject: Re: add a not device managed memremap_pages v3
Thread-Topic: add a not device managed memremap_pages v3
Thread-Index: AQHVVaR5OJ5/f8ILRkKWPl6fjF7s4qcECm4A
Date: Tue, 20 Aug 2019 13:26:29 +0000
Message-ID: <20190820132622.GC29225@mellanox.com>
References: <20190818090557.17853-1-hch@lst.de>
In-Reply-To: <20190818090557.17853-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0104.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 62df5a3f-d7ac-420e-79e5-08d725720241
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB4832;
x-ms-traffictypediagnostic: VI1PR05MB4832:
x-microsoft-antispam-prvs:
 <VI1PR05MB4832CDDEDBE44DBFF0962BA4CFAB0@VI1PR05MB4832.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4941;
x-forefront-prvs: 013568035E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(346002)(396003)(136003)(376002)(54534003)(199004)(189003)(86362001)(99286004)(478600001)(25786009)(66066001)(11346002)(102836004)(71200400001)(6506007)(386003)(446003)(476003)(33656002)(4326008)(2616005)(186003)(256004)(6246003)(14454004)(71190400001)(76176011)(14444005)(305945005)(53936002)(486006)(7736002)(1076003)(66946007)(66446008)(66476007)(64756008)(4744005)(26005)(2906002)(52116002)(229853002)(8676002)(6486002)(81166006)(81156014)(66556008)(8936002)(54906003)(36756003)(6916009)(316002)(6436002)(5660300002)(6116002)(3846002)(6512007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4832;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 PLxb9jzB+NrrG3NcZNztvgSRAFSmyWycpiI4wHlMAtqFgCMUD1OS+HAzDc4+jgg3CIkjOutw2wUJWrpv8rRgJ4rmfhH02V/8WnK+XEXB0t3LJNTCvBTVvV28pdRaXXtIG99qLFvzELwyCPWwCiHoCaVRZkCorF80AfG+k2jc62OWrmisIxNn1QR9xMatUZ8E0OWWW/DSkUzSAsHn+DzK8VvtCQ7T/GA4pn7T+2+iNXJBthQtMHNqgDbCHMzsYhg1dMAqHrgRTNbGPt9Sh+pw73Sc2lX/RFyVbUPWglBkUXtUWLkUKOakBQQQJJykE4xDIyfHSdmHj4LRPuLOJtH780Cl0Luk+LXkVm8uZVqm8118Vk8/ZbnM1crzjKqsk4sHuMg4m4Mb93CoihXBqb+3u157BZfrfG/PalgazVAZHew=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <76D56E88DFAB2E4AA34C7F681118F0D2@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 62df5a3f-d7ac-420e-79e5-08d725720241
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Aug 2019 13:26:29.2368
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: CTIRnFwaRThv874lgZ2tPWFiZjUYNtgSFTy/ezzGVU/Xe4U8k/K8gLoQTLD7AiMzooug1siugFUFIkv7lidfgw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4832
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 11:05:53AM +0200, Christoph Hellwig wrote:
> Hi Dan and Jason,
>=20
> Bharata has been working on secure page management for kvmppc guests,
> and one I thing I noticed is that he had to fake up a struct device
> just so that it could be passed to the devm_memremap_pages
> instrastructure for device private memory.
>=20
> This series adds non-device managed versions of the
> devm_request_free_mem_region and devm_memremap_pages functions for
> his use case.
>=20
> Changes since v2:
>  - improved changelogs that the the v2 changes into account
>=20
> Changes since v1:
>  - don't overload devm_request_free_mem_region
>  - export the memremap_pages and munmap_pages as kvmppc can be a module

Looks good, I fixed up the patch with Dan's note and reviewed them as
well.

Applied to hmm.git as requested

Thanks,
Jason

