Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D0DC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:05:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0B0021479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 11:05:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="cJaRCIlX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0B0021479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E48E6B027B; Fri, 10 May 2019 07:05:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BE956B027C; Fri, 10 May 2019 07:05:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 034E66B027D; Fri, 10 May 2019 07:05:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA1766B027B
	for <linux-mm@kvack.org>; Fri, 10 May 2019 07:05:01 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s184so2115453oig.19
        for <linux-mm@kvack.org>; Fri, 10 May 2019 04:05:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=nVlpM+6hUpJfEDjmqqh5buswTi9IXWo+idp+3aYvadA=;
        b=uHgd3k6CZ56gm295a7zTdO0Vd9QqsqJMRprlt73gxDN4RldLkDsiDnnjqE7SsBPofs
         Ng+5heeapW9mjP4A9chCKku7NyJhY0nLTxmaYAwg/m6k9jtzjjaC3YodNxipnyyo4Lsl
         jxEDMxbbgqym9xsVIwE7HIsBvxn/622LupBE6jy2x2OyaPsauzQZTsq5fTSWTj+PoPC9
         7j+5IVn8bVNWQENn8gDxDEkkPLzQTBRz7CGgPzL4WF+kYsNUf7EuuAAXYJhurf3QLv4R
         o31oXCyDkbjTeIuJ3w/ie7uzJ03sinAUPTnG9Y7t9Oy7NbGTu3NYlKPHU1OwIu45hjOU
         aDOw==
X-Gm-Message-State: APjAAAXUXBFEXZPcWs7pMZb0oxnn5jEFIwADduhtl1c31I4gcPhJ9LiS
	PHZ1mW5KCxobeI9Qk+rRJDrcXejmVyLQ9JlUxuffoCbcyhZl3PhyUtvEx+E7YNwL0Ncxd2Gxwh8
	hLStvvoB6lOJLCKySKhmXSQ35Fpyj7F/WEnhCzVj0+V4xZcP30rWaisnCaIXh7gVI/w==
X-Received: by 2002:aca:e4c8:: with SMTP id b191mr5066414oih.110.1557486301288;
        Fri, 10 May 2019 04:05:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNSXRaA+shRWyW7HChDNwCu958hSqqhnpj1k+2XXx2ZVe3p0x4TILxOUGlpzjKCqF4RjT/
X-Received: by 2002:aca:e4c8:: with SMTP id b191mr5066377oih.110.1557486300629;
        Fri, 10 May 2019 04:05:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557486300; cv=none;
        d=google.com; s=arc-20160816;
        b=qKgsfzI2kv3RqoVQzr91adLxElh652s47bkUc8Lk+eMCJO+qumroBUBowP5BaDq/OP
         OgUXK6twlGgve05JMPKg/0PEOCTj2tqNkhzVD3LekOwDVFP9LnekCYk/GOoOTt8AzCy3
         KcAEzlXaN7j+DS7DIFZ19DG/25N21JwDkdDSdNafZzuZWQYyKFMah4yyhA6LAOGRNfV7
         T0dd0jRAbp+umnEa9NYq+9Mw02Icoq52MagXRWXm6wX9SpA/Mt38aTnww9FdSkXy1b+z
         GOBIGGyXLG0v/A4fa7GRcVujZ6LIkJ8vS6n5A9xwXz1iLpVdhON7GIR8PWfZsiUqGQBL
         zVQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=nVlpM+6hUpJfEDjmqqh5buswTi9IXWo+idp+3aYvadA=;
        b=ZkxOSjMIiNPMJ/UZhNiURHG8rN3Yy3bhDiL1z7eyJSTMxvM2WC1jEZXeTfuiy9jvxd
         OK0NTR8u2FmMD687npee6pgAkWwOY9Pn6zWyBJQ0FzyKHgVpYTvqVr5+SQ5h8uRgXpuv
         6TkaNTDPJkCf6gMA3gu75AuArBGr9oLn4DV3IvpplRmxiubwbyulEtNTfzDVzI+Dt1DL
         OU6bXQNt6UhC9d6uLce4l8OUENe8UPDbgbZikssCoEGRA54rSes2wt8VLuZ5bucyFusP
         PYS20cu0qWuhUNaLf4L4Z3qPxM0+MmpcHAVpqTtLuqgf4Y8wvUZ3hyeziI5Z1GdEUVel
         n6ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=cJaRCIlX;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.74 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780074.outbound.protection.outlook.com. [40.107.78.74])
        by mx.google.com with ESMTPS id c25si2873179otf.205.2019.05.10.04.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 04:05:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.74 as permitted sender) client-ip=40.107.78.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=cJaRCIlX;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.74 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nVlpM+6hUpJfEDjmqqh5buswTi9IXWo+idp+3aYvadA=;
 b=cJaRCIlXlhytsC0WOUjovdUXlHRExZWPjhVf03F0+kh9EW3mb68RI6Rnc3cHyEhKGz4sJV9wA82vpcEx/F+iU3ypyrnsW4/k0e997VS2hIGKO+igCU4zzHHlAx2b/kf5RKAjaKA2W3b6tkRnBRfNgWUAFNGQGOnAYoLiEYdp3VE=
