Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CA27C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 12:56:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D502420857
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 12:56:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="DHF0wpi2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D502420857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 365208E0003; Sat,  2 Mar 2019 07:56:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 316EC8E0001; Sat,  2 Mar 2019 07:56:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DFC68E0003; Sat,  2 Mar 2019 07:56:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B61218E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 07:56:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i20so372152edv.21
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 04:56:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=xKkrdgy4sxDG+g4+6p6ybVWcmJjsSEcbrNBjKqfqtmQ=;
        b=HACX0h1b6nkBoGo1IIp27nsjpvr/O0K5iuMUilDEZ9CVIYgQ69GCjzRQE75+YcOuTU
         HOJkDsh9n/XG0MSHTLDTExriv3o84ZxOTlD50TUhdA5bEGU+3ZVyZ+2AlYvYbLuSRa6D
         rFx8CqRS68mI4bwP3TaXmXbNOzt63Vyk5UIQW5Psr1801VEIFTTOI/Zi1eXKjDOTuPK6
         9m1IiMhx6KqBpPyXEPQkEFgzUEmhZNsKLzfbZJ1eGk2vkqjTgkT5lj1qkdNZv8koJ4g1
         qJlfRzdgyUzMLV/kzSnuTsExsEljO0Sg+p0R9hvf8iMrlzxq6id8z3DUDbG32dxZ9Dps
         56BQ==
X-Gm-Message-State: APjAAAVK7mRuKeu1uifDv+ufd/3AYWA9e6PoiHwz5UKqo4DJl2aaokfx
	CNokAwDmOUclQhvnptrgE48UkyAowxHNKHOuKsCooMYkFM1kdSuf22vpXQOx+BgOIw/1M393DF+
	WAJncHIsh+jq4Zw6CH9CtpGH1H91oMsKFfb6EsPa0ajVwx35V48zDaS/pG6nxxRsOBw==
X-Received: by 2002:a50:86cf:: with SMTP id 15mr7995798edu.239.1551531409120;
        Sat, 02 Mar 2019 04:56:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqwrWEsMgVOb9rHrHhHNWdyg3zIegnN992AnXAuwIiwuKB3H959AMWpmr3mbOC7HMW1yXAwb
X-Received: by 2002:a50:86cf:: with SMTP id 15mr7995750edu.239.1551531408125;
        Sat, 02 Mar 2019 04:56:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551531408; cv=none;
        d=google.com; s=arc-20160816;
        b=R48sLqMDhrc+m6bNKGUxE/1u0rYP6ikW2KTL1koRA172iZhj/R5kAnVfxxm6rbCviP
         MaYdgqJUTu+vb6wDkhC1VKbn5G5qjYFzTccAX8eWFT9Z9lJxQkiyg759vVucvyltlkKJ
         SDGKWsEuRREGZrIbbzUKIDdp//y/HqBAiZ734LaQ5cLKOn9avr+g4ApWYllu1P+V06GH
         mmQ62LZiyPnzVggbNJQBnp3r9hExZVjaKoFgBiGZidhr6aUN8LoOmpndN3JvmV1rTrbh
         t89zmbXvbGgbSi2gfrU1qwk9M0Bmzlf/8FBvuoynJwFvlAg9LkIQ5wPD+pzW9sZXC8OL
         15bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=xKkrdgy4sxDG+g4+6p6ybVWcmJjsSEcbrNBjKqfqtmQ=;
        b=s1rNgh2jGtQRyIUPTZtkER+dM5YLnKpcFvfqkhYjK3zC/BQsKfeflqUeMcbHNHwLGQ
         pFwSTIs7eMCNuhuAXp1pq198NRdgUJK3xdX++04VrHAW/iJM/jGmxcrDjKw7VsP7IBV9
         8PkR1VL5d1yS5DyAbhGs3h7JYxg+vkNPaXUP36r3dNdlZ0dop9d/qsGFyGh+jsQp3JOw
         rOju4LSAdOffnxp7fgPg3Ex+WZy0Ek9sGUeZBKZov3oa03S0/cRhBETtStLzL0ErJavN
         8v4m1wbLl2Tm21e2RlBC/FGhp1Iql3iuu8/4txQmg+6rFVx8lnmilnQXbUXh09ACPIsE
         64dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=DHF0wpi2;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.42 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140042.outbound.protection.outlook.com. [40.107.14.42])
        by mx.google.com with ESMTPS id z13si47581edx.149.2019.03.02.04.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 04:56:48 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.42 as permitted sender) client-ip=40.107.14.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=DHF0wpi2;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.42 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xKkrdgy4sxDG+g4+6p6ybVWcmJjsSEcbrNBjKqfqtmQ=;
 b=DHF0wpi2y6PD1mcrl15X5UPheWEB09RfxAw0g5Gh6aRHKtLs0Bm9cXOhvP/MfmpOyoYuTWmrPgKrbhfxB/7VzGpYxGjpTaD9WFM940ye4OfXAcwh8FZ/g+COFEG6NUoi1+FNtKKJ3p3b0ZGaXlf1wP9EvKdqu+i9ogv11saoBvI=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4386.eurprd04.prod.outlook.com (52.135.152.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.18; Sat, 2 Mar 2019 12:56:46 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 12:56:46 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 01/12] percpu: update free path with correct new free
 region
