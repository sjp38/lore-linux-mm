Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47C35C3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 15:05:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 005B52189D
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 15:05:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="qy6MoR0+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 005B52189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56A366B0008; Wed, 28 Aug 2019 11:05:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 519F56B000C; Wed, 28 Aug 2019 11:05:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40A646B000E; Wed, 28 Aug 2019 11:05:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5626B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 11:05:25 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A30C9AF96
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:05:24 +0000 (UTC)
X-FDA: 75872160168.09.459A97F
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin09.hostedemail.com (Postfix) with ESMTP id 481CD180AD80A
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:05:24 +0000 (UTC)
X-HE-Tag: boats62_6933f0c49b056
X-Filterd-Recvd-Size: 7461
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50046.outbound.protection.outlook.com [40.107.5.46])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:05:22 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dNqjLMjCDMmDZgertpkEYrH2ZZTj30EK7OTb4gCyFxkMizUgiLXRUJqd7FPpOlIMBA5gS5/i32XtJ+vZwkuCyoh3MXt0zmFAMOz23auWPJpdee0L87Bk7W4hO8iczUbNoYxz+uPa1j1xutuk8IOf7xVLErJbdw9Rsv/yHAM8iKqldRAGBePxxmpS+sWPYcnP0scG/CWtyR/SLaODjbEnMN0fCbHjmQwJGvTMVLnzA5k08zf/4vZvXIiG2HefH92OkwyVVbDStJdFvMqluu+JoB7+R4CxXCobd2SOlln8N6H9YH7zTQd7QAo7dPzL0rDdmlpRFhbMdu/eacvuj2fOvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NIzqAZC+Rv88aklpUKo1hI3j0zYPDkUYxyeG0hug2Q8=;
 b=Yf1fm1t+LWT6niJYNqgb+JYUkLpWhfIXRYPAsC3Oqk0eil5LWZlBVM98jghU0d5nsYq84ZvxhPYabJbn2nv6PMM8T85ShMG+nI64PVJiZCg17BBlq24KaGMDe+ie6wDGtf7sZ3N/3wSteYsK4SlyyrmS5H/VgUNwQMQOLd3T4Z6Gb/NzIfTBMdcAQAuqOu2B1vOKZqVTTLHz6hq7H7IaMFQAm4yMWttia4raJlJrXVeBzJs/OEaEDLs8JxEe/Pb4INJ1yQ81KlzcemIuZoZvx/85HIRxf5Ss8fz0O4pVe+COyCeweqnizF7J+o7CPsd/FSaFt+5bSPY/F17GCAXpcQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NIzqAZC+Rv88aklpUKo1hI3j0zYPDkUYxyeG0hug2Q8=;
 b=qy6MoR0+pM8E0nm63mmJ9dyC+hzr0lEPkqUiTxuJQgKvkVkBjQUkQEj6MkK/Dtp4U3dQUydOkc+L8LDCe/6JPyEdr1rpclixnztXPFEmLEPj8E0R6GnLRIx0LgaD87ujWo5jUwk2VKNe6CHdimhN3yZw9w5TYIzTKCARvQiMr+8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3231.eurprd05.prod.outlook.com (10.170.238.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Wed, 28 Aug 2019 15:05:19 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.021; Wed, 28 Aug 2019
 15:05:19 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton
	<akpm@linux-foundation.org>, =?iso-8859-1?Q?Thomas_Hellstr=F6m?=
	<thomas@shipmail.org>, Jerome Glisse <jglisse@redhat.com>, Steven Price
	<steven.price@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas
 Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Topic: [PATCH 2/3] pagewalk: separate function pointers from iterator
 data
Thread-Index: AQHVXauzoOyMGt/Rm0+/Xu8LAWoHTqcQqKUA
Date: Wed, 28 Aug 2019 15:05:19 +0000
Message-ID: <20190828150514.GN914@mellanox.com>
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-3-hch@lst.de>
In-Reply-To: <20190828141955.22210-3-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3295f98e-30c0-4093-39a4-08d72bc9242d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3231;
x-ms-traffictypediagnostic: VI1PR05MB3231:
x-microsoft-antispam-prvs:
 <VI1PR05MB32317232C381B96F37FC9D96CFA30@VI1PR05MB3231.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 014304E855
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(376002)(136003)(39860400002)(366004)(346002)(189003)(199004)(6436002)(6506007)(8676002)(6116002)(81166006)(4744005)(2906002)(3846002)(81156014)(71190400001)(71200400001)(99286004)(66946007)(1076003)(66556008)(66476007)(6486002)(86362001)(229853002)(186003)(8936002)(33656002)(305945005)(256004)(7736002)(386003)(446003)(2616005)(26005)(478600001)(102836004)(64756008)(4326008)(476003)(14454004)(6512007)(5660300002)(66446008)(6246003)(76176011)(25786009)(11346002)(486006)(53936002)(66066001)(52116002)(6916009)(316002)(54906003)(36756003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3231;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 E7BYcxFP7SiBLFAtPEHGeII1iE4OE6fy2y/FGTKw7uWZEbuSSaVkTeiyvjgWFtZuGrSqGVTqNn1Ro7kmPJtrxd03+NUVCgmxbbgtufwKhxS3tbdUvPxsva9iVfumFozyzNfaR+E7/2i4dYSHmIZRvxOkUVckkoql9q2GMaR8O7NIr1vBYCjq9WdW9Xoq/nqYcrug+Y/lXr/XDE2y+rkg9eS1ON48aiMTuqDgtG4hUpUW/Bx88mcazNgne7yeRLi+A/JoV1vRIwaIQULCl7rlduBRLmMK7rzhVc2hyxp0IYbcP7rjdgIo7dwsc+of9RO3mbEAlxW3eDT2m0v6YS4dSYdFSI9AGoxdfMXMttebx1gltiCGCdGzzda8AdnVxCzOijOD5QtqqUBiLPUN79P9MhhdlPMVhZ27E+tnVk9QTLg=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <DDF7F470CEE7F54BB9E26C59705027BE@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3295f98e-30c0-4093-39a4-08d72bc9242d
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Aug 2019 15:05:19.4037
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: O795HJkDcQRFlxtnNpleCnYMo3hHxkSGwUwGhbBn2nXvFu9AkNpuHYux6GE2iL2taTQfYNMw9dKTcFp70mbILA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3231
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:19:54PM +0200, Christoph Hellwig wrote:
> @@ -2546,7 +2542,7 @@ int s390_enable_sie(void)
>  	mm->context.has_pgste =3D 1;
>  	/* split thp mappings and disable thp for future mappings */
>  	thp_split_mm(mm);
> -	zap_zero_pages(mm);
> +	walk_page_range(mm, 0, TASK_SIZE, &zap_zero_walk_ops, NULL);
>  	up_write(&mm->mmap_sem);
>  	return 0;
>  }

[..]

> @@ -1217,7 +1222,8 @@ static ssize_t clear_refs_write(struct file *file, =
const char __user *buf,
>  						0, NULL, mm, 0, -1UL);
>  			mmu_notifier_invalidate_range_start(&range);
>  		}
> -		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
> +		walk_page_range(mm, 0, mm->highest_vm_end, &clear_refs_walk_ops,
> +				&cp);

Is the difference between TASK_SIZE and 'highest_vm_end' deliberate,
or should we add a 'walk_all_pages'() mini helper for this? I see most
of the users are using one or the other variant.

Otherwise the mechanical transformation looked OK to me

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

