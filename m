Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99D75C3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CB6220870
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:42:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="V/ZSJwbQ";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="1qDsaxNl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB6220870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC6B56B0007; Wed,  4 Sep 2019 01:42:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C50096B000E; Wed,  4 Sep 2019 01:42:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEFFA6B0010; Wed,  4 Sep 2019 01:42:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0198.hostedemail.com [216.40.44.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CCB66B0007
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:42:22 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 153F1180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:42:22 +0000 (UTC)
X-FDA: 75896142924.02.owner90_6b85717d6e80a
X-HE-Tag: owner90_6b85717d6e80a
X-Filterd-Recvd-Size: 17339
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80089.outbound.protection.outlook.com [40.107.8.89])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:42:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PcHpxBoxgum5vzYBvGq6ygAPe9+IUv0/32qq07XzVEA=;
 b=V/ZSJwbQQy7Cnrd1xfsJTNAyQKQn5UW/ekrLlAWYIscviHVK8Eg0BnTkGbWXA5U54PRd8EHkDYSRnEfCOvMvgiazWCtRCm/gm38otEPOimLA/XqoZ5IoTxT07j2Wo7zxDn8pWIAMDja9wToNIB+A7GZeFHYu2ejCzJnzkW5eN4s=
Received: from VE1PR08CA0009.eurprd08.prod.outlook.com (2603:10a6:803:104::22)
 by VI1PR08MB4079.eurprd08.prod.outlook.com (2603:10a6:803:e5::29) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2220.18; Wed, 4 Sep
 2019 05:42:14 +0000
Received: from AM5EUR03FT017.eop-EUR03.prod.protection.outlook.com
 (2a01:111:f400:7e08::201) by VE1PR08CA0009.outlook.office365.com
 (2603:10a6:803:104::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.2241.13 via Frontend
 Transport; Wed, 4 Sep 2019 05:42:14 +0000
Authentication-Results: spf=temperror (sender IP is 63.35.35.123)
 smtp.mailfrom=arm.com; kvack.org; dkim=pass (signature was verified)
 header.d=armh.onmicrosoft.com;kvack.org; dmarc=temperror action=none
 header.from=arm.com;
Received-SPF: TempError (protection.outlook.com: error in processing during
 lookup of arm.com: DNS Timeout)
Received: from 64aa7808-outbound-1.mta.getcheckrecipient.com (63.35.35.123) by
 AM5EUR03FT017.mail.protection.outlook.com (10.152.16.89) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.16 via Frontend Transport; Wed, 4 Sep 2019 05:42:12 +0000
Received: ("Tessian outbound 108f768cde3d:v27"); Wed, 04 Sep 2019 05:42:04 +0000
X-CR-MTA-TID: 64aa7808
Received: from 0a8c337c2a1a.2 (ip-172-16-0-2.eu-west-1.compute.internal [104.47.6.57])
	by 64aa7808-outbound-1.mta.getcheckrecipient.com id 8678AA65-75F7-4814-BE81-BEB148ED2C97.1;
	Wed, 04 Sep 2019 05:41:59 +0000
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-ve1eur02lp2057.outbound.protection.outlook.com [104.47.6.57])
    by 64aa7808-outbound-1.mta.getcheckrecipient.com with ESMTPS id 0a8c337c2a1a.2
    (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384);
    Wed, 04 Sep 2019 05:41:59 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=m/jeGrp9jc07awO73XnjNvujn7EIBDgMoc2vWZRBEjU5LCKPl7fBOda2+Nn3Qj6hAn33xQNA2U5cQUDD2dlnJ4D1o2KoA+ja6HqqnwXoB1KjWoWiGf8ax0/NBG/6G40KVXXNX3FlcgxFPMkpB+6pVpO6faiMqrodYkx+f84gqu1hHoa7P/Au9dLeOp8Uh/Fd+CFPUsEGjfgoUkVyKoo/Hf6cIObXDTDbNrcltpnAi1kpPSaWyavHKbIxjCAR+cI9AjGWFqIbLRVoqpWPFe2cwczt6IKslyDAl0Hf+eHd+XwE+XTejW4jETPNo4LDMJFAylI+zbv2QDZGXu1M004dng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5EAMgcVvGrZdnw5Q9/W0MG+rQ3MShKMWlQXPV9zEzgI=;
 b=TVGVnw2OfDqTOg07AwQ+z/dG1jK2oqHUXguUz87ZdzfhGtcutOK3ZjT5tHGVfspJDSbZy7hyAMhz8mmsaS8kJVA+gRIkG29SdZJMpzHS6XjW4XipXjxFcqc0+qngWCORah18qMyePmOH4G0JWS+aJ4vjFOa5jHyN9UnQUA21FEvGdjQfejseSpW04JatHuJrp/CPRu1LXl2EW5GMG0DmrK86vq24NCH/wX9ia1XVyYOa4xTuaqm4XqyZJ1T18cgb68ECErxuj+VoUbfbrNv020v8wT14fnYEoGn1aiyvIh4ADAIPyE8dZQ3Zld/gkWg9i1C8qXtXisrH6/Zc9TT9TA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=arm.com; dmarc=pass action=none header.from=arm.com; dkim=pass
 header.d=arm.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5EAMgcVvGrZdnw5Q9/W0MG+rQ3MShKMWlQXPV9zEzgI=;
 b=1qDsaxNlojvpJUH0l94WBZGTxsQxfVUEV1J/9ANtWnQS9vGX3W5bRktgXbr1SjyiAB9dAcSgQSJ6h4lyiuL6gX0Yu8SKw6+kdjSmkV1lffMbJbQvlGfxwp81Ovqbrwi1AnzUwPDRUuLu+3Fy1jP91ZY6IsiSicoOTatzAtt85tQ=
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com (52.134.110.24) by
 DB7PR08MB3097.eurprd08.prod.outlook.com (52.134.110.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.20; Wed, 4 Sep 2019 05:41:56 +0000
Received: from DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734]) by DB7PR08MB3082.eurprd08.prod.outlook.com
 ([fe80::2121:ca3a:3068:734%3]) with mapi id 15.20.2220.022; Wed, 4 Sep 2019
 05:41:56 +0000
