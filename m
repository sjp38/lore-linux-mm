Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B08C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BE992086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="r+Yk4hh/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BE992086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09E356B0003; Fri, 16 Aug 2019 08:40:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 050656B0005; Fri, 16 Aug 2019 08:40:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7F796B000A; Fri, 16 Aug 2019 08:40:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id C75D66B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:40:33 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 75E74181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:40:33 +0000 (UTC)
X-FDA: 75828249546.28.truck29_21ddc4c5eee53
X-HE-Tag: truck29_21ddc4c5eee53
X-Filterd-Recvd-Size: 6943
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60053.outbound.protection.outlook.com [40.107.6.53])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:40:32 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=YESYB6AXN4CeudgldfnpVuQqQSa8FubEo/bpOzfOB44FymI85b2jUJMczO9KTC8unPLpavdyWq66hN2gZ+JLb73oWigVD3MmSQC5xDXZlVkgumcZHwV2RtNsozfo9KpTcGUgOCkImAxiB21NGjBolPdFCOeyL33hd6e8Y7ZBYcItKw6vih22LhS119PhX7xu2yCVjYpABjRWEd5UU8kCnK2I8vgjh/eXIxxDo4PiehoQ58DghzRet1Z44EZXJLUx8a8fjixL6Y44nQRUmBm2+mRMeBb5JO92gWdvj2M8HOLtQ0g1bsrFGMHayEu8Fs+WyLFxeOTk76Sg83tpp1flqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6MQHQ34g+2H1b0ZoReFLzIEtb4+bD/IlYOfpioqTric=;
 b=FEH3SRojDEP1GOBJwnRq/L04DyWCScX4qVmlph4jXK3Jfg0VVHkyjsx76u3TFOt2mjBWyj+Kl9DNkdf6VJQbRcR4z7cW046RyQJlSglc3WsTgP+FxJEKU6ADTQRMrtj4oIQII/x+1kKFMvZpQTSxEytoa3+e6JTuzBYWhBNFgf+RXmqFocImFRwKSU7ebYfgTgJ74tRK/ZdAwn/bi0m2nxWb9IomViIgjRTFMni7uyDxbsJmRdy6mfvqp9cMttDn8cGubXtHTDe8VsQh2+XHC0Ic9w7SdDxEdF7kpvcGWoR4+87Iqn0qxgaaXfp1gz4LlNS9TR9TNXr55KlRv98zyA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6MQHQ34g+2H1b0ZoReFLzIEtb4+bD/IlYOfpioqTric=;
 b=r+Yk4hh/zE9TGLK+2z/i2eX1rsGQoj9Rx0XoHLOEXModJH6Ql8BKsVwJwlzhIffbj5PBhfqBfNM/3L5PiytTmIyX17arbBiFc2c0DYZo+Fr6sLmfeC9rnIsTcdJ8MQw/omxNhkvwkJ78BzF1K0N39di8H159XDe5VDcjnt5CCw0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4272.eurprd05.prod.outlook.com (52.133.12.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Fri, 16 Aug 2019 12:40:30 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 12:40:30 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>
Subject: Re: add a not device managed memremap_pages v2
Thread-Topic: add a not device managed memremap_pages v2
Thread-Index: AQHVU/97vsv9UEZaeUmMAUjVp5ftIKb9tb4AgAAAnICAAAEzAA==
Date: Fri, 16 Aug 2019 12:40:30 +0000
Message-ID: <20190816124024.GF5412@mellanox.com>
References: <20190816065434.2129-1-hch@lst.de>
 <20190816123356.GE5412@mellanox.com> <20190816123607.GA22681@lst.de>
In-Reply-To: <20190816123607.GA22681@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0016.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ff118e16-0ef1-4aa3-a43f-08d72246ec1a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4272;
x-ms-traffictypediagnostic: VI1PR05MB4272:
x-microsoft-antispam-prvs:
 <VI1PR05MB42722C7BFF7B7A49010D6F9CCFAF0@VI1PR05MB4272.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(376002)(39850400004)(396003)(346002)(136003)(189003)(199004)(5660300002)(11346002)(8936002)(81166006)(81156014)(4744005)(8676002)(26005)(86362001)(66066001)(229853002)(1076003)(14454004)(186003)(54906003)(6916009)(478600001)(386003)(33656002)(102836004)(6506007)(52116002)(76176011)(446003)(486006)(476003)(2616005)(316002)(99286004)(4326008)(3846002)(6436002)(256004)(6512007)(25786009)(14444005)(66446008)(71200400001)(66476007)(6246003)(64756008)(53936002)(6486002)(66556008)(7736002)(71190400001)(36756003)(305945005)(6116002)(2906002)(66946007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4272;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 I2etAiXoz1Q0bO4szsQ9ZyGopxORIB8Zai6kmODFx+LptCh1xZJlz001Xfys434s18LcskeJkxfrsn2jmBZe8VEihJovMKOaEcQ31d701uFNki0guN0tgahkEfkjhxvJQL3715IuZrObazTpTPz/p3bHafRfDWxfysmDKG3vKL8bM0GeJT1qJb1sbtVkI2VPwSEj+EhG8YdSXDF2rUct1ly+vplAsOJ8KaZtCuFF/A/+zkQpL1bzA0QOeWaRfw+dmUfDabSylxZIC7jM1GG73oUxxYP4IpzeIRCh9CxproQDLpKX0O0SX27FCIzR3mwSrgYv7aSRkDkyC4eDodeoKP7Ed++efWO/BpkufuwfPXKuCOcqXhvtrLULuJXcaBa9tm91hGQy36KFBvpkplMN7Yeiy+1yZ3YpGbwrF7OTr5M=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <49CFD18A4DCBF442B6C7AF0837F23DC5@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ff118e16-0ef1-4aa3-a43f-08d72246ec1a
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 12:40:30.2337
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: O3V86azQkC5uno8w8R0FgXibF7U7UEHD3Bw9sdhW2d79/vC9P5P6mGbjUslksa1nFTxgfrBtpGXlTJVGXi+iHA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4272
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:36:07PM +0200, Christoph Hellwig wrote:
> > > Changes since v1:
> > >  - don't overload devm_request_free_mem_region
> > >  - export the memremap_pages and munmap_pages as kvmppc can be a modu=
le
> >=20
> > What tree do we want this to go through? Dan are you running a pgmap
> > tree still? Do we know of any conflicts?
>=20
> The last changes in this area went through the hmm tree.  There are
> now known conflicts, and the kvmppc drivers that needs this already
> has a dependency on the hmm tree for the migrate_vma_* changes.

OK by me, Dan can you ack or review? Thanks

Jason

