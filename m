Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0D01C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C18D2184A
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="xJ2lO5cA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C18D2184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622DC8E0007; Wed, 27 Feb 2019 13:05:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A9428E0001; Wed, 27 Feb 2019 13:05:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44BAF8E0007; Wed, 27 Feb 2019 13:05:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1889C8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:05:40 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id c186so7621743oih.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:05:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=G9EJJ6Os9exzGqiba14eICDN0E9F2QYcsfbkjTwPVgw=;
        b=Rnl7qlK5TKG+VRPy6lHgrL50NdBUN2Vw3dH7NpiHTNL39E4hlL9GNKFX5kqNsU2ZpA
         nGmTTezm3ik/bBrRgYaz4M/I48bAAEnNx8JG6T4LeNOcL3smbzHbk7NFzqyFnJFyLIBI
         ELppuIKOPtlFe9qDh9Fs+GikhDZRwIhwKKS0qlv72f+hsWVAP5N002vpC/ZfLLxOthC0
         pJOZ3ESBbePibSmoiBKs70XnAZoMr9ZC3dg6PVAb5e7uNrkx260vPfl9J37GeXEnWJyy
         0XZ01fIPUoFSTFKy0zUWqUWz34Y1R//H3URGvMgZx5Y+752KBFuNAivDw2tnbc0lJMlD
         uKxQ==
X-Gm-Message-State: AHQUAua4/Jrh89YqU1S837eRrtQ1aFMgz6RDZLjMCr/V3LU3ANCXeQNe
	BXQlnr65v3Chec/H8FOH5I0m9zuWNW9iR73YK5PZl1EfGCQ+pba1+5BbMxT1zGSvEXdI2F3d0TL
	JVfteaeamHF6nkN3LjXV9Yx5RvNN7E9zJMxFi8pmCLxLtPUfisxSWJ4CviYv/s+c=
X-Received: by 2002:aca:ab94:: with SMTP id u142mr394293oie.58.1551290739790;
        Wed, 27 Feb 2019 10:05:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqzGQuFEykFjs9i75IFFRjZKxrh7DSceUdMEc8FtLKax0gkau3BFPAAmBZgBzF5LZGAATIJQ
X-Received: by 2002:aca:ab94:: with SMTP id u142mr394232oie.58.1551290738733;
        Wed, 27 Feb 2019 10:05:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551290738; cv=none;
        d=google.com; s=arc-20160816;
        b=YMt0Q3c0C5K+8XEscPkdi4uXkT2dOs8Ggo4JGNILb6YbpWgRmzsYX3yWuFoAIetdyY
         EGPNpRQSN8si4WVEOyJol0yDGenyV3Zxqwqm2OAsxt47axFmk/WLACM2a0/4CWbN6sWC
         eexS26LPWig+0E53DwQO9CM61Bl+MM9bDivMpsJtLWG1FlS9qvDz52/IRe1/WG5FlujA
         Oc+4HOp1/ImkJryOluGlvyEqU2gqaajW/BfSL0KPvik2Tata8Zrs8g/ZbBtA7puMPGGe
         LsBMHtym43dSM4u+8x5WObbOdpnPgkIo4LbYjVYmlFNgUv5O5wTyCTsxjM7XsFW3fO9i
         uMZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=G9EJJ6Os9exzGqiba14eICDN0E9F2QYcsfbkjTwPVgw=;
        b=tUoDUnDLECX+YqfAjRfYRQ6cBZvmZEarjyxwJW5f3RtGqmaHdHIk6nBjICjG//sQCP
         krDB/67saNPhdMkNBbu2qBuUxyjtn8/HxikgOQFajaZQQyDi9UazTY5DfD5jDwRdbGAS
         PyGbzQiWQhnTuElvD6ihcSRikyQFqJwQoZXKZgmwz7p7alfS1Z2Jj3aB5+Yx2spMhL2X
         zGaaqv0I+lcmrAOPeu6yKDG90i+t/z+sOcknmSbgbLbfIYxxvB6ISE0RVy8w6956C4Tz
         eudmOIV/2CSMXR5EY+X5VqmW6opoX8Y04RQmsvDwNk5miXtjpsAOQWTNr9kEbFPk2O8f
         PffA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=xJ2lO5cA;
       spf=neutral (google.com: 40.107.71.53 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710053.outbound.protection.outlook.com. [40.107.71.53])
        by mx.google.com with ESMTPS id k192si6491643oih.148.2019.02.27.10.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 10:05:38 -0800 (PST)
