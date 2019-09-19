Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64DAFC4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:55:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CDAE218AE
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:55:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="AK0++a8R";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="EZEiZwXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CDAE218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B1F96B0327; Wed, 18 Sep 2019 21:55:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78A426B0329; Wed, 18 Sep 2019 21:55:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 652A86B032A; Wed, 18 Sep 2019 21:55:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 31B426B0327
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:55:36 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DE7A1181AC9B4
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:55:35 +0000 (UTC)
X-FDA: 75950003430.23.screw16_13761dddd0c49
X-HE-Tag: screw16_13761dddd0c49
X-Filterd-Recvd-Size: 15791
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70077.outbound.protection.outlook.com [40.107.7.77])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:55:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KLl2dYUqqb+uWUSdCthuXUo4Y5KKkOAqXYoX7+1aDVQ=;
 b=AK0++a8RMSkJkBDpPjWv3Hhu2qkC6s9KQ8Wa1CZ92C08HMA+8t+LIJeqe+qTIHYNP+s/r3xa0EqW3Ow7D7CHdvNgr1N28oUJMVqA5faMKw+vgFQ0uyLjr+a3Yv6qVCYe14KzzYw9FT7ZAsa937ok5HwwdI7iRZAd9c6Ipo4ZO2c=
Received: from AM4PR08CA0050.eurprd08.prod.outlook.com (2603:10a6:205:2::21)
 by HE1PR0802MB2380.eurprd08.prod.outlook.com (2603:10a6:3:c6::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2284.20; Thu, 19 Sep
 2019 01:55:27 +0000
Received: from AM5EUR03FT014.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e08::202) by AM4PR08CA0050.outlook.office365.com
 (2603:10a6:205:2::21) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2284.18 via Frontend
 Transport; Thu, 19 Sep 2019 01:55:27 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=none action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 AM5EUR03FT014.mail.protection.outlook.com (10.152.16.130) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2284.20 via Frontend Transport; Thu, 19 Sep 2019 01:55:25 +0000
