Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CF8CC3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 12:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B210221019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 12:50:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="E5h62KTp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B210221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119FD6B0008; Sat, 17 Aug 2019 08:50:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CA306B000A; Sat, 17 Aug 2019 08:50:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED41C6B000C; Sat, 17 Aug 2019 08:50:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id C8FE96B0008
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 08:50:11 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 694508248AD2
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 12:50:11 +0000 (UTC)
X-FDA: 75831902622.23.wave49_1e9f507d86f59
X-HE-Tag: wave49_1e9f507d86f59
X-Filterd-Recvd-Size: 7160
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10041.outbound.protection.outlook.com [40.107.1.41])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 12:50:10 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dFNbMY32Ycu62r1bCxURHDABZxgMZvTWrapmSZEX2ulfx2zSvFHUSDI4NqZqt+rkYMHj8hi5zvyHVLcBGFZINrI6YE9ynBkW/69cJQuCHfmalz0jQb4rVDbKZgjBtJVUhfrCSt9uDTuytkRWzypw0tRMSRbF/DN4lXFA6hTaMMwyNf8bJQcXQGriBtVeMk3kDVH/0hwz4ggHNADEz/FEYB7o6dgdqaR3liNpc3RK2RPF2iqPqAjtUBYTbwwyXxxWXGY1Q+l3LJcFfOc7rDYZFAelbWJvvVltm/3Sip/noE5x+jiQ1MHJ48nwJgrR+Q0yEfULNN2am2QjcznGL3riOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xBnKmRLyCwxqWMxqtYtaxBjRMqaAzEVPpluFObk7JBI=;
 b=cPRdZSFtreNvKSFuRlf8wY/TTv3k50Hc93iLoqOCeg5OeBK5ubcqrLjeASDjLXUQ2e1HVArQwfa6aNCAHpKaLM0BVECH5qdcPfnVSIO88Beou1Tt71249yNmIu2EMY7W/flPXzlpsHlXfLpEKfiTS3AQbs5b+oA87IAQ0uc37cWF/+iwNuDkCqepAqHTA8j/k2UB6uPKJIm7hlzPtWr06xF9ybht9nfFaF3/NkPMnOZdN8xp55FyRBhV5cCDvgcUeopQ9dlxdgLZkib1+8eWW7Rnvzb27lZnXybmrpuaa6uSR5N8FOhtAk0jMwDf83P45RpcMCUbtjUYQxC/AZI4Gw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xBnKmRLyCwxqWMxqtYtaxBjRMqaAzEVPpluFObk7JBI=;
 b=E5h62KTphx3fmnZnqZZPNrG2W+s15qxVT8fHXjtukqhwrJif3z07tmSm1iwfrTDQUCS4fEogir7raCmv9s/R7YV1jBYkNYeh0dHxP2ttuN+Wdd+lP4eU3K2b2d3t1wv5hWtNV6d2AOEU7Fp8sPn+pgjUvvz0TswCpZ0AfPSWkPg=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5311.eurprd05.prod.outlook.com (20.178.8.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Sat, 17 Aug 2019 12:50:06 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Sat, 17 Aug 2019
 12:50:06 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 01/10] mm: turn migrate_vma upside down
Thread-Topic: [PATCH 01/10] mm: turn migrate_vma upside down
Thread-Index: AQHVUnY4TvdvZdqG70SoVm3XhXkEbab+BjuAgAEzdgCAABX0AA==
Date: Sat, 17 Aug 2019 12:50:06 +0000
Message-ID: <20190817125002.GB10068@mellanox.com>
References: <20190814075928.23766-1-hch@lst.de>
 <20190814075928.23766-2-hch@lst.de> <20190816171101.GK5412@mellanox.com>
 <20190817113128.GA23295@lst.de>
In-Reply-To: <20190817113128.GA23295@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0069.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::46) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a6dd676e-d353-45d8-2e8e-08d723116df6
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5311;
x-ms-traffictypediagnostic: VI1PR05MB5311:
x-microsoft-antispam-prvs:
 <VI1PR05MB5311621D322316A86401EC2ECFAE0@VI1PR05MB5311.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0132C558ED
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(136003)(366004)(396003)(39860400002)(189003)(199004)(6246003)(76176011)(386003)(478600001)(25786009)(446003)(186003)(86362001)(99286004)(102836004)(6506007)(316002)(6512007)(1076003)(66066001)(14454004)(26005)(52116002)(486006)(4744005)(5660300002)(11346002)(476003)(2616005)(7416002)(256004)(305945005)(71200400001)(71190400001)(33656002)(7736002)(6116002)(81166006)(8936002)(36756003)(81156014)(6486002)(8676002)(229853002)(53936002)(66476007)(66556008)(4326008)(64756008)(2906002)(3846002)(66446008)(6916009)(66946007)(6436002)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5311;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Vlg8j145DMCic0yKX8M55cA/znV95y7LwbgWTEb5V0oTNzuOES/RUEw7fJF0WGnLUVEIqwDfvihM07pkp5D8C8wv+fDuMbOIAY5Tr/WC4oLLgCPTRMhM6FwBFpEQKcXiFmFNvvLW0lujg0LxH0NahHY7lCRucgP/xZbi5asYTku5DxdDcC7xhRDbIm5E70dLwMHslGv2uFCatqbtiOfixIelAfH2M8TjHbqZecb6oFFuvwxXUJKsrpsHOserO/k3uXQ+2g9n48qS4EVHfiPA1k96zIv2RFAMyNUTpAphFVSQCuLoSR5M0JZpmJINt84y2MORaMNhJwUHtk288UHDafyP7KXTazzqSMKsk+on6hfTIcH2398HOD23XV89QnKtKFbrHmWnhtge7ijlxSP26PUFTkOLssKRTbmG9BG3GWg=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <1695A1151C0F3641B6BBDBD97CAD2365@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a6dd676e-d353-45d8-2e8e-08d723116df6
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Aug 2019 12:50:06.3920
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: EKbtjcdg48Acrsg7vuLj3RsaBb93XGMzGcoKoIlnd/brgbVOLdhA7UfwMUk7gN0gLJX7vy6ZDXTc7Kal2bGWHg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5311
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 01:31:28PM +0200, Christoph Hellwig wrote:
> On Fri, Aug 16, 2019 at 05:11:07PM +0000, Jason Gunthorpe wrote:
> > -	if (args->cpages)
> > -		migrate_vma_prepare(args);
> > -	if (args->cpages)
> > -		migrate_vma_unmap(args);
> > +	if (!args->cpages)
> > +		return 0;
> > +
> > +	migrate_vma_prepare(args);
> > +	migrate_vma_unmap(args);
>=20
> I don't think this is ok.  Both migrate_vma_prepare and migrate_vma_unmap
> can reduce args->cpages, including possibly to 0.

Oh, yes, that was far too hasty on my part, I had assumed collect set
the cpages. Thank you for checking

Jason

