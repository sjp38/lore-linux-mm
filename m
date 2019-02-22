Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52FF8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:10:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7EC20818
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:10:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="K0XGkZ+A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7EC20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7378E0119; Fri, 22 Feb 2019 11:10:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3969F8E0109; Fri, 22 Feb 2019 11:10:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25FAF8E0119; Fri, 22 Feb 2019 11:10:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC6DA8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:10:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id j5so1120979edt.17
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:10:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=BwbmA6QUpC/PUB8yG4wMDwColQTEWt5sncKQ3NY5zp4=;
        b=BrizTK2sHg/LLb9JUVmNcyUodsyehAukJGHsCFGapg9k3qL79uyjZ3osww2/TSWsSl
         pHkc4IXdwzxY6m3jRBHOnJqDi93veuw2wJHBw9RHjRySzbCNfji557wgT8sU8hwBhu0g
         qKldU0WbdZniDKdCtc0BzAZ/qZCpaFekolsLudX7Ja0DlBYqP5IjV+GlYLy1Fzsy9VTm
         HOmaRV30RXyk16UbCCt+TqmakRgsHILL74/ksSHzg5sUNuB30y/P9VSqCgcQ1lfWIlyZ
         91HDbi7umJvqPdNJFU7wbdO4wAjx+M2vvzwDzlxNOe2XGSaXQBRVIrlzAHpsxJ4ocjrm
         H9NQ==
X-Gm-Message-State: AHQUAubgM+OAqKYM63404ri6krp5RZui92KQomrgMaIlbjBue4nPqC/l
	8IhW+ulXEqf5FP+mkDN38lpr1e//iL82wfqDsAEHzo0bAZnKrqYD3khfSaGTV7pxOuqIzHwhm35
	CRd5Xa93nDVNT9t6pL0EmWunctF8qeAAySluCPHXUcBwMft/w50NQ1pv/jR2/VpqgmA==
X-Received: by 2002:a50:f5ea:: with SMTP id x39mr3871435edm.154.1550851832014;
        Fri, 22 Feb 2019 08:10:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibw6m+Fd5mlr7dVdoTXv/dTTup37r/CXWSWD8ooMkwmElYc9ZcvjUGcgb7B+uAmraOy7uSg
X-Received: by 2002:a50:f5ea:: with SMTP id x39mr3871341edm.154.1550851830735;
        Fri, 22 Feb 2019 08:10:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550851830; cv=none;
        d=google.com; s=arc-20160816;
        b=OViqNG4aVyBPKavfAR1QBwTA9GYPs+O96w7wZel21Qx94cJ4KnaLBcTZm+0l3LBri7
         8R4iGH3MDn0ufRc/H14g3WtC/FMLGQDcd59GZP8SufFltWdhihhNfwM7jV0cxOJem/rp
         6odFNHhFYhH0Nj5rA7RATyi+CvEAIsdPNISMgvjSw4Q3mv81zxyvf7FKrm5UphqsQtOc
         +i1hYv1SsTyfpWfwjXIyVq34ce/t7vaOiE4Qfximw711roFYEVhxlKf5OgqGc/GjK55c
         eB4HkHMa524zlZP2tibL0sDXE6Ts+QrPXWt30ECihd2JfzNHOvyzkciHSkOPlK6MHuXQ
         cYDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=BwbmA6QUpC/PUB8yG4wMDwColQTEWt5sncKQ3NY5zp4=;
        b=xo2WBAL6R6riwDrFrN+yadn3nGc7LjVyy+Zo6F3bilqryYr78Y2XWxiFVzZ7VtZyox
         jXftwX5JJ/HTxYOBWPrjZLUzCLjchqMYfJnWEbHSN7kZjAFYFS7eMtoDjkanEA+AS1Ke
         3BNctPpg7g9+1uepzf+PKgTl3FFlfpihVBne8PkpJpJEfJm90zdk/+pIlKUCaW5exo1D
         3quuvhmWpKvTuoSzfz6cf5siVlNM52hA/qt/9jtcr3qMv2Jfil7PTvUVw7qTb38mWFtb
         KdVazhQWAkC2RuGFnn/t3pwgz7YiiX3URLjGoi7+bKOJ2II5O36ODJkpyXAt4U+b+j/4
         afEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=K0XGkZ+A;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.1.48 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10048.outbound.protection.outlook.com. [40.107.1.48])
        by mx.google.com with ESMTPS id m2si822196edm.389.2019.02.22.08.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Feb 2019 08:10:30 -0800 (PST)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.1.48 as permitted sender) client-ip=40.107.1.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=K0XGkZ+A;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.1.48 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BwbmA6QUpC/PUB8yG4wMDwColQTEWt5sncKQ3NY5zp4=;
 b=K0XGkZ+AjjOSb4B6zIzrDhtxYmjGYNqKJb+MwySr1SWzrDNQdqFqufOvucPfWgxHvW/7UUFGG+A+NMDsIBontRENA31xnCXoAu9Y7thE+XMW0Z2KdGlqQgpRut+mE9qgPflKPYCyRMq8ORgd4FAGTeWYp4L8faOOY8Ec4x9pkJg=
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com (20.178.13.96) by
 VI1PR08MB4509.eurprd08.prod.outlook.com (20.179.27.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Fri, 22 Feb 2019 16:10:27 +0000
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52]) by VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52%6]) with mapi id 15.20.1622.021; Fri, 22 Feb 2019
 16:10:27 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
