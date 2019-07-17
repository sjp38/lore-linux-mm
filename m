Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFEFC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9493620880
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:34:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="IMwhwrlv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9493620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 303DB6B0005; Wed, 17 Jul 2019 07:34:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B3368E0003; Wed, 17 Jul 2019 07:34:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17CC38E0001; Wed, 17 Jul 2019 07:34:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB2836B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:34:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so17810432edu.11
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:34:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=eo0iOzaYLhoGQAU73D5qq8fABgoaI2DBdFuH1MMkfKE=;
        b=Bw9Wnyn0aZZzyq1vUUINso3xea5WG9tq5CZzu2DeJdrHDv2kiGKc2ImWdAatYlNwx1
         lFY72rWfXjRyt0NBpkm3Yzxx4rXJc2PQl1Cyq+AAIlfq6UK7S+Vj1mvswWrW7hqLoF/Y
         jZj48A6Wd1XUDBNKw9vM8niumN3zw5i7PSDSsHVIQ7wigejLNYQpHxuiDvV80KlFZ1Qn
         SiCHDGPk8+Z6hGp/UnlVwLvkzMg6UETEBPURRIAQOsSNrJc9yDEVeg6JgJ1GswdnXXkr
         1WzBpp1Wc2zdakRdE3DaWtMku79UhEG8TPpkLVawJmUIuiHUkac1438y3LRgga1ni08T
         XnTQ==
X-Gm-Message-State: APjAAAWMv7/5qbv9NuoYcQZjHrmiad97xzPxm41ztHRLC9N1/2fc4dD5
	DC9vqLlsPs1wEmNfAjXPA8HxUhd0NW07RnrSE9RBa9hM9ERYR+/v4+9da+9eKntp7+CNHOYWoUa
	lq2RbTAwrUJ2P4rMHzGyYWOObd7ekc5iQ9m+ywptUl+w5IfjY9QmdT4z2VOmPbVWFOA==
X-Received: by 2002:a17:906:a417:: with SMTP id l23mr18678328ejz.20.1563363273321;
        Wed, 17 Jul 2019 04:34:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyT75PZx6JBXQ2zeVlxUNyhF98pALMC2LQRCxSnoPtrH4MTgA7Y7Ixirtbv+idjSN03M4G
