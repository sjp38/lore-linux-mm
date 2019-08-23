Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1653C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:39:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A5B822CE3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="s5iXJyzT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A5B822CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8228F6B0492; Fri, 23 Aug 2019 09:39:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4EB6B0493; Fri, 23 Aug 2019 09:39:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C37A6B0494; Fri, 23 Aug 2019 09:39:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4D55F6B0492
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 09:39:57 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 04F52824CA3B
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:39:57 +0000 (UTC)
X-FDA: 75853800834.18.head44_56b9a9932b03a
X-HE-Tag: head44_56b9a9932b03a
X-Filterd-Recvd-Size: 8512
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60068.outbound.protection.outlook.com [40.107.6.68])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:39:55 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=YMhtqs9qIEhkPYA5po5ym8H0tjP9VUZj/Xm6F0bRiMRczca+3LGuigvUqJm5Sy4JlKnk986yx+OFwOTcv+zpY4Sycq5qU/33QHPI1vZXLNMyisltF3ScWRs/4VgPr9MQjUgWw0PkOlKVRwzJoyzhCA4FvsrNSisPL1cVo0eKRwStDy3vDbXbu3kZYpe1DSsoKkqxZ0fdzSSDjMDOCqAUCOZP8/SqQDviz6Wmb5mhkPCohOi+QFDAhudLZd8luQENtynou6XnBELDOdwJBqCInbRZJ6gbtP9zub1YEDsbk3UUf9rPw/k+VT8W+V6vM0wU20GfSKgqeHfq5ZGBKo7lBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ftQDzR/AP8dNDLIhocqzyCA3i3hWhgktd6LDwCpNQ3k=;
 b=IPZTAHE0aO5TC0rfvzsEUT5u2mo9dZdFp+0cIYFgXADi3bjhMcOy2su4fVw8ro+7Q6AlIxBHWpYXsJJeCsmh/PgMQ8A03sGRs79Kg+v/GMjp0kzbWHFaLpepNy3st5bKGecmDHD2IiWrHMgDkB5hSJzunF6oIc0D8A9uI5+P1EPTrR6ITHvF4eZ0+csns9R+PpbOXLyCypkS2S3pg+rJVclHd6UXGaIMQzKn7QI0yPakXAy+yDoaNMm5Ye7kfS/MsxenS3RloSZ7E25MaJp7UvDQzM+eWJ+PLIDeUr/H5zk7A7n3DWaUAepm6hYN8A4K+EC1hZ51cnCtDf1PLKnOjw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ftQDzR/AP8dNDLIhocqzyCA3i3hWhgktd6LDwCpNQ3k=;
 b=s5iXJyzTkoaaOfMK7edWhaVfbpPQ9uGJZ1FPfFf6L0ZvNvHLzp+f9Q7V46ZyluhW8mxlmUMopAA4DShvOaVjuAU/d6Vxwefao4QnrXtIgnvUBx+ZUZg+AWnQMO1CfINYCOmMZ9bG+dlyH4y7hjRQU/m50P+gkXBbRg77IgWN+eQ=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6575.eurprd05.prod.outlook.com (20.179.25.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Fri, 23 Aug 2019 13:39:53 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.020; Fri, 23 Aug 2019
 13:39:53 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Yang, Philip" <Philip.Yang@amd.com>
CC: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>
Subject: Re: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Topic: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Index: AQHVU6tqPJgEXxIoEkOKYOi6xfC1FacIyRmA
Date: Fri, 23 Aug 2019 13:39:53 +0000
Message-ID: <20190823133943.GF12847@mellanox.com>
References: <20190815205227.7949-1-Philip.Yang@amd.com>
In-Reply-To: <20190815205227.7949-1-Philip.Yang@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0016.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d54db258-9cd0-43e9-4fcd-08d727cf60f3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB6575;
x-ms-traffictypediagnostic: VI1PR05MB6575:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB657545FAF3D2BFF84F365AE6CFA40@VI1PR05MB6575.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1051;
x-forefront-prvs: 0138CD935C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(136003)(346002)(366004)(376002)(39860400002)(189003)(199004)(478600001)(316002)(8676002)(66946007)(14454004)(64756008)(5660300002)(66476007)(8936002)(186003)(14444005)(81166006)(256004)(6512007)(66556008)(3846002)(386003)(81156014)(2906002)(6306002)(99286004)(305945005)(7736002)(4326008)(26005)(52116002)(33656002)(36756003)(446003)(6246003)(71190400001)(71200400001)(486006)(54906003)(1076003)(76176011)(66574012)(6116002)(66446008)(53936002)(6916009)(6506007)(966005)(25786009)(476003)(66066001)(86362001)(6486002)(102836004)(2616005)(6436002)(11346002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6575;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 6ghJQ6nz/VD38QOxvr5u4lLmJ5a84R+DFrylRR5TWdD5CCluyEBsRA7xnK+S9HL8ny4QuZqn7MwIxeQ8gI+h28ew7AOjxLsGKndIl60yF49D8jCpfOlstkdViS95/96L8xDRxzYT2dk7CHDLbAefyLq5ATwnplQXDRv+gz0LKaSNedIKxLd0C3/pM0uazv7dmM0CxTPTXcact/YcilC4K0SHeHREKal5tMWkiQPCC/pleTE/2EJRLBhCrXlNxaNimH0bPeSbtUV00hegbPv4vlf/S3nv4f87Pm/KFcKc9EfHjKOX+Rr67Fvr6ivcSEPWny9NRyOrFvDOjp7SLC5BwwSVK88S6YmvM5moeMcy/lNEAdUgIC58T6ISSZgSOr/p7zeKQIlMyVO9CUKrXjF5HhfCYlJMjzfvHAsLXuvDar8=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <32DE2572A8F1254E94CE64D5F6FF937A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d54db258-9cd0-43e9-4fcd-08d727cf60f3
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Aug 2019 13:39:53.7444
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: o7ppP3pxtZYGDMKnRsFPWMqN+vxoZfQXm6fmJYaT5n9xUzmlpxBN/SbWENXgdnoaHewxutx2vChqdJ0h4A3dmg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6575
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBBdWcgMTUsIDIwMTkgYXQgMDg6NTI6NTZQTSArMDAwMCwgWWFuZywgUGhpbGlwIHdy
b3RlOg0KPiBobW1fcmFuZ2VfZmF1bHQgbWF5IHJldHVybiBOVUxMIHBhZ2VzIGJlY2F1c2Ugc29t
ZSBvZiBwZm5zIGFyZSBlcXVhbCB0bw0KPiBITU1fUEZOX05PTkUuIFRoaXMgaGFwcGVucyByYW5k
b21seSB1bmRlciBtZW1vcnkgcHJlc3N1cmUuIFRoZSByZWFzb24gaXMNCj4gZm9yIHN3YXBwZWQg
b3V0IHBhZ2UgcHRlIHBhdGgsIGhtbV92bWFfaGFuZGxlX3B0ZSBkb2Vzbid0IHVwZGF0ZSBmYXVs
dA0KPiB2YXJpYWJsZSBmcm9tIGNwdV9mbGFncywgc28gaXQgZmFpbGVkIHRvIGNhbGwgaG1tX3Zh
bV9kb19mYXVsdCB0byBzd2FwDQo+IHRoZSBwYWdlIGluLg0KPiANCj4gVGhlIGZpeCBpcyB0byBj
YWxsIGhtbV9wdGVfbmVlZF9mYXVsdCB0byB1cGRhdGUgZmF1bHQgdmFyaWFibGUuDQo+IA0KPiBD
aGFuZ2UtSWQ6IEkyZTg2MTE0ODU1NjNkMTFkOTM4ODgxYzE4Yjc5MzVmYTFlN2M5MWVlDQo+IFNp
Z25lZC1vZmYtYnk6IFBoaWxpcCBZYW5nIDxQaGlsaXAuWWFuZ0BhbWQuY29tPg0KPiAgbW0vaG1t
LmMgfCAzICsrKw0KPiAgMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKQ0KDQpBcHBsaWVk
IHRvIGhtbS5naXQsIHRoYW5rcw0KDQpJIGZpeGVkIHRoZSBjb21taXQgbWVzc2FnZToNCg0KQXV0
aG9yOiBZYW5nLCBQaGlsaXAgPFBoaWxpcC5ZYW5nQGFtZC5jb20+DQpEYXRlOiAgIFRodSBBdWcg
MTUgMjA6NTI6NTYgMjAxOSArMDAwMA0KDQogICAgbW0vaG1tOiBmaXggaG1tX3JhbmdlX2ZhdWx0
KCkncyBoYW5kbGluZyBvZiBzd2FwcGVkIG91dCBwYWdlcw0KICAgIA0KICAgIGhtbV9yYW5nZV9m
YXVsdCgpIG1heSByZXR1cm4gTlVMTCBwYWdlcyBiZWNhdXNlIHNvbWUgb2YgdGhlIHBmbnMgYXJl
IGVxdWFsDQogICAgdG8gSE1NX1BGTl9OT05FLiBUaGlzIGhhcHBlbnMgcmFuZG9tbHkgdW5kZXIg
bWVtb3J5IHByZXNzdXJlLiBUaGUgcmVhc29uDQogICAgaXMgZHVyaW5nIHRoZSBzd2FwcGVkIG91
dCBwYWdlIHB0ZSBwYXRoLCBobW1fdm1hX2hhbmRsZV9wdGUoKSBkb2Vzbid0DQogICAgdXBkYXRl
IHRoZSBmYXVsdCB2YXJpYWJsZSBmcm9tIGNwdV9mbGFncywgc28gaXQgZmFpbGVkIHRvIGNhbGwN
CiAgICBobW1fdmFtX2RvX2ZhdWx0KCkgdG8gc3dhcCB0aGUgcGFnZSBpbi4NCiAgICANCiAgICBU
aGUgZml4IGlzIHRvIGNhbGwgaG1tX3B0ZV9uZWVkX2ZhdWx0KCkgdG8gdXBkYXRlIGZhdWx0IHZh
cmlhYmxlLg0KICAgIA0KICAgIEZpeGVzOiA3NGVlZTE4MGI5MzUgKCJtbS9obW0vbWlycm9yOiBk
ZXZpY2UgcGFnZSBmYXVsdCBoYW5kbGVyIikNCiAgICBMaW5rOiBodHRwczovL2xvcmUua2VybmVs
Lm9yZy9yLzIwMTkwODE1MjA1MjI3Ljc5NDktMS1QaGlsaXAuWWFuZ0BhbWQuY29tDQogICAgU2ln
bmVkLW9mZi1ieTogUGhpbGlwIFlhbmcgPFBoaWxpcC5ZYW5nQGFtZC5jb20+DQogICAgUmV2aWV3
ZWQtYnk6ICJKw6lyw7RtZSBHbGlzc2UiIDxqZ2xpc3NlQHJlZGhhdC5jb20+DQogICAgU2lnbmVk
LW9mZi1ieTogSmFzb24gR3VudGhvcnBlIDxqZ2dAbWVsbGFub3guY29tPg0K