CC: nd <nd@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon
	<Will.Deacon@arm.com>, Mark Rutland <Mark.Rutland@arm.com>, Robin Murphy
	<Robin.Murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart
	<kstewart@linuxfoundation.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo
 Molnar <mingo@kernel.org>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Vincenzo
 Frascino <Vincenzo.Frascino@arm.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-doc@vger.kernel.org"
	<linux-doc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov
	<dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov
	<eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan
	<Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben
 Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya
	<cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave P Martin <Dave.Martin@arm.com>, Kevin Brodsky <Kevin.Brodsky@arm.com>
Subject: Re: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
Thread-Topic: [PATCH v10 00/12] arm64: untag user pointers passed to the
 kernel
Thread-Index: AQHUyq2dD9o2nPb5w0GtvSKm/T3roaXr8zMAgAABaYCAAAg+gA==
Date: Fri, 22 Feb 2019 16:10:26 +0000
Message-ID: <96d1086c-ca82-d6d7-24c3-f6686d98d47a@arm.com>
References: <cover.1550839937.git.andreyknvl@google.com>
 <464111f3-e255-ad45-8964-58462d889e6f@arm.com>
 <CAAeHK+wCZK7F7T1k+Kg_HkK47J8R9ugtH1g1ciLYH_KJ22ZVjg@mail.gmail.com>
In-Reply-To:
 <CAAeHK+wCZK7F7T1k+Kg_HkK47J8R9ugtH1g1ciLYH_KJ22ZVjg@mail.gmail.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.53]
x-clientproxiedby: LO2P265CA0341.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:d::17) To VI1PR08MB4223.eurprd08.prod.outlook.com
 (2603:10a6:803:b5::32)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bb16ba33-564f-43dc-10fc-08d698e041f3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB4509;
x-ms-traffictypediagnostic: VI1PR08MB4509:
x-ms-exchange-purlcount: 4
nodisclaimer: True
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB4509;20:JJ4KaMrCn5E6kxQBBr5uk88p0VWFA98UWb1OkobAMJW0dTHaTZ9iZm5Jc7sNivDMC3Hc410wXoDNxTHfwFt2w7qzNCiu78U0isfK98HINjcbCkszm1bvONP208ZgbTEP34B74bk2f6MTiyAURnsZ3+pGu/UyeEqrDswRrNVw5LM=
x-microsoft-antispam-prvs:
 <VI1PR08MB4509A42EC0E26A982E197BDCED7F0@VI1PR08MB4509.eurprd08.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(366004)(376002)(136003)(346002)(43544003)(199004)(189003)(36756003)(72206003)(44832011)(2906002)(26005)(476003)(316002)(229853002)(71200400001)(58126008)(6246003)(446003)(64126003)(2616005)(86362001)(486006)(5660300002)(966005)(6486002)(11346002)(31696002)(186003)(14444005)(71190400001)(256004)(54906003)(478600001)(6436002)(4326008)(6116002)(102836004)(65956001)(66066001)(386003)(53936002)(6306002)(65806001)(6512007)(6506007)(53546011)(305945005)(31686004)(6916009)(52116002)(3846002)(68736007)(81166006)(99286004)(8936002)(7736002)(106356001)(8676002)(25786009)(97736004)(105586002)(14454004)(81156014)(7416002)(65826007)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB4509;H:VI1PR08MB4223.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 S/7jbC9DALl99ZEkV/L8rHSikTvMX3uMx8qMcI8I+JyTPUlt/8shz9XEAFtbvp/OLp0gDyFgLrO08Q3W6fRV4ZYbNHwUyBscDQdOPegGQFO8J/L4hbSU7mQGJ18RfD6CKHBaQcg2HmrW+mJobexFWo7LbQO3BU2vfIF1XXEUNTDPLuiJAdka689a7Pc4Tt6Ep8tBrWuC4EGogDRkzVGH+qcqPnqnrCIf90SKJpOb+ghLNnKgpJPLcS2GzKp6DyH7nL4z9oOre5OUVE6W8F8fPwzt9UEILGJDc0Vc/6RDwsKVtIEJmy1VQxKRb7/0g4dUH+FOe5oWJP85Vq4pASs2M1vQkiZ9lbtny6bRy2plt/pSwQKVT440qDwruP0q3+qXcgGDOdiy4cFSKykiB1Wp+D48Nk6dmmvq+T8vzaa/jis=
