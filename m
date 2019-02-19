Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA5C5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DC7521479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:38:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="GUqSmhc2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DC7521479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1498E0003; Tue, 19 Feb 2019 13:38:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A52218E0002; Tue, 19 Feb 2019 13:38:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9412A8E0003; Tue, 19 Feb 2019 13:38:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22A358E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:38:48 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so3961171edm.18
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:38:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=tYlLzMG2PNPj3O81YCrCIulvZ0Gw13H105iKSt8GvGw=;
        b=Ar9lPbj9Adgq+lWtz1eFtIDGgbU5B6lvVW79tRysvVattfKRqnWSTppbRcI7iQpI/b
         R9MlGJ30tEKRTBb7GIriTM/nfqEmT8Gj1LdXH/yuNz1wGIVvXlGqxKhqb8EMH3E9bQIW
         CszdDpwVJ8OS60cItsLpc7rMuFMzRP9YrjevSMulDS0Ji3zfYzVC4Rxad9kKdSJ0vtrL
         CIkzaj5G57kWMHNmCORLaMp1rPJPL+cAT9Gcf7WeOpbGkKb6/0jahZK5oWsl1MhVWOkP
         91a292csfFVXOIf3RSe6DsRlTG8mBKaGhSc2wntnCVvoGsFaekLk1YCWIjgrUWezxT6d
         NHWQ==
X-Gm-Message-State: AHQUAuZKbIPK41MLsSqovGYdAijR5OuaFR+XM5JWzr1onTIR/EsMkkJB
	jkKUxCrGwXPmwx1E5He+VQ7PeNtD/loMNQ1OkICKowZt1cGKPrytmA8rZXqm0CX5R1adJWM9nUS
	Tb2y77wT9uUllIwtIvGb4O1E3Lf+nhq+O5GY69Zlx/sMw1YbmY26uPcDm25I7lvXvJw==
X-Received: by 2002:a50:86cf:: with SMTP id 15mr24129630edu.239.1550601527432;
        Tue, 19 Feb 2019 10:38:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYs2aNDAyJF41DL4CVuITkIqhC5E9w1etv+IaO9fL43Fp/23fb0byiCyE4KYlbHZ6T0gop4
X-Received: by 2002:a50:86cf:: with SMTP id 15mr24129555edu.239.1550601525968;
        Tue, 19 Feb 2019 10:38:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550601525; cv=none;
        d=google.com; s=arc-20160816;
        b=D2oZpzvr11OtzrQjY0kakVpKkkQ2LAnMZw0eO5IoMgGi92of26xGAXLNOhtsOzol1z
         bCkgvvxOGAa/bsysVUQ+mCaJ6JvLDX7JyTEQUWLVOCIBvmazlPjoohgQNRQ6AH6/2gk1
         8ojHWYrQCkVA/qfFyRKdexni3ECnxwVxg+iTdtziVi0GF1V/alEzSEzer8Ey4efkyg+i
         u4ken1X41kEDe/YF2XTf35FyBlJmYcMPKgH8jiwzLr2uVe2OA+coxu57XVQxNtwVy6SR
         /+LqJkOE+0i4ssxQYFQmCJ1BBFa0vWL3KjhQImEj8b3s6XrvmxF7jZl5osqPruSfgHXA
         T6Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=tYlLzMG2PNPj3O81YCrCIulvZ0Gw13H105iKSt8GvGw=;
        b=dtGgMF9RcOCwXF32Aasb8n0Eptc2cPuJ50nnNAAH7cIize4GQ3Z4OgiyfMT3x/yzlQ
         hDN67Mp0JDrA/amiiJ12TrdVGNt8bU1TDLP1ASYBRY4L2hLI4UvW5b4qWNiD4R/z1/IB
         lG8OI+NFTcrhe94PQ0ywMKHeLRc0UPAf0+OJZET1UCURj6LoReavN8GQOiWazvhEeLa+
         lWCf17FDazbD0/2YdUYsZSurKjtO+ELLBZxN7PuTD6QRrz4AXogxBSmhm0X3i9Ax6FLg
         LBKrFe7ZebMSqI/1HD1qBcENFM5jHYed6ksPTDcYdPHqTLzzM33QG/UPDQNW7VHYtWPH
         gFYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=GUqSmhc2;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.2.61 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20061.outbound.protection.outlook.com. [40.107.2.61])
        by mx.google.com with ESMTPS id 5si3926923ejn.67.2019.02.19.10.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 10:38:45 -0800 (PST)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.2.61 as permitted sender) client-ip=40.107.2.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=GUqSmhc2;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.2.61 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tYlLzMG2PNPj3O81YCrCIulvZ0Gw13H105iKSt8GvGw=;
 b=GUqSmhc2n5XFdrGkeMSbOHTIKb5WZCMLhGvSK+9eRti3nHWLZH3hRp78djTijQOCkdFQerj0Zey0Ak5CZLE5FMEPJijeOOGl2WtKcz2JYb/ByL2+wVmGuHQ0zl4omsbhOlGDM9ir5mefPNGgxpkXHzioezei3Dow0/N7GXjpbo8=
