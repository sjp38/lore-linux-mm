Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A70EFC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:02:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48F1721850
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:02:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="RqRNKURS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48F1721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF75C8E0003; Wed, 27 Feb 2019 08:02:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA6A98E0001; Wed, 27 Feb 2019 08:02:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46D28E0003; Wed, 27 Feb 2019 08:02:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 584748E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:02:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a9so6995029edy.13
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 05:02:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=K45MmbRvOZbHDlvUb35gg8/x/6MqGUjDBkjyYusRYlY=;
        b=fk9KsNkRW1AsKxcdYK4I79v75kPZh9N3+/EvcNosTYLqlCSU7Ti6zdihNVxsgbKhT/
         qIu2UwH2K9uE5QPldmmzVRLOPk4iI9ZpO9UONbo7S5a6KkVsk4OrnfsEEjDWd0LYzJpK
         3kfxsSl7NYGzaAjnk0ItH1p0p0ChRNAll0vnJZi+XbSSgJ2/yCa4sEcaXL/IMPLRWDpI
         8f/7E4K99s8mx+g6BqhcszHIVDf/RMdij3GEIgPJBuwYMsetO6yuyYqNF832KHmekI+S
         qv7cxuQn0gma3hCXxVvSyDEqPxFBTRAjzYj1r+1A6YoFJ5NxyunxnyFqhyUbthwgJ+Q6
         tuKQ==
