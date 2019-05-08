Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0983BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:26:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2B28204EC
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:26:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="Mi3Xs1RZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2B28204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7C56B0007; Wed,  8 May 2019 09:26:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358936B0008; Wed,  8 May 2019 09:26:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 220646B000A; Wed,  8 May 2019 09:26:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECB6D6B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 09:26:37 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id k90so11029456otk.21
        for <linux-mm@kvack.org>; Wed, 08 May 2019 06:26:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=jRZOazIR7In+02p6vDsRizpcnxBWx1U//h0MEIEuZuc=;
        b=IVSHO+7QUYy7ch14+7zvyO0mB1G/6tCo7oq/rc0EfUyqcLW+ThR0sfyEzLswRH3Ydy
         phhYAjfDq6gonJcLqR/WFuy92oPVh2AQAI4BwVEsydAn4jaupd9xFrYo+Cz3P8clskcy
         66oQjDwX3TN2Y7kBR4x2JL0TA67u1GKhZyW8AJsYmTZe8tcWDqzxiDK/y/Y49RUzmevy
         +7c22nmEXrhWbw9tU+avw75tPBH5uNCt58vV1FFnsyCOnivHwMMLq+SoOedy90OQPb9E
         FBxSqyN4QZHNS0zZkaRTYCOi1A5sT5YHSDC/WT7bkgK1nF4xP0M6qZdQ9lEpW2VxJdaO
         afjg==
X-Gm-Message-State: APjAAAW4lbL9mYtZ4frd/U1MyZIRFGzvZo9iWyCYJ6Cm0GdlWvZlaw1X
	ECLlg/ZrclT2JDGuApiUYaQzkRggj5LYdjeciKXx3dOAlCajgJu4lAdz7vVPTWxOz+o/BoMQYKN
	R+T7cYfCrVsrAiRZYm+/tGc2q+DR2QJ6kw629C0ZypbTDfZh57HwrGCfHzMjc1lMChA==
X-Received: by 2002:aca:470e:: with SMTP id u14mr2218476oia.127.1557321997693;
        Wed, 08 May 2019 06:26:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFytSkVtJCCOVTi2MHehzy0xnDzsDQ1xWgEvW1e4hp4hB5O0R+xyEptvCpkt1VHxiY/b5d
X-Received: by 2002:aca:470e:: with SMTP id u14mr2218433oia.127.1557321996907;
        Wed, 08 May 2019 06:26:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557321996; cv=none;
        d=google.com; s=arc-20160816;
        b=YwAgJgRbgOkjciXuw9yFf9E5gSZzd2hY/9fl+rM+6FpePZ67WfgVpwE0D83fT2vENc
         U+MRVcW+BPxTslVA+cDi3qeKHvH2gyUI9JKLpDvlcVeM/eNuRJ9HZQQvD1RAuNBEheEL
         DMPxL/Vwl6EhBqeF53vFpR2fCEy3NwWqmfUXs+A8GnVWKTv8Pdd0dSKWzrzI+lFbfUDX
         HjWbJVu5OyW2WFlF+p1WlvV/jX1aldQCZEgpo9hmJaoBRxl7UuZtaiHN7tyb3SVFj5x9
         zu8fNFrRRgCCoxYq39aR6pf0d7pSflGhemjnGde0IPQNI16/ze5LCBJDst7pCsiTPn1x
         q/tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jRZOazIR7In+02p6vDsRizpcnxBWx1U//h0MEIEuZuc=;
        b=HTPt0Wom7xU8k7AaL+cxDjJCH0GZw0+HjmJLbK/YXI2R0kYLCL4jQKZ3lCipWnQlHd
         F46QBMJZp60164MtqKx5lM9oBvcVm6SiPgdux09hoDhH7SxtE+nrLLG+sU00njeT0C8m
         pfFR6Ez0ApiUnryUj9vPaWEn5b7KekRfLDvGCeqjlXmjAVZsD0lvheniWfYYwN0Qi9LW
         omZad89Qq61K6jVvRL6BoNrjwB0bqWEWCsRLw6J4GIn5ttPUJ5VfNY1eK4Jkje9RCsnQ
         4mWaBrUa8MfvynbST7POzMED2BNMABdnh75R41DaZwe7z6G/YeYG26t2i52Tv/+AjOTC
         Mutg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Mi3Xs1RZ;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.77 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800077.outbound.protection.outlook.com. [40.107.80.77])
        by mx.google.com with ESMTPS id a10si9765145otp.255.2019.05.08.06.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 06:26:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.77 as permitted sender) client-ip=40.107.80.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Mi3Xs1RZ;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.77 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jRZOazIR7In+02p6vDsRizpcnxBWx1U//h0MEIEuZuc=;
 b=Mi3Xs1RZR1Kk+9QXXdeLCo8LvH71RvweK88Lp8oOtgh22y7zUwWEHAVk/8NUHjE2KwzUQnuoX6z3YpP+BGC5DbMSAxk+Z+07rj9W/9VF7pgKWq8mzmZ/O53Qy+mJj7jhPTUQW7S5tpYn4NiZ/bCdRjZQhZSSjGo97Kg1QMa3Zxk=
