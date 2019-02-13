Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8453C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:47:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77AB6222B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:47:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="HQRiTLZL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77AB6222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110058E0002; Wed, 13 Feb 2019 03:47:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C2318E0001; Wed, 13 Feb 2019 03:47:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECA278E0002; Wed, 13 Feb 2019 03:47:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 952E78E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:47:01 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so711055edd.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:47:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=oH0DCiQh+QdNREwjH3Qdacl6HoL64DBlZCHxm+uysok=;
        b=Y/tXGolnah9qp3s5NFLTqcHiN2DRAi2PI4u6LDXwuyMqeDlZcw2JK3TFfFAUwJ/iGh
         0qeSC3Sxxtowy1UK2nDFPsT1z/vcCZVWJLTVyS+6VVdoOqYKM03h5PXduszuvW64vW2r
         85faE7Iv9cgCtqbTXoInFKSNdMTmLqxhvgTJ9ta9iu3zMygovZqVDomx1d0RKzUpodbV
         fStH2L+uWnCTf4g8gb1hMvZOBNQdB2MwvAOkqjZ8zqWadtXW/Eerme//sK17vCk4PwFW
         JpYwWZtny9guvnificcgv+gCJD9pUe2nS0eXI9VvU+thp5NCMokV8c5pWUuEKnNoO7YS
         TkEA==
X-Gm-Message-State: AHQUAuaEfVaEmLmbB26srl6wmDzWt+gBrbEFapPIByfw3jN7npnfE0gg
	AbTbjBCVjdrB+4/bMod4P/gnIrY5mCSxtb3tX/hFsNp18W35hKjMZwRu+3oBXYpkFgKnSw2/ApG
	ozDmrHr6n6MgGmxghi7edwZcpSzFvnew1wjiFenOt94ILmCPZVaizhWXyFdrhW0JFWw==
X-Received: by 2002:aa7:d051:: with SMTP id n17mr6587930edo.251.1550047621160;
        Wed, 13 Feb 2019 00:47:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbgjN8+U7sAbjr012DSYhKMo3+FowzP/twM69J8A03xnsTQS64GJwTWxT+5PufyCx87Qs3K
X-Received: by 2002:aa7:d051:: with SMTP id n17mr6587892edo.251.1550047620234;
        Wed, 13 Feb 2019 00:47:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550047620; cv=none;
        d=google.com; s=arc-20160816;
        b=mlhdLMtEkx5IdupO978aUka9cRJ2gliUsUf7sAwMwp80osTfPAwXHo716BFyZQmCQh
         q/4miQerM4JRbm2w1o8N0rpoOyNR+3p78i58zv6Ayu7wNrx+EviK2Ui5ITK23VjSRDt6
         8k4G0I8CRJufV/lk34kWlJHsqH8Ed6XmQkZPTPGbmcvOgdtStFhTFaYLCOQpPuHeYiji
         Cf/8GsR+yX+gRMWHNuh5612/L1SOdo3+40tYZ1wCqBEXLRenJ9IDxPuLWRyAyF9g5m6y
         5J3t54IKWZ4PWaDM8GRX0T9a3wxNQrgMqHgSd/AajQA70onlbIv5LJIDfGZnZgusIm6p
         x4fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=oH0DCiQh+QdNREwjH3Qdacl6HoL64DBlZCHxm+uysok=;
        b=CmX9s5AlwwhsUc0cf4rDyzYUxDWco7BS9YzB3PJYYhe7Chuxt+sED6uDttPgjUkgrk
         1eokZPuS6m2BSFEWdZZ4FqL58TZVxzSYjFLZx1hWkh3ycvh6wo7KtZGy6+QV4zs5DeOt
         d0EZSWBLMo7oSKeFvrSTpKkVkhkwfY+TK7sLUcG9Tn14VAEL4YS+bNv/6rVexnHs61aX
         UI3I2q5iKIaXnXK6g3zJBTgh8K0+CjIiVQTXwiXUJxM37rLxR6+N5YZtekT1mEH5xQwv
         w8hhSVVxIqXhv9BARqP+gaQTu5RImqiHQHNoMUNOeupuGSOY4AMMLBkKSaPiTgVLRI84
         DO5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=HQRiTLZL;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.8.49 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80049.outbound.protection.outlook.com. [40.107.8.49])
        by mx.google.com with ESMTPS id d8si7494933edo.400.2019.02.13.00.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 00:47:00 -0800 (PST)