Received: from BN6PR03CA0017.namprd03.prod.outlook.com (2603:10b6:404:23::27)
 by BY2PR03MB556.namprd03.prod.outlook.com (2a01:111:e400:2c3a::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1878.22; Fri, 10 May
 2019 11:04:54 +0000
Received: from BL2NAM02FT036.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::208) by BN6PR03CA0017.outlook.office365.com
 (2603:10b6:404:23::27) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.20 via Frontend
 Transport; Fri, 10 May 2019 11:04:54 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; linux.intel.com; dkim=none (message not signed)
 header.d=none;linux.intel.com; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 BL2NAM02FT036.mail.protection.outlook.com (10.152.77.154) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Fri, 10 May 2019 11:04:53 +0000
Received: from NWD2HUBCAS9.ad.analog.com (nwd2hubcas9.ad.analog.com [10.64.69.109])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x4AB4rkt031706
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Fri, 10 May 2019 04:04:53 -0700
Received: from NWD2MBX7.ad.analog.com ([fe80::190e:f9c1:9a22:9663]) by
 NWD2HUBCAS9.ad.analog.com ([fe80::44a2:871b:49ab:ea47%12]) with mapi id
 14.03.0415.000; Fri, 10 May 2019 07:04:53 -0400
From: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
To: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
CC: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-ide@vger.kernel.org"
	<linux-ide@vger.kernel.org>, "linux-mtd@lists.infradead.org"
	<linux-mtd@lists.infradead.org>, "linux-rockchip@lists.infradead.org"
	<linux-rockchip@lists.infradead.org>, "linux-usb@vger.kernel.org"
	<linux-usb@vger.kernel.org>, "linux-mmc@vger.kernel.org"
	<linux-mmc@vger.kernel.org>, "linux-tegra@vger.kernel.org"
	<linux-tegra@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-clk@vger.kernel.org"
	<linux-clk@vger.kernel.org>, "alsa-devel@alsa-project.org"
	<alsa-devel@alsa-project.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>, "andriy.shevchenko@linux.intel.com"
	<andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Thread-Topic: [PATCH 09/16] mmc: sdhci-xenon: use new match_string()
 helper/macro
Thread-Index: AQHVBZFjC5krcc3G0k+g00YBPwx6V6ZhaK0AgAAShYCAAt35AIAAHiKAgAABAAA=
Date: Fri, 10 May 2019 11:04:53 +0000
Message-ID: <d320a13ad06bba87fcb0c04c4143e911723684ea.camel@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
	 <20190508112842.11654-11-alexandru.ardelean@analog.com>
	 <20190508122010.GC21059@kadam>
	 <2ec6812d6bf2f33860c7c816c641167a31eb2ed6.camel@analog.com>
	 <31be52eb1a1abbc99a24729f5c65619235cb201f.camel@analog.com>
	 <20190510110116.GB18105@kadam>