From: "Justin He (Arm Technology China)" <Justin.He@arm.com>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra
	<peterz@infradead.org>, Dave Airlie <airlied@redhat.com>, Aneesh Kumar K.V
	<aneesh.kumar@linux.ibm.com>, Thomas Hellstrom <thellstrom@vmware.com>,
	Souptick Joarder <jrdr.linux@gmail.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Topic: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
Thread-Index: AQHVYrxRC4qr3uPmLUaMEJjscnv5A6ca2YiAgAAV/4CAAAK4AIAAC4iAgAADUrA=
Date: Wed, 4 Sep 2019 05:41:56 +0000
Message-ID:
 <DB7PR08MB30823169136CD395C076EF65F7B80@DB7PR08MB3082.eurprd08.prod.outlook.com>
References: <20190904005831.153934-1-justin.he@arm.com>
 <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
 <961889b3-ef08-2ee9-e3a1-6aba003f47c1@arm.com>
 <DB7PR08MB3082E820B4871F1D1552BF34F7B80@DB7PR08MB3082.eurprd08.prod.outlook.com>
 <1b7aa74b-c6a7-0406-2802-8cf639e35bf0@arm.com>
In-Reply-To: <1b7aa74b-c6a7-0406-2802-8cf639e35bf0@arm.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ts-tracking-id: 461f063d-d691-4666-b6a1-752b139e453a.1
x-checkrecipientchecked: true
Authentication-Results-Original: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
x-originating-ip: [113.29.88.7]
x-ms-publictraffictype: Email
X-MS-Office365-Filtering-Correlation-Id: a3e169d7-e52d-45b3-d726-08d730faa2c2
X-MS-Office365-Filtering-HT: Tenant
X-Microsoft-Antispam-Untrusted:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB7PR08MB3097;
X-MS-TrafficTypeDiagnostic: DB7PR08MB3097:|DB7PR08MB3097:|VI1PR08MB4079:
x-ms-exchange-transport-forked: True
X-Microsoft-Antispam-PRVS:
	<VI1PR08MB407986754C84BA06BBAAD392F7B80@VI1PR08MB4079.eurprd08.prod.outlook.com>
