Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D28C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:36:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFE3B2186A
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:36:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="l/QY1f/o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFE3B2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38F576B0006; Tue, 27 Aug 2019 19:36:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 318A16B0008; Tue, 27 Aug 2019 19:36:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B8DD6B000A; Tue, 27 Aug 2019 19:36:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id EBCAE6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:36:30 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9CC73181AC9B4
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:36:30 +0000 (UTC)
X-FDA: 75869819340.20.waves29_9001c70693b0f
X-HE-Tag: waves29_9001c70693b0f
X-Filterd-Recvd-Size: 8535
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00066.outbound.protection.outlook.com [40.107.0.66])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:36:29 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=XjZVmJ2xUAHZcJZKpemA/batWwdsymQ97tSOkk/5E0o1kGlqVt6vHFCo5YCLOWW0sZtsoN6vyOw44t/F0fDSApOOMA3lSk6sEH865fxy/5k41Ybc6Fp3Pze6Y16K0VklL4Dvq0jLEi9dMJLTImz62xdNxk25UN4ri7ZHjC1XzPyVwG6VumyezNYQI7TUrMJ5FjZ0tNO2cxfI1U4seRMiPa+s1w43CX5m4h5vhiKm9iAiqY2GT8FaSN2/8rmN40Py/SCqCuMN2WYvoXFcqwJcS+Fhj5AeBcx0AlEE8qrZ71aEg/QfMg6k852amnO2qHmLR8LsB9GbtfsqPqEDd8U8Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XpEoZSJD+FDl+XxcImTPbTIweRRTP6ERpQW/dO7MmL0=;
 b=nT1mwbLpOkW1oyljGzCvKDUb5FcYpy9gn3Crd7HgJkJTAJbZvrNQSktKjFMgM3s64RvCcRpv1iMfprIUXcC7LYEb4gRge/TVHj8dlIkwSpIIeiomMATLO2uX1KOk64o5L3UeSruQan6EeexkLf0abYrz13WY8yjE7mGiUyZd9eavIUb2bY8uCAjgOMb+t5q2nswXdJt51nlWhf3UmhKbinDsHB7FahhP8uJ6tZeIqh0IhNJosw8dOp/Oag7DYReiT0EJZc0AsstlISid6dYSXubcE0pQhRZr65gCzpMgnW88p01Fw3j5B9QKfkmB+qZqjqWBxmhvnUXzdmANW33U4w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XpEoZSJD+FDl+XxcImTPbTIweRRTP6ERpQW/dO7MmL0=;
 b=l/QY1f/ogRmNlpx+LqXa4z1OMJ11rHIhg3BvrIQVRG6ijioe3IU3/cXnx7BtAPv9mpnNZUgebcGhJmBHjaqODN2Bx9wbtV8hAzwd6pXg3SLgfR3LVG5cPErDJk7K8rNiNt9yIrv3GR9AJW18GKEFbWZWcXWbnWtSQxwacRPLIR8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5104.eurprd05.prod.outlook.com (20.177.49.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.21; Tue, 27 Aug 2019 23:36:26 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.021; Tue, 27 Aug 2019
 23:36:26 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Linus Torvalds
	<torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@shipmail.org>, Jerome Glisse
	<jglisse@redhat.com>, Steven Price <steven.price@arm.com>, Linux-MM
	<linux-mm@kvack.org>, Linux List Kernel Mailing
	<linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Thread-Topic: cleanup the walk_page_range interface
Thread-Index:
 AQHVTf/tP3JKoCdlsUaV5lyTDbBfbKbxh5KAgAvT44CAC3nwAIACJKyAgANY+QCAAXDpgIAAAIGA
Date: Tue, 27 Aug 2019 23:36:26 +0000
Message-ID: <20190827233619.GB28814@mellanox.com>
References: <20190808154240.9384-1-hch@lst.de>
 <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190823134308.GH12847@mellanox.com>
 <20190824222654.GA28766@infradead.org> <20190827013408.GC31766@mellanox.com>
 <20190827163431.65a284b295004d1ed258fbd5@linux-foundation.org>
In-Reply-To: <20190827163431.65a284b295004d1ed258fbd5@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0015.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::28) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0c6f60c3-fcd6-4681-38e5-08d72b4760cd
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5104;
x-ms-traffictypediagnostic: VI1PR05MB5104:
x-microsoft-antispam-prvs:
 <VI1PR05MB5104D72C1E0F1E339C475D70CFA00@VI1PR05MB5104.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5797;
