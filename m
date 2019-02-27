Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B4B3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30C2C2183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:14:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="GFEjBbFN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30C2C2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9EC18E0003; Wed, 27 Feb 2019 12:14:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4F938E0001; Wed, 27 Feb 2019 12:14:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A16BD8E0003; Wed, 27 Feb 2019 12:14:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 432558E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:14:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o25so7129479edr.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:14:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=og5KX0cHCtnyQVwvgHPQlKFf36uyq4g6zJgf/DGtrIM=;
        b=YzcO2FxWBeXuh6eVlHqSqbsmPZxNGVoYz2qCgi8Vx+1vk0CiiO7FZopNdiRZnUQYVZ
         uBGvbxZuFQEKm9mDQm380o8/rhPPfz6b4o9PJpC7ZfhT3ZhEoNSu/Q4QeVJGzUaslesp
         yIB07HGXAWcPfJFFqYE5XYN3OAwZqBOQddf2/SfkAkCz7PUWmHM2fpCZ900V5H2Y6tmC
         qpMwj5ye1SrRSKpTzf2KfN442VwUVLVBuxwWWAyb8d1/cH0BIItZ1C3nFWOkPCZxtVS8
         CcnjUa7t1naRpd4TkolE0WBZT+ld5kRxicXH/QFFmTrbpAxL8NZxGCYlW8iKTDPpGlan
         OhpA==
X-Gm-Message-State: AHQUAuYhYzykMk+kd25BrFkEI5zl7eCoxCFTJ3HfMInBz8LHdZCePkZH
	VU/LFTPX1SJkN4MJSi+Z+tQ0XKbEcpxmSi8MSMHZegPnwOUH8U52WJSo+JP3fLysxJDMbImUEMl
	7c8xZCMu+TbVLCzAfjZOI4QpskJdqApb/GdiAs3WLFty3nKO/ECYODCwC+GIH0nE=
X-Received: by 2002:a17:906:5e0d:: with SMTP id n13mr1128080eju.139.1551287648792;
        Wed, 27 Feb 2019 09:14:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCiDGgxqB3d9nJ7aH5IlNgXXf0UtOURIWOHAF/6604ywp+oN4RatxMxtyOVG+nd8QUnV6v
X-Received: by 2002:a17:906:5e0d:: with SMTP id n13mr1127991eju.139.1551287647334;
        Wed, 27 Feb 2019 09:14:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287647; cv=none;
        d=google.com; s=arc-20160816;
        b=SCbcSp/5zAFCDAGuhS2OAv/Iw4FIEovhothpESiD8W/x3l+Z6sALEaX/QouOL/JjjA
         V67CKsSu9mXXQ2M8VPQ6LAEHyoBOs/uP0U4Cus/Up3DyBjaULxs/O/94kHWn9UD49PkU
         SF+lJY5xNKZBQWtJl67tB4aBno8+6WdJE2BEkDCUU3BmfJoxXPy5FQe0k0Y8D+Vk9S65
         Dc5KHV7ttvfAKMlp+4XcFEktCmGuXAxNs4X9QyKK+xmHqMB2j+0Fo0SZf7yKDQcxmw9v
         TZ6y1SCD9zndYOvLm+NE0Rprjw6s0M4tKuQSzey465uvnDDwVZC0Lk9uFAAObZExoVvh
         0aCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=og5KX0cHCtnyQVwvgHPQlKFf36uyq4g6zJgf/DGtrIM=;
        b=zfxb3W9bgJaTFHbt1J6aMkhXMNWRZa47kJ6MfFJjK5oxuwqCgyZOCMtPwSyA9ZqIlS
         h9+gRk2DYvkETbQesYobRI6JCwnHqph4AID2LuElX/hZpOv5j0PzRaZ1Moxj7caiXZw5
         OepWZAza9tYMYSZ0U8MifHQLYk+IFCCfmTL/M3lylRG22BFA+O0TZvh55BIpYl2uiFz2
         0cpTtRS+du5q1jaDxpRSSyXCsWwCehgLoTPNhfqEM3xTTCDX3OXBHR2WcI/ykhBZgCVy
         d6M6hm4VS6ifvqIeJZtfOEqrXs6Xu+H8TZ9acXVeCZ+qiHskpiQEeseWLXhsPV+TQbrX
         NtCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=GFEjBbFN;
       spf=neutral (google.com: 40.107.77.45 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770045.outbound.protection.outlook.com. [40.107.77.45])
        by mx.google.com with ESMTPS id k8si4670724eda.4.2019.02.27.09.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 09:14:07 -0800 (PST)
Received-SPF: neutral (google.com: 40.107.77.45 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) client-ip=40.107.77.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=GFEjBbFN;
       spf=neutral (google.com: 40.107.77.45 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=og5KX0cHCtnyQVwvgHPQlKFf36uyq4g6zJgf/DGtrIM=;
 b=GFEjBbFNKf0tJykFfwpI/Zt3gjJPdKPB843vMmkd8HAqHC4Xz667gqCIAza7AR/ok7/dryGpGB2jauD0mjEhlaXzBThxWViniTZ3wAWyvMP3t1GH0dXkT4sbHfsh8DccPkQvRwFLc7yvI+mzaK8Vatm8DPEUZBn8sVdm44i2eLE=
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com (10.174.106.148) by
 DM5PR1201MB2555.namprd12.prod.outlook.com (10.172.91.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Wed, 27 Feb 2019 17:14:05 +0000
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7]) by DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7%8]) with mapi id 15.20.1643.022; Wed, 27 Feb 2019
 17:14:05 +0000