Received-SPF: neutral (google.com: 40.107.71.53 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) client-ip=40.107.71.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=xJ2lO5cA;
       spf=neutral (google.com: 40.107.71.53 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=G9EJJ6Os9exzGqiba14eICDN0E9F2QYcsfbkjTwPVgw=;
 b=xJ2lO5cAblPZZCrdf1/sqsBI6lX9A1HMmvAnY3a7Zx25+tYc9+FeLP0uXAtc1sewlgEV4NTAa3n8pF/dn8+dTgdHNeCBYgNa/HmXqIv7k50DcdpAKw/TyiC8zt+HT42d9UOg8NH+WKG9J6t3Txe7O1sC/YV+ZQ5H/1ydA1hA0Zs=
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com (10.174.106.148) by
 DM5PR1201MB2474.namprd12.prod.outlook.com (10.172.87.136) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Wed, 27 Feb 2019 18:05:37 +0000
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7]) by DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7%8]) with mapi id 15.20.1643.022; Wed, 27 Feb 2019
 18:05:37 +0000
From: "Yang, Philip" <Philip.Yang@amd.com>
To: =?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: KASAN caught amdgpu / HMM use-after-free
Thread-Topic: KASAN caught amdgpu / HMM use-after-free
Thread-Index: AQHUzr5Iv9fZwgvZtkOvi9fDH0RyfqXzjl0AgABZOYCAAAj0gA==
Date: Wed, 27 Feb 2019 18:05:36 +0000
Message-ID: <35d7e134-6eef-9732-8ebf-83256e40eb65@amd.com>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
 <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
 <c26fa310-38d1-acba-cf82-bc6dc2f782c0@daenzer.net>
