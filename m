Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD138C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E75D2186A
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:09:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="T7tkSC51"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E75D2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8DEC6B05CC; Mon, 26 Aug 2019 14:09:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C64526B05CD; Mon, 26 Aug 2019 14:09:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B54656B05CE; Mon, 26 Aug 2019 14:09:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 9529D6B05CC
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:09:47 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3D55F180AD801
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:09:47 +0000 (UTC)
X-FDA: 75865367214.10.crush44_8f7ad36457721
X-HE-Tag: crush44_8f7ad36457721
X-Filterd-Recvd-Size: 7880
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130089.outbound.protection.outlook.com [40.107.13.89])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:09:45 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=U5dIh3Fl+mOCroP3/RVqLquYBThvKEO3WLt2LpTjqDmXj0RglPTFSlReduzVnGgCxh78w3k4qCyVo2nKRtjIMBnMbLSzTI1z6drldObKdgXdAfufOmRCS0TnvsYVhI3PSk8sE/kEalEUKkPHLeCJEms0QupnXPl8QEGAWTdIFEuMwu8vvw3q8RjDq4l50dDTQ0mSqFfI2Djv0q8WWWYpVQv9/dAj8fhr3k683IjdlyCW9sUOCa/dHJgxOGes9BJjO9GiMm7EuISLq/Nyt/mAIBWpRjD8P4Sqb7NsN18FrySIonR3GPG/b6D+v4VTxZBeazFS/dvIz6JwsKTjv2OXLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FGRChx0m+eJzl7dhyV88O00JmWNdWjyEK7YCMGleaCY=;
 b=i4uFUHHZnqy20vQNh6jzlKfudxNobLjkTAQqXaYqr7YY1GWTbZHeGCHpNw726M4p9lOTGJNMlULVA30BY+rCdyej6WGbaVZcLKsqJ+UJksddYUvSMoU7ClWQO9g8Vs2e7P2Izpm4+sjcGI3wQMGjyNpd/iczhSF7PHfmCN1r72TWqJ0bbQdR7rJWzN0zgBt/2VYDKxVRBXRdbfImF4QeUwhN/wbfoFVmZOdR6mNITDlHcwuIOBP1pUdwD7JK5ZyfmLNEMLormF4+EvRpUKivUIKw/mFutghdvzIqodJoUgRRvsfw65vcfx9u0POSLwLYeNtNl6CRhqPkBBNGwMqwtA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FGRChx0m+eJzl7dhyV88O00JmWNdWjyEK7YCMGleaCY=;
 b=T7tkSC51J467IklLMNl+7HvJN9yBLFC6diuldOdNJ/CelHnOfe8RFlgiEsDgMqsUr+BG3G+cRa6QxpfCBMgJxL7CYn48zzjQXCHfItYdFOHORxaI0k76lt7AM5rpoOPoKjixOdOJzhN/LuYQNWCglayFfaosIG4xmL45ZysFBdc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6269.eurprd05.prod.outlook.com (20.177.49.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.21; Mon, 26 Aug 2019 18:09:42 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.020; Mon, 26 Aug 2019
 18:09:42 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Christoph Hellwig <hch@lst.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/hmm: hmm_range_fault() NULL pointer bug
Thread-Topic: [PATCH 1/2] mm/hmm: hmm_range_fault() NULL pointer bug
Thread-Index: AQHVWgCoFJcsFk0T0kqUlq3r7T9NpacK5SEAgALXogCAAAITgA==
Date: Mon, 26 Aug 2019 18:09:42 +0000
Message-ID: <20190826180937.GI27031@mellanox.com>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-2-rcampbell@nvidia.com> <20190824223754.GA21891@lst.de>
 <e2ecc1a7-0d2f-5957-e6cb-b3c86c085d80@nvidia.com>
In-Reply-To: <e2ecc1a7-0d2f-5957-e6cb-b3c86c085d80@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0037.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::14) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a43b3676-6b61-4b08-c38d-08d72a509191
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB6269;
x-ms-traffictypediagnostic: VI1PR05MB6269:
x-microsoft-antispam-prvs:
 <VI1PR05MB626915FD045BAC4A7B16A0EACFA10@VI1PR05MB6269.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 01415BB535
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(396003)(136003)(376002)(346002)(366004)(189003)(199004)(386003)(54906003)(102836004)(66946007)(53546011)(6506007)(53936002)(6512007)(3846002)(52116002)(316002)(6116002)(66476007)(66556008)(64756008)(66446008)(71190400001)(256004)(14454004)(26005)(1076003)(66066001)(6436002)(36756003)(8676002)(25786009)(4326008)(305945005)(5660300002)(186003)(86362001)(7736002)(71200400001)(76176011)(33656002)(2906002)(6486002)(8936002)(6916009)(99286004)(486006)(476003)(478600001)(11346002)(2616005)(81156014)(229853002)(446003)(6246003)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6269;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xJx5kMvdEmdL4l/EBzz1xBnKWwCJiReAExlcCqgUJAGowwln5DyiNlB1cL4Qw3vRobHskkqQz1rPpnBWJLYSEfe/pGWwQUE0lypDfu9JoCa+umkBfHKaZbXLd1cKn6UfEYj8bc6yQapdfXad+IEC4j7/xVVU8H1M7QRS8wE4SYaMWJl5KeZGbXmiO5XdXpdvHY7iwOB9IYeX624tc9lA8qLDolI5KM4g9sa9AM6B4Jq2Zcr1mREic8FDMdIAR/zKqa7WhbUaET99PLwgzv2BFrw589cwg+F58MteOtUa/5PqNl4f/CRJEFHmWVkutW64QtE0fSCC1AkTkdMj7Ut/VONhtOhbVoil+g2FzFm8UDkmNUD4PRceBTowaNkGM8mM+3doPWXNKnY0hNyVUnIN55b6NEzJcy5FlTVLYFoWpvY=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <13598A34FD89014892271F429ACE899D@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a43b3676-6b61-4b08-c38d-08d72a509191
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Aug 2019 18:09:42.5922
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Ms67caVPI1xL6QIPQ45f408XuFjZVGN4eZ4NOTmxeOOExwJwjOf8QSMGJGkPmcWZxQk+IWGtouBhXrhcvjIaMA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6269
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 11:02:12AM -0700, Ralph Campbell wrote:
>=20
> On 8/24/19 3:37 PM, Christoph Hellwig wrote:
> > On Fri, Aug 23, 2019 at 03:17:52PM -0700, Ralph Campbell wrote:
> > > Although hmm_range_fault() calls find_vma() to make sure that a vma e=
xists
> > > before calling walk_page_range(), hmm_vma_walk_hole() can still be ca=
lled
> > > with walk->vma =3D=3D NULL if the start and end address are not conta=
ined
> > > within the vma range.
> >=20
> > Should we convert to walk_vma_range instead?  Or keep walk_page_range
> > but drop searching the vma ourselves?
> >=20
> > Except for that the patch looks good to me:
> >=20
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> >=20
>=20
> I think keeping the call to walk_page_range() makes sense.
> Jason is hoping to be able to snapshot a range with & without vmas
> and have the pfns[] filled with empty/valid entries as appropriate.
>=20
> I plan to repost my patch changing hmm_range_fault() to use
> walk.test_walk which will remove the call to find_vma().
> Jason had some concerns about testing it so that's why I have
> been working on some HMM self tests before resending it.

I'm really excited to see tests for hmm_range_fault()!

Did you find this bug with the tests??

Jason

