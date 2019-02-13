Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E3E0C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CE73222B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:50:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="n/Yt7MZ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CE73222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF6188E0002; Wed, 13 Feb 2019 03:50:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA5928E0001; Wed, 13 Feb 2019 03:50:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46228E0002; Wed, 13 Feb 2019 03:50:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5924B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:50:58 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id a5so635907wrq.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:50:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=LNxQjQ21aDzsTxKP/w9FaFOQWpPcJ3cRKnfCnQCuBPo=;
        b=jbq8k8z89krggxn0f/iiEojdC40EUychoUQ4npFlVFQpzrnDn6nNNP3lBmb+oZPy2g
         oMdsTfCpNXsGXf/wzr0LJx29g/pveHwJ5SClppUiR3DfAs2aPEqVzx0tvZv2nrIE/Hb4
         9NdSf7DasY04f9soIYiwlnwt54hql8BWgkmviuI6GQXdPUPgypimAKH0Cqt+tiYcaCMG
         BeS5XwMbWbWdBP0vajjGKJLNLdUtya7ddp8C/tUEKcnkD4KyMY/lejT37T7tIkA11o2n
         sQzjTNLcyf0mULdkYpmYw+W2W1fTUBBbeFk3FxpKEbnP56IAJW+m0GuFfy37y7ju+qD2
         +gMw==
X-Gm-Message-State: AHQUAubps6vPZgjjCRm7MPaor1D5eaD4lR70zvRcTloiZRVdwg+dh1EC
	mBT121KxI9hkICy0/zXPjByWn0+VuC7Ui8tDQpxa7rwC4ieqnMB2WRjX1ztrLZ+tSREKB7vLlZo
	gfFDZy82PjUP1kIe98sjWhu8fNSgjuVh16Ef3So1FhirOAuXszfj/tLRgOK89R/DMxw==
X-Received: by 2002:adf:a749:: with SMTP id e9mr5881964wrd.210.1550047857853;
        Wed, 13 Feb 2019 00:50:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8XySI+x1DeTASq7Zorsvh+zj/J0G3sRcLcfANmTGl5MvYSRzFeJOJIS9xGQhBZlwmE8wy
X-Received: by 2002:adf:a749:: with SMTP id e9mr5881913wrd.210.1550047857018;
        Wed, 13 Feb 2019 00:50:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550047857; cv=none;
        d=google.com; s=arc-20160816;
        b=aPAmqoFAMI0UaTcigPjLvvmVKVZP9e2HCO74Zr3Yjdc1Mw5uWy4Pj9mrBpC3PNl81C
         bav36eYkCTbkbrI6kg5JOJ+4kR5IX+7goQ8ZVzaPnick7BaycCPBzdHvDoiFXA9y/rmd
         xQdJWUzm6ylyg2dMTw3jtNjMdcge7Fi7gynP6S9H3jai3RplW+4sNZ+H884n+CpmKlWs
         BFWRXT/sUQQ5SHNh71VkKGr0bjoezT8ZosZi+uH9sUG+GpPDbUmlak/yxiVEEA/oM2O5
         S84wg3H8kUSmAIF1Q8GlaOeg52hwXj7v/Xyz/yPWV7f8HLdBYDyZBBa704NQgO4mt5Y4
         oyQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=LNxQjQ21aDzsTxKP/w9FaFOQWpPcJ3cRKnfCnQCuBPo=;
        b=TGbQ+4L+MfulXE3A31qm34rL/JALFwWLrGu/hkb2yrFEwMgAPq+6xBfTWB1HaGPo6L
         hyTyiptzhWY/sRDaWaijxTXrXuWKXM+lIPCQhXxLIqedkROmJZY7h33D00IpO1YSBJEi
         fbjgbQ3wsjVrrLB+VSnOvS+sFpEQt0mfTg9m250+Lo2oGa9mRSVAZyZ1JtkAdX+nv9R9
         EVqWySE1DsHADjP69esv0ri7KKaDdj/tuqj1YJ30jh+0guauh+aIdkGrWZec1ibe21x6
         Omigd/gWC9Y2fCe2kGdm8mCp+fsheHLZRYyrTJ9KSiOsIEGj4Mub+Y55IkDC6GxzavJY
         2vXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="n/Yt7MZ2";
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.15.88 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150088.outbound.protection.outlook.com. [40.107.15.88])
        by mx.google.com with ESMTPS id g8si5155469wro.305.2019.02.13.00.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 00:50:57 -0800 (PST)