X-Gm-Message-State: AHQUAuZN83J6vuii0VwniMcZapL6cLUWeEbV3FBC52wzHwH2PuwoqPJB
	4vI/F0awm3KGDZm0xlziyDh4kpuMFdzsyLcpKMAP/NpEPzFcaCv7Tqd33eY2crbrW+7X35Nq7wr
	Z8wMtxiw+GzkmLr3b0RMojjE/h3wlEqXcNdY38mOZ55g2iPts6YprcHL3FtlJPE5PbQ==
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr2282263eds.102.1551272538714;
        Wed, 27 Feb 2019 05:02:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjmTlf3eO4M1xsgn03gjhyAzhP+B5r9S27VrojMUFzJu2Gvu4b4BxCjsXoxdyBLPuPhPyo
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr2282193eds.102.1551272537616;
        Wed, 27 Feb 2019 05:02:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551272537; cv=none;
        d=google.com; s=arc-20160816;
        b=KgN+ytOvO8KcJ+7skynZk5tBzhXIWDsc6/CCZ1wxsR9XoOBI8cjAlAA6xuOD7c0C4D
         gZpmCoPzEn7N612ga07pTx5Q5q7O0J6+ywKxghKIKttmqgzyG8nxsy+3H+YVNg1jW55C
         xnIF7TKXM2GY+YWYmGnkSt4N3gnup/hNYXjRa99fR5WyBt2qaYkSpIj2AazUz/X6MGQv
         if2JiTffvN0AgqhCuAo8/HW8LWVy8lQL8/2jOtVPjnbatJiHofJAC9xZ+KOew6HWy2WJ
         L97Mv8E6fRiDC9HoUEmdNa8+VvEW+XB8V5Kb/ZZqI/+Y1DUsw9McbgFIrzVkvjvaUIXw
         mpww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=K45MmbRvOZbHDlvUb35gg8/x/6MqGUjDBkjyYusRYlY=;
        b=GfDW270I13Ik0SgAF/Rbek6rWDZz2c9/E3bMkRDia13+s34QYkI1YrIhBiSEbcNsFP
         fY+boqkMGbwuubAuWn/84QdDgbSBNGieVQ63Z2m0dGLGNU5LqkF5uILoWcGM0/rYwB/F
         zcDL2WHeurS1b1yGeQYj338gNVULepJaSXuqtu5zXSVAxCOqgCIorgrdROyX5CYNkgSD
         5gPWDc6NiADUrVAMAuGGnsfiD/AOUFDkUJzT2pJxxoIzKbt7n+A0t9kFvHamLF7GWYwL
         kyz4w13gORTTYm+1UqZHjInrv5d+3GKZ/fK7ZQviC7TOI78hEJ3cbhb0L22WvjPnuyWZ
         524g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=RqRNKURS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.81 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80081.outbound.protection.outlook.com. [40.107.8.81])
        by mx.google.com with ESMTPS id o13si5299754ejm.7.2019.02.27.05.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 05:02:17 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.81 as permitted sender) client-ip=40.107.8.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=RqRNKURS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.81 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=K45MmbRvOZbHDlvUb35gg8/x/6MqGUjDBkjyYusRYlY=;
 b=RqRNKURSxe7cIj5GtU8u6v8iG7IM+/QgsVprmfCVXqxyFSFa38xIjFScUL4AZAhbTGvccoG1+6kZa9gzXzEveldDUQVm+BqFpWfO1tsjAmnHNSsibhdOFyl3E77zbFNoCgu9uwi4Ej42QKXLzWYzPSfYAlA3pvVQ4T4mBW5v8PE=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4322.eurprd04.prod.outlook.com (52.134.125.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.18; Wed, 27 Feb 2019 13:02:16 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1643.019; Wed, 27 Feb 2019
 13:02:16 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Christopher Lameter <cl@linux.com>
CC: "tj@kernel.org" <tj@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [PATCH 1/2] percpu: km: remove SMP check
Thread-Topic: [PATCH 1/2] percpu: km: remove SMP check
Thread-Index: AQHUzELEXhV7UVWfi0W/HwwXYpeEX6XwoM8AgAGTPACAAB3fgIABS/yA
Date: Wed, 27 Feb 2019 13:02:16 +0000
Message-ID:
 <AM0PR04MB44814B3BA09388DFF3681E1388740@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
 <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
 <20190226170339.GB47262@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190226170339.GB47262@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: caeb20c0-a6ff-405f-3586-08d69cb3cc6d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4322;
x-ms-traffictypediagnostic: AM0PR04MB4322:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0MzIyOzIzOkpBWEhUZjRidHk5Ykp2ME9DdG1uSXlLaC8v?=
 =?gb2312?B?SWxaWTBmNGFDeXpNZFZVU0NYZ1JJcTkyanp2eDQxWWlKVXFUbDZxV2VQa2pw?=
 =?gb2312?B?dzVYYmJQSXcrZUxscnByY1FkZ3plQVFHRnFUcE1JSWE5VUcvK2xBSDJ3TDdn?=
 =?gb2312?B?VzR0elhWQzdJRkoyQnlBdDB6MnRqdXQxa2xOcHN1VUI2WktrT3gzZXlXeFph?=
 =?gb2312?B?MWJ1VDZPaXQzbGhDbVdHaXZpTmZmdmZWeTJXSlBBQWZ4Mk41bWdhcEhTM1gw?=
 =?gb2312?B?WkM4Q0FOT3QyamM1dGYzbE9NM3oxeG0wUnZzdXNQQ3dQRUNSVkpxUkoweUY2?=
 =?gb2312?B?dlpHVGlNRHpwUW9sbVc1cHRaQzV2VkhmaEY5SUlBc0pQTEVMelQxNzdvUGww?=
 =?gb2312?B?emM1UnZkeGhCVTRmb1JIQnJ3NDRkZ2UrVXY2QlR1V3ZNNHBjZWIrSWRhZXhH?=
 =?gb2312?B?MVVHQkVyMGtERjBvcTBNd3RpcGpEUVlDcVFFcjNCaEFXd2M4MjhVVkR5Zk12?=
 =?gb2312?B?UXdEQ2VXU0hKbmNCckNFMmpkOGZuMlhXb2MydEUxblBLaWMwZFp5RjlnYUlT?=
 =?gb2312?B?MjRTWE1sTm1SUFV1UWxKMkZTRVE5UER4SWJ3QmZQY3cwdWhyd0dreGRJYWll?=
 =?gb2312?B?anljWnJ5a0lXWmJzQm1UbUxnTlV2cmxhV0NuY1pMKytQY1lBWkhqb056a3h2?=
 =?gb2312?B?bmNVUURlS05RK3Qxc0dQdXE4MU1lazc0T1RvK0dQbzBLVTBkQUVtck5WY0hC?=
 =?gb2312?B?VGFjNjZ2RERHYjlwK2tqQjJDUmpFdTdCL3M4d0NSQ05sbkdMeGdIYTZiTWZz?=
 =?gb2312?B?ekNlSjlXU2psaUR3TjhKck8rUDNNZUI2T2UvMjlwanBzMWlxS2VkZjdRQVFw?=
 =?gb2312?B?QjRiQnRPb3VuejJuYVpXblhjUkUrZUZOSmNmNzhicE84Ky92OE9tTDltWHpH?=
 =?gb2312?B?cXZCZjRRQ25YQWI5TlB0bi90Zi8wK0V3YndaK0xRMzBUcnc4azFEZ1gveStH?=
 =?gb2312?B?RW5UZTUyYVVYMEVZZmFTK09FWnl6YjhlU2tFQWl5TS9HZXhmOUJwY0ZjUzV5?=
 =?gb2312?B?RWEwNDBxaUtEN0hjRmczWVRVVDQ2OTYxY0NmWFUySmExRVM4b0drbXNzSGl6?=
 =?gb2312?B?RUNXUEprS0xOTSs3L1Exanh1cjBGWjg0ZnBWQUJBcFJPQ2U1T1dCWHVWVGs0?=
 =?gb2312?B?Nmg4aGJ3am0xUHJ3SzdSVVRjUkEwclBVZGt6eHp3RkpweFptM0pKN0dPWDVT?=
 =?gb2312?B?SFZiSXE0VXVRdDM5Wmh5Z2xGV01ST1pnZHhPalJHTUpVRzNqdVphRXFWcmwy?=
 =?gb2312?B?b1BpMElsQUpHY1djTjZ4aWowZjRETzh6Tm1wRlhYNVc2a20wamNqbzNPRUVZ?=
 =?gb2312?B?YkhKTHoxQ1ZWc1YvbUhKOVFSc3BYdEt6dHJLaHduN01XTHdiMEJwQy8ycFlh?=
 =?gb2312?B?M2dvczhzKzZ1eHh2NEVMcjNYODB6OHU0c1p3Ti85RlZCN0tVYXpHcS9SNHcr?=
 =?gb2312?B?RkU2TW1SMk5wbDFub0kwK3RVUlZDTjFHdVE5ZlpaL3N0TitTYXpIL2ZnRjl2?=
 =?gb2312?B?R2p0VlZ2N01BUEh2cWE1RkhFMDJwTW5Pb29kR1VyYXIxajczQis3ZlZFRmZu?=
 =?gb2312?B?blYwZkdnU2IxWC9kbStTZnFkd3JLS1Q3ZWFscHJiVDc3cXljWllaUEMvVTlH?=
 =?gb2312?B?dzJYbUJjaWNNZCtza3VRcnJTNW1nM0VSVTluVGhsRllvMlFDeVp2ZmlPc2lG?=
 =?gb2312?Q?zI4qI1ShbP5+gZTesj6VeXe7Kqi6hgkrF8Tzg=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB43220482E51DC61035B2A33D88740@AM0PR04MB4322.eurprd04.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(136003)(366004)(346002)(396003)(39860400002)(199004)(189003)(13464003)(68736007)(3846002)(74316002)(486006)(6116002)(44832011)(305945005)(6246003)(446003)(11346002)(7736002)(8676002)(93886005)(8936002)(25786009)(476003)(66066001)(81156014)(81166006)(186003)(54906003)(110136005)(33656002)(97736004)(4326008)(55016002)(53936002)(316002)(6506007)(9686003)(26005)(53546011)(478600001)(14454004)(229853002)(6436002)(102836004)(86362001)(106356001)(14444005)(256004)(71190400001)(71200400001)(2906002)(99286004)(52536013)(5660300002)(105586002)(7696005)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4322;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 D5/4/Pzfc+3ypwpvNid5rNYjSQS/5FUojby6M5clPhnrPvu45V8f5aYX3aQFukFsgnI0qWwjMeIJT1wKToScJipGdG/6F5TibrNo5zL1oHROM4i5/oCmPMrMZTvcHOVoX0XoGPm0Kn9FC9myqZlrP6/Vj75Hx5dgerAzgmXvqUZDfLKwED87QFzmqAy85/2qN6Fw6WwvQK1NR1C65Ni7/vtKbSzFgMoPEZQxRGcepl9roPtgBa1f6Co/levhC3JrkMlFfNwtytLPangoy3oW72pgCtcalws8ITk72XrDcL0r9S41s844ZzsYf4XSYT0OZZ0gS0+kU5a0SU9Rk3UxMpQVl4fuffDCrU4IqxayLFNmQZ9AwbyC2Ece/uaof5xPzZG3B46/dLHOlGSM/BFG1P+Yc3HjFUSwbj+JzzYmhKg=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: caeb20c0-a6ff-405f-3586-08d69cb3cc6d
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 13:02:16.1081
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4322
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGVubmlz
IFpob3UgW21haWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOcTqMtTCMjfI1SAx
OjA0DQo+IFRvOiBDaHJpc3RvcGhlciBMYW1ldGVyIDxjbEBsaW51eC5jb20+DQo+IENjOiBQZW5n
IEZhbiA8cGVuZy5mYW5AbnhwLmNvbT47IHRqQGtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9y
ZzsNCj4gbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgdmFuLmZyZWVuaXhAZ21haWwuY29t
DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8yXSBwZXJjcHU6IGttOiByZW1vdmUgU01QIGNoZWNr
DQo+IA0KPiBPbiBUdWUsIEZlYiAyNiwgMjAxOSBhdCAwMzoxNjo0NFBNICswMDAwLCBDaHJpc3Rv
cGhlciBMYW1ldGVyIHdyb3RlOg0KPiA+IE9uIE1vbiwgMjUgRmViIDIwMTksIERlbm5pcyBaaG91
IHdyb3RlOg0KPiA+DQo+ID4gPiA+IEBAIC0yNyw3ICsyNyw3IEBADQo+ID4gPiA+ICAgKiAgIGNo
dW5rIHNpemUgaXMgbm90IGFsaWduZWQuICBwZXJjcHUta20gY29kZSB3aWxsIHdoaW5lIGFib3V0
IGl0Lg0KPiA+ID4gPiAgICovDQo+ID4gPiA+DQo+ID4gPiA+IC0jaWYgZGVmaW5lZChDT05GSUdf
U01QKSAmJg0KPiA+ID4gPiBkZWZpbmVkKENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9D
SFVOSykNCj4gPiA+ID4gKyNpZiBkZWZpbmVkKENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJT
VF9DSFVOSykNCj4gPiA+ID4gICNlcnJvciAiY29udGlndW91cyBwZXJjcHUgYWxsb2NhdGlvbiBp
cyBpbmNvbXBhdGlibGUgd2l0aCBwYWdlZCBmaXJzdA0KPiBjaHVuayINCj4gPiA+ID4gICNlbmRp
Zg0KPiA+ID4gPg0KPiA+ID4gPiAtLQ0KPiA+ID4gPiAyLjE2LjQNCj4gPiA+ID4NCj4gPiA+DQo+
ID4gPiBIaSwNCj4gPiA+DQo+ID4gPiBJIHRoaW5rIGtlZXBpbmcgQ09ORklHX1NNUCBtYWtlcyB0
aGlzIGVhc2llciB0byByZW1lbWJlcg0KPiA+ID4gZGVwZW5kZW5jaWVzIHJhdGhlciB0aGFuIGhh
dmluZyB0byBkaWcgaW50byB0aGUgY29uZmlnLiBTbyB0aGlzIGlzIGEgTkFDSw0KPiBmcm9tIG1l
Lg0KPiA+DQo+ID4gQnV0IGl0IHNpbXBsaWZpZXMgdGhlIGNvZGUgYW5kIG1ha2VzIGl0IGVhc2ll
ciB0byByZWFkLg0KPiA+DQo+ID4NCj4gDQo+IEkgdGhpbmsgdGhlIGNoZWNrIGlzbid0IHF1aXRl
IHJpZ2h0IGFmdGVyIGxvb2tpbmcgYXQgaXQgYSBsaXR0bGUgbG9uZ2VyLg0KPiBMb29raW5nIGF0
IHg4NiwgSSBiZWxpZXZlIHlvdSBjYW4gY29tcGlsZSBpdCB3aXRoICFTTVAgYW5kDQo+IENPTkZJ
R19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSyB3aWxsIHN0aWxsIGJlIHNldC4gVGhpcyBz
aG91bGQNCj4gc3RpbGwgd29yayBiZWNhdXNlIHg4NiBoYXMgYW4gTU1VLg0KDQpZb3UgYXJlIHJp
Z2h0LCB4ODYgY291bGQgYm9vdHMgdXAgd2l0aCBORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVO
Sw0KPXkgYW5kIFNNUD1uLiBUZXN0ZWQgd2l0aCBxZW11LCBpbmZvIGFzIGJlbG93Og0KDQovICMg
emNhdCAvcHJvYy9jb25maWcuZ3ogfCBncmVwIE5FRURfUEVSX0NQVV9LTQ0KQ09ORklHX05FRURf
UEVSX0NQVV9LTT15DQovICMgemNhdCAvcHJvYy9jb25maWcuZ3ogfCBncmVwIFNNUA0KQ09ORklH
X0JST0tFTl9PTl9TTVA9eQ0KIyBDT05GSUdfU01QIGlzIG5vdCBzZXQNCkNPTkZJR19HRU5FUklD
X1NNUF9JRExFX1RIUkVBRD15DQovICMgemNhdCAvcHJvYy9jb25maWcuZ3ogfCBncmVwIE5FRURf
UEVSX0NQVV9QQUdFX0ZJUlNUX0NIVU5LDQpDT05GSUdfTkVFRF9QRVJfQ1BVX1BBR0VfRklSU1Rf
Q0hVTks9eQ0KLyAjIGNhdCAvcHJvYy9jcHVpbmZvDQpwcm9jZXNzb3IgICAgICAgOiAwDQp2ZW5k
b3JfaWQgICAgICAgOiBBdXRoZW50aWNBTUQNCmNwdSBmYW1pbHkgICAgICA6IDYNCm1vZGVsICAg
ICAgICAgICA6IDYNCm1vZGVsIG5hbWUgICAgICA6IFFFTVUgVmlydHVhbCBDUFUgdmVyc2lvbiAy
LjUrDQpzdGVwcGluZyAgICAgICAgOiAzDQpjcHUgTUh6ICAgICAgICAgOiAzMTkyLjYxMw0KY2Fj
aGUgc2l6ZSAgICAgIDogNTEyIEtCDQpmcHUgICAgICAgICAgICAgOiB5ZXMNCmZwdV9leGNlcHRp
b24gICA6IHllcw0KY3B1aWQgbGV2ZWwgICAgIDogMTMNCndwICAgICAgICAgICAgICA6IHllcw0K
ZmxhZ3MgICAgICAgICAgIDogZnB1IGRlIHBzZSB0c2MgbXNyIHBhZSBtY2UgY3g4IGFwaWMgc2Vw
IG10cnIgcGdlIG1jYSBjbW92IHBhdCBwc2UzNiBjbGZsdXNoIG1teCBmeHNyIHNzZSBzc2UyIHN5
c2NhbGwgbnggbG0gbm9wbCBjcHVpZCBwbmkgY3gxNiBoeXBlcnZpc29yIGxhaGZfbG0gc3ZtIDNk
bm93cHJlZmV0bA0KYnVncyAgICAgICAgICAgIDogZnhzYXZlX2xlYWsgc3lzcmV0X3NzX2F0dHJz
IHNwZWN0cmVfdjEgc3BlY3RyZV92MiBzcGVjX3N0b3JlX2J5cGFzcw0KYm9nb21pcHMgICAgICAg
IDogNjM4NS4yMg0KVExCIHNpemUgICAgICAgIDogMTAyNCA0SyBwYWdlcw0KY2xmbHVzaCBzaXpl
ICAgIDogNjQNCmNhY2hlX2FsaWdubWVudCA6IDY0DQphZGRyZXNzIHNpemVzICAgOiA0MiBiaXRz
IHBoeXNpY2FsLCA0OCBiaXRzIHZpcnR1YWwNCnBvd2VyIG1hbmFnZW1lbnQ6DQoNCg0KQnV0IGZy
b20gdGhlIGNvbW1lbnRzIGluIHRoaXMgZmlsZToNCiINCiogLSBDT05GSUdfTkVFRF9QRVJfQ1BV
X1BBR0VfRklSU1RfQ0hVTksgbXVzdCBub3QgYmUgZGVmaW5lZC4gIEl0J3MNCiAqICAgbm90IGNv
bXBhdGlibGUgd2l0aCBQRVJfQ1BVX0tNLiAgRU1CRURfRklSU1RfQ0hVTksgc2hvdWxkIHdvcmsN
CiAqICAgZmluZS4NCiINCg0KSSBkaWQgbm90IHJlYWQgaW50byBkZXRhaWxzIHdoeSBpdCBpcyBu
b3QgYWxsb3dlZCwgYnV0IHg4NiBjb3VsZCBzdGlsbCB3b3JrIHdpdGggS00NCmFuZCBORUVEX1BF
Ul9DUFVfUEFHRV9GSVJTVF9DSFVOSy4NCg0KPiANCj4gSSB0aGluayBtb3JlIGNvcnJlY3RseSBp
dCB3b3VsZCBiZSBzb21ldGhpbmcgbGlrZSBiZWxvdywgYnV0IEkgZG9uJ3QgaGF2ZSB0aGUNCj4g
dGltZSB0byBmdWxseSB2ZXJpZnkgaXQgcmlnaHQgbm93Lg0KPiANCj4gVGhhbmtzLA0KPiBEZW5u
aXMNCj4gDQo+IC0tLQ0KPiBkaWZmIC0tZ2l0IGEvbW0vcGVyY3B1LWttLmMgYi9tbS9wZXJjcHUt
a20uYyBpbmRleA0KPiAwZjY0M2RjMmRjNjUuLjY5Y2NhZDdkOTgwNyAxMDA2NDQNCj4gLS0tIGEv
bW0vcGVyY3B1LWttLmMNCj4gKysrIGIvbW0vcGVyY3B1LWttLmMNCj4gQEAgLTI3LDcgKzI3LDcg
QEANCj4gICAqICAgY2h1bmsgc2l6ZSBpcyBub3QgYWxpZ25lZC4gIHBlcmNwdS1rbSBjb2RlIHdp
bGwgd2hpbmUgYWJvdXQgaXQuDQo+ICAgKi8NCj4gDQo+IC0jaWYgZGVmaW5lZChDT05GSUdfU01Q
KSAmJg0KPiBkZWZpbmVkKENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSykNCj4g
KyNpZiAhZGVmaW5lZChDT05GSUdfTU1VKSAmJg0KPiArZGVmaW5lZChDT05GSUdfTkVFRF9QRVJf
Q1BVX1BBR0VfRklSU1RfQ0hVTkspDQo+ICAjZXJyb3IgImNvbnRpZ3VvdXMgcGVyY3B1IGFsbG9j
YXRpb24gaXMgaW5jb21wYXRpYmxlIHdpdGggcGFnZWQgZmlyc3QgY2h1bmsiDQo+ICAjZW5kaWYN
Cj4gDQoNCkFja2VkLWJ5OiBQZW5nIEZhbiA8cGVuZy5mYW5AbnhwLmNvbT4NCg0KVGhhbmtzLA0K
UGVuZw0K