From: "Yang, Philip" <Philip.Yang@amd.com>
To: =?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
CC: "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: KASAN caught amdgpu / HMM use-after-free
Thread-Topic: KASAN caught amdgpu / HMM use-after-free
Thread-Index: AQHUzr5Iv9fZwgvZtkOvi9fDH0RyfqXz4i4A
Date: Wed, 27 Feb 2019 17:14:04 +0000
Message-ID: <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
In-Reply-To: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
Accept-Language: en-ZA, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0043.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:1::20) To DM5PR1201MB0155.namprd12.prod.outlook.com
 (2603:10b6:4:55::20)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Philip.Yang@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [165.204.55.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6f980818-f3cf-4de9-5057-08d69cd6f9ab
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DM5PR1201MB2555;
x-ms-traffictypediagnostic: DM5PR1201MB2555:
x-microsoft-exchange-diagnostics:
 1;DM5PR1201MB2555;20:2xHti1NKK1aS3lkeUb/kEN5k89oXsQIap/zQ1dwcT4zAr6Zjw/T+9KHiwHZP9APzUI+uP8VAXNVmTw2yJ21CXzILQtTMKmoM7ohwIvZPaxGPkEszqSiMn8JDhnL+CKff8EfhAcQFNAgGgy1V+5nDan2tC9UTBaJ5GVxMSL8VdONoLCGAV81J3TIgVUD6kJI8C2lWdwWnLH7lGv1uno/cary/B3nbAuARkpyNNgBzPgIGtYH/stw8Ad5amWidw9Og
x-microsoft-antispam-prvs:
 <DM5PR1201MB25553AEFEC5CF3750DBBCF1FE6740@DM5PR1201MB2555.namprd12.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(396003)(346002)(376002)(366004)(189003)(199004)(52116002)(25786009)(72206003)(53546011)(229853002)(102836004)(2906002)(110136005)(36756003)(7736002)(6116002)(316002)(3846002)(6246003)(305945005)(105586002)(6506007)(386003)(6436002)(14454004)(31686004)(6512007)(4326008)(53936002)(106356001)(68736007)(6486002)(4744005)(99286004)(86362001)(486006)(5024004)(31696002)(256004)(81166006)(81156014)(54906003)(8936002)(11346002)(186003)(5660300002)(97736004)(71200400001)(476003)(71190400001)(2616005)(8676002)(66066001)(478600001)(76176011)(26005)(446003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR1201MB2555;H:DM5PR1201MB0155.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 POiUkhHr273AgmSGQDoE3oX9/Mu3IP0GSapAxQ1mkQaM2LJBwfR9vIYKUkmmOvcBvaM4OEMZhvMeWhkyJsLS5QU95yEFViYdzzuDhxSsqIRNm6jyNcskSuaG2eMEIhEa4O00FE5WJ5IMg5RFCzGM0db5ddUSQz7ugp0UoekMCORV3gOSrowFejtdst7i50uI3tGYMOeA7ALGM108pipl+g4j9TgUrVcW5ruEoOy/XBbIr29APqXf8kW9WXReHRQg0jCL5ljv8OgC1dxUlCLl/a8cn/bEGBAa1Sq0jpyckw6rvE+cr6sfJ1KPyuum1MNG9O5esoGwLU6ERub+dWwnZzE/hLjSgwScbiWuqqGZMgpW7e08v8cJUa9Ud//BF9y7BJR738L/Ko2LvXu++qIMHxhCASc8Oxq+DLN8dUJcz64=
Content-Type: text/plain; charset="utf-8"
Content-ID: <CCAA4E538C783F46A55E3D53C5408631@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6f980818-f3cf-4de9-5057-08d69cd6f9ab
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 17:14:04.2179
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR1201MB2555
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgTWljaGVsLA0KDQpZZXMsIEkgZm91bmQgdGhlIHNhbWUgaXNzdWUgYW5kIHRoZSBidWcgaGFz
IGJlZW4gZml4ZWQgYnkgSmVyb21lOg0KDQo4NzZiNDYyMTIwYWEgbW0vaG1tOiB1c2UgcmVmZXJl
bmNlIGNvdW50aW5nIGZvciBITU0gc3RydWN0DQoNClRoZSBmaXggaXMgb24gaG1tLWZvci01LjEg
YnJhbmNoLCBJIGNoZXJyeS1waWNrIGl0IGludG8gbXkgbG9jYWwgYnJhbmNoIA0KdG8gd29ya2Fy
b3VuZCB0aGUgaXNzdWUuDQoNClJlZ2FyZHMsDQpQaGlsaXANCg0KT24gMjAxOS0wMi0yNyAxMjow
MiBwLm0uLCBNaWNoZWwgRMOkbnplciB3cm90ZToNCj4gDQo+IFNlZSB0aGUgYXR0YWNoZWQgZG1l
c2cgZXhjZXJwdC4gSSd2ZSBoaXQgdGhpcyBhIGZldyB0aW1lcyBydW5uaW5nIHBpZ2xpdA0KPiB3
aXRoIGFtZC1zdGFnaW5nLWRybS1uZXh0LCBmaXJzdCBvbiBGZWJydWFyeSAyMm5kLg0KPiANCj4g
VGhlIG1lbW9yeSB3YXMgZnJlZWQgYWZ0ZXIgY2FsbGluZyBobW1fbWlycm9yX3VucmVnaXN0ZXIg
aW4NCj4gYW1kZ3B1X21uX2Rlc3Ryb3kuDQo+IA0KPiANCg==