x-checkrecipientrouted: true
x-ms-oob-tlc-oobclassifiers: OLM:9508;OLM:9508;
x-forefront-prvs: 0150F3F97D
X-Forefront-Antispam-Report-Untrusted:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(376002)(39860400002)(366004)(396003)(136003)(189003)(199004)(51914003)(13464003)(66066001)(5660300002)(76116006)(66946007)(66446008)(66476007)(66556008)(64756008)(66574012)(33656002)(71200400001)(71190400001)(52536014)(25786009)(7696005)(81156014)(76176011)(6246003)(53936002)(229853002)(9686003)(55016002)(102836004)(55236004)(6506007)(53546011)(8936002)(86362001)(2501003)(3846002)(6116002)(2201001)(486006)(446003)(26005)(8676002)(186003)(14444005)(81166006)(6436002)(11346002)(14454004)(7416002)(476003)(256004)(478600001)(561944003)(99286004)(110136005)(2906002)(7736002)(74316002)(305945005)(316002)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB3097;H:DB7PR08MB3082.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info-Original:
 1n0MBrvA9rirut5rYIuE27eMfq04L/BJVdAxZluHYTTM9bKZ62l+u1ul1o7skkOCxwifIv6T7qXMJxNIfcwdwlatcnNBayyrP1R3M0bkYawPb1rt4tXApHhJ24Wra1LH4Nvf93amXsYXbB4bF3GF2Y9QlOJe0i00CbU1G3wXaKkPD8Eux3db76MiP7SvtrXIs8OM5g5tChA27KAl8H5+wQmH/uXliDU4N+rZmXwJ6S1SogR1YrJzgRGDaOiFyQ5JTVaFmZ8+0OXXljaKFMnaYHQOQ4MkMsTQkloGpzxQTE15JedJU3ViVS0BcZ/OuxgTYk6QjblbR5pPRVNs39L2cAz7NB9UODeS4nv/8DaaG2tzas5SMeqq8dttezdh++LePTloE2p31LHBD9MNYzwAWNfvzl8N8YWMdr8Yr5YlpIE=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3097
