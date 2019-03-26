Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9481EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 02:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36CB520823
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 02:21:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="hU11KZl2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36CB520823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5756B0006; Mon, 25 Mar 2019 22:21:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B65546B0007; Mon, 25 Mar 2019 22:21:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A53E06B0008; Mon, 25 Mar 2019 22:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53CFC6B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 22:21:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c41so4595594edb.7
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:21:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=2Qc3Ftt99F9FlhYO0ppub9xXnKGKsSXaM2HfHqlSz9E=;
        b=CkaNNoflAbaV/coQKrITLWwST+1WDvBhmFK688TQ0cEX+xaiNVXGCa2exriT1GrVuQ
         ayGQtuMOoPTP/9DaFLLkSisbgVMc3OZQ7HOKzySfbwMh8+FaFgjymovoeWDrCqfLHKoD
         HMt6Gm5J17ZKfRevlzDheGoAnrnQZFF3DD8GT7J5heSCl2WR/O/Iakug5YMh8/poah59
         Rf07qcn3LP+ssNHeXJEFQstn64PDfUgupRLz4oaXhAyHexqW/rNUWrYT1iACYVeV5pW+
         lSxDdVU8YqWieClJUrwb8lcDqBORxUSMO4WRoBzHFIhBZQSCXdwaG5LjYXAM94L4fx1i
         peeg==
X-Gm-Message-State: APjAAAXY/W7cbBjj6DuWSDdyUFTh0A8tzMVvUW+tbb4fNANzAoJ6dXJU
	RZhs/FW/KMu29R09T/GOfD4KC8RXIMxL7IP6aLBeydL12VTJmgPDagQfF3svyAvkCPg8lAUf0hZ
	BoGQRjTxc6gwSYLif3y9bUeW34fJBA6HVEpH00bLVk0NQIBeElP+cqKQ978UqUnU/Fw==
X-Received: by 2002:a50:8835:: with SMTP id b50mr18554176edb.262.1553566885882;
        Mon, 25 Mar 2019 19:21:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf2GmGFn5XzlluSFfxzpfc5hIIn1Oag7ao/hNrMbnxlW8PUJKYXZNW/vhnSOPAYNtFaDK8
X-Received: by 2002:a50:8835:: with SMTP id b50mr18554143edb.262.1553566884851;
        Mon, 25 Mar 2019 19:21:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553566884; cv=none;
        d=google.com; s=arc-20160816;
        b=yzYlcpeogHfB0QQD03lIER7GXL0sbVf4cTxYvi3PnfFETgLATBpT2xEfDMimct0Pwz
         j+CNklswUMmrY1oGEkRaEe2dqcr5R++ibp+S1XRrCz+RKZZEhXS4cZFqKNXQMjE+ZSXN
         vGV4xT9PRZPABe94uetruVlGSBaR2y6o2GM3Ns9CVVF+MPxKnRSkOKihoIT063P40u3d
         DXFNNmsG9lpvQek9lAtf2AcnlO25bzB3Ce9udX+5KU8QDsAp9B42ZaUumtcCUTwszSpL
         gJpdsvF+yQmMWqApPJRTaxYGz4eLwQbUG4F8sFcSkW89fp/G0yQ5sHuL585WeRu8MA8q
         BM2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=2Qc3Ftt99F9FlhYO0ppub9xXnKGKsSXaM2HfHqlSz9E=;
        b=XPzohqpNWQf4u79i7GvXCtx657nWxuVIgImCeTv+IWHzvqBOlgmV5umC8Suv+0ReZe
         wpMllSC2rszi4enqOB7zgUUi1BMUZchix1MdtFxK+Wi6V/FMaNpFSyPppLCcbgI1aNuH
         f0ywJzKa2Ygky6rlzrPDVbXv8MUuuhJWfMFqFFKYDZ0iLnkxWIJZ/36VK/zu7My/nCA2
         i1dW+X2oJYKq9a5YjWxrxoXicwJFCEaO965WnRKKfzYbvofRkOXaevFyShzQ+AaRRsGn
         AAoSX8a2+vdZuc34uCw8LXUJvopJE67DeKQzmLtyJpC/KULAKb1o4mSf5s3NtZSaY4iE
         /7SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=hU11KZl2;
       spf=pass (google.com: domain of peter.chen@nxp.com designates 40.107.14.74 as permitted sender) smtp.mailfrom=peter.chen@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140074.outbound.protection.outlook.com. [40.107.14.74])
        by mx.google.com with ESMTPS id r1si331570eju.280.2019.03.25.19.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Mar 2019 19:21:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of peter.chen@nxp.com designates 40.107.14.74 as permitted sender) client-ip=40.107.14.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=hU11KZl2;
       spf=pass (google.com: domain of peter.chen@nxp.com designates 40.107.14.74 as permitted sender) smtp.mailfrom=peter.chen@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2Qc3Ftt99F9FlhYO0ppub9xXnKGKsSXaM2HfHqlSz9E=;
 b=hU11KZl2TZJzgdUPprtj1o+WsqA4CK9JkmXlvK0lXUxe2aBeFLIJGynul0Y9nJ3VyWJw8Ccr/lFua5pEgd84g5jWKe8Y7Ump/MaYGl/Qa+s7T5oSVKUXMH+r8ud9rMSI1diMmbobLLHPTvXO6mQfRjR41gjKuB8Y7gdWGRAW1js=