Content-Type: text/plain; charset="utf-8"
Content-ID: <377964F0ADA85C4DA3F27A0A85288B86@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bb16ba33-564f-43dc-10fc-08d698e041f3
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 16:10:25.5891
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB4509
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjIvMDIvMjAxOSAxNTo0MCwgQW5kcmV5IEtvbm92YWxvdiB3cm90ZToNCj4gT24gRnJpLCBG
ZWIgMjIsIDIwMTkgYXQgNDozNSBQTSBTemFib2xjcyBOYWd5IDxTemFib2xjcy5OYWd5QGFybS5j
b20+IHdyb3RlOg0KPj4NCj4+IE9uIDIyLzAyLzIwMTkgMTI6NTMsIEFuZHJleSBLb25vdmFsb3Yg
d3JvdGU6DQo+Pj4gVGhpcyBwYXRjaHNldCBpcyBtZWFudCB0byBiZSBtZXJnZWQgdG9nZXRoZXIg
d2l0aCAiYXJtNjQgcmVsYXhlZCBBQkkiIFsxXS4NCj4+Pg0KPj4+IGFybTY0IGhhcyBhIGZlYXR1
cmUgY2FsbGVkIFRvcCBCeXRlIElnbm9yZSwgd2hpY2ggYWxsb3dzIHRvIGVtYmVkIHBvaW50ZXIN
Cj4+PiB0YWdzIGludG8gdGhlIHRvcCBieXRlIG9mIGVhY2ggcG9pbnRlci4gVXNlcnNwYWNlIHBy
b2dyYW1zIChzdWNoIGFzDQo+Pj4gSFdBU2FuLCBhIG1lbW9yeSBkZWJ1Z2dpbmcgdG9vbCBbMl0p
IG1pZ2h0IHVzZSB0aGlzIGZlYXR1cmUgYW5kIHBhc3MNCj4+PiB0YWdnZWQgdXNlciBwb2ludGVy
cyB0byB0aGUga2VybmVsIHRocm91Z2ggc3lzY2FsbHMgb3Igb3RoZXIgaW50ZXJmYWNlcy4NCj4+
Pg0KPj4+IFJpZ2h0IG5vdyB0aGUga2VybmVsIGlzIGFscmVhZHkgYWJsZSB0byBoYW5kbGUgdXNl
ciBmYXVsdHMgd2l0aCB0YWdnZWQNCj4+PiBwb2ludGVycywgZHVlIHRvIHRoZXNlIHBhdGNoZXM6
DQo+Pj4NCj4+PiAxLiA4MWNkZGQ2NSAoImFybTY0OiB0cmFwczogZml4IHVzZXJzcGFjZSBjYWNo
ZSBtYWludGVuYW5jZSBlbXVsYXRpb24gb24gYQ0KPj4+ICAgICAgICAgICAgICB0YWdnZWQgcG9p
bnRlciIpDQo+Pj4gMi4gN2RjZDlkZDggKCJhcm02NDogaHdfYnJlYWtwb2ludDogZml4IHdhdGNo
cG9pbnQgbWF0Y2hpbmcgZm9yIHRhZ2dlZA0KPj4+ICAgICAgICAgICAgIHBvaW50ZXJzIikNCj4+
PiAzLiAyNzZlOTMyNyAoImFybTY0OiBlbnRyeTogaW1wcm92ZSBkYXRhIGFib3J0IGhhbmRsaW5n
IG9mIHRhZ2dlZA0KPj4+ICAgICAgICAgICAgIHBvaW50ZXJzIikNCj4+Pg0KPj4+IFRoaXMgcGF0
Y2hzZXQgZXh0ZW5kcyB0YWdnZWQgcG9pbnRlciBzdXBwb3J0IHRvIHN5c2NhbGwgYXJndW1lbnRz
Lg0KPj4+DQo+Pj4gRm9yIG5vbi1tZW1vcnkgc3lzY2FsbHMgdGhpcyBpcyBkb25lIGJ5IHVudGFn
aW5nIHVzZXIgcG9pbnRlcnMgd2hlbiB0aGUNCj4+PiBrZXJuZWwgcGVyZm9ybXMgcG9pbnRlciBj
aGVja2luZyB0byBmaW5kIG91dCB3aGV0aGVyIHRoZSBwb2ludGVyIGNvbWVzDQo+Pj4gZnJvbSB1
c2Vyc3BhY2UgKG1vc3Qgbm90YWJseSBpbiBhY2Nlc3Nfb2spLiBUaGUgdW50YWdnaW5nIGlzIGRv
bmUgb25seQ0KPj4+IHdoZW4gdGhlIHBvaW50ZXIgaXMgYmVpbmcgY2hlY2tlZCwgdGhlIHRhZyBp
cyBwcmVzZXJ2ZWQgYXMgdGhlIHBvaW50ZXINCj4+PiBtYWtlcyBpdHMgd2F5IHRocm91Z2ggdGhl
IGtlcm5lbC4NCj4+Pg0KPj4+IFNpbmNlIG1lbW9yeSBzeXNjYWxscyAobW1hcCwgbXByb3RlY3Qs
IGV0Yy4pIGRvbid0IGRvIG1lbW9yeSBhY2Nlc3NlcyBidXQNCj4+PiByYXRoZXIgZGVhbCB3aXRo
IG1lbW9yeSByYW5nZXMsIHVudGFnZ2VkIHBvaW50ZXJzIGFyZSBiZXR0ZXIgc3VpdGVkIHRvDQo+
Pj4gZGVzY3JpYmUgbWVtb3J5IHJhbmdlcyBpbnRlcm5hbGx5LiBUaHVzIGZvciBtZW1vcnkgc3lz
Y2FsbHMgd2UgdW50YWcNCj4+PiBwb2ludGVycyBjb21wbGV0ZWx5IHdoZW4gdGhleSBlbnRlciB0
aGUga2VybmVsLg0KPj4NCj4+IGkgdGhpbmsgdGhlIHNhbWUgaXMgdHJ1ZSB3aGVuIHVzZXIgcG9p
bnRlcnMgYXJlIGNvbXBhcmVkLg0KPj4NCj4+IGUuZy4gaSBzdXNwZWN0IHRoZXJlIG1heSBiZSBp
c3N1ZXMgd2l0aCB0YWdnZWQgcm9idXN0IG11dGV4DQo+PiBsaXN0IHBvaW50ZXJzIGJlY2F1c2Ug
dGhlIGtlcm5lbCBkb2VzDQo+Pg0KPj4gZnV0ZXguYzozNTQxOiAgIHdoaWxlIChlbnRyeSAhPSAm
aGVhZC0+bGlzdCkgew0KPj4NCj4+IHdoZXJlIGVudHJ5IGlzIGEgdXNlciBwb2ludGVyIHRoYXQg
bWF5IGJlIHRhZ2dlZCwgYW5kDQo+PiAmaGVhZC0+bGlzdCBpcyBwcm9iYWJseSBub3QgdGFnZ2Vk
Lg0KPiANCj4gWW91J3JlIHJpZ2h0LiBJJ2xsIGV4cGFuZCB0aGUgY292ZXIgbGV0dGVyIGluIHRo
ZSBuZXh0IHZlcnNpb24gdG8NCj4gZGVzY3JpYmUgdGhpcyBtb3JlIGFjY3VyYXRlbHkuIFRoZSBw
YXRjaHNldCBob3dldmVyIGNvbnRhaW5zICJtbSwNCj4gYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRl
cnMgaW4gbW0vZ3VwLmMiIHRoYXQgc2hvdWxkIHRha2UgY2FyZSBvZiBmdXRleA0KPiBwb2ludGVy
cy4NCg0KdGhlIHJvYnVzdCBtdXRleCBsaXN0IHBvaW50ZXIgaXMgbm90IGEgZnV0ZXggcG9pbnRl
ciwNCmknbSBub3Qgc3VyZSBob3cgdGhlIG1tL2d1cC5jIHBhdGNoIGhlbHBzLg0KDQo+Pg0KPj4+
IE9uZSBvZiB0aGUgYWx0ZXJuYXRpdmUgYXBwcm9hY2hlcyB0byB1bnRhZ2dpbmcgdGhhdCB3YXMg
Y29uc2lkZXJlZCBpcyB0bw0KPj4+IGNvbXBsZXRlbHkgc3RyaXAgdGhlIHBvaW50ZXIgdGFnIGFz
IHRoZSBwb2ludGVyIGVudGVycyB0aGUga2VybmVsIHdpdGgNCj4+PiBzb21lIGtpbmQgb2YgYSBz
eXNjYWxsIHdyYXBwZXIsIGJ1dCB0aGF0IHdvbid0IHdvcmsgd2l0aCB0aGUgY291bnRsZXNzDQo+
Pj4gbnVtYmVyIG9mIGRpZmZlcmVudCBpb2N0bCBjYWxscy4gV2l0aCB0aGlzIGFwcHJvYWNoIHdl
IHdvdWxkIG5lZWQgYSBjdXN0b20NCj4+PiB3cmFwcGVyIGZvciBlYWNoIGlvY3RsIHZhcmlhdGlv
biwgd2hpY2ggZG9lc24ndCBzZWVtIHByYWN0aWNhbC4NCj4+Pg0KPj4+IFRoZSBmb2xsb3dpbmcg
dGVzdGluZyBhcHByb2FjaGVzIGhhcyBiZWVuIHRha2VuIHRvIGZpbmQgcG90ZW50aWFsIGlzc3Vl
cw0KPj4+IHdpdGggdXNlciBwb2ludGVyIHVudGFnZ2luZzoNCj4+Pg0KPj4+IDEuIFN0YXRpYyB0
ZXN0aW5nICh3aXRoIHNwYXJzZSBbM10gYW5kIHNlcGFyYXRlbHkgd2l0aCBhIGN1c3RvbSBzdGF0
aWMNCj4+PiAgICBhbmFseXplciBiYXNlZCBvbiBDbGFuZykgdG8gdHJhY2sgY2FzdHMgb2YgX191
c2VyIHBvaW50ZXJzIHRvIGludGVnZXINCj4+PiAgICB0eXBlcyB0byBmaW5kIHBsYWNlcyB3aGVy
ZSB1bnRhZ2dpbmcgbmVlZHMgdG8gYmUgZG9uZS4NCj4+Pg0KPj4+IDIuIFN0YXRpYyB0ZXN0aW5n
IHdpdGggZ3JlcCB0byBmaW5kIHBhcnRzIG9mIHRoZSBrZXJuZWwgdGhhdCBjYWxsDQo+Pj4gICAg
ZmluZF92bWEoKSAoYW5kIG90aGVyIHNpbWlsYXIgZnVuY3Rpb25zKSBvciBkaXJlY3RseSBjb21w
YXJlIGFnYWluc3QNCj4+PiAgICB2bV9zdGFydC92bV9lbmQgZmllbGRzIG9mIHZtYS4NCj4+Pg0K
Pj4+IDMuIFN0YXRpYyB0ZXN0aW5nIHdpdGggZ3JlcCB0byBmaW5kIHBhcnRzIG9mIHRoZSBrZXJu
ZWwgdGhhdCBjb21wYXJlDQo+Pj4gICAgdXNlciBwb2ludGVycyB3aXRoIFRBU0tfU0laRSBvciBv
dGhlciBzaW1pbGFyIGNvbnN0cyBhbmQgbWFjcm9zLg0KPj4+DQo+Pj4gNC4gRHluYW1pYyB0ZXN0
aW5nOiBhZGRpbmcgQlVHX09OKGhhc190YWcoYWRkcikpIHRvIGZpbmRfdm1hKCkgYW5kIHJ1bm5p
bmcNCj4+PiAgICBhIG1vZGlmaWVkIHN5emthbGxlciB2ZXJzaW9uIHRoYXQgcGFzc2VzIHRhZ2dl
ZCBwb2ludGVycyB0byB0aGUga2VybmVsLg0KPj4+DQo+Pj4gQmFzZWQgb24gdGhlIHJlc3VsdHMg
b2YgdGhlIHRlc3RpbmcgdGhlIHJlcXVyaWVkIHBhdGNoZXMgaGF2ZSBiZWVuIGFkZGVkDQo+Pj4g
dG8gdGhlIHBhdGNoc2V0Lg0KPj4+DQo+Pj4gVGhpcyBwYXRjaHNldCBoYXMgYmVlbiBtZXJnZWQg
aW50byB0aGUgUGl4ZWwgMiBrZXJuZWwgdHJlZSBhbmQgaXMgbm93DQo+Pj4gYmVpbmcgdXNlZCB0
byBlbmFibGUgdGVzdGluZyBvZiBQaXhlbCAyIHBob25lcyB3aXRoIEhXQVNhbi4NCj4+Pg0KPj4+
IFRoaXMgcGF0Y2hzZXQgaXMgYSBwcmVyZXF1aXNpdGUgZm9yIEFSTSdzIG1lbW9yeSB0YWdnaW5n
IGhhcmR3YXJlIGZlYXR1cmUNCj4+PiBzdXBwb3J0IFs0XS4NCj4+Pg0KPj4+IFRoYW5rcyENCj4+
Pg0KPj4+IFsxXSBodHRwczovL2xrbWwub3JnL2xrbWwvMjAxOC8xMi8xMC80MDINCj4+Pg0KPj4+
IFsyXSBodHRwOi8vY2xhbmcubGx2bS5vcmcvZG9jcy9IYXJkd2FyZUFzc2lzdGVkQWRkcmVzc1Nh
bml0aXplckRlc2lnbi5odG1sDQo+Pj4NCj4+PiBbM10gaHR0cHM6Ly9naXRodWIuY29tL2x1Y3Zv
by9zcGFyc2UtZGV2L2NvbW1pdC81Zjk2MGNiMTBmNTZlYzIwMTdjMTI4ZWY5ZDE2MDYwZTAxNDVm
MjkyDQo+Pj4NCj4+PiBbNF0gaHR0cHM6Ly9jb21tdW5pdHkuYXJtLmNvbS9wcm9jZXNzb3JzL2Iv
YmxvZy9wb3N0cy9hcm0tYS1wcm9maWxlLWFyY2hpdGVjdHVyZS0yMDE4LWRldmVsb3BtZW50cy1h
cm12ODVhDQo+Pj4NCj4+PiBDaGFuZ2VzIGluIHYxMDoNCj4+PiAtIEFkZGVkICJtbSwgYXJtNjQ6
IHVudGFnIHVzZXIgcG9pbnRlcnMgcGFzc2VkIHRvIG1lbW9yeSBzeXNjYWxscyIgYmFjay4NCj4+
PiAtIE5ldyBwYXRjaCAiZnMsIGFybTY0OiB1bnRhZyB1c2VyIHBvaW50ZXJzIGluIGZzL3VzZXJm
YXVsdGZkLmMiLg0KPj4+IC0gTmV3IHBhdGNoICJuZXQsIGFybTY0OiB1bnRhZyB1c2VyIHBvaW50
ZXJzIGluIHRjcF96ZXJvY29weV9yZWNlaXZlIi4NCj4+PiAtIE5ldyBwYXRjaCAia2VybmVsLCBh
cm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiBwcmN0bF9zZXRfbW0qIi4NCj4+PiAtIE5ldyBw
YXRjaCAidHJhY2luZywgYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gc2VxX3ByaW50X3Vz
ZXJfaXAiLg0KPj4+DQo+Pj4gQ2hhbmdlcyBpbiB2OToNCj4+PiAtIFJlYmFzZWQgb250byA0LjIw
LXJjNi4NCj4+PiAtIFVzZWQgdTY0IGluc3RlYWQgb2YgX191NjQgaW4gdHlwZSBjYXN0cyBpbiB0
aGUgdW50YWdnZWRfYWRkciBtYWNybyBmb3INCj4+PiAgIGFybTY0Lg0KPj4+IC0gQWRkZWQgYnJh
Y2VzIGFyb3VuZCAoYWRkcikgaW4gdGhlIHVudGFnZ2VkX2FkZHIgbWFjcm8gZm9yIG90aGVyIGFy
Y2hlcy4NCj4+Pg0KPj4+IENoYW5nZXMgaW4gdjg6DQo+Pj4gLSBSZWJhc2VkIG9udG8gNjUxMDIy
MzggKDQuMjAtcmMxKS4NCj4+PiAtIEFkZGVkIGEgbm90ZSB0byB0aGUgY292ZXIgbGV0dGVyIG9u
IHdoeSBzeXNjYWxsIHdyYXBwZXJzL3NoaW1zIHRoYXQgdW50YWcNCj4+PiAgIHVzZXIgcG9pbnRl
cnMgd29uJ3Qgd29yay4NCj4+PiAtIEFkZGVkIGEgbm90ZSB0byB0aGUgY292ZXIgbGV0dGVyIHRo
YXQgdGhpcyBwYXRjaHNldCBoYXMgYmVlbiBtZXJnZWQgaW50bw0KPj4+ICAgdGhlIFBpeGVsIDIg
a2VybmVsIHRyZWUuDQo+Pj4gLSBEb2N1bWVudGF0aW9uIGZpeGVzLCBpbiBwYXJ0aWN1bGFyIGFk
ZGVkIGEgbGlzdCBvZiBzeXNjYWxscyB0aGF0IGRvbid0DQo+Pj4gICBzdXBwb3J0IHRhZ2dlZCB1
c2VyIHBvaW50ZXJzLg0KPj4+DQo+Pj4gQ2hhbmdlcyBpbiB2NzoNCj4+PiAtIFJlYmFzZWQgb250
byAxN2I1N2IxOCAoNC4xOS1yYzYpLg0KPj4+IC0gRHJvcHBlZCB0aGUgImFybTY0OiB1bnRhZyB1
c2VyIGFkZHJlc3MgaW4gX19kb191c2VyX2ZhdWx0IiBwYXRjaCwgc2luY2UNCj4+PiAgIHRoZSBl
eGlzdGluZyBwYXRjaGVzIGFscmVhZHkgaGFuZGxlIHVzZXIgZmF1bHRzIHByb3Blcmx5Lg0KPj4+
IC0gRHJvcHBlZCB0aGUgInVzYiwgYXJtNjQ6IHVudGFnIHVzZXIgYWRkcmVzc2VzIGluIGRldmlv
IiBwYXRjaCwgc2luY2UgdGhlDQo+Pj4gICBwYXNzZWQgcG9pbnRlciBtdXN0IGNvbWUgZnJvbSBh
IHZtYSBhbmQgdGhlcmVmb3JlIGJlIHVudGFnZ2VkLg0KPj4+IC0gRHJvcHBlZCB0aGUgImFybTY0
OiBhbm5vdGF0ZSB1c2VyIHBvaW50ZXJzIGNhc3RzIGRldGVjdGVkIGJ5IHNwYXJzZSINCj4+PiAg
IHBhdGNoIChzZWUgdGhlIGRpc2N1c3Npb24gdG8gdGhlIHJlcGxpZXMgb2YgdGhlIHY2IG9mIHRo
aXMgcGF0Y2hzZXQpLg0KPj4+IC0gQWRkZWQgbW9yZSBjb250ZXh0IHRvIHRoZSBjb3ZlciBsZXR0
ZXIuDQo+Pj4gLSBVcGRhdGVkIERvY3VtZW50YXRpb24vYXJtNjQvdGFnZ2VkLXBvaW50ZXJzLnR4
dC4NCj4+Pg0KPj4+IENoYW5nZXMgaW4gdjY6DQo+Pj4gLSBBZGRlZCBhbm5vdGF0aW9ucyBmb3Ig
dXNlciBwb2ludGVyIGNhc3RzIGZvdW5kIGJ5IHNwYXJzZS4NCj4+PiAtIFJlYmFzZWQgb250byAw
NTBjZGM2YyAoNC4xOS1yYzErKS4NCj4+Pg0KPj4+IENoYW5nZXMgaW4gdjU6DQo+Pj4gLSBBZGRl
ZCAzIG5ldyBwYXRjaGVzIHRoYXQgYWRkIHVudGFnZ2luZyB0byBwbGFjZXMgZm91bmQgd2l0aCBz
dGF0aWMNCj4+PiAgIGFuYWx5c2lzLg0KPj4+IC0gUmViYXNlZCBvbnRvIDQ0YzkyOWUxICg0LjE4
LXJjOCkuDQo+Pj4NCj4+PiBDaGFuZ2VzIGluIHY0Og0KPj4+IC0gQWRkZWQgYSBzZWxmdGVzdCBm
b3IgY2hlY2tpbmcgdGhhdCBwYXNzaW5nIHRhZ2dlZCBwb2ludGVycyB0byB0aGUNCj4+PiAgIGtl
cm5lbCBzdWNjZWVkcy4NCj4+PiAtIFJlYmFzZWQgb250byA4MWU5N2YwMTMgKDQuMTgtcmMxKyku
DQo+Pj4NCj4+PiBDaGFuZ2VzIGluIHYzOg0KPj4+IC0gUmViYXNlZCBvbnRvIGU1YzUxZjMwICg0
LjE3LXJjNispLg0KPj4+IC0gQWRkZWQgbGludXgtYXJjaEAgdG8gdGhlIGxpc3Qgb2YgcmVjaXBp
ZW50cy4NCj4+Pg0KPj4+IENoYW5nZXMgaW4gdjI6DQo+Pj4gLSBSZWJhc2VkIG9udG8gMmQ2MThi
ZGYgKDQuMTctcmMzKykuDQo+Pj4gLSBSZW1vdmVkIGV4Y2Vzc2l2ZSB1bnRhZ2dpbmcgaW4gZ3Vw
LmMuDQo+Pj4gLSBSZW1vdmVkIHVudGFnZ2luZyBwb2ludGVycyByZXR1cm5lZCBmcm9tIF9fdWFj
Y2Vzc19tYXNrX3B0ci4NCj4+Pg0KPj4+IENoYW5nZXMgaW4gdjE6DQo+Pj4gLSBSZWJhc2VkIG9u
dG8gNC4xNy1yYzEuDQo+Pj4NCj4+PiBDaGFuZ2VzIGluIFJGQyB2MjoNCj4+PiAtIEFkZGVkICIj
aWZuZGVmIHVudGFnZ2VkX2FkZHIuLi4iIGZhbGxiYWNrIGluIGxpbnV4L3VhY2Nlc3MuaCBpbnN0
ZWFkIG9mDQo+Pj4gICBkZWZpbmluZyBpdCBmb3IgZWFjaCBhcmNoIGluZGl2aWR1YWxseS4NCj4+
PiAtIFVwZGF0ZWQgRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0Lg0KPj4+
IC0gRHJvcHBlZCAibW0sIGFybTY0OiB1bnRhZyB1c2VyIGFkZHJlc3NlcyBpbiBtZW1vcnkgc3lz
Y2FsbHMiLg0KPj4+IC0gUmViYXNlZCBvbnRvIDNlYjJjZTgyICg0LjE2LXJjNykuDQo+Pj4NCj4+
PiBSZXZpZXdlZC1ieTogTHVjIFZhbiBPb3N0ZW5yeWNrIDxsdWMudmFub29zdGVucnlja0BnbWFp
bC5jb20+DQo+Pj4gU2lnbmVkLW9mZi1ieTogQW5kcmV5IEtvbm92YWxvdiA8YW5kcmV5a252bEBn
b29nbGUuY29tPg0KPj4+DQo+Pj4gQW5kcmV5IEtvbm92YWxvdiAoMTIpOg0KPj4+ICAgdWFjY2Vz
czogYWRkIHVudGFnZ2VkX2FkZHIgZGVmaW5pdGlvbiBmb3Igb3RoZXIgYXJjaGVzDQo+Pj4gICBh
cm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiBhY2Nlc3Nfb2sgYW5kIF9fdWFjY2Vzc19tYXNr
X3B0cg0KPj4+ICAgbGliLCBhcm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiBzdHJuKl91c2Vy
DQo+Pj4gICBtbSwgYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgcGFzc2VkIHRvIG1lbW9yeSBz
eXNjYWxscw0KPj4+ICAgbW0sIGFybTY0OiB1bnRhZyB1c2VyIHBvaW50ZXJzIGluIG1tL2d1cC5j
DQo+Pj4gICBmcywgYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gY29weV9tb3VudF9vcHRp
b25zDQo+Pj4gICBmcywgYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gZnMvdXNlcmZhdWx0
ZmQuYw0KPj4+ICAgbmV0LCBhcm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiB0Y3BfemVyb2Nv
cHlfcmVjZWl2ZQ0KPj4+ICAga2VybmVsLCBhcm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiBw
cmN0bF9zZXRfbW0qDQo+Pj4gICB0cmFjaW5nLCBhcm02NDogdW50YWcgdXNlciBwb2ludGVycyBp
biBzZXFfcHJpbnRfdXNlcl9pcA0KPj4+ICAgYXJtNjQ6IHVwZGF0ZSBEb2N1bWVudGF0aW9uL2Fy
bTY0L3RhZ2dlZC1wb2ludGVycy50eHQNCj4+PiAgIHNlbGZ0ZXN0cywgYXJtNjQ6IGFkZCBhIHNl
bGZ0ZXN0IGZvciBwYXNzaW5nIHRhZ2dlZCBwb2ludGVycyB0byBrZXJuZWwNCj4+Pg0KPj4+ICBE
b2N1bWVudGF0aW9uL2FybTY0L3RhZ2dlZC1wb2ludGVycy50eHQgICAgICAgfCAyNSArKysrKysr
KysrKy0tLS0tLS0tDQo+Pj4gIGFyY2gvYXJtNjQvaW5jbHVkZS9hc20vdWFjY2Vzcy5oICAgICAg
ICAgICAgICB8IDEwICsrKysrLS0tDQo+Pj4gIGZzL25hbWVzcGFjZS5jICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICB8ICAyICstDQo+Pj4gIGZzL3VzZXJmYXVsdGZkLmMgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICB8ICA1ICsrKysNCj4+PiAgaW5jbHVkZS9saW51eC9tZW1vcnku
aCAgICAgICAgICAgICAgICAgICAgICAgIHwgIDQgKysrDQo+Pj4gIGlwYy9zaG0uYyAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8ICAyICsrDQo+Pj4gIGtlcm5lbC9zeXMuYyAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8IDE0ICsrKysrKysrKysrDQo+Pj4gIGtl
cm5lbC90cmFjZS90cmFjZV9vdXRwdXQuYyAgICAgICAgICAgICAgICAgICB8ICAyICstDQo+Pj4g
IGxpYi9zdHJuY3B5X2Zyb21fdXNlci5jICAgICAgICAgICAgICAgICAgICAgICB8ICAyICsrDQo+
Pj4gIGxpYi9zdHJubGVuX3VzZXIuYyAgICAgICAgICAgICAgICAgICAgICAgICAgICB8ICAyICsr
DQo+Pj4gIG1tL2d1cC5jICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8ICA0
ICsrKw0KPj4+ICBtbS9tYWR2aXNlLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
fCAgMiArKw0KPj4+ICBtbS9tZW1wb2xpY3kuYyAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgfCAgNSArKysrDQo+Pj4gIG1tL21pZ3JhdGUuYyAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICB8ICAxICsNCj4+PiAgbW0vbWluY29yZS5jICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIHwgIDIgKysNCj4+PiAgbW0vbWxvY2suYyAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIHwgIDUgKysrKw0KPj4+ICBtbS9tbWFwLmMgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgfCAgNyArKysrKysNCj4+PiAgbW0vbXByb3RlY3QuYyAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDIgKysNCj4+PiAgbW0vbXJlbWFwLmMgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDIgKysNCj4+PiAgbW0vbXN5bmMuYyAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDIgKysNCj4+PiAgbmV0L2lwdjQvdGNw
LmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDIgKysNCj4+PiAgdG9vbHMvdGVz
dGluZy9zZWxmdGVzdHMvYXJtNjQvLmdpdGlnbm9yZSAgICAgIHwgIDEgKw0KPj4+ICB0b29scy90
ZXN0aW5nL3NlbGZ0ZXN0cy9hcm02NC9NYWtlZmlsZSAgICAgICAgfCAxMSArKysrKysrKw0KPj4+
ICAuLi4vdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQvcnVuX3RhZ3NfdGVzdC5zaCAgfCAxMiArKysr
KysrKysNCj4+PiAgdG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQvdGFnc190ZXN0LmMgICAg
IHwgMTkgKysrKysrKysrKysrKysNCj4+PiAgMjUgZmlsZXMgY2hhbmdlZCwgMTI5IGluc2VydGlv
bnMoKyksIDE2IGRlbGV0aW9ucygtKQ0KPj4+ICBjcmVhdGUgbW9kZSAxMDA2NDQgdG9vbHMvdGVz
dGluZy9zZWxmdGVzdHMvYXJtNjQvLmdpdGlnbm9yZQ0KPj4+ICBjcmVhdGUgbW9kZSAxMDA2NDQg
dG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQvTWFrZWZpbGUNCj4+PiAgY3JlYXRlIG1vZGUg
MTAwNzU1IHRvb2xzL3Rlc3Rpbmcvc2VsZnRlc3RzL2FybTY0L3J1bl90YWdzX3Rlc3Quc2gNCj4+
PiAgY3JlYXRlIG1vZGUgMTAwNjQ0IHRvb2xzL3Rlc3Rpbmcvc2VsZnRlc3RzL2FybTY0L3RhZ3Nf
dGVzdC5jDQo+Pj4NCj4+DQoNCg==