Original-Authentication-Results: spf=none (sender IP is )
 smtp.mailfrom=Justin.He@arm.com; 
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 AM5EUR03FT017.eop-EUR03.prod.protection.outlook.com
X-Forefront-Antispam-Report:
	CIP:63.35.35.123;IPV:CAL;SCL:-1;CTRY:IE;EFV:NLI;SFV:NSPM;SFS:(10009020)(4636009)(136003)(376002)(396003)(39860400002)(346002)(2980300002)(199004)(189003)(40434004)(51914003)(13464003)(561944003)(52536014)(33656002)(3846002)(5024004)(70206006)(70586007)(74316002)(7736002)(22756006)(26005)(186003)(47776003)(6116002)(14444005)(5660300002)(66066001)(305945005)(7696005)(23676004)(316002)(36906005)(53546011)(6506007)(99286004)(76176011)(336012)(8936002)(2486003)(2906002)(66574012)(110136005)(478600001)(102836004)(8676002)(55016002)(476003)(81156014)(81166006)(356004)(486006)(11346002)(446003)(63370400001)(63350400001)(436003)(76130400001)(50466002)(86362001)(6246003)(25786009)(126002)(2501003)(14454004)(26826003)(9686003)(229853002)(2201001)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB4079;H:64aa7808-outbound-1.mta.getcheckrecipient.com;FPR:;SPF:TempError;LANG:en;PTR:ec2-63-35-35-123.eu-west-1.compute.amazonaws.com;A:1;MX:1;
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	9fddc4cf-5cbd-4adf-9915-08d730fa9940
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(710020)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR08MB4079;
X-Forefront-PRVS: 0150F3F97D
X-Microsoft-Antispam-Message-Info:
	7l3T0tltHdnjzGw3WgypPKG5MC+Itk7yuaoxTjAGjKNbnYnIxlu08r6NH4cAhd46RDOjUYI7jiuVD95KUsuw375AWnfrGYQh5jGelI/apg3kDKLhF4riHlMHyAejRa/tjjdOJydyZwrwRMZG2pc6aKdC9owo73I9MWii37Q/gg/cylY7TTDS9xDr+IofaCIP8g06Kk9z1n9QjnGZeEp8fwJtxgRaU4i2keN+KpIGA7b4Tp0qjG48Acx8MZtp8whya8Ai7IHGrUF8WmjOm63lBxOAgay1mho8FZwB6SbbPWlU85FEjC4plL7XG1uvlV2agJghlbzhS04c946dS/KKP6WBU3FXpPEiujgQv4hKCT0tSfM/Hqn/+wA+PaThCfyuGGuf7gdpvfWDMAEVjVwShZtxPHZfVFDmYP89l5r5zU0=
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 04 Sep 2019 05:42:12.5718
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: a3e169d7-e52d-45b3-d726-08d730faa2c2
X-MS-Exchange-CrossTenant-Id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=f34e5979-57d9-4aaa-ad4d-b122a662184d;Ip=[63.35.35.123];Helo=[64aa7808-outbound-1.mta.getcheckrecipient.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB4079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQW5zaHVtYW4NCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBbnNo
dW1hbiBLaGFuZHVhbCA8YW5zaHVtYW4ua2hhbmR1YWxAYXJtLmNvbT4NCj4gU2VudDogMjAxOeW5
tDnmnIg05pelIDEzOjI5DQo+IFRvOiBKdXN0aW4gSGUgKEFybSBUZWNobm9sb2d5IENoaW5hKSA8
SnVzdGluLkhlQGFybS5jb20+OyBBbmRyZXcNCj4gTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRp
b24ub3JnPjsgTWF0dGhldyBXaWxjb3gNCj4gPHdpbGx5QGluZnJhZGVhZC5vcmc+OyBKw6lyw7Rt
ZSBHbGlzc2UgPGpnbGlzc2VAcmVkaGF0LmNvbT47IFJhbHBoDQo+IENhbXBiZWxsIDxyY2FtcGJl
bGxAbnZpZGlhLmNvbT47IEphc29uIEd1bnRob3JwZSA8amdnQHppZXBlLmNhPjsNCj4gUGV0ZXIg
WmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPjsgRGF2ZSBBaXJsaWUgPGFpcmxpZWRAcmVk
aGF0LmNvbT47DQo+IEFuZWVzaCBLdW1hciBLLlYgPGFuZWVzaC5rdW1hckBsaW51eC5pYm0uY29t
PjsgVGhvbWFzIEhlbGxzdHJvbQ0KPiA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPjsgU291cHRpY2sg
Sm9hcmRlciA8anJkci5saW51eEBnbWFpbC5jb20+Ow0KPiBsaW51eC1tbUBrdmFjay5vcmc7IGxp
bnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSF0gbW06IGZp
eCBkb3VibGUgcGFnZSBmYXVsdCBvbiBhcm02NCBpZiBQVEVfQUYgaXMNCj4gY2xlYXJlZA0KPg0K
Pg0KPg0KPiBPbiAwOS8wNC8yMDE5IDEwOjI3IEFNLCBKdXN0aW4gSGUgKEFybSBUZWNobm9sb2d5
IENoaW5hKSB3cm90ZToNCj4gPiBIaSBBbnNodW1hbiwgdGhhbmtzIGZvciB0aGUgY29tbWVudHMs
IHNlZSBiZWxvdyBwbGVhc2UNCj4gPg0KPiA+PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0K
PiA+PiBGcm9tOiBBbnNodW1hbiBLaGFuZHVhbCA8YW5zaHVtYW4ua2hhbmR1YWxAYXJtLmNvbT4N
Cj4gPj4gU2VudDogMjAxOeW5tDnmnIg05pelIDEyOjM4DQo+ID4+IFRvOiBKdXN0aW4gSGUgKEFy
bSBUZWNobm9sb2d5IENoaW5hKSA8SnVzdGluLkhlQGFybS5jb20+OyBBbmRyZXcNCj4gPj4gTW9y
dG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPjsgTWF0dGhldyBXaWxjb3gNCj4gPj4gPHdp
bGx5QGluZnJhZGVhZC5vcmc+OyBKw6lyw7RtZSBHbGlzc2UgPGpnbGlzc2VAcmVkaGF0LmNvbT47
IFJhbHBoDQo+ID4+IENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNvbT47IEphc29uIEd1bnRo
b3JwZSA8amdnQHppZXBlLmNhPjsNCj4gPj4gUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRl
YWQub3JnPjsgRGF2ZSBBaXJsaWUgPGFpcmxpZWRAcmVkaGF0LmNvbT47DQo+ID4+IEFuZWVzaCBL
dW1hciBLLlYgPGFuZWVzaC5rdW1hckBsaW51eC5pYm0uY29tPjsgVGhvbWFzIEhlbGxzdHJvbQ0K
PiA+PiA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPjsgU291cHRpY2sgSm9hcmRlciA8anJkci5saW51
eEBnbWFpbC5jb20+Ow0KPiA+PiBsaW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2Vy
Lmtlcm5lbC5vcmcNCj4gPj4gU3ViamVjdDogUmU6IFtQQVRDSF0gbW06IGZpeCBkb3VibGUgcGFn
ZSBmYXVsdCBvbiBhcm02NCBpZiBQVEVfQUYgaXMNCj4gPj4gY2xlYXJlZA0KPiA+Pg0KPiA+Pg0K
PiA+Pg0KPiA+PiBPbiAwOS8wNC8yMDE5IDA4OjQ5IEFNLCBBbnNodW1hbiBLaGFuZHVhbCB3cm90
ZToNCj4gPj4+ICAgICAgICAgICAvKg0KPiA+Pj4gICAgICAgICAgICAqIFRoaXMgcmVhbGx5IHNo
b3VsZG4ndCBmYWlsLCBiZWNhdXNlIHRoZSBwYWdlIGlzIHRoZXJlDQo+ID4+PiAgICAgICAgICAg
ICogaW4gdGhlIHBhZ2UgdGFibGVzLiBCdXQgaXQgbWlnaHQganVzdCBiZSB1bnJlYWRhYmxlLA0K
PiA+Pj4gICAgICAgICAgICAqIGluIHdoaWNoIGNhc2Ugd2UganVzdCBnaXZlIHVwIGFuZCBmaWxs
IHRoZSByZXN1bHQgd2l0aA0KPiA+Pj4gLSAgICAgICAgICAqIHplcm9lcy4NCj4gPj4+ICsgICAg
ICAgICAgKiB6ZXJvZXMuIElmIFBURV9BRiBpcyBjbGVhcmVkIG9uIGFybTY0LCBpdCBtaWdodA0K
PiA+Pj4gKyAgICAgICAgICAqIGNhdXNlIGRvdWJsZSBwYWdlIGZhdWx0IGhlcmUuIHNvIG1ha2Vz
IHB0ZSB5b3VuZyBoZXJlDQo+ID4+PiAgICAgICAgICAgICovDQo+ID4+PiArICAgICAgICAgaWYg
KCFwdGVfeW91bmcodm1mLT5vcmlnX3B0ZSkpIHsNCj4gPj4+ICsgICAgICAgICAgICAgICAgIGVu
dHJ5ID0gcHRlX21reW91bmcodm1mLT5vcmlnX3B0ZSk7DQo+ID4+PiArICAgICAgICAgICAgICAg
ICBpZiAocHRlcF9zZXRfYWNjZXNzX2ZsYWdzKHZtZi0+dm1hLCB2bWYtPmFkZHJlc3MsDQo+ID4+
PiArICAgICAgICAgICAgICAgICAgICAgICAgIHZtZi0+cHRlLCBlbnRyeSwgdm1mLT5mbGFncyAm
DQo+ID4+IEZBVUxUX0ZMQUdfV1JJVEUpKQ0KPiA+Pj4gKyAgICAgICAgICAgICAgICAgICAgICAg
ICB1cGRhdGVfbW11X2NhY2hlKHZtZi0+dm1hLCB2bWYtDQo+ID4+PiBhZGRyZXNzLA0KPiA+Pj4g
KyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdm1mLT5wdGUpOw0KPiA+
Pj4gKyAgICAgICAgIH0NCj4gPj4NCj4gPj4gVGhpcyBsb29rcyBjb3JyZWN0IHdoZXJlIGl0IHVw
ZGF0ZXMgdGhlIHB0ZSBlbnRyeSB3aXRoIFBURV9BRiB3aGljaA0KPiA+PiB3aWxsIHByZXZlbnQg
YSBzdWJzZXF1ZW50IHBhZ2UgZmF1bHQuIEJ1dCBJIHRoaW5rIHdoYXQgd2UgcmVhbGx5IG5lZWQN
Cj4gPj4gaGVyZSBpcyB0byBtYWtlIHN1cmUgJ3VhZGRyJyBpcyBtYXBwZWQgY29ycmVjdGx5IGF0
IHZtYS0+cHRlLiBQcm9iYWJseQ0KPiA+PiBhIGdlbmVyaWMgZnVuY3Rpb24gYXJjaF9tYXBfcHRl
KCkgd2hlbiBkZWZpbmVkIGZvciBhcm02NCBzaG91bGQgY2hlY2sNCj4gPj4gQ1BVIHZlcnNpb24g
YW5kIGVuc3VyZSBjb250aW51YW5jZSBvZiBQVEVfQUYgaWYgcmVxdWlyZWQuIFRoZQ0KPiBjb21t
ZW50DQo+ID4+IGFib3ZlIGFsc28gbmVlZCB0byBiZSB1cGRhdGVkIHNheWluZyBub3Qgb25seSB0
aGUgcGFnZSBzaG91bGQgYmUgdGhlcmUNCj4gPj4gaW4gdGhlIHBhZ2UgdGFibGUsIGl0IG5lZWRz
IHRvIG1hcHBlZCBhcHByb3ByaWF0ZWx5IGFzIHdlbGwuDQo+ID4NCj4gPiBJIGFncmVlIHRoYXQg
YSBnZW5lcmljIGludGVyZmFjZSBoZXJlIGlzIG5lZWRlZCBidXQgbm90IHRoZSBhcmNoX21hcF9w
dGUoKS4NCj4gPiBJbiB0aGlzIGNhc2UsIEkgdGhvdWdodCBhbGwgdGhlIHBnZC9wdWQvcG1kL3B0
ZSBoYWQgYmVlbiBzZXQgY29ycmVjdGx5DQo+IGV4Y2VwdA0KPiA+IGZvciB0aGUgUFRFX0FGIGJp
dC4NCj4gPiBIb3cgYWJvdXQgYXJjaF9od19hY2Nlc3NfZmxhZygpPw0KPg0KPiBTdXJlLCBnbyBh
aGVhZC4gSSBqdXN0IG1lYW50ICdtYXAnIHRvIGluY2x1ZGUgbm90IG9ubHkgdGhlIFBGTiBidXQg
YWxzbw0KPiBhcHByb3ByaWF0ZSBIVyBhdHRyaWJ1dGVzIG5vdCBjYXVzZSBhIHBhZ2UgZmF1bHQu
DQo+DQo+ID4gSWYgbm9uLWFybTY0LCBhcmNoX2h3X2FjY2Vzc19mbGFnKCkgPT0gdHJ1ZQ0KPg0K
PiBUaGUgZnVuY3Rpb24gZG9lcyBub3QgbmVlZCB0byByZXR1cm4gYW55dGhpbmcuIER1bW15IGRl
ZmF1bHQgZGVmaW5pdGlvbg0KPiBpbiBnZW5lcmljIE1NIHdpbGwgZG8gbm90aGluZyB3aGVuIGFy
Y2ggZG9lcyBub3Qgb3ZlcnJpZGUuDQo+DQoNCk9rLCBnb3QgaXQsIHRoYW5rcw0KDQotLQ0KQ2hl
ZXJzLA0KSnVzdGluIChKaWEgSGUpDQoNCg0KDQo+ID4gSWYgYXJtNjQgd2l0aCBoYXJkd2FyZS1t
YW5hZ2VkIGFjY2VzcyBmbGFnIHN1cHBvcnRlZCwgPT0gdHJ1ZQ0KPiA+IGVsc2UgPT0gZmFsc2U/
DQo+DQo+IE9uIGFybTY0IHdpdGggaGFyZHdhcmUtbWFuYWdlZCBhY2Nlc3MgZmxhZyBzdXBwb3J0
ZWQsIGl0IHdpbGwgZG8gbm90aGluZy4NCj4gQnV0IGluIGNhc2UgaXRzIG5vdCBzdXBwb3J0ZWQg
dGhlIGFib3ZlIG1lbnRpb25lZCBwdGUgdXBkYXRlIGFzIGluIHRoZQ0KPiBjdXJyZW50IHByb3Bv
c2FsIG5lZWRzIHRvIGJlIGV4ZWN1dGVkLiBUaGUgZGV0YWlscyBzaG91bGQgaGlkZSBpbiBhcmNo
DQo+IHNwZWNpZmljIG92ZXJyaWRlLg0KSU1QT1JUQU5UIE5PVElDRTogVGhlIGNvbnRlbnRzIG9m
IHRoaXMgZW1haWwgYW5kIGFueSBhdHRhY2htZW50cyBhcmUgY29uZmlkZW50aWFsIGFuZCBtYXkg
YWxzbyBiZSBwcml2aWxlZ2VkLiBJZiB5b3UgYXJlIG5vdCB0aGUgaW50ZW5kZWQgcmVjaXBpZW50
LCBwbGVhc2Ugbm90aWZ5IHRoZSBzZW5kZXIgaW1tZWRpYXRlbHkgYW5kIGRvIG5vdCBkaXNjbG9z
ZSB0aGUgY29udGVudHMgdG8gYW55IG90aGVyIHBlcnNvbiwgdXNlIGl0IGZvciBhbnkgcHVycG9z
ZSwgb3Igc3RvcmUgb3IgY29weSB0aGUgaW5mb3JtYXRpb24gaW4gYW55IG1lZGl1bS4gVGhhbmsg
eW91Lg0K