X-Received: by 2002:a17:906:a417:: with SMTP id l23mr18678282ejz.20.1563363272586;
        Wed, 17 Jul 2019 04:34:32 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563363272; cv=pass;
        d=google.com; s=arc-20160816;
        b=nmiNAT85ziHMdTTod82quom2FVoY1uhf67ej5YZkfrOy7DkshQyyGxt9451DqXZnpi
         cPUeJRgGUJm1qjqXarmMrFXq0yaGD0qi6EOM9kzaydfLcR74ErSt5CuZO05jqX0aITOH
         GoPJc+o81BcmOF2t+Cx5kpK3tk9hKoNtrlNUp+sNz8teAUs6g5xLMYk0Foa8kRqOE+eI
         W2bKwZu29Anyde4ysbue237w2jNSh5f1VCUmXHZjo2s0rWnQKymq01CD534zmjKM9rPK
         /bmld8n0Fjm/o18gNWAOdVWxyMOPlPb7SUZkLaAguAebVpW2uT6C1vjwe3m7pNU6lqUZ
         Dhvw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=eo0iOzaYLhoGQAU73D5qq8fABgoaI2DBdFuH1MMkfKE=;
        b=gdp8jucLV/poqqBLGPKtyh+I67dfNCmyctrUtY0Ms3jvecw3mf7uzn5H9TQfa3KXlI
         F+ROu5lNYIUx4d7xz4fASIb9uJ/Lo9HD7BjN48qTE76oHqCD+EDMyw3fMOglwfpw5coW
         kc0bKNu39x1jkb0YZmm5aPZ0gtRiAFyGuYvvrjdZ/r4R/mER7VlcTnj0BpGMz8x7JkN3
         7hEC22fAdCcgqocoAfGSeDpJc1UaJHEDkGbAzA5kJ8SB8CQj3+s+P1fBF0BvwepY5exZ
         WX+KYWQpTiRCzOWXV5qv5i59sAqC44G4TqupqLj90czGLfSra1gUkpyekzolvbiK8YrY
         Xgsg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=IMwhwrlv;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50089.outbound.protection.outlook.com. [40.107.5.89])
        by mx.google.com with ESMTPS id ce13si12503162ejb.305.2019.07.17.04.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 04:34:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) client-ip=40.107.5.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=IMwhwrlv;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CEe0KdRm+ZO9NxlshafJiEOBi1R8jH9OlAZ3MkhYOiZnQ091PoWaX4+qca2Up5MVKLeaSn+8wtn7HYW1K8LCKLBvaDkdJI1C0Ce6RdoMZwBgEzADLJ2+hQy1uV3pdPKcnaZX6IGHKujIrj2MjH+br2TSY7UjFWO7SLTMVHKP2bhAMZINL63ug1hA7+k5OPWZVyEn6FV8xleNN2nuJfxaoRrOTvMOdzOLR/HgwUNhVkRVa2JohU9JXwOmFPInqH4Fg7c9IcvJMlePsfCX8OqJIKrpTgI84us0jDRjdJ1hPk09WKwpHy9clXfk/rsaUxc6P2fdxA8d62EfCK+aGkcA3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eo0iOzaYLhoGQAU73D5qq8fABgoaI2DBdFuH1MMkfKE=;
 b=ioxYsLU1Cu0sa6Dde8bpxIlQ2j3Vlv5/FV4HKiUfGaMKF7N5qqxdcZMIV8993inyg/9aJex4shs26EUF5/c9ojdCahq+e57I3JXqDW+cWxMzxc/Lgg1gQcAkBqxmTULS4eUhxr0RDog8gUGc2sJHE2Q8448JXY2KMvEC67k+QC6fWGAMXTE/i01dGTGfaySCg01L7lt9q1idRYQi2jwj83xIs2oiO+0uU0AdvHhBjxIzL0sJ0XnFM5rQiFuiH+pKUAr3WQwWB18tKVQn/vfKRZKbXUXBLIpuoBbiM1OezcASUOieW9Gfe1ZNfMFAh3DfcTlHNljnfalWREt76vKMEg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eo0iOzaYLhoGQAU73D5qq8fABgoaI2DBdFuH1MMkfKE=;
 b=IMwhwrlvCjPo7JKYF13+Ivl5VcLhsTPxgwNFa2EelmAvGSR7cF3vuS8U+tjFteRyiNyAu5JzSnjr1odr4TPi/W4wCWkuTvNRi3blfxOH0R1NYz1J7wF7zy+gHxXis0HYIBxVBi76JW5t+c5n1DyAYFqiV4uQSEWb+dNsZiGKO1A=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5182.eurprd05.prod.outlook.com (20.178.11.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.14; Wed, 17 Jul 2019 11:34:30 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2073.012; Wed, 17 Jul 2019
 11:34:30 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
CC: =?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: HMM related use-after-free with amdgpu
Thread-Topic: HMM related use-after-free with amdgpu
Thread-Index:
 AQHVOy2BuBeOBwIpPkyfmkDLpwDNk6bL7iyAgAGDN4CAAAFJgIAACCMAgABVeACAAOCJgA==
Date: Wed, 17 Jul 2019 11:34:30 +0000
Message-ID: <20190717113425.GA12099@mellanox.com>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
 <20190715172515.GA5043@mellanox.com>
 <823db68e-6601-bb3a-0c1f-bfc5169cb7c9@daenzer.net>
 <20190716163545.GF29741@mellanox.com>
 <cc010b8d-0018-783a-648f-01099fc63352@daenzer.net>
 <7b5daece-10ea-e96e-5e75-f6fa4e589d5e@amd.com>
In-Reply-To: <7b5daece-10ea-e96e-5e75-f6fa4e589d5e@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0062.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::39) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f8b6320d-80c3-47c2-989f-08d70aaabb6f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5182;
x-ms-traffictypediagnostic: VI1PR05MB5182:
x-microsoft-antispam-prvs:
 <VI1PR05MB5182DFF8ECAF53310C16ED05CFC90@VI1PR05MB5182.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4714;
