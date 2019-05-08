Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47B4CC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA8ED20850
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="UMtRA7bt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA8ED20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CA2F6B0007; Wed,  8 May 2019 09:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7535E6B0008; Wed,  8 May 2019 09:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CCDA6B000A; Wed,  8 May 2019 09:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38C9E6B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 09:22:12 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i124so21775980qkf.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 06:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=57n0axMWfSppjRKnE2U+vW//5BLzA4EzmC99Z5lXAeE=;
        b=XTVZv9xHwnLv3MAyXMjJXV+/zaRdl+ZVYiTF80nyUuQDgQXkd5ZElnM9WvHLayKxsN
         4XZl4BoXadykoYmv8eFk/PS+NIBMN0Ypsp7UfS7WiJt8t973dWh1+S7ujZOS0e9kHPGN
         qqEJFoXNh9m3amV8WmLmPo1kxhoZkCJ53aOMwyCLarg7X6EQyKVeo6yrdo5uOWq+9psn
         Nz/CqmM1KTPNldgfomM+Pit39PoSlN5h+Z/nt7Gl2qn2bxPfr0dayrof29SUo99OkeBt
         c87ccyANo5FJLsYJgb2ue52b4T+OyryXTlMN5j4EoftynwtBrH9e+lS8iFpiQcg80meM
         vnUQ==
X-Gm-Message-State: APjAAAXJ8aIqMVAHBSEL6jouC1pup1957RMKqIv9ka5AmJRtoc682T2g
	ZYGhw45UM9LTucR2u07EZBrOLEDBLhPK58PZVblB0/d9hjzBrMcclc0atR1JzxslHMLAJ1IJTY+
	OJAseQAgT5vNnN/3iKK6h2QqtLOOtMUJiNkb6gLJ291awOt2VTYIYdao7DwBQLqyIhA==
X-Received: by 2002:ac8:3702:: with SMTP id o2mr13409480qtb.119.1557321731950;
        Wed, 08 May 2019 06:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwMDxxsv35E5zZeg94MXLL4VMrpZVcy1YqSSathPcWWq4Q1etxjeNzejAb5w0K4tUHHAV1
X-Received: by 2002:ac8:3702:: with SMTP id o2mr13409432qtb.119.1557321731399;
        Wed, 08 May 2019 06:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557321731; cv=none;
        d=google.com; s=arc-20160816;
        b=XANHM/7gKajKJ1g0aI4IdJEeIEJv/Nj8HTYN854fdARfXp2ViHBM5RJIae7dWJ7hzt
         6DJq5nCUmLOY8PZm3mRvVEnqvvMxOcfPQ8wRbmALgxFtTmcLqzNZ3BGwGjHLVV0mK+MB
         ipi2rKm8iT0qr+VKqfKZN1oZKiTMIoNbtCmja86Y0gljqt4UTvrZ5qMo6+kBzYJfpNE1
         J960Qv/Voa0vTDm1s82wrOi8e99IszGBhHl5Pn4mDRb+2lWqP3gZqRIIJ+AaY1R5i3vm
         cZC1vMGUJHgOICejt98vW1j1BPtqgIwwmomRJBk04ijQv/LC22gtL5j8y2CMC/sid7JJ
         Xl2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=57n0axMWfSppjRKnE2U+vW//5BLzA4EzmC99Z5lXAeE=;
        b=nkzBalfsAUuAW1zot0aiTQu5FX92MHQhD8fQ0rcqFjsdqjSsS7nogVltGF5gGrBGuJ
         bntzcI5aYi6w2fhXovQk+2CT3Ze7rvJg/Ug+Sv14FuKt7xmWWQKi53GTxYQA9U8eLsAJ
         6FEsPzjUDddof8OCeOLP+0Ak9oW5zxc+xMWnfrWTLWefJq4LmJw3VqDmngBGDeNZ5XKt
         xvksfusYXxn/V2biPh2lqQQVUmsZRqpYtVRX3ZOecs9IAgVPx5cJbDByTvD04cp4F2Hx
         HC0a3JFR/6TAY92zHb/mQiwJn5yaYlSnD5LTCHiBarNgDKECrleXzFz/6Gd1MymTfhQt
         rWSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=UMtRA7bt;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680071.outbound.protection.outlook.com. [40.107.68.71])
        by mx.google.com with ESMTPS id y34si6331118qvf.20.2019.05.08.06.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 06:22:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) client-ip=40.107.68.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=UMtRA7bt;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=57n0axMWfSppjRKnE2U+vW//5BLzA4EzmC99Z5lXAeE=;
 b=UMtRA7btjltIWs48hXkIv4/4HA4IV3jQ8cBnXHCpLfp1I3Z4Akzil07iQIkMOgwEDQXTy0tz3IdYXq0FC5hSRTvvuT1Xev4r2cg33hAk4ofoV6UgoZNKh+NcLw6xgdfmxGeEwPGz/hf9ACdPlcTPaDajdfqjDPJ4X5c+Lq4NkTc=
