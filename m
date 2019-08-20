Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40C07C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8BFE214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="aMslOdLO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8BFE214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EDD26B026F; Tue, 20 Aug 2019 09:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8784A6B0270; Tue, 20 Aug 2019 09:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 718356B0271; Tue, 20 Aug 2019 09:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7556B026F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:26:57 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D530E8248AB1
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:26:56 +0000 (UTC)
X-FDA: 75842881632.10.scarf57_5997fb42c1f1f
X-HE-Tag: scarf57_5997fb42c1f1f
X-Filterd-Recvd-Size: 7445
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80082.outbound.protection.outlook.com [40.107.8.82])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:26:55 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=OclklD1EXCvXwZ3rJG/JVC6Pm/lhKI1V5oyOHm3/sHTOGoKfkUMpe4lbd1HjP1mYMZ0TEuSViF/6EW6s+b291tp0+gY0Ze1J2Y60BgPXoIZPMlu586o0pRpcYNqD4ZBtkojEdMyuZAybG6hkv+NyqkE04RjL72+ITpIvDF6TbTLX4KSdDaeD519eZrH9Piis5QgL5vASbiSuUVgl9uHqUpp4ll+bU7LB/QAcuWRfTP4PyBWxYG64LuVfjuCfjeC9yeX3PWmxd6UDfVcvsvQhW9NPCFBaUb4oTGt9ntF+yCy3a5EFEC1PLlRIWousJs09H5aasRdj0ygCs02/FUHszQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qk0Zfis+FYA5R200PWCSUF5HtU1meX3JvrdZSBKuRvY=;
 b=HBmE7fhFpGbDAllay+KJOLMj0cUTlj5EzV2YaVDALT2ic3N7zW7lFkLj5Eav+ZDH84DIc2rlbjl+YV0qOAd5+hqMZT1kxdflNo4C81h0bIqiTU5jT378UWYryR3j8Im4oO+7R/pvv4DYDGvSYhY8JCpYaZ6rhI+vezuBnmqN6MVHNauWyMuEkvhmWe1piJv5Nj8kVsK+GAP7bLJFXoTzfbqc11tWdQVuZp/Y2vSzDoXMpguddME8ZH3n/FplnA7LAtqVougT/wzrxVPXMKzIJkUembXYH9vkl3sLYuxaamtodFAxJ2I0ehmuxg8fbGe0YL2Gxs6KGra+YdSD0+cPCw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qk0Zfis+FYA5R200PWCSUF5HtU1meX3JvrdZSBKuRvY=;
 b=aMslOdLOfrIzJghLQwoRqBBiOhjCCgpZupK9mJMt4v4B6KwEIQclX8aAeQMpKy0LbnWbDfzRVKcrLbIKsKsiufI2VVWLaqzKPR4PRrUBGqeU5bwZj7Ko/jg+W8jukfjJEb/ZVoRydNi0oX9ckKyO1fx0mHu15K7bWOmErY+fxKk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5231.eurprd05.prod.outlook.com (20.178.12.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.15; Tue, 20 Aug 2019 13:26:53 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.018; Tue, 20 Aug 2019
 13:26:53 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm
	<linux-nvdimm@lists.01.org>, Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Topic: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Thread-Index: AQHVVaUUhGk4jDl8B02XMFt421bWy6cDRjIAgADEW4A=
Date: Tue, 20 Aug 2019 13:26:53 +0000
Message-ID: <20190820132649.GD29225@mellanox.com>
References: <20190818090557.17853-1-hch@lst.de>
 <20190818090557.17853-3-hch@lst.de>
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com>
In-Reply-To:
 <CAPcyv4iYytOoX3QMRmvNLbroxD0szrVLauXFjnQMvtQOH3as_w@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0006.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::19) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e7be4bf2-af4f-4394-0f67-08d7257210c4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5231;
x-ms-traffictypediagnostic: VI1PR05MB5231:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB5231C3FCE9C7BA2C30813F6CCFAB0@VI1PR05MB5231.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4714;
x-forefront-prvs: 013568035E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(346002)(366004)(136003)(376002)(39860400002)(189003)(199004)(76176011)(476003)(66946007)(36756003)(256004)(54906003)(1076003)(186003)(2616005)(66066001)(33656002)(486006)(99286004)(86362001)(305945005)(6246003)(66446008)(64756008)(14454004)(6436002)(6486002)(66476007)(6916009)(8936002)(71190400001)(966005)(5660300002)(11346002)(316002)(478600001)(81166006)(6512007)(6306002)(8676002)(2906002)(66556008)(386003)(6506007)(229853002)(446003)(7736002)(102836004)(52116002)(71200400001)(53936002)(3846002)(4744005)(26005)(25786009)(6116002)(53546011)(4326008)(81156014);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5231;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ej07UNTvYo6qJo7IwweEpHdeZhz1cLgR1KPl+AhKCm/kKflLvbJ2he30XTS2vUJhtvQ4XRyCFjCOgyPxqkugWtJ90vZD96AEfN58YHydx5xDnzGMkSl/OviY5LZvhCXR/hfC0dJkjn9Q5j/gRIJ9aGSW1XTIKcSeVB3xhJLLOG3AKILcxFcXTH9WSFm2dZfiWDvc5Oc9NfwOoTmtZ4IqaQEoGzP6n66TLtQEh1nH8E5CEL3OGL0fpYfAi0BGFvsjnWd6yu8giv72iv6+4CA+U9t/OjMoMiwNeNhdWXpMO08owL1T/NarOLPKKB+nw5QZZjJfRc2XM7kiKyMxtPuq/T1x+97baqWE4Y3yph1PMsmKnsBn3Mm6cjCW9qSjqAOJB8wV4oIg6AAZ7jwk+jjIz9s89uGn7bD0GilCZrQ68BM=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2A4A25E80EC9994BB15BAC6FDC6901E0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e7be4bf2-af4f-4394-0f67-08d7257210c4
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Aug 2019 13:26:53.5547
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: MIU6EkXPDMI64Rd3TV6BYTRCmqHoYoHKqhpZQskQmMueokI/8O7ysL7iER5BsCwV6Q//XcnDyB1u4CsTWI9krQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5231
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 06:44:02PM -0700, Dan Williams wrote:
> On Sun, Aug 18, 2019 at 2:12 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > The dev field in struct dev_pagemap is only used to print dev_name in
> > two places, which are at best nice to have.  Just remove the field
> > and thus the name in those two messages.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
>=20
> Needs the below as well.
>=20
> /me goes to check if he ever merged the fix to make the unit test
> stuff get built by default with COMPILE_TEST [1]. Argh! Nope, didn't
> submit it for 5.3-rc1, sorry for the thrash.
>=20
> You can otherwise add:
>=20
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>=20
> [1]: https://lore.kernel.org/lkml/156097224232.1086847.946386192468337274=
1.stgit@dwillia2-desk3.amr.corp.intel.com/

Can you get this merged? Do you want it to go with this series?

Jason