Received-SPF: pass (google.com: domain of tariqt@mellanox.com designates 40.107.8.49 as permitted sender) client-ip=40.107.8.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=HQRiTLZL;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.8.49 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oH0DCiQh+QdNREwjH3Qdacl6HoL64DBlZCHxm+uysok=;
 b=HQRiTLZLYy3FAIE0pdVYTyQqSWjUUyurB5URQxfRuVEp9LD8xsVeBidLfrW7sC+BNfnkPNPtaywAGOOWpTEfpwY1cmtMjs/pAoS5Zvh+kRNV5snkJQ6EWw0Mr56/ouHFUuYWpH7decxD6D7kiSaqiQh+r39DVU0sJTpF17I/BE0=
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com (10.170.243.19) by
 HE1PR05MB4521.eurprd05.prod.outlook.com (20.176.163.14) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Wed, 13 Feb 2019 08:46:58 +0000
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a]) by HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a%7]) with mapi id 15.20.1601.023; Wed, 13 Feb 2019
 08:46:58 +0000
From: Tariq Toukan <tariqt@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>, Eric Dumazet
	<eric.dumazet@gmail.com>
CC: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas
	<ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>,
	"brouer@redhat.com" <brouer@redhat.com>, David Miller <davem@davemloft.net>,
	"toke@redhat.com" <toke@redhat.com>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Topic: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Index:
 AQHUvvKPEpTQQqXqi0+ZzMx9yc3kKaXUb92AgAADlACAAGXpgIAAAm4AgAACaICABZPkAIAAanSAgAFFsACAACuVgIAAMZ4AgAD0BgA=
Date: Wed, 13 Feb 2019 08:46:58 +0000
Message-ID: <bf8450d2-ced4-e59d-f811-0f970ac4cbb1@mellanox.com>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
 <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
 <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
 <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