Received: from BN6PR03CA0059.namprd03.prod.outlook.com (2603:10b6:404:4c::21)
 by CY4PR03MB3125.namprd03.prod.outlook.com (2603:10b6:910:53::26) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.15; Wed, 8 May
 2019 13:22:07 +0000
Received: from CY1NAM02FT028.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::204) by BN6PR03CA0059.outlook.office365.com
 (2603:10b6:404:4c::21) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Wed, 8 May 2019 13:22:06 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 CY1NAM02FT028.mail.protection.outlook.com (10.152.75.132) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 13:22:05 +0000
Received: from NWD2HUBCAS9.ad.analog.com (nwd2hubcas9.ad.analog.com [10.64.69.109])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48DM4Hp020338
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 06:22:04 -0700
Received: from NWD2MBX7.ad.analog.com ([fe80::190e:f9c1:9a22:9663]) by
 NWD2HUBCAS9.ad.analog.com ([fe80::44a2:871b:49ab:ea47%12]) with mapi id
 14.03.0415.000; Wed, 8 May 2019 09:22:04 -0400
From: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
To: "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
CC: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-omap@vger.kernel.org"
	<linux-omap@vger.kernel.org>, "linux-gpio@vger.kernel.org"
	<linux-gpio@vger.kernel.org>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "devel@driverdev.osuosl.org"
	<devel@driverdev.osuosl.org>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>, "linux-fbdev@vger.kernel.org"
	<linux-fbdev@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "alsa-devel@alsa-project.org"
	<alsa-devel@alsa-project.org>, "linux-rockchip@lists.infradead.org"
	<linux-rockchip@lists.infradead.org>, "linux-clk@vger.kernel.org"
	<linux-clk@vger.kernel.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-mtd@lists.infradead.org"
	<linux-mtd@lists.infradead.org>, "linux-tegra@vger.kernel.org"
	<linux-tegra@vger.kernel.org>
Subject: Re: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Thread-Topic: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Thread-Index: AQHVBZFQXT7pBvOEwE+osXNwuBSvQKZhdwMAgAACFgCAAADdAA==
Date: Wed, 8 May 2019 13:22:03 +0000
Message-ID: <b2440bc9485456a7a90a488c528997587b22088b.camel@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
	 <20190508112842.11654-5-alexandru.ardelean@analog.com>
	 <20190508131128.GL9224@smile.fi.intel.com>
	 <20190508131856.GB10138@kroah.com>
