Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A445C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 09:13:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3B5321479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 09:13:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="UtgaGDmS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3B5321479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4335C6B026E; Fri, 10 May 2019 05:13:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E5846B0270; Fri, 10 May 2019 05:13:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2860C6B0271; Fri, 10 May 2019 05:13:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id F23846B026E
	for <linux-mm@kvack.org>; Fri, 10 May 2019 05:13:35 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id e88so2609918ote.14
        for <linux-mm@kvack.org>; Fri, 10 May 2019 02:13:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Cd+V8yqGMykCDx3832Gazx49N+DzcZoh0jyuHRt5ol4=;
        b=D/huqV0TF44/bajPGFEElUnCOp6kpUGo3OywNPQdUiBKC3bxh9Yoy2JZnmux5RQVya
         fTxHYcGuIVwEHAQQXS4B/33J3F5m0riuernHLg4LJ76cskc3x4gXWVcvZj0nJtXIjqLb
         yOUmC+14bQURty7q9/xWrpwwBacaGuVBX1zzMFUjwvsm415T8BxNyVidzd29c5Wg2XCk
         Hth/vYuiwpSuXTPdaegp5+eHa2wmt7fXrLZNLFze6/pBTnRPHizkTpuvCFTy1VJ/b0XQ
         35as/nUQ/zHfkBdBfpgNEzurwowpmLxYMmrbZizWsnXfFC0QqGv4bTskH3Dl4XXI3xkI
         SBjA==
X-Gm-Message-State: APjAAAXc4oTrIH19gigfZeJj6ZyXQRjiUG3JykAGu2UJmnhWtzFA4KPN
	mIdg2zGHJYBJEKwO2MFg+tc1STwTl2E7j18hI+NIjC29pkNOqpoCbFmjarNBmSeWMjLo+3XOrhF
	yyDuU2MxsAfiV6xvU6sqMFvryZB7SpUs4TzEYILNpENo4T/gVBO8FPyT1NdkE8ycJLg==
X-Received: by 2002:a9d:74c9:: with SMTP id a9mr3092819otl.218.1557479615585;
        Fri, 10 May 2019 02:13:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQBZFYcFUeHfNNFPhl+4vK10tiKoDOfoolmOa/vOA54qZiYOKqdswaL889GYisya71r7RX
X-Received: by 2002:a9d:74c9:: with SMTP id a9mr3092788otl.218.1557479614711;
        Fri, 10 May 2019 02:13:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557479614; cv=none;
        d=google.com; s=arc-20160816;
        b=D2LTjc+EdtUGTssWGlcFIS3V4NcC6ODjZ1Pbri+pPBm6VJjxmtcDNf3IxUtq6+Y4rc
         1qE9VfAC5Qab5EK22o8rPAA/9s2XCgprU1RXdVZ/To4QECGct9+UTKY8UB4yOLKt36Fb
         taSoloZxxrhvU1eqybTCMIviQ+w1JWd6fHJVzes36954fxy6kPRD4e/6yqdNz2SpjUHh
         S1Tq40641EDPCH8AlWXBprUTO956VbQNurFJ1AUbxOT/L7eJGlsvjlG04skVbDYHutKc
         RkJp6sEnCZq5ucAEBl+LOJ5krVjUHOMjhHpLGuOAlBTN05zoQy7ePP70QOm4siO3zL0p
         XFgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Cd+V8yqGMykCDx3832Gazx49N+DzcZoh0jyuHRt5ol4=;
        b=hkg6RzyX+LrdoXHKP9zp+9m30m6KaUIJmk/x+7gL4jaNmn2COQ611tNNf6Lhi4WuCS
         D05JPiBCCWPfUiBCp3XX3iNLd4Nij63htPLQsjisHIrnl/L6ImUbm3DxGnbEaEhm02+l
         2l1vWuwcgMMNvBoSn2iYnzaq0AeXA/dM1CuNnIeliwBwMMf6gsxiXdNZ1ZzlLBOQIyUB
         +78aw0ZqJt8goYY6JO5pLTRvT+kQr4SPfTKqIu7YW9rz7PMYPe5VoTg04frYXQ5qwRE1
         cFgqEXulvDldPPK1SZ+BfYduh4czSmPhdF2x6jv8XXLZz/Q6cXExP5lgajPoEtyNDfUG
         662Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=UtgaGDmS;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.89 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730089.outbound.protection.outlook.com. [40.107.73.89])
        by mx.google.com with ESMTPS id u79si2849668oif.72.2019.05.10.02.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 02:13:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.89 as permitted sender) client-ip=40.107.73.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=UtgaGDmS;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.89 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Cd+V8yqGMykCDx3832Gazx49N+DzcZoh0jyuHRt5ol4=;
 b=UtgaGDmS/mFN7LqP4rRanlhIErtROJDfXKgcIeQ1c2pUsTHgWkYu7j96Yd2lPftDdz2wXx3xkpYor7R+H8gftiZOSJxx+ATBAk9fPgRuYm3L0Lav4JU1SKRoMBgfFlLd2aeYeN4GFuH2989f+gy+Ay1+8Dk0VQ9Sau1g+bv3pvo=
