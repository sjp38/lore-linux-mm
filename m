Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 043C2C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DD3520835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="CB3Aouol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DD3520835
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2828A6B0003; Wed, 17 Apr 2019 05:16:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2335E6B0006; Wed, 17 Apr 2019 05:16:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FE166B000D; Wed, 17 Apr 2019 05:16:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D81536B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:16:21 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y9so17543387ywc.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:16:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=LXftkQvs09zgykXovvAQWGQ8+LUx1uaSyZ8Q5oSJ5Ys=;
        b=ipDu7qEa2ujq4BAq5gPGGsUpzgybZCJJxVdp6/qlvSINEjIYYUmyoWYaSZxprwwwj3
         LlK9tMNJZDw/mTyh/qdSXA3nvmtyF/kY4VSeR6rW1Fz+oXZH/TqNtRl1YJp/UoMprwem
         Lj0na2MpHQSrl8PspCNQR7KxCmeucvypoozBZ2RkUdAU9VSLl2deDthK280koN/Mpq4A
         P3JzqgE0R3mEAxdZzX+SnuP9Qtqb4JdGBCwa9/cQLrIoO/RVPUt1mAQ22Z8hY2JPX2L2
         T/B7dXVQ9kJib7A7TyuTXrR6gY7GQPVeyhsgOAG3Ce1Zo7XFJb7SaxUqnvqkmVxe0QRe
         FNSA==
X-Gm-Message-State: APjAAAXzeW7BDCrIxPtOIfOvB1rXNgZ0sYtlx2PwjzPb2SyGChkdWK5S
	Pj2tSI6gmtFVbEGlp57P6KxTbi8VJvF2xQwEwyrl/ufzmJVli5p4jdyab8eVse1BJ86HMTaOrwT
	2jE586AYvSngbj8XsaELE+EyWmffufw2W6ZSWkMH/DNMMJwKMLUhoG5wWF4WA77mwrg==
X-Received: by 2002:a81:5255:: with SMTP id g82mr37488393ywb.90.1555492581487;
        Wed, 17 Apr 2019 02:16:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAHJIgnr+9W0KAXvwZOg13BjKGiSBWYSgH5saUddZ2jEcbkgFc1ZLWkGDABhGavuKGu+SS
X-Received: by 2002:a81:5255:: with SMTP id g82mr37488353ywb.90.1555492580522;
        Wed, 17 Apr 2019 02:16:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555492580; cv=none;
        d=google.com; s=arc-20160816;
        b=OEqR6a0Chfi9UiVOkgknhWZUIvHf874zoRWkn7gMpbxhg9E1JSpzVlt++NlZRJAgER
         uodyXdktisz5gnP10oXAN/ohzZErOi/8LSQLMXIfaVIuijVcLNWKEIK0BFI6SSBZWE5i
         X0tuJFy6NjhJM68BwhgayW6yFH79KENZit7o+lRip83xEbJ7iQ5vC2Pq9IbX/6pZZFrG
         YUJm2opDhWVcQ+rm8svB+wZlrY15DWA+P5bWkVAbJOvw7SdrGrSblBeQ2LKbHqItqjon
         pBTKlZwGvWaAG6bmiTqmmJQfHxf7aczL9MohbQ6I+k9Thn5CsEU6LQ/arO65A5tgxB5z
         CSiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=LXftkQvs09zgykXovvAQWGQ8+LUx1uaSyZ8Q5oSJ5Ys=;
        b=EbcoDEk0oWaTJpCYfcAxGaTrpUlJHHywLOIH/PvuoDM2Q0G3U+Azb8pZgFfb3z0WvD
         QuO12T5Mhc9u6HL7gLQrhpACSxV5psK7mdTcK6KY/VObI3yZBh/DwcTVnddtlp3IDUOB
         goWoj4N/68qJfJjz8QbU4j4w+KQlcsJfzOi9xTr8M25vGGM0X2lrWLQawBd0leaLDrrn
         ORNpKho+vHjvnxdNH/LKbALgVUKEJw+8AB852jMtJSwviAlpin9GZo0RgDowmuiJvA5o
         XvP1LqQGPV7s25cJjAMDkk/ZohhuVnxKR11KKpfRBLTbu2XfXRf0LJox6mIbXpkC9gFM
         DI4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=CB3Aouol;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.87 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800087.outbound.protection.outlook.com. [40.107.80.87])
        by mx.google.com with ESMTPS id 194si34370163ywh.68.2019.04.17.02.16.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 02:16:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.87 as permitted sender) client-ip=40.107.80.87;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=CB3Aouol;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.87 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LXftkQvs09zgykXovvAQWGQ8+LUx1uaSyZ8Q5oSJ5Ys=;
 b=CB3AouolxO9AAV1Lm+zp8WCYT+gmzbM6YlNu+2YZWg1iT5XjgYehxYt/WvSfe6VP0k7H4L5i9OJVNDnfW87jRG8hS2Q13tGtMckOXTKjbeJm2wFop+LPLz6F9xqyVxKTDllk1UTXNaNPi9oOefpmUYeTG7UvqfrRNWv+gKRjqJc=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6063.namprd05.prod.outlook.com (20.178.240.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.5; Wed, 17 Apr 2019 09:15:52 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%7]) with mapi id 15.20.1813.009; Wed, 17 Apr 2019
 09:15:52 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "willy@infradead.org"
	<willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"jrdr.linux@gmail.com" <jrdr.linux@gmail.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, "mhocko@suse.com"
	<mhocko@suse.com>, Linux-graphics-maintainer
	<Linux-graphics-maintainer@vmware.com>, "ying.huang@intel.com"
	<ying.huang@intel.com>, "riel@surriel.com" <riel@surriel.com>
