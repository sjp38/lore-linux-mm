Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E684AC43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8261C20863
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:49:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="n/RzXhC9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8261C20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1477A8E000D; Sun,  3 Mar 2019 03:49:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F8078E0001; Sun,  3 Mar 2019 03:49:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED8188E000D; Sun,  3 Mar 2019 03:49:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5988E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 03:49:56 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id o6so1781113wrm.2
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 00:49:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=jPcLV9NLgrzCiWp0i0iEbDiz5liD/uRm6SkFsxaUQXk=;
        b=p2yrYBrUcMr6hbM6PTdH1afSiQh3AE+e+TjnDSZvi5HNnAeO4vERK5sTtTk0DoGOWM
         eCinXZcQc5kxrcGub0+eNerqdozRSzjbogfT2NqvaYMpyxkttaFIQLfiXhyd1RRFtkX4
         fm8uB/f0aSg6rEzUe9KfKFF2jRptg6feh6f1JRqRA/HMdjjozM2IHk1AHXkzD1fS0rct
         BGmn9zoLVgXE2j92O8lZ/aiaDtv1I60/Cx9hFNz2KudcNM9ya2hitmooO9AGdWcX3a65
         6vNhRbntM1diav4aCQ7H2+5k+3zZ1WMpShoQtDwBhrxkNY+upgBcHsGBIpdjXk44J/T/
         34iw==
X-Gm-Message-State: AHQUAuZ3Wfv4XfzRpCMPgDwaXewTLLK6s4MwGkIpa8jIXVI0ybhYvBlm
	O+AapQfbogbkrIqmQyhPPm44llamZGK3C4zMFUDch5bUo+LY/Q7ZKcDVdorfRzkOXF5ksbx8oGK
	SQjZmmoiXV/tTCUOgrDs9otA0C//nhD+R5UicIzH337HhhJ5++yb7ic5hl6/HUa7Dvw==
X-Received: by 2002:a1c:1d15:: with SMTP id d21mr7401173wmd.132.1551602995987;
        Sun, 03 Mar 2019 00:49:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqyduQOoV65tultuC2FE/2hhD625qlHJfr4w/Hk6wQpLXfv/qtMuVZxCIzEBrEvd9gyKuyiI