Received: from BN3PR03CA0101.namprd03.prod.outlook.com (2603:10b6:400:4::19)
 by BN3PR03MB2257.namprd03.prod.outlook.com (2a01:111:e400:c5f1::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1878.22; Fri, 10 May
 2019 09:13:30 +0000
Received: from BL2NAM02FT032.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::206) by BN3PR03CA0101.outlook.office365.com
 (2603:10b6:400:4::19) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Fri, 10 May 2019 09:13:29 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 BL2NAM02FT032.mail.protection.outlook.com (10.152.77.169) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Fri, 10 May 2019 09:13:29 +0000
Received: from NWD2HUBCAS8.ad.analog.com (nwd2hubcas8.ad.analog.com [10.64.69.108])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x4A9DRsE000406
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Fri, 10 May 2019 02:13:27 -0700
Received: from NWD2MBX7.ad.analog.com ([fe80::190e:f9c1:9a22:9663]) by
 NWD2HUBCAS8.ad.analog.com ([fe80::90a0:b93e:53c6:afee%12]) with mapi id
 14.03.0415.000; Fri, 10 May 2019 05:13:27 -0400
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
Thread-Index: AQHVBZFjC5krcc3G0k+g00YBPwx6V6ZhaK0AgAAShYCAAt35AA==
Date: Fri, 10 May 2019 09:13:26 +0000
Message-ID: <31be52eb1a1abbc99a24729f5c65619235cb201f.camel@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
	 <20190508112842.11654-11-alexandru.ardelean@analog.com>
	 <20190508122010.GC21059@kadam>
	 <2ec6812d6bf2f33860c7c816c641167a31eb2ed6.camel@analog.com>
In-Reply-To: <2ec6812d6bf2f33860c7c816c641167a31eb2ed6.camel@analog.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.50.1.244]
x-adiroutedonprem: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <BB59C46108248B4E9B7153CD2DF23B7C@analog.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(39860400002)(136003)(376002)(396003)(346002)(2980300002)(189003)(199004)(486006)(126002)(86362001)(186003)(436003)(426003)(11346002)(6916009)(2351001)(476003)(2501003)(478600001)(2616005)(47776003)(336012)(446003)(229853002)(5640700003)(5660300002)(305945005)(70206006)(70586007)(6116002)(7406005)(3846002)(7416002)(118296001)(7736002)(8676002)(54906003)(8936002)(6246003)(7636002)(102836004)(76176011)(7696005)(246002)(2486003)(23676004)(36756003)(26005)(356004)(316002)(2906002)(50466002)(14454004)(4326008)(106002)(14444005);DIR:OUT;SFP:1101;SCL:1;SRVR:BN3PR03MB2257;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: ed9fe5e3-db8d-4bcc-4243-08d6d527c4a6
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328)(7193020);SRVR:BN3PR03MB2257;
X-MS-TrafficTypeDiagnostic: BN3PR03MB2257:
X-Microsoft-Antispam-PRVS:
	<BN3PR03MB22575AF9CEACED448826345BF90C0@BN3PR03MB2257.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:9508;