Received: from DB7PR08MB4217.eurprd08.prod.outlook.com (20.178.47.91) by
 DB7PR08MB3484.eurprd08.prod.outlook.com (20.176.238.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.19; Tue, 19 Feb 2019 18:38:31 +0000
Received: from DB7PR08MB4217.eurprd08.prod.outlook.com
 ([fe80::483e:afa9:c9f:9db8]) by DB7PR08MB4217.eurprd08.prod.outlook.com
 ([fe80::483e:afa9:c9f:9db8%4]) with mapi id 15.20.1622.018; Tue, 19 Feb 2019
 18:38:31 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>, Evgenii Stepanov
	<eugenis@google.com>
CC: nd <nd@arm.com>, Kevin Brodsky <Kevin.Brodsky@arm.com>, Dave P Martin
	<Dave.Martin@arm.com>, Mark Rutland <Mark.Rutland@arm.com>, Kate Stewart
	<kstewart@linuxfoundation.org>, "open list:DOCUMENTATION"
	<linux-doc@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Linux Memory
 Management List <linux-mm@kvack.org>, "open list:KERNEL SELFTEST FRAMEWORK"
	<linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>,
	Vincenzo Frascino <Vincenzo.Frascino@arm.com>, Shuah Khan <shuah@kernel.org>,
	Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>,
	Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan
	<Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee
 Smith <Lee.Smith@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux
 ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany
	<kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML
	<linux-kernel@vger.kernel.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Ramana Radhakrishnan
	<Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <Robin.Murphy@arm.com>, Luc Van Oostenryck
	<luc.vanoostenryck@gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Thread-Topic: [RFC][PATCH 0/3] arm64 relaxed ABI
Thread-Index: AQHUyFD8LSHMwEYo7kaikjJNt8xTtqXnc/kA
Date: Tue, 19 Feb 2019 18:38:31 +0000
Message-ID: <ac8f4e3b-84b8-6067-6a7a-fac7dc48daea@arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
In-Reply-To: <20190212180223.GD199333@arrakis.emea.arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.53]
x-clientproxiedby: LO2P265CA0412.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a0::16) To DB7PR08MB4217.eurprd08.prod.outlook.com
 (2603:10a6:10:7d::27)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3accbe23-3152-4a43-2dba-08d69699721d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DB7PR08MB3484;
x-ms-traffictypediagnostic: DB7PR08MB3484:
nodisclaimer: True
x-microsoft-exchange-diagnostics:
 1;DB7PR08MB3484;20:9Bej0nFFovYFcJcFVUiuDiv//aiNT46KfwhUSVSDIWQxMykDduOqsJ3i+UND2FX24/2chMACX/g7qc5761SVnrrQQZ4PJNMBu9W9JiCDp58ekIb+e8mwcWnWg+2hvVBhJ4mLYiBDCzRW8HDCnMxaj85TLv+OiMWqOGKXGfH57NM=
x-microsoft-antispam-prvs:
 <DB7PR08MB34848F48BEF9C64FA1D148DCED7C0@DB7PR08MB3484.eurprd08.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(979002)(39860400002)(366004)(346002)(376002)(396003)(136003)(199004)(189003)(478600001)(14454004)(3846002)(65826007)(106356001)(25786009)(105586002)(2906002)(68736007)(6116002)(7416002)(26005)(5660300002)(8936002)(6506007)(386003)(14444005)(186003)(72206003)(256004)(102836004)(30864003)(64126003)(6486002)(53546011)(229853002)(446003)(93886005)(97736004)(44832011)(11346002)(476003)(2616005)(81166006)(81156014)(8676002)(76176011)(305945005)(66066001)(52116002)(486006)(7736002)(110136005)(58126008)(65956001)(316002)(561944003)(65806001)(36756003)(6436002)(54906003)(99286004)(4326008)(31696002)(6512007)(31686004)(53936002)(71200400001)(6246003)(71190400001)(86362001)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR08MB3484;H:DB7PR08MB4217.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 yjk0JL+f75i8Kv65h6t96hFo+Cupa6OpgM+2BIGOMYiS12A7BkuGNukrKdPxyZ6A/3rmxsKRZIEVvEJQRiFJVl3Hf9jKOJo9wSZm6E3taCoooiBC+qY1kwU7lb0vLngJIhfY6+yGVq1hi1/6i9ShywBU50n0ZaXRbQjN4jPIO30ZpmZkqGx7Txnp4uw2ujos9GVPb7zkHwiVtPifPmTGNFrZG9LwLF1YutINiIbOZns7sNGTmCHgUXfc8UpEJnb0xhm0BH/zi0C6cP90eMDeZ2m0yGCI332kO25dXzQybRrvr0lq8FwJSiSHsmJJpwtE/bT27A8LXYx7juwKZJHJSGtj8u2Lz+8RH5VDeCsD6SRKmIFVhwubBsy5+IUIjW+ADMhrP3l2Wg3k11AXjOnb2Xkm0KKaEdfd+HbBghuqGno=
