Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0771C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:21:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4EB92133F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:21:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="UAJVyHEx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4EB92133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7766B0007; Fri, 16 Aug 2019 11:21:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380FF6B0008; Fri, 16 Aug 2019 11:21:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 221656B000A; Fri, 16 Aug 2019 11:21:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id EFC9A6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:21:48 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A1BBA181AC9BF
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:21:48 +0000 (UTC)
X-FDA: 75828655896.11.cause75_84184a5ba9d11
X-HE-Tag: cause75_84184a5ba9d11
X-Filterd-Recvd-Size: 7128
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70050.outbound.protection.outlook.com [40.107.7.50])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:21:47 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=FFkQAU3fkEaElh9ej4aBuOWi9I8bnEuaRSxZ30/nfPhM8UgxNHU5DhYQf71uNusAnPsxh/NIQ1HWUYG8blJij1yBmZ0DoUCbn/3mfpY68EQmIuWM2w/5pyZuYPb89EJte2sFCm7UzaVAZgBFuKw969TcRxjJrbFS0ZQTZiFoCQ3wdBKesdY1IOcAdfSsbwdYnTdH+KGtxAG1mzEJnGKiUY288Dno/8vsRSSCLy2gw4lUuVmNuNwFZaGDoluSIQNX+E97qiTZ91tb82j8QJN2dTaijA6A8upQ/euTJoLlkrmFYKLJcQ1F2gBgHhGvGK8B2XM8YFWZ4O88xdZz/6C7rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rS76EDuPEyeL5Rl1fno4/MNIps/Oi0lANHdSDWdxe78=;
 b=RXKBgAsrVV2XJmT/6iiY5AOd5/o4fvf4Eq7bc4AUL0DKj+G0TUfSa5rd9W/2HCGuEK2fKUFZXZiztTpbpbVbD4ZltoLJrzkyXWWmy/Z1sfIcQl/dTu3YskpqGWkoXxwSetz/mxShe7Vn+QsIKmdsVHBlOjx0ivDocE+DYqnqUTdFIBfzGltpv9Hvz8CBI15pE6hA9N+VaIorIqFmiIZKWBaheqPPwF1xcNC+3KnD45ISPRo4U6glnSMLJjRBKToISgaLDDRywx3B+ecYIhh5AMzSMsVrpx35TSL3aq3GgUWweLrG1JVzqwOXZlKjtWBsEhJAF1y8GKFvNp+hGpJvag==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rS76EDuPEyeL5Rl1fno4/MNIps/Oi0lANHdSDWdxe78=;
 b=UAJVyHEx8/QQS/e5wmbvwzUXDKDOqhwBZMl3CYj/0L6yuXjTeBOWMgpTwkKhSedrxZtKrx3h5EIt8GkD1leUqT4RqZKDFGaoC3fnDzBCa8hxDSLd+dOJ2fOCLS++4Us6Tu/M+cSOla9d+M0l6ZwSgDr1sStaKw16afEQ2TNqI6Y=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3213.eurprd05.prod.outlook.com (10.170.237.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Fri, 16 Aug 2019 15:21:44 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 15:21:44 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 10/10] mm: remove CONFIG_MIGRATE_VMA_HELPER
Thread-Topic: [PATCH 10/10] mm: remove CONFIG_MIGRATE_VMA_HELPER
Thread-Index: AQHVUnZJYsnBieZzVUGpUZxcbs6dtKb956sA
Date: Fri, 16 Aug 2019 15:21:44 +0000
Message-ID: <20190816152138.GI5412@mellanox.com>
References: <20190814075928.23766-1-hch@lst.de>
 <20190814075928.23766-11-hch@lst.de>
In-Reply-To: <20190814075928.23766-11-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0041.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::18) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d688622a-311d-4f9a-5b6a-08d7225d724b
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB3213;
x-ms-traffictypediagnostic: VI1PR05MB3213:
x-microsoft-antispam-prvs:
 <VI1PR05MB32134E3484BEA6259E6E5116CFAF0@VI1PR05MB3213.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1122;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(136003)(346002)(396003)(376002)(189003)(199004)(86362001)(36756003)(66066001)(6916009)(53936002)(81156014)(8676002)(33656002)(6246003)(4326008)(476003)(14454004)(256004)(11346002)(486006)(8936002)(5660300002)(66946007)(66556008)(66446008)(25786009)(66476007)(64756008)(1076003)(7416002)(4744005)(7736002)(54906003)(81166006)(446003)(6116002)(2616005)(3846002)(316002)(305945005)(52116002)(6506007)(76176011)(99286004)(6486002)(6436002)(186003)(26005)(386003)(229853002)(102836004)(6512007)(478600001)(71200400001)(71190400001)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3213;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 LSSkYRTKWULuarBCdAI4ev3NilPmoRFGRPD1mKzzAOrUVkT/KSLQLhu5kxQpvON/GmJdKaEqbDcjvXsFFSZHS4a4NNOEmZMLrUAyW9ohvPv2j+rkRysqY/lOx/HTm1fOjXu4ZcCAxtHNCnwXop81ViizY7NSSFO2w+vALCyI7TnVnEKcoHCLkZSzNmcCrrlAox+8qKsMBfAbCzQ1D1TAV4aSr6ec5C0cZghq2qSRXoC8k5GNfI5X6YxVT+BtMt841x1S2dtLidqXDllIcd4Q1ImCqG+iGwYxIRLodwV4EA6CavTzGrS1KbjwxuyT0ajE923wzHVQ43KoSdeSFLa90V9aMe9s+kvoPLofF5yU/RwqbP7qUVC8A3zKhUmsypU8ZvcK06Rz5fQpRvjUUXy1fgBQeim/CVEQH0Gey5IIo3s=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <BE99DC30C2439747B23BD48ADDB50FEA@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d688622a-311d-4f9a-5b6a-08d7225d724b
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 15:21:44.2527
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DB77qARSXSVjoLwsNB/gfby8t5ZqoSSOk31af2mOqGhP/RtbR8vnAxR9ONmlanih3n5yS9jZEqFZTyREr5kJig==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3213
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 09:59:28AM +0200, Christoph Hellwig wrote:
> CONFIG_MIGRATE_VMA_HELPER guards helpers that are required for proper
> devic private memory support.  Remove the option and just check for
> CONFIG_DEVICE_PRIVATE instead.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/Kconfig | 1 -
>  mm/Kconfig                      | 3 ---
>  mm/migrate.c                    | 4 ++--
>  3 files changed, 2 insertions(+), 6 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Aside from it making sense, I checked no other driver enables
DEVICE_PRIVATE, so no change in kernel build.

Jason