Received-SPF: pass (google.com: domain of tariqt@mellanox.com designates 40.107.15.88 as permitted sender) client-ip=40.107.15.88;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b="n/Yt7MZ2";
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.15.88 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LNxQjQ21aDzsTxKP/w9FaFOQWpPcJ3cRKnfCnQCuBPo=;
 b=n/Yt7MZ2maZAgPaJzbCtAqKh4EZw1feG3aDPMOVhn5KuD9pbW/FB2afLkSn/W0LW5kkERBGQENKSiV1yObfsu+9qKIKxA6d+hG1FLhi8fdSMbGgeSE4wO36T9XeYpDttwfyWW87FbcY6VfR1jgqC31+m6uZEkatkC/9dHkz7DXc=
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com (10.170.243.19) by
 HE1PR05MB4748.eurprd05.prod.outlook.com (20.176.164.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.22; Wed, 13 Feb 2019 08:50:54 +0000
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a]) by HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a%7]) with mapi id 15.20.1601.023; Wed, 13 Feb 2019
 08:50:54 +0000
From: Tariq Toukan <tariqt@mellanox.com>
To: Ilias Apalodimas <ilias.apalodimas@linaro.org>, Alexander Duyck
	<alexander.duyck@gmail.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>,
	Matthew Wilcox <willy@infradead.org>, "brouer@redhat.com"
	<brouer@redhat.com>, David Miller <davem@davemloft.net>, "toke@redhat.com"
	<toke@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Topic: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Index:
 AQHUvvKPEpTQQqXqi0+ZzMx9yc3kKaXUb92AgAADlACAAGXpgIAAAm4AgAACaICABZPkAIAAanSAgAFFsACAACuVgIAAMZ4AgAAB9oCAAPMqAA==
Date: Wed, 13 Feb 2019 08:50:54 +0000
Message-ID: <d869617f-0e22-05b7-3865-4d9559d89b33@mellanox.com>
References: <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
 <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
 <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
 <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
 <20190212182031.GA23057@apalos>