x-forefront-prvs: 0142F22657
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(39860400002)(376002)(396003)(346002)(366004)(189003)(199004)(8676002)(66946007)(6512007)(386003)(36756003)(99286004)(2906002)(66556008)(86362001)(76176011)(71190400001)(6486002)(256004)(6116002)(6916009)(229853002)(26005)(6436002)(8936002)(52116002)(53936002)(6246003)(33656002)(102836004)(1076003)(11346002)(186003)(4326008)(446003)(6506007)(7736002)(2616005)(476003)(71200400001)(5660300002)(25786009)(66066001)(478600001)(486006)(305945005)(3846002)(316002)(14454004)(66476007)(81166006)(81156014)(54906003)(66446008)(64756008);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5104;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Ql4i38YkoLvDEt0TTsvtiRpO0NrRqag0OxiYOgOR1of9p00Quq2dvfGchDS2TSzAERfsuGYJfa1XpIf+2mTXzLc2qJaGyjXGwzAm9aZt8v518qiUh+NTFx8bnhy/CyPmDRJYaGqWk9NGkkUvnsIeFtmyISkP46fm1uBvd685ZC6RoN2BQN8MwkXLNwPyQVIrC4z981h6AVkMuqw2KWnYHX618AvzHYEBiMNGthBCLcDiM06V+UsSwGw0k+/S97uIt7Dp+lfwMJnZ9aVEwDQEGKZaIGIDYeqCQ6T+bae8rWzlY/RL7EsFbZqWmSy8BC+m9xggA2aIYgaY0qeAu6nD3CgK7A5LpPCX9t7VJMdkaemvk/0PDHlq40Eu2NMuloZXngPU0pXsXq+WX2egUmMba3aMxyLYF3V26LXBUIbyf0M=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <4504015CE82312439FC3C48C90672925@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0c6f60c3-fcd6-4681-38e5-08d72b4760cd
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Aug 2019 23:36:26.4937
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: xcshjZt6kc0th1TIGm0wPVKwoK+MhzpUxFPgKi/AF8reFh42wM9YID2sP41tTh99TTWsd2qaUwpvVrw41w1lgw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 04:34:31PM -0700, Andrew Morton wrote:
> On Tue, 27 Aug 2019 01:34:13 +0000 Jason Gunthorpe <jgg@mellanox.com> wro=
te:
>=20
> > On Sat, Aug 24, 2019 at 03:26:55PM -0700, Christoph Hellwig wrote:
> > > On Fri, Aug 23, 2019 at 01:43:12PM +0000, Jason Gunthorpe wrote:
> > > > > So what is the plan forward?  Probably a little late for 5.3,
> > > > > so queue it up in -mm for 5.4 and deal with the conflicts in at l=
east
> > > > > hmm?  Queue it up in the hmm tree even if it doesn't 100% fit?
> > > >=20
> > > > Did we make a decision on this? Due to travel & LPC I'd like to
> > > > finalize the hmm tree next week.
> > >=20
> > > I don't think we've made any decision.  I'd still love to see this
> > > in hmm.git.  It has a minor conflict, but I can resend a rebased
> > > version.
> >=20
> > I'm looking at this.. The hmm conflict is easy enough to fix.
> >=20
> > But the compile conflict with these two patches in -mm requires some
> > action from Andrew:
> >=20
> > commit 027b9b8fd9ee3be6b7440462102ec03a2d593213
> > Author: Minchan Kim <minchan@kernel.org>
> > Date:   Sun Aug 25 11:49:27 2019 +1000
> >=20
> >     mm: introduce MADV_PAGEOUT
> >=20
> > commit f227453a14cadd4727dd159782531d617f257001
> > Author: Minchan Kim <minchan@kernel.org>
> > Date:   Sun Aug 25 11:49:27 2019 +1000
> >=20
> >     mm: introduce MADV_COLD
> >    =20
> >     Patch series "Introduce MADV_COLD and MADV_PAGEOUT", v7.
> >=20
> > I'm inclined to suggest you send this series in the 2nd half of the
> > merge window after this MADV stuff lands for least disruption?=20
>=20
> Just merge it, I'll figure it out.  Probably by staging Minchan's
> patches after linux-next.

Okay, I'll get it on a branch and merge it toward hmm.git tomorrow

Steven, do you need the branch as well for your patch series? Let me know

Thanks,
Jason

