Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15257C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 01:49:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C09A206B6
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 01:49:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="QutsTOrN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C09A206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110538E0004; Mon,  4 Mar 2019 20:49:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C1978E0001; Mon,  4 Mar 2019 20:49:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAE908E0004; Mon,  4 Mar 2019 20:49:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB788E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 20:49:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so3674671ede.9
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 17:49:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=YxZKtjiFeE4gnGXzOi37GIHRBSbE0tz4GTNLwQ6+Ufo=;
        b=sqIfTbwCP5DQDdeLlFctK3xc2usqE/4RaWyiwt0ew+VCLOoxTQcr1MlrskDKKn0OMq
         2TSu+hJMWTotcpSXSLES9RRoyWsLyfQYIDaVgKNmoYm8OvI67FXgw1g+wADxeM2lq8wq
         45sW93p3IUWvL7Z8aVsnhWtAEFSa2Ter0uSR9K6ejQDOHSz97FkXPeBPnaaLER+htyDT
         n/2YCunWgdCdpNS70/srf10MXbaoktO/1ExDFtEKNFChp/UMWCBF5UGlGZBG3SLSHviN
         CPeCxz6ErT0bbsbaoqTKzRd6vayzjO+VGFhZft2Wb4vlT1QRHou4jkf/e0mXdbgzXxVR
         zd+w==
X-Gm-Message-State: APjAAAUVOu5pgSH1oREE7nquKgAwPw+28s+yE8UT2uqbaRl6ERaDoUXC
	spTls9fZBfjwVGCrjGNRXdT4TtQAdPU+J0vVp9CUh+Bg2BeHi8lADxwUruAxgTLx3K9gOMpRk1G
	E9aDwZoLIEltZN395gtxDs1e1R2g4bSKSERzXoyitmTWGSnK53BCIAp164XZD5xw8ig==
X-Received: by 2002:a50:ed81:: with SMTP id h1mr17679204edr.145.1551750573902;
        Mon, 04 Mar 2019 17:49:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqys7z8XjTESfmfet2T0GGYHrtMkG84Yiiq6RJgnvBAKKuKFonQ0iR9pbGGNvNm4KgJXn6pR
