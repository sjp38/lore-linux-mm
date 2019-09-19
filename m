Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F228AC4CEC9
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:46:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81BE2218AE
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:46:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="llg6hyAv";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="CHZ+IQIL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81BE2218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E48006B0322; Wed, 18 Sep 2019 21:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF9476B0323; Wed, 18 Sep 2019 21:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C70FD6B0324; Wed, 18 Sep 2019 21:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 92C4B6B0322
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:46:52 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4AE556889
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:46:52 +0000 (UTC)
X-FDA: 75949981464.13.star22_58a4bdf94fb22
X-HE-Tag: star22_58a4bdf94fb22
X-Filterd-Recvd-Size: 15659
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50045.outbound.protection.outlook.com [40.107.5.45])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:46:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=d2SPqlh2gbwyS372uV+LAISVlaRZSRKc7Z6L9MkjQG8=;
 b=llg6hyAvFFj/qMtNR23gueO9RIvddQxdHTAgaeKB1IjOFDVn04f5Joe5ajml4TzPVktn5xT37cq9Nm+BxMPIOn9AEgqDmWVKVygvNo0PM61UzSyRvnJf79vqoKkVqZ94vM1ZO4HPVT8i4+WWaSsHP4090tcCCtaHA2kyj4Qm1I4=
Received: from DB6PR0802CA0044.eurprd08.prod.outlook.com (2603:10a6:4:a3::30)
 by AM0PR08MB3843.eurprd08.prod.outlook.com (2603:10a6:208:fb::23) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2263.15; Thu, 19 Sep
 2019 01:46:44 +0000
Received: from AM5EUR03FT061.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e08::205) by DB6PR0802CA0044.outlook.office365.com
 (2603:10a6:4:a3::30) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2284.18 via Frontend
 Transport; Thu, 19 Sep 2019 01:46:44 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=none action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 AM5EUR03FT061.mail.protection.outlook.com (10.152.16.247) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2284.20 via Frontend Transport; Thu, 19 Sep 2019 01:46:43 +0000