Thread-Topic: [PATCH 01/12] percpu: update free path with correct new free
 region
Thread-Index: AQHUzwvxqvudgH94gkaVeLURKBFXS6X4Tzjg
Date: Sat, 2 Mar 2019 12:56:46 +0000
Message-ID:
 <AM0PR04MB4481091BB9F6BF0481C7F13B88770@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-2-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-2-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 743b958b-ddde-4971-ca15-08d69f0e871c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4386;
x-ms-traffictypediagnostic: AM0PR04MB4386:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0Mzg2OzIzOkdRR1VNeUtncERFdnBIdFUzcFo1eXc5bVFD?=
 =?gb2312?B?VjJ1cUk0b0RiQmdhK0ZUNmZhZ29ua1lNbFk3dkgwL1pSc2VGMVVzUngwZ2pk?=
 =?gb2312?B?bjJ5eCtzSWhCVzNQdmk1SEY0ZlZaWVpyZXpXb09UVmU4ZWo1azk2aHNFQk9V?=
 =?gb2312?B?VUhjNzYyUFhCVUNoSzhWSVVvZklZZnMwMGN1TmJPUlNiYXNvZGZuWXBKVjRN?=
 =?gb2312?B?TWE0QnorbGg1b0ZITUM3dzM0ZWkwZXdZTFR6QWVkRmpyd2FQOHdCZ1NzZGZJ?=
 =?gb2312?B?VGMrM20xNUo5bHR2eGg0YThHR1g2SnI3YW9NQWEvQ250YWFIU0t3MDNDUkVv?=
 =?gb2312?B?NnBnQTROS25MeGtjTWZBTTBxVG11Rmw5dlkwTnBvVjRiN2NWb0lIaU5qYkdR?=
 =?gb2312?B?YlhmVVEyV3pLM3RCVjFVWkVpMG1aaTRxcHhmNUJBUXI2QkQ1OTY1Umg1RzhV?=
 =?gb2312?B?TjhSUkYxOHhQUlo2alN3WEorQkRBWWtJVjJXdndmWDErYTZiV2VuRW1NRlJj?=
 =?gb2312?B?TFdPUm1CelRENnZZeHRRVm5HaXVZYVV6UFRzRGo3bGMzL0VjazU3NlZUMzNV?=
 =?gb2312?B?bDF6N0txU3YvbkkyVWdmWWtoRDhVY2ZyK3NwUE5VTnV4amNaRnEzZWF3c2Qz?=
 =?gb2312?B?bUJNU2pPNkRzMXpEV1NVRnE5TkxyMEtZeTYwUzQ4QnpUbjVjQ3lNSmFWbllE?=
 =?gb2312?B?WE1XckllM0xHQThnNGpnbmZySTVpNHNaRWtMZ0hNSHBQY0pUYm1XNFBJRFBr?=
 =?gb2312?B?Z25DZUZobitqVWIxR01Tang0ZnJEaXBuOFlBSmNIV214bmVmQ2twaWJId0Zp?=
 =?gb2312?B?YmVNcm0rMUJTVXlWeGp6dFZIM2pxWVRxZWQ1TGZOZERwZmt0Y3F5cW5EcGtW?=
 =?gb2312?B?dngveGxUdDYwTHlPQUU4R25mY0FOYmxqZEMzclAwbEROZHRuQmltbnVaaERX?=
 =?gb2312?B?SDdqV2JjV3ZxdzBLZlk1NU9jSjJwTHN4b3hFY2owTXNyaW5yODY4YWc1TkpC?=
 =?gb2312?B?M2xNVE5QTTNkbWNqTkxGcHVwOFh5TGZCY3dkSHVkMWxPWldkWnJwb2tDRWFN?=
 =?gb2312?B?cDlNRjNYSGF2MWdmckwzbEJyOFdOc25KUU1UVHF5bmlBaGdDS2NCVzNUSWZ5?=
 =?gb2312?B?YlRLTXRzbTd2aGtIdFlqRzFpZnpCcXB2QTZBdzZROC9oZzNFWmJVa1JaWWxN?=
 =?gb2312?B?ck5XaGpSQlpQY2NJMUx2UzQzRnZMbm5UWjVxSFJyOER0OHAwQXI4MFg3cWZq?=
 =?gb2312?B?NGcxa29MSit3azNPRjZ2WDJIYlZOZjhZRWlIc0pseXQ1bGRtaXYzS1BPY1o3?=
 =?gb2312?B?QjNlaGFaOHRCM1d1US9YOG0veWM3NXQ3eFYxK2thbXcrdVgwR3dNOXFieGgz?=
 =?gb2312?B?N1hoeHgxcmZ3M3VaQ25YcWs2QzhERTZkR0o3dzJNRVkzT3NFbHFsYi9yejdX?=
 =?gb2312?B?ZVJMNUhpc2RVQkpkU2x5djIrSDA4TUR5ZDBRY2c0S1E5YnFnbU9ZUzBGL3VW?=
 =?gb2312?B?Q2Q2OGNCRmh5eENid3pMNDFJNlZRd0c2SG4zYkpraXJrTGpydjhaRE9xMzQv?=
 =?gb2312?B?RW9obEZLcWEzcDg0ZnJvdnJ3Tm1takp2a0ZiNEdPNWhoSi9SRUYwdUkxZ3U5?=
 =?gb2312?B?SkxRSUtRR0NaUzJyeWI4SDNmcHozWGRocXZqOWh6N3NKV0R4M09KaDY0ejJt?=
 =?gb2312?B?TU1iVVJTUDVscEV4TmJhQ2hqUzhMUFpQVHQ2UnhBenJORlhGSmtMWTl5VzU3?=
 =?gb2312?B?enFtR3pFVEZISDFPRlg5YW9uVjlLdUcxbWxDR0prTm1xR0hFMlYvMHNJSXpI?=
 =?gb2312?Q?m5SpC56gLvqAW?=