Received: ("Tessian outbound 0d576b67b9f5:v31"); Thu, 19 Sep 2019 01:55:19 +0000
X-CR-MTA-TID: 64aa7808
Received: from a5b2040cd570.3 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.1.58])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id C618FD25-8A4E-4880-9A49-26968ABAFBF9.1;
	Thu, 19 Sep 2019 01:55:14 +0000
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01lp2058.outbound.protection.outlook.com [104.47.1.58])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id a5b2040cd570.3
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384);
    Thu, 19 Sep 2019 01:55:14 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Oha41wjD9pJYayM8WePZPtL+c0OKwwmumCukYadOHJpJc/dJCemReatHNxzVWSoD7OtFpQV4h0W9wWkVR7Wiujz3za+SO+T89kuC3pSXIeDNScXx29ZucXgpcIMc9GrxP9fO3DjkRlzb+z6ZejWmLYds1pB1lkfS37O61fg8FzuOvIQduQylttwfXFc44RK32c51pixPxVKDv/RWkabfEz/Jy2mXG1uy9tqmuUjam0EadxBWoOSYeoPHxgUdWnfbPucNuRTte7HL0OSIAnJFLTSRZzBmcJddWx9sHFUMTCGiUBSqYlJsMnxqhyryOZ3btZhrPaMCnTJBf1HC+Zu/ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xVRNmnvXPvRsHb1RvbPlgt3JdDv8vsWkMWKyDH6t0Ps=;
 b=iwCi9vYL4/oZUjb/T3H0T8oYTSwx3M187denuL6nW9df6ROvkR4mhC55qnF8FK2O2051ZhQDo9K2MyELbZ/7Vwoo0d2sruNJfELQJqEwwJTUMfk42vnLpT1NQt04CPjJPb70ymZBSLUMtElpqUtZ0bl4B8h23auQBwOHEQb9MTdNX1b/RFLwMVtTsGBonRHxgTGD0iT1t88RHEk1TiHE/WD9BBQn3qse1nbXncW0wlXr1NJs5VV3PzddkvJ0wUPR1aYmEjrDAo/5abcuQRikkMibNgkhOHX7oW1S2ty9e0KVqN/oGix1A6SdRW/EKzKmCPcG+IGn/eEK/oNfGyEfJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xVRNmnvXPvRsHb1RvbPlgt3JdDv8vsWkMWKyDH6t0Ps=;
 b=EZEiZwXjh1I/5GIWeUKXXIVoBsYZpcazbRjPmt9uUYK47SlsD4laVu2NxiAhXp31xaFjRfmYA1jPAGLwQjjbrOEVfJXYyqii/CuEzZHkIITJ2PVR0FNoP0WtG7N3wTWGYTD7EvY4tSxAtra+Cjj0fBHWpOloY5cyTeQeF6p4WBI=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB2988.eurprd08.prod.outlook.com (52.134.107.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.21; Thu, 19 Sep 2019 01:55:10 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2263.023; Thu, 19 Sep 2019
 01:55:10 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>, Suzuki Poulose
	<Suzuki.Poulose@arm.com>
CC: Will Deacon <will@kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, James
 Morse <James.Morse@arm.com>, Marc Zyngier <maz@kernel.org>, Matthew Wilcox
	<willy@infradead.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Punit Agrawal <punitagrawal@gmail.com>, Anshuman Khandual
	<Anshuman.Khandual@arm.com>, Jun Yao <yaojun8558363@gmail.com>, Alex Van
 Brunt <avanbrunt@nvidia.com>, Robin Murphy <Robin.Murphy@arm.com>, Thomas
 Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "hejianet@gmail.com" <hejianet@gmail.com>, "Kaly Xin
 (Arm Technology China)" <Kaly.Xin@arm.com>
Subject: RE: [PATCH v4 1/3] arm64: cpufeature: introduce helper
 cpu_has_hw_af()
Thread-Topic: [PATCH v4 1/3] arm64: cpufeature: introduce helper
 cpu_has_hw_af()
Thread-Index: AQHVbiPCArKkzco6w0S1SPIowJk4TacxfDiAgAAoi4CAAJkFsA==
Date: Thu, 19 Sep 2019 01:55:10 +0000
Message-ID:
 <DB7PR08MB30827C81CD6CDB03B17A1BDEF7890@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190918131914.38081-1-justin.he@arm.com>
 <20190918131914.38081-2-justin.he@arm.com>
 <78881acb-5871-9534-c8cc-6f54937be3fd@arm.com>
 <20190918164546.GA41588@arrakis.emea.arm.com>
In-Reply-To: <20190918164546.GA41588@arrakis.emea.arm.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: f2a493a6-b947-4e32-9238-6e92fbabfcea.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: bb26077d-e597-4109-8366-08d73ca47082
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4618075)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DB7PR08MB2988;
X-MS-TrafficTypeDiagnostic: DB7PR08MB2988:|DB7PR08MB2988:|HE1PR0802MB2380:
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<HE1PR0802MB2380136B4D8B17D71B37E15AF7890@HE1PR0802MB2380.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:7691;OLM:7691;
x-forefront-prvs: 016572D96D
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(39860400002)(136003)(366004)(376002)(346002)(13464003)(189003)(199004)(86362001)(99286004)(76176011)(7696005)(476003)(446003)(11346002)(102836004)(6246003)(6506007)(26005)(186003)(53546011)(55236004)(3846002)(6116002)(33656002)(2906002)(7416002)(81166006)(81156014)(8676002)(8936002)(7736002)(305945005)(4326008)(74316002)(110136005)(25786009)(66556008)(66476007)(66446008)(64756008)(52536014)(14454004)(66946007)(6436002)(229853002)(54906003)(66066001)(5660300002)(55016002)(9686003)(76116006)(486006)(256004)(6636002)(478600001)(71190400001)(71200400001)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB2988;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 jgAO8dUFyWirEHW0+6y7hMqkAi0npZz4i5E5cC7zoWeMJX0rt7rVZTE9raOPZ3L/0aRHV/Tq36J0Ii9NH9sS4rbYCWP4TEP39WvjSZTuRX660p8g9AayNptgQzyOoRPcl2WThcys7cqCzrLQpGT05hnLRayJX14HPRCDFNhrtFeCx4RfcGNwuUTSh34MF/hFDYZwUH4Xr7PSel9qlcSSlldvUuUbGySzAliHNyLBBj239sUpSDREtYkQ/qDTrep/j054u30VikW+wRKbzs9S4qcZjo+N/FNMiTcdVy4XObhfOaydTjbleZGbsRfBsUZ2Oq/hhgOZmqi/zL/6JsQBBUmIXfPNrEJA/xzTFLAoimzi3rCrdH69qiD0kfuccq/zDuBLrj4pMZ/Rf5eqGJxAoTGOEAhISZ1czFZpDA84XbY=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB2988
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 AM5EUR03FT014.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(376002)(136003)(346002)(396003)(40434004)(13464003)(199004)(189003)(86362001)(22756006)(52536014)(81156014)(8676002)(66574012)(8936002)(99286004)(81166006)(4326008)(2906002)(47776003)(186003)(53546011)(26005)(7696005)(54906003)(336012)(102836004)(2486003)(6506007)(70586007)(23676004)(6116002)(110136005)(70206006)(76176011)(316002)(36906005)(5660300002)(3846002)(229853002)(6246003)(486006)(14454004)(305945005)(50466002)(436003)(476003)(126002)(356004)(25786009)(11346002)(446003)(76130400001)(63350400001)(9686003)(7736002)(66066001)(33656002)(74316002)(478600001)(14444005)(5024004)(6636002)(26826003)(55016002);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR0802MB2380;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;A:1;MX:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	50ad4b83-9f1e-441c-5519-08d73ca467b0
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600167)(710020)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:HE1PR0802MB2380;
X-Forefront-PRVS: 016572D96D
X-Microsoft-Antispam-Message-Info:
	8rv8muG7H0eU2IL2uSIe99aLMzXKwAI2r1Tr/jORYbHMZ8/Q6/0FNZU74gzOfDOdgyivYzfxrcYEM8zppIv4zfopf4otxCQADWdSwekQHqYuIC18PGtIhmHl0VjXY5wczZdpxTCcjI1PhInVyDVWXHUbcpMR9Q788a8xaftyMZ8oqedgXZXxaQAX6FzpsN4RTcDuOM/ARxjY+tisr9hEHegK+KhgJIziK7Xcc1Ga7EVb3gdQsFbImhS0xkTnVtFPfVn5Okp+PLELsFr01GO8KtozIZHsXm1cZmhhCwarXfcX2R86GaFg1o7Tcnjn6akCb1VVUN9sRp6PXrq8w7KvYe93coMZ4Oa+0WajTmRB6XLtjU/0FkQkLtaOWWr/xksKXDwDtCZbGB0FgpLC76NhV0ymb2EI8JtWISrnS8Z7B1k=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 19 Sep 2019 01:55:25.5578
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: bb26077d-e597-4109-8366-08d73ca47082
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR0802MB2380
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgU3V6dWtpDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQ2F0YWxp
biBNYXJpbmFzIDxjYXRhbGluLm1hcmluYXNAYXJtLmNvbT4NCj4gU2VudDogMjAxOeW5tDnmnIgx
OeaXpSAwOjQ2DQo+IFRvOiBTdXp1a2kgUG91bG9zZSA8U3V6dWtpLlBvdWxvc2VAYXJtLmNvbT4N
Cj4gQ2M6IEp1c3RpbiBIZSAoQXJtIFRlY2hub2xvZ3kgQ2hpbmEpIDxKdXN0aW4uSGVAYXJtLmNv
bT47IFdpbGwgRGVhY29uDQo+IDx3aWxsQGtlcm5lbC5vcmc+OyBNYXJrIFJ1dGxhbmQgPE1hcmsu
UnV0bGFuZEBhcm0uY29tPjsgSmFtZXMgTW9yc2UNCj4gPEphbWVzLk1vcnNlQGFybS5jb20+OyBN
YXJjIFp5bmdpZXIgPG1hekBrZXJuZWwub3JnPjsgTWF0dGhldw0KPiBXaWxjb3ggPHdpbGx5QGlu
ZnJhZGVhZC5vcmc+OyBLaXJpbGwgQS4gU2h1dGVtb3YNCj4gPGtpcmlsbC5zaHV0ZW1vdkBsaW51
eC5pbnRlbC5jb20+OyBsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmc7DQo+IGxp
bnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgUHVuaXQgQWdy
YXdhbA0KPiA8cHVuaXRhZ3Jhd2FsQGdtYWlsLmNvbT47IEFuc2h1bWFuIEtoYW5kdWFsDQo+IDxB
bnNodW1hbi5LaGFuZHVhbEBhcm0uY29tPjsgSnVuIFlhbyA8eWFvanVuODU1ODM2M0BnbWFpbC5j
b20+Ow0KPiBBbGV4IFZhbiBCcnVudCA8YXZhbmJydW50QG52aWRpYS5jb20+OyBSb2JpbiBNdXJw
aHkNCj4gPFJvYmluLk11cnBoeUBhcm0uY29tPjsgVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0
cm9uaXguZGU+Ow0KPiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPjsg
SsOpcsO0bWUgR2xpc3NlDQo+IDxqZ2xpc3NlQHJlZGhhdC5jb20+OyBSYWxwaCBDYW1wYmVsbCA8
cmNhbXBiZWxsQG52aWRpYS5jb20+Ow0KPiBoZWppYW5ldEBnbWFpbC5jb207IEthbHkgWGluIChB
cm0gVGVjaG5vbG9neSBDaGluYSkgPEthbHkuWGluQGFybS5jb20+DQo+IFN1YmplY3Q6IFJlOiBb
UEFUQ0ggdjQgMS8zXSBhcm02NDogY3B1ZmVhdHVyZTogaW50cm9kdWNlIGhlbHBlcg0KPiBjcHVf
aGFzX2h3X2FmKCkNCj4NCj4gT24gV2VkLCBTZXAgMTgsIDIwMTkgYXQgMDM6MjA6NDFQTSArMDEw
MCwgU3V6dWtpIEsgUG91bG9zZSB3cm90ZToNCj4gPiBPbiAxOC8wOS8yMDE5IDE0OjE5LCBKaWEg
SGUgd3JvdGU6DQo+ID4gPiBkaWZmIC0tZ2l0IGEvYXJjaC9hcm02NC9pbmNsdWRlL2FzbS9jcHVm
ZWF0dXJlLmgNCj4gYi9hcmNoL2FybTY0L2luY2x1ZGUvYXNtL2NwdWZlYXR1cmUuaA0KPiA+ID4g
aW5kZXggYzk2ZmZhNDcyMmQzLi4yMDZiNmUzOTU0Y2YgMTAwNjQ0DQo+ID4gPiAtLS0gYS9hcmNo
L2FybTY0L2luY2x1ZGUvYXNtL2NwdWZlYXR1cmUuaA0KPiA+ID4gKysrIGIvYXJjaC9hcm02NC9p
bmNsdWRlL2FzbS9jcHVmZWF0dXJlLmgNCj4gPiA+IEBAIC0zOTAsNiArMzkwLDcgQEAgZXh0ZXJu
IERFQ0xBUkVfQklUTUFQKGJvb3RfY2FwYWJpbGl0aWVzLA0KPiBBUk02NF9OUEFUQ0hBQkxFKTsN
Cj4gPiA+ICAgICAgICAgICBmb3JfZWFjaF9zZXRfYml0KGNhcCwgY3B1X2h3Y2FwcywgQVJNNjRf
TkNBUFMpDQo+ID4gPiAgIGJvb2wgdGhpc19jcHVfaGFzX2NhcCh1bnNpZ25lZCBpbnQgY2FwKTsN
Cj4gPiA+ICtib29sIGNwdV9oYXNfaHdfYWYodm9pZCk7DQo+ID4gPiAgIHZvaWQgY3B1X3NldF9m
ZWF0dXJlKHVuc2lnbmVkIGludCBudW0pOw0KPiA+ID4gICBib29sIGNwdV9oYXZlX2ZlYXR1cmUo
dW5zaWduZWQgaW50IG51bSk7DQo+ID4gPiAgIHVuc2lnbmVkIGxvbmcgY3B1X2dldF9lbGZfaHdj
YXAodm9pZCk7DQo+ID4gPiBkaWZmIC0tZ2l0IGEvYXJjaC9hcm02NC9rZXJuZWwvY3B1ZmVhdHVy
ZS5jDQo+IGIvYXJjaC9hcm02NC9rZXJuZWwvY3B1ZmVhdHVyZS5jDQo+ID4gPiBpbmRleCBiMWZk
YzQ4NmFlZDguLmM1MDk3ZjU4NjQ5ZCAxMDA2NDQNCj4gPiA+IC0tLSBhL2FyY2gvYXJtNjQva2Vy
bmVsL2NwdWZlYXR1cmUuYw0KPiA+ID4gKysrIGIvYXJjaC9hcm02NC9rZXJuZWwvY3B1ZmVhdHVy
ZS5jDQo+ID4gPiBAQCAtMTE0MSw2ICsxMTQxLDEyIEBAIHN0YXRpYyBib29sIGhhc19od19kYm0o
Y29uc3Qgc3RydWN0DQo+IGFybTY0X2NwdV9jYXBhYmlsaXRpZXMgKmNhcCwNCj4gPiA+ICAgICAg
ICAgICByZXR1cm4gdHJ1ZTsNCj4gPiA+ICAgfQ0KPiA+ID4gKy8qIERlY291cGxlIEFGIGZyb20g
QUZEQk0uICovDQo+ID4gPiArYm9vbCBjcHVfaGFzX2h3X2FmKHZvaWQpDQo+ID4gPiArew0KPiA+
IFNvcnJ5IGZvciBub3QgaGF2aW5nIGFza2VkIHRoaXMgZWFybGllci4gQXJlIHdlIGludGVyZXN0
ZWQgaW4sDQo+ID4NCj4gPiAid2hldGhlciAqdGhpcyogQ1BVIGhhcyBBRiBzdXBwb3J0ID8iIG9y
ICJ3aGV0aGVyICphdCBsZWFzdCBvbmUqDQo+ID4gQ1BVIGhhcyB0aGUgQUYgc3VwcG9ydCIgPyBU
aGUgZm9sbG93aW5nIGNvZGUgZG9lcyB0aGUgZm9ybWVyLg0KPiA+DQo+ID4gPiArIHJldHVybiAo
cmVhZF9jcHVpZChJRF9BQTY0TU1GUjFfRUwxKSAmIDB4Zik7DQo+DQo+IEluIGEgbm9uLXByZWVt
cHRpYmxlIGNvbnRleHQsIHRoZSBmb3JtZXIgaXMgb2sgKHBlci1DUFUpLg0KDQpZZXMsIGp1c3Qg
YXMgd2hhdCBDYXRhbGluIGV4cGxhaW5lZCwgd2UgbmVlZCB0aGUgZm9ybWVyIGJlY2F1c2UgdGhl
DQpwYWdlZmF1bHQgb2NjdXJyZWQgaW4gZXZlcnkgY3B1cw0KDQotLQ0KQ2hlZXJzLA0KSnVzdGlu
IChKaWEgSGUpDQoNCg0KPg0KPiAtLQ0KPiBDYXRhbGluDQpJTVBPUlRBTlQgTk9USUNFOiBUaGUg
Y29udGVudHMgb2YgdGhpcyBlbWFpbCBhbmQgYW55IGF0dGFjaG1lbnRzIGFyZSBjb25maWRlbnRp
YWwgYW5kIG1heSBhbHNvIGJlIHByaXZpbGVnZWQuIElmIHlvdSBhcmUgbm90IHRoZSBpbnRlbmRl
ZCByZWNpcGllbnQsIHBsZWFzZSBub3RpZnkgdGhlIHNlbmRlciBpbW1lZGlhdGVseSBhbmQgZG8g
bm90IGRpc2Nsb3NlIHRoZSBjb250ZW50cyB0byBhbnkgb3RoZXIgcGVyc29uLCB1c2UgaXQgZm9y
IGFueSBwdXJwb3NlLCBvciBzdG9yZSBvciBjb3B5IHRoZSBpbmZvcm1hdGlvbiBpbiBhbnkgbWVk
aXVtLiBUaGFuayB5b3UuDQo=