In-Reply-To: <c26fa310-38d1-acba-cf82-bc6dc2f782c0@daenzer.net>
Accept-Language: en-ZA, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0022.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::35) To DM5PR1201MB0155.namprd12.prod.outlook.com
 (2603:10b6:4:55::20)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Philip.Yang@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [165.204.55.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e27c1e33-1b32-4215-8fd3-08d69cde2cb4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DM5PR1201MB2474;
x-ms-traffictypediagnostic: DM5PR1201MB2474:
x-microsoft-exchange-diagnostics:
 1;DM5PR1201MB2474;20:+xPNjvwOnez9R2oDRWeWr4H1TogtukTVf5umu1BkCVspJ61RQbZZq3vNg0sfOVkZx340/2a3T3Fvlmp2UngcTd9gnxMgJJiuKPqLm9IFssc4Tr8XJi2CFCpgDG8sSbfxDz9JpgCbs/78PLSVr1RSsxTRc2FqxMp31B/Q4VgUMX1jRH2X+BxRUN+gataFEpc4zN3rkpaT/glX/R69bpJJWoZY04avIbQ8bKdOvhZSnpkZmqE9cIxkuOnb7D044ATU
x-microsoft-antispam-prvs:
 <DM5PR1201MB2474E47945747CBB3F743716E6740@DM5PR1201MB2474.namprd12.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(39860400002)(366004)(136003)(396003)(189003)(199004)(81156014)(81166006)(68736007)(72206003)(478600001)(3846002)(486006)(8676002)(4326008)(6116002)(6246003)(31686004)(25786009)(31696002)(86362001)(99286004)(11346002)(446003)(256004)(186003)(97736004)(316002)(14454004)(2616005)(106356001)(105586002)(5660300002)(54906003)(476003)(52116002)(110136005)(6512007)(71190400001)(71200400001)(102836004)(6436002)(36756003)(6506007)(305945005)(386003)(7736002)(66066001)(53936002)(76176011)(53546011)(4744005)(26005)(6486002)(229853002)(2906002)(8936002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR1201MB2474;H:DM5PR1201MB0155.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 6xjmUdTSAJMBJigYZ/ow8hj0MqNsxXetzftD4MpzDxUus1bkvSfwKJjtd8XIw5ehb6NzHSVr6WeHzaL2QSheHwUM2HIkMsk55YhnFJIAaIL+yGGBEY2x+FIDu4XedxDBRNmaVjJJphcP5qcBwP/kGcFZLwbsCXw1u97G2KCoVwG+92nxJOMq7CfdMPvjekPc6i5SxZEv8RwBXviyE6F27dT94EELDroG01Dn0nBhFy/vqlasO8mm/uqThaWGPyvblgRFPFA0D1iHDF8oGrV+vzuw9f/jU+auLmA7iZTEWtl1dD/VAU6YJulbzpfifloT17LlBF8rG73GjczvwlX5twfJW1NZKsbni0x2rB85LYlgg7dGdI2uxB8TS1EZtxen0K4JMbnHFvlqaorC+UhT2IxSr3hL59QZO1ybaFrXlII=
Content-Type: text/plain; charset="utf-8"
Content-ID: <4B97951C6861FF4681AFBA5D9CE2BADB@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e27c1e33-1b32-4215-8fd3-08d69cde2cb4
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 18:05:36.3064
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR1201MB2474
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

YW1kLXN0YWdpbmctZHJtLW5leHQgd2lsbCByZWJhc2UgdG8ga2VybmVsIDUuMSB0byBwaWNrdXAg
dGhpcyBmaXggDQphdXRvbWF0aWNhbGx5LiBBcyBhIHNob3J0LXRlcm0gd29ya2Fyb3VuZCwgcGxl
YXNlIGNoZXJyeS1waWNrIHRoaXMgZml4IA0KaW50byB5b3VyIGxvY2FsIHJlcG9zaXRvcnkuDQoN
ClJlZ2FyZHMsDQpQaGlsaXANCg0KT24gMjAxOS0wMi0yNyAxMjozMyBwLm0uLCBNaWNoZWwgRMOk
bnplciB3cm90ZToNCj4gT24gMjAxOS0wMi0yNyA2OjE0IHAubS4sIFlhbmcsIFBoaWxpcCB3cm90
ZToNCj4+IEhpIE1pY2hlbCwNCj4+DQo+PiBZZXMsIEkgZm91bmQgdGhlIHNhbWUgaXNzdWUgYW5k
IHRoZSBidWcgaGFzIGJlZW4gZml4ZWQgYnkgSmVyb21lOg0KPj4NCj4+IDg3NmI0NjIxMjBhYSBt
bS9obW06IHVzZSByZWZlcmVuY2UgY291bnRpbmcgZm9yIEhNTSBzdHJ1Y3QNCj4+DQo+PiBUaGUg
Zml4IGlzIG9uIGhtbS1mb3ItNS4xIGJyYW5jaCwgSSBjaGVycnktcGljayBpdCBpbnRvIG15IGxv
Y2FsIGJyYW5jaA0KPj4gdG8gd29ya2Fyb3VuZCB0aGUgaXNzdWUuDQo+IA0KPiBQbGVhc2UgcHVz
aCBpdCB0byBhbWQtc3RhZ2luZy1kcm0tbmV4dCwgc28gdGhhdCBvdGhlcnMgZG9uJ3QgcnVuIGlu
dG8NCj4gdGhlIGlzc3VlIGFzIHdlbGwuDQo+IA0KPiANCg==

