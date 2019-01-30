Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F2BDC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:33:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B904520815
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:33:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="xoadB6Lr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B904520815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D438E0002; Wed, 30 Jan 2019 05:33:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DDF38E0001; Wed, 30 Jan 2019 05:33:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CD128E0002; Wed, 30 Jan 2019 05:33:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1020E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:33:43 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t17so12885717ywc.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:33:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=D+ebTc0+10tslO8wD4HXKAboq0wLl7gDqKO2drmwrK0=;
        b=plQtGQqWR0k4GRqJHndetNwS8Ifov3eBI89RF2i0k4Np6h8yDB96YNJskgM9VGi18z
         wAjiSMobf5jOvKuJ2RKv3eHXFAFq8zRthgauS2p7aPFYdegXQDOwaf3eRT2NscHeqi5H
         ODP6w+Q51aXv53Q98LW0fYQhtf0fx/6qNB0QWH8NlASRraO8H1SNcRlOBcCeDsEn7lkU
         zoDKnKK0k7EDsrb7L3CC7K5pG2E23z3JgyrZ8xf+/3e46FxSwkz3+G6Btpd8mgj9mSQU
         AGo/Fjr4nE1ZW26IwwUT8dKCXpizBx/qz3vGQshrbP3GFuRwP4o0L9hNGBgBZBBm4nlL
         yU1Q==
X-Gm-Message-State: AJcUukcLZGd1hkbtVsPJdbwRUV3AA47Jx7V5yxwyzTJTyDO29sKt6lMK
	N9huy1+SX74nUHSw/sdPoBeB2u6Vs2F8uVosH+h3kq+qbSMWTIlEANYqPJcUt98SXASpT4Xg5VX
	EtN0oDNl2OXGWnjFEWG9qF3l4oMpWSfpitjBXS/+WNmTkJ5Xwk1jk1IIt5e0w1pE=
X-Received: by 2002:a81:5f88:: with SMTP id t130mr28786116ywb.494.1548844422696;
        Wed, 30 Jan 2019 02:33:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN76wwpCMHRqY86fn19blZOcbt6NWfnvYVlM+CcPdzp4xcba3CuQQ8FVXnfBhe5ltmKRu9tj
X-Received: by 2002:a81:5f88:: with SMTP id t130mr28786088ywb.494.1548844422053;
        Wed, 30 Jan 2019 02:33:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548844422; cv=none;
        d=google.com; s=arc-20160816;
        b=WG65j5b6wquynZdBYGk/MNhpU92guEXaPhsaJMG6o1DTHaDF5bY0nzasFOemvat2CZ
         iCK4zQPjbtFPRh0RpEEwafe47rCfD2qfmQkafoeA1Ga5hXAkWnjKbuC0aAjpCz6ll542
         Gd+O0qrTd/7vLztfdRao5135pY9IKoIqpt8jpnKoquUW2hMDZz2qSzik3mk5WT1RivtP
         7YWfISYRW0OC31lMAYeQbvDA2PsLy7wVSxN/pdlgjG0R1dZFFI9GshD5ddIcy/hxY8Fg
         ZkiU+qDlKv5r0Tn8Oog9HhZtdoDIoi57SKDg27q1H+Bq8HBBjm5uiSxZYIY+H3mdHm2b
         4Svg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=D+ebTc0+10tslO8wD4HXKAboq0wLl7gDqKO2drmwrK0=;
        b=QgMRTNYWjywDsGZgrFZikeFFBxuHOxeskpAaNTGuVQSgmdMZrUmOefCbLMllY4obx8
         WB6QVxdgmxRJxepwx61yZ0RQ14wKxysE3oLcU15ZkmyRWeqdhnE0R4Sx4ceg2C8kHYS/
         sYRCuEsNHUItmCsCXod8aA80J8iMJmRYDU1ygioNAwPjCuGBGcj8kxCJH9Nl7yzKJxjN
         +cGsydMy5NzSiZzi/4AN77diJ9xau93AahBOCYvksr/j3oGjnhvpIufy2QRGorgwYQeP
         otd+hTKf8J6q/3796IlZ3DEObmqqMyz8krXIWLAQPpm58keFEqIwzoEZixQEgf6v1BQ9
         9acw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=xoadB6Lr;
       spf=neutral (google.com: 40.107.70.64 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700064.outbound.protection.outlook.com. [40.107.70.64])
        by mx.google.com with ESMTPS id i129si592300yba.47.2019.01.30.02.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 02:33:41 -0800 (PST)