x-microsoft-antispam-prvs:
 <AM0PR04MB438639AFFBC1DC1D3FAA9EDF88770@AM0PR04MB4386.eurprd04.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(376002)(366004)(346002)(136003)(189003)(13464003)(199004)(15650500001)(229853002)(446003)(4326008)(99286004)(7696005)(6436002)(6116002)(11346002)(476003)(14454004)(44832011)(76176011)(53936002)(25786009)(106356001)(33656002)(5660300002)(71200400001)(53546011)(6506007)(71190400001)(3846002)(105586002)(102836004)(26005)(186003)(6246003)(52536013)(97736004)(7736002)(305945005)(81166006)(8676002)(81156014)(256004)(14444005)(66066001)(86362001)(2906002)(74316002)(55016002)(68736007)(110136005)(9686003)(486006)(8936002)(478600001)(54906003)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4386;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 iQH7gOaHje6Pr1mf5qQLAqWtQKr3kbIUxiC+YPtqJ+zPQ6JQ4+8PcZ87+CTgahyrvCG3vpD5fNAs7Jwz6mz3T2YmtssvOY5MFVuWZLGV3tgRKn10QorKUsdcl+rZ255Kwv3SCjwsl/Vq/ykT/jnj3fYXQxu/0vvXc7CQr4kqo7czDt4CMnBYPdYR6SRHwEdLYwXZ8WHq8kvZWW4G0Jd8Kdo+JlE+exkGvvhbjkyblFEIr0bGipLADXlHOBO6LhP1HoSW112n25AAD2rasTuALfxTz/ymsG5SU416EANwV2bYI8s2/Pkyp/24tTzNauBhw2HnnIIYFkuhaE4ENcZbA7NmaZW/Gmfoj17oa5VnAXsaS4rWLrsjWq6RCJzfKWofVpq43Ph/95deXdOQbo7UDIBxE8ud7X3Q3BoKdGTsOG0=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 743b958b-ddde-4971-ca15-08d69f0e871c
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 12:56:46.3072
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4386
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogb3duZXItbGludXgtbW1A
a3ZhY2sub3JnIFttYWlsdG86b3duZXItbGludXgtbW1Aa3ZhY2sub3JnXSBPbg0KPiBCZWhhbGYg
T2YgRGVubmlzIFpob3UNCj4gU2VudDogMjAxOcTqMtTCMjjI1SAxMDoxOA0KPiBUbzogRGVubmlz
IFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPjsgVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPjsgQ2hy
aXN0b3BoDQo+IExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gQ2M6IFZsYWQgQnVzbG92IDx2bGFk
YnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiBsaW51eC1tbUBrdmFjay5v
cmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BBVENIIDAxLzEy
XSBwZXJjcHU6IHVwZGF0ZSBmcmVlIHBhdGggd2l0aCBjb3JyZWN0IG5ldyBmcmVlIHJlZ2lvbg0K
PiANCj4gV2hlbiB1cGRhdGluZyB0aGUgY2h1bmsncyBjb250aWdfaGludCBvbiB0aGUgZnJlZSBw
YXRoIG9mIGEgaGludCB0aGF0IGRvZXMgbm90DQo+IHRvdWNoIHRoZSBwYWdlIGJvdW5kYXJpZXMs
IGl0IHdhcyBpbmNvcnJlY3RseSB1c2luZyB0aGUgc3RhcnRpbmcgb2Zmc2V0IG9mIHRoZQ0KPiBm
cmVlIHJlZ2lvbiBhbmQgdGhlIGJsb2NrJ3MgY29udGlnX2hpbnQuIFRoaXMgY291bGQgbGVhZCB0
byBpbmNvcnJlY3QNCj4gYXNzdW1wdGlvbnMgYWJvdXQgZml0IGdpdmVuIGEgc2l6ZSBhbmQgYmV0
dGVyIGFsaWdubWVudCBvZiB0aGUgc3RhcnQuIEZpeCB0aGlzIGJ5DQo+IHVzaW5nIChlbmQgLSBz
dGFydCkgYXMgdGhpcyBpcyBvbmx5IGNhbGxlZCB3aGVuIHVwZGF0aW5nIGEgaGludCB3aXRoaW4g
YSBibG9jay4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVs
Lm9yZz4NCj4gLS0tDQo+ICBtbS9wZXJjcHUuYyB8IDIgKy0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAx
IGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL21tL3BlcmNw
dS5jIGIvbW0vcGVyY3B1LmMNCj4gaW5kZXggZGI4NjI4MmZkMDI0Li41M2JkNzlhNjE3YjEgMTAw
NjQ0DQo+IC0tLSBhL21tL3BlcmNwdS5jDQo+ICsrKyBiL21tL3BlcmNwdS5jDQo+IEBAIC04NzEs
NyArODcxLDcgQEAgc3RhdGljIHZvaWQgcGNwdV9ibG9ja191cGRhdGVfaGludF9mcmVlKHN0cnVj
dA0KPiBwY3B1X2NodW5rICpjaHVuaywgaW50IGJpdF9vZmYsDQo+ICAJCXBjcHVfY2h1bmtfcmVm
cmVzaF9oaW50KGNodW5rKTsNCj4gIAllbHNlDQo+ICAJCXBjcHVfY2h1bmtfdXBkYXRlKGNodW5r
LCBwY3B1X2Jsb2NrX29mZl90b19vZmYoc19pbmRleCwgc3RhcnQpLA0KPiAtCQkJCSAgc19ibG9j
ay0+Y29udGlnX2hpbnQpOw0KPiArCQkJCSAgZW5kIC0gc3RhcnQpOw0KPiAgfQ0KDQpSZXZpZXdl
ZC1ieTogUGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQoNCj4gDQo+ICAvKioNCj4gLS0NCj4g
Mi4xNy4xDQoNCg==