Content-Type: text/plain; charset="utf-8"
Content-ID: <D09BD30AAA68A44CAF812C33404D843E@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3accbe23-3152-4a43-2dba-08d69699721d
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 18:38:29.8254
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3484
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMTIvMDIvMjAxOSAxODowMiwgQ2F0YWxpbiBNYXJpbmFzIHdyb3RlOg0KPiBPbiBNb24sIEZl
YiAxMSwgMjAxOSBhdCAxMjozMjo1NVBNIC0wODAwLCBFdmdlbmlpIFN0ZXBhbm92IHdyb3RlOg0K
Pj4gT24gTW9uLCBGZWIgMTEsIDIwMTkgYXQgOToyOCBBTSBLZXZpbiBCcm9kc2t5IDxrZXZpbi5i
cm9kc2t5QGFybS5jb20+IHdyb3RlOg0KPj4+IE9uIDE5LzEyLzIwMTggMTI6NTIsIERhdmUgTWFy
dGluIHdyb3RlOg0KPj4+PiBSZWFsbHksIHRoZSBrZXJuZWwgc2hvdWxkIGRvIHRoZSBleHBlY3Rl
ZCB0aGluZyB3aXRoIGFsbCAibm9uLXdlaXJkIg0KPj4+PiBtZW1vcnkuDQo+Pj4+DQo+Pj4+IElu
IGxpZXUgb2YgYSBwcm9wZXIgZGVmaW5pdGlvbiBvZiAibm9uLXdlaXJkIiwgSSB0aGluayB3ZSBz
aG91bGQgaGF2ZQ0KPj4+PiBzb21lIGxpc3RzIG9mIHRoaW5ncyB0aGF0IGFyZSBleHBsaWNpdGx5
IGluY2x1ZGVkLCBhbmQgYWxzbyBleGNsdWRlZDoNCj4+Pj4NCj4+Pj4gT0s6DQo+Pj4+ICAgICAg
IGtlcm5lbC1hbGxvY2F0ZWQgcHJvY2VzcyBzdGFjaw0KPj4+PiAgICAgICBicmsgYXJlYQ0KPj4+
PiAgICAgICBNQVBfQU5PTllNT1VTIHwgTUFQX1BSSVZBVEUNCj4+Pj4gICAgICAgTUFQX1BSSVZB
VEUgbWFwcGluZ3Mgb2YgL2Rldi96ZXJvDQo+Pj4+DQo+Pj4+IE5vdCBPSzoNCj4+Pj4gICAgICAg
TUFQX1NIQVJFRA0KPj4+PiAgICAgICBtbWFwcyBvZiBub24tbWVtb3J5LWxpa2UgZGV2aWNlcw0K
Pj4+PiAgICAgICBtbWFwcyBvZiBhbnl0aGluZyB0aGF0IGlzIG5vdCBhIHJlZ3VsYXIgZmlsZQ0K
Pj4+PiAgICAgICB0aGUgVkRTTw0KPj4+PiAgICAgICAuLi4NCj4+Pj4NCj4+Pj4gSW4gZ2VuZXJh
bCwgdXNlcnNwYWNlIGNhbiB0YWcgbWVtb3J5IHRoYXQgaXQgIm93bnMiLCBhbmQgd2UgZG8gbm90
IGFzc3VtZQ0KPj4+PiBhIHRyYW5zZmVyIG9mIG93bmVyc2hpcCBleGNlcHQgaW4gdGhlICJPSyIg
bGlzdCBhYm92ZS4gIE90aGVyd2lzZSwgaXQncw0KPj4+PiB0aGUga2VybmVsJ3MgbWVtb3J5LCBv
ciB0aGUgb3duZXIgaXMgc2ltcGx5IG5vdCB3ZWxsIGRlZmluZWQuDQo+Pj4NCj4+PiBBZ3JlZWQg
b24gdGhlIGdlbmVyYWwgaWRlYTogYSBwcm9jZXNzIHNob3VsZCBiZSBhYmxlIHRvIHBhc3MgdGFn
Z2VkIHBvaW50ZXJzIGF0IHRoZQ0KPj4+IHN5c2NhbGwgaW50ZXJmYWNlLCBhcyBsb25nIGFzIHRo
ZXkgcG9pbnQgdG8gbWVtb3J5IHByaXZhdGVseSBvd25lZCBieSB0aGUgcHJvY2Vzcy4gSQ0KPj4+
IHRoaW5rIGl0IHdvdWxkIGJlIHBvc3NpYmxlIHRvIHNpbXBsaWZ5IHRoZSBkZWZpbml0aW9uIG9m
ICJub24td2VpcmQiIG1lbW9yeSBieSB1c2luZw0KPj4+IG9ubHkgdGhpcyAiT0siIGxpc3Q6DQo+
Pj4gLSBtbWFwKCkgZG9uZSBieSB0aGUgcHJvY2VzcyBpdHNlbGYsIHdoZXJlIGVpdGhlcjoNCj4+
PiAgICAqIGZsYWdzID0gTUFQX1BSSVZBVEUgfCBNQVBfQU5PTllNT1VTDQo+Pj4gICAgKiBmbGFn
cyA9IE1BUF9QUklWQVRFIGFuZCBmZCByZWZlcnMgdG8gYSByZWd1bGFyIGZpbGUgb3IgYSB3ZWxs
LWRlZmluZWQgbGlzdCBvZg0KPj4+IGRldmljZSBmaWxlcyAobGlrZSAvZGV2L3plcm8pDQo+Pj4g
LSBicmsoKSBkb25lIGJ5IHRoZSBwcm9jZXNzIGl0c2VsZg0KPj4+IC0gQW55IG1lbW9yeSBtYXBw
ZWQgYnkgdGhlIGtlcm5lbCBpbiB0aGUgbmV3IHByb2Nlc3MncyBhZGRyZXNzIHNwYWNlIGR1cmlu
ZyBleGVjdmUoKSwNCj4+PiB3aXRoIHRoZSBzYW1lIHJlc3RyaWN0aW9ucyBhcyBhYm92ZSAoW3Zk
c29dL1t2dmFyXSBhcmUgdGhlcmVmb3JlIGV4Y2x1ZGVkKQ0KPiANCj4gU291bmRzIHJlYXNvbmFi
bGUuDQoNCk9LLiB0aGlzIG5vbi13ZWlyZCBtZW1vcnkgZGVmaW5pdGlvbiB3b3JrcyBmb3IgbWUg
dG9vLg0KDQpydWxlIDE6IGlmIHdlaXJkIG1lbW9yeSBwb2ludGVycyBhcmUgcGFzc2VkIHRvIHRo
ZSBrZXJuZWwNCndpdGggdG9wIGJ5dGUgc2V0IHRoZW4gdGhlIGJlaGF2aW91ciBpcyB1bmRlZmlu
ZWQuDQoNCj4+Pj4gICAqIFdoZW4gdGhlIGtlcm5lbCBkZXJlZmVyZW5jZXMgYSBwb2ludGVyIG9u
IHVzZXJzcGFjZSdzIGJlaGFsZiwgaXQNCj4+Pj4gICAgIHNoYWxsIGJlaGF2ZSBlcXVpdmFsZW50
bHkgdG8gdXNlcnNwYWNlIGRlcmVmZXJlbmNpbmcgdGhlIHNhbWUgcG9pbnRlciwNCj4+Pj4gICAg
IGluY2x1ZGluZyB1c2Ugb2YgdGhlIHNhbWUgdGFnICh3aGVyZSBwYXNzZWQgYnkgdXNlcnNwYWNl
KS4NCj4+Pj4NCj4+Pj4gICAqIFdoZXJlIHRoZSBwb2ludGVyIHRhZyBhZmZlY3RzIHBvaW50ZXIg
ZGVyZWZlcmVuY2UgYmVoYXZpb3VyIChpLmUuLA0KPj4+PiAgICAgd2l0aCBoYXJkd2FyZSBtZW1v
cnkgY29sb3VyaW5nKSB0aGUga2VybmVsIG1ha2VzIG5vIGd1YXJhbnRlZSB0bw0KPj4+PiAgICAg
aG9ub3VyIHBvaW50ZXIgdGFncyBjb3JyZWN0bHkgZm9yIGV2ZXJ5IGxvY2F0aW9uIGEgYnVmZmVy
IGJhc2VkIG9uIGENCj4+Pj4gICAgIHBvaW50ZXIgcGFzc2VkIGJ5IHVzZXJzcGFjZSB0byB0aGUg
a2VybmVsLg0KPj4+Pg0KPj4+PiAgICAgKFRoaXMgbWVhbnMgZm9yIGV4YW1wbGUgdGhhdCBmb3Ig
YSByZWFkKGZkLCBidWYsIHNpemUpLCB3ZSBjYW4gY2hlY2sNCj4+Pj4gICAgIHRoZSB0YWcgZm9y
IGEgc2luZ2xlIGFyYml0cmFyeSBsb2NhdGlvbiBpbiAqKGNoYXIgKCopW3NpemVdKWJ1Zg0KPj4+
PiAgICAgYmVmb3JlIHBhc3NpbmcgdGhlIGJ1ZmZlciB0byBnZXRfdXNlcl9wYWdlcygpLiAgSG9w
ZWZ1bGx5IHRoaXMgY291bGQNCj4+Pj4gICAgIGJlIGRvbmUgaW4gZ2V0X3VzZXJfcGFnZXMoKSBp
dHNlbGYgcmF0aGVyIHRoYW4gaHVudGluZyBjYWxsIHNpdGVzLg0KPj4+PiAgICAgRm9yIHVzZXJz
cGFjZSwgaXQgbWVhbnMgdGhhdCB5b3UncmUgb24geW91ciBvd24gaWYgeW91IGFzayB0aGUNCj4+
Pj4gICAgIGtlcm5lbCB0byBvcGVyYXRlIG9uIGEgYnVmZmVyIHRoYW4gc3BhbnMgbXVsdGlwbGUs
IGluZGVwZW5kZW50bHktDQo+Pj4+ICAgICBhbGxvY2F0ZWQgb2JqZWN0cywgb3IgYSBkZWxpYmVy
YXRlbHkgc3RyaXBlZCBzaW5nbGUgb2JqZWN0LikNCj4+Pg0KPj4+IEkgdGhpbmsgYm90aCBwb2lu
dHMgYXJlIHJlYXNvbmFibGUuIEl0IGlzIHZlcnkgdmFsdWFibGUgZm9yIHRoZSBrZXJuZWwgdG8g
YWNjZXNzDQo+Pj4gdXNlcnNwYWNlIG1lbW9yeSB1c2luZyB0aGUgdXNlci1wcm92aWRlZCB0YWcs
IGJlY2F1c2UgaXQgZW5hYmxlcyBrZXJuZWwgYWNjZXNzZXMgdG8NCj4+PiBiZSBjaGVja2VkIGlu
IHRoZSBzYW1lIHdheSBhcyB1c2VyIGFjY2Vzc2VzLCBhbGxvd2luZyB0byBkZXRlY3QgYnVncyB0
aGF0IGFyZQ0KPj4+IHBvdGVudGlhbGx5IGhhcmQgdG8gZmluZC4gRm9yIGluc3RhbmNlLCBpZiBh
IHBvaW50ZXIgdG8gYW4gb2JqZWN0IGlzIHBhc3NlZCB0byB0aGUNCj4+PiBrZXJuZWwgYWZ0ZXIg
aXQgaGFzIGJlZW4gZGVhbGxvY2F0ZWQsIHRoaXMgaXMgaW52YWxpZCBhbmQgc2hvdWxkIGJlIGRl
dGVjdGVkLg0KPj4+IEhvd2V2ZXIsIHlvdSBhcmUgYWJzb2x1dGVseSByaWdodCB0aGF0IHRoZSBr
ZXJuZWwgY2Fubm90ICpndWFyYW50ZWUqIHRoYXQgc3VjaCBhDQo+Pj4gY2hlY2sgaXMgY2Fycmll
ZCBvdXQgZm9yIHRoZSBlbnRpcmUgbWVtb3J5IHJhbmdlIChvciBpbiBmYWN0IGF0IGFsbCk7IGl0
IHNob3VsZCBiZSBhDQo+Pj4gYmVzdC1lZmZvcnQgYXBwcm9hY2guDQo+Pg0KPj4gSXQgd291bGQg
YWxzbyBiZSB2YWx1YWJsZSB0byBuYXJyb3cgZG93biB0aGUgc2V0IG9mICJyZWxheGVkIiAoaS5l
Lg0KPj4gbm90IHRhZy1jaGVja2luZykgc3lzY2FsbHMgYXMgcmVhc29uYWJseSBwb3NzaWJsZS4g
V2Ugd291bGQgd2FudCB0bw0KPj4gcHJvdmlkZSB0YWctY2hlY2tpbmcgdXNlcnNwYWNlIHdyYXBw
ZXJzIGZvciBhbnkgaW1wb3J0YW50IGNhbGxzIHRoYXQNCj4+IGFyZSBub3QgY2hlY2tlZCBpbiB0
aGUga2VybmVsLiBJcyBpdCBjb3JyZWN0IHRvIGFzc3VtZSB0aGF0IGFueXRoaW5nDQo+PiB0aGF0
IGdvZXMgdGhyb3VnaCBjb3B5X2Zyb21fdXNlciAgLyBjb3B5X3RvX3VzZXIgaXMgY2hlY2tlZD8N
Cj4gDQo+IEkgbG9zdCB0cmFjayBvZiB0aGUgY29udGV4dCBvZiB0aGlzIHRocmVhZCBidXQgaWYg
aXQncyBqdXN0IGFib3V0DQo+IHJlbGF4aW5nIHRoZSBBQkkgZm9yIGh3YXNhbiwgdGhlIGtlcm5l
bCBoYXMgbm8gaWRlYSBvZiB0aGUgY29tcGlsZXINCj4gZ2VuZXJhdGVkIHN0cnVjdHVyZXMgaW4g
dXNlciBzcGFjZSwgc28gbm90aGluZyBpcyBjaGVja2VkLg0KPiANCj4gSWYgd2UgdGFsayBhYm91
dCB0YWdzIGluIHRoZSBjb250ZXh0IG9mIE1URSwgdGhhbiB5ZXMsIHdpdGggdGhlIGN1cnJlbnQN
Cj4gcHJvcG9zYWwgdGhlIHRhZyB3b3VsZCBiZSBjaGVja2VkIGJ5IGNvcHlfKl91c2VyKCkgZnVu
Y3Rpb25zLg0KDQpydWxlIDI6IGtlcm5lbCBkZXJlZnMgYXMgaWYgdXNlciBkZXJlZnMgd2hlbiBu
b24td2VpcmQgbWVtb3J5DQpwb2ludGVycyBhcmUgcGFzc2VkIHRvIHRoZSBrZXJuZWwuDQoNCm5v
dGUgdGhhdCB0aGUgaW1wb3J0YW50IGJpdCBpcyB3aGF0IGhhcHBlbnMgb24gdmFsaWQgcG9pbnRl
cg0KZGVyZWZzLCBpbnZhbGlkIHBvaW50ZXIgZGVyZWYgaXMgdXN1YWxseSB1bmRlZmluZWQgZm9y
IHVzZXINCnByb2dyYW1zLCBzbyB3aGF0IGhhcHBlbnMgaW4gY2FzZSBvZiBtdGUgdGFnIGZhaWx1
cmVzIGlzDQptb3JlIG9mIGEgUW9JIGlzc3VlIHRoYW4gYWJpIGkgdGhpbmsuDQoNCihlLmcuIEVG
QVVMVCBpcyBub3QgZ3VhcmFudGVlZCBieSB0aGUga2VybmVsIGN1cnJlbnRseSwgaSBjYW4NCnN1
Y2Nlc3NmdWxseSBkbyB3cml0ZShvcGVuKCIvZGV2L251bGwiLE9fV1JPTkxZKSwgMCwgMSksIG9y
DQpnZXQgYSBjcmFzaCB3aGVuIHBhc3NpbmcgaW52YWxpZCBwb2ludGVyIHRvIGEgdmRzbyBmdW5j
dGlvbiwNCnNvIHVzZXJzcGFjZSBzaG91bGQgbm90IHJlbHkgb24gc29tZSBzdHJpY3QgRUZBVUxU
IGJlaGF2aW91cikuDQoNCj4+Pj4gICAqIFRoZSBrZXJuZWwgc2hhbGwgbm90IGV4dGVuZCB0aGUg
bGlmZXRpbWUgb2YgdXNlciBwb2ludGVycyBpbiB3YXlzDQo+Pj4+ICAgICB0aGF0IGFyZSBub3Qg
Y2xlYXIgZnJvbSB0aGUgc3BlY2lmaWNhdGlvbiBvZiB0aGUgc3lzY2FsbCBvcg0KPj4+PiAgICAg
aW50ZXJmYWNlIHRvIHdoaWNoIHRoZSBwb2ludGVyIGlzIHBhc3NlZCAoYW5kIGluIGFueSBjYXNl
IHNoYWxsIG5vdA0KPj4+PiAgICAgZXh0ZW5kIHBvaW50ZXIgbGlmZXRpbWVzIHdpdGhvdXQgZ29v
ZCByZWFzb24pLg0KPj4+Pg0KPj4+PiAgICAgU28gbm8gY2xldmVyIHRyYW5zcGFyZW50IGNhY2hp
bmcgYmV0d2VlbiBzeXNjYWxscywgdW5sZXNzIGl0IF9yZWFsbHlfDQo+Pj4+ICAgICBpcyB0cmFu
c3BhcmVudCBpbiB0aGUgcHJlc2VuY2Ugb2YgdGFncy4NCj4+Pg0KPj4+IERvIHlvdSBoYXZlIGFu
eSBwYXJ0aWN1bGFyIGNhc2UgaW4gbWluZD8gSWYgc3VjaCBjYWNoaW5nIGlzIHJlYWxseSB2YWx1
YWJsZSwgaXQgaXMNCj4+PiBhbHdheXMgcG9zc2libGUgdG8gYWNjZXNzIHRoZSBvYmplY3Qgd2hp
bGUgaWdub3JpbmcgdGhlIHRhZy4gRm9yIHN1cmUsIHRoZQ0KPj4+IHVzZXItcHJvdmlkZWQgdGFn
IGNhbiBvbmx5IGJlIHVzZWQgZHVyaW5nIHRoZSBzeXNjYWxsIGhhbmRsaW5nIGl0c2VsZiwgbm90
DQo+Pj4gYXN5bmNocm9ub3VzbHkgbGF0ZXIgb24sIHVubGVzcyBvdGhlcndpc2Ugc3BlY2lmaWVk
Lg0KPj4NCj4+IEZvciBhaW8qIG9wZXJhdGlvbnMgaXQgd291bGQgYmUgbmljZSBpZiB0aGUgdGFn
IHdhcyBjaGVja2VkIGF0IHRoZQ0KPj4gdGltZSBvZiB0aGUgYWN0dWFsIHVzZXJzcGFjZSByZWFk
L3dyaXRlLCBlaXRoZXIgaW5zdGVhZCBvZiBvciBpbg0KPj4gYWRkaXRpb24gdG8gYXQgdGhlIHRp
bWUgb2YgdGhlIHN5c3RlbSBjYWxsLg0KPiANCj4gV2l0aCBhaW8qIChhbmQgc3luY2hyb25vdXMg
aW92ZWMtYmFzZWQgc3lzY2FsbHMpLCB0aGUga2VybmVsIG1heSBhY2Nlc3MNCj4gdGhlIG1lbW9y
eSB3aGlsZSB0aGUgY29ycmVzcG9uZGluZyB1c2VyIHByb2Nlc3MgaXMgc2NoZWR1bGVkIG91dC4g
R2l2ZW4NCj4gdGhhdCBzdWNoIGFjY2VzcyBpcyBub3QgZG9uZSBpbiB0aGUgY29udGV4dCBvZiB0
aGUgdXNlciBwcm9jZXNzIChhbmQNCj4gdXNpbmcgdGhlIHVzZXIgVkEgbGlrZSBjb3B5XypfdXNl
ciksIHRoZSBrZXJuZWwgY2Fubm90IGhhbmRsZSBwb3RlbnRpYWwNCj4gdGFnIGZhdWx0cy4gTW9y
ZW92ZXIsIHRoZSB0cmFuc2ZlciBtYXkgYmUgZG9uZSBieSBETUEgYW5kIHRoZSBkZXZpY2UNCj4g
ZG9lcyBub3QgdW5kZXJzdGFuZCB0YWdzLg0KPiANCj4gSSdkIGxpa2UgdG8ga2VlcCB0YWdzIGFz
IGEgcHJvcGVydHkgb2YgdGhlIHBvaW50ZXIgaW4gYSBzcGVjaWZpYyB2aXJ0dWFsDQo+IGFkZHJl
c3Mgc3BhY2UuIFRoZSBtb21lbnQgeW91IGNvbnZlcnQgaXQgdG8gYSBkaWZmZXJlbnQgYWRkcmVz
cyBzcGFjZQ0KPiAoZS5nLiBrZXJuZWwgbGluZWFyIG1hcCwgcGh5c2ljYWwgYWRkcmVzcyksIHRo
ZSB0YWcgcHJvcGVydHkgaXMgc3RyaXBwZWQNCj4gYW5kIEkgZG9uJ3QgdGhpbmsgd2Ugc2hvdWxk
IHJlLWJ1aWxkIGl0IChhbmQgaGF2ZSBpdCBjaGVja2VkKS4NCg0KT0suDQoNCmkgZG9uJ3QgdGhp
bmsgdGhlIG5ldyBhYmkgbmVlZHMgc3BlY2lhbCBydWxlcyBhYm91dA0KcG9pbnRlciBsaWZldGlt
ZS4NCg0KPj4+PiAgICogRm9yIHB1cnBvc2VzIG90aGVyIHRoYW4gZGVyZWZlcmVuY2UsIHRoZSBr
ZXJuZWwgc2hhbGwgYWNjZXB0IGFueQ0KPj4+PiAgICAgbGVnaXRpbWF0ZWx5IHRhZ2dlZCBwb2lu
dGVyIChhY2NvcmRpbmcgdG8gdGhlIGFib3ZlIHJ1bGVzKSBhcw0KPj4+PiAgICAgaWRlbnRpZnlp
bmcgdGhlIGFzc29jaWF0ZWQgbWVtb3J5IGxvY2F0aW9uLg0KPj4+Pg0KPj4+PiAgICAgU28sIG1w
cm90ZWN0KHNvbWVfcGFnZV9hbGlnbmVkX29iamVjdCwgLi4uKTsgaXMgdmFsaWQgaXJyZXNwZWN0
aXZlDQo+Pj4+ICAgICBvZiB3aGVyZSBwYWdlX2FsaWduZWRfb2JqZWN0KCkgY2FtZSBmcm9tLiAg
VGhlcmUgaXMgbm8gaW1wbGljaXQNCj4+Pj4gICAgIGRlcmVmZW5jZSBieSB0aGUga2VybmVsIGhl
cmUsIGhlbmNlIG5vIHRhZyBjaGVjay4NCj4+Pj4NCj4+Pj4gICAgIFRoZSBrZXJuZWwgZG9lcyBu
b3QgZ3VhcmFudGVlIHRvIHdvcmsgY29ycmVjdGx5IGlmIHRoZSB3cm9uZyB0YWcNCj4+Pj4gICAg
IGlzIHVzZWQsIGJ1dCB0aGVyZSBpcyBub3QgYWx3YXlzIGEgd2VsbC1kZWZpbmVkICJyaWdodCIg
dGFnLCBzbw0KPj4+PiAgICAgd2UgY2FuJ3QgcmVhbGx5IGd1YXJhbnRlZSB0byBjaGVjayBpdC4g
IFNvIGEgcG9pbnRlciBkZXJpdmVkIGJ5DQo+Pj4+ICAgICBhbnkgcmVhc29uYWJsZSBtZWFucyBi
eSB1c2Vyc3BhY2UgaGFzIHRvIGJlIHRyZWF0ZWQgYXMgZXF1YWxseQ0KPj4+PiAgICAgdmFsaWQu
DQo+Pj4NCj4+PiBUaGlzIGlzIGEgZGlzcHV0ZWQgcG9pbnQgOikgSW4gbXkgb3BpbmlvbiwgdGhp
cyBpcyB0aGUgdGhlIG1vc3QgcmVhc29uYWJsZSBhcHByb2FjaC4NCj4+DQo+PiBZZXMsIGl0IHdv
dWxkIGJlIG5pY2UgaWYgdGhlIGtlcm5lbCBleHBsaWNpdGx5IHByb21pc2VkLCBleC4NCj4+IG1w
cm90ZWN0KCkgb3ZlciBhIHJhbmdlIG9mIGRpZmZlcmVudGx5IHRhZ2dlZCBwYWdlcyB0byBiZSBh
bGxvd2VkDQo+PiAoaS5lLiBhZGRyZXNzIHRhZyBzaG91bGQgYmUgdW5jaGVja2VkKS4NCj4gDQo+
IEkgZG9uJ3QgdGhpbmsgbXByb3RlY3QoKSBvdmVyIGRpZmZlcmVudGx5IHRhZ2dlZCBwYWdlcyB3
YXMgZXZlciBhDQo+IHByb2JsZW0uIEkgb3JpZ2luYWxseSBhc2tlZCB0aGF0IG1wcm90ZWN0KCkg
YW5kIGZyaWVuZHMgZG8gbm90IGFjY2VwdA0KPiB0YWdnZWQgcG9pbnRlcnMgc2luY2UgdGhlc2Ug
ZnVuY3Rpb25zIGRlYWwgd2l0aCBtZW1vcnkgcmFuZ2VzIHJhdGhlcg0KPiB0aGFuIGRlcmVmZXJl
bmNpbmcgc3VjaCBwb2ludGVyICh0aGUgcmVhc29uIGJlaW5nIG1pbmltYWwga2VybmVsDQo+IGNo
YW5nZXMpLiBIb3dldmVyLCBnaXZlbiBob3cgY29tcGxpY2F0ZWQgaXQgaXMgdG8gc3BlY2lmeSBh
biBBQkksIEkgY2FtZQ0KPiB0byB0aGUgY29uY2x1c2lvbiB0aGF0IGEgcG9pbnRlciBwYXNzZWQg
dG8gc3VjaCBmdW5jdGlvbiBzaG91bGQgYmUNCj4gYWxsb3dlZCB0byBoYXZlIG5vbi16ZXJvIHRv
cCBieXRlLiBJdCB3b3VsZCBiZSB0aGUga2VybmVsJ3MNCj4gcmVzcG9uc2liaWxpdHkgdG8gc3Ry
aXAgaXQgb3V0IGFzIGFwcHJvcHJpYXRlLg0KDQpPSy4NCg0KcnVsZSAzOiBrZXJuZWwgYWNjZXB0
cyBsZWdpdGltYXRlbHkgdGFnZ2VkIG5vbi13ZWlyZCBtZW1vcnkNCnBvaW50ZXJzIGFuZCB1bnRh
Z3MgdGhlbSBiZWZvcmUgdXNhZ2Ugb3RoZXIgdGhhbiBkZXJlZi4NCg0KdGhpcyBpcyByZWxldmFu
dCBpZiBhIHN5c2NhbGwgdXNlcyBwb2ludGVycyBmb3IgYWRkcmVzcyByYW5nZQ0Kc3BlY2lmaWNh
dGlvbiwgaW5zdGVhZCBvZiBkZXJlZi4gKG1wcm90ZWN0LCBtYWR2aXNlLC4uLikNCg0KaSBhbHNv
IHByb3Bvc2U6DQoNCnJ1bGUgNDoga2VybmVsIGtlZXBzIGxlZ2l0aW1hdGUgdGFncyBvbiBub24t
d2VpcmQgbWVtb3J5DQpwb2ludGVycyB0aGF0IGl0IHJldHVybnMgdG8gdGhlIHVzZXIuDQoNCmUu
Zy4gY2xvbmUgcGFzc2VzIHN0YWNrL2FyZy90bHMgcG9pbnRlcnMgb24gd2l0aG91dCBkcm9wcGlu
Zw0KdGFncywgc2FtZSBmb3Igc2V0L2dldF9yb2J1c3RfbGlzdC4gaSdtIG5vdCBzdXJlIGlmIHRo
ZXJlDQphcmUgcG9pbnRlciB2YWx1ZXMgb2JzZXJ2YWJsZSBpbiAvcHJvYyBldGMgYnV0IHRob3Nl
IHNob3VsZA0Ka2VlcCB0YWdzIHRvby4NCg0KImxlZ2l0aW1hdGVseSB0YWdnZWQiIG1heSBub3Qg
YWx3YXlzIGJlIG9idmlvdXMsIGJ1dCB0aGUNCmlsbGVnaXRpbWF0ZWx5IHRhZ2dlZCBjYXNlIGNh
biBiZSBsZWZ0IHVuc3BlY2lmaWVkIGkgdGhpbmssDQpzbyBkcm9wcGluZyB0YWdzIGlzIG9rLCBi
dXQgbm90IHJlcXVpcmVkIGlmIHRiaSBpcyBvZmYgYW5kDQptdGUgaXMgbm90IHVzZWQgKGkuZS4g
dGFnIGlzIGlsbGVnaXRpbWF0ZSkuDQoNCmkgdGhpbmsgdGhlc2UgcnVsZXMgd29yayBmb3IgdGhl
IGNhc2VzIGkgY2FyZSBhYm91dCwgYSBtb3JlDQp0cmlja3kgcXVlc3Rpb24gaXMgd2hlbi9ob3cg
dG8gY2hlY2sgZm9yIHRoZSBuZXcgc3lzY2FsbCBhYmkNCmFuZCB3aGVuL2hvdyB0aGUgVENSX0VM
MS5UQkkwIHNldHRpbmcgbWF5IGJlIHR1cm5lZCBvZmYuDQpjb25zaWRlciB0aGUgZm9sbG93aW5n
IGNhc2VzICh0YiA9PSB0b3AgYnl0ZSk6DQoNCmJpbmFyeSAxOiB1c2VyIHRiID0gYW55LCBzeXNj
YWxsIHRiID0gMA0KICB0YmkgaXMgb24sICJsZWdhY3kgYmluYXJ5Ig0KDQpiaW5hcnkgMjogdXNl
ciB0YiA9IGFueSwgc3lzY2FsbCB0YiA9IGFueQ0KICB0YmkgaXMgb24sICJuZXcgYmluYXJ5IHVz
aW5nIHRiIg0KICBmb3IgYmFja3dhcmQgY29tcGF0IGl0IG5lZWRzIHRvIGNoZWNrIGZvciBuZXcg
c3lzY2FsbCBhYmkuDQoNCmJpbmFyeSAzOiB1c2VyIHRiID0gMCwgc3lzY2FsbCB0YiA9IDANCiAg
dGJpIGNhbiBiZSBvZmYsICJuZXcgYmluYXJ5IiwNCiAgYmluYXJ5IGlzIG1hcmtlZCB0byBpbmRp
Y2F0ZSB1bnVzZWQgdGIsDQogIGtlcm5lbCBtYXkgdHVybiB0Ymkgb2ZmOiBhZGRpdGlvbmFsIHBh
YyBiaXRzLg0KDQpiaW5hcnkgNDogdXNlciB0YiA9IG10ZSwgc3lzY2FsbCB0YiA9IG10ZQ0KICBs
aWtlIGJpbmFyeSAzLCBidXQgd2l0aCBtdGUsICJuZXcgYmluYXJ5IHVzaW5nIG10ZSINCiAgZG9l
cyBpdCBoYXZlIHRvIGNoZWNrIGZvciBuZXcgc3lzY2FsbCBhYmk/DQogIG9yIE1URSBIV0NBUCB3
b3VsZCBpbXBseSBpdD8NCiAgKGlzIGl0IHBvc3NpYmxlIHRvIHVzZSBtdGUgd2l0aG91dCBuZXcg
c3lzY2FsbCBhYmk/KQ0KDQppbiB1c2Vyc3BhY2Ugd2Ugd2FudCBtb3N0IGJpbmFyaWVzIHRvIGJl
IGxpa2UgYmluYXJ5IDMgYW5kIDQNCmV2ZW50dWFsbHksIGkuZS4gbWFya2VkIGFzIG5vdC1yZWx5
aW5nLW9uLXRiaSwgaWYgYSBkc28gaXMNCmxvYWRlZCB0aGF0IGlzIHVubWFya2VkIChsZWdhY3kg
b3IgbmV3IHRiIHVzZXIpLCB0aGVuIGVpdGhlcg0KdGhlIGxvYWQgZmFpbHMgKGUuZy4gaWYgbXRl
IGlzIGFscmVhZHkgdXNlZD8gb3IgY2FuIHdlIHR1cm4NCm10ZSBvZmYgYXQgcnVudGltZT8pIG9y
IHRiaSBoYXMgdG8gYmUgZW5hYmxlZCAocHJjdGw/IGRvZXMNCnRoaXMgd29yayB3aXRoIHBhYz8g
b3IgbXVsdGktdGhyZWFkcz8pLg0KDQphcyBmb3IgY2hlY2tpbmcgdGhlIG5ldyBzeXNjYWxsIGFi
aTogaSBkb24ndCBzZWUgbXVjaCBzZW1hbnRpYw0KZGlmZmVyZW5jZSBiZXR3ZWVuIEFUX0hXQ0FQ
IGFuZCBBVF9GTEFHUyAoZWl0aGVyIHdheSwgdGhlIHVzZXINCmhhcyB0byBjaGVjayBhIGZlYXR1
cmUgZmxhZyBiZWZvcmUgdXNpbmcgdGhlIGZlYXR1cmUgb2YgdGhlDQp1bmRlcmx5aW5nIHN5c3Rl
bSBhbmQgaXQgZG9lcyBub3QgbWF0dGVyIG11Y2ggaWYgaXQncyBhIHN5c2NhbGwNCmFiaSBmZWF0
dXJlIG9yIGNwdSBmZWF0dXJlKSwgYnV0IGkgZG9uJ3Qgc2VlIGFueXRoaW5nIHdyb25nDQp3aXRo
IEFUX0ZMQUdTIGlmIHRoZSBrZXJuZWwgcHJlZmVycyB0aGF0Lg0KDQp0aGUgZGlzY3Vzc2lvbiBo
ZXJlIHdhcyBtb3N0bHkgYWJvdXQgYmluYXJ5IDIsIGJ1dCBmb3INCm1lIHRoZSBvcGVuIHF1ZXN0
aW9uIGlzIGlmIHdlIGNhbiBtYWtlIGJpbmFyeSAzLzQgd29yay4NCih3aGljaCByZXF1aXJlcyBz
b21lIGVsZiBiaW5hcnkgbWFya2luZywgdGhhdCBpcyByZWNvZ25pc2VkDQpieSB0aGUga2VybmVs
IGFuZCBkeW5hbWljIGxvYWRlciwgYW5kIGVmZmljaWVudCBoYW5kbGluZyBvZg0KdGhlIFRCSTAg
Yml0LCAuLmlmIGl0J3Mgbm90IHBvc3NpYmxlLCB0aGVuIGkgZG9uJ3Qgc2VlIGhvdw0KbXRlIHdp
bGwgYmUgZGVwbG95ZWQpLg0KDQphbmQgaSBndWVzcyBvbiB0aGUga2VybmVsIHNpZGUgdGhlIG9w
ZW4gcXVlc3Rpb24gaXMgaWYgdGhlDQpydWxlcyAxLzIvMy80IGNhbiBiZSBtYWRlIHRvIHdvcmsg
aW4gY29ybmVyIGNhc2VzIGUuZy4gd2hlbg0KcG9pbnRlcnMgZW1iZWRkZWQgaW50byBzdHJ1Y3Rz
IGFyZSBwYXNzZWQgZG93biBpbiBpb2N0bC4NCg==