Received-SPF: neutral (google.com: 40.107.70.64 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) client-ip=40.107.70.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=xoadB6Lr;
       spf=neutral (google.com: 40.107.70.64 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=D+ebTc0+10tslO8wD4HXKAboq0wLl7gDqKO2drmwrK0=;
 b=xoadB6Lrys/AU7ic2NaXXhgQ7gnN3HzQ/i1w6cgHRvsLrUvdROGkP61fZ+kBl4ZR3HNBEkjs3taGd4kVKAJuIrkF3hhE3sCVwuaF2Q9stKYraS7YA3ujrcE9tE4RHAKGsB2WmyBTvsSf/2eRdFnaBoXOVW525vxWvQ9z1r9Rctk=
Received: from DM5PR12MB1546.namprd12.prod.outlook.com (10.172.36.23) by
 DM5PR12MB1531.namprd12.prod.outlook.com (10.172.34.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Wed, 30 Jan 2019 10:33:40 +0000
Received: from DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::35a3:c1b4:5ad0:ec6e]) by DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::35a3:c1b4:5ad0:ec6e%10]) with mapi id 15.20.1558.023; Wed, 30 Jan
 2019 10:33:40 +0000
From: "Koenig, Christian" <Christian.Koenig@amd.com>
To: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>
CC: Logan Gunthorpe <logang@deltatee.com>, Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rAgVEbp32b0EuMjAjrX5/WJ6XGkyOAgAAJwICAAAYHgIAAEq6AgAAFP4CAALlkAIAAKk0A
Date: Wed, 30 Jan 2019 10:33:39 +0000
Message-ID: <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
In-Reply-To: <20190130080208.GC29665@lst.de>
Accept-Language: de-DE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [2a02:908:1252:fb60:be8a:bd56:1f94:86e7]
x-clientproxiedby: AM6PR05CA0027.eurprd05.prod.outlook.com
 (2603:10a6:20b:2e::40) To DM5PR12MB1546.namprd12.prod.outlook.com
 (2603:10b6:4:8::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Christian.Koenig@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DM5PR12MB1531;20:FloESh8INSWxgfyoZKWhQ8zAB+q9wNINSjE+hwqS7lrM+vEfhaK9aXKHPCBnCjjKY/vIJDY8Uw7bRc9l/dQ/ji5rz5ipoN3frBcblJ5BAozuR2tzzbYUsqTHvERtSlM3w0xiWVT5Xa5h+okk7ReCZprJI+JzDUMfk7FXxmhSDpXL/jrfoHkCBVDa/GI5Ud0e5ImKSpHsnRODwxxuLyoCaD2b6h2GcpzamDKHS5jHfvrNi3cCAjVN0FrN+Q6tPk5j
x-ms-office365-filtering-correlation-id: 6c32b3c0-d7dc-4204-2d2e-08d6869e6629
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DM5PR12MB1531;
x-ms-traffictypediagnostic: DM5PR12MB1531:
x-microsoft-antispam-prvs:
 <DM5PR12MB153189765275979C9F6E9FA883900@DM5PR12MB1531.namprd12.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(396003)(39860400002)(366004)(136003)(199004)(189003)(305945005)(4326008)(64126003)(110136005)(86362001)(54906003)(316002)(53936002)(58126008)(256004)(72206003)(81166006)(8676002)(8936002)(81156014)(2906002)(217873002)(7736002)(478600001)(93886005)(386003)(25786009)(186003)(99286004)(65826007)(76176011)(65806001)(52116002)(68736007)(65956001)(102836004)(36756003)(6246003)(229853002)(14454004)(46003)(6116002)(446003)(7416002)(71200400001)(6506007)(11346002)(105586002)(31696002)(6486002)(97736004)(6436002)(71190400001)(486006)(2616005)(6512007)(31686004)(476003)(106356001);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR12MB1531;H:DM5PR12MB1546.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 9aiyJXBkI1aV6nhi+ENcbwQFQxjsBTCy2lYBNKahnq+5cEWYvFhhKrxgA1BWYUzd8gy7mm7Tj27e/bUh2uK6c6D0AqGjc2rpQ1sx+TM2OFsYbcm2WfRXE/j7at3jBWf2HvyKK76tvScRL5Oczng23TCDog6Ep/4aI0qhYWp0GvG9hPGOnXsKopcW61Ex0kIIaeW/NC2FUgLbWqxPcGAoSM81E440DAlSwpR19qg2rThXlHChI80Hde8uUoYKCybh25e21kclDxSLPadh43ar4Q4zfVhwJsxAGSA3HJk0YZWFSGOdP1k5ajfj8gn/cVWi81N/9BFVo9u+ubJA3sfGe/ns5AJwsqZv4EjYX57MEdIuhTQJX5UHQkafZ30cQ/nxJaxUJKOeK4QxVB1Qef832IozbGFtXJTMa0VhwukVFh0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0297C7D5305B774FB9CFD8B1E00EE95C@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6c32b3c0-d7dc-4204-2d2e-08d6869e6629
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 10:33:36.8750
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR12MB1531
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

QW0gMzAuMDEuMTkgdW0gMDk6MDIgc2NocmllYiBDaHJpc3RvcGggSGVsbHdpZzoNCj4gT24gVHVl
LCBKYW4gMjksIDIwMTkgYXQgMDg6NTg6MzVQTSArMDAwMCwgSmFzb24gR3VudGhvcnBlIHdyb3Rl
Og0KPj4gT24gVHVlLCBKYW4gMjksIDIwMTkgYXQgMDE6Mzk6NDlQTSAtMDcwMCwgTG9nYW4gR3Vu
dGhvcnBlIHdyb3RlOg0KPj4NCj4+PiBpbXBsZW1lbnQgdGhlIG1hcHBpbmcuIEFuZCBJIGRvbid0
IHRoaW5rIHdlIHNob3VsZCBoYXZlICdzcGVjaWFsJyB2bWEncw0KPj4+IGZvciB0aGlzICh0aG91
Z2ggd2UgbWF5IG5lZWQgc29tZXRoaW5nIHRvIGVuc3VyZSB3ZSBkb24ndCBnZXQgbWFwcGluZw0K
Pj4+IHJlcXVlc3RzIG1peGVkIHdpdGggZGlmZmVyZW50IHR5cGVzIG9mIHBhZ2VzLi4uKS4NCj4+
IEkgdGhpbmsgSmVyb21lIGV4cGxhaW5lZCB0aGUgcG9pbnQgaGVyZSBpcyB0byBoYXZlIGEgJ3Nw
ZWNpYWwgdm1hJw0KPj4gcmF0aGVyIHRoYW4gYSAnc3BlY2lhbCBzdHJ1Y3QgcGFnZScgYXMsIHJl
YWxseSwgd2UgZG9uJ3QgbmVlZCBhDQo+PiBzdHJ1Y3QgcGFnZSBhdCBhbGwgdG8gbWFrZSB0aGlz
IHdvcmsuDQo+Pg0KPj4gSWYgSSByZWNhbGwgeW91ciBlYXJsaWVyIGF0dGVtcHRzIGF0IGFkZGlu
ZyBzdHJ1Y3QgcGFnZSBmb3IgQkFSDQo+PiBtZW1vcnksIGl0IHJhbiBhZ3JvdW5kIG9uIGlzc3Vl
cyByZWxhdGVkIHRvIE9fRElSRUNUL3NnbHMsIGV0YywgZXRjLg0KPiBTdHJ1Y3QgcGFnZSBpcyB3
aGF0IG1ha2VzIE9fRElSRUNUIHdvcmssIHVzaW5nIHNnbHMgb3IgYmlvdmVjcywgZXRjIG9uDQo+
IGl0IHdvcmsuICBXaXRob3V0IHN0cnVjdCBwYWdlIG5vbmUgb2YgdGhlIGFib3ZlIGNhbiB3b3Jr
IGF0IGFsbC4gIFRoYXQNCj4gaXMgd2h5IHdlIHVzZSBzdHJ1Y3QgcGFnZSBmb3IgYmFja2luZyBC
QVJzIGluIHRoZSBleGlzdGluZyBQMlAgY29kZS4NCj4gTm90IHRoYXQgSSdtIGEgcGFydGljdWxh
ciBmYW4gb2YgY3JlYXRpbmcgc3RydWN0IHBhZ2UgZm9yIHRoaXMgZGV2aWNlDQo+IG1lbW9yeSwg
YnV0IHdpdGhvdXQgbWFqb3IgaW52YXNpdmUgc3VyZ2VyeSB0byBsYXJnZSBwYXJ0cyBvZiB0aGUg
a2VybmVsDQo+IGl0IGlzIHRoZSBvbmx5IHdheSB0byBtYWtlIGl0IHdvcmsuDQoNClRoZSBwcm9i
bGVtIHNlZW1zIHRvIGJlIHRoYXQgc3RydWN0IHBhZ2UgZG9lcyB0d28gdGhpbmdzOg0KDQoxLiBN
ZW1vcnkgbWFuYWdlbWVudCBmb3Igc3lzdGVtIG1lbW9yeS4NCjIuIFRoZSBvYmplY3QgdG8gd29y
ayB3aXRoIGluIHRoZSBJL08gbGF5ZXIuDQoNClRoaXMgd2FzIGRvbmUgYmVjYXVzZSBhIGdvb2Qg
cGFydCBvZiB0aGF0IHN0dWZmIG92ZXJsYXBzLCBsaWtlIHJlZmVyZW5jZSANCmNvdW50aW5nIGhv
dyBvZnRlbiBhIHBhZ2UgaXMgdXNlZC7CoCBUaGUgcHJvYmxlbSBub3cgaXMgdGhhdCB0aGlzIGRv
ZXNuJ3QgDQp3b3JrIHZlcnkgd2VsbCBmb3IgZGV2aWNlIG1lbW9yeSBpbiBzb21lIGNhc2VzLg0K
DQpGb3IgZXhhbXBsZSBvbiBHUFVzIHlvdSB1c3VhbGx5IGhhdmUgYSBsYXJnZSBhbW91bnQgb2Yg
bWVtb3J5IHdoaWNoIGlzIA0Kbm90IGV2ZW4gYWNjZXNzaWJsZSBieSB0aGUgQ1BVLiBJbiBvdGhl
ciB3b3JkcyB5b3UgY2FuJ3QgZWFzaWx5IGNyZWF0ZSBhIA0Kc3RydWN0IHBhZ2UgZm9yIGl0IGJl
Y2F1c2UgeW91IGNhbid0IHJlZmVyZW5jZSBpdCB3aXRoIGEgcGh5c2ljYWwgQ1BVIA0KYWRkcmVz
cy4NCg0KTWF5YmUgc3RydWN0IHBhZ2Ugc2hvdWxkIGJlIHNwbGl0IHVwIGludG8gc21hbGxlciBz
dHJ1Y3R1cmVzPyBJIG1lYW4gDQppdCdzIHJlYWxseSBvdmVybG9hZGVkIHdpdGggZGF0YS4NCg0K
Q2hyaXN0aWFuLg0KDQoNCg==