Received: from DM6PR03CA0050.namprd03.prod.outlook.com (2603:10b6:5:100::27)
 by SN2PR03MB2270.namprd03.prod.outlook.com (2603:10b6:804:d::15) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.10; Wed, 8 May
 2019 13:26:33 +0000
Received: from CY1NAM02FT011.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::201) by DM6PR03CA0050.outlook.office365.com
 (2603:10b6:5:100::27) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 13:26:33 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 CY1NAM02FT011.mail.protection.outlook.com (10.152.75.156) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 13:26:31 +0000
Received: from NWD2HUBCAS9.ad.analog.com (nwd2hubcas9.ad.analog.com [10.64.69.109])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48DQUQM021820
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 06:26:30 -0700
Received: from NWD2MBX7.ad.analog.com ([fe80::190e:f9c1:9a22:9663]) by
 NWD2HUBCAS9.ad.analog.com ([fe80::44a2:871b:49ab:ea47%12]) with mapi id
 14.03.0415.000; Wed, 8 May 2019 09:26:29 -0400
From: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
To: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
CC: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org"
	<linux-omap@vger.kernel.org>, "linux-gpio@vger.kernel.org"
	<linux-gpio@vger.kernel.org>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "devel@driverdev.osuosl.org"
	<devel@driverdev.osuosl.org>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>, "linux-fbdev@vger.kernel.org"
	<linux-fbdev@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "alsa-devel@alsa-project.org"
	<alsa-devel@alsa-project.org>, "linux-rockchip@lists.infradead.org"
	<linux-rockchip@lists.infradead.org>, "linux-clk@vger.kernel.org"
	<linux-clk@vger.kernel.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-mtd@lists.infradead.org"
	<linux-mtd@lists.infradead.org>, "linux-tegra@vger.kernel.org"
	<linux-tegra@vger.kernel.org>
Subject: Re: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Thread-Topic: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Thread-Index: AQHVBZFjC5krcc3G0k+g00YBPwx6V6ZhaK0AgAAShYA=
Date: Wed, 8 May 2019 13:26:29 +0000
Message-ID: <2ec6812d6bf2f33860c7c816c641167a31eb2ed6.camel@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
	 <20190508112842.11654-11-alexandru.ardelean@analog.com>
	 <20190508122010.GC21059@kadam>