Received: ("Tessian outbound 0d576b67b9f5:v31"); Thu, 19 Sep 2019 01:46:40 +0000
X-CR-MTA-TID: 64aa7808
Received: from 43d2b85e0adb.2 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.13.56])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id 8E4F7821-85A2-43C1-9888-6F531C4A0A4B.1;
	Thu, 19 Sep 2019 01:46:35 +0000
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-he1eur04lp2056.outbound.protection.outlook.com [104.47.13.56])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id 43d2b85e0adb.2
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384);
    Thu, 19 Sep 2019 01:46:35 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ltoFX0GiUyGySvggePl/6aN4X4SFWRdt69lBku3F5Qt5HBAN7EScOZtRj/XmzbGDabrltwvVj7TNQdpIcn62kaOpUuQV/CJZYslxkU+E7SaRbVv7gtGPAST9wOIg0TPjTF+iRmMfWHLd0KBOhhO7U4CdI3XINW03gImhevcY5Z8HHUoWUZ0ejgJyhDG8sOzMRoE3uNQiP7WU+2WUuGzzNbPpq4i7Qt6OBGqtOgdUUFHLUCIGj2VsNsGVTeywTpnQo+eL/e6L53khSmhmYbFUVYVJdvLgHmaa1DpCpAzJWsM7ye339lhTvT7+BaTjDwvAQxTzDRBjZtHOc79T3Q/Atg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=IU57WGhu4StaQg/fJiktihBe13x52CapcWzDbC8K638=;
 b=C9VZzN1asL0YflAc7nl8mtVxZyweo05/fUyVaOMI2vMv7TqcPFD42av+pCMC/oNl039v1m/XeNB9sHHJm0+YmkXDqgml8wBVnc+ZTiQL1vYMbZcNmfsmmMLoB6G2NFjxuI9xp61wgNpWC5zx2/bLV9guo0jIJsH0xW2BrEAjsgXVs2yQ59cd4esCxobMdeDvxYUPnOhqA/8EoBFtP1Lst4XQC5NjJxNQfIX4qqTPifUbE43w1WW3cPnPI2AK30D+O07ddfwQ1YXN/hGDNqGuAruBldO6Cg3G2PqlG7toT08OgMtmZVHpdzufX315yyHIst402RXAXJwK1wb+AiHZIQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=IU57WGhu4StaQg/fJiktihBe13x52CapcWzDbC8K638=;
 b=CHZ+IQILah4nvCZpsyxAF+CclxDDBVZYcpq+7p7AGKYUciduBAK9x1mIQ7Nu4M8oNnyct4qLGVUfxYcKgCftO29p3uKYugyazmFLq6NHjAn9fMTJjcAAjTgFOcq4rkz+rdCGx3QQYpeMeh9NH537g/OgBj5VNmfNPYyPIlAQkq8=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB3017.eurprd08.prod.outlook.com (52.134.111.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.17; Thu, 19 Sep 2019 01:46:31 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2263.023; Thu, 19 Sep 2019
 01:46:31 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: kbuild test robot <lkp@intel.com>
CC: "kbuild-all@01.org" <kbuild-all@01.org>, Catalin Marinas
	<Catalin.Marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland
	<Mark.Rutland@arm.com>, James Morse <James.Morse@arm.com>, Marc Zyngier
	<maz@kernel.org>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal
	<punitagrawal@gmail.com>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Jun
 Yao <yaojun8558363@gmail.com>, Alex Van Brunt <avanbrunt@nvidia.com>, Robin
 Murphy <Robin.Murphy@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew
 Morton <akpm@linux-foundation.org>, "jglisse@redhat.com"
	<jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"hejianet@gmail.com" <hejianet@gmail.com>, "Kaly Xin (Arm Technology China)"
	<Kaly.Xin@arm.com>
Subject: RE: [PATCH v4 3/3] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Thread-Topic: [PATCH v4 3/3] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Thread-Index: AQHVbiPH7tIovpDc7EGl02aq95xmnKcx1EeAgABnNuA=
Date: Thu, 19 Sep 2019 01:46:31 +0000
Message-ID:
 <DB7PR08MB3082F79B9A1F09E60BEEC3C9F7890@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190918131914.38081-4-justin.he@arm.com>
 <201909190328.1k5H6WLv%lkp@intel.com>
In-Reply-To: <201909190328.1k5H6WLv%lkp@intel.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: c84a278a-1604-4f7a-b3f7-4787d9967d05.0
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: 49c7bccd-7e7d-49a9-f8d5-08d73ca33991
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4618075)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DB7PR08MB3017;
X-MS-TrafficTypeDiagnostic: DB7PR08MB3017:|DB7PR08MB3017:|AM0PR08MB3843:
X-MS-Exchange-PUrlCount: 3
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<AM0PR08MB38436C78EC91047457D21F24F7890@AM0PR08MB3843.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:8273;OLM:8273;
x-forefront-prvs: 016572D96D
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(979002)(4636009)(366004)(376002)(39860400002)(346002)(136003)(396003)(13464003)(199004)(189003)(229853002)(11346002)(71200400001)(74316002)(7736002)(305945005)(486006)(53546011)(6246003)(54906003)(55236004)(71190400001)(6436002)(81166006)(6506007)(8676002)(6306002)(81156014)(26005)(9686003)(2906002)(186003)(99286004)(102836004)(76176011)(3846002)(6116002)(7416002)(55016002)(66946007)(66556008)(5660300002)(476003)(256004)(64756008)(33656002)(66446008)(66476007)(5024004)(7696005)(8936002)(4326008)(6916009)(316002)(966005)(446003)(25786009)(66066001)(52536014)(478600001)(86362001)(14454004)(76116006)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB3017;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 VFZft1LLbUzucTh1q43pJrb4qmWJt5ObW3omJeBm7q/cp7Zoxs3B2C52CJB+K34TLCWSzzKtkn/VB2Z9Cm5XP11uayL7uy8m2m48GVVPxuxQ+DP82S4EgpE2KXJPxuta63Ro0IVmCjFY+68gYkWu9gGV1cGTGmmUclKomKOF4u9sHAKgOPhymkwr3N6xsHVkDcE9aobEOJqtYjMcCFFvSbQQj3TudTjTzyvXdxWskx3m1KGCbmUBZgsoGxySc5luhwSiNzC30WlUKmG4+y4oNXY5HuM14bMzgRH3uI/zD04UFqhe4FXG/8Bf8VxKK/rLVBoMXld7LxhwJOdVQEKKvIiZ/gnjwlEyWQ/0Q6PYf2GWWKBpLKXnoYHCIOMqIY7vQ4HMiF9wPrxSEC21NWfsXcgQFusyVsgW4H/PcSgJN+s=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3017
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 AM5EUR03FT061.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(979002)(4636009)(39860400002)(136003)(396003)(376002)(346002)(40434004)(13464003)(199004)(189003)(8936002)(14454004)(86362001)(26826003)(229853002)(478600001)(22756006)(81156014)(356004)(48336001)(7736002)(74316002)(305945005)(966005)(47136003)(81166006)(2906002)(52536014)(5024004)(50466002)(33656002)(336012)(70586007)(186003)(6116002)(476003)(66066001)(36906005)(7696005)(446003)(23696002)(76130400001)(11346002)(70206006)(76176011)(14444005)(3846002)(102836004)(6862004)(6506007)(4326008)(316002)(126002)(53546011)(25786009)(486006)(5660300002)(55016002)(8676002)(6246003)(6306002)(26005)(436003)(9686003)(63350400001)(54906003)(99286004)(47776003)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR08MB3843;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;A:1;MX:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	d8f171aa-8f62-45e6-9316-08d73ca33210
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(710020)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:AM0PR08MB3843;
X-Forefront-PRVS: 016572D96D
X-Microsoft-Antispam-Message-Info:
	RC1kvUMMwFK0sfYdyGv2kMWfDIYXnOI0Qof7i8cYeQIVtxanwk7AdjBeZuYQ7mg1ed6hrDNhwTDYmgfPAYa14wQsIoSs7UohsFSOK2mBjgYVkZME0DaLmjf70y8g3PPN15i/2aNOZjp2aRCK6P0HC7GijvGe2+fEQm7wiE3Zihbi/Fj/DEG/FCBxhO62pRWQxHRK1TFc0az0fXccAX9vyXXEbeNbxYJjRWJUNN2nfA+pMFjR/UZs6xdCkPm+jXFxa4mGUttOgHPqp8OhMExZHvKxIQDRVGaasNAjM2s/XMOMxnsPSuX4NSUxlZZ5EddFsoSLIIUZFbyTTGmQWohYXNBCPRQuQbE5u+TwV97QCSZ7hEkmaY+nhWOQV0LSSmhVydx10PxGy+GsG3RaqejbLMBXgJKvmtkOD2LJG1ArFns=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 19 Sep 2019 01:46:43.8719
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 49c7bccd-7e7d-49a9-f8d5-08d73ca33991
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR08MB3843
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbToga2J1aWxkIHRlc3Qgcm9i
b3QgPGxrcEBpbnRlbC5jb20+DQo+IFNlbnQ6IDIwMTnE6jnUwjE5yNUgMzozNg0KPiBUbzogSnVz
dGluIEhlIChBcm0gVGVjaG5vbG9neSBDaGluYSkgPEp1c3Rpbi5IZUBhcm0uY29tPg0KPiBDYzog
a2J1aWxkLWFsbEAwMS5vcmc7IENhdGFsaW4gTWFyaW5hcyA8Q2F0YWxpbi5NYXJpbmFzQGFybS5j
b20+OyBXaWxsDQo+IERlYWNvbiA8d2lsbEBrZXJuZWwub3JnPjsgTWFyayBSdXRsYW5kIDxNYXJr
LlJ1dGxhbmRAYXJtLmNvbT47DQo+IEphbWVzIE1vcnNlIDxKYW1lcy5Nb3JzZUBhcm0uY29tPjsg
TWFyYyBaeW5naWVyIDxtYXpAa2VybmVsLm9yZz47DQo+IE1hdHRoZXcgV2lsY294IDx3aWxseUBp
bmZyYWRlYWQub3JnPjsgS2lyaWxsIEEuIFNodXRlbW92DQo+IDxraXJpbGwuc2h1dGVtb3ZAbGlu
dXguaW50ZWwuY29tPjsgbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnOw0KPiBs
aW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7IFN1enVraSBQ
b3Vsb3NlDQo+IDxTdXp1a2kuUG91bG9zZUBhcm0uY29tPjsgUHVuaXQgQWdyYXdhbCA8cHVuaXRh
Z3Jhd2FsQGdtYWlsLmNvbT47DQo+IEFuc2h1bWFuIEtoYW5kdWFsIDxBbnNodW1hbi5LaGFuZHVh
bEBhcm0uY29tPjsgSnVuIFlhbw0KPiA8eWFvanVuODU1ODM2M0BnbWFpbC5jb20+OyBBbGV4IFZh
biBCcnVudCA8YXZhbmJydW50QG52aWRpYS5jb20+Ow0KPiBSb2JpbiBNdXJwaHkgPFJvYmluLk11
cnBoeUBhcm0uY29tPjsgVGhvbWFzIEdsZWl4bmVyDQo+IDx0Z2x4QGxpbnV0cm9uaXguZGU+OyBB
bmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPjsNCj4gamdsaXNzZUByZWRo
YXQuY29tOyBSYWxwaCBDYW1wYmVsbCA8cmNhbXBiZWxsQG52aWRpYS5jb20+Ow0KPiBoZWppYW5l
dEBnbWFpbC5jb207IEthbHkgWGluIChBcm0gVGVjaG5vbG9neSBDaGluYSkNCj4gPEthbHkuWGlu
QGFybS5jb20+OyBKdXN0aW4gSGUgKEFybSBUZWNobm9sb2d5IENoaW5hKQ0KPiA8SnVzdGluLkhl
QGFybS5jb20+DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggdjQgMy8zXSBtbTogZml4IGRvdWJsZSBw
YWdlIGZhdWx0IG9uIGFybTY0IGlmIFBURV9BRg0KPiBpcyBjbGVhcmVkDQo+DQo+IEhpIEppYSwN
Cj4NCj4gVGhhbmsgeW91IGZvciB0aGUgcGF0Y2ghIFlldCBzb21ldGhpbmcgdG8gaW1wcm92ZToN
Cj4NCj4gW2F1dG8gYnVpbGQgdGVzdCBFUlJPUiBvbiBsaW51cy9tYXN0ZXJdDQo+IFtjYW5ub3Qg
YXBwbHkgdG8gdjUuMyBuZXh0LTIwMTkwOTE3XQ0KPiBbaWYgeW91ciBwYXRjaCBpcyBhcHBsaWVk
IHRvIHRoZSB3cm9uZyBnaXQgdHJlZSwgcGxlYXNlIGRyb3AgdXMgYSBub3RlIHRvIGhlbHANCj4g
aW1wcm92ZSB0aGUgc3lzdGVtXQ0KPg0KPiB1cmw6ICAgIGh0dHBzOi8vZ2l0aHViLmNvbS8wZGF5
LWNpL2xpbnV4L2NvbW1pdHMvSmlhLUhlL2ZpeC1kb3VibGUtcGFnZS0NCj4gZmF1bHQtb24tYXJt
NjQvMjAxOTA5MTgtMjIwMDM2DQo+IGNvbmZpZzogYXJtNjQtYWxsbm9jb25maWcgKGF0dGFjaGVk
IGFzIC5jb25maWcpDQo+IGNvbXBpbGVyOiBhYXJjaDY0LWxpbnV4LWdjYyAoR0NDKSA3LjQuMA0K
PiByZXByb2R1Y2U6DQo+ICAgICAgICAgd2dldCBodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVu
dC5jb20vaW50ZWwvbGtwLQ0KPiB0ZXN0cy9tYXN0ZXIvc2Jpbi9tYWtlLmNyb3NzIC1PIH4vYmlu
L21ha2UuY3Jvc3MNCj4gICAgICAgICBjaG1vZCAreCB+L2Jpbi9tYWtlLmNyb3NzDQo+ICAgICAg
ICAgIyBzYXZlIHRoZSBhdHRhY2hlZCAuY29uZmlnIHRvIGxpbnV4IGJ1aWxkIHRyZWUNCj4gICAg
ICAgICBHQ0NfVkVSU0lPTj03LjQuMCBtYWtlLmNyb3NzIEFSQ0g9YXJtNjQNCj4NCj4gSWYgeW91
IGZpeCB0aGUgaXNzdWUsIGtpbmRseSBhZGQgZm9sbG93aW5nIHRhZw0KPiBSZXBvcnRlZC1ieTog
a2J1aWxkIHRlc3Qgcm9ib3QgPGxrcEBpbnRlbC5jb20+DQo+DQo+IEFsbCBlcnJvcnMgKG5ldyBv
bmVzIHByZWZpeGVkIGJ5ID4+KToNCj4NCj4gICAgbW0vbWVtb3J5Lm86IEluIGZ1bmN0aW9uIGB3
cF9wYWdlX2NvcHknOg0KPiA+PiBtZW1vcnkuYzooLnRleHQrMHg4ZmMpOiB1bmRlZmluZWQgcmVm
ZXJlbmNlIHRvIGBjcHVfaGFzX2h3X2FmJw0KPiAgICBtZW1vcnkuYzooLnRleHQrMHg4ZmMpOiBy
ZWxvY2F0aW9uIHRydW5jYXRlZCB0byBmaXQ6IFJfQUFSQ0g2NF9DQUxMMjYNCj4gYWdhaW5zdCB1
bmRlZmluZWQgc3ltYm9sIGBjcHVfaGFzX2h3X2FmJw0KPg0KQWgsIEkgc2hvdWxkIGFkZCBhIHN0
dWIgZm9yIENPTkZJR19BUk02NF9IV19BRkRCTSBpcyAnTicgb24gYXJtNjQgYXJjaA0KV2lsbCBm
aXggaXQgYXNhcA0KDQotLQ0KQ2hlZXJzLA0KSnVzdGluIChKaWEgSGUpDQoNCg0KPiAwLURBWSBr
ZXJuZWwgdGVzdCBpbmZyYXN0cnVjdHVyZSAgICAgICAgICAgICAgICBPcGVuIFNvdXJjZSBUZWNo
bm9sb2d5IENlbnRlcg0KPiBodHRwczovL2xpc3RzLjAxLm9yZy9waXBlcm1haWwva2J1aWxkLWFs
bCAgICAgICAgICAgICAgICAgICBJbnRlbCBDb3Jwb3JhdGlvbg0KSU1QT1JUQU5UIE5PVElDRTog
VGhlIGNvbnRlbnRzIG9mIHRoaXMgZW1haWwgYW5kIGFueSBhdHRhY2htZW50cyBhcmUgY29uZmlk
ZW50aWFsIGFuZCBtYXkgYWxzbyBiZSBwcml2aWxlZ2VkLiBJZiB5b3UgYXJlIG5vdCB0aGUgaW50
ZW5kZWQgcmVjaXBpZW50LCBwbGVhc2Ugbm90aWZ5IHRoZSBzZW5kZXIgaW1tZWRpYXRlbHkgYW5k
IGRvIG5vdCBkaXNjbG9zZSB0aGUgY29udGVudHMgdG8gYW55IG90aGVyIHBlcnNvbiwgdXNlIGl0
IGZvciBhbnkgcHVycG9zZSwgb3Igc3RvcmUgb3IgY29weSB0aGUgaW5mb3JtYXRpb24gaW4gYW55
IG1lZGl1bS4gVGhhbmsgeW91Lg0K