X-Received: by 2002:a1c:1d15:: with SMTP id d21mr7401143wmd.132.1551602994957;
        Sun, 03 Mar 2019 00:49:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551602994; cv=none;
        d=google.com; s=arc-20160816;
        b=UTftvdWKjiOwFCOnplRtEt30i4nlhyWbtNi0LtLRvKT6btnYSAB92fEQLdsbqV46w4
         vm5Aqo4lz4Ra1Me1XHwXGVU4I0IXonc3AtCegRXgilG1vci4NdYvHWgIa8ZHSq53Goxs
         W44qyvyHNJ+sbO0lVq4zWJHcTFRSpygPxk7KfT+klNniZ+zteUmtzsErRnO9HMWdQNtl
         4ICTnd9PZ6kr7+qi1uYcZe0BVVvV7FYLDH/vP+Wvt8Da/kNaVYINwEYzVqnbtOqINo5B
         g5deP9GvOgpz+MBcrLdiUSQO4HFpoacJoS5lRx+cJ7QJIINbigoeGkFgSxHpYo3DXw9k
         tFSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jPcLV9NLgrzCiWp0i0iEbDiz5liD/uRm6SkFsxaUQXk=;
        b=XgNTukltEcJ6zQ2zCQJhYTbEzwBby+1K/y/xnANfJB+lx72KcHvV2u+3I87ErFy9Sj
         5nU/Y67MKtfmWmwLvXEM6uLR6XHDMya2hUOm2Zw0BlOaQM4JUZplEbIDPpAKX4Nl5/IZ
         +JE7uVU6IKfK3WXlJ//PwLgn/we6TSiNgnbFp/DZ4tvGt8+pB0m0c5Py82JqAbM/+1KV
         U4yn+AIQUS7dukGOLhW4aaxlf7ZrSx2ebxP2OPjpLbkeiap8hNonD5Lbu4oeENG1JpwN
         6MgA3cOzxC8Ku6Jb+p7Q6KLi0pxpLkfSzH2Q/fVBrTCmIxC/M7cX6JfRaIU25WL/9ktJ
         2ajA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b="n/RzXhC9";
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.46 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30046.outbound.protection.outlook.com. [40.107.3.46])
        by mx.google.com with ESMTPS id n187si1746201wma.38.2019.03.03.00.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 00:49:54 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.46 as permitted sender) client-ip=40.107.3.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b="n/RzXhC9";
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.3.46 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jPcLV9NLgrzCiWp0i0iEbDiz5liD/uRm6SkFsxaUQXk=;
 b=n/RzXhC9/YOd6/w6PPOgH2TYKDOscJ6SqOGs1cQ0eva4TlNKUg6P6Ka+yr5E3eMNRgpgmtRWSn1Evf40mkqFAmU2blHG1F9Q2K1sxFF/hFHgjad9giM7LCXr/4/kcw1PU/4OsvuCFLxI+ODRSlO4WCVU/SZC+meZY3DQNM9OmGQ=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5411.eurprd04.prod.outlook.com (20.178.114.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.18; Sun, 3 Mar 2019 08:49:53 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sun, 3 Mar 2019
 08:49:53 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: Christopher Lameter <cl@linux.com>, "tj@kernel.org" <tj@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [PATCH 1/2] percpu: km: remove SMP check
Thread-Topic: [PATCH 1/2] percpu: km: remove SMP check
Thread-Index:
 AQHUzELEXhV7UVWfi0W/HwwXYpeEX6XwoM8AgAGTPACAAB3fgIABS/yAgABAIoCABcUR0A==
Date: Sun, 3 Mar 2019 08:49:52 +0000
Message-ID:
 <AM0PR04MB448110C252CBE33FBB50D40788700@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
 <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
 <20190226170339.GB47262@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB44814B3BA09388DFF3681E1388740@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190227164125.GA2379@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190227164125.GA2379@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 75e614a6-c0d4-4a77-94aa-08d69fb53419
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5411;
x-ms-traffictypediagnostic: AM0PR04MB5411:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtBTTBQUjA0TUI1NDExOzIzOklBZ0pYWk4xaEFxT0lqMHBhcDZvV053OThP?=
 =?utf-8?B?R0tXQlRoYnArS3h1MHZWQ2x1YnFrR29NMVVrTFN2TlhWNUJxVlhhVGxRdnFT?=
 =?utf-8?B?ZUcxR1hwam5NM2IwVGQwOWxuenJmSjh5eVFKNzRQSDcxYUxoM2hHcGNTRFRz?=
 =?utf-8?B?U00xblkyVWUxWnUrZHlVMDFuaWtPUWxBclltZitTQjMwSFZ2WDlpYlQrTVlq?=
 =?utf-8?B?c3gwOXp2RVJNQksraFMzRTVDMU1yUFpMQ3ZieVVNdUdMVy9LTkJJWnFGL2xr?=
 =?utf-8?B?UWVzV050bnBKNE9kUjcvbUtrbUdXTkxJWlNuY3Vwd3ZlNW9QcXJpSUd4aDJU?=
 =?utf-8?B?K2VQSnFiNmdvVFp4R1dTeTB3TU5SL3VZVEtDMFVTdTBPZEp2UytGdE9LNVNY?=
 =?utf-8?B?UVAvV1lWSDNoQ25DanZlZ0s1Z1dPUS9ZeFZuMEtFWG1XNGZiVzNlMU4zU0or?=
 =?utf-8?B?cm5rZUxsM0pOYVlUU0dNVDdmcEV0UnNJQUtMVDhJbm4ydTJoMndFMUtvWGVx?=
 =?utf-8?B?bTg3aWRHNk53QllSbmVISHdtajBUUXUra28xbFZaNmNnYStPamZhbEtQRjN5?=
 =?utf-8?B?RS8wM2wyN1phYjJQVVNtcmRNa3FMVGdrZGcvSHVCdGU3eXhqUjI0YXdLRDA4?=
 =?utf-8?B?VWE3bG9vOTk0YzRjcnJ1N1RzTHNxd0VtMVJESzlDSEhvZ214dVVpL3JMU04x?=
 =?utf-8?B?d216c2dZRFFseG41aHFWNi9pazA5d1diSjU0c2xURU5aSEhRSU44RXczMmhW?=
 =?utf-8?B?TGMzOEhLbVlUNkNYSS90dkZqWHhTNjRvY1ZScVd5SlF2UTVGL2s4K3Fvelp2?=
 =?utf-8?B?Z3NId0hhSGdhMHVlQ3BVNUlWRTZOVkt5RFpZMjlqeE1lZ204YzZObmhuNUp4?=
 =?utf-8?B?VDZneUVBK3hWTDFXTW1neURsa2hzL1RGUUxDMjFBQXJlb2hJTEw4QkdKOXMy?=
 =?utf-8?B?Y2NZcWpSUlpvUzJVeEZnVmVpWkhVWTBxelFXZjhWQk90WHZlU3ZoNDFVNTdt?=
 =?utf-8?B?bFpseG53L1YwbjJqQWZzaUg0Ri9TQ0ptM0QrSHA3UEM3WkRxVWdiVjNqUkty?=
 =?utf-8?B?Q2RGeFRPQ3phNEpDRGpvRWJLKzFzdVdqUHdOME16Um40SmUwNnpkSHhWTEVC?=
 =?utf-8?B?Ky9FTlhtMVg3dEpYSmdCK2NORVJqTlBPVVFoclFQaVN0Q0ErOFg5QjBVWGhx?=
 =?utf-8?B?a1pFbUdJd1ZGeWlyNlllOFlhZ0NBakQrVTFuN1YvOTZUV1M1aWMvUU9PSnRt?=
 =?utf-8?B?QWtJL25Ody92bUQyR05SR21GMlUrZjBQRHJsQ2U1MGZGeCtvdm9CUElaZW5P?=
 =?utf-8?B?c3p6Z2JjdC9KQ0hOOFp5bTdQZ1U3R1FnV2tMUHRGTXJIWWJVUXpmSjlpeVk2?=
 =?utf-8?B?eGh2Z1JqVlNTMVpWSnBwNFRxd1pLcjRHMHRpeWh3elB2dWpLRHV4cEp3NXh2?=
 =?utf-8?B?VnFzcWllRDNQdWxtTkVSOVhyNGNhYkI1d0d1QU9GV3RWRWZ4MzdUUjVWNkhU?=
 =?utf-8?B?YkhIdHZOSU1GQ3BRbmkvY0RaVmwwUndmR1M0QW9mQ0Yva2VwU3ZZVm9QaU1q?=
 =?utf-8?B?Qms0UUdFeGdJc2R4Zy9PUEFwUm1XMThtWk9QYlF5NFpCd05ML05IakNJRjF2?=
 =?utf-8?B?QjRUZTZMcHdPNDBXcVhqRGlWd0ZnMFcxakY0UlR3WC9QLzJ6ZUIzR3VtdDFX?=
 =?utf-8?B?WjJFekR6WGFiYW1HdWkxa21lMjNMaVV5TmNYNkxXMEpMZ3p5S1YwVjIwdWVG?=
 =?utf-8?Q?V7pnbunbzNpyMXP374TIyMlESQlB+OzRsY1wE=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB5411E6262854D2500577C4A888700@AM0PR04MB5411.eurprd04.prod.outlook.com>
x-forefront-prvs: 096507C068
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(376002)(39860400002)(366004)(396003)(136003)(189003)(199004)(13464003)(44832011)(14454004)(53546011)(6506007)(97736004)(105586002)(26005)(4326008)(102836004)(478600001)(5660300002)(6246003)(476003)(486006)(76176011)(446003)(7696005)(106356001)(52536013)(6916009)(256004)(14444005)(66066001)(305945005)(7736002)(33656002)(25786009)(11346002)(74316002)(93886005)(2906002)(229853002)(8936002)(86362001)(81156014)(6116002)(54906003)(316002)(3846002)(53936002)(68736007)(81166006)(6436002)(186003)(71190400001)(55016002)(99286004)(71200400001)(9686003)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5411;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Yd4HoOYpwLuMxN5H4d1Q80LR3XcJD2sLdWH6XO83D2cMgb60Pm0+1cXx/ODtFC1wbK+wvrlJTeN9GVwHt/dSzI7TknaTQN7W3oPeSI72xvwpcGv6O4vYDmO1jW6fIeeh/8FCxse2aAUhF+QI86Kwo47HYKKpSe9qCLaay85pkcsZ4LwwW8Hwb1rFln+LEctiZq7X/PhrDWI6oPwKnKNTWFkwq94Yu5C1gHBFTmrhRddgzQ4bfRFFtOKsCXjmkr9XPr8DaciVHr9mqrn+5TbAYwFzOoWn9FtD4zi9jevdjCmkFmTUGEMl1yFPIdFwU913XqDDk6SgqwSXO6lAqOO71QJWAAlWFEDlUszz3btFoKE+OvMWv4SQmznzUgSCeIhoSVCTaODrIYp6+ps5F3pbUNr6q8jWcVVgVM/P6toy/6w=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 75e614a6-c0d4-4a77-94aa-08d69fb53419
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Mar 2019 08:49:53.0501
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5411
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGVubmlzIFpob3UgW21h
aWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOeW5tDLmnIgyOOaXpSAwOjQxDQo+
IFRvOiBQZW5nIEZhbiA8cGVuZy5mYW5AbnhwLmNvbT4NCj4gQ2M6IERlbm5pcyBaaG91IDxkZW5u
aXNAa2VybmVsLm9yZz47IENocmlzdG9waGVyIExhbWV0ZXIgPGNsQGxpbnV4LmNvbT47DQo+IHRq
QGtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVs
Lm9yZzsNCj4gdmFuLmZyZWVuaXhAZ21haWwuY29tDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8y
XSBwZXJjcHU6IGttOiByZW1vdmUgU01QIGNoZWNrDQo+IA0KPiBPbiBXZWQsIEZlYiAyNywgMjAx
OSBhdCAwMTowMjoxNlBNICswMDAwLCBQZW5nIEZhbiB3cm90ZToNCj4gPiBIaSBEZW5uaXMNCj4g
Pg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gPiA+IEZyb206IERlbm5pcyBa
aG91IFttYWlsdG86ZGVubmlzQGtlcm5lbC5vcmddDQo+ID4gPiBTZW50OiAyMDE55bm0MuaciDI3
5pelIDE6MDQNCj4gPiA+IFRvOiBDaHJpc3RvcGhlciBMYW1ldGVyIDxjbEBsaW51eC5jb20+DQo+
ID4gPiBDYzogUGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+OyB0akBrZXJuZWwub3JnOyBsaW51
eC1tbUBrdmFjay5vcmc7DQo+ID4gPiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyB2YW4u
ZnJlZW5peEBnbWFpbC5jb20NCj4gPiA+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMS8yXSBwZXJjcHU6
IGttOiByZW1vdmUgU01QIGNoZWNrDQo+ID4gPg0KPiA+ID4gT24gVHVlLCBGZWIgMjYsIDIwMTkg
YXQgMDM6MTY6NDRQTSArMDAwMCwgQ2hyaXN0b3BoZXIgTGFtZXRlciB3cm90ZToNCj4gPiA+ID4g
T24gTW9uLCAyNSBGZWIgMjAxOSwgRGVubmlzIFpob3Ugd3JvdGU6DQo+ID4gPiA+DQo+ID4gPiA+
ID4gPiBAQCAtMjcsNyArMjcsNyBAQA0KPiA+ID4gPiA+ID4gICAqICAgY2h1bmsgc2l6ZSBpcyBu
b3QgYWxpZ25lZC4gIHBlcmNwdS1rbSBjb2RlIHdpbGwgd2hpbmUgYWJvdXQNCj4gaXQuDQo+ID4g
PiA+ID4gPiAgICovDQo+ID4gPiA+ID4gPg0KPiA+ID4gPiA+ID4gLSNpZiBkZWZpbmVkKENPTkZJ
R19TTVApICYmDQo+ID4gPiA+ID4gPiBkZWZpbmVkKENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9G
SVJTVF9DSFVOSykNCj4gPiA+ID4gPiA+ICsjaWYgZGVmaW5lZChDT05GSUdfTkVFRF9QRVJfQ1BV
X1BBR0VfRklSU1RfQ0hVTkspDQo+ID4gPiA+ID4gPiAgI2Vycm9yICJjb250aWd1b3VzIHBlcmNw
dSBhbGxvY2F0aW9uIGlzIGluY29tcGF0aWJsZSB3aXRoDQo+ID4gPiA+ID4gPiBwYWdlZCBmaXJz
dA0KPiA+ID4gY2h1bmsiDQo+ID4gPiA+ID4gPiAgI2VuZGlmDQo+ID4gPiA+ID4gPg0KPiA+ID4g
PiA+ID4gLS0NCj4gPiA+ID4gPiA+IDIuMTYuNA0KPiA+ID4gPiA+ID4NCj4gPiA+ID4gPg0KPiA+
ID4gPiA+IEhpLA0KPiA+ID4gPiA+DQo+ID4gPiA+ID4gSSB0aGluayBrZWVwaW5nIENPTkZJR19T
TVAgbWFrZXMgdGhpcyBlYXNpZXIgdG8gcmVtZW1iZXINCj4gPiA+ID4gPiBkZXBlbmRlbmNpZXMg
cmF0aGVyIHRoYW4gaGF2aW5nIHRvIGRpZyBpbnRvIHRoZSBjb25maWcuIFNvIHRoaXMNCj4gPiA+
ID4gPiBpcyBhIE5BQ0sNCj4gPiA+IGZyb20gbWUuDQo+ID4gPiA+DQo+ID4gPiA+IEJ1dCBpdCBz
aW1wbGlmaWVzIHRoZSBjb2RlIGFuZCBtYWtlcyBpdCBlYXNpZXIgdG8gcmVhZC4NCj4gPiA+ID4N
Cj4gPiA+ID4NCj4gPiA+DQo+ID4gPiBJIHRoaW5rIHRoZSBjaGVjayBpc24ndCBxdWl0ZSByaWdo
dCBhZnRlciBsb29raW5nIGF0IGl0IGEgbGl0dGxlIGxvbmdlci4NCj4gPiA+IExvb2tpbmcgYXQg
eDg2LCBJIGJlbGlldmUgeW91IGNhbiBjb21waWxlIGl0IHdpdGggIVNNUCBhbmQNCj4gPiA+IENP
TkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSyB3aWxsIHN0aWxsIGJlIHNldC4gVGhp
cw0KPiBzaG91bGQNCj4gPiA+IHN0aWxsIHdvcmsgYmVjYXVzZSB4ODYgaGFzIGFuIE1NVS4NCj4g
Pg0KPiA+IFlvdSBhcmUgcmlnaHQsIHg4NiBjb3VsZCBib290cyB1cCB3aXRoDQo+IE5FRURfUEVS
X0NQVV9QQUdFX0ZJUlNUX0NIVU5LDQo+ID4gPXkgYW5kIFNNUD1uLiBUZXN0ZWQgd2l0aCBxZW11
LCBpbmZvIGFzIGJlbG93Og0KPiA+DQo+ID4gLyAjIHpjYXQgL3Byb2MvY29uZmlnLmd6IHwgZ3Jl
cCBORUVEX1BFUl9DUFVfS00NCj4gPiBDT05GSUdfTkVFRF9QRVJfQ1BVX0tNPXkgLyAjIHpjYXQg
L3Byb2MvY29uZmlnLmd6IHwgZ3JlcCBTTVANCj4gPiBDT05GSUdfQlJPS0VOX09OX1NNUD15ICMg
Q09ORklHX1NNUCBpcyBub3Qgc2V0DQo+ID4gQ09ORklHX0dFTkVSSUNfU01QX0lETEVfVEhSRUFE
PXkgLyAjIHpjYXQgL3Byb2MvY29uZmlnLmd6IHwgZ3JlcA0KPiA+IE5FRURfUEVSX0NQVV9QQUdF
X0ZJUlNUX0NIVU5LDQo+IENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSz15DQo+
ID4gLyAjIGNhdCAvcHJvYy9jcHVpbmZvDQo+ID4gcHJvY2Vzc29yICAgICAgIDogMA0KPiA+IHZl
bmRvcl9pZCAgICAgICA6IEF1dGhlbnRpY0FNRA0KPiA+IGNwdSBmYW1pbHkgICAgICA6IDYNCj4g
PiBtb2RlbCAgICAgICAgICAgOiA2DQo+ID4gbW9kZWwgbmFtZSAgICAgIDogUUVNVSBWaXJ0dWFs
IENQVSB2ZXJzaW9uIDIuNSsNCj4gPiBzdGVwcGluZyAgICAgICAgOiAzDQo+ID4gY3B1IE1IeiAg
ICAgICAgIDogMzE5Mi42MTMNCj4gPiBjYWNoZSBzaXplICAgICAgOiA1MTIgS0INCj4gPiBmcHUg
ICAgICAgICAgICAgOiB5ZXMNCj4gPiBmcHVfZXhjZXB0aW9uICAgOiB5ZXMNCj4gPiBjcHVpZCBs
ZXZlbCAgICAgOiAxMw0KPiA+IHdwICAgICAgICAgICAgICA6IHllcw0KPiA+IGZsYWdzICAgICAg
ICAgICA6IGZwdSBkZSBwc2UgdHNjIG1zciBwYWUgbWNlIGN4OCBhcGljIHNlcCBtdHJyIHBnZSBt
Y2ENCj4gY21vdiBwYXQgcHNlMzYgY2xmbHVzaCBtbXggZnhzciBzc2Ugc3NlMiBzeXNjYWxsIG54
IGxtIG5vcGwgY3B1aWQgcG5pIGN4MTYNCj4gaHlwZXJ2aXNvciBsYWhmX2xtIHN2bSAzZG5vd3By
ZWZldGwNCj4gPiBidWdzICAgICAgICAgICAgOiBmeHNhdmVfbGVhayBzeXNyZXRfc3NfYXR0cnMg
c3BlY3RyZV92MSBzcGVjdHJlX3YyDQo+IHNwZWNfc3RvcmVfYnlwYXNzDQo+ID4gYm9nb21pcHMg
ICAgICAgIDogNjM4NS4yMg0KPiA+IFRMQiBzaXplICAgICAgICA6IDEwMjQgNEsgcGFnZXMNCj4g
PiBjbGZsdXNoIHNpemUgICAgOiA2NA0KPiA+IGNhY2hlX2FsaWdubWVudCA6IDY0DQo+ID4gYWRk
cmVzcyBzaXplcyAgIDogNDIgYml0cyBwaHlzaWNhbCwgNDggYml0cyB2aXJ0dWFsDQo+ID4gcG93
ZXIgbWFuYWdlbWVudDoNCj4gPg0KPiA+DQo+ID4gQnV0IGZyb20gdGhlIGNvbW1lbnRzIGluIHRo
aXMgZmlsZToNCj4gPiAiDQo+ID4gKiAtIENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9D
SFVOSyBtdXN0IG5vdCBiZSBkZWZpbmVkLg0KPiBJdCdzDQo+ID4gICogICBub3QgY29tcGF0aWJs
ZSB3aXRoIFBFUl9DUFVfS00uICBFTUJFRF9GSVJTVF9DSFVOSyBzaG91bGQNCj4gd29yaw0KPiA+
ICAqICAgZmluZS4NCj4gPiAiDQo+ID4NCj4gPiBJIGRpZCBub3QgcmVhZCBpbnRvIGRldGFpbHMg
d2h5IGl0IGlzIG5vdCBhbGxvd2VkLCBidXQgeDg2IGNvdWxkIHN0aWxsDQo+ID4gd29yayB3aXRo
IEtNIGFuZCBORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSy4NCj4gPg0KPiANCj4gVGhlIGZp
cnN0IGNodW5rIHJlcXVpcmVzIHNwZWNpYWwgaGFuZGxpbmcgb24gU01QIHRvIGJyaW5nIHRoZSBz
dGF0aWMgdmFyaWFibGVzDQo+IGludG8gdGhlIHBlcmNwdSBhZGRyZXNzIHNwYWNlLiBPbiBVUCwg
aWRlbnRpdHkgbWFwcGluZyBtYWtlcyBzdGF0aWMgdmFyaWFibGVzDQo+IGluZGlzdGluZ3Vpc2hh
YmxlIGJ5IGFsaWduaW5nIHRoZSBwZXJjcHUgYWRkcmVzcyBzcGFjZSBhbmQgdGhlIHZpcnR1YWwg
YWRyZXNzDQo+IHNwYWNlLiBUaGUgcGVyY3B1LWttIGFsbG9jYXRvciBhbGxvY2F0ZXMgZnVsbCBj
aHVua3MgYXQgYSB0aW1lIHRvIGRlYWwgd2l0aA0KPiBOT01NVSBhcmNocy4gU28gdGhlIGRpZmZl
cmVuY2UgaXMgaWYgdGhlIHZpcnR1YWwgYWRkcmVzcyBzcGFjZSBpcyB0aGUgc2FtZSBhcw0KPiB0
aGUgcGh5c2ljYWwuDQoNClRoYW5rcyBmb3IgY2xhcmlmaWNhdGlvbi4NCg0KPiANCj4gPiA+DQo+
ID4gPiBJIHRoaW5rIG1vcmUgY29ycmVjdGx5IGl0IHdvdWxkIGJlIHNvbWV0aGluZyBsaWtlIGJl
bG93LCBidXQgSSBkb24ndA0KPiA+ID4gaGF2ZSB0aGUgdGltZSB0byBmdWxseSB2ZXJpZnkgaXQg
cmlnaHQgbm93Lg0KPiA+ID4NCj4gPiA+IFRoYW5rcywNCj4gPiA+IERlbm5pcw0KPiA+ID4NCj4g
PiA+IC0tLQ0KPiA+ID4gZGlmZiAtLWdpdCBhL21tL3BlcmNwdS1rbS5jIGIvbW0vcGVyY3B1LWtt
LmMgaW5kZXgNCj4gPiA+IDBmNjQzZGMyZGM2NS4uNjljY2FkN2Q5ODA3IDEwMDY0NA0KPiA+ID4g
LS0tIGEvbW0vcGVyY3B1LWttLmMNCj4gPiA+ICsrKyBiL21tL3BlcmNwdS1rbS5jDQo+ID4gPiBA
QCAtMjcsNyArMjcsNyBAQA0KPiA+ID4gICAqICAgY2h1bmsgc2l6ZSBpcyBub3QgYWxpZ25lZC4g
IHBlcmNwdS1rbSBjb2RlIHdpbGwgd2hpbmUgYWJvdXQgaXQuDQo+ID4gPiAgICovDQo+ID4gPg0K
PiA+ID4gLSNpZiBkZWZpbmVkKENPTkZJR19TTVApICYmDQo+ID4gPiBkZWZpbmVkKENPTkZJR19O
RUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSykNCj4gPiA+ICsjaWYgIWRlZmluZWQoQ09ORklH
X01NVSkgJiYNCj4gPiA+ICtkZWZpbmVkKENPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9D
SFVOSykNCj4gPiA+ICAjZXJyb3IgImNvbnRpZ3VvdXMgcGVyY3B1IGFsbG9jYXRpb24gaXMgaW5j
b21wYXRpYmxlIHdpdGggcGFnZWQgZmlyc3QNCj4gY2h1bmsiDQo+ID4gPiAgI2VuZGlmDQo+ID4g
Pg0KPiA+DQo+ID4gQWNrZWQtYnk6IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiA+DQo+
ID4gVGhhbmtzLA0KPiA+IFBlbmcNCj4gDQo+IFdoaWxlIHRoaXMgY2hhbmdlIG1heSBzZWVtIHJp
Z2h0IHRvIG1lLiBWZXJpZmljYXRpb24gd291bGQgYmUgdG8gZG91YmxlDQo+IGNoZWNrIG90aGVy
IGFyY2hpdGVjdHVyZXMgdG9vLiB4ODYganVzdCBoYXBwZW5lZCB0byBiZSBhIGNvdW50ZXIgZXhh
bXBsZSBJDQo+IGhhZCBpbiBtaW5kLiBVbmxlc3Mgc29tZW9uZSByZXBvcnRzIHRoaXMgYXMgYmVp
bmcgYW4gaXNzdWUgb3Igc29tZW9uZSB0YWtlcw0KPiB0aGUgdGltZSB0byB2YWxpZGF0ZSB0aGlz
IG1vcmUgdGhvcm91Z2hseSB0aGFuIG15IGN1cnNvcnkgbG9vay4NCj4gSSB0aGluayB0aGUgcmlz
ayBvZiB0aGlzIG91dHdlaWdocyB0aGUgYmVuZWZpdC4gVGhpcyBtYXkgYmUgc29tZXRoaW5nIEkg
Zml4IGluIHRoZQ0KPiBmdXR1cmUgd2hlbiBJIGhhdmUgbW9yZSB0aW1lLiBUaGlzIHdvdWxkIGFs
c28gaW52b2x2ZSBtYWtpbmcgc3VyZSB0aGUNCj4gY29tbWVudHMgYXJlIGNvbnNpc3RlbnQuDQoN
CkkgYW0gbm90IGFibGUgdG8gY2hlY2sgb3RoZXIgYXJjaGl0ZWN0dXJlcyBub3cuIFNvIGp1c3Qg
bGVhdmUgdGhlIGNvZGUgYXMgaXMuDQoNClRoYW5rcywNClBlbmcuDQoNCj4gDQo+IFRoYW5rcywN
Cj4gRGVubmlzDQo=