Received: from VI1PR04MB5327.eurprd04.prod.outlook.com (20.177.52.16) by
 VI1PR04MB3294.eurprd04.prod.outlook.com (10.170.231.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Tue, 26 Mar 2019 02:21:22 +0000
Received: from VI1PR04MB5327.eurprd04.prod.outlook.com
 ([fe80::6462:e965:413a:e1c1]) by VI1PR04MB5327.eurprd04.prod.outlook.com
 ([fe80::6462:e965:413a:e1c1%3]) with mapi id 15.20.1730.019; Tue, 26 Mar 2019
 02:21:22 +0000
From: Peter Chen <peter.chen@nxp.com>
To: Florian Fainelli <f.fainelli@gmail.com>, Russell King - ARM Linux admin
	<linux@armlinux.org.uk>, Peter Chen <hzpeterchen@gmail.com>
CC: Michal Nazarewicz <mina86@mina86.com>, Andy Duan <fugang.duan@nxp.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>, lkml
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, Marek Szyprowski
	<m.szyprowski@samsung.com>
Subject: RE: Why CMA allocater fails if there is a signal pending?
Thread-Topic: Why CMA allocater fails if there is a signal pending?
Thread-Index: AQHU4uX43sLiG5DSx062fdc8KJ7nyKYcJKOAgABpioCAAJ6gYA==
Date: Tue, 26 Mar 2019 02:21:22 +0000
Message-ID:
 <VI1PR04MB5327DE30DCECAD65554F64018B5F0@VI1PR04MB5327.eurprd04.prod.outlook.com>
References:
 <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
 <20190325102633.v6hkvda6q7462wza@shell.armlinux.org.uk>
 <7905eeb4-51ce-956b-31ed-33313bcfe7eb@gmail.com>
In-Reply-To: <7905eeb4-51ce-956b-31ed-33313bcfe7eb@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peter.chen@nxp.com; 
x-originating-ip: [119.31.174.66]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 54c324d3-bf1b-4aaa-4e85-08d6b191bda4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR04MB3294;
x-ms-traffictypediagnostic: VI1PR04MB3294:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR04MB3294CA4CCC3C879A0DF7502A8B5F0@VI1PR04MB3294.eurprd04.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(346002)(136003)(366004)(376002)(396003)(189003)(199004)(71190400001)(71200400001)(76176011)(54906003)(81166006)(229853002)(305945005)(14444005)(81156014)(52536014)(9686003)(53936002)(6306002)(7696005)(966005)(105586002)(256004)(106356001)(7736002)(33656002)(186003)(446003)(11346002)(14454004)(8676002)(6116002)(3846002)(6246003)(66066001)(68736007)(53546011)(6506007)(5660300002)(486006)(26005)(478600001)(102836004)(476003)(45080400002)(99286004)(4326008)(6436002)(110136005)(8936002)(25786009)(316002)(86362001)(2906002)(74316002)(44832011)(97736004)(55016002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR04MB3294;H:VI1PR04MB5327.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 YWiZK7ZowB3SwLfpwiwuuV8DoHhl3UXGRDfnFvPcbglueR8DUstS4nyAaRgB1XrWYW5RgNRhguYzpPrD6HC3mvhjhLyZSUAAbenv3gl5lCPJhmzrPw0/+TfuXVbQ+gi+lIXpxyCkEe7ExVkfniQpTJpKj4gyqjgjaCGzJd3BnXEzsdLLMlf0UYJw+FTbnxXdrYoilI4XyDsoYiq3yDrYrueZgvrhjP5d7C4rIKxbyQ2J1uRi0A6BITT/uGcEG0CRciRoaLIfxaNZhvzFPBQAZ0/nEFbWyGAT5ZIANtGl4K91et4nhddOIL66nQ/EqrMRuK7LJbKMkmHDpYdrDaaCOtQ4hOi+5ryNahNknSNEw8lUw9apm73cbjl9QttLzlCCHzTByJjpA+bzanW1J3tIq6vfVH+ImFDifpjUOBpt3dI=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 54c324d3-bf1b-4aaa-4e85-08d6b191bda4
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 02:21:22.8419
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR04MB3294
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

IA0KPiANCj4gT24gMy8yNS8xOSAzOjI2IEFNLCBSdXNzZWxsIEtpbmcgLSBBUk0gTGludXggYWRt
aW4gd3JvdGU6DQo+ID4gT24gTW9uLCBNYXIgMjUsIDIwMTkgYXQgMDQ6Mzc6MDlQTSArMDgwMCwg
UGV0ZXIgQ2hlbiB3cm90ZToNCj4gPj4gSGkgTWljaGFsICYgTWFyZWssDQo+ID4+DQo+ID4+IEkg
bWVldCBhbiBpc3N1ZSB0aGF0IHRoZSBETUEgKENNQSB1c2VkKSBhbGxvY2F0aW9uIGZhaWxlZCBp
ZiB0aGVyZSBpcw0KPiA+PiBhIHVzZXIgc2lnbmFsLCBFZyBDdHJsK0MsIGl0IGNhdXNlcyB0aGUg
VVNCIHhIQ0kgc3RhY2sgZmFpbHMgdG8NCj4gPj4gcmVzdW1lIGR1ZSB0byBkbWFfYWxsb2NfY29o
ZXJlbnQgZmFpbGVkLiBJdCBjYW4gYmUgZWFzeSB0byByZXByb2R1Y2UNCj4gPj4gaWYgdGhlIHVz
ZXIgcHJlc3MgQ3RybCtDIGF0IHN1c3BlbmQvcmVzdW1lIHRlc3QuDQo+ID4NCj4gPiBJdCBoYXMg
YmVlbiBwb3NzaWJsZSBpbiB0aGUgcGFzdCBmb3IgY21hX2FsbG9jKCkgdG8gdGFrZSBzZWNvbmRz
IG9yDQo+ID4gbG9uZ2VyIHRvIGFsbG9jYXRlLCBkZXBlbmRpbmcgb24gdGhlIHNpemUgb2YgdGhl
IENNQSBhcmVhIGFuZCB0aGUNCj4gPiBudW1iZXIgb2YgcGlubmVkIEdGUF9NT1ZBQkxFIHBhZ2Vz
IHdpdGhpbiB0aGUgQ01BIGFyZWEuICBXaGV0aGVyIHRoYXQNCj4gPiBpcyB0cnVlIG9mIHRvZGF5
J3MgQ01BIG9yIG5vdCwgSSBkb24ndCBrbm93Lg0KPiA+DQo+ID4gSXQncyBwcm9iYWJseSB0aGVy
ZSB0byBhbGxvdyBzdWNoIGEgc2l0dWF0aW9uIHRvIGJlIHJlY292ZXJhYmxlLCBidXQNCj4gPiBp
cyBub3QgYSBnb29kIGlkZWEgaWYgd2UncmUgZXhwZWN0aW5nIGRtYV9hbGxvY18qKCkgbm90IHRv
IGZhaWwgaW4NCj4gPiB0aG9zZSBzY2VuYXJpb3MuDQo+ID4NCj4gDQo+IFRoaXMgaXMgYSBrbm93
biBpc3N1ZSB0aGF0IHdhcyBkaXNjdXNzZWQgaGVyZSBiZWZvcmU6DQo+IA0KPiBodHRwczovL2V1
cjAxLnNhZmVsaW5rcy5wcm90ZWN0aW9uLm91dGxvb2suY29tLz91cmw9aHR0cCUzQSUyRiUyRmxp
c3RzLmluZnJhZGVhZC4NCj4gb3JnJTJGcGlwZXJtYWlsJTJGbGludXgtYXJtLWtlcm5lbCUyRjIw
MTQtDQo+IE5vdmVtYmVyJTJGMjk5MjY1Lmh0bWwmYW1wO2RhdGE9MDIlN0MwMSU3Q3BldGVyLmNo
ZW4lNDBueHAuY29tJTdDZg0KPiBlODVmNmZmYTkyZDQyZWIxYjcyMDhkNmIxNDEyNWQyJTdDNjg2
ZWExZDNiYzJiNGM2ZmE5MmNkOTljNWMzMDE2MzUlNw0KPiBDMCU3QzAlN0M2MzY4OTEyOTA2OTYw
MzMyNjgmYW1wO3NkYXRhPWY3JTJGODVXejglMkJwOGlEYmxwZ3JwM1c4DQo+IEZmdzBiclVwZFU3
eDNyZFppQ212YyUzRCZhbXA7cmVzZXJ2ZWQ9MA0KPiANCj4gb25lIGlzc3VlIGlzIHRoYXQgdGhl
IHByb2Nlc3MgdGhhdCBpcyByZXNwb25zaWJsZSBmb3IgcHV0dGluZyB0aGUgc3lzdGVtIGFzbGVl
cCBhbmQgaXMNCj4gYmVpbmcgcmVzdW1lZCAod2hpY2ggY2FuIGJlIGFzIHNpbXBsZSBhcyB5b3Vy
IHNoZWxsIGRvaW5nIGFuICdlY2hvICJzdGFuZGJ5IiA+DQo+IC9zeXMvcG93ZXIvc3RhdGUnIGNh
biBiZSBraWxsZWQsIGFuZCB0aGF0IHByb3BhZ2F0ZXMgdGhyb3VnaG91dCBkcG1fcmVzdW1lKCku
IEl0IGlzDQo+IGRlYmF0YWJsZSB3aGV0aGVyIHRoZSBzaWduYWwgc2hvdWxkIGJlIGlnbm9yZWQg
b3Igbm90LCBwcm9iYWJseSBub3QuDQo+IA0KPiBZb3UgY2FuIHdvcmsgYXJvdW5kIHRoaXMgYnkg
d3JhcHBpbmcgeW91ciBlY2hvIHRvIC9zeXMvcG93ZXIvc3RhdGUgd2l0aCBhIHNoZWxsDQo+IHNj
cmlwdCB0aGF0IHRyYXAgdGhlIHNpZ25hbCBhbmQgc2F5LCBkb2VzIGFuIGV4aXQgMS4gQUZBSVIg
dGhlcmUgYXJlIG1hbnkgcGxhY2VzDQo+IHdoZXJlIGEgZG1hX2FsbG9jXyogYWxsb2NhdGlvbiBj
YW4gZmFpbCwgYW5kIG5vdCBhbGwgZHJpdmVycyBhcmUgZGVzaWduZWQgdG8gcmVjb3Zlcg0KPiBj
b3JyZWN0bHkuDQogDQpUaGFua3MsIEZsb3JpYW4uDQoNClRoaXMgd29ya2Fyb3VuZCBjYW4ndCB3
b3JrIHNpbmNlIHRoZSBrZXJuZWwgY2FwdHVyZWQgdGhpcyBzaWduYWwgSU5UIGFmdGVyIHRoZQ0K
ZnJlZXphYmxlIHRhc2tzIGFyZSBmcm96ZW4sIGFuZCB3aGVuIHRoZSByZXN1bWUgYmFja3MsIHRo
ZSBkcml2ZXIncyByZXN1bWUNCnJ1biBiZWZvcmUgZnJlZXphYmxlIGFwcGxpY2F0aW9uIChlY2hv
IG1lbSA+IC9zeXMvcG93ZXIvc3RhdGUpLiBJIGFkZGVkDQpjYXB0dXJlZCBjb2RlIGF0IHNjcmlw
dCwgeW91IGNvdWxkIGZpbmQgaXQgYXQgdGhlIGxhc3Qgb3V0cHV0Lg0KDQpydGN3YWtldXAub3V0
OiB3YWtldXAgZnJvbSAibWVtIiB1c2luZyBydGMwIGF0IEZyaSBGZWIgMjIgMjE6NDI6MTQgMjAx
OQ0KWyAgNTk0LjcyODMzOF0gUE06IHN1c3BlbmQgZW50cnkgKGRlZXApDQpbICA1OTQuNzMxOTcw
XSBQTTogU3luY2luZyBmaWxlc3lzdGVtcyAuLi4gZG9uZS4NClsgIDU5NC43NDAyNzJdIEZyZWV6
aW5nIHVzZXIgc3BhY2UgcHJvY2Vzc2VzIC4uLiAoZWxhcHNlZCAwLjAwMSBzZWNvbmRzKSBkb25l
Lg0KWyAgNTk0Ljc0ODc1MV0gT09NIGtpbGxlciBkaXNhYmxlZC4NClsgIDU5NC43NTE5OTVdIEZy
ZWV6aW5nIHJlbWFpbmluZyBmcmVlemFibGUgdGFza3MgLi4uIChlbGFwc2VkIDAuMDAxIHNlY29u
ZHMpIGRvbmUuDQpbICA1OTQuNzYwNjYwXSBTdXNwZW5kaW5nIGNvbnNvbGUocykgKHVzZSBub19j
b25zb2xlX3N1c3BlbmQgdG8gZGVidWcpDQpeQ15DXkNbICA1OTUuNDM3MTEzXSBQTTogc3VzcGVu
ZCBkZXZpY2VzIHRvb2sgMC42NzIgc2Vjb25kcw0KWyAgNTk1LjQ1MDY0N10gRGlzYWJsaW5nIG5v
bi1ib290IENQVXMgLi4uDQpbICA1OTUuNDY0NTkwXSBDUFUxOiBzaHV0ZG93bg0KWyAgNTk1LjQ2
NDU5N10gcHNjaTogQ1BVMSBraWxsZWQuDQpbICA1OTUuNDg4NDkzXSBDUFUyOiBzaHV0ZG93bg0K
WyAgNTk1LjUwNzgzMV0gcHNjaTogUmV0cnlpbmcgYWdhaW4gdG8gY2hlY2sgZm9yIENQVSBraWxs
DQpbICA1OTUuNTA3ODM1XSBwc2NpOiBDUFUyIGtpbGxlZC4NClsgIDU5NS41MjQ0MjNdIENQVTM6
IHNodXRkb3duDQpbICA1OTUuNTQzODIxXSBwc2NpOiBSZXRyeWluZyBhZ2FpbiB0byBjaGVjayBm
b3IgQ1BVIGtpbGwNClsgIDU5NS41NDM4MjZdIHBzY2k6IENQVTMga2lsbGVkLg0KWyAgNTk1LjU0
NDI0N10gZmFpbCB0byBwb3dlciBvbiByZXNvdXJjZSAyODkNClsgIDU5NS41NDQyNzddIEVuYWJs
aW5nIG5vbi1ib290IENQVXMgLi4uDQpbICA1OTUuNTQ1MDQ2XSBEZXRlY3RlZCBWSVBUIEktY2Fj
aGUgb24gQ1BVMQ0KWyAgNTk1LjU0NTA3M10gR0lDdjM6IENQVTE6IGZvdW5kIHJlZGlzdHJpYnV0
b3IgMSByZWdpb24gMDoweDAwMDAwMDAwNTFiMjAwMDANClsgIDU5NS41NDUxMTNdIENQVTE6IEJv
b3RlZCBzZWNvbmRhcnkgcHJvY2Vzc29yIFs0MTBmZDA0Ml0NClsgIDU5NS41NDU3NDldICBjYWNo
ZTogcGFyZW50IGNwdTEgc2hvdWxkIG5vdCBiZSBzbGVlcGluZw0KWyAgNTk1LjU0NTk1Nl0gQ1BV
MSBpcyB1cA0KWyAgNTk1LjU0NjY1NF0gRGV0ZWN0ZWQgVklQVCBJLWNhY2hlIG9uIENQVTINClsg
IDU5NS41NDY2NzNdIEdJQ3YzOiBDUFUyOiBmb3VuZCByZWRpc3RyaWJ1dG9yIDIgcmVnaW9uIDA6
MHgwMDAwMDAwMDUxYjQwMDAwDQpbICA1OTUuNTQ2Njk4XSBDUFUyOiBCb290ZWQgc2Vjb25kYXJ5
IHByb2Nlc3NvciBbNDEwZmQwNDJdDQpbICA1OTUuNTQ3MDM2XSAgY2FjaGU6IHBhcmVudCBjcHUy
IHNob3VsZCBub3QgYmUgc2xlZXBpbmcNClsgIDU5NS41NDcyMTNdIENQVTIgaXMgdXANClsgIDU5
NS41NDc5MTBdIERldGVjdGVkIFZJUFQgSS1jYWNoZSBvbiBDUFUzDQpbICA1OTUuNTQ3OTI3XSBH
SUN2MzogQ1BVMzogZm91bmQgcmVkaXN0cmlidXRvciAzIHJlZ2lvbiAwOjB4MDAwMDAwMDA1MWI2
MDAwMA0KWyAgNTk1LjU0Nzk1M10gQ1BVMzogQm9vdGVkIHNlY29uZGFyeSBwcm9jZXNzb3IgWzQx
MGZkMDQyXQ0KWyAgNTk1LjU0ODI5M10gIGNhY2hlOiBwYXJlbnQgY3B1MyBzaG91bGQgbm90IGJl
IHNsZWVwaW5nDQpbICA1OTUuNTQ4NDkwXSBDUFUzIGlzIHVwDQpbICA1OTYuNTExMDUyXSB1c2Ig
dXNiMTogcm9vdCBodWIgbG9zdCBwb3dlciBvciB3YXMgcmVzZXQNClsgIDU5Ni41MTEwNjBdIHVz
YiB1c2IyOiByb290IGh1YiBsb3N0IHBvd2VyIG9yIHdhcyByZXNldA0KWyAgNTk2LjUxMzMwMl0g
Y21hOiBjbWFfYWxsb2M6IGFsbG9jIGZhaWxlZCwgcmVxLXNpemU6IDEgcGFnZXMsIHJldDogLTQN
ClsgIDU5Ni43MjM5MTNdIGh1YiAxLTA6MS4wOiBodWJfZXh0X3BvcnRfc3RhdHVzIGZhaWxlZCAo
ZXJyID0gLTMyKQ0KWyAgNTk2LjcyMzkxN10gaHViIDItMDoxLjA6IGh1Yl9leHRfcG9ydF9zdGF0
dXMgZmFpbGVkIChlcnIgPSAtMzIpDQpbICA1OTYuNzI0MDEwXSBodWIgMi0wOjEuMDogaHViX2V4
dF9wb3J0X3N0YXR1cyBmYWlsZWQgKGVyciA9IC0zMikNClsgIDU5Ni43MjQwNDRdIHVzYiB1c2Iy
LXBvcnQxOiBjYW5ub3QgZGlzYWJsZSAoZXJyID0gLTMyKQ0KWyAgNTk2LjcyNzYwMF0gUE06IHJl
c3VtZSBkZXZpY2VzIHRvb2sgMS4xNTYgc2Vjb25kcw0KWyAgNTk2Ljg4NzE2NF0gT09NIGtpbGxl
ciBlbmFibGVkLg0KWyAgNTk2Ljg5MDMzN10gUmVzdGFydGluZyB0YXNrcyAuLi4gZG9uZS4NClsg
IDU5Ni44OTc4OTNdIFBNOiBzdXNwZW5kIGV4aXQNCnNpZ25hbCBJTlQgcmVjZWl2ZWQsIHNjcmlw
dCBlbmRpbmcNCg0KUGV0ZXINCg==