X-Received: by 2002:a50:ed81:: with SMTP id h1mr17679175edr.145.1551750573070;
        Mon, 04 Mar 2019 17:49:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551750573; cv=none;
        d=google.com; s=arc-20160816;
        b=tny0vxdbiItmGzyYmItGCoVo8atzqZm0pjWHMp+dOs5coxDFK0JumFfNnbz0KMiCIj
         PssClFgafL8JSinymuUnlvzGBgwzMZTztacB73Ux6o/4dqC0t2sUhIVX34yIXPKahTwm
         GlrEDROo0q4v//XtTsuZPvhR7ZUhUD0k43DuJKc8mm12CM3QIZ/mm1TXSnVcBMaGv/9Z
         6QtMLqAIcfYQbcvapuT+RXt/0dr6mF8b2H4Bdty64kJkV+1t777/W1qzeuomoEARjOQX
         jbqYtk/lqZ/kEp8Kg/9TBUP/0egzJeSbsIBZRxgCaewrYFfK1tWtAx2Lvc4EYEHhw7Vt
         ewhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=YxZKtjiFeE4gnGXzOi37GIHRBSbE0tz4GTNLwQ6+Ufo=;
        b=EI0npS6xeKQkQjorVY2tmMLj+yH2BNLq5Y4rExLCMDNP3suBkvP96c5/UOa7yc3/6U
         fE76F4VN6KPGUUFeWaNrHiUZPl/DPgd39Pa/SH3zGQpcLJs4ii4Y0bcmykeIVEQ/J9Ge
         ps6h0qQy5X88K1FbINUdrpQVaslcRYRgArggL/iysCXKra9KmvG48xLI1wVWMbAId7XI
         AVf76rxZNdE8Sv1ukvJfyZ4HVlyUxHaGbskQyqmqGzooz2vUTgALDXPHv1f3M3pnaKQh
         2zS+FGPTwIaEuz+UQPrJo2g4BRrPV03abJyw02K3G9PAYZfmnDQw1Hsf0wp/IaZdZCTz
         srsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=QutsTOrN;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.67 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50067.outbound.protection.outlook.com. [40.107.5.67])
        by mx.google.com with ESMTPS id d22si78350ejm.135.2019.03.04.17.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Mar 2019 17:49:33 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.67 as permitted sender) client-ip=40.107.5.67;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=QutsTOrN;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.67 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YxZKtjiFeE4gnGXzOi37GIHRBSbE0tz4GTNLwQ6+Ufo=;
 b=QutsTOrNhb2dBcBx/Yrfb/avT7fA1MkJd9cn2MBo4juMtwtllz6o9E+N3faoIhetUYo1uon1wpkt+yNADv6vlQzH17po1Lh/iE0fKZ6swCGYoKnY+OL0KucKzrJFZ/UCuadUR/v2bHg+jX/JUHr9YbtZRnBA0cAQyISBT8BQ4x0=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4803.eurprd04.prod.outlook.com (20.177.40.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.19; Tue, 5 Mar 2019 01:49:29 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.020; Tue, 5 Mar 2019
 01:49:29 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [PATCH 1/2] perpcu: correct pcpu_find_block_fit comments
Thread-Topic: [PATCH 1/2] perpcu: correct pcpu_find_block_fit comments
Thread-Index: AQHU0nXCD5AKhUIPbU2zUP7D5ZNbSqX719kAgABqFLA=
Date: Tue, 5 Mar 2019 01:49:29 +0000
Message-ID:
 <AM0PR04MB4481249A8F1B729E8E2AC41F88720@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190304104541.25745-1-peng.fan@nxp.com>
 <20190304191344.GB17970@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190304191344.GB17970@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [92.121.36.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 71778c2d-a38e-40c6-30c9-08d6a10cce93
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4803;
x-ms-traffictypediagnostic: AM0PR04MB4803:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0ODAzOzIzOjhQUVRGWmRyYzJpdXEvWHk3bGVtcFpxRkM4?=
 =?gb2312?B?Qko1YmFHWlJOSTNrS3VkN2hYbFBBU2hEQWJ2clZFYit2Mm9GT2ZHbitmU2Vv?=
 =?gb2312?B?dE1tMkR2K2JDTDhiVDZyT0FjMmVXYWFPbTZvdk4vMG5WRHIxT2doVXNmMVJ5?=
 =?gb2312?B?S1pHTlJTaGViTzE1NlFsWEpZNTBteStwekVETVVIV1A4SFdGN3Q3UkVLWnFQ?=
 =?gb2312?B?SUtCTWsrbDFFc2IwNkhRL2FLRFRmcHN5TVBCY2p6cFZCbkJwMk00NlhJUlJr?=
 =?gb2312?B?M0dSYXlxa3dXMkpjQ0o3Qjd0TysyY25YTDNlSUR6MGt5TmhuK0FFMGxxQTh1?=
 =?gb2312?B?OXRBdnY2M2dSY2h2d0RlYWU0SjJoQjN6Q1NmcVZHcWI0NDlaMDBIQllqTDNE?=
 =?gb2312?B?MDRxcFJNMWUwMlZvblVEYVlucWJpT0h3MVN2Q2gvdm9KUnpWQTVGTE1VS0ts?=
 =?gb2312?B?L1RkZEVjaFFGZ0paTGthRVpXRHV3VExrdW4yQTNZc292UFFvSjM0ZEFrNDJo?=
 =?gb2312?B?Mm1YNjRHSWF2bTd1VldmN0lsWks3YWxaUEJTcUVZL1FEdkI4WG0wZGVNS2Rm?=
 =?gb2312?B?WXdRNjBpcVh1QWFyVlVaSTZPY1Y3YkRTNzRoT2Q3aWJVY0JZd0tNdlFhNjRS?=
 =?gb2312?B?dk4yZnZPU00vY09MOEJWUElZaUtJeTdrcy8xUzF0SXcwQWgrWENEbnk2OTZo?=
 =?gb2312?B?emM3V0dLRlZHMWxKT0FWNGlUMHF3UnV2b3dYaTNCZmwxU1gwaXNvWVM1c2xk?=
 =?gb2312?B?R2dBUGFZTU1KUm43eE55QXNnOVZVQmo2K1REU01MZm9hdURtTEV3TlpWTUhG?=
 =?gb2312?B?ZFJRL1Uvejhnc1d0bG5ReTVQQVBGdmk4Tk9aaUdVY3dpZHphZy9qVkdNTS8x?=
 =?gb2312?B?WUlFMlZDYlplNGg3ZmNucWVBeSs1K3hUaDd4Y0ptR1BiL1pBRmtrOFJFRmFj?=
 =?gb2312?B?bHM3cE9ySU1YWGlzNXlidTdLU3g5WG8zeDV3WVUvNzdOZW05QThhbStFL3RK?=
 =?gb2312?B?Nk1oOG5oMmFrZEU5UEVpTW9lR2dPY2kxVitVK0FwaW9Ldzh5VXNqMWlxa1Fn?=
 =?gb2312?B?YURrYkRUZVBjNUNYZVNuWEpQdktLNmU4SC9BczhTWm1qajFBZVcxZi9NVmtk?=
 =?gb2312?B?Rk1OaGdxbTV3bmNrdlk1cUwxZWdWdVA2Qjdua1dqTUNxZVZTUndiSVBtbkpX?=
 =?gb2312?B?UHFweTUzR3h0czRObHhSTEhoVzVySU9vR2l2d3JxOFZiUzBGWHo2QktoeGNj?=
 =?gb2312?B?RlNDL21mWnpIYzMzUnhwVkZOMGk5em10TmVodlhKK21oSEZYSzlJZHBZNkw2?=
 =?gb2312?B?ZkU3YkpMdFNrN3ViblJZcGhxMWxZSHZIdytNVWxmejBkajYzVFVxdXoyNEg4?=
 =?gb2312?B?Y3ltRWRRZmlXNE16S01vRUdCdklEd25TZkVScDEyL2FDaE9mMm1DZlBmVjBa?=
 =?gb2312?B?ejBiWHBvdGt4VktGcHBVWHA3aFJFRkVFUXZzOVp4SUo3NGR1N3dYWjNvZ0wv?=
 =?gb2312?B?clFYSTV6WXZhd25Xam1aSjFvSi9CTHgzODM0R0pVaDVXdnRqa0pWTGxnRE9N?=
 =?gb2312?B?L3lHTkpXd3BubWtsUTBwWFlkTXpsWUpnb2d1UVNBWlhXSXdVUStWQWdFN0l6?=
 =?gb2312?B?NXNWY3VhdFdTNjE4ek1qZ3lsb21KRHEyL3cxK0RieDF6QnAxUmRYeFRaR1Rm?=
 =?gb2312?B?MytYbW91TTlobVRHbVJnTjVPbXhvN0t2ZlVOdnphRE9RYXNQNEVscHEraCtl?=
 =?gb2312?B?NFUydmMwK3NKejZWNTdJbVpqdUFNaDRkMy9rM0NtZjl2SUhFOE5uYnl1T1Za?=
 =?gb2312?B?NTdjclhQUzZ5bGE3ZWw0T1E4ZmtLNDdnaEJKbU4xa3ArVVE9PQ==?=
x-microsoft-antispam-prvs:
 <AM0PR04MB480365DF9030DF5B094EBDF388720@AM0PR04MB4803.eurprd04.prod.outlook.com>
x-forefront-prvs: 0967749BC1
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(366004)(136003)(376002)(346002)(13464003)(189003)(199004)(11346002)(66066001)(476003)(446003)(99286004)(53936002)(44832011)(486006)(74316002)(86362001)(6506007)(71200400001)(102836004)(71190400001)(14444005)(53546011)(76176011)(229853002)(256004)(97736004)(6246003)(4326008)(26005)(7736002)(54906003)(7696005)(6436002)(105586002)(45080400002)(106356001)(305945005)(25786009)(478600001)(6916009)(8936002)(966005)(186003)(2906002)(33656002)(6116002)(14454004)(3846002)(55016002)(8676002)(81166006)(9686003)(81156014)(6306002)(52536013)(5660300002)(68736007)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4803;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 1R12QitoFq4nD2oGMYRN4ACmd2ViNT8qlvG0o+jv9Hwm0ZgfsO/SeM2eNTpLS/fqDScZ5DtZc/4iKb3QB/zq1Tswjb2/abT77QpJUST8ZD5bx/BDb6m5mXG5Yob/vuS/9HaEIKvJjLH7Czr0BekmTm/HdOTvxqSrkjUKrmWFfo7GWR/B9OvOmTFDLuPzPmOk7bNAgjCQ6LljgHcQrqpaEIt9LSKEHjt/ysB992lqHeJelQ7mWTyt+qzgw4LMwdAz1DWLllerahkOty8O8wA+Ddkm+kcGoLDVxwoLs4IVFSBQ1+DFaPlXNTB/+msz5Yp2GlS/Cu8E8B5i0+/ogffQjveQ1snunlRwHJmEgsMARVSXLEEOWePxrmymn7ko6eSgst4RHTzSRcn06CRSn+E4CUKeJOX8DNoVA5CEpRjHyjI=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 71778c2d-a38e-40c6-30c9-08d6a10cce93
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Mar 2019 01:49:29.6295
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4803
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGVubmlzIFpob3UgW21h
aWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOcTqM9TCNcjVIDM6MTQNCj4gVG86
IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiBDYzogdGpAa2VybmVsLm9yZzsgY2xAbGlu
dXguY29tOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5v
cmc7IHZhbi5mcmVlbml4QGdtYWlsLmNvbQ0KPiBTdWJqZWN0OiBSZTogW1BBVENIIDEvMl0gcGVy
cGN1OiBjb3JyZWN0IHBjcHVfZmluZF9ibG9ja19maXQgY29tbWVudHMNCj4gDQo+IE9uIE1vbiwg
TWFyIDA0LCAyMDE5IGF0IDEwOjMzOjUyQU0gKzAwMDAsIFBlbmcgRmFuIHdyb3RlOg0KPiA+IHBj
cHVfZmluZF9ibG9ja19maXQgaXMgbm90IGZpbmQgYmxvY2sgaW5kZXgsIGl0IGlzIHRvIGZpbmQg
dGhlIGJpdG1hcA0KPiA+IG9mZiBpbiBhIGNodW5rLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTog
UGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQo+ID4gLS0tDQo+ID4NCj4gPiBWMToNCj4gPiAg
IEJhc2VkIG9uDQo+ID4NCj4gaHR0cHM6Ly9lbWVhMDEuc2FmZWxpbmtzLnByb3RlY3Rpb24ub3V0
bG9vay5jb20vP3VybD1odHRwcyUzQSUyRiUyRnBhdA0KPiA+DQo+IGNod29yay5rZXJuZWwub3Jn
JTJGY292ZXIlMkYxMDgzMjQ1OSUyRiZhbXA7ZGF0YT0wMiU3QzAxJTdDcGVuZy4NCj4gZmFuJTQw
DQo+ID4NCj4gbnhwLmNvbSU3Q2ViYjRkM2QzMWRjYTRjNzZlYzJlMDhkNmEwZDU4N2ZkJTdDNjg2
ZWExZDNiYzJiNGM2ZmE5DQo+IDJjZDk5YzUNCj4gPg0KPiBjMzAxNjM1JTdDMCU3QzAlN0M2MzY4
NzMyMzYzMDg5MDUxNzImYW1wO3NkYXRhPVBPTTBhTEI1UDdnM3kNCj4gcDZvRDVzOHVEWQ0KPiA+
IDYyOWpmSWVvNGhrbzRQY3FOQTcwJTNEJmFtcDtyZXNlcnZlZD0wIGFwcGxpZWQgbGludXgtbmV4
dA0KPiA+DQo+ID4gIG1tL3BlcmNwdS5jIHwgMiArLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9tbS9wZXJj
cHUuYyBiL21tL3BlcmNwdS5jIGluZGV4DQo+ID4gN2Y2MzBkNTQ2OWU4Li41ZWU5MGZjMzRlYTMg
MTAwNjQ0DQo+ID4gLS0tIGEvbW0vcGVyY3B1LmMNCj4gPiArKysgYi9tbS9wZXJjcHUuYw0KPiA+
IEBAIC0xMDYxLDcgKzEwNjEsNyBAQCBzdGF0aWMgYm9vbCBwY3B1X2lzX3BvcHVsYXRlZChzdHJ1
Y3QgcGNwdV9jaHVuaw0KPiA+ICpjaHVuaywgaW50IGJpdF9vZmYsIGludCBiaXRzLCAgfQ0KPiA+
DQo+ID4gIC8qKg0KPiA+IC0gKiBwY3B1X2ZpbmRfYmxvY2tfZml0IC0gZmluZHMgdGhlIGJsb2Nr
IGluZGV4IHRvIHN0YXJ0IHNlYXJjaGluZw0KPiA+ICsgKiBwY3B1X2ZpbmRfYmxvY2tfZml0IC0g
ZmluZHMgdGhlIG9mZnNldCBpbiBjaHVuayBiaXRtYXAgdG8gc3RhcnQNCj4gPiArIHNlYXJjaGlu
Zw0KPiA+ICAgKiBAY2h1bms6IGNodW5rIG9mIGludGVyZXN0DQo+ID4gICAqIEBhbGxvY19iaXRz
OiBzaXplIG9mIHJlcXVlc3QgaW4gYWxsb2NhdGlvbiB1bml0cw0KPiA+ICAgKiBAYWxpZ246IGFs
aWdubWVudCBvZiBhcmVhIChtYXggUEFHRV9TSVpFIGJ5dGVzKQ0KPiA+IC0tDQo+ID4gMi4xNi40
DQo+ID4NCj4gDQo+IFNvIHJlYWxseSB0aGUgYmxvY2sgaW5kZXggaXMgZW5jb2RlZCBpbiB0aGUg
Yml0IG9mZnNldC4gSSdtIG5vdCBzdXBlcg0KPiBoYXBweSB3aXRoIGVpdGhlciB3b3JkaW5nIGJl
Y2F1c2UgdGhlIHBvaW50IG9mIHRoZSBmdW5jdGlvbiByZWFsbHkgaXMgdG8NCj4gZmluZCBhIGJs
b2NrKHMpIHRoYXQgY2FuIHN1cHBvcnQgdGhpcyBhbGxvY2F0aW9uIGFuZCBpdCBoYXBwZW5zIHRo
ZQ0KPiBvdXRwdXQgaXMgYSBjaHVuayBvZmZzZXQuDQoNCkkganVzdCB0aGluayB0aGUgY29tbWVu
dHMgaXMgY29uZnVzaW5nLCBiZWNhdXNlIGJsb2NrX2luZGV4IGlzIG5vdCB1c2VkIGluDQp0aGlz
IGZ1bmN0aW9uIG9yIHJldHVybmVkLiBIb3dldmVyIHRoZSBmdW5jdGlvbiByZXR1cm5zIGEgYml0
IG9mZnNldA0KaW4gYSBjaHVuayBmb3IgY2FsbGVyJ3MuIEkgdW5kZXJzdGFuZCBibG9jayBpbmRl
eCBpcyBlbmNvZGVkIGluIHRoZSBiaXQgb2Zmc2V0IGFzIGZvbGxvd2luZw0KICAgICAgICAgICAg
YmxvY2tfaW5kZXggICAgIA0KICAgICAgICAgICAgICB8DQogICAgICAgICAgICAgIHYNCkJsb2Nr
ICAgfC0tLS18LS0tLXwtLS0tfC0tLS18LS0tLXwtLS0tfC0tLS18LS0tLXwtLS0tfC0tLS18DQpD
aHVuayAgfC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLXwNCiAgICAgICAgICAgICAgICB8DQogICAgICAgICAgICAgICAgVg0KICAgICAgICAgICAg
ICAgYml0X29mZiBpbiBhIGNodW5rDQphbmQgYml0X29mZiA9IGJsb2NrX2luZGV4ICogUENQVV9C
SVRNQVBfQkxPQ0tfQklUUyArIG9mZnNldCBpbiBhIGJsb2NrDQoNCkknbGwgbGVhdmUgaXQgYXMg
aXMsIHNpbmNlIHlvdSBub3QgcHJlZmVyLg0KDQpUaGFua3MsDQpQZW5nLg0KPiANCj4gVGhhbmtz
LA0KPiBEZW5uaXMNCg==