x-forefront-prvs: 01018CB5B3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(376002)(136003)(396003)(346002)(366004)(189003)(199004)(86362001)(66446008)(256004)(6436002)(476003)(5024004)(66946007)(1076003)(26005)(2616005)(76176011)(478600001)(5660300002)(64756008)(66476007)(6246003)(6116002)(6486002)(446003)(66556008)(102836004)(8936002)(11346002)(68736007)(7736002)(386003)(305945005)(3846002)(6512007)(186003)(6916009)(36756003)(53546011)(14454004)(229853002)(6506007)(25786009)(33656002)(52116002)(4326008)(486006)(316002)(53936002)(66066001)(81166006)(2906002)(81156014)(71190400001)(54906003)(8676002)(71200400001)(99286004);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5182;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 yLEWRqs08p1OVz/gbOvbGfJRzXd/Of/E5Q6I/a9+7kZIgN5WCXaQZf6smeGzHdhIb99CyO4BBafqzSPTBN1+xhgCA0Hy9w09heahsSur+lQh9Sxf2Bv6U7dnAnHMf20kDMpaGdTLAAF0aZJOX/WUwbuJbaCw6kyYV7eiAL0GSDlNLNJGYZVsE307QmGlrRhqE5QhTNO1G9VtEP6EoVl8CaUAqeoJ1rxgMcKJmt1Db/A4TtHL45rB1dSXWy5B8g6F7snFsG2K1mxtG7FFY/w0P41bKWZ3NP5QKJJwX60WxQFUeeLHmegm0gEayxpuwk7mC80Lmy3XvURTNVNh8e+/yYm9bsU3JAI2dvklV15pZQa0nRNwySj9qycDfbPR/ovpS7BAy9vJA6O61OIkqGQVj3p8ldIUxRJT4U3d9q/dsYU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <75CF9C281BF49D4196B4B1C1103E39DB@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f8b6320d-80c3-47c2-989f-08d70aaabb6f
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jul 2019 11:34:30.4503
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCBKdWwgMTYsIDIwMTkgYXQgMTA6MTA6NDZQTSArMDAwMCwgS3VlaGxpbmcsIEZlbGl4
IHdyb3RlOg0KPiBPbiAyMDE5LTA3LTE2IDE6MDQgcC5tLiwgTWljaGVsIETDpG56ZXIgd3JvdGU6
DQo+ID4gT24gMjAxOS0wNy0xNiA2OjM1IHAubS4sIEphc29uIEd1bnRob3JwZSB3cm90ZToNCj4g
Pj4gT24gVHVlLCBKdWwgMTYsIDIwMTkgYXQgMDY6MzE6MDlQTSArMDIwMCwgTWljaGVsIETDpG56
ZXIgd3JvdGU6DQo+ID4+PiBPbiAyMDE5LTA3LTE1IDc6MjUgcC5tLiwgSmFzb24gR3VudGhvcnBl
IHdyb3RlOg0KPiA+Pj4+IE9uIE1vbiwgSnVsIDE1LCAyMDE5IGF0IDA2OjUxOjA2UE0gKzAyMDAs
IE1pY2hlbCBEw6RuemVyIHdyb3RlOg0KPiA+Pj4+PiBXaXRoIGEgS0FTQU4gZW5hYmxlZCBrZXJu
ZWwgYnVpbHQgZnJvbSBhbWQtc3RhZ2luZy1kcm0tbmV4dCwgdGhlDQo+ID4+Pj4+IGF0dGFjaGVk
IHVzZS1hZnRlci1mcmVlIGlzIHByZXR0eSByZWxpYWJseSBkZXRlY3RlZCBkdXJpbmcgYSBwaWds
aXQgZ3B1IHJ1bi4NCj4gPj4+PiBEb2VzIHRoaXMgYnJhbmNoIHlvdSBhcmUgdGVzdGluZyBoYXZl
IHRoZSBobW0uZ2l0IG1lcmdlZD8gSSB0aGluayBmcm9tDQo+ID4+Pj4gdGhlIG5hbWUgaXQgZG9l
cyBub3Q/DQo+ID4+PiBJbmRlZWQsIG5vLg0KPiA+Pj4NCj4gPj4+DQo+ID4+Pj4gVXNlIGFmdGVy
IGZyZWUncyBvZiB0aGlzIG5hdHVyZSB3ZXJlIHNvbWV0aGluZyB0aGF0IHdhcyBmaXhlZCBpbg0K
PiA+Pj4+IGhtbS5naXQuLg0KPiA+Pj4+DQo+ID4+Pj4gSSBkb24ndCBzZWUgYW4gb2J2aW91cyB3
YXkgeW91IGNhbiBoaXQgc29tZXRoaW5nIGxpa2UgdGhpcyB3aXRoIHRoZQ0KPiA+Pj4+IG5ldyBj
b2RlIGFycmFuZ2VtZW50Li4NCj4gPj4+IEkgdHJpZWQgbWVyZ2luZyB0aGUgaG1tLWRldm1lbS1j
bGVhbnVwLjQgY2hhbmdlc1swXSBpbnRvIG15IDUuMi55ICsNCj4gPj4+IGRybS1uZXh0IGZvciA1
LjMga2VybmVsLiBXaGlsZSB0aGUgcmVzdWx0IGRpZG4ndCBoaXQgdGhlIHByb2JsZW0sIGFsbA0K
PiA+Pj4gR0xfQU1EX3Bpbm5lZF9tZW1vcnkgcGlnbGl0IHRlc3RzIGZhaWxlZCwgc28gSSBzdXNw
ZWN0IHRoZSBwcm9ibGVtIHdhcw0KPiA+Pj4gc2ltcGx5IGF2b2lkZWQgYnkgbm90IGFjdHVhbGx5
IGhpdHRpbmcgdGhlIEhNTSByZWxhdGVkIGZ1bmN0aW9uYWxpdHkuDQo+ID4+Pg0KPiA+Pj4gSXQn
cyBwb3NzaWJsZSB0aGF0IEkgbWFkZSBhIG1pc3Rha2UgaW4gbWVyZ2luZyB0aGUgY2hhbmdlcywg
b3IgdGhhdCBJDQo+ID4+PiBtaXNzZWQgc29tZSBvdGhlciByZXF1aXJlZCBjaGFuZ2VzLiBCdXQg
aXQncyBhbHNvIHBvc3NpYmxlIHRoYXQgdGhlIEhNTQ0KPiA+Pj4gY2hhbmdlcyBicm9rZSB0aGUg
Y29ycmVzcG9uZGluZyB1c2VyLXBvaW50ZXIgZnVuY3Rpb25hbGl0eSBpbiBhbWRncHUuDQo+ID4+
IE5vdCBzdXJlLCB0aGlzIHdhcyBhbGwgVGVzdGVkIGJ5IHRoZSBBTUQgdGVhbSBzbyBpdCBzaG91
bGQgd29yaywgSQ0KPiA+PiBob3BlLg0KPiA+IEl0IGNhbid0LCBkdWUgdG8gdGhlIGlzc3VlIHBv
aW50ZWQgb3V0IGJ5IExpbnVzIGluIHRoZSAiZHJtIHB1bGwgZm9yDQo+ID4gNS4zLXJjMSIgdGhy
ZWFkOiBEUk1fQU1ER1BVX1VTRVJQVFIgc3RpbGwgZGVwZW5kcyBvbiBBUkNIX0hBU19ITU0sIHdo
aWNoDQo+ID4gbm8gbG9uZ2VyIGV4aXN0cywgc28gaXQgY2FuJ3QgYmUgZW5hYmxlZC4NCj4gDQo+
IEFzIGZhciBhcyBJIGNhbiB0ZWxsLCBMaW51cyBmaXhlZCB0aGlzIHVwIGluIGhpcyBtZXJnZSBj
b21taXQgDQo+IGJlODQ1NGFmYzUwZjQzMDE2Y2E4YjYxMzBkOTY3M2JkZDBiZDU2ZWMuIEphc29u
LCBpcyBobW0uZ2l0IGdvaW5nIHRvIGdldCANCj4gcmViYXNlZCBvciBtZXJnZSB0byBwaWNrIHVw
IHRoZSBhbWRncHUgY2hhbmdlcyBmb3IgSE1NIGZyb20gbWFzdGVyPw0KDQpJdCB3aWxsIGJlIHJl
c2V0IHRvIC1yYzEgd2hlbiBpdCBjb21lcyBvdXQsIHRoZW4gd2Ugc3RhcnQgYWxsIG92ZXINCmFn
YWluLg0KDQpKYXNvbg0K