Subject: Re: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
Thread-Topic: [PATCH 2/9] mm: Add an apply_to_pfn_range interface
Thread-Index: AQHU8UlivMPCX9sP50+Af9Zp3fb7A6Y5BPeAgAC/wICABR8xgIABNdCA
Date: Wed, 17 Apr 2019 09:15:52 +0000
Message-ID: <2dd9b36444dc92f409b44c74667b6d63dc1713a8.camel@vmware.com>
References: <20190412160338.64994-1-thellstrom@vmware.com>
	 <20190412160338.64994-3-thellstrom@vmware.com>
	 <20190412210743.GA19252@redhat.com>
	 <ba1f1f97259e09cd3cc6377cad89b036285c0272.camel@vmware.com>
	 <20190416144657.GA3254@redhat.com>
In-Reply-To: <20190416144657.GA3254@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7503228d-e0a9-4828-82d5-08d6c3154a53
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600140)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MN2PR05MB6063;
x-ms-traffictypediagnostic: MN2PR05MB6063:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6063E9CF2CAD7A77682C4F37A1250@MN2PR05MB6063.namprd05.prod.outlook.com>
x-forefront-prvs: 0010D93EFE
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(136003)(366004)(376002)(346002)(189003)(199004)(186003)(99286004)(14454004)(66574012)(93886005)(486006)(25786009)(54906003)(316002)(7736002)(305945005)(2906002)(3846002)(6116002)(2501003)(478600001)(86362001)(26005)(7416002)(11346002)(97736004)(476003)(76176011)(2616005)(30864003)(446003)(106356001)(5660300002)(71200400001)(71190400001)(229853002)(2351001)(8936002)(6916009)(6486002)(68736007)(256004)(105586002)(102836004)(6436002)(118296001)(14444005)(6246003)(81156014)(81166006)(4326008)(5640700003)(6506007)(6512007)(66066001)(36756003)(53936002)(1730700003)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6063;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0dK0nm1qhLjShWdy17+0rbhWshDBReCCFaR9Tyt3UzENdx4qLOgq7tZxl5h3LlmFooT7lmr3c0Kb4kkq5/eLHdLvl7tbsCPNYnMdiPfcmSZrPp3VK0g7M+9G5FL2WMaGi7SI5gkJI3QXJQNlyMbCsEgEeZdhFnasjifsHwkuhS5Tbf2w5+HwQFKYNqqZxch78YWtp09fVAwwoJeDXeavpldYjvsucWJIdK1s4aqsuNhomVBqqaqo9YJ4e4xVq+kFtHaeX11JTTWpDgywtDCMWKOuAnGfNk3thF4Vpb0aotEiwNhH7o4/LPj+5j0JDm3krYwmwJiyjfGmxgU5xtiE3jOYnfRlHFwmpq9bergkXtW3RjP82SrOPtTDGGwEmtTLGDIM0r/n5kkCQItA8FOCN4QRUL98HADuEe+VAMzubY8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <82CD193B8771FA4AA11065F90DE6923A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7503228d-e0a9-4828-82d5-08d6c3154a53
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Apr 2019 09:15:52.6689
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCAyMDE5LTA0LTE2IGF0IDEwOjQ2IC0wNDAwLCBKZXJvbWUgR2xpc3NlIHdyb3RlOg0K
PiBPbiBTYXQsIEFwciAxMywgMjAxOSBhdCAwODozNDowMkFNICswMDAwLCBUaG9tYXMgSGVsbHN0
cm9tIHdyb3RlOg0KPiA+IEhpLCBKw6lyw7RtZQ0KPiA+IA0KPiA+IE9uIEZyaSwgMjAxOS0wNC0x
MiBhdCAxNzowNyAtMDQwMCwgSmVyb21lIEdsaXNzZSB3cm90ZToNCj4gPiA+IE9uIEZyaSwgQXBy
IDEyLCAyMDE5IGF0IDA0OjA0OjE4UE0gKzAwMDAsIFRob21hcyBIZWxsc3Ryb20gd3JvdGU6DQo+
ID4gPiA+IFRoaXMgaXMgYmFzaWNhbGx5IGFwcGx5X3RvX3BhZ2VfcmFuZ2Ugd2l0aCBhZGRlZCBm
dW5jdGlvbmFsaXR5Og0KPiA+ID4gPiBBbGxvY2F0aW5nIG1pc3NpbmcgcGFydHMgb2YgdGhlIHBh
Z2UgdGFibGUgYmVjb21lcyBvcHRpb25hbCwNCj4gPiA+ID4gd2hpY2gNCj4gPiA+ID4gbWVhbnMg
dGhhdCB0aGUgZnVuY3Rpb24gY2FuIGJlIGd1YXJhbnRlZWQgbm90IHRvIGVycm9yIGlmDQo+ID4g
PiA+IGFsbG9jYXRpb24NCj4gPiA+ID4gaXMgZGlzYWJsZWQuIEFsc28gcGFzc2luZyBvZiB0aGUg
Y2xvc3VyZSBzdHJ1Y3QgYW5kIGNhbGxiYWNrDQo+ID4gPiA+IGZ1bmN0aW9uDQo+ID4gPiA+IGJl
Y29tZXMgZGlmZmVyZW50IGFuZCBtb3JlIGluIGxpbmUgd2l0aCBob3cgdGhpbmdzIGFyZSBkb25l
DQo+ID4gPiA+IGVsc2V3aGVyZS4NCj4gPiA+ID4gDQo+ID4gPiA+IEZpbmFsbHkgd2Uga2VlcCBh
cHBseV90b19wYWdlX3JhbmdlIGFzIGEgd3JhcHBlciBhcm91bmQNCj4gPiA+ID4gYXBwbHlfdG9f
cGZuX3JhbmdlDQo+ID4gPiA+IA0KPiA+ID4gPiBUaGUgcmVhc29uIGZvciBub3QgdXNpbmcgdGhl
IHBhZ2Utd2FsayBjb2RlIGlzIHRoYXQgd2Ugd2FudCB0bw0KPiA+ID4gPiBwZXJmb3JtDQo+ID4g
PiA+IHRoZSBwYWdlLXdhbGsgb24gdm1hcyBwb2ludGluZyB0byBhbiBhZGRyZXNzIHNwYWNlIHdp
dGhvdXQNCj4gPiA+ID4gcmVxdWlyaW5nIHRoZQ0KPiA+ID4gPiBtbWFwX3NlbSB0byBiZSBoZWxk
IHJhdGhlciB0aGFuZCBvbiB2bWFzIGJlbG9uZ2luZyB0byBhIHByb2Nlc3MNCj4gPiA+ID4gd2l0
aCB0aGUNCj4gPiA+ID4gbW1hcF9zZW0gaGVsZC4NCj4gPiA+ID4gDQo+ID4gPiA+IE5vdGFibGUg
Y2hhbmdlcyBzaW5jZSBSRkM6DQo+ID4gPiA+IERvbid0IGV4cG9ydCBhcHBseV90b19wZm4gcmFu
Z2UuDQo+ID4gPiA+IA0KPiA+ID4gPiBDYzogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3Vu
ZGF0aW9uLm9yZz4NCj4gPiA+ID4gQ2M6IE1hdHRoZXcgV2lsY294IDx3aWxseUBpbmZyYWRlYWQu
b3JnPg0KPiA+ID4gPiBDYzogV2lsbCBEZWFjb24gPHdpbGwuZGVhY29uQGFybS5jb20+DQo+ID4g
PiA+IENjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+DQo+ID4gPiA+IENj
OiBSaWsgdmFuIFJpZWwgPHJpZWxAc3VycmllbC5jb20+DQo+ID4gPiA+IENjOiBNaW5jaGFuIEtp
bSA8bWluY2hhbkBrZXJuZWwub3JnPg0KPiA+ID4gPiBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29A
c3VzZS5jb20+DQo+ID4gPiA+IENjOiBIdWFuZyBZaW5nIDx5aW5nLmh1YW5nQGludGVsLmNvbT4N
Cj4gPiA+ID4gQ2M6IFNvdXB0aWNrIEpvYXJkZXIgPGpyZHIubGludXhAZ21haWwuY29tPg0KPiA+
ID4gPiBDYzogIkrDqXLDtG1lIEdsaXNzZSIgPGpnbGlzc2VAcmVkaGF0LmNvbT4NCj4gPiA+ID4g
Q2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KPiA+ID4gPiBDYzogbGludXgta2VybmVsQHZnZXIua2Vy
bmVsLm9yZw0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBUaG9tYXMgSGVsbHN0cm9tIDx0aGVsbHN0
cm9tQHZtd2FyZS5jb20+DQo+ID4gPiA+IC0tLQ0KPiA+ID4gPiAgaW5jbHVkZS9saW51eC9tbS5o
IHwgIDEwICsrKysNCj4gPiA+ID4gIG1tL21lbW9yeS5jICAgICAgICB8IDEzMCArKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrLS0tDQo+ID4gPiA+IC0tLS0NCj4gPiA+ID4gLS0tLQ0K
PiA+ID4gPiAgMiBmaWxlcyBjaGFuZ2VkLCAxMDggaW5zZXJ0aW9ucygrKSwgMzIgZGVsZXRpb25z
KC0pDQo+ID4gPiA+IA0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9tbS5oIGIv
aW5jbHVkZS9saW51eC9tbS5oDQo+ID4gPiA+IGluZGV4IDgwYmI2NDA4ZmU3My4uYjdkZDRkZGQ2
ZWZiIDEwMDY0NA0KPiA+ID4gPiAtLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgNCj4gPiA+ID4gKysr
IGIvaW5jbHVkZS9saW51eC9tbS5oDQo+ID4gPiA+IEBAIC0yNjMyLDYgKzI2MzIsMTYgQEAgdHlw
ZWRlZiBpbnQgKCpwdGVfZm5fdCkocHRlX3QgKnB0ZSwNCj4gPiA+ID4gcGd0YWJsZV90IHRva2Vu
LCB1bnNpZ25lZCBsb25nIGFkZHIsDQo+ID4gPiA+ICBleHRlcm4gaW50IGFwcGx5X3RvX3BhZ2Vf
cmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkDQo+ID4gPiA+IGxvbmcNCj4gPiA+
ID4gYWRkcmVzcywNCj4gPiA+ID4gIAkJCSAgICAgICB1bnNpZ25lZCBsb25nIHNpemUsIHB0ZV9m
bl90IGZuLA0KPiA+ID4gPiB2b2lkDQo+ID4gPiA+ICpkYXRhKTsNCj4gPiA+ID4gIA0KPiA+ID4g
PiArc3RydWN0IHBmbl9yYW5nZV9hcHBseTsNCj4gPiA+ID4gK3R5cGVkZWYgaW50ICgqcHRlcl9m
bl90KShwdGVfdCAqcHRlLCBwZ3RhYmxlX3QgdG9rZW4sIHVuc2lnbmVkDQo+ID4gPiA+IGxvbmcg
YWRkciwNCj4gPiA+ID4gKwkJCSBzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlKTsNCj4g
PiA+ID4gK3N0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgew0KPiA+ID4gPiArCXN0cnVjdCBtbV9zdHJ1
Y3QgKm1tOw0KPiA+ID4gPiArCXB0ZXJfZm5fdCBwdGVmbjsNCj4gPiA+ID4gKwl1bnNpZ25lZCBp
bnQgYWxsb2M7DQo+ID4gPiA+ICt9Ow0KPiA+ID4gPiArZXh0ZXJuIGludCBhcHBseV90b19wZm5f
cmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwNCj4gPiA+ID4gKwkJCSAgICAg
IHVuc2lnbmVkIGxvbmcgYWRkcmVzcywgdW5zaWduZWQNCj4gPiA+ID4gbG9uZw0KPiA+ID4gPiBz
aXplKTsNCj4gPiA+ID4gIA0KPiA+ID4gPiAgI2lmZGVmIENPTkZJR19QQUdFX1BPSVNPTklORw0K
PiA+ID4gPiAgZXh0ZXJuIGJvb2wgcGFnZV9wb2lzb25pbmdfZW5hYmxlZCh2b2lkKTsNCj4gPiA+
ID4gZGlmZiAtLWdpdCBhL21tL21lbW9yeS5jIGIvbW0vbWVtb3J5LmMNCj4gPiA+ID4gaW5kZXgg
YTk1YjRhM2IxYWUyLi42MGQ2NzE1ODk2NGYgMTAwNjQ0DQo+ID4gPiA+IC0tLSBhL21tL21lbW9y
eS5jDQo+ID4gPiA+ICsrKyBiL21tL21lbW9yeS5jDQo+ID4gPiA+IEBAIC0xOTM4LDE4ICsxOTM4
LDE3IEBAIGludCB2bV9pb21hcF9tZW1vcnkoc3RydWN0DQo+ID4gPiA+IHZtX2FyZWFfc3RydWN0
DQo+ID4gPiA+ICp2bWEsIHBoeXNfYWRkcl90IHN0YXJ0LCB1bnNpZ25lZCBsb25nDQo+ID4gPiA+
ICB9DQo+ID4gPiA+ICBFWFBPUlRfU1lNQk9MKHZtX2lvbWFwX21lbW9yeSk7DQo+ID4gPiA+ICAN
Cj4gPiA+ID4gLXN0YXRpYyBpbnQgYXBwbHlfdG9fcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3Qg
Km1tLCBwbWRfdA0KPiA+ID4gPiAqcG1kLA0KPiA+ID4gPiAtCQkJCSAgICAgdW5zaWduZWQgbG9u
ZyBhZGRyLA0KPiA+ID4gPiB1bnNpZ25lZCBsb25nDQo+ID4gPiA+IGVuZCwNCj4gPiA+ID4gLQkJ
CQkgICAgIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KPiA+ID4gPiArc3RhdGljIGludCBhcHBs
eV90b19wdGVfcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwNCj4gPiA+ID4g
cG1kX3QgKnBtZCwNCj4gPiA+ID4gKwkJCSAgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWdu
ZWQgbG9uZw0KPiA+ID4gPiBlbmQpDQo+ID4gPiA+ICB7DQo+ID4gPiA+ICAJcHRlX3QgKnB0ZTsN
Cj4gPiA+ID4gIAlpbnQgZXJyOw0KPiA+ID4gPiAgCXBndGFibGVfdCB0b2tlbjsNCj4gPiA+ID4g
IAlzcGlubG9ja190ICp1bmluaXRpYWxpemVkX3ZhcihwdGwpOw0KPiA+ID4gPiAgDQo+ID4gPiA+
IC0JcHRlID0gKG1tID09ICZpbml0X21tKSA/DQo+ID4gPiA+ICsJcHRlID0gKGNsb3N1cmUtPm1t
ID09ICZpbml0X21tKSA/DQo+ID4gPiA+ICAJCXB0ZV9hbGxvY19rZXJuZWwocG1kLCBhZGRyKSA6
DQo+ID4gPiA+IC0JCXB0ZV9hbGxvY19tYXBfbG9jayhtbSwgcG1kLCBhZGRyLCAmcHRsKTsNCj4g
PiA+ID4gKwkJcHRlX2FsbG9jX21hcF9sb2NrKGNsb3N1cmUtPm1tLCBwbWQsIGFkZHIsDQo+ID4g
PiA+ICZwdGwpOw0KPiA+ID4gPiAgCWlmICghcHRlKQ0KPiA+ID4gPiAgCQlyZXR1cm4gLUVOT01F
TTsNCj4gPiA+ID4gIA0KPiA+ID4gPiBAQCAtMTk2MCw4NiArMTk1OSwxMDcgQEAgc3RhdGljIGlu
dCBhcHBseV90b19wdGVfcmFuZ2Uoc3RydWN0DQo+ID4gPiA+IG1tX3N0cnVjdCAqbW0sIHBtZF90
ICpwbWQsDQo+ID4gPiA+ICAJdG9rZW4gPSBwbWRfcGd0YWJsZSgqcG1kKTsNCj4gPiA+ID4gIA0K
PiA+ID4gPiAgCWRvIHsNCj4gPiA+ID4gLQkJZXJyID0gZm4ocHRlKyssIHRva2VuLCBhZGRyLCBk
YXRhKTsNCj4gPiA+ID4gKwkJZXJyID0gY2xvc3VyZS0+cHRlZm4ocHRlKyssIHRva2VuLCBhZGRy
LA0KPiA+ID4gPiBjbG9zdXJlKTsNCj4gPiA+ID4gIAkJaWYgKGVycikNCj4gPiA+ID4gIAkJCWJy
ZWFrOw0KPiA+ID4gPiAgCX0gd2hpbGUgKGFkZHIgKz0gUEFHRV9TSVpFLCBhZGRyICE9IGVuZCk7
DQo+ID4gPiA+ICANCj4gPiA+ID4gIAlhcmNoX2xlYXZlX2xhenlfbW11X21vZGUoKTsNCj4gPiA+
ID4gIA0KPiA+ID4gPiAtCWlmIChtbSAhPSAmaW5pdF9tbSkNCj4gPiA+ID4gKwlpZiAoY2xvc3Vy
ZS0+bW0gIT0gJmluaXRfbW0pDQo+ID4gPiA+ICAJCXB0ZV91bm1hcF91bmxvY2socHRlLTEsIHB0
bCk7DQo+ID4gPiA+ICAJcmV0dXJuIGVycjsNCj4gPiA+ID4gIH0NCj4gPiA+ID4gIA0KPiA+ID4g
PiAtc3RhdGljIGludCBhcHBseV90b19wbWRfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHB1
ZF90DQo+ID4gPiA+ICpwdWQsDQo+ID4gPiA+IC0JCQkJICAgICB1bnNpZ25lZCBsb25nIGFkZHIs
DQo+ID4gPiA+IHVuc2lnbmVkIGxvbmcNCj4gPiA+ID4gZW5kLA0KPiA+ID4gPiAtCQkJCSAgICAg
cHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4gPiA+ICtzdGF0aWMgaW50IGFwcGx5X3RvX3Bt
ZF9yYW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0KPiA+ID4gPiBwdWRfdCAq
cHVkLA0KPiA+ID4gPiArCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25n
DQo+ID4gPiA+IGVuZCkNCj4gPiA+ID4gIHsNCj4gPiA+ID4gIAlwbWRfdCAqcG1kOw0KPiA+ID4g
PiAgCXVuc2lnbmVkIGxvbmcgbmV4dDsNCj4gPiA+ID4gLQlpbnQgZXJyOw0KPiA+ID4gPiArCWlu
dCBlcnIgPSAwOw0KPiA+ID4gPiAgDQo+ID4gPiA+ICAJQlVHX09OKHB1ZF9odWdlKCpwdWQpKTsN
Cj4gPiA+ID4gIA0KPiA+ID4gPiAtCXBtZCA9IHBtZF9hbGxvYyhtbSwgcHVkLCBhZGRyKTsNCj4g
PiA+ID4gKwlwbWQgPSBwbWRfYWxsb2MoY2xvc3VyZS0+bW0sIHB1ZCwgYWRkcik7DQo+ID4gPiA+
ICAJaWYgKCFwbWQpDQo+ID4gPiA+ICAJCXJldHVybiAtRU5PTUVNOw0KPiA+ID4gPiArDQo+ID4g
PiA+ICAJZG8gew0KPiA+ID4gPiAgCQluZXh0ID0gcG1kX2FkZHJfZW5kKGFkZHIsIGVuZCk7DQo+
ID4gPiA+IC0JCWVyciA9IGFwcGx5X3RvX3B0ZV9yYW5nZShtbSwgcG1kLCBhZGRyLCBuZXh0LA0K
PiA+ID4gPiBmbiwNCj4gPiA+ID4gZGF0YSk7DQo+ID4gPiA+ICsJCWlmICghY2xvc3VyZS0+YWxs
b2MgJiYNCj4gPiA+ID4gcG1kX25vbmVfb3JfY2xlYXJfYmFkKHBtZCkpDQo+ID4gPiA+ICsJCQlj
b250aW51ZTsNCj4gPiA+ID4gKwkJZXJyID0gYXBwbHlfdG9fcHRlX3JhbmdlKGNsb3N1cmUsIHBt
ZCwgYWRkciwNCj4gPiA+ID4gbmV4dCk7DQo+ID4gPiA+ICAJCWlmIChlcnIpDQo+ID4gPiA+ICAJ
CQlicmVhazsNCj4gPiA+ID4gIAl9IHdoaWxlIChwbWQrKywgYWRkciA9IG5leHQsIGFkZHIgIT0g
ZW5kKTsNCj4gPiA+ID4gIAlyZXR1cm4gZXJyOw0KPiA+ID4gPiAgfQ0KPiA+ID4gPiAgDQo+ID4g
PiA+IC1zdGF0aWMgaW50IGFwcGx5X3RvX3B1ZF9yYW5nZShzdHJ1Y3QgbW1fc3RydWN0ICptbSwg
cDRkX3QNCj4gPiA+ID4gKnA0ZCwNCj4gPiA+ID4gLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcgYWRk
ciwNCj4gPiA+ID4gdW5zaWduZWQgbG9uZw0KPiA+ID4gPiBlbmQsDQo+ID4gPiA+IC0JCQkJICAg
ICBwdGVfZm5fdCBmbiwgdm9pZCAqZGF0YSkNCj4gPiA+ID4gK3N0YXRpYyBpbnQgYXBwbHlfdG9f
cHVkX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUsDQo+ID4gPiA+IHA0ZF90
ICpwNGQsDQo+ID4gPiA+ICsJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxv
bmcNCj4gPiA+ID4gZW5kKQ0KPiA+ID4gPiAgew0KPiA+ID4gPiAgCXB1ZF90ICpwdWQ7DQo+ID4g
PiA+ICAJdW5zaWduZWQgbG9uZyBuZXh0Ow0KPiA+ID4gPiAtCWludCBlcnI7DQo+ID4gPiA+ICsJ
aW50IGVyciA9IDA7DQo+ID4gPiA+ICANCj4gPiA+ID4gLQlwdWQgPSBwdWRfYWxsb2MobW0sIHA0
ZCwgYWRkcik7DQo+ID4gPiA+ICsJcHVkID0gcHVkX2FsbG9jKGNsb3N1cmUtPm1tLCBwNGQsIGFk
ZHIpOw0KPiA+ID4gPiAgCWlmICghcHVkKQ0KPiA+ID4gPiAgCQlyZXR1cm4gLUVOT01FTTsNCj4g
PiA+ID4gKw0KPiA+ID4gPiAgCWRvIHsNCj4gPiA+ID4gIAkJbmV4dCA9IHB1ZF9hZGRyX2VuZChh
ZGRyLCBlbmQpOw0KPiA+ID4gPiAtCQllcnIgPSBhcHBseV90b19wbWRfcmFuZ2UobW0sIHB1ZCwg
YWRkciwgbmV4dCwNCj4gPiA+ID4gZm4sDQo+ID4gPiA+IGRhdGEpOw0KPiA+ID4gPiArCQlpZiAo
IWNsb3N1cmUtPmFsbG9jICYmDQo+ID4gPiA+IHB1ZF9ub25lX29yX2NsZWFyX2JhZChwdWQpKQ0K
PiA+ID4gPiArCQkJY29udGludWU7DQo+ID4gPiA+ICsJCWVyciA9IGFwcGx5X3RvX3BtZF9yYW5n
ZShjbG9zdXJlLCBwdWQsIGFkZHIsDQo+ID4gPiA+IG5leHQpOw0KPiA+ID4gPiAgCQlpZiAoZXJy
KQ0KPiA+ID4gPiAgCQkJYnJlYWs7DQo+ID4gPiA+ICAJfSB3aGlsZSAocHVkKyssIGFkZHIgPSBu
ZXh0LCBhZGRyICE9IGVuZCk7DQo+ID4gPiA+ICAJcmV0dXJuIGVycjsNCj4gPiA+ID4gIH0NCj4g
PiA+ID4gIA0KPiA+ID4gPiAtc3RhdGljIGludCBhcHBseV90b19wNGRfcmFuZ2Uoc3RydWN0IG1t
X3N0cnVjdCAqbW0sIHBnZF90DQo+ID4gPiA+ICpwZ2QsDQo+ID4gPiA+IC0JCQkJICAgICB1bnNp
Z25lZCBsb25nIGFkZHIsDQo+ID4gPiA+IHVuc2lnbmVkIGxvbmcNCj4gPiA+ID4gZW5kLA0KPiA+
ID4gPiAtCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQo+ID4gPiA+ICtzdGF0aWMg
aW50IGFwcGx5X3RvX3A0ZF9yYW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0K
PiA+ID4gPiBwZ2RfdCAqcGdkLA0KPiA+ID4gPiArCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRy
LCB1bnNpZ25lZCBsb25nDQo+ID4gPiA+IGVuZCkNCj4gPiA+ID4gIHsNCj4gPiA+ID4gIAlwNGRf
dCAqcDRkOw0KPiA+ID4gPiAgCXVuc2lnbmVkIGxvbmcgbmV4dDsNCj4gPiA+ID4gLQlpbnQgZXJy
Ow0KPiA+ID4gPiArCWludCBlcnIgPSAwOw0KPiA+ID4gPiAgDQo+ID4gPiA+IC0JcDRkID0gcDRk
X2FsbG9jKG1tLCBwZ2QsIGFkZHIpOw0KPiA+ID4gPiArCXA0ZCA9IHA0ZF9hbGxvYyhjbG9zdXJl
LT5tbSwgcGdkLCBhZGRyKTsNCj4gPiA+ID4gIAlpZiAoIXA0ZCkNCj4gPiA+ID4gIAkJcmV0dXJu
IC1FTk9NRU07DQo+ID4gPiA+ICsNCj4gPiA+ID4gIAlkbyB7DQo+ID4gPiA+ICAJCW5leHQgPSBw
NGRfYWRkcl9lbmQoYWRkciwgZW5kKTsNCj4gPiA+ID4gLQkJZXJyID0gYXBwbHlfdG9fcHVkX3Jh
bmdlKG1tLCBwNGQsIGFkZHIsIG5leHQsDQo+ID4gPiA+IGZuLA0KPiA+ID4gPiBkYXRhKTsNCj4g
PiA+ID4gKwkJaWYgKCFjbG9zdXJlLT5hbGxvYyAmJg0KPiA+ID4gPiBwNGRfbm9uZV9vcl9jbGVh
cl9iYWQocDRkKSkNCj4gPiA+ID4gKwkJCWNvbnRpbnVlOw0KPiA+ID4gPiArCQllcnIgPSBhcHBs
eV90b19wdWRfcmFuZ2UoY2xvc3VyZSwgcDRkLCBhZGRyLA0KPiA+ID4gPiBuZXh0KTsNCj4gPiA+
ID4gIAkJaWYgKGVycikNCj4gPiA+ID4gIAkJCWJyZWFrOw0KPiA+ID4gPiAgCX0gd2hpbGUgKHA0
ZCsrLCBhZGRyID0gbmV4dCwgYWRkciAhPSBlbmQpOw0KPiA+ID4gPiAgCXJldHVybiBlcnI7DQo+
ID4gPiA+ICB9DQo+ID4gPiA+ICANCj4gPiA+ID4gLS8qDQo+ID4gPiA+IC0gKiBTY2FuIGEgcmVn
aW9uIG9mIHZpcnR1YWwgbWVtb3J5LCBmaWxsaW5nIGluIHBhZ2UgdGFibGVzIGFzDQo+ID4gPiA+
IG5lY2Vzc2FyeQ0KPiA+ID4gPiAtICogYW5kIGNhbGxpbmcgYSBwcm92aWRlZCBmdW5jdGlvbiBv
biBlYWNoIGxlYWYgcGFnZSB0YWJsZS4NCj4gPiA+ID4gKy8qKg0KPiA+ID4gPiArICogYXBwbHlf
dG9fcGZuX3JhbmdlIC0gU2NhbiBhIHJlZ2lvbiBvZiB2aXJ0dWFsIG1lbW9yeSwNCj4gPiA+ID4g
Y2FsbGluZyBhDQo+ID4gPiA+IHByb3ZpZGVkDQo+ID4gPiA+ICsgKiBmdW5jdGlvbiBvbiBlYWNo
IGxlYWYgcGFnZSB0YWJsZSBlbnRyeQ0KPiA+ID4gPiArICogQGNsb3N1cmU6IERldGFpbHMgYWJv
dXQgaG93IHRvIHNjYW4gYW5kIHdoYXQgZnVuY3Rpb24gdG8NCj4gPiA+ID4gYXBwbHkNCj4gPiA+
ID4gKyAqIEBhZGRyOiBTdGFydCB2aXJ0dWFsIGFkZHJlc3MNCj4gPiA+ID4gKyAqIEBzaXplOiBT
aXplIG9mIHRoZSByZWdpb24NCj4gPiA+ID4gKyAqDQo+ID4gPiA+ICsgKiBJZiBAY2xvc3VyZS0+
YWxsb2MgaXMgc2V0IHRvIDEsIHRoZSBmdW5jdGlvbiB3aWxsIGZpbGwgaW4NCj4gPiA+ID4gdGhl
DQo+ID4gPiA+IHBhZ2UgdGFibGUNCj4gPiA+ID4gKyAqIGFzIG5lY2Vzc2FyeS4gT3RoZXJ3aXNl
IGl0IHdpbGwgc2tpcCBub24tcHJlc2VudCBwYXJ0cy4NCj4gPiA+ID4gKyAqIE5vdGU6IFRoZSBj
YWxsZXIgbXVzdCBlbnN1cmUgdGhhdCB0aGUgcmFuZ2UgZG9lcyBub3QNCj4gPiA+ID4gY29udGFp
bg0KPiA+ID4gPiBodWdlIHBhZ2VzLg0KPiA+ID4gPiArICogVGhlIGNhbGxlciBtdXN0IGFsc28g
YXNzdXJlIHRoYXQgdGhlIHByb3BlciBtbXVfbm90aWZpZXINCj4gPiA+ID4gZnVuY3Rpb25zIGFy
ZQ0KPiA+ID4gPiArICogY2FsbGVkLiBFaXRoZXIgaW4gdGhlIHB0ZSBsZWFmIGZ1bmN0aW9uIG9y
IGJlZm9yZSBhbmQgYWZ0ZXINCj4gPiA+ID4gdGhlDQo+ID4gPiA+IGNhbGwgdG8NCj4gPiA+ID4g
KyAqIGFwcGx5X3RvX3Bmbl9yYW5nZS4NCj4gPiA+IA0KPiA+ID4gVGhpcyBpcyB3cm9uZyB0aGVy
ZSBzaG91bGQgYmUgYSBiaWcgRkFUIHdhcm5pbmcgdGhhdCB0aGlzIGNhbg0KPiA+ID4gb25seSBi
ZQ0KPiA+ID4gdXNlDQo+ID4gPiBhZ2FpbnN0IG1tYXAgb2YgZGV2aWNlIGZpbGUuIFRoZSBwYWdl
IHRhYmxlIHdhbGtpbmcgYWJvdmUgaXMNCj4gPiA+IGJyb2tlbg0KPiA+ID4gZm9yDQo+ID4gPiB2
YXJpb3VzIHRoaW5nIHlvdSBtaWdodCBmaW5kIGluIGFueSBvdGhlciB2bWEgbGlrZSBUSFAsIGRl
dmljZQ0KPiA+ID4gcHRlLA0KPiA+ID4gaHVnZXRsYmZzLA0KPiA+IA0KPiA+IEkgd2FzIGZpZ3Vy
aW5nIHNpbmNlIHdlIGRpZG4ndCBleHBvcnQgdGhlIGZ1bmN0aW9uIGFueW1vcmUsIHRoZQ0KPiA+
IHdhcm5pbmcNCj4gPiBhbmQgY2hlY2tzIGNvdWxkIGJlIGxlZnQgdG8gaXRzIHVzZXJzLCBhc3N1
bWluZyB0aGF0IGFueSBvdGhlcg0KPiA+IGZ1dHVyZQ0KPiA+IHVzYWdlIG9mIHRoaXMgZnVuY3Rp
b24gd291bGQgcmVxdWlyZSBtbSBwZW9wbGUgYXVkaXQgYW55d2F5LiBCdXQgSQ0KPiA+IGNhbg0K
PiA+IG9mIGNvdXJzZSBhZGQgdGhhdCB3YXJuaW5nIGFsc28gdG8gdGhpcyBmdW5jdGlvbiBpZiB5
b3Ugc3RpbGwgd2FudA0KPiA+IHRoYXQ/DQo+IA0KPiBZZWFoIG1vcmUgd2FybmluZyBhcmUgYmV0
dGVyLCBwZW9wbGUgbWlnaHQgc3RhcnQgdXNpbmcgdGhpcywgaSBrbm93DQo+IHNvbWUgcG9lcGxl
IHVzZSB1bmV4cG9ydGVkIHN5bWJvbCBhbmQgdGhlbiByZXBvcnQgYnVncyB3aGlsZSB0aGV5DQo+
IGp1c3Qgd2VyZSBkb2luZyBzb21ldGhpbmcgaWxsZWdhbC4NCj4gDQo+ID4gPiAuLi4NCj4gPiA+
IA0KPiA+ID4gQWxzbyB0aGUgbW11IG5vdGlmaWVyIGNhbiBub3QgYmUgY2FsbCBmcm9tIHRoZSBw
Zm4gY2FsbGJhY2sgYXMNCj4gPiA+IHRoYXQNCj4gPiA+IGNhbGxiYWNrDQo+ID4gPiBoYXBwZW5z
IHVuZGVyIHBhZ2UgdGFibGUgbG9jayAodGhlIGNoYW5nZV9wdGUgbm90aWZpZXIgY2FsbGJhY2sN
Cj4gPiA+IGlzDQo+ID4gPiB1c2VsZXNzDQo+ID4gPiBhbmQgbm90IGVub3VnaCkuIFNvIGl0IF9t
dXN0XyBoYXBwZW4gYXJvdW5kIHRoZSBjYWxsIHRvDQo+ID4gPiBhcHBseV90b19wZm5fcmFuZ2UN
Cj4gPiANCj4gPiBJbiB0aGUgY29tbWVudHMgSSB3YXMgaGF2aW5nIGluIG1pbmQgdXNhZ2Ugb2Ys
IGZvciBleGFtcGxlDQo+ID4gcHRlcF9jbGVhcl9mbHVzaF9ub3RpZnkoKS4gQnV0IHlvdSdyZSB0
aGUgbW11X25vdGlmaWVyIGV4cGVydCBoZXJlLg0KPiA+IEFyZQ0KPiA+IHlvdSBzYXlpbmcgdGhh
dCBmdW5jdGlvbiBieSBpdHNlbGYgd291bGQgbm90IGJlIHN1ZmZpY2llbnQ/DQo+ID4gSW4gdGhh
dCBjYXNlLCBzaG91bGQgSSBqdXN0IHNjcmF0Y2ggdGhlIHRleHQgbWVudGlvbmluZyB0aGUgcHRl
DQo+ID4gbGVhZg0KPiA+IGZ1bmN0aW9uPw0KPiANCj4gcHRlcF9jbGVhcl9mbHVzaF9ub3RpZnko
KSBpcyB1c2VsZXNzIC4uLiBpIGhhdmUgcG9zdGVkIHBhdGNoZXMgdG8NCj4gZWl0aGVyDQo+IHJl
c3RvcmUgaXQgb3IgcmVtb3ZlIGl0LiBJbiBhbnkgY2FzZSB5b3UgbXVzdCBjYWxsIG1tdSBub3Rp
ZmllciByYW5nZQ0KPiBhbmQNCj4gdGhleSBjYW4gbm90IGhhcHBlbiB1bmRlciBsb2NrLiBZb3Ug
dXNhZ2UgbG9va2VkIGZpbmUgKGluIHRoZSBuZXh0DQo+IHBhdGNoKQ0KPiBidXQgaSB3b3VsZCBy
YXRoZXIgaGF2ZSBhIGJpdCBvZiBjb21tZW50IGhlcmUgdG8gbWFrZSBzdXJlIHBlb3BsZSBhcmUN
Cj4gYWxzbw0KPiBhd2FyZSBvZiB0aGF0Lg0KPiANCj4gV2hpbGUgd2UgY2FuIGhvcGUgdGhhdCBw
ZW9wbGUgd291bGQgY2MgbW0gd2hlbiB1c2luZyBtbSBmdW5jdGlvbiwgaXQNCj4gaXMNCj4gbm90
IGFsd2F5cyB0aGUgY2FzZS4gU28gaSByYXRoZXIgYmUgY2F1dGlvdXMgYW5kIHdhcm4gaW4gY29t
bWVudCBhcw0KPiBtdWNoDQo+IGFzIHBvc3NpYmxlLg0KPiANCg0KT0suIFVuZGVyc3Rvb2QuIEFs
bCB0aGlzIGFjdHVhbGx5IG1ha2VzIG1lIHRlbmQgdG8gd2FudCB0byB0cnkgYSBiaXQNCmhhcmRl
ciB1c2luZyBhIHNsaWdodCBtb2RpZmljYXRpb24gdG8gdGhlIHBhZ2V3YWxrIGNvZGUgaW5zdGVh
ZC4gRG9uJ3QNCnJlYWxseSB3YW50IHRvIGVuY291cmFnZSB0d28gcGFyYWxsZWwgY29kZSBwYXRo
cyBkb2luZyBlc3NlbnRpYWxseSB0aGUNCnNhbWUgdGhpbmc7IG9uZSBnb29kIGFuZCBvbmUgYmFk
Lg0KDQpPbmUgdGhpbmcgdGhhdCBjb25mdXNlcyBtZSBhIGJpdCB3aXRoIHRoZSBwYWdld2FsayBj
b2RlIGlzIHRoYXQgY2FsbGVycw0KKGZvciBleGFtcGxlIHNvZnRkaXJ0eSkgdHlwaWNhbGx5IGNh
bGwNCm1tdV9ub3RpZmllcl9pbnZhbGlkYXRlX3JhbmdlX3N0YXJ0KCkgYXJvdW5kIHRoZSBwYWdl
d2FsaywgYnV0IHRoZW4gaWYNCml0IGVuZHMgdXAgc3BsaXR0aW5nIGEgcG1kLCBtbXVfbm90aWZp
ZXJfaW52YWxpZGF0ZV9yYW5nZSBpcyBjYWxsZWQNCmFnYWluLCB3aXRoaW4gdGhlIGZpcnN0IHJh
bmdlLiBEb2NzIGFyZW4ndCByZWFsbHkgY2xlYXIgd2hldGhlciB0aGF0J3MNCnBlcm1pdHRlZCBv
ciBub3QuIElzIGl0Pw0KDQpUaGFua3MsDQpUaG9tYXMNCg0KPiBDaGVlcnMsDQo+IErDqXLDtG1l
DQo=

