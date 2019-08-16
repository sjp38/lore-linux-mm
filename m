Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE06EC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:43:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9114C2086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:43:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="jodWbgNs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9114C2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B8756B0003; Thu, 15 Aug 2019 20:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 268C56B0005; Thu, 15 Aug 2019 20:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156C56B0007; Thu, 15 Aug 2019 20:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0176.hostedemail.com [216.40.44.176])
	by kanga.kvack.org (Postfix) with ESMTP id E20866B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:43:12 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 54042181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:43:12 +0000 (UTC)
X-FDA: 75826441824.13.wheel06_1bdb2b05b8d32
X-HE-Tag: wheel06_1bdb2b05b8d32
X-Filterd-Recvd-Size: 7600
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50040.outbound.protection.outlook.com [40.107.5.40])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:43:11 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=i4ZnDIFqVa32ZRCo6FyOtKqmtHJdpZ+wio23ioQgokDEsYjQlskS4R/GXtZHb2IyRBhsBP6lNpnPijUyonXdRlKvg/JwGKEw9SZ038V+J/xQc2DCy67THP2CDxlYkT7cTyHbD8f+Ohyiyid4W68AvSarYsYsX6r1yfZuy4OdfOqy6GvEri2duAkx4wTpjkAFVWf0qD79dtEUIQp1SNM2ZVHUkcys4KHkybAGj0wYyuKj2TmTnjMcNOc03IOIKdgyEIuJY+K7KgxTmje943hXouiUAjHcGB9wcKtb+D1kVTdVb1QNpeqw8mpZAbkOLyY5GCgNK2NxtaUTYiNJCgFrUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=f+fFWNtn3fh9ETaY63oLhYA/T5giLbLqJ/XZiEiqCu4=;
 b=Slklgyq5I3kJrEM3DSFiAlfv5zOCxysUVzBSDldV5MONflIjHo5nzvTRE2UjxqxrU7sJQO1w+RmCoIJKeV/WbCdJgnlCdLMjEJrB4XALHolHYt5hCOUgchRRJq8HaRCe7BfeHpdjZlNQpK3l8Y2d40J7nv2C1CUoYU0xnL8C9BTovwPnI1YR7wflCirPK0yujKI/qk9OKc55S20o8GuJJ54YQ6gHi66W5zF0tGRWjXfENsVgJmlPgEw8OM+s/riOunbHTG7RDkFaEP5lC22E5HiVFLdFzzMk1VAjAen94UBWrJkQTC+zIhaeRUP0GTif/1iLgnnqEwbbHYZboSKN3A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=f+fFWNtn3fh9ETaY63oLhYA/T5giLbLqJ/XZiEiqCu4=;
 b=jodWbgNsx2PUvjFc8wwpCsTnz5ILZzWpt1yigSDEzqvkhytQBu7a4AxixAhEGzmP6srsWpGQnIDGNPZPNqX8cbZ+KUqkYG0pdZlbMkEpMNhNtdiPOsHJBigxtN2SGR5ftHCnq0w2lxQ99kMccr34vtTmwbDR0SinqD9zQ4eMQtE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3279.eurprd05.prod.outlook.com (10.170.238.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 16 Aug 2019 00:43:08 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 00:43:08 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Thread-Topic: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Thread-Index:
 AQHVTHDc5B4IgstYQk6yBJaVfn8xGqbv9wIAgAARNACAAMySgIAJE76AgABlPQCAAGF5AIAAFowAgAHIzYCAABojAIAAAd6AgAAIBgCAAAXLAIAAAlcAgAAC0YCAAECugA==
Date: Fri, 16 Aug 2019 00:43:07 +0000
Message-ID: <20190816004303.GC9929@mellanox.com>
References: <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com>
 <20190815205132.GC25517@redhat.com>
In-Reply-To: <20190815205132.GC25517@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0040.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::17) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 106bd7bf-d98c-4516-588d-08d721e2b4f4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3279;
x-ms-traffictypediagnostic: VI1PR05MB3279:
x-microsoft-antispam-prvs:
 <VI1PR05MB32795D2B9DE58CE56782B8F6CFAF0@VI1PR05MB3279.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(136003)(39850400004)(366004)(396003)(189003)(199004)(66446008)(486006)(99286004)(2616005)(53936002)(25786009)(186003)(446003)(14444005)(4326008)(26005)(66066001)(8936002)(8676002)(81166006)(476003)(2906002)(102836004)(64756008)(66556008)(3846002)(478600001)(14454004)(11346002)(229853002)(81156014)(66476007)(76176011)(6506007)(6116002)(66946007)(6246003)(386003)(52116002)(5660300002)(36756003)(4744005)(305945005)(256004)(7416002)(54906003)(316002)(6486002)(71200400001)(6512007)(33656002)(71190400001)(1076003)(7736002)(6916009)(86362001)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3279;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 OvC8VzM8dF3CLVqHkn4dBVstZo8TtpmSrOkswOKvfj9a0WLRThrnxNl5Qkacpo6l1I5Ka1cTfAhuy9xVyJc+PzcX5cmv2b0+NHwpPXob/TpLXaU5DJPmwHaBsj2RIY6fKoKtjo7Fo5EudnY0EdMKAZSczA8GGOPzbUOpQFnTm2HdxKOo/VG57rxw1wwdAZ1hpeTqh2guOGXVrDypYG9gxjU0dxDgXSuyj7aeSDtnBSh38edJQJo9R90PiFDEQijCoJv1CAS1tuSLRobZtKPym+FryB6azqE1CUJEzd6ZhldRE53XhDcKSvN2cVSxia76qCNUVSqAsPPHTBaRC3tWgl4ey4x0RurXJydfnumXHc94tl/6SIHvq7vP6fMNh7l6+TmRvnxMTE5kBQW2tbWd8r+NBpXNlxmdgl0sTP6/QUQ=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1B3BBB0F1C80154FA9AB9F1D5250931A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 106bd7bf-d98c-4516-588d-08d721e2b4f4
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 00:43:07.9721
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DfwHXrCGyHOLLgzXg9/lhVI/zaC66jQfTzcfrsc6nG+hSL7Zg3SzXg2gAuSKlVASRuWkjY4cclT+21T2JpzUEQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3279
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:51:33PM -0400, Jerome Glisse wrote:

> struct page. In this case any way we can update the
> nouveau_dmem_page() to check that page page->pgmap =3D=3D the
> expected pgmap.

I was also wondering if that is a problem.. just blindly doing a
container_of on the page->pgmap does seem like it assumes that only
this driver is using DEVICE_PRIVATE.

It seems like something missing in hmm_range_fault, it should be told
what DEVICE_PRIVATE is acceptable to trigger HMM_PFN_DEVICE_PRIVATE
and fault all others?

Jason=20

