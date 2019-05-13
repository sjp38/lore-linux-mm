Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4DC7C04AB4
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 07:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7034520C01
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 07:00:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="gDL7Mqp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7034520C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC6406B0005; Mon, 13 May 2019 03:00:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B76E56B0006; Mon, 13 May 2019 03:00:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17326B0007; Mon, 13 May 2019 03:00:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 518276B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 03:00:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f41so16537595ede.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 00:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=sYMxlTU42U8IEHuaefeXBUDbrbbRBESKyCojAVqw4Hs=;
        b=XFD99JnsKoB2VkJzTdQirLdVPq65IVQFfubM7aKgUJhh+nhQh5f6/RbDeoXdNeimIV
         fJ66yS9myPrVzGo25vsPrnAoIwibQ1f2jNE3PXqU5AHixoSR/CUZo7LDQK2HP0ubAGJU
         elzp+X0cwoCqWMcbHov/An7bR/gCsL7s5E36iqTE3kbbM/F4f1Ui0bYyUm6at9YR0Ln2
         86M5fPngZEU7ZPz/fddeM66pXJygs5oVmNf6rWnJYoWPzi1cTI8drUkhuUZtb0aZlwGd
         CFabnDNVnyBvJxfA92nvNp+3pTS1vNNN3iADK249cqhAFcfB8oKWFheHWYIq9vOlryMv
         ItZQ==
X-Gm-Message-State: APjAAAW77f30KNZtuMi2IyLR6c/ly2OVJj/m7r9Oksz3MO2d1iDAlPYi
	aCvRxnnC/xsLOP43uPbtHbiEEDQ+xQIDi4rE1X4wf+jMbZDfuBBGU6e2mz+9fi3/i4RLOdjalCL
	PjYpaBRm5SmQz/NO3rJ3Y5EzMbm/PNn36NwthQUHFP0s8S+slyW2KTw+sd8jVJIb7uw==
X-Received: by 2002:a17:906:3e85:: with SMTP id a5mr20561427ejj.272.1557730828618;
        Mon, 13 May 2019 00:00:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5G33UgxeDWvsuCcaNX04Z2ryJOAadjRCJ2iaq8nEgHUCGe+w/V4eKE1gwYvxw7yTeOJRx
X-Received: by 2002:a17:906:3e85:: with SMTP id a5mr20561347ejj.272.1557730827605;
        Mon, 13 May 2019 00:00:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557730827; cv=none;
        d=google.com; s=arc-20160816;
        b=A645IPFh9OAKrdqzcQjS+kLNnZKannLRaidC5YhnYstPHea/YLO9aRHuj7wGfMpGDd
         2VIqqZW0y+NP0iTA+yCGlVQmZnW+fcg1VHWs1T7vHCQQZ5w+htIhbauMM5bk3FFTS9Y0
         pYs0m7GCCMiBrjlkdgPfFprjz35PToE9lES4ymJF9H12sg64xdkjWp69skFF/a9E281h
         AjHSedVzTDM2/ACj8iQeK6undAl1g3ypboT4n95VcJAH9YpecwVjKkXaExetoGLVfOd+
         heRLQP9Xb40AhTpaW9UB7Vb+2umjVr3tC+Bl+9CuU1ividijZENt/AU1F+xZx61v1kvm
         tu/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=sYMxlTU42U8IEHuaefeXBUDbrbbRBESKyCojAVqw4Hs=;
        b=rn1Gr1qrIcFggBd3m4Ey/P0iymy4RfEAJmTtOegogEH++M2MBvhtvyYqZkhQz3+iG+
         3UqhD/DxVZYxbWO6gj90yOfO8to6cAkrsQ4OsyUfkSE7rLQa/+1eKUkxXBz7yNj6EFJ5
         KwbwsZGnhLInCIHfzjX6ORzEfpYXEc/gqhm8f3bKzAAvabGiTsy7sV70Vru2N1zK+04f
         LfYoswVqSpkWcToZ1zwcK8extQ629jReZKvJRLLYYtiNjzfgFS4W9UKl7R0Kp0/r/y9k
         dz/QWi7klZlESpsAneitdpdKDsftgHrsdPrfzUOnLhGJx5666bE1g85X+qosm1bT+WCe
         LqFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=gDL7Mqp4;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.51 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770051.outbound.protection.outlook.com. [40.107.77.51])
        by mx.google.com with ESMTPS id w9si1252903edt.395.2019.05.13.00.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 May 2019 00:00:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.51 as permitted sender) client-ip=40.107.77.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=gDL7Mqp4;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.51 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sYMxlTU42U8IEHuaefeXBUDbrbbRBESKyCojAVqw4Hs=;
 b=gDL7Mqp4cjHd9tnfv2Oc1qnpYT4Fac8j07kqzHoMV4t4fblqqvc/VaI9b3eW64VcLXIB/IIy6eJ2zPrMIPgV3ZayvIayU+ziMWE4G1SNhTClihPWWYWJfxAonZzDgMbLjip70cWFf6cVkIyteBkWBVFGb865vhK+yAGxY5lk4K0=