In-Reply-To: <20190510110116.GB18105@kadam>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.50.1.244]
x-adiroutedonprem: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <134D0B85CEA25646B3EBD898406EC02C@analog.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(136003)(396003)(376002)(346002)(39860400002)(2980300002)(189003)(199004)(426003)(76176011)(102836004)(26005)(436003)(70206006)(446003)(8936002)(7696005)(70586007)(36756003)(14444005)(6246003)(186003)(336012)(2486003)(8676002)(6116002)(3846002)(229853002)(5660300002)(11346002)(47776003)(5640700003)(356004)(305945005)(50466002)(2616005)(476003)(6916009)(2906002)(118296001)(478600001)(126002)(7736002)(86362001)(14454004)(2351001)(2501003)(7636002)(23676004)(106002)(246002)(4326008)(316002)(7416002)(7406005)(54906003)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:BY2PR03MB556;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: f76a2088-dc12-4942-d433-08d6d537549b
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328)(7193020);SRVR:BY2PR03MB556;
X-MS-TrafficTypeDiagnostic: BY2PR03MB556:
X-Microsoft-Antispam-PRVS:
	<BY2PR03MB5567CAEF2048D0CACEA3D3CF90C0@BY2PR03MB556.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-Forefront-PRVS: 0033AAD26D
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	tULqUEYxx8A1Vcan/qfbE7E/YiNcE+blJBkWLIfZLYQfoW+YJfMk/7pGVcvZ1Zi7zwbrhva5fOWhPlE7BRloVhcy0b7UY+H3u7eHfxlqm2FqcBDBRA6rNCrikJSdpJCdjDevTorMO4v2pbPJ9vgXgpdzx4rSWTBAzaTFpTqnxoN6817pHFRM6OimKYwZT+zkHQBRDborUH0cfCMCTH7W/DYsug3lJUPmoVohbzUw7Qlzb5gflrpKMIIuKRlZUQA5y+LwbgY2fjwZItJ1in7CCdq2yHbgQEyod/D4nUaFXtQNysaVfM6q5P4JW2pJdKeJjrqkRhofhZP8Dy5+VsJYbafZu2hWLTkGR5O0X96SKzhm9VbATpPl5eWgoo6bTpaSEgvMToAEFFE6dQ7aXg+NwW0dDvkkJwZFaifj5Uv3dxk=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 10 May 2019 11:04:53.7708
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: f76a2088-dc12-4942-d433-08d6d537549b
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY2PR03MB556
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA1LTEwIGF0IDE0OjAxICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiBbRXh0ZXJuYWxdDQo+IA0KPiANCj4gT24gRnJpLCBNYXkgMTAsIDIwMTkgYXQgMDk6MTM6MjZB
TSArMDAwMCwgQXJkZWxlYW4sIEFsZXhhbmRydSB3cm90ZToNCj4gPiBPbiBXZWQsIDIwMTktMDUt
MDggYXQgMTY6MjYgKzAzMDAsIEFsZXhhbmRydSBBcmRlbGVhbiB3cm90ZToNCj4gPiA+IE9uIFdl
ZCwgMjAxOS0wNS0wOCBhdCAxNToyMCArMDMwMCwgRGFuIENhcnBlbnRlciB3cm90ZToNCj4gPiA+
ID4gDQo+ID4gPiA+IA0KPiA+ID4gPiBPbiBXZWQsIE1heSAwOCwgMjAxOSBhdCAwMjoyODozNVBN
ICswMzAwLCBBbGV4YW5kcnUgQXJkZWxlYW4gd3JvdGU6DQo+ID4gPiA+ID4gLXN0YXRpYyBjb25z
dCBjaGFyICogY29uc3QgcGh5X3R5cGVzW10gPSB7DQo+ID4gPiA+ID4gLSAgICAgImVtbWMgNS4w
IHBoeSIsDQo+ID4gPiA+ID4gLSAgICAgImVtbWMgNS4xIHBoeSINCj4gPiA+ID4gPiAtfTsNCj4g
PiA+ID4gPiAtDQo+ID4gPiA+ID4gIGVudW0geGVub25fcGh5X3R5cGVfZW51bSB7DQo+ID4gPiA+
ID4gICAgICAgRU1NQ181XzBfUEhZLA0KPiA+ID4gPiA+ICAgICAgIEVNTUNfNV8xX1BIWSwNCj4g
PiA+ID4gPiAgICAgICBOUl9QSFlfVFlQRVMNCj4gPiA+ID4gDQo+ID4gPiA+IFRoZXJlIGlzIG5v
IG5lZWQgZm9yIE5SX1BIWV9UWVBFUyBub3cgc28geW91IGNvdWxkIHJlbW92ZSB0aGF0IGFzDQo+
ID4gPiA+IHdlbGwuDQo+ID4gPiA+IA0KPiA+ID4gDQo+ID4gPiBJIHRob3VnaHQgdGhlIHNhbWUu
DQo+ID4gPiBUaGUgb25seSByZWFzb24gdG8ga2VlcCBOUl9QSFlfVFlQRVMsIGlzIGZvciBwb3Rl
bnRpYWwgZnV0dXJlDQo+ID4gPiBwYXRjaGVzLA0KPiA+ID4gd2hlcmUgaXQgd291bGQgYmUganVz
dCAxIGFkZGl0aW9uDQo+ID4gPiANCj4gPiA+ICBlbnVtIHhlbm9uX3BoeV90eXBlX2VudW0gew0K
PiA+ID4gICAgICAgRU1NQ181XzBfUEhZLA0KPiA+ID4gICAgICAgRU1NQ181XzFfUEhZLA0KPiA+
ID4gKyAgICAgIEVNTUNfNV8yX1BIWSwNCj4gPiA+ICAgICAgIE5SX1BIWV9UWVBFUw0KPiA+ID4g
ICB9DQo+ID4gPiANCj4gPiA+IERlcGVuZGluZyBvbiBzdHlsZS9wcmVmZXJlbmNlIG9mIGhvdyB0
byBkbyBlbnVtcyAoYWxsb3cgY29tbWEgb24gbGFzdA0KPiA+ID4gZW51bQ0KPiA+ID4gb3Igbm90
IGFsbG93IGNvbW1hIG9uIGxhc3QgZW51bSB2YWx1ZSksIGFkZGluZyBuZXcgZW51bSB2YWx1ZXMg
d291ZGwNCj4gPiA+IGJlIDINCj4gPiA+IGFkZGl0aW9ucyArIDEgZGVsZXRpb24gbGluZXMuDQo+
ID4gPiANCj4gPiA+ICBlbnVtIHhlbm9uX3BoeV90eXBlX2VudW0gew0KPiA+ID4gICAgICAgRU1N
Q181XzBfUEhZLA0KPiA+ID4gLSAgICAgIEVNTUNfNV8xX1BIWQ0KPiA+ID4gKyAgICAgIEVNTQ0K
PiA+ID4gQ181XzFfUEhZLA0KPiA+ID4gKyAgICAgIEVNTUNfNV8yX1BIWQ0KPiA+ID4gIH0NCj4g
PiA+IA0KPiA+ID4gRWl0aGVyIHdheSAobGVhdmUgTlJfUEhZX1RZUEVTIG9yIHJlbW92ZSBOUl9Q
SFlfVFlQRVMpIGlzIGZpbmUgZnJvbQ0KPiA+ID4gbXkNCj4gPiA+IHNpZGUuDQo+ID4gPiANCj4g
PiANCj4gPiBQcmVmZXJlbmNlIG9uIHRoaXMgPw0KPiA+IElmIG5vIG9iamVjdGlvbiBbbm9ib2R5
IGluc2lzdHNdIEkgd291bGQga2VlcC4NCj4gPiANCj4gPiBJIGRvbid0IGZlZWwgc3Ryb25nbHkg
YWJvdXQgaXQgW2Ryb3BwaW5nIE5SX1BIWV9UWVBFUyBvciBub3RdLg0KPiANCj4gSWYgeW91IGVu
ZCB1cCByZXNlbmRpbmcgdGhlIHNlcmllcyBjb3VsZCB5b3UgcmVtb3ZlIGl0LCBidXQgaWYgbm90
IHRoZW4NCj4gaXQncyBub3Qgd29ydGggaXQuDQoNCmFjaw0KDQp0aGFua3MNCkFsZXgNCg0KPiAN
Cj4gcmVnYXJkcywNCj4gZGFuIGNhcnBlbnRlcg0KPiANCg==

