Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46429C3A59E
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FBF2087E
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 01:19:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="9qAFlWvE";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="hnGOrCvo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FBF2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81AFE6B0003; Wed,  4 Sep 2019 21:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5816B0005; Wed,  4 Sep 2019 21:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61E526B0006; Wed,  4 Sep 2019 21:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0045.hostedemail.com [216.40.44.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEE56B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:19:22 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9B45C55FA9
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:19:21 +0000 (UTC)
X-FDA: 75899108922.01.blood89_3458c08991116
X-HE-Tag: blood89_3458c08991116
X-Filterd-Recvd-Size: 16512
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140043.outbound.protection.outlook.com [40.107.14.43])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:19:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qRv5iRWMo6NdtzyoUxmxCfLfIdVvXJnnIZ8IzP9KfS8=;
 b=9qAFlWvE4wovigxLqGgrooExaikY8FbEVivrbx/oZBefzqiFwlg8mY1Dq3ZBViu6gf+uC6v4NdCsJV2J2aNURLli/NAd6YClae+kCTm+bY0K1oNb3pfH2Sdw4fHX+3qMV3uFBxFkU1L7/9mUq+CFgX7h5mhzDV+i/KOAQVUbLec=
Received: from DB7PR08CA0002.eurprd08.prod.outlook.com (2603:10a6:5:16::15) by
 VI1PR0801MB1631.eurprd08.prod.outlook.com (2603:10a6:800:5c::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2241.14; Thu, 5 Sep
 2019 01:19:13 +0000
Received: from VE1EUR03FT033.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e09::206) by DB7PR08CA0002.outlook.office365.com
 (2603:10a6:5:16::15) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2241.13 via Frontend
 Transport; Thu, 5 Sep 2019 01:19:13 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=temperror action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 VE1EUR03FT033.mail.protection.outlook.com (10.152.18.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.14 via Frontend Transport; Thu, 5 Sep 2019 01:19:11 +0000
Received: ("Tessian outbound ea3fc1501f20:v27"); Thu, 05 Sep 2019 01:18:59 +0000
X-CR-MTA-TID: 64aa7808
Received: from f2c9e5532d7a.3 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.9.51])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id A525ADCD-334B-4995-98C9-2B09C79EB91B.1;
	Thu, 05 Sep 2019 01:18:54 +0000
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-ve1eur03lp2051.outbound.protection.outlook.com [104.47.9.51])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id f2c9e5532d7a.3
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384);
    Thu, 05 Sep 2019 01:18:54 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=WdcGe9Mz5htquZ1ZUxkEfsJZEZFPMiz4NWB6dSpTRgQAVTVM0GfVgcYgLLflsJXxraliqX+7S7ipdNqnJ8Ybew1Bmn9Ui5QbFTfyarUQXCIvizt42Wxz9H9/Khj2FFQ46a9i2drxD4MC+xXq8AhZ7AUo2zDbV63xlrgXr6jOSgPMApXjiry3vMp/Hx9gU9b/Ahoe912uYLOVJkguME0L8KYIEU9tuekjZnGFrPTmRTd7fsGoFL6nEOcHDVMgB0vCGGNQinUDs4jgH6dtLRtP9+a1609V6HAq3+mdEYzz4n3sJyMMiY3Xbvd8DFrhhDXltmxd6vU6lpaVKSRMdj4sUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AAWwzNQdUKCwWqrJomOl5fJu5gJEdK3imhPddNPMG20=;
 b=hyonaRYA9ZhruyHdcsIMEX8O6LFwW9bfom1JMKNhmAZmQt0U7Jx6IUTcOlNU3u/CqlfI5EbPrl8SudPBRTFm8fJICqYLQ48pS2H2epFE2sMbG1yhjPumUb//W/1/QWJgnVuqMq+s8m841KxTGuOmUiHd1/X0rVQlGkxzGhd12QqEf9tRZ3Kc9OsEuTeBYiqJBL0GEF4sEo15SPcwKZzaiTuH4s9h2j4PONApA20CG84ldyAfSQMLns/lWD9UV/SfnNuVCgUznXR35n5WooYyD7jWA6mYzPrEJ8kvhR+aE22HWdLO9OSEf+GaF6PKwbCKCrc1ZQUxJOesSXx2EHsz/Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AAWwzNQdUKCwWqrJomOl5fJu5gJEdK3imhPddNPMG20=;
 b=hnGOrCvoX5UF7H0gvdlHRszHElbRyeEygI+0s6tpM51JOpFFBRg/rS4ajEzR8Mr6EMf7PH7brecs9dJl/jo1UJ8Y5qugiFMgsjPkAMIhqvYwMALMLQTu2dPV/OUBLLgaZ04MCmzjpQLsvu6keWdhErJ9UlyBtpsK12n4jzMqfuQ=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB2988.eurprd08.prod.outlook.com (52.134.107.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.19; Thu, 5 Sep 2019 01:18:52 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2220.022; Thu, 5 Sep 2019
 01:18:51 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>, Anshuman Khandual
	<Anshuman.Khandual@arm.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Peter
 Zijlstra <peterz@infradead.org>, Dave Airlie <airlied@redhat.com>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Thomas Hellstrom
	<thellstrom@vmware.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm
	<linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Topic: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Index: AQHVYrxRC4qr3uPmLUaMEJjscnv5A6ca2YiAgAC5PYCAALdVwA==
Date: Thu, 5 Sep 2019 01:18:51 +0000
Message-ID:
 <DB7PR08MB3082ED2077384FD8F962B3BEF7BB0@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190904005831.153934-1-justin.he@arm.com>
 <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
 <CAHkRjk6cQTu7N+UanTspWm_LyABRhfPHQn1+PPdaHYrTC3PtfQ@mail.gmail.com>
In-Reply-To:
 <CAHkRjk6cQTu7N+UanTspWm_LyABRhfPHQn1+PPdaHYrTC3PtfQ@mail.gmail.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: d00e990f-ac4e-405e-bd48-2b7069821373.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: ff8783d4-142a-4ea1-d406-08d7319f0f02
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB7PR08MB2988;
X-MS-TrafficTypeDiagnostic: DB7PR08MB2988:|DB7PR08MB2988:|VI1PR0801MB1631:
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<VI1PR0801MB163118856450D48D88B6169DF7BB0@VI1PR0801MB1631.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:2089;OLM:2089;
x-forefront-prvs: 015114592F
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(366004)(346002)(136003)(396003)(376002)(199004)(189003)(13464003)(256004)(14444005)(6116002)(5660300002)(305945005)(7736002)(33656002)(74316002)(66066001)(52536014)(561944003)(76116006)(66946007)(66476007)(186003)(6506007)(26005)(3846002)(316002)(66556008)(6636002)(99286004)(76176011)(2906002)(7696005)(66446008)(229853002)(8936002)(53546011)(64756008)(55236004)(102836004)(54906003)(110136005)(8676002)(478600001)(71200400001)(14454004)(486006)(446003)(7416002)(11346002)(476003)(81156014)(81166006)(71190400001)(6436002)(66574012)(25786009)(6246003)(53936002)(86362001)(9686003)(4326008)(55016002);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB2988;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 yypfb8BCRAeo13ZZZrhB9iuw7WZ/HoQ2ZXhxNUtLXLJ4e4vCR73Ws+JpAcHuNbE3dz4CJbb4a1N8byxxlJw1UpyrgM2lIuRuRfaFcY+BMw4e5x81kQGO5osFIKakuYXW0QDdaGW5f/iSwAU03FpN/VftvZrFCS8TxOG9jtKY6BPcG+2d2xG4F8KYo2ltkIR9JIe4icE22BKI9kCLJV1p7dmQhe6ls8wOJ2l6MLS9feOVDhYnbMsvyp2+zqQavn0N3+BYtE+Lg//S2t+sqPwewCyMNgoIBCETHfc5cHKIqAM88iOxlsTnJWGx5koFugXS6XNf2esfNAABwjhfTun6KyNWU0p4GKJ/9Jow8+72ttTT/YCtNxGPy2Z79n/+vWcx/J4m9a9/bKlmaJUKUdClM6zmojyGXoLEDJPua2HDSY4=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB2988
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 VE1EUR03FT033.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(39860400002)(136003)(376002)(2980300002)(13464003)(189003)(199004)(40434004)(47776003)(76130400001)(9686003)(66066001)(33656002)(356004)(70586007)(66574012)(50466002)(70206006)(486006)(5660300002)(52536014)(11346002)(476003)(126002)(446003)(5024004)(336012)(478600001)(14454004)(14444005)(186003)(26826003)(436003)(63350400001)(63370400001)(55016002)(74316002)(36906005)(8676002)(110136005)(6116002)(316002)(81156014)(7736002)(53546011)(2486003)(23676004)(305945005)(81166006)(7696005)(6506007)(107886003)(8936002)(3846002)(102836004)(6246003)(54906003)(76176011)(86362001)(2906002)(99286004)(22756006)(561944003)(26005)(4326008)(6636002)(25786009)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR0801MB1631;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;MX:1;A:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	7fdb4572-8493-4a59-a5f0-08d7319f0338
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(710020)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR0801MB1631;
X-Forefront-PRVS: 015114592F
X-Microsoft-Antispam-Message-Info:
	rkwnBeVRXGYvVGuhJMJSf0H/ULKJbg8OvYmCHInTzBiziy/WMuPGFjT6uh1L0JjEhF9/T1wsQ0Na7SJmt6VQKRd0BmKshC/0lHRaHlM3MWIv2YXqD7OnmZYhoZOc2H39rT36lzfmfeK/x4pfgU5ADkbKEZv/ND6eSD9I/051+tNJM7NnJWayJvr4dRKXWUwW2+KuuFAt9nVGlIFCLJuPtn2FFXifXx/IRxxWJQKWGkMjc9zzSd0fZUn97JdvqmZDqph2MdBW+864pYNkpzPH58crG1mYoeWLbY8PLjGqwrZkLBPUDIece0+PfVK7S62olgH3AaADbQSnmUgz7HGz2DEagPAxqMdmk7Ir+kaPvqqRkdS5zOyqMcEhR9/6HSnyBya4jTovbZX4k0LmI7tfa6bqxaWPShE47GxgGU83pr4=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Sep 2019 01:19:11.5607
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: ff8783d4-142a-4ea1-d406-08d7319f0f02
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR0801MB1631
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQ2F0YWxpbg0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IENhdGFs
aW4gTWFyaW5hcyA8Y2F0YWxpbi5tYXJpbmFzQGFybS5jb20+DQo+IFNlbnQ6IDIwMTnlubQ55pyI
NOaXpSAyMjoyMg0KPiBUbzogQW5zaHVtYW4gS2hhbmR1YWwgPEFuc2h1bWFuLktoYW5kdWFsQGFy
bS5jb20+DQo+IENjOiBKdXN0aW4gSGUgKEFybSBUZWNobm9sb2d5IENoaW5hKSA8SnVzdGluLkhl
QGFybS5jb20+OyBBbmRyZXcNCj4gTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPjsg
TWF0dGhldyBXaWxjb3gNCj4gPHdpbGx5QGluZnJhZGVhZC5vcmc+OyBKw6lyw7RtZSBHbGlzc2Ug
PGpnbGlzc2VAcmVkaGF0LmNvbT47IFJhbHBoDQo+IENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlh
LmNvbT47IEphc29uIEd1bnRob3JwZSA8amdnQHppZXBlLmNhPjsNCj4gUGV0ZXIgWmlqbHN0cmEg
PHBldGVyekBpbmZyYWRlYWQub3JnPjsgRGF2ZSBBaXJsaWUgPGFpcmxpZWRAcmVkaGF0LmNvbT47
DQo+IEFuZWVzaCBLdW1hciBLLlYgPGFuZWVzaC5rdW1hckBsaW51eC5pYm0uY29tPjsgVGhvbWFz
IEhlbGxzdHJvbQ0KPiA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPjsgU291cHRpY2sgSm9hcmRlciA8
anJkci5saW51eEBnbWFpbC5jb20+Ow0KPiBsaW51eC1tbSA8bGludXgtbW1Aa3ZhY2sub3JnPjsg
TGludXggS2VybmVsIE1haWxpbmcgTGlzdCA8bGludXgtDQo+IGtlcm5lbEB2Z2VyLmtlcm5lbC5v
cmc+DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIG1tOiBmaXggZG91YmxlIHBhZ2UgZmF1bHQgb24g
YXJtNjQgaWYgUFRFX0FGIGlzDQo+IGNsZWFyZWQNCj4NCj4gT24gV2VkLCA0IFNlcCAyMDE5IGF0
IDA0OjIwLCBBbnNodW1hbiBLaGFuZHVhbA0KPiA8YW5zaHVtYW4ua2hhbmR1YWxAYXJtLmNvbT4g
d3JvdGU6DQo+ID4gT24gMDkvMDQvMjAxOSAwNjoyOCBBTSwgSmlhIEhlIHdyb3RlOg0KPiA+ID4g
QEAgLTIxNTIsMjAgKzIxNTMsMzAgQEAgc3RhdGljIGlubGluZSB2b2lkIGNvd191c2VyX3BhZ2Uo
c3RydWN0DQo+IHBhZ2UgKmRzdCwgc3RydWN0IHBhZ2UgKnNyYywgdW5zaWduZWQgbG8NCj4gPiA+
ICAgICAgICAqLw0KPiA+ID4gICAgICAgaWYgKHVubGlrZWx5KCFzcmMpKSB7DQo+ID4gPiAgICAg
ICAgICAgICAgIHZvaWQgKmthZGRyID0ga21hcF9hdG9taWMoZHN0KTsNCj4gPiA+IC0gICAgICAg
ICAgICAgdm9pZCBfX3VzZXIgKnVhZGRyID0gKHZvaWQgX191c2VyICopKHZhICYgUEFHRV9NQVNL
KTsNCj4gPiA+ICsgICAgICAgICAgICAgdm9pZCBfX3VzZXIgKnVhZGRyID0gKHZvaWQgX191c2Vy
ICopKHZtZi0+YWRkcmVzcyAmDQo+IFBBR0VfTUFTSyk7DQo+ID4gPiArICAgICAgICAgICAgIHB0
ZV90IGVudHJ5Ow0KPiA+ID4NCj4gPiA+ICAgICAgICAgICAgICAgLyoNCj4gPiA+ICAgICAgICAg
ICAgICAgICogVGhpcyByZWFsbHkgc2hvdWxkbid0IGZhaWwsIGJlY2F1c2UgdGhlIHBhZ2UgaXMg
dGhlcmUNCj4gPiA+ICAgICAgICAgICAgICAgICogaW4gdGhlIHBhZ2UgdGFibGVzLiBCdXQgaXQg
bWlnaHQganVzdCBiZSB1bnJlYWRhYmxlLA0KPiA+ID4gICAgICAgICAgICAgICAgKiBpbiB3aGlj
aCBjYXNlIHdlIGp1c3QgZ2l2ZSB1cCBhbmQgZmlsbCB0aGUgcmVzdWx0IHdpdGgNCj4gPiA+IC0g
ICAgICAgICAgICAgICogemVyb2VzLg0KPiA+ID4gKyAgICAgICAgICAgICAgKiB6ZXJvZXMuIElm
IFBURV9BRiBpcyBjbGVhcmVkIG9uIGFybTY0LCBpdCBtaWdodA0KPiA+ID4gKyAgICAgICAgICAg
ICAgKiBjYXVzZSBkb3VibGUgcGFnZSBmYXVsdCBoZXJlLiBzbyBtYWtlcyBwdGUgeW91bmcgaGVy
ZQ0KPiA+ID4gICAgICAgICAgICAgICAgKi8NCj4gPiA+ICsgICAgICAgICAgICAgaWYgKCFwdGVf
eW91bmcodm1mLT5vcmlnX3B0ZSkpIHsNCj4gPiA+ICsgICAgICAgICAgICAgICAgICAgICBlbnRy
eSA9IHB0ZV9ta3lvdW5nKHZtZi0+b3JpZ19wdGUpOw0KPiA+ID4gKyAgICAgICAgICAgICAgICAg
ICAgIGlmIChwdGVwX3NldF9hY2Nlc3NfZmxhZ3Modm1mLT52bWEsIHZtZi0+YWRkcmVzcywNCj4g
PiA+ICsgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZtZi0+cHRlLCBlbnRyeSwgdm1mLT5m
bGFncyAmIEZBVUxUX0ZMQUdfV1JJVEUpKQ0KPiA+ID4gKyAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgdXBkYXRlX21tdV9jYWNoZSh2bWYtPnZtYSwgdm1mLT5hZGRyZXNzLA0KPiA+ID4gKyAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZtZi0+cHRlKTsNCj4g
PiA+ICsgICAgICAgICAgICAgfQ0KPiA+ID4gKw0KPiA+ID4gICAgICAgICAgICAgICBpZiAoX19j
b3B5X2Zyb21fdXNlcl9pbmF0b21pYyhrYWRkciwgdWFkZHIsIFBBR0VfU0laRSkpDQo+ID4NCj4g
PiBTaG91bGQgbm90IHBhZ2UgZmF1bHQgYmUgZGlzYWJsZWQgd2hlbiBkb2luZyB0aGlzID8NCj4N
Cj4gUGFnZSBmYXVsdHMgYXJlIGFscmVhZHkgZGlzYWJsZWQgYnkgdGhlIGttYXBfYXRvbWljKCku
IEJ1dCB0aGF0IG9ubHkNCj4gbWVhbnMgdGhhdCB5b3UgZG9uJ3QgZGVhZGxvY2sgdHJ5aW5nIHRv
IHRha2UgdGhlIG1tYXBfc2VtIGFnYWluLg0KPg0KPiA+IElkZWFsbHkgaXQgc2hvdWxkDQo+ID4g
aGF2ZSBhbHNvIGNhbGxlZCBhY2Nlc3Nfb2soKSBvbiB0aGUgdXNlciBhZGRyZXNzIHJhbmdlIGZp
cnN0Lg0KPg0KPiBOb3QgbmVjZXNzYXJ5LCB3ZSd2ZSBhbHJlYWR5IGdvdCBhIHZtYSBhbmQgdGhl
IGFjY2VzcyB0byB0aGUgdm1hIGNoZWNrZWQuDQo+DQo+ID4gVGhlIHBvaW50DQo+ID4gaXMgdGhh
dCB0aGUgY2FsbGVyIG9mIF9fY29weV9mcm9tX3VzZXJfaW5hdG9taWMoKSBtdXN0IG1ha2Ugc3Vy
ZSB0aGF0DQo+ID4gdGhlcmUgY2Fubm90IGJlIGFueSBwYWdlIGZhdWx0IHdoaWxlIGRvaW5nIHRo
ZSBhY3R1YWwgY29weS4NCj4NCj4gV2hlbiB5b3UgY29weSBmcm9tIGEgdXNlciBhZGRyZXNzLCBp
biBnZW5lcmFsIHRoYXQncyBub3QgZ3VhcmFudGVlZCwNCj4gbW9yZSBvZiBhIGJlc3QgZWZmb3J0
Lg0KPg0KPiA+IEJ1dCBhbHNvIGl0DQo+ID4gc2hvdWxkIGJlIGRvbmUgaW4gZ2VuZXJpYyB3YXks
IHNvbWV0aGluZyBsaWtlIGluIGFjY2Vzc19vaygpLiBUaGUgY3VycmVudA0KPiA+IHByb3Bvc2Fs
IGhlcmUgc2VlbXMgdmVyeSBzcGVjaWZpYyB0byBhcm02NCBjYXNlLg0KPg0KPiBUaGUgY29tbWl0
IGxvZyBkaWRuJ3QgZXhwbGFpbiB0aGUgcHJvYmxlbSBwcm9wZXJseS4gT24gYXJtNjQgd2l0aG91
dA0KPiBoYXJkd2FyZSBBY2Nlc3MgRmxhZywgY29weWluZyBmcm9tIHVzZXIgd2lsbCBmYWlsIGJl
Y2F1c2UgdGhlIHB0ZSBpcw0KPiBvbGQgYW5kIGNhbm5vdCBiZSBtYXJrZWQgeW91bmcuIFNvIHdl
IGFsd2F5cyBlbmQgdXAgd2l0aCB6ZXJvZWQgcGFnZQ0KPiBhZnRlciBmb3JrKCkgKyBDb1cgZm9y
IHBmbiBtYXBwaW5ncy4NCj4NCg0KT2sgSSB3aWxsIHVwZGF0ZSBpdCwgdGhhbmtzDQoNCi0tDQpD
aGVlcnMsDQpKdXN0aW4gKEppYSBIZSkNCg0KDQo+IC0tDQo+IENhdGFsaW4NCklNUE9SVEFOVCBO
T1RJQ0U6IFRoZSBjb250ZW50cyBvZiB0aGlzIGVtYWlsIGFuZCBhbnkgYXR0YWNobWVudHMgYXJl
IGNvbmZpZGVudGlhbCBhbmQgbWF5IGFsc28gYmUgcHJpdmlsZWdlZC4gSWYgeW91IGFyZSBub3Qg
dGhlIGludGVuZGVkIHJlY2lwaWVudCwgcGxlYXNlIG5vdGlmeSB0aGUgc2VuZGVyIGltbWVkaWF0
ZWx5IGFuZCBkbyBub3QgZGlzY2xvc2UgdGhlIGNvbnRlbnRzIHRvIGFueSBvdGhlciBwZXJzb24s
IHVzZSBpdCBmb3IgYW55IHB1cnBvc2UsIG9yIHN0b3JlIG9yIGNvcHkgdGhlIGluZm9ybWF0aW9u
IGluIGFueSBtZWRpdW0uIFRoYW5rIHlvdS4NCg==

