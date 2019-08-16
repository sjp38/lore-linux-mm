Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9A38C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F81220665
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:13:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="sZWCpxXG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F81220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108E16B0005; Fri, 16 Aug 2019 13:13:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BAF26B0006; Fri, 16 Aug 2019 13:13:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3A96B0007; Fri, 16 Aug 2019 13:13:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id CA47D6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:13:00 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6E3548248AC6
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:13:00 +0000 (UTC)
X-FDA: 75828936120.22.farm66_5457d6ee08e31
X-HE-Tag: farm66_5457d6ee08e31
X-Filterd-Recvd-Size: 7042
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10040.outbound.protection.outlook.com [40.107.1.40])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:12:59 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dUm5k2T6G7ABit7aXHA8OvHTGVe+8lk+OHdA+Mbd2vak4i8r23YCsc8g+tudJhlLvTrdHG3D92smCGmwsE2/Ul7nk/FxpDY1walMmemKiw+BzS4/vpnWwIYa40joopmeHGePnLE2zi2kc6WEnAPBXbgdgcZiGKQVTSJeR3izl5M06loxVjWsXAXoTU1VASGK0qSN4UygKfyfBK53XOJqUsV0zUM7wcY/8owdEujcb+m3U9XOKEt9kiu117x6q8eg5YqkF6eZfSITEH4mJm1YsnZaLNzWPSHBR0e3h4A2RPG+a4tw9yLE8Jt9WoqJ4rVqQG/nnwAU5WGN7zQ1IQKfVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9dQ3ke8uff1NAjFFAPHyYOpvImMQUrO5vor3sThz4Cw=;
 b=HuGn/H2yec9o3yeCA5+NdVgrd9ZF5qAgOBpe+fF4pt095JSLocq/+Z0uLmGuAwS/hV3OyGoFQrhwhQXT5C7fz9ks2gOxZNd167bNtMp92F6YsQRDilGKqQytRRjmwg9tXj4+mP7Evz58MQeQ7ACQq7m0zHvvoMKa48DecUfCsSksbkNInsesCmO/r1nkJ5xDUjoamP1vB/ae6mYQzicF4+8/VnDMO5H0cm5Q9KQ/c0Ixma3SlsIuS5jHPnaqMDuqUYWKziXt0t62NNFhQwolPn9Kar8ihA7JpqtuDmZ/I0qnVBE47N6LhYMX0w4HMSeVe8pusQTqWeoy+zLn4bgCaw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9dQ3ke8uff1NAjFFAPHyYOpvImMQUrO5vor3sThz4Cw=;
 b=sZWCpxXGtRwVOdzsESuAKFNlZtIbvLE2t7BmRp0/gZhXkCCrozH29l5JHhAuaReFPdT9dir2mQ/ASDb8tGdPs+rSl3/tAgRRRaMDgOq2sOuc0MRfTyZ4T5+wgXIc6ugl5J/BqYy/PNnauXsQuGFC1vvxjohrYoK/q/xHvGx/Iog=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4399.eurprd05.prod.outlook.com (52.133.13.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.16; Fri, 16 Aug 2019 17:12:57 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 17:12:57 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: turn hmm migrate_vma upside down v3
Thread-Topic: turn hmm migrate_vma upside down v3
Thread-Index: AQHVUnY3o2YuKC2GgEGP76ylqL0JqKb+Br6A
Date: Fri, 16 Aug 2019 17:12:57 +0000
Message-ID: <20190816171251.GL5412@mellanox.com>
References: <20190814075928.23766-1-hch@lst.de>
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ab3d94b3-69f2-42ca-d103-08d7226cfb95
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4399;
x-ms-traffictypediagnostic: VI1PR05MB4399:
x-microsoft-antispam-prvs:
 <VI1PR05MB4399832B0B252C78852C8000CFAF0@VI1PR05MB4399.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4714;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(39860400002)(396003)(136003)(346002)(189003)(199004)(6512007)(186003)(53936002)(1076003)(305945005)(316002)(7736002)(76176011)(52116002)(66446008)(2906002)(6116002)(8936002)(26005)(2616005)(6246003)(102836004)(229853002)(86362001)(71190400001)(81156014)(81166006)(36756003)(3846002)(8676002)(99286004)(25786009)(66066001)(256004)(4326008)(14454004)(6916009)(6506007)(71200400001)(54906003)(446003)(478600001)(386003)(4744005)(6486002)(6436002)(476003)(66946007)(11346002)(7416002)(66476007)(66556008)(64756008)(486006)(33656002)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4399;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Q3ogh7wkYXZo5Of84+w58jdXDAe0A19cTkHVIN1tUaS3j0Q/X7Uunm2Fmmz0If/N+rHowxlDYIT+jQKgMAEgXeA2kMsdJzaRwVgWiDK3Q0Ju7aX9r8ec/fQUbkwVsHJhRtv0d/NICRDYFPXQ4KPcz1pEfsxQrpQtbyRKxMiEmUY9QPxqZ/BK22eNYVySOCEMy6HhpLUKc4nZTBQRKGjK8NaJq+lXhbJt8fpk6mgQaes1MdpNo4X5fAO0nJFAJHO+8smpb+i9Ch4kkqNCrHkv3BCuajd/kHL3br/e4M30O5+/2QnEPJ3uvrikLkZG14pZ8DJAceNwwmxWTFSmnUxzkeJmkFcBlI+C7fyOBPWmXQ5DkMKGQDM5aJLJbPzreKSCAweMeRWJQZSg+utYrrYZ3EgSLBqZ2JjcRX7TKwfArR8=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <1964F1888B3B054D9FCFE8BDD7D5370B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ab3d94b3-69f2-42ca-d103-08d7226cfb95
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 17:12:57.0935
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: bLd5sukRTConBMZ5oo5kNEzb5BlHBt4PBWj8/HVxLeD/vlCIRwuOKNr7PvlaVqloBpK2MsNgu2qx9TMBIvPCwA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4399
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCBBdWcgMTQsIDIwMTkgYXQgMDk6NTk6MThBTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIErDqXLDtG1lLCBCZW4gYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgYWdhaW5zdCB0aGUgaG1tIHRyZWUgd2hpY2ggc3RhcnRzIHJldmFtcGluZyB0aGUN
Cj4gbWlncmF0ZV92bWEgZnVuY3Rpb25hbGl0eS4gIFRoZSBwcmltZSBpZGVhIGlzIHRvIGV4cG9y
dCB0aHJlZSBzbGlnaHRseQ0KPiBsb3dlciBsZXZlbCBmdW5jdGlvbnMgYW5kIHRodXMgYXZvaWQg
dGhlIG5lZWQgZm9yIG1pZ3JhdGVfdm1hX29wcw0KPiBjYWxsYmFja3MuDQo+IA0KPiBEaWZmc3Rh
dDoNCj4gDQo+ICAgICA3IGZpbGVzIGNoYW5nZWQsIDI4MiBpbnNlcnRpb25zKCspLCA2MTQgZGVs
ZXRpb25zKC0pDQoNCllheSwgYW5vdGhlciBiaWcgd2FjayBvZiBjb2RlIGdvbmUNCiANCkFwcGxp
ZWQgdG8gaG1tLmdpdA0KDQpUaGFua3MsDQpKYXNvbg0K