In-Reply-To: <20190508122010.GC21059@kadam>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.50.1.244]
x-adiroutedonprem: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <6166AD703C20264A8933E29F0D6472FA@analog.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(376002)(396003)(346002)(136003)(39860400002)(2980300002)(199004)(189003)(7696005)(76176011)(229853002)(356004)(70206006)(7416002)(7406005)(316002)(2486003)(23676004)(305945005)(7736002)(7636002)(47776003)(6246003)(4326008)(54906003)(2906002)(106002)(6116002)(3846002)(446003)(14444005)(36756003)(478600001)(186003)(102836004)(126002)(486006)(2616005)(476003)(2351001)(86362001)(2501003)(70586007)(118296001)(50466002)(336012)(8936002)(5660300002)(14454004)(5640700003)(6916009)(4744005)(436003)(426003)(26005)(246002)(11346002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:SN2PR03MB2270;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: cfdadccb-4d44-4864-c715-08d6d3b8c9c3
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328)(7193020);SRVR:SN2PR03MB2270;
X-MS-TrafficTypeDiagnostic: SN2PR03MB2270:
X-Microsoft-Antispam-PRVS:
	<SN2PR03MB22702FB510E95C53ECE1B38AF9320@SN2PR03MB2270.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:9508;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	fV1p6yRnB85jQZJN7eRbmOVfYHNwky9etvny6vTDXhePyeWXsqL1v2Aesb+Wk2QXqNCdHVI7JxPpMwTuJmBLaQ98M5NyNZ6XAm57uPOwak+8pn1MIc9yqsnCgia/XHmaLRDKnfXPVsH6Dygj8nYwt/0eV2mYNm9yTO8q0OeU2Og99154RYQ9n8VC3F0OaaBq7VRly+zYEpsK/KpXipHcs3BgmCCQ4nFSeqWpM/F2P+H7TCUsZxK/t9wXauan74KDJNvfmggirOduBXb04+FG6sVpxsKYTszlRJOKYk27ytxWmH843gqE47SClPstH2PhW66aSpufvNJ0pbqiMVZw6BPG0s0jouyFZkplH++TiX/GsSSRxs9pL+v1FgQVuD5jfwwE6cpi+GA0D9SnaPwM45pGQJSeNO4gm4s7r+wCjks=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 13:26:31.5064
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: cfdadccb-4d44-4864-c715-08d6d3b8c9c3
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN2PR03MB2270
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTA4IGF0IDE1OjIwICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiANCj4gDQo+IE9uIFdlZCwgTWF5IDA4LCAyMDE5IGF0IDAyOjI4OjM1UE0gKzAzMDAsIEFsZXhh
bmRydSBBcmRlbGVhbiB3cm90ZToNCj4gPiAtc3RhdGljIGNvbnN0IGNoYXIgKiBjb25zdCBwaHlf
dHlwZXNbXSA9IHsNCj4gPiAtICAgICAiZW1tYyA1LjAgcGh5IiwNCj4gPiAtICAgICAiZW1tYyA1
LjEgcGh5Ig0KPiA+IC19Ow0KPiA+IC0NCj4gPiAgZW51bSB4ZW5vbl9waHlfdHlwZV9lbnVtIHsN
Cj4gPiAgICAgICBFTU1DXzVfMF9QSFksDQo+ID4gICAgICAgRU1NQ181XzFfUEhZLA0KPiA+ICAg
ICAgIE5SX1BIWV9UWVBFUw0KPiANCj4gVGhlcmUgaXMgbm8gbmVlZCBmb3IgTlJfUEhZX1RZUEVT
IG5vdyBzbyB5b3UgY291bGQgcmVtb3ZlIHRoYXQgYXMgd2VsbC4NCj4gDQoNCkkgdGhvdWdodCB0
aGUgc2FtZS4NClRoZSBvbmx5IHJlYXNvbiB0byBrZWVwIE5SX1BIWV9UWVBFUywgaXMgZm9yIHBv
dGVudGlhbCBmdXR1cmUgcGF0Y2hlcywNCndoZXJlIGl0IHdvdWxkIGJlIGp1c3QgMSBhZGRpdGlv
bg0KDQogZW51bSB4ZW5vbl9waHlfdHlwZV9lbnVtIHsNCiAgICAgIEVNTUNfNV8wX1BIWSwNCiAg
ICAgIEVNTUNfNV8xX1BIWSwNCisgICAgICBFTU1DXzVfMl9QSFksDQogICAgICBOUl9QSFlfVFlQ
RVMNCiAgfQ0KDQpEZXBlbmRpbmcgb24gc3R5bGUvcHJlZmVyZW5jZSBvZiBob3cgdG8gZG8gZW51
bXMgKGFsbG93IGNvbW1hIG9uIGxhc3QgZW51bQ0Kb3Igbm90IGFsbG93IGNvbW1hIG9uIGxhc3Qg
ZW51bSB2YWx1ZSksIGFkZGluZyBuZXcgZW51bSB2YWx1ZXMgd291ZGwgYmUgMg0KYWRkaXRpb25z
ICsgMSBkZWxldGlvbiBsaW5lcy4NCg0KIGVudW0geGVub25fcGh5X3R5cGVfZW51bSB7DQogICAg
ICBFTU1DXzVfMF9QSFksDQotICAgICAgRU1NQ181XzFfUEhZDQorICAgICAgRU1NDQpDXzVfMV9Q
SFksDQorICAgICAgRU1NQ181XzJfUEhZDQogfQ0KDQpFaXRoZXIgd2F5IChsZWF2ZSBOUl9QSFlf
VFlQRVMgb3IgcmVtb3ZlIE5SX1BIWV9UWVBFUykgaXMgZmluZSBmcm9tIG15DQpzaWRlLg0KDQpU
aGFua3MNCkFsZXgNCg0KPiByZWdhcmRzLA0KPiBkYW4gY2FycGVudGVyDQo+IA0K

