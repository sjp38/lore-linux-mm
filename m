Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18707C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 11:57:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFE992086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 11:57:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="OT5TKuvU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFE992086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B20E6B0003; Fri, 16 Aug 2019 07:57:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 662A56B0005; Fri, 16 Aug 2019 07:57:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550E36B0006; Fri, 16 Aug 2019 07:57:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id 3380F6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:57:45 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CB221AF68
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:57:44 +0000 (UTC)
X-FDA: 75828141648.20.hat88_609c06f68ca1b
X-HE-Tag: hat88_609c06f68ca1b
X-Filterd-Recvd-Size: 8369
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40080.outbound.protection.outlook.com [40.107.4.80])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:57:43 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=htqbcar2YMQf/h00xNlWhyTwILds+Z/P32vyI8uv76WA4NLCtDqAaASsvJgSvPvfRWrmW68HF3cVrWma3Kcg8equ9Jn58FOQ5qdOyaNTAWAdDILiGsSSbXWrlajE3kqkY/3X9haj9Jdx09d45oJz2nSs4jvh9pOfI+lsXdDDDaN1fN1d7yVkiUq0NbTfF1twJ3G2R7VflbMlQLo/Shtp1FywjmMJ6MDOvAi2WXbruSfaeZ32MS2T91ZLAn411OuKfOvALFU1fqIBKqhSmBcMqwPqYCzglu2YHMYxEficKuXu0uMbCz7VO4xQa68QPYK9j/k+0cQ7ieSgwjKsoZTy8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lZhLO4ofK9hiYxDDbjru964S2Ow8QRvo6QEzrOLAGQc=;
 b=B1kRzw4ccG4YewD15OWLKJ4gbS01WdB3Y+szb42l7TKPrUgJ3oh9KLa+SZ4dLOdtCN9TGL2CB8pRllcePWRO3IFrvermh1DWyiJmOErJhLUIIdg53a0pouyK08WZxLhn7584zn7WNy2GPofIfBQFcjWW7KSckKX1U5MdLHb/fSkB2FfwL6ku4+et9v0ygvMbr1mptCl1OuJTr0HFoDHc+KyDmpB8JXmKP0lb2v+qSQkK189T/FvNQYdu22+dsDgZCMSPTTnr6oGhEkQtBVteMRWaO0693W4sd1YKQ/ZmIZbqNgHfnIbH7ZKkTizj+K9bWXh88m9ScKNNnuMKt6tshQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lZhLO4ofK9hiYxDDbjru964S2Ow8QRvo6QEzrOLAGQc=;
 b=OT5TKuvUIzQk06ilXAQ6UhI4P9uvLKclXvc1uham7X0zFPcjSXZAZeWiuzRvxAq+5BapoOSH2McjSIHqV+BtzpIp+hOh8hqpLjWFL4wSvMo+rRbg4aGYZ94bbsZ9U4Ojs+765DWIhBAxTNt1pB7Ys7kkqUVMS8CWJIu83t+Z0xs=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5440.eurprd05.prod.outlook.com (20.177.200.82) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Fri, 16 Aug 2019 11:57:40 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 11:57:40 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig
	<hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@shipmail.org>, Jerome Glisse
	<jglisse@redhat.com>, Steven Price <steven.price@arm.com>, Linux-MM
	<linux-mm@kvack.org>, Linux List Kernel Mailing
	<linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Thread-Topic: cleanup the walk_page_range interface