X-Forefront-PRVS: 0033AAD26D
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	hz7ohuHgjnC+2gC26Y3onOT2s7J5axPm+umLFJQFpWgNQk6MlgOTYWYEOsKdiXoy1GNT+vGczdwJR2hzhjkPPM1uQL11kNZN6SYSWyKfr2kiZbabqEYBPxg7icedXBmdO+rbB5SwWFk2CrIhe/7lkW+xgUYjQGNgYAWGE0lXiIRaorInlOmQTMPz663NCbL7aaCb7ajYyo05LxXNUMEKTW2Pof7owMPxVhD448BZPhIoBbV1UHHwV/vrelBEVbXLtRY94OqIxeAe7xTw2lhziZuN15WfFYwjblJa6OE/jYP1PkRLhqh4l1AN/UYxDW/icpD8nSoxxD0H5PPn7qhAU0pjn6TkUKbqtid8LuApVz3z+EfmjXcQFNq5JLTewszxUxStGHfqcWVxcM/2aY0TjxPPu7OPuaGxGQvTycbDhqM=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 10 May 2019 09:13:29.7933
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: ed9fe5e3-db8d-4bcc-4243-08d6d527c4a6
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN3PR03MB2257
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTA4IGF0IDE2OjI2ICswMzAwLCBBbGV4YW5kcnUgQXJkZWxlYW4gd3Jv
dGU6DQo+IE9uIFdlZCwgMjAxOS0wNS0wOCBhdCAxNToyMCArMDMwMCwgRGFuIENhcnBlbnRlciB3
cm90ZToNCj4gPiANCj4gPiANCj4gPiBPbiBXZWQsIE1heSAwOCwgMjAxOSBhdCAwMjoyODozNVBN
ICswMzAwLCBBbGV4YW5kcnUgQXJkZWxlYW4gd3JvdGU6DQo+ID4gPiAtc3RhdGljIGNvbnN0IGNo
YXIgKiBjb25zdCBwaHlfdHlwZXNbXSA9IHsNCj4gPiA+IC0gICAgICJlbW1jIDUuMCBwaHkiLA0K
PiA+ID4gLSAgICAgImVtbWMgNS4xIHBoeSINCj4gPiA+IC19Ow0KPiA+ID4gLQ0KPiA+ID4gIGVu
dW0geGVub25fcGh5X3R5cGVfZW51bSB7DQo+ID4gPiAgICAgICBFTU1DXzVfMF9QSFksDQo+ID4g
PiAgICAgICBFTU1DXzVfMV9QSFksDQo+ID4gPiAgICAgICBOUl9QSFlfVFlQRVMNCj4gPiANCj4g
PiBUaGVyZSBpcyBubyBuZWVkIGZvciBOUl9QSFlfVFlQRVMgbm93IHNvIHlvdSBjb3VsZCByZW1v
dmUgdGhhdCBhcyB3ZWxsLg0KPiA+IA0KPiANCj4gSSB0aG91Z2h0IHRoZSBzYW1lLg0KPiBUaGUg
b25seSByZWFzb24gdG8ga2VlcCBOUl9QSFlfVFlQRVMsIGlzIGZvciBwb3RlbnRpYWwgZnV0dXJl
IHBhdGNoZXMsDQo+IHdoZXJlIGl0IHdvdWxkIGJlIGp1c3QgMSBhZGRpdGlvbg0KPiANCj4gIGVu
dW0geGVub25fcGh5X3R5cGVfZW51bSB7DQo+ICAgICAgIEVNTUNfNV8wX1BIWSwNCj4gICAgICAg
RU1NQ181XzFfUEhZLA0KPiArICAgICAgRU1NQ181XzJfUEhZLA0KPiAgICAgICBOUl9QSFlfVFlQ
RVMNCj4gICB9DQo+IA0KPiBEZXBlbmRpbmcgb24gc3R5bGUvcHJlZmVyZW5jZSBvZiBob3cgdG8g
ZG8gZW51bXMgKGFsbG93IGNvbW1hIG9uIGxhc3QNCj4gZW51bQ0KPiBvciBub3QgYWxsb3cgY29t
bWEgb24gbGFzdCBlbnVtIHZhbHVlKSwgYWRkaW5nIG5ldyBlbnVtIHZhbHVlcyB3b3VkbCBiZSAy
DQo+IGFkZGl0aW9ucyArIDEgZGVsZXRpb24gbGluZXMuDQo+IA0KPiAgZW51bSB4ZW5vbl9waHlf
dHlwZV9lbnVtIHsNCj4gICAgICAgRU1NQ181XzBfUEhZLA0KPiAtICAgICAgRU1NQ181XzFfUEhZ
DQo+ICsgICAgICBFTU0NCj4gQ181XzFfUEhZLA0KPiArICAgICAgRU1NQ181XzJfUEhZDQo+ICB9
DQo+IA0KPiBFaXRoZXIgd2F5IChsZWF2ZSBOUl9QSFlfVFlQRVMgb3IgcmVtb3ZlIE5SX1BIWV9U
WVBFUykgaXMgZmluZSBmcm9tIG15DQo+IHNpZGUuDQo+IA0KDQpQcmVmZXJlbmNlIG9uIHRoaXMg
Pw0KSWYgbm8gb2JqZWN0aW9uIFtub2JvZHkgaW5zaXN0c10gSSB3b3VsZCBrZWVwLg0KDQpJIGRv
bid0IGZlZWwgc3Ryb25nbHkgYWJvdXQgaXQgW2Ryb3BwaW5nIE5SX1BIWV9UWVBFUyBvciBub3Rd
Lg0KDQpUaGFua3MNCkFsZXgNCg0KPiBUaGFua3MNCj4gQWxleA0KPiANCj4gPiByZWdhcmRzLA0K
PiA+IGRhbiBjYXJwZW50ZXINCj4gPiANCg==