In-Reply-To:
 <CAKgT0UfG08aYoN=zO_aVyx+OgNPmN9pVkBNeZMPTF2KL7XqoBQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0281.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a1::29) To HE1PR05MB3257.eurprd05.prod.outlook.com
 (2603:10a6:7:35::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=tariqt@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 14172103-3794-4f85-d707-08d6918fd091
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:HE1PR05MB4521;
x-ms-traffictypediagnostic: HE1PR05MB4521:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtIRTFQUjA1TUI0NTIxOzIzOm9PT0o0cXU0TkxSMGlPWGNZM0RrNks3TmlJ?=
 =?utf-8?B?eU9SclYxYTZpUCs1cHBheUsrNXQxdEl4Y01UdXJ4R1B5eUVkNFpBclpmblFY?=
 =?utf-8?B?a3Z0bThmcm9Ia3N4YTQ3bmJ2UUZyRU04N2dNdExLVEFPeFIwRHZZMHZabndI?=
 =?utf-8?B?SXJoUzZPWEJXdVVPeC81VTFRYm5aZ3hRMCtEYURlS2J4ZzQ2UWNWeWtKTXZ0?=
 =?utf-8?B?V0ZZNUlTQ0FQTlBrNWhydTZucWwvWEVET2hXazRTbHhpMUtLM0kzQXFLUXBH?=
 =?utf-8?B?Rlhvd2VIL1gvQjI5NlkyRUN3MW9JL1B4Q1UvQ253NnZJa21Lci90ZmRqVyth?=
 =?utf-8?B?b2lvYitlWXdtdmk3aUJnNnhCOEw3UVZKdmJUQ2dvd3lmR3FvakZTZUs1bUp5?=
 =?utf-8?B?TTlPTmZ0TWtxNTF3S3liMFRtMXZGR0JLUEJteWlubHlhVFJpQTFWUU5yeFZa?=
 =?utf-8?B?TGdBOFZNMmwzQXQwVy9KNG4vZlJHOXFzRGdjVmFrRDFneXQ4LzNmbFo2VUZy?=
 =?utf-8?B?YndCaThxRDdRbDNqcVk0ZTdvaFBtZ3lIYUNCVnFXNGZsc1BUV0t6RmZJaGpi?=
 =?utf-8?B?aHFsNmJiZFJORmdZYjNDeENzaUx6QWk2clN6RUdZZ1BKVTA1M1ZZKzNHWU9G?=
 =?utf-8?B?YlV5cTB5VXpTS1gvTnhVclBuNXg2dVZ2QktwV3dxbFFBSmtPNldFajVNOGI0?=
 =?utf-8?B?ZS9BeUtWUlVHdE5oU0p3SWhtODFqcHg1NWdyRzQyTXptRXBwRUk3VFpjZHpH?=
 =?utf-8?B?dmV1VTI2N0hRZS9iQ3NFelF4YmUydm1yQ2kyTmZtTnZ4Vy9YN0RHYlpUQmkx?=
 =?utf-8?B?OUpMa2xWRFVZYTNBSU5HenVOVldKa0Z5YXc0VzJSdnI0c1VPZ0xhOEpkU25t?=
 =?utf-8?B?UVRlR2NwZ25CckhROHRMcko3c0U3ZEdFeDlvWVhGM1lrY3huVmRqSG0zWHo1?=
 =?utf-8?B?cnBNWENHUHpqc3FQRDdHS01ob055Q3hpZWtOb2k1bDNKcG9ORXJ3Wng0M2tJ?=
 =?utf-8?B?T1FxNW9velB4VEV3VEU4OGorSkNSdlZ0OUVEZnUrWlA1bmN1T2JNekVoYUF6?=
 =?utf-8?B?NDBwaVV1bW1yOUlvdXBleTcvOWFOdmZidUI4SnVLaiswN0pUeTEwNGVXTVJW?=
 =?utf-8?B?UUpaZnB5a0tqUXFFNnpyQkZkU0RTUDJJVk0zRDdLc3FkQksrdThOUlk2blpu?=
 =?utf-8?B?bUNkZkI1cFNvbC9FTEEvQldwUG12Vkp0YjhKdTZES1JLOFlvbWdpTHJEcFQ4?=
 =?utf-8?B?RlJ1Mm9COW4vbmNtQjUvQ3FHMmZ4ZGlLUmc0T1VFeklWOFNXeG5nY1Zocit4?=
 =?utf-8?B?Tml2MUwveW9PZnh5MzJUOGxqYWhCREludm9KUWp5cllpT3B3VTE1WHNVaTJr?=
 =?utf-8?B?aHJzNG52aldTdkMzOTlTOGlLd21rNlZYYU1vVWxjNjdTME1XS002ZnhUK0Yw?=
 =?utf-8?B?WC8vSzJqbjBLNjV4VVZZd25QV3BZZTNtNEJjRGNJdFpYb2Z6b2xkNHd1a3lC?=
 =?utf-8?B?VzROVFhVZ25Tdnl2R1IvYkJiL25oNXpzWExMRTUrSmloQXpFQXBBdmo1VGFr?=
 =?utf-8?B?RFJqMm1qa2NTL2x0RnJPNDYyanRhYUJXcWRvQlU0eFhkN2dXbkdOUlNpbzVo?=
 =?utf-8?B?MWk1RmZ3T05oMGdPWDFtVDFGR0hadHhVdE5MNlRyTlF3d3BJSEsrQUQxUlZS?=
 =?utf-8?B?YkhmR0RYdDNPVHNoYWwzRmhPTFFVbXlNWkl5NmVHWnpZVFE0UG5BNXEzY09a?=
 =?utf-8?Q?+DHtBlLB842IdlyudTZkHyX/t1K4JyU8VnbBI=3D?=
x-microsoft-antispam-prvs:
 <HE1PR05MB45210D3FE30F16CA0329CFDDAE660@HE1PR05MB4521.eurprd05.prod.outlook.com>
x-forefront-prvs: 094700CA91
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(376002)(346002)(396003)(39860400002)(136003)(199004)(189003)(25786009)(105586002)(6512007)(68736007)(31686004)(26005)(478600001)(4326008)(186003)(7416002)(6246003)(106356001)(14454004)(14444005)(3846002)(53546011)(102836004)(386003)(6506007)(256004)(6116002)(71190400001)(71200400001)(316002)(36756003)(446003)(8936002)(93886005)(81166006)(97736004)(31696002)(8676002)(86362001)(305945005)(486006)(54906003)(110136005)(81156014)(2906002)(76176011)(7736002)(52116002)(229853002)(53936002)(6486002)(66066001)(476003)(2616005)(99286004)(11346002)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR05MB4521;H:HE1PR05MB3257.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Gh9pn3MVr5hcl58PLinXoEkbHcCJ36+rO8XV9qRYwOHPqt/kT/i8UEC9dM0cnfY63UAU+Ymb+WFNxHnSpOBQm3jHeYvOe8TeVldDHI5CAjH/o8xtXfwPCQ5bGJn4YAcZW0QFTa8R0QsjZG5awLenXLvLP/p0Y1pxc2lAb2bTYnLx8b8UKqXMTUNLzWr376zXEUO8/2u9I7//vAQ2AReUPiGnbRtwmiRCTGKZD9r+LkMrHecuh/nnPGRmtmIcBubNNHDVfOdce3fLj12DHu8nNk+ClqyuRn6dQ9mlM2sJn8fiR8/00MxUq79jY/uhbkR8dMUj3NXo5YRkKws9wOngz+vqV2fdDogf+sqUvNDxFBMZWS+oLFVAU2u7gYWBZ5LOD1pHBIjQZYKkrvqLy42p3ehI16aCYbFV3mzfvIagT1Y=
Content-Type: text/plain; charset="utf-8"
Content-ID: <1C518CA3C9514B45883800640AE36903@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 14172103-3794-4f85-d707-08d6918fd091
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Feb 2019 08:46:57.2016
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR05MB4521
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDIvMTIvMjAxOSA4OjEzIFBNLCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6DQo+IE9uIFR1
ZSwgRmViIDEyLCAyMDE5IGF0IDc6MTYgQU0gRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21h
aWwuY29tPiB3cm90ZToNCj4+DQo+Pg0KPj4NCj4+IE9uIDAyLzEyLzIwMTkgMDQ6MzkgQU0sIFRh
cmlxIFRvdWthbiB3cm90ZToNCj4+Pg0KPj4+DQo+Pj4gT24gMi8xMS8yMDE5IDc6MTQgUE0sIEVy
aWMgRHVtYXpldCB3cm90ZToNCj4+Pj4NCj4+Pj4NCj4+Pj4gT24gMDIvMTEvMjAxOSAxMjo1MyBB
TSwgVGFyaXEgVG91a2FuIHdyb3RlOg0KPj4+Pj4NCj4+Pj4NCj4+Pj4+IEhpLA0KPj4+Pj4NCj4+
Pj4+IEl0J3MgZ3JlYXQgdG8gdXNlIHRoZSBzdHJ1Y3QgcGFnZSB0byBzdG9yZSBpdHMgZG1hIG1h
cHBpbmcsIGJ1dCBJIGFtDQo+Pj4+PiB3b3JyaWVkIGFib3V0IGV4dGVuc2liaWxpdHkuDQo+Pj4+
PiBwYWdlX3Bvb2wgaXMgZXZvbHZpbmcsIGFuZCBpdCB3b3VsZCBuZWVkIHNldmVyYWwgbW9yZSBw
ZXItcGFnZSBmaWVsZHMuDQo+Pj4+PiBPbmUgb2YgdGhlbSB3b3VsZCBiZSBwYWdlcmVmX2JpYXMs
IGEgcGxhbm5lZCBvcHRpbWl6YXRpb24gdG8gcmVkdWNlIHRoZQ0KPj4+Pj4gbnVtYmVyIG9mIHRo
ZSBjb3N0bHkgYXRvbWljIHBhZ2VyZWYgb3BlcmF0aW9ucyAoYW5kIHJlcGxhY2UgZXhpc3RpbmcN
Cj4+Pj4+IGNvZGUgaW4gc2V2ZXJhbCBkcml2ZXJzKS4NCj4+Pj4+DQo+Pj4+DQo+Pj4+IEJ1dCB0
aGUgcG9pbnQgYWJvdXQgcGFnZXJlZl9iaWFzIGlzIHRvIHBsYWNlIGl0IGluIGEgZGlmZmVyZW50
IGNhY2hlIGxpbmUgdGhhbiAic3RydWN0IHBhZ2UiDQo+Pj4+DQo+Pj4+IFRoZSBtYWpvciBjb3N0
IGlzIGhhdmluZyBhIGNhY2hlIGxpbmUgYm91bmNpbmcgYmV0d2VlbiBwcm9kdWNlciBhbmQgY29u
c3VtZXIuDQo+Pj4+DQo+Pj4NCj4+PiBwYWdlcmVmX2JpYXMgaXMgbWVhbnQgdG8gYmUgZGlydGll
ZCBvbmx5IGJ5IHRoZSBwYWdlIHJlcXVlc3RlciwgaS5lLiB0aGUNCj4+PiBOSUMgZHJpdmVyIC8g
cGFnZV9wb29sLg0KPj4+IEFsbCBvdGhlciBjb21wb25lbnRzIChiYXNpY2FsbHksIFNLQiByZWxl
YXNlIGZsb3cgLyBwdXRfcGFnZSkgc2hvdWxkDQo+Pj4gY29udGludWUgd29ya2luZyB3aXRoIHRo
ZSBhdG9taWMgcGFnZV9yZWZjbnQsIGFuZCBub3QgZGlydHkgdGhlDQo+Pj4gcGFnZXJlZl9iaWFz
Lg0KPj4NCj4+IFRoaXMgaXMgZXhhY3RseSBteSBwb2ludC4NCj4+DQo+PiBZb3Ugc3VnZ2VzdGVk
IHRvIHB1dCBwYWdlcmVmX2JpYXMgaW4gc3RydWN0IHBhZ2UsIHdoaWNoIGJyZWFrcyB0aGlzIGNv
bXBsZXRlbHkuDQo+Pg0KPj4gcGFnZXJlZl9iaWFzIGlzIGJldHRlciBrZXB0IGluIGEgZHJpdmVy
IHN0cnVjdHVyZSwgd2l0aCBhcHByb3ByaWF0ZSBwcmVmZXRjaGluZw0KPj4gc2luY2UgbW9zdCBO
SUMgdXNlIGEgcmluZyBidWZmZXIgZm9yIHRoZWlyIHF1ZXVlcy4NCj4+DQo+PiBUaGUgZG1hIGFk
ZHJlc3MgX2Nhbl8gYmUgcHV0IGluIHRoZSBzdHJ1Y3QgcGFnZSwgc2luY2UgdGhlIGRyaXZlciBk
b2VzIG5vdCBkaXJ0eSBpdA0KPj4gYW5kIGRvZXMgbm90IGV2ZW4gcmVhZCBpdCB3aGVuIHBhZ2Ug
Y2FuIGJlIHJlY3ljbGVkLg0KPiANCj4gSW5zdGVhZCBvZiBtYWludGFpbmluZyB0aGUgcGFnZXJl
Zl9iaWFzIGluIHRoZSBwYWdlIGl0c2VsZiBpdCBjb3VsZCBiZQ0KPiBtYWludGFpbmVkIGluIHNv
bWUgc29ydCBvZiBzZXBhcmF0ZSBzdHJ1Y3R1cmUuIFlvdSBjb3VsZCBqdXN0IG1haW50YWluDQo+
IGEgcG9pbnRlciB0byBhIHNsb3QgaW4gYW4gYXJyYXkgc29tZXdoZXJlLiBUaGVuIHlvdSBjYW4g
c3RpbGwgYWNjZXNzDQo+IGl0IGlmIG5lZWRlZCwgdGhlIHBvaW50ZXIgd291bGQgYmUgc3RhdGlj
IGZvciBhcyBsb25nIGFzIGl0IGlzIGluIHRoZQ0KPiBwYWdlIHBvb2wsIGFuZCB5b3UgY291bGQg
aW52YWxpZGF0ZSB0aGUgcG9pbnRlciBwcmlvciB0byByZW1vdmluZyB0aGUNCj4gYmlhcyBmcm9t
IHRoZSBwYWdlLg0KPiANCg0KSGkgQWxleCwNCg0KVGhhdCdzIHJpZ2h0Lg0KQnV0IGFzIEkgZGVz
Y3JpYmUgaW4gbXkgb3RoZXIgcmVwbHkgeWVzdGVyZGF5LCB0aGVyZSBpcyBhIG1vcmUgc2VyaW91
cyANCmlzc3VlIHdpdGggY29tYmluaW5nIHRoZSBwYWdlcmVmX2JpYXMgZmVhdHVyZSB3aXRoIHRo
ZSBuZXcgcGFnZV9wb29sIA0KY2FwYWJpbGl0eSBmb3IgZWxldmF0ZWQgcmVmY291bnQgcGFnZXMu
DQpJdCB3b24ndCB3b3JrIG9uIHRvcCwgYW5kIHRoYXQncyBmaW5lLCBhcyB0aGUgaWRlYSBvZiB0
aGUgbmV3IGVsZXZhdGVkIA0KcmVmY291bnQgcXVldWUgY2FwYWJpbGl0eSBpcyBtb3JlIHByb21p
c2luZyBhbmQgaW1wb3J0YW50LCBhbmQgaXQgd2lucyBoZXJlLg0KDQpSZWdhcmRzLA0KVGFyaXEN
Cg==

