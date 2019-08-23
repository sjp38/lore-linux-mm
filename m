Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E364FC3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6E492070B
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:43:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="mHWgOzSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6E492070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49F696B0496; Fri, 23 Aug 2019 09:43:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4017A6B0497; Fri, 23 Aug 2019 09:43:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27BCC6B0498; Fri, 23 Aug 2019 09:43:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 05ECD6B0496
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 09:43:15 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 96C99181AC9AE
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:43:15 +0000 (UTC)
X-FDA: 75853809150.27.cars93_73a7bfe4d3d0c
X-HE-Tag: cars93_73a7bfe4d3d0c
X-Filterd-Recvd-Size: 8314
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20085.outbound.protection.outlook.com [40.107.2.85])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:43:14 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Wzf/ZV5hMroq0I7dYFZFMJ0aYLPLtiUaT87dU05KZed/YmZKOMb/mo7V45MU8CCmd4RoP+njFzGACLI6k93dC3AAMGpE6HJ7i9rzZbfFBHMkNmxpH0MFdR/GXxxQRvhV5yaII623DMQXYK5zMMstBfD/Vz5f4g/59FnIGAacE1GtvHICpoPs1V0qcSwATQ7i9f2mB1zNKrM8KfiuCxnkWutMXCm5krf46odSvQXQgnggjpAK0lzh1bacCgm9wh0kTfNXkWryfVAbSkWAAteLKG5a7pdLzNpRtFS+D3eSqPZmZue+cO0VadnWQ2ctp8ZpVSJZfZjtqoiSq+TcwkTgJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KrDQutUh3bXeGuSyt0dEXpSA3sXfaxfgdaq4qvoTUBo=;
 b=OMUqQ2AGfhnEG4REpEqg/heGRpNKYC1n84mWhlldbeS10pRdNjc9nzJkXbk2qayPbOss/RZY0M5+UgpHkGv0mqVq+s76mJ1I2uJ+q8163IOZx2Cm9uE2Iplxc2ELPaidxkcq1BL0Tx9b8PjlaI1nGkzmRPlbg/Wl8CNdm2Qh3qlXsGnrdpt/SkY5+Moi+pzvZ5hktseC/SwwLyfkHyWytEq4RXb6b9fX87EodfYcQcRlG4klJOfiwV4fxZS+50ztbkuMjJcHeHtggsTyW2NGmUGIWoMsybiEumsOjzH7bsxuPfsXTvJi8ue5ofK2x+umcQkz5XQ7QGwO9kEZ7UGC+Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KrDQutUh3bXeGuSyt0dEXpSA3sXfaxfgdaq4qvoTUBo=;
 b=mHWgOzSBbOxrUUXlvhRUjzgi25etKUkxOnJ/Ghym/ZIL35IveiffOCwOChYCEbqnDWsT+lJJaI4owyJWoYU94Bv6srWsm+L2Yiq4wVB53qrTxK/+cEZIcJdXQy/fehMTDEnByT2X19hBFLOl25vM72NbJj1niuIGPx/TDXbMtE0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6575.eurprd05.prod.outlook.com (20.179.25.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Fri, 23 Aug 2019 13:43:12 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.020; Fri, 23 Aug 2019
 13:43:12 +0000
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
Thread-Index: AQHVTf/tP3JKoCdlsUaV5lyTDbBfbKbxh5KAgAvT44CAC3nwAA==
Date: Fri, 23 Aug 2019 13:43:12 +0000
Message-ID: <20190823134308.GH12847@mellanox.com>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org>
In-Reply-To: <20190816062751.GA16169@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0057.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b277c664-5bf6-4b03-891d-08d727cfd7a3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB6575;
x-ms-traffictypediagnostic: VI1PR05MB6575:
x-microsoft-antispam-prvs:
 <VI1PR05MB657559A079DDD5F7B9D1CD35CFA40@VI1PR05MB6575.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0138CD935C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(136003)(346002)(366004)(376002)(39860400002)(189003)(199004)(478600001)(316002)(8676002)(66946007)(14454004)(64756008)(5660300002)(66476007)(8936002)(186003)(14444005)(81166006)(256004)(6512007)(66556008)(3846002)(386003)(81156014)(2906002)(99286004)(305945005)(53546011)(7736002)(4326008)(26005)(52116002)(33656002)(36756003)(446003)(6246003)(71190400001)(71200400001)(486006)(54906003)(1076003)(76176011)(6116002)(66446008)(53936002)(6916009)(6506007)(25786009)(476003)(66066001)(86362001)(6486002)(102836004)(2616005)(6436002)(11346002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6575;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gmDc2zubSO7qacLuhHlyi5GnV2uvZ5Dt2FlaJFl73f+hKdV7XdVdIhkRAx6J/2tWwWLULgzB4Pa1fpS3BpmRjX9J9F3vFkN+0J6J+QvZRFRoOfQ1eKpJI5u5kJytKvNxn7KqqCQxuALg24sYHz7HFO9FX1ZjzjnrtOtHo8MuPsp7zlSOwHzWGI2XLgUr3b2PfyHJM2I5Z2Enxuwib3tY/hI/z78TG7/XhXnD2uJ5WsaiBar/nJznPJUMYNYXBn66upCD7M1ToUVVrljeXwQinjxm/r/PU8ohGwH6eDKLT9k3AygdFON8HNusruam1njlFxUJ9RChC/Lotn+iNQRK0XSuz8LgKaDh1af+8yuz2DOhHAyKv+q4tpUMw8HU866XO4yAKx14T4m1vqxXi80HqX9jZZvkNBrY1ge1Z/Y2rkU=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <420EA7641430E643BBBEE42A0E9E92A0@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b277c664-5bf6-4b03-891d-08d727cfd7a3
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Aug 2019 13:43:12.7445
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: YgDSOjQpp122FDc/w2yEvVnDbFVROvCXY64dD68CiVPIQwkjCxlaLWWe5au30lnOp+ZJHvW2UpPzaC2rWhQ5UA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6575
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

Did we make a decision on this? Due to travel & LPC I'd like to
finalize the hmm tree next week.

Thanks,
Jason