In-Reply-To: <20190508131856.GB10138@kroah.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.50.1.244]
x-adiroutedonprem: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <1E6885BF46859D4BA859205743820E9A@analog.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(396003)(136003)(376002)(346002)(39860400002)(2980300002)(189003)(199004)(486006)(70586007)(246002)(26005)(126002)(2906002)(6246003)(2501003)(316002)(86362001)(70206006)(54906003)(7416002)(11346002)(36756003)(110136005)(5660300002)(476003)(4744005)(50466002)(102836004)(356004)(446003)(478600001)(436003)(186003)(106002)(426003)(4326008)(2616005)(229853002)(8936002)(7736002)(14454004)(336012)(7636002)(3846002)(76176011)(118296001)(6116002)(7696005)(8676002)(2486003)(305945005)(47776003)(23676004)(142933001);DIR:OUT;SFP:1101;SCL:1;SRVR:CY4PR03MB3125;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: bf20b47f-7a5e-4fec-5507-08d6d3b82ade
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328)(7193020);SRVR:CY4PR03MB3125;
X-MS-TrafficTypeDiagnostic: CY4PR03MB3125:
X-Microsoft-Antispam-PRVS:
	<CY4PR03MB3125B0A44595D00ED95BC72FF9320@CY4PR03MB3125.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	Y23xOtmneh07yASE+/blELoCkrmoUK2VWWlwgfLPI2XEB7HSNAG31rJcUjy0gmVYvxrvWAJWix4tCmwxJND2sMhli4fdVGFvwA+r1WjwvaHAApuJYd3VNN4OWSQT/CJhB+OvvdFJJwQlGID7fD9BmmAUUIz44XSoq5JB1yP3qTQOjUc9QybzLdR4/w1V8KZgHUgitxp1f85Fsq6Gp/t7tpe3x9bohvD3luQWpxzuQodTpuIoNkt9J/0jNcc4OJcpeiQYGsEMFn1Wm6GweN4qfiaHcfFLjzADZt7JchoV72QH3aogegojaUXzeYue5Y1hMAswgJmlCCOkjQNQRyvvx6iYA32Asn2Wy2nCRCMqaFN0wb4+EM9SyjG0jUY9CnHEEttETR6crG7QDiTZNLtDe3Op5pVyuXYipjCRAcV6uKw=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 13:22:05.0484
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: bf20b47f-7a5e-4fec-5507-08d6d3b82ade
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY4PR03MB3125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTA4IGF0IDE1OjE4ICswMjAwLCBHcmVnIEtIIHdyb3RlOg0KPiANCj4g
DQo+IE9uIFdlZCwgTWF5IDA4LCAyMDE5IGF0IDA0OjExOjI4UE0gKzAzMDAsIEFuZHkgU2hldmNo
ZW5rbyB3cm90ZToNCj4gPiBPbiBXZWQsIE1heSAwOCwgMjAxOSBhdCAwMjoyODoyOVBNICswMzAw
LCBBbGV4YW5kcnUgQXJkZWxlYW4gd3JvdGU6DQo+ID4gPiBUaGlzIGNoYW5nZSByZS1pbnRyb2R1
Y2VzIGBtYXRjaF9zdHJpbmcoKWAgYXMgYSBtYWNybyB0aGF0IHVzZXMNCj4gPiA+IEFSUkFZX1NJ
WkUoKSB0byBjb21wdXRlIHRoZSBzaXplIG9mIHRoZSBhcnJheS4NCj4gPiA+IFRoZSBtYWNybyBp
cyBhZGRlZCBpbiBhbGwgdGhlIHBsYWNlcyB0aGF0IGRvDQo+ID4gPiBgbWF0Y2hfc3RyaW5nKF9h
LCBBUlJBWV9TSVpFKF9hKSwgcylgLCBzaW5jZSB0aGUgY2hhbmdlIGlzIHByZXR0eQ0KPiA+ID4g
c3RyYWlnaHRmb3J3YXJkLg0KPiA+IA0KPiA+IENhbiB5b3Ugc3BsaXQgaW5jbHVkZS9saW51eC8g
Y2hhbmdlIGZyb20gdGhlIHJlc3Q/DQo+IA0KPiBUaGF0IHdvdWxkIGJyZWFrIHRoZSBidWlsZCwg
d2h5IGRvIHlvdSB3YW50IGl0IHNwbGl0IG91dD8gIFRoaXMgbWFrZXMNCj4gc2Vuc2UgYWxsIGFz
IGEgc2luZ2xlIHBhdGNoIHRvIG1lLg0KPiANCg0KTm90IHJlYWxseS4NCkl0IHdvdWxkIGJlIGp1
c3QgYmUgdGhlIG5ldyBtYXRjaF9zdHJpbmcoKSBoZWxwZXIvbWFjcm8gaW4gYSBuZXcgY29tbWl0
Lg0KQW5kIHRoZSBjb252ZXJzaW9ucyBvZiB0aGUgc2ltcGxlIHVzZXJzIG9mIG1hdGNoX3N0cmlu
ZygpICh0aGUgb25lcyB1c2luZw0KQVJSQVlfU0laRSgpKSBpbiBhbm90aGVyIGNvbW1pdC4NCg0K
VGhhbmtzDQpBbGV4DQoNCj4gdGhhbmtzLA0KPiANCj4gZ3JlZyBrLWgNCg==

