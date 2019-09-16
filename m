Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A67EC4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:35:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7939206C2
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:35:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="5msRRyMB";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="Lb5bKsJg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7939206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 631BD6B0005; Mon, 16 Sep 2019 05:35:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B8FA6B0006; Mon, 16 Sep 2019 05:35:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 430BD6B0007; Mon, 16 Sep 2019 05:35:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 14A456B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:35:44 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9024D180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:35:43 +0000 (UTC)
X-FDA: 75940276566.25.mask60_4edfc68afbf12
X-HE-Tag: mask60_4edfc68afbf12
X-Filterd-Recvd-Size: 20502
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00079.outbound.protection.outlook.com [40.107.0.79])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:35:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I2ifp6qquXKQH2w1uuifkddXzceZUeNZk5MO+DHTeHI=;
 b=5msRRyMBnLBsGh6OJFATp5duUwuQ9QHJvU6qoRyOOTgNPncN7i7yc9ZNvyMEmKrSG6/r309WEFVYe0SzscxpyOPw61O6X11WrTuuQMT/1BeTSUDw5huRXKLb3g+socjy2OkhQcmRh1ZanB7UTxiop0RMo+FoSHEFuMKXX0tMaUY=
Received: from VI1PR08CA0215.eurprd08.prod.outlook.com (2603:10a6:802:15::24)
 by DBBPR08MB4524.eurprd08.prod.outlook.com (2603:10a6:10:c5::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2263.17; Mon, 16 Sep
 2019 09:35:38 +0000
Received: from DB5EUR03FT034.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e0a::204) by VI1PR08CA0215.outlook.office365.com
 (2603:10a6:802:15::24) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2263.15 via Frontend
 Transport; Mon, 16 Sep 2019 09:35:38 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=none action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 DB5EUR03FT034.mail.protection.outlook.com (10.152.20.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.14 via Frontend Transport; Mon, 16 Sep 2019 09:35:36 +0000
Received: ("Tessian outbound 55d20e99e8e2:v31"); Mon, 16 Sep 2019 09:35:27 +0000
X-CR-MTA-TID: 64aa7808
Received: from cf2f8bfb4420.2 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.10.50])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id 9F7BAF5C-831F-4AF1-85C3-B6ABD9F82A71.1;
	Mon, 16 Sep 2019 09:35:22 +0000
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-db5eur03lp2050.outbound.protection.outlook.com [104.47.10.50])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id cf2f8bfb4420.2
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384);
    Mon, 16 Sep 2019 09:35:22 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=fjd/5C1JmGRarovY2ok//qIN5zoCLI6RgO4lrYoRsvKTPw5Vpb9tIDJzfeCbCiWP6Pl7+VCXgiz10KzuezgFtu2kz44FyZLsWkO2wzGMUkWgKFSCnxxCL//79xmU2pRVpPYGUkfL3woyFoBALhnTA+q7X9is5kd9iTrkUwj3G136iYNPWlL/aweLfT1zf4LcYCEp0Vqns/ABYKMZIoIq3aP/YPbcMwIw/vwO6pHlldhycvwIqtffZD2pQJwjDJ8dXb9iQnOKV81rTa+/e3kUjc3gwKN8qmtEVlqdX5v4m1lPc+XPfN/2bfo3X9OmmGJqbULGioPny8n6TVQPTi/pNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xnGT3LL/wB+97Vcfz2P/FHGvByzlhoWnaHPTS9fhgpA=;
 b=Jhty7Bb5/UkQ6o1zlBKd0c0oAq7TEyjUi153sC5QjwPbAkvWHFFqalRZAtD2dgsimZVgGs7EdLfb9t1X6PGjz/jO2D29ZDnhX0RHTt45jAPiU0QoBHBrdabXV30sg/GeZRUZvC8riKZOADcN6S2U2p/ubWrhezgznLt4g0uGrx2zAliPu62LlKVR80ehg0np8Shh13xINbLFwAob4keXE3SlceT0ieOw7H5PcpHnhFHsMOLP7axqlm3g4+Nf1uiSKDv5CzxRmyu98cE4PJpipNd8PD5rtPMY6ay9HKjFDy/1R5t/x9J9tJfxjRCGxCS4QkZLa/p04YVAnWZRu2DFcw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xnGT3LL/wB+97Vcfz2P/FHGvByzlhoWnaHPTS9fhgpA=;
 b=Lb5bKsJgjI8vgTBR5SsluQ5WQ+cWTcSiaGLGpw6tkvgKKQfqrE/Z4H1xRUPdIiN65Dx6g9r9LUS2TJUhaqUiWkbkYAx0isLoa4XJ/hAOI3aRwCRpyD3M+Upmd8nHvKpOIU7HvnA834ZKXzEZBS2Kh5bHCaJNTW56jQSfEiglfoM=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB3707.eurprd08.prod.outlook.com (20.178.45.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.23; Mon, 16 Sep 2019 09:35:21 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2263.023; Mon, 16 Sep 2019
 09:35:21 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will@kernel.org>,
	Mark Rutland <Mark.Rutland@arm.com>, James Morse <James.Morse@arm.com>, Marc
 Zyngier <maz@kernel.org>, Matthew Wilcox <willy@infradead.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Punit Agrawal <punitagrawal@gmail.com>, Anshuman Khandual
	<Anshuman.Khandual@arm.com>, Jun Yao <yaojun8558363@gmail.com>, Alex Van
 Brunt <avanbrunt@nvidia.com>, Robin Murphy <Robin.Murphy@arm.com>, Thomas
 Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "hejianet@gmail.com" <hejianet@gmail.com>
Subject: RE: [PATCH v3 2/2] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Thread-Topic: [PATCH v3 2/2] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Thread-Index: AQHValDxzQ2H3fUPY0iuAtQTMeuRL6cuCjUAgAAFC4A=
Date: Mon, 16 Sep 2019 09:35:21 +0000
Message-ID:
 <DB7PR08MB30825C23ABB0962CC8826CBAF78C0@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190913163239.125108-1-justin.he@arm.com>
 <20190913163239.125108-3-justin.he@arm.com>
 <20190916091628.bkuvd3g3ie3x6qav@box.shutemov.name>
In-Reply-To: <20190916091628.bkuvd3g3ie3x6qav@box.shutemov.name>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: 86659871-5b5b-4a18-bc25-baf6fd402980.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: 98d832d7-d0ad-4597-6bc8-08d73a893abc
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4618075)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DB7PR08MB3707;
X-MS-TrafficTypeDiagnostic: DB7PR08MB3707:|DB7PR08MB3707:|DBBPR08MB4524:
X-MS-Exchange-PUrlCount: 1
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<DBBPR08MB45247BFF097764872561D402F78C0@DBBPR08MB4524.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:6790;OLM:6790;
x-forefront-prvs: 0162ACCC24
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(39860400002)(366004)(136003)(396003)(346002)(13464003)(199004)(189003)(6246003)(55016002)(9686003)(6306002)(66574012)(54906003)(966005)(11346002)(446003)(86362001)(478600001)(316002)(476003)(99286004)(76116006)(14444005)(256004)(66066001)(25786009)(66476007)(66556008)(64756008)(8936002)(14454004)(71200400001)(2906002)(71190400001)(66946007)(66446008)(5660300002)(7416002)(6916009)(53546011)(76176011)(6506007)(52536014)(33656002)(53936002)(229853002)(26005)(186003)(6436002)(7736002)(6116002)(305945005)(3846002)(81166006)(74316002)(4326008)(81156014)(8676002)(486006)(102836004)(7696005)(55236004);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB3707;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 hnl7yek65lSnWAxmpHYstElSvfPKaoeGQwS5Jf72HeaZ/+23Pl7/1sA+46rBcktYM7jwud1BCrzPs+DEIoSDZH7pYaIW+HDD7+2W1VyL8glwNpb8XytZPDQXaez0KEcp7g9/7/wJ3lGOwnGatPjJKgQpI7IC8UWa2HoZ+VyNTNRMJACkF4kaVn5WDcf7qtu0dzH6VyMOfL4/dpIS65glfV8TJUrP9Xt7yzjt66k2CKn2K26JnvxBZ1KYCnx7Cs59RsiS6BD0HpYArDUPoduz+o4KN2JGw3DNBF2DLlpm7ZLBpff/aikm4/FmBY8HpSqWFBvbzJQ/1uXWL9rwzUYqK40k6Yk452ls3npv8aQLpNODNgwlB04sY13cHk5I9b1EGAK4PjboczH65pt8JZ0UvLkQDY4+b4Nm282avSBNjhY=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3707
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 DB5EUR03FT034.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(376002)(136003)(39860400002)(189003)(199004)(40434004)(13464003)(2906002)(66066001)(107886003)(81166006)(70586007)(70206006)(86362001)(81156014)(8676002)(99286004)(102836004)(478600001)(53546011)(26826003)(26005)(6506007)(25786009)(5024004)(14444005)(305945005)(7736002)(74316002)(52536014)(22756006)(316002)(336012)(356004)(76130400001)(6862004)(11346002)(446003)(63350400001)(6246003)(436003)(5660300002)(229853002)(55016002)(50466002)(66574012)(33656002)(76176011)(6306002)(9686003)(3846002)(6116002)(476003)(126002)(14454004)(8936002)(7696005)(23676004)(2486003)(4326008)(486006)(47776003)(54906003)(186003)(966005);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR08MB4524;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;MX:1;A:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	02e87f9f-ea6f-4dc6-2f68-08d73a893186
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(710020)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DBBPR08MB4524;
X-Forefront-PRVS: 0162ACCC24
X-Microsoft-Antispam-Message-Info:
	QU6YOXdY2C5U1ZSmXris2u4b7XCPKP9PN8KPwWL10vqYWNQCuKN+BrwJdKU9v/rfmU00M/PQjxG2WtFvt8uWUHZ400V6RpkdBjYcFAIWA+U7xvUWiAGGwlIQIsJtcztFDw3gKM8wA4k87nrkWC6Z0XPd8Yt4vTR7saI/H/UNzxYH5Etrch7+QjfSfm/cvARPDTipTNlql6nng+PgBQrodCpNqV8hBosH/OrxwGd9bUqXwR7gbe24DLvQNWL8oBr7jphBvR5k5A+GU+ihbL9PqVsid/XHUcthNvNhcCChc8fP6rPBPGWGoYMIDbfvLTKiYmFglJWpDtir+zxJAtDatvRmB5BBMw+eSu6mO019jXGEH2yh2TYrf8bbjRePIBxKZQBroQkm7S9KFd3qyS9YZYUepvj5f669QdL/yCgO/z8=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 16 Sep 2019 09:35:36.6051
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 98d832d7-d0ad-4597-6bc8-08d73a893abc
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR08MB4524
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQpIaSBLaXJpbGwNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogS2lyaWxs
IEEuIFNodXRlbW92IDxraXJpbGxAc2h1dGVtb3YubmFtZT4NCj4gU2VudDogMjAxOeW5tDnmnIgx
NuaXpSAxNzoxNg0KPiBUbzogSnVzdGluIEhlIChBcm0gVGVjaG5vbG9neSBDaGluYSkgPEp1c3Rp
bi5IZUBhcm0uY29tPg0KPiBDYzogQ2F0YWxpbiBNYXJpbmFzIDxDYXRhbGluLk1hcmluYXNAYXJt
LmNvbT47IFdpbGwgRGVhY29uDQo+IDx3aWxsQGtlcm5lbC5vcmc+OyBNYXJrIFJ1dGxhbmQgPE1h
cmsuUnV0bGFuZEBhcm0uY29tPjsgSmFtZXMgTW9yc2UNCj4gPEphbWVzLk1vcnNlQGFybS5jb20+
OyBNYXJjIFp5bmdpZXIgPG1hekBrZXJuZWwub3JnPjsgTWF0dGhldw0KPiBXaWxjb3ggPHdpbGx5
QGluZnJhZGVhZC5vcmc+OyBLaXJpbGwgQS4gU2h1dGVtb3YNCj4gPGtpcmlsbC5zaHV0ZW1vdkBs
aW51eC5pbnRlbC5jb20+OyBsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmc7DQo+
IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgUHVuaXQg
QWdyYXdhbA0KPiA8cHVuaXRhZ3Jhd2FsQGdtYWlsLmNvbT47IEFuc2h1bWFuIEtoYW5kdWFsDQo+
IDxBbnNodW1hbi5LaGFuZHVhbEBhcm0uY29tPjsgSnVuIFlhbyA8eWFvanVuODU1ODM2M0BnbWFp
bC5jb20+Ow0KPiBBbGV4IFZhbiBCcnVudCA8YXZhbmJydW50QG52aWRpYS5jb20+OyBSb2JpbiBN
dXJwaHkNCj4gPFJvYmluLk11cnBoeUBhcm0uY29tPjsgVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxp
bnV0cm9uaXguZGU+Ow0KPiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3Jn
PjsgSsOpcsO0bWUgR2xpc3NlDQo+IDxqZ2xpc3NlQHJlZGhhdC5jb20+OyBSYWxwaCBDYW1wYmVs
bCA8cmNhbXBiZWxsQG52aWRpYS5jb20+Ow0KPiBoZWppYW5ldEBnbWFpbC5jb20NCj4gU3ViamVj
dDogUmU6IFtQQVRDSCB2MyAyLzJdIG1tOiBmaXggZG91YmxlIHBhZ2UgZmF1bHQgb24gYXJtNjQg
aWYgUFRFX0FGDQo+IGlzIGNsZWFyZWQNCj4NCj4gT24gU2F0LCBTZXAgMTQsIDIwMTkgYXQgMTI6
MzI6MzlBTSArMDgwMCwgSmlhIEhlIHdyb3RlOg0KPiA+IFdoZW4gd2UgdGVzdGVkIHBtZGsgdW5p
dCB0ZXN0IFsxXSB2bW1hbGxvY19mb3JrIFRFU1QxIGluIGFybTY0IGd1ZXN0LA0KPiB0aGVyZQ0K
PiA+IHdpbGwgYmUgYSBkb3VibGUgcGFnZSBmYXVsdCBpbiBfX2NvcHlfZnJvbV91c2VyX2luYXRv
bWljIG9mDQo+IGNvd191c2VyX3BhZ2UuDQo+ID4NCj4gPiBCZWxvdyBjYWxsIHRyYWNlIGlzIGZy
b20gYXJtNjQgZG9fcGFnZV9mYXVsdCBmb3IgZGVidWdnaW5nIHB1cnBvc2UNCj4gPiBbICAxMTAu
MDE2MTk1XSBDYWxsIHRyYWNlOg0KPiA+IFsgIDExMC4wMTY4MjZdICBkb19wYWdlX2ZhdWx0KzB4
NWE0LzB4NjkwDQo+ID4gWyAgMTEwLjAxNzgxMl0gIGRvX21lbV9hYm9ydCsweDUwLzB4YjANCj4g
PiBbICAxMTAuMDE4NzI2XSAgZWwxX2RhKzB4MjAvMHhjNA0KPiA+IFsgIDExMC4wMTk0OTJdICBf
X2FyY2hfY29weV9mcm9tX3VzZXIrMHgxODAvMHgyODANCj4gPiBbICAxMTAuMDIwNjQ2XSAgZG9f
d3BfcGFnZSsweGIwLzB4ODYwDQo+ID4gWyAgMTEwLjAyMTUxN10gIF9faGFuZGxlX21tX2ZhdWx0
KzB4OTk0LzB4MTMzOA0KPiA+IFsgIDExMC4wMjI2MDZdICBoYW5kbGVfbW1fZmF1bHQrMHhlOC8w
eDE4MA0KPiA+IFsgIDExMC4wMjM1ODRdICBkb19wYWdlX2ZhdWx0KzB4MjQwLzB4NjkwDQo+ID4g
WyAgMTEwLjAyNDUzNV0gIGRvX21lbV9hYm9ydCsweDUwLzB4YjANCj4gPiBbICAxMTAuMDI1NDIz
XSAgZWwwX2RhKzB4MjAvMHgyNA0KPiA+DQo+ID4gVGhlIHB0ZSBpbmZvIGJlZm9yZSBfX2NvcHlf
ZnJvbV91c2VyX2luYXRvbWljIGlzIChQVEVfQUYgaXMgY2xlYXJlZCk6DQo+ID4gW2ZmZmY5YjAw
NzAwMF0gcGdkPTAwMDAwMDAyM2Q0ZjgwMDMsIHB1ZD0wMDAwMDAwMjNkYTliMDAzLA0KPiBwbWQ9
MDAwMDAwMDIzZDRiMzAwMywgcHRlPTM2MDAwMDI5ODYwN2JkMw0KPiA+DQo+ID4gQXMgdG9sZCBi
eSBDYXRhbGluOiAiT24gYXJtNjQgd2l0aG91dCBoYXJkd2FyZSBBY2Nlc3MgRmxhZywgY29weWlu
Zw0KPiBmcm9tDQo+ID4gdXNlciB3aWxsIGZhaWwgYmVjYXVzZSB0aGUgcHRlIGlzIG9sZCBhbmQg
Y2Fubm90IGJlIG1hcmtlZCB5b3VuZy4gU28gd2UNCj4gPiBhbHdheXMgZW5kIHVwIHdpdGggemVy
b2VkIHBhZ2UgYWZ0ZXIgZm9yaygpICsgQ29XIGZvciBwZm4gbWFwcGluZ3MuIHdlDQo+ID4gZG9u
J3QgYWx3YXlzIGhhdmUgYSBoYXJkd2FyZS1tYW5hZ2VkIGFjY2VzcyBmbGFnIG9uIGFybTY0LiIN
Cj4gPg0KPiA+IFRoaXMgcGF0Y2ggZml4IGl0IGJ5IGNhbGxpbmcgcHRlX21reW91bmcuIEFsc28s
IHRoZSBwYXJhbWV0ZXIgaXMNCj4gPiBjaGFuZ2VkIGJlY2F1c2Ugdm1mIHNob3VsZCBiZSBwYXNz
ZWQgdG8gY293X3VzZXJfcGFnZSgpDQo+ID4NCj4gPiBbMV0NCj4gaHR0cHM6Ly9naXRodWIuY29t
L3BtZW0vcG1kay90cmVlL21hc3Rlci9zcmMvdGVzdC92bW1hbGxvY19mb3JrDQo+ID4NCj4gPiBS
ZXBvcnRlZC1ieTogWWlibyBDYWkgPFlpYm8uQ2FpQGFybS5jb20+DQo+ID4gU2lnbmVkLW9mZi1i
eTogSmlhIEhlIDxqdXN0aW4uaGVAYXJtLmNvbT4NCj4gPiAtLS0NCj4gPiAgbW0vbWVtb3J5LmMg
fCAzMCArKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQs
IDI1IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pDQo+ID4NCj4gPiBkaWZmIC0tZ2l0IGEv
bW0vbWVtb3J5LmMgYi9tbS9tZW1vcnkuYw0KPiA+IGluZGV4IGUyYmI1MWI2MjQyZS4uYTY0YWY2
NDk1ZjcxIDEwMDY0NA0KPiA+IC0tLSBhL21tL21lbW9yeS5jDQo+ID4gKysrIGIvbW0vbWVtb3J5
LmMNCj4gPiBAQCAtMTE4LDYgKzExOCwxMyBAQCBpbnQgcmFuZG9taXplX3ZhX3NwYWNlIF9fcmVh
ZF9tb3N0bHkgPQ0KPiA+ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDI7DQo+
ID4gICNlbmRpZg0KPiA+DQo+ID4gKyNpZm5kZWYgYXJjaF9mYXVsdHNfb25fb2xkX3B0ZQ0KPiA+
ICtzdGF0aWMgaW5saW5lIGJvb2wgYXJjaF9mYXVsdHNfb25fb2xkX3B0ZSh2b2lkKQ0KPiA+ICt7
DQo+ID4gKyAgIHJldHVybiBmYWxzZTsNCj4gPiArfQ0KPiA+ICsjZW5kaWYNCj4gPiArDQo+ID4g
IHN0YXRpYyBpbnQgX19pbml0IGRpc2FibGVfcmFuZG1hcHMoY2hhciAqcykNCj4gPiAgew0KPiA+
ICAgICByYW5kb21pemVfdmFfc3BhY2UgPSAwOw0KPiA+IEBAIC0yMTQwLDcgKzIxNDcsOCBAQCBz
dGF0aWMgaW5saW5lIGludCBwdGVfdW5tYXBfc2FtZShzdHJ1Y3QNCj4gbW1fc3RydWN0ICptbSwg
cG1kX3QgKnBtZCwNCj4gPiAgICAgcmV0dXJuIHNhbWU7DQo+ID4gIH0NCj4gPg0KPiA+IC1zdGF0
aWMgaW5saW5lIHZvaWQgY293X3VzZXJfcGFnZShzdHJ1Y3QgcGFnZSAqZHN0LCBzdHJ1Y3QgcGFn
ZSAqc3JjLA0KPiB1bnNpZ25lZCBsb25nIHZhLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkN
Cj4gPiArc3RhdGljIGlubGluZSB2b2lkIGNvd191c2VyX3BhZ2Uoc3RydWN0IHBhZ2UgKmRzdCwg
c3RydWN0IHBhZ2UgKnNyYywNCj4gPiArICAgICAgICAgICAgICAgICAgICAgICAgICAgc3RydWN0
IHZtX2ZhdWx0ICp2bWYpDQo+ID4gIHsNCj4gPiAgICAgZGVidWdfZG1hX2Fzc2VydF9pZGxlKHNy
Yyk7DQo+ID4NCj4gPiBAQCAtMjE1MiwyMCArMjE2MCwzMiBAQCBzdGF0aWMgaW5saW5lIHZvaWQg
Y293X3VzZXJfcGFnZShzdHJ1Y3QgcGFnZQ0KPiAqZHN0LCBzdHJ1Y3QgcGFnZSAqc3JjLCB1bnNp
Z25lZCBsbw0KPiA+ICAgICAgKi8NCj4gPiAgICAgaWYgKHVubGlrZWx5KCFzcmMpKSB7DQo+ID4g
ICAgICAgICAgICAgdm9pZCAqa2FkZHIgPSBrbWFwX2F0b21pYyhkc3QpOw0KPiA+IC0gICAgICAg
ICAgIHZvaWQgX191c2VyICp1YWRkciA9ICh2b2lkIF9fdXNlciAqKSh2YSAmIFBBR0VfTUFTSyk7
DQo+ID4gKyAgICAgICAgICAgdm9pZCBfX3VzZXIgKnVhZGRyID0gKHZvaWQgX191c2VyICopKHZt
Zi0+YWRkcmVzcyAmDQo+IFBBR0VfTUFTSyk7DQo+ID4gKyAgICAgICAgICAgcHRlX3QgZW50cnk7
DQo+ID4NCj4gPiAgICAgICAgICAgICAvKg0KPiA+ICAgICAgICAgICAgICAqIFRoaXMgcmVhbGx5
IHNob3VsZG4ndCBmYWlsLCBiZWNhdXNlIHRoZSBwYWdlIGlzIHRoZXJlDQo+ID4gICAgICAgICAg
ICAgICogaW4gdGhlIHBhZ2UgdGFibGVzLiBCdXQgaXQgbWlnaHQganVzdCBiZSB1bnJlYWRhYmxl
LA0KPiA+ICAgICAgICAgICAgICAqIGluIHdoaWNoIGNhc2Ugd2UganVzdCBnaXZlIHVwIGFuZCBm
aWxsIHRoZSByZXN1bHQgd2l0aA0KPiA+IC0gICAgICAgICAgICAqIHplcm9lcy4NCj4gPiArICAg
ICAgICAgICAgKiB6ZXJvZXMuIElmIFBURV9BRiBpcyBjbGVhcmVkIG9uIGFybTY0LCBpdCBtaWdo
dA0KPiA+ICsgICAgICAgICAgICAqIGNhdXNlIGRvdWJsZSBwYWdlIGZhdWx0LiBTbyBtYWtlcyBw
dGUgeW91bmcgaGVyZQ0KPiA+ICAgICAgICAgICAgICAqLw0KPiA+ICsgICAgICAgICAgIGlmIChh
cmNoX2ZhdWx0c19vbl9vbGRfcHRlKCkgJiYgIXB0ZV95b3VuZyh2bWYtPm9yaWdfcHRlKSkNCj4g
ew0KPiA+ICsgICAgICAgICAgICAgICAgICAgc3Bpbl9sb2NrKHZtZi0+cHRsKTsNCj4gPiArICAg
ICAgICAgICAgICAgICAgIGVudHJ5ID0gcHRlX21reW91bmcodm1mLT5vcmlnX3B0ZSk7DQo+DQo+
IFNob3VsZCd0IHlvdSByZS12YWxpZGF0ZSB0aGF0IG9yaWdfcHRlIGFmdGVyIHJlLXRha2luZyBw
dGw/IEl0IGNhbiBiZQ0KPiBzdGFsZSBieSBub3cuDQpUaGFua3MsIGRvIHlvdSBtZWFuIGZsdXNo
X2NhY2hlX3BhZ2Uodm1hLCB2bWYtPmFkZHJlc3MsIHB0ZV9wZm4odm1mLT5vcmlnX3B0ZSkpDQpi
ZWZvcmUgcHRlX21reW91bmc/DQoNCi0tDQpDaGVlcnMsDQpKdXN0aW4gKEppYSBIZSkNCg0KDQo+
DQo+ID4gKyAgICAgICAgICAgICAgICAgICBpZiAocHRlcF9zZXRfYWNjZXNzX2ZsYWdzKHZtZi0+
dm1hLCB2bWYtPmFkZHJlc3MsDQo+ID4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIHZtZi0+cHRlLCBlbnRyeSwgMCkpDQo+ID4gKyAgICAgICAgICAgICAgICAg
ICAgICAgICAgIHVwZGF0ZV9tbXVfY2FjaGUodm1mLT52bWEsIHZtZi0NCj4gPmFkZHJlc3MsDQo+
ID4gKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdm1mLT5wdGUp
Ow0KPiA+ICsgICAgICAgICAgICAgICAgICAgc3Bpbl91bmxvY2sodm1mLT5wdGwpOw0KPiA+ICsg
ICAgICAgICAgIH0NCj4gPiArDQo+ID4gICAgICAgICAgICAgaWYgKF9fY29weV9mcm9tX3VzZXJf
aW5hdG9taWMoa2FkZHIsIHVhZGRyLCBQQUdFX1NJWkUpKQ0KPiA+ICAgICAgICAgICAgICAgICAg
ICAgY2xlYXJfcGFnZShrYWRkcik7DQo+ID4gICAgICAgICAgICAga3VubWFwX2F0b21pYyhrYWRk
cik7DQo+ID4gICAgICAgICAgICAgZmx1c2hfZGNhY2hlX3BhZ2UoZHN0KTsNCj4gPiAgICAgfSBl
bHNlDQo+ID4gLSAgICAgICAgICAgY29weV91c2VyX2hpZ2hwYWdlKGRzdCwgc3JjLCB2YSwgdm1h
KTsNCj4gPiArICAgICAgICAgICBjb3B5X3VzZXJfaGlnaHBhZ2UoZHN0LCBzcmMsIHZtZi0+YWRk
cmVzcywgdm1mLT52bWEpOw0KPiA+ICB9DQo+ID4NCj4gPiAgc3RhdGljIGdmcF90IF9fZ2V0X2Zh
dWx0X2dmcF9tYXNrKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hKQ0KPiA+IEBAIC0yMzE4LDcg
KzIzMzgsNyBAQCBzdGF0aWMgdm1fZmF1bHRfdCB3cF9wYWdlX2NvcHkoc3RydWN0DQo+IHZtX2Zh
dWx0ICp2bWYpDQo+ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZtZi0+YWRkcmVzcyk7
DQo+ID4gICAgICAgICAgICAgaWYgKCFuZXdfcGFnZSkNCj4gPiAgICAgICAgICAgICAgICAgICAg
IGdvdG8gb29tOw0KPiA+IC0gICAgICAgICAgIGNvd191c2VyX3BhZ2UobmV3X3BhZ2UsIG9sZF9w
YWdlLCB2bWYtPmFkZHJlc3MsIHZtYSk7DQo+ID4gKyAgICAgICAgICAgY293X3VzZXJfcGFnZShu
ZXdfcGFnZSwgb2xkX3BhZ2UsIHZtZik7DQo+ID4gICAgIH0NCj4gPg0KPiA+ICAgICBpZiAobWVt
X2Nncm91cF90cnlfY2hhcmdlX2RlbGF5KG5ld19wYWdlLCBtbSwgR0ZQX0tFUk5FTCwNCj4gJm1l
bWNnLCBmYWxzZSkpDQo+ID4gLS0NCj4gPiAyLjE3LjENCj4gPg0KPiA+DQo+DQo+IC0tDQo+ICBL
aXJpbGwgQS4gU2h1dGVtb3YNCklNUE9SVEFOVCBOT1RJQ0U6IFRoZSBjb250ZW50cyBvZiB0aGlz
IGVtYWlsIGFuZCBhbnkgYXR0YWNobWVudHMgYXJlIGNvbmZpZGVudGlhbCBhbmQgbWF5IGFsc28g
YmUgcHJpdmlsZWdlZC4gSWYgeW91IGFyZSBub3QgdGhlIGludGVuZGVkIHJlY2lwaWVudCwgcGxl
YXNlIG5vdGlmeSB0aGUgc2VuZGVyIGltbWVkaWF0ZWx5IGFuZCBkbyBub3QgZGlzY2xvc2UgdGhl
IGNvbnRlbnRzIHRvIGFueSBvdGhlciBwZXJzb24sIHVzZSBpdCBmb3IgYW55IHB1cnBvc2UsIG9y
IHN0b3JlIG9yIGNvcHkgdGhlIGluZm9ybWF0aW9uIGluIGFueSBtZWRpdW0uIFRoYW5rIHlvdS4N
Cg==