Received: from BY5PR03CA0029.namprd03.prod.outlook.com (2603:10b6:a03:1e0::39)
 by CY1PR03MB2265.namprd03.prod.outlook.com (2603:10b6:600:1::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1878.21; Mon, 13 May
 2019 07:00:23 +0000
Received: from CY1NAM02FT063.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::206) by BY5PR03CA0029.outlook.office365.com
 (2603:10b6:a03:1e0::39) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Mon, 13 May 2019 07:00:22 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 CY1NAM02FT063.mail.protection.outlook.com (10.152.75.161) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Mon, 13 May 2019 07:00:20 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x4D70JiL017961
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Mon, 13 May 2019 00:00:19 -0700
Received: from NWD2MBX7.ad.analog.com ([fe80::190e:f9c1:9a22:9663]) by
 NWD2HUBCAS7.ad.analog.com ([fe80::595b:ced1:cc03:539d%12]) with mapi id
 14.03.0415.000; Mon, 13 May 2019 03:00:19 -0400
From: "Ardelean, Alexandru" <alexandru.Ardelean@analog.com>
To: "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>
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
	<devel@driverdev.osuosl.org>, "linux-mtd@lists.infradead.org"
	<linux-mtd@lists.infradead.org>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "linux-fbdev@vger.kernel.org"
	<linux-fbdev@vger.kernel.org>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-tegra@vger.kernel.org"
	<linux-tegra@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "linux-rockchip@lists.infradead.org"
	<linux-rockchip@lists.infradead.org>, "alsa-devel@alsa-project.org"
	<alsa-devel@alsa-project.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-clk@vger.kernel.org"
	<linux-clk@vger.kernel.org>
Subject: Re: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Thread-Topic: [PATCH 03/16] lib,treewide: add new match_string() helper/macro
Thread-Index: AQHVBZFQXT7pBvOEwE+osXNwuBSvQKZhdwMAgAACFgCAAADdAIAC38WAgABZCYCABDgygA==
Date: Mon, 13 May 2019 07:00:18 +0000
Message-ID: <146ba7b61998d1e26cf2312fdaa01525d7c7d8de.camel@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
	 <20190508112842.11654-5-alexandru.ardelean@analog.com>
	 <20190508131128.GL9224@smile.fi.intel.com>
	 <20190508131856.GB10138@kroah.com>
	 <b2440bc9485456a7a90a488c528997587b22088b.camel@analog.com>
	 <4df165bc4247e60aa4952fd55cb0c77e60712767.camel@analog.com>
	 <20190510143407.GA9224@smile.fi.intel.com>