Thread-Index: AQHVTf/tP3JKoCdlsUaV5lyTDbBfbKbxh5KAgAvT44CAAFwggA==
Date: Fri, 16 Aug 2019 11:57:40 +0000
Message-ID: <20190816115735.GB5412@mellanox.com>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org>
In-Reply-To: <20190816062751.GA16169@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0029.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::42) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3896fe9f-3c68-4c9a-b6f1-08d72240f086
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5440;
x-ms-traffictypediagnostic: VI1PR05MB5440:
x-microsoft-antispam-prvs:
 <VI1PR05MB544042057500F5E0658EEF74CFAF0@VI1PR05MB5440.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(376002)(396003)(366004)(39860400002)(136003)(199004)(189003)(53936002)(478600001)(33656002)(476003)(99286004)(6512007)(36756003)(305945005)(7736002)(81156014)(6116002)(3846002)(2906002)(81166006)(6916009)(6436002)(8936002)(66066001)(8676002)(186003)(316002)(52116002)(25786009)(76176011)(4326008)(71190400001)(66476007)(71200400001)(53546011)(386003)(6506007)(26005)(14444005)(256004)(6486002)(6246003)(102836004)(5660300002)(66446008)(486006)(66556008)(54906003)(446003)(66946007)(1076003)(64756008)(14454004)(11346002)(2616005)(229853002)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5440;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 bHA6tfVGDLM11jekVfVAB46zo9mqR0YCd8nDsdLbakffEcjXAJaSW9o4wh7xaIiGdv6KfXVgrVP9p9Bj5EE8vhfnBbXcqbammySrOtAC6/Z/htFIyOALtK48mn+7eCFYw773WJvkW3+CV8/0DZQECdtHbTe0K2jaQSuj8gIFRyBaa616Yc/8dxXr1ZumA4fTXeug2n08pdAfcYhuNz8X39o3i3mJQX2v+p6at5NRJ7ALjNa4cJqwYZ/6FGInBB3EIeUBIb2bWj2eOkHqv1zkGNb2iaRlaDJ8U/CE4tAt8KBMiX0C1MLDn+vBnJY5ZKO0wsBnb+Fa6ix772kZ1RaZ/NYxhwfnzlu9XfVZmme5w+mIh8vqwrY9G0GOafT4vg8QBXUHrgmfje3eqefrMmwwwJU/DEQwHWzjaCLGS3TlfQk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <35B5AB222822AA4E835D14641243E8AA@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3896fe9f-3c68-4c9a-b6f1-08d72240f086
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 11:57:40.6455
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: IhNEEv+l45bHrFateBmWwMEbSFHU5nYJCKIIkS9fHQkQtDR4E6CtFgqJAqGwslt7l6LHE2jvdnhv1pXBnTNtxQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5440
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 11:27:51PM -0700, Christoph Hellwig wrote:
> On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
> > On Thu, Aug 8, 2019 at 8:42 AM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > this series is based on a patch from Linus to split the callbacks
> > > passed to walk_page_range and walk_page_vma into a separate structure
> > > that can be marked const, with various cleanups from me on top.
> >=20
> > The whole series looks good to me. Ack.
> >=20
> > > Note that both Thomas and Steven have series touching this area pendi=
ng,
> > > and there are a couple consumer in flux too - the hmm tree already
> > > conflicts with this series, and I have potential dma changes on top o=
f
> > > the consumers in Thomas and Steven's series, so we'll probably need a
> > > git tree similar to the hmm one to synchronize these updates.
> >=20
> > I'd be willing to just merge this now, if that helps. The conversion
> > is mechanical, and my only slight worry would be that at least for my
> > original patch I didn't build-test the (few) non-x86
> > architecture-specific cases. But I did end up looking at them fairly
> > closely  (basically using some grep/sed scripts to see that the
> > conversions I did matched the same patterns). And your changes look
> > like obvious improvements too where any mistake would have been caught
> > by the compiler.
> >=20
> > So I'm not all that worried from a functionality standpoint, and if
> > this will help the next merge window, I'll happily pull now.
>=20
> So what is the plan forward?  Probably a little late for 5.3,
> so queue it up in -mm for 5.4 and deal with the conflicts in at least
> hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?

Are there conflicts with trees other than hmm?

We can put it on a topic branch and merge to hmm to resolve. If hmm
has problems then send the topic on its own?

Jason

