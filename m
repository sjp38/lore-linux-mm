Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D8CC3A5A4
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6BBE2173E
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:34:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="hYktlTuz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6BBE2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 523ED6B0005; Mon, 26 Aug 2019 21:34:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5686B0006; Mon, 26 Aug 2019 21:34:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C44C6B0007; Mon, 26 Aug 2019 21:34:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 189596B0005
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 21:34:20 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A747D180AD803
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:34:19 +0000 (UTC)
X-FDA: 75866487438.24.heart97_5fdc6302e142e
X-HE-Tag: heart97_5fdc6302e142e
X-Filterd-Recvd-Size: 7839
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60088.outbound.protection.outlook.com [40.107.6.88])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:34:18 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=F5e8w6HcqOK10JLhh+mpdutPqDmZtDnBLKO0GTDXESY5+fR6CtTWtYe/6jxYVg9Q3XBwzMj1rLyFWGeBCHdc/+cLz7iBTpChXl2Dk+RZaVHcg1fUwdHScQk1f3Yv01QsFXSyoBWx//KbC5HEjeVGLrGBfAaZAsH+PNQ9Pe9LEKPnsCsqhiFt9ri2Wk91jszHIjZH+DtBkJOkk/HFtt0NQHGN/gUZTVZEexWn6HKbXzMFCn20r2ZfQ0rykccLV6SOZ0RQ8WqIKnTHt7Fc3XPZ+AkGfWHrVOwxXwQBVgVP+DnTsFMhQfrscb2U6NmmELGf8gwHkrprvuYlTc7/YtKNhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NUfPIctBKtmIVvmVnNNxaYJvbIxrVq/xSLdrbs42Khk=;
 b=fQ2C3QIHvggay0R6mauXpa+wuGC3QumHzIAIfHNWfwjqbvjN4IveLENrP5qY7JST9IK1CEFhgtGHyl/cmMk9CVnn3lMknB21aOaPhbFw7bMvoHSbd0ATkUjVzyuN3Zx0+Sb33ECrx5v8GaVTq73fB6Q4oPLFrMHxuCqz+iuOjtR8FIfwAdn2r7IFbsUnyOEDwF08XCdAPpJVSTNXcBbgCzPXWOnXu8XrOKbAQuHk00IZ5pKgKPqxOPqBkN5e1Ojb2wcc472NG7k0UKqfiwgaRRiU7yHR1uVFdudcj3WsMnOCR8FeG3mGwGKjtt2Oeg6VdKHnmHetgAw9N2XK6MmQKg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NUfPIctBKtmIVvmVnNNxaYJvbIxrVq/xSLdrbs42Khk=;
 b=hYktlTuzovzl90TRmzTeGvZXI3Fo4RCUPf8i/KRtxWdUOu+jSyuFwEvBaU9mAlyTWemQojhc/fX7fMZfjdrum+jysFHEP43lYuPwpHxnCRDQ8g7CHt0US0u3V60r2gcX7Oaj8IStTJXQmz7sxDKfJlToY6sD2yKVfd4DMhHQlpI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6077.eurprd05.prod.outlook.com (20.178.204.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.19; Tue, 27 Aug 2019 01:34:14 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.020; Tue, 27 Aug 2019
 01:34:14 +0000
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
Thread-Index: AQHVTf/tP3JKoCdlsUaV5lyTDbBfbKbxh5KAgAvT44CAC3nwAIACJKyAgANY+QA=
Date: Tue, 27 Aug 2019 01:34:13 +0000
Message-ID: <20190827013408.GC31766@mellanox.com>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190823134308.GH12847@mellanox.com>
 <20190824222654.GA28766@infradead.org>
In-Reply-To: <20190824222654.GA28766@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0054.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::31) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5ee5581b-6d88-4f21-69f5-08d72a8eaaf1
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6077;
x-ms-traffictypediagnostic: VI1PR05MB6077:
x-microsoft-antispam-prvs:
 <VI1PR05MB6077FB97F6EA0A4A189D3BF3CFA00@VI1PR05MB6077.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 0142F22657
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(366004)(136003)(376002)(346002)(396003)(189003)(199004)(53936002)(33656002)(478600001)(14454004)(229853002)(36756003)(6512007)(6916009)(25786009)(54906003)(6246003)(4326008)(66946007)(386003)(6506007)(486006)(66556008)(64756008)(476003)(66476007)(52116002)(102836004)(66446008)(76176011)(6116002)(305945005)(99286004)(3846002)(66066001)(1076003)(446003)(81166006)(81156014)(2616005)(11346002)(8936002)(8676002)(26005)(71190400001)(71200400001)(86362001)(6436002)(6486002)(2906002)(7736002)(186003)(256004)(316002)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6077;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 TAW7CNQ2wVGFQYFNPTm7DckLNLNLzLjP76qxRWInlMQ72iLmBgwILCRjsWRWflWj73jkOhO8g200zojr7FEZ7VJdF9wstv/0udSt8ZSE1y9iUD5YguT0LAaYcXOLOPaFJgLpuAC1w4QudjHzhiX1z4NrtlvDtycvN5XhcK/21PAbrDvwUAztvcUdB0oVnP6ajkSbPwN0o0L1hGJU5MWhtXgCaomvU90rtspb2htX6lDHn8Wl63J1uOYPaMGPuADBXbi9qyYCIqlObtghRrA6qxa2mOvPcP4WB0Rf7IW/gVCRTL2jzCOwF52UtvM9hweWNLplEEMrXFMuAQcmSK2DceZNGvY/9U180joqoWiQQ0kxdG9YtY4Socd1dN3XLSPwbZa1rUKk/O9bgUXtA/Umy2k9BjAOQG9DyOt8EhJus8s=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9519383735B8064C9756BBB78E48AB50@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5ee5581b-6d88-4f21-69f5-08d72a8eaaf1
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Aug 2019 01:34:14.0953
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Xu6tZYNn547ufO06IiCF/dAboMVSBF6QeQN28a6lEa32YL5aNiVYMS4QvfFPDsIDX/I/CxeSlkWpi6ehjNmhmA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6077
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 24, 2019 at 03:26:55PM -0700, Christoph Hellwig wrote:
> On Fri, Aug 23, 2019 at 01:43:12PM +0000, Jason Gunthorpe wrote:
> > > So what is the plan forward?  Probably a little late for 5.3,
> > > so queue it up in -mm for 5.4 and deal with the conflicts in at least
> > > hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?
> >=20
> > Did we make a decision on this? Due to travel & LPC I'd like to
> > finalize the hmm tree next week.
>=20
> I don't think we've made any decision.  I'd still love to see this
> in hmm.git.  It has a minor conflict, but I can resend a rebased
> version.

I'm looking at this.. The hmm conflict is easy enough to fix.

But the compile conflict with these two patches in -mm requires some
action from Andrew:

commit 027b9b8fd9ee3be6b7440462102ec03a2d593213
Author: Minchan Kim <minchan@kernel.org>
Date:   Sun Aug 25 11:49:27 2019 +1000

    mm: introduce MADV_PAGEOUT

commit f227453a14cadd4727dd159782531d617f257001
Author: Minchan Kim <minchan@kernel.org>
Date:   Sun Aug 25 11:49:27 2019 +1000

    mm: introduce MADV_COLD
   =20
    Patch series "Introduce MADV_COLD and MADV_PAGEOUT", v7.

I'm inclined to suggest you send this series in the 2nd half of the
merge window after this MADV stuff lands for least disruption?=20

Thanks,
Jason