In-Reply-To: <20190510143407.GA9224@smile.fi.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.50.1.244]
x-adiroutedonprem: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <FDDE4955D460DC40AB641BB9139D6ABF@analog.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(396003)(346002)(39860400002)(136003)(376002)(2980300002)(189003)(199004)(51914003)(426003)(446003)(50466002)(436003)(126002)(2616005)(6246003)(2906002)(11346002)(336012)(8936002)(476003)(2351001)(246002)(186003)(356004)(26005)(316002)(86362001)(23676004)(5660300002)(305945005)(7636002)(5640700003)(70206006)(14444005)(4326008)(229853002)(106002)(2501003)(47776003)(2486003)(76176011)(14454004)(118296001)(54906003)(7736002)(3846002)(6916009)(8676002)(486006)(36756003)(6116002)(70586007)(478600001)(7696005)(102836004)(7416002)(142933001);DIR:OUT;SFP:1101;SCL:1;SRVR:CY1PR03MB2265;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 00d843ba-2114-4365-1750-08d6d770ab01
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328)(7193020);SRVR:CY1PR03MB2265;
X-MS-TrafficTypeDiagnostic: CY1PR03MB2265:
X-Microsoft-Antispam-PRVS:
	<CY1PR03MB2265347D2D5A29BD38B4EABBF90F0@CY1PR03MB2265.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-Forefront-PRVS: 0036736630
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	pqGW1MWQ3Zq088ZBBnRq58UtaiOWWrFuHBJi7VQpoJbSlJTml7IN0ZB79LgwW/q3coszuClL9TMb8LD8oKaWG7L67xaWLTLo4Dl5yXSxaYpBmG+Xog6/FxwkOZuU2IjOucWlNzpAFux6Mwb2L0fj7gBrNwwieeRaYqhwSdf06t/SMvTJASTiiAUu2AW4N7x6Xc6ahiqNZGT2RZlVmczozENjmdjvtvndvf2Dx+mGlM4/aQJY0WTqVMlcWs8jrF4ba/XFXGMyWvyAyH4V58N9E72j8+HxTQe7Yc0mkFuxWNDA0N0r9OC/7KnwHUj3pg1+Gx6dW22M8zWeA2xQJm1BF3xnZkV9zf9qWppJGAC5RZM2IO73HRpNW7spE2HNsspgIzH/VtLuyUQIVg7MbQ0TJO0gxLjUaCUyPM4+5bVRGLE=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 13 May 2019 07:00:20.8904
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 00d843ba-2114-4365-1750-08d6d770ab01
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY1PR03MB2265
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA1LTEwIGF0IDE3OjM0ICswMzAwLCBhbmRyaXkuc2hldmNoZW5rb0BsaW51
eC5pbnRlbC5jb20gd3JvdGU6DQo+IFtFeHRlcm5hbF0NCj4gDQo+IA0KPiBPbiBGcmksIE1heSAx
MCwgMjAxOSBhdCAwOToxNToyN0FNICswMDAwLCBBcmRlbGVhbiwgQWxleGFuZHJ1IHdyb3RlOg0K
PiA+IE9uIFdlZCwgMjAxOS0wNS0wOCBhdCAxNjoyMiArMDMwMCwgQWxleGFuZHJ1IEFyZGVsZWFu
IHdyb3RlOg0KPiA+ID4gT24gV2VkLCAyMDE5LTA1LTA4IGF0IDE1OjE4ICswMjAwLCBHcmVnIEtI
IHdyb3RlOg0KPiA+ID4gPiBPbiBXZWQsIE1heSAwOCwgMjAxOSBhdCAwNDoxMToyOFBNICswMzAw
LCBBbmR5IFNoZXZjaGVua28gd3JvdGU6DQo+ID4gPiA+ID4gT24gV2VkLCBNYXkgMDgsIDIwMTkg
YXQgMDI6Mjg6MjlQTSArMDMwMCwgQWxleGFuZHJ1IEFyZGVsZWFuDQo+ID4gPiA+ID4gd3JvdGU6
DQo+ID4gPiA+ID4gQ2FuIHlvdSBzcGxpdCBpbmNsdWRlL2xpbnV4LyBjaGFuZ2UgZnJvbSB0aGUg
cmVzdD8NCj4gPiA+ID4gDQo+ID4gPiA+IFRoYXQgd291bGQgYnJlYWsgdGhlIGJ1aWxkLCB3aHkg
ZG8geW91IHdhbnQgaXQgc3BsaXQgb3V0PyAgVGhpcw0KPiA+ID4gPiBtYWtlcw0KPiA+ID4gPiBz
ZW5zZSBhbGwgYXMgYSBzaW5nbGUgcGF0Y2ggdG8gbWUuDQo+ID4gPiA+IA0KPiA+ID4gDQo+ID4g
PiBOb3QgcmVhbGx5Lg0KPiA+ID4gSXQgd291bGQgYmUganVzdCBiZSB0aGUgbmV3IG1hdGNoX3N0
cmluZygpIGhlbHBlci9tYWNybyBpbiBhIG5ldw0KPiA+ID4gY29tbWl0Lg0KPiA+ID4gQW5kIHRo
ZSBjb252ZXJzaW9ucyBvZiB0aGUgc2ltcGxlIHVzZXJzIG9mIG1hdGNoX3N0cmluZygpICh0aGUg
b25lcw0KPiA+ID4gdXNpbmcNCj4gPiA+IEFSUkFZX1NJWkUoKSkgaW4gYW5vdGhlciBjb21taXQu
DQo+ID4gPiANCj4gPiANCj4gPiBJIHNob3VsZCBoYXZlIGFza2VkIGluIG15IHByZXZpb3VzIHJl
cGx5Lg0KPiA+IExlYXZlIHRoaXMgYXMtaXMgb3IgcmUtZm9ybXVsYXRlIGluIDIgcGF0Y2hlcyA/
DQo+IA0KPiBEZXBlbmRzIG9uIG9uIHdoYXQgeW91IHdvdWxkIGxpa2UgdG8gc3BlbmQgeW91ciB0
aW1lOiBjb2xsZWN0aW5nIEFja3MgZm9yDQo+IGFsbA0KPiBwaWVjZXMgaW4gdHJlZXdpZGUgcGF0
Y2ggb3Igc2VuZCBuZXcgQVBJIGZpcnN0IGZvbGxvd2VkIHVwIGJ5IHBlciBkcml2ZXINCj4gLw0K
PiBtb2R1bGUgdXBkYXRlIGluIG5leHQgY3ljbGUuDQoNCkkgYWN0dWFsbHkgd291bGQgaGF2ZSBw
cmVmZXJyZWQgbmV3IEFQSSBmaXJzdCwgd2l0aCB0aGUgY3VycmVudA0KYG1hdGNoX3N0cmluZygp
YCAtPiBgX19tYXRjaF9zdHJpbmcoKWAgcmVuYW1lIGZyb20gdGhlIHN0YXJ0LCBidXQgSSB3YXNu
J3QNCnN1cmUuIEkgYW0gc3RpbGwgbmF2aWdhdGluZyB0aHJvdWdoIGhvdyBmZWVkYmFja3MgYXJl
IHdvcmtpbmcgaW4gdGhpcw0KcmVhbG0uDQoNCkknbGwgc2VuZCBhIFYyIHdpdGggdGhlIEFQSSBj
aGFuZ2UtZmlyc3Qvb25seTsgc2hvdWxkIGJlIGEgc21hbGxlciBsaXN0Lg0KVGhlbiBzZWUgYWJv
dXQgZm9sbG93LXVwcy9jaGFuZ2VzIHBlciBzdWJzeXN0ZW1zLg0KDQo+IA0KPiBJIGFsc28gaGF2
ZSBubyBzdHJvbmcgcHJlZmVyZW5jZS4NCj4gQW5kIEkgdGhpbmsgaXQncyBnb29kIHRvIGFkZCBI
ZWlra2kgS3JvZ2VydXMgdG8gQ2MgbGlzdCBmb3IgYm90aCBwYXRjaA0KPiBzZXJpZXMsDQo+IHNp
bmNlIGhlIGlzIHRoZSBhdXRob3Igb2Ygc3lzZnMgdmFyaWFudCBhbmQgbWF5IGhhdmUgc29tZXRo
aW5nIHRvIGNvbW1lbnQNCj4gb24NCj4gdGhlIHJlc3QuDQoNClRoYW5rcyBmb3IgdGhlIHJlZmVy
ZW5jZS4NCg0KPiANCj4gLS0NCj4gV2l0aCBCZXN0IFJlZ2FyZHMsDQo+IEFuZHkgU2hldmNoZW5r
bw0KPiANCj4gDQo=