In-Reply-To: <20190212182031.GA23057@apalos>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0450.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:e::30) To HE1PR05MB3257.eurprd05.prod.outlook.com
 (2603:10a6:7:35::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=tariqt@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5b59aa95-d362-487b-9f37-08d691905ce6
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:HE1PR05MB4748;
x-ms-traffictypediagnostic: HE1PR05MB4748:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtIRTFQUjA1TUI0NzQ4OzIzOmVrTHFmeEx2cjNiU2lXa1lNd1hUejRNZUQv?=
 =?utf-8?B?QlpKcWFHMVNsMFcvQkVsMkVxT1ZRYWVycjdSajVKaHRqVUE4QnRPWllMbSty?=
 =?utf-8?B?ZHlOK1o4aWRsT3EvOXU4N200MlFkRG95eTA0OFQ2UGlzbDgvTWc3ZHdoekx0?=
 =?utf-8?B?Q0tIUVZzNmhGMXprTVd5eWY1WTZYRyszdVNMT3ZKbmpJTWx1MkNzczZRSytu?=
 =?utf-8?B?MDAyazZTaVBkejFYS2tPMHlyd0QvTkRlM2U0ZlBPUUVaNHlYNElodWJjM25Y?=
 =?utf-8?B?cDhaWVZsNzRQK2kxZU03ZEQzUldiZ0hna3o1SDZvMUptWWNlNDVnd01CS2R6?=
 =?utf-8?B?ZG1oMS93L1NHTFU4cGs3cTJ1V3JYRlhtRGdyRi9hOTBrVm9WZjFEeVN1U3pl?=
 =?utf-8?B?OWZRMkZIRXNHbXNJenI1ZkdpOFhzSXlpbUFxeEJ5ZThCdzZrVFdMT2lObWor?=
 =?utf-8?B?S2NXMTJwbVhzM1YrcU1RN2syLy9IY3l4RlNtelhEV3JhNXNuWFhEaW8yMzU5?=
 =?utf-8?B?OFRmZ1FteUo3WUNHRzU5L2hxV1FBbW8rUmxsWjMwbitld0o4bWlMdm1CTElS?=
 =?utf-8?B?emdZY2tYa0w4ZWNSTkxGQU1MQ2w4ZmN0eldvRkQ5YnM3TFpwOC9xWDJxUm5O?=
 =?utf-8?B?R3BKcWkvbno3dVh4Wnl6VUxvKzZVdHpQOGR6UlczOURFM0F4NVFtOXpBbnQ1?=
 =?utf-8?B?R1g1SnFNNjVEK3Q5T2kyNHRBOGc4bE05OTRKSGVDLzgxZlI4Z3N2cU4rMFhE?=
 =?utf-8?B?SHk3OStPZGJncm5PeG41WSsybVhsUE1kM2xhVTlBNG5iSGJLakYyWWpyZ0ZI?=
 =?utf-8?B?NGdLK0FVczBkbXhGRnY0bUcySDNWTHdiR01yckM5V3NHVU5DcHliWEF6Njdm?=
 =?utf-8?B?Y2lJaHJkU0J2bExRMndaT3ZvSTVVTDN2T1hORXlmVDJvUFVuaWJrV3lpcFB2?=
 =?utf-8?B?bVBDR3ZNaEYxUHBqNVEyMGYzTXVaQkNtRlJDbGFZTG5QOTQzZGlaejFsMGV1?=
 =?utf-8?B?Z2VyeFFwcWttNHlJay9RZnpjTS95b1o4bE1ETUN2dEd3S1pGaXBUZ3FNSEti?=
 =?utf-8?B?ZTJndHlLcld4S1pXaVhwRHpYOERsRllFVU9WOWo2MTJsanJQUzNqSkk0NGph?=
 =?utf-8?B?L05BYlhBdEJlZ25xRTNIYkI2cXVUMXJaODZBbEVmTnEvL2F3YWhHOFh0WnlZ?=
 =?utf-8?B?eGRjRCtYc2dwTVlZenJUUDBLZStFVHlpWDhzbWpzTG9Pa3lHZHhBR1hXWXpa?=
 =?utf-8?B?YWM0NnR1ZFM3OStFZ1FYNHZ0OUFNcGJPZ2JpMHROdFdXa2s3dSsrWkRWTnRv?=
 =?utf-8?B?NVZRaEJxdy94ZFdoUWVxeTR4SWVMWXVOeUZqNGZsekJjL0ZBLy9VQnUvcnFF?=
 =?utf-8?B?OUtrRnZ5RnljOGZadVJvem9oeUJPMENjVHVUcjlLYVUxVE11c2lFQ3hlL25F?=
 =?utf-8?B?T3Z3Tm1wYVhxMlJ4b0J4VE9ETEp4QzR3YTJBaEtkdHBMUno4VkN6Q3JvOTYr?=
 =?utf-8?B?RlhoZlZWbUFKeFhOdTh6OHM4amllYTFwYmhSckhwbFVtSjRUbzc5bnRKd2x2?=
 =?utf-8?B?UCt4eldNSE9UdUFDbERIYlRBcGw2Z2VqR0p3enRxOWVqN1I1ZzdFdEk0TU1G?=
 =?utf-8?B?alRoM1htV2pSM0h4ZWFKSEx3L1laMEtyaWRQQlZlQ3VyVk9DVm95UGVySXlq?=
 =?utf-8?B?Vm1oNXk0MEFuczZTQW1yQkF4b01QZ1kzbUxjY0dST1JXVHBuWGNyUk5HSDYx?=
 =?utf-8?B?VE1HNGo0SmZYbzU2VVRIWEpsSGo0L2VxaTRheWVaUFdBVkJ3dktqN1BuRG1x?=
 =?utf-8?Q?jYXW5yN7BsIDw?=
x-microsoft-antispam-prvs:
 <HE1PR05MB474883E8A5EA4093834A53B6AE660@HE1PR05MB4748.eurprd05.prod.outlook.com>
x-forefront-prvs: 094700CA91
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(39860400002)(396003)(346002)(376002)(199004)(189003)(51444003)(8676002)(68736007)(3846002)(316002)(7416002)(76176011)(81156014)(36756003)(229853002)(110136005)(486006)(476003)(6116002)(26005)(446003)(6436002)(14444005)(2906002)(4326008)(256004)(11346002)(52116002)(2616005)(99286004)(186003)(54906003)(386003)(53546011)(6486002)(6506007)(102836004)(305945005)(7736002)(25786009)(105586002)(106356001)(14454004)(93886005)(97736004)(8936002)(31686004)(66066001)(53936002)(71190400001)(71200400001)(81166006)(6512007)(31696002)(6246003)(86362001)(478600001);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR05MB4748;H:HE1PR05MB3257.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 QJgoQp6fliQKTChjUTIjEnXLwrr/bWr9n8OdoPI+0eIvwjcyoxcfmfYDguZzvg5Yd62ehfqtRFJvEfRuuzQONoPai3JE5St+qU+ktTFvtfzrR7lKwUm0HaH0FujzEyfHxSP6mMmS7mAIMO0XNooRC6LcqagUvn7BsKDMHp5uP6GCGt0VA+7Ovploh2PZ+myhXC8th+rmGX94QhP6GHUu83mBp8LSVjvpWAZLB/SPw7K2aXiGaXnr31umBHZdwBU0bvFKYWynq/C9ixkhhIVviNLjp2q5I+kc5qXLn89ZdPau44Jd+R2y7KzlEL49DsuoA9NxWEbARjCPSFW8I5l/glxVYcvX9RoTAZ5mbYvzmo1LOyl7T2kCuxrZLuYRcI0wiomprCG4SwceAimmf0qN/YcFXBc8v1x7f7m+ylv+PB8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <5C5EB7D4BAD90743BBCCBCF4562B175F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5b59aa95-d362-487b-9f37-08d691905ce6
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Feb 2019 08:50:52.5470
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR05MB4748
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDIvMTIvMjAxOSA4OjIwIFBNLCBJbGlhcyBBcGFsb2RpbWFzIHdyb3RlOg0KPiBIaSBB
bGV4YW5kZXIsDQo+IA0KPiBPbiBUdWUsIEZlYiAxMiwgMjAxOSBhdCAxMDoxMzozMEFNIC0wODAw
LCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6DQo+PiBPbiBUdWUsIEZlYiAxMiwgMjAxOSBhdCA3OjE2
IEFNIEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4gd3JvdGU6DQo+Pj4NCj4+
Pg0KPj4+DQo+Pj4gT24gMDIvMTIvMjAxOSAwNDozOSBBTSwgVGFyaXEgVG91a2FuIHdyb3RlOg0K
Pj4+Pg0KPj4+Pg0KPj4+PiBPbiAyLzExLzIwMTkgNzoxNCBQTSwgRXJpYyBEdW1hemV0IHdyb3Rl
Og0KPj4+Pj4NCj4+Pj4+DQo+Pj4+PiBPbiAwMi8xMS8yMDE5IDEyOjUzIEFNLCBUYXJpcSBUb3Vr
YW4gd3JvdGU6DQo+Pj4+Pj4NCj4+Pj4+DQo+Pj4+Pj4gSGksDQo+Pj4+Pj4NCj4+Pj4+PiBJdCdz
IGdyZWF0IHRvIHVzZSB0aGUgc3RydWN0IHBhZ2UgdG8gc3RvcmUgaXRzIGRtYSBtYXBwaW5nLCBi
dXQgSSBhbQ0KPj4+Pj4+IHdvcnJpZWQgYWJvdXQgZXh0ZW5zaWJpbGl0eS4NCj4+Pj4+PiBwYWdl
X3Bvb2wgaXMgZXZvbHZpbmcsIGFuZCBpdCB3b3VsZCBuZWVkIHNldmVyYWwgbW9yZSBwZXItcGFn
ZSBmaWVsZHMuDQo+Pj4+Pj4gT25lIG9mIHRoZW0gd291bGQgYmUgcGFnZXJlZl9iaWFzLCBhIHBs
YW5uZWQgb3B0aW1pemF0aW9uIHRvIHJlZHVjZSB0aGUNCj4+Pj4+PiBudW1iZXIgb2YgdGhlIGNv
c3RseSBhdG9taWMgcGFnZXJlZiBvcGVyYXRpb25zIChhbmQgcmVwbGFjZSBleGlzdGluZw0KPj4+
Pj4+IGNvZGUgaW4gc2V2ZXJhbCBkcml2ZXJzKS4NCj4+Pj4+Pg0KPj4+Pj4NCj4+Pj4+IEJ1dCB0
aGUgcG9pbnQgYWJvdXQgcGFnZXJlZl9iaWFzIGlzIHRvIHBsYWNlIGl0IGluIGEgZGlmZmVyZW50
IGNhY2hlIGxpbmUgdGhhbiAic3RydWN0IHBhZ2UiDQo+Pj4+Pg0KPj4+Pj4gVGhlIG1ham9yIGNv
c3QgaXMgaGF2aW5nIGEgY2FjaGUgbGluZSBib3VuY2luZyBiZXR3ZWVuIHByb2R1Y2VyIGFuZCBj
b25zdW1lci4NCj4+Pj4+DQo+Pj4+DQo+Pj4+IHBhZ2VyZWZfYmlhcyBpcyBtZWFudCB0byBiZSBk
aXJ0aWVkIG9ubHkgYnkgdGhlIHBhZ2UgcmVxdWVzdGVyLCBpLmUuIHRoZQ0KPj4+PiBOSUMgZHJp
dmVyIC8gcGFnZV9wb29sLg0KPj4+PiBBbGwgb3RoZXIgY29tcG9uZW50cyAoYmFzaWNhbGx5LCBT
S0IgcmVsZWFzZSBmbG93IC8gcHV0X3BhZ2UpIHNob3VsZA0KPj4+PiBjb250aW51ZSB3b3JraW5n
IHdpdGggdGhlIGF0b21pYyBwYWdlX3JlZmNudCwgYW5kIG5vdCBkaXJ0eSB0aGUNCj4+Pj4gcGFn
ZXJlZl9iaWFzLg0KPj4+DQo+Pj4gVGhpcyBpcyBleGFjdGx5IG15IHBvaW50Lg0KPj4+DQo+Pj4g
WW91IHN1Z2dlc3RlZCB0byBwdXQgcGFnZXJlZl9iaWFzIGluIHN0cnVjdCBwYWdlLCB3aGljaCBi
cmVha3MgdGhpcyBjb21wbGV0ZWx5Lg0KPj4+DQo+Pj4gcGFnZXJlZl9iaWFzIGlzIGJldHRlciBr
ZXB0IGluIGEgZHJpdmVyIHN0cnVjdHVyZSwgd2l0aCBhcHByb3ByaWF0ZSBwcmVmZXRjaGluZw0K
Pj4+IHNpbmNlIG1vc3QgTklDIHVzZSBhIHJpbmcgYnVmZmVyIGZvciB0aGVpciBxdWV1ZXMuDQo+
Pj4NCj4+PiBUaGUgZG1hIGFkZHJlc3MgX2Nhbl8gYmUgcHV0IGluIHRoZSBzdHJ1Y3QgcGFnZSwg
c2luY2UgdGhlIGRyaXZlciBkb2VzIG5vdCBkaXJ0eSBpdA0KPj4+IGFuZCBkb2VzIG5vdCBldmVu
IHJlYWQgaXQgd2hlbiBwYWdlIGNhbiBiZSByZWN5Y2xlZC4NCj4+DQo+PiBJbnN0ZWFkIG9mIG1h
aW50YWluaW5nIHRoZSBwYWdlcmVmX2JpYXMgaW4gdGhlIHBhZ2UgaXRzZWxmIGl0IGNvdWxkIGJl
DQo+PiBtYWludGFpbmVkIGluIHNvbWUgc29ydCBvZiBzZXBhcmF0ZSBzdHJ1Y3R1cmUuIFlvdSBj
b3VsZCBqdXN0IG1haW50YWluDQo+PiBhIHBvaW50ZXIgdG8gYSBzbG90IGluIGFuIGFycmF5IHNv
bWV3aGVyZS4gVGhlbiB5b3UgY2FuIHN0aWxsIGFjY2Vzcw0KPj4gaXQgaWYgbmVlZGVkLCB0aGUg
cG9pbnRlciB3b3VsZCBiZSBzdGF0aWMgZm9yIGFzIGxvbmcgYXMgaXQgaXMgaW4gdGhlDQo+PiBw
YWdlIHBvb2wsIGFuZCB5b3UgY291bGQgaW52YWxpZGF0ZSB0aGUgcG9pbnRlciBwcmlvciB0byBy
ZW1vdmluZyB0aGUNCj4+IGJpYXMgZnJvbSB0aGUgcGFnZS4NCj4gDQo+IEkgdGhpbmsgdGhhdCdz
IHdoYXQgVGFyaXEgd2FzIHN1Z2dlc3RpbmcgaW4gdGhlIGZpcnN0IHBsYWNlLg0KPiANCj4gL0ls
aWFzDQo+IA0KDQpDb3JyZWN0Lg0KQnV0IG5vdCByZWxldmFudCBhbnltb3JlLCBhcyBpdCB3b24n
dCB3b3JrIGZvciBvdGhlciByZWFzb25zLg0KDQpUYXJpcQ0K

