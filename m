Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C94DC282D9
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7B42086C
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 00:25:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="jY+94VHz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7B42086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C439F8E0003; Thu, 31 Jan 2019 19:25:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF11B8E0001; Thu, 31 Jan 2019 19:25:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92978E0003; Thu, 31 Jan 2019 19:25:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 614B78E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 19:25:47 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 89so3659931ple.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 16:25:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Eoesr+avZHybWqYak19mzfk9DSZQ/hxKNgKYvR+XcKI=;
        b=qxNlcEsBTa/kfKCGWzECkjfmlrakgVoJmuHWFaSMNmjekLqM7y9qSeu4ChxRJh181b
         wjZzzwQihqzlvb6j63WFoxoQcwokMNaVNjZs2MPEB1DNggcAjHKoFToVN38NGA8KzMDs
         JKzYqBfM0/VCaJy5D7Hq/l8Vc9K5MDf5F1Ho3a757U8gJkip4E8lFuQFMHimf0pT+/Er
         6hmskqf/BB6TKC6CTifza3ivN6iTHWNLRQ9GBqqZ777hcessNAzvQ+poJsmtsb4azC8J
         3iBnAvypKNkBCZ2pw5TOrXLjpxXpaKx4uwwYfXiITNqDfpm/tLQV6cvENgRMHEDtmBM1
         lNwA==
X-Gm-Message-State: AJcUukfpg8PuV7Dca6n/n56jtlhwuyo5VyQ+1FGBFJbP6cEZwGsKLgfL
	ojJY2WRpmqWaQVpxtFd5thnvH0YJuzIF06fPBDrPa4jkjr/cO/zsQ6AfRtFzTZ8lVFuAEPPuPJg
	IiAJFmecHhO25/sNrCQp+s+1sl973yHp3tfy7f/mjOxo6KB+VKYuHTZWPI0kOq54lfg==
X-Received: by 2002:a62:de06:: with SMTP id h6mr38008718pfg.158.1548980746985;
        Thu, 31 Jan 2019 16:25:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5ovlAdWO5G3IYUeUTFGaF/haNJfHB8TQji/31T2SbPA0Js/cVEX5HEcoheGPpfVFEqtHpX
X-Received: by 2002:a62:de06:: with SMTP id h6mr38008673pfg.158.1548980746013;
        Thu, 31 Jan 2019 16:25:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548980745; cv=none;
        d=google.com; s=arc-20160816;
        b=KzeR8vv5SSSWnGA97X4T8Kho2/L9DQchGO4EHQxL7vTQ7/vN5/g2+JFFOOrGA0MpKE
         dClF3vgjo3j6Uy6J05rRSTEd5Vj/ATk24Z8Pw2Fw0RQxPQhZ0vrZsM/LKbYPfwPzi5Mg
         /kgtLj6SepLkR9Uvtq6C3cqfwsYjrUoeON7eRFaHgWPawkFYbla8M/qqQ4eVgbHpUD+H
         h0SXSaCRJrqViZ7L5e1UE5u1pFvNCmKO3uHXc4pMfIazDWKulKrZCWLKSyNKBzE0h6tU
         htSexkzA8vCmliu6epL/ORqFgZkzzevlt96zfzv2asR35j6H85gcDHiq2Rfr6vv6vrDE
         S/ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Eoesr+avZHybWqYak19mzfk9DSZQ/hxKNgKYvR+XcKI=;
        b=QjnmAVPEQ99c+b727x01IQ24fKZtdIkuTVHLBcykD4JCIJLBa14ghGxcJ6WjFzWqL+
         AlpK6GiHoRMq/FAXZs1RIgARCiGnFvWu5pewplYhEoTP5PaKhbwG4IQzsyV/BcbPMo84
         7NQalso44eq13S+v0+QprY4t+JBqksPwJ4UkY8kd63eGpYK6VzVeTQuJ1edbH/Uepqjq
         vKhCg+m98h8jpPmuxDThU7D/6D3vmSV2k36o523hI6/J1XUi3MssXliMeHbywHjrV6fV
         TaIf9BBLjEd6z6FezsjdllCKclocP32lBzQC4CmARSjR2JOGu5EQ2C6d2kH+P7QccA+9
         saHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=jY+94VHz;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800055.outbound.protection.outlook.com. [40.107.80.55])
        by mx.google.com with ESMTPS id a3si6273183pld.252.2019.01.31.16.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 Jan 2019 16:25:45 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.80.55 as permitted sender) client-ip=40.107.80.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=jY+94VHz;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Eoesr+avZHybWqYak19mzfk9DSZQ/hxKNgKYvR+XcKI=;
 b=jY+94VHz679uGbEghPRaqWHsdKes5YOgpzHpe7w0HZVu0FBHRrl1RlivJBR93TWIcjlAMo4+pF/W+7rUQvvA73q7Im1SOsAE8SyPqKUDTs3c/aWuVtnPXzWURU9lvF48PEdsqHsTdfOwHuz5nLsIxg1UiNSwQavusvdCVyr+HAM=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6087.namprd05.prod.outlook.com (20.178.54.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.10; Fri, 1 Feb 2019 00:25:43 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31%3]) with mapi id 15.20.1601.011; Fri, 1 Feb 2019
 00:25:43 +0000
From: Nadav Amit <namit@vmware.com>
To: Borislav Petkov <bp@alien8.de>
CC: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski
	<luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen
	<dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Damian
 Tometzki <linux_dti@icloud.com>, linux-integrity
	<linux-integrity@vger.kernel.org>, LSM List
	<linux-security-module@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kernel Hardening
	<kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will
 Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, Kees Cook <keescook@chromium.org>, Dave Hansen
	<dave.hansen@intel.com>
Subject: Re: [PATCH v2 03/20] x86/mm: temporary mm struct
Thread-Topic: [PATCH v2 03/20] x86/mm: temporary mm struct
Thread-Index: AQHUt2sRwAS+mFb6qECsCs685/9Pk6XJQbUAgAC1oACAAB5FAIAABOQA
Date: Fri, 1 Feb 2019 00:25:43 +0000
Message-ID: <D0AE47D2-F4B7-4938-A002-BBEEA3A5AB49@vmware.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-4-rick.p.edgecombe@intel.com>
 <20190131112948.GE6749@zn.tnic>
 <C481E605-E19A-4EA6-AB9A-6FF4229789E0@vmware.com>
 <20190201000812.GP6749@zn.tnic>
In-Reply-To: <20190201000812.GP6749@zn.tnic>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;BYAPR05MB6087;20:czt+c0sCKtRZufioavLX9l3Oj7F5inRxRK/ASyBzM2VTQ+Y/TOfoDmKMRzSGSE54lLUlL4cRW8XQWXpp9Ap2DfwCjzM4KgTuR+oxwFiu+vl8yHX8gXzAuX9rJK77WxoNeLXj8SsUMWcrvkeC8Lgy7l1RrIXxa7X6aFZUuotZONA=
x-ms-office365-filtering-correlation-id: ffef8a9a-4892-4e44-9dd8-08d687dbcdae
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR05MB6087;
x-ms-traffictypediagnostic: BYAPR05MB6087:
x-microsoft-antispam-prvs:
 <BYAPR05MB608706B4F78AF80641F2C998D0920@BYAPR05MB6087.namprd05.prod.outlook.com>
x-forefront-prvs: 09352FD734
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(39860400002)(366004)(136003)(376002)(199004)(189003)(36756003)(106356001)(53546011)(11346002)(446003)(81156014)(8676002)(316002)(66066001)(81166006)(82746002)(6512007)(53936002)(4326008)(478600001)(6916009)(54906003)(102836004)(2616005)(14454004)(25786009)(33656002)(39060400002)(105586002)(476003)(26005)(6506007)(186003)(6246003)(76176011)(256004)(99286004)(71200400001)(7416002)(2906002)(7736002)(97736004)(486006)(8936002)(6116002)(6436002)(6486002)(3846002)(305945005)(229853002)(83716004)(68736007)(86362001)(93886005)(71190400001);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6087;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 YStyBkvhgtyMGntAbK+aaaMc3Cd5fwBEbQqTfx6lNynrwAJ2svHEMzB5CPATVeVKf7K18X+f6XQW5BsfAecVkt2ZVVrTP58SjqLIBhok6/xWzb0gS4q9V3V+WRPh8NcFzadWVfOMJ4Va326lA6/QzfzxzY5Pb3c3l6ltBKCVvcgjDnwRP88frp1TD1eyl7aT5k7reLvQFjMoh+GsYp9H9TwVfUOsDdtxJnbzTQUVD0AuB2sy4wekc/zWbW2Ijml/DjPYrbQRNzAkxghxnY66zPJIevNa2aqKwKoJ+zcyq6nE6h15eQtiyeOlxxvoPbNiTdms5b9vmp7SIaxBEQCrx+rODTf3Ca1c3Wk023jLYB3UquE7dT7HP0YwnfFRq9RYD6M0uaKgJt3VSrlNiHctNdLJuO46oh2LyJduAJraShA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <A873F991F428B14CAEEB63AA4CB8EBCD@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ffef8a9a-4892-4e44-9dd8-08d687dbcdae
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Feb 2019 00:25:43.5652
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKYW4gMzEsIDIwMTksIGF0IDQ6MDggUE0sIEJvcmlzbGF2IFBldGtvdiA8YnBAYWxpZW44
LmRlPiB3cm90ZToNCj4gDQo+IE9uIFRodSwgSmFuIDMxLCAyMDE5IGF0IDEwOjE5OjU0UE0gKzAw
MDAsIE5hZGF2IEFtaXQgd3JvdGU6DQo+PiBNZXRhLXF1ZXN0aW9uOiBjb3VsZCB5b3UgcGxlYXNl
IHJldmlldyB0aGUgZW50aXJlIHBhdGNoLXNldD8gVGhpcyBpcw0KPj4gYWN0dWFsbHkgdjkgb2Yg
dGhpcyBwYXJ0aWN1bGFyIHBhdGNoIC0gaXQgd2FzIHBhcnQgb2YgYSBzZXBhcmF0ZSBwYXRjaC1z
ZXQNCj4+IGJlZm9yZS4gSSBkb27igJl0IHRoaW5rIHRoYXQgdGhlIHBhdGNoIGhhcyBjaGFuZ2Vk
IHNpbmNlICh0aGUgcmVhbCkgdjEuDQo+PiANCj4+IFRoZXNlIHNwb3JhZGljIGNvbW1lbnRzIGFm
dGVyIGVhY2ggdmVyc2lvbiByZWFsbHkgbWFrZXMgaXQgaGFyZCB0byBnZXQgdGhpcw0KPj4gd29y
ayBjb21wbGV0ZWQuDQo+IA0KPiBTb3JyeSBidXQgd2hlcmUgSSBhbSB0aGUgZGF5IGhhcyBvbmx5
IDI0IGhvdXJzIGFuZCB0aGlzIHBhdGNoc2V0IGlzIG5vdA0KPiB0aGUgb25seSBvbmUgaW4gbXkg
b3ZlcmZsb3dpbmcgbWJveC4gSWYgbXkgc3BvcmFkaWMgY29tbWVudHMgYXJlIG1ha2luZw0KPiBp
dCBoYXJkIHRvIGZpbmlzaCB5b3VyIHdvcmssIEkgYmV0dGVyIG5vdCBpbnRlcmZlcmUgdGhlbi4N
Cg0KSSBjZXJ0YWlubHkgZGlkIG5vdCBpbnRlbmQgZm9yIGl0IHRvIHNvdW5kIHRoaXMgd2F5LCBh
bmQgeW91ciBmZWVkYmFjayBpcw0Kb2J2aW91c2x5IHZhbHVhYmxlLg0KDQpKdXN0IGxldCBtZSBr
bm93IHdoZW4geW91IGFyZSBkb25lIHJldmlld2luZyB0aGUgcGF0Y2gtc2V0LCBzbyBJIHdpbGwg
bm90DQpvdmVyZmxvdyB5b3VyIG1haWxib3ggd2l0aCBldmVuIHVubmVjZXNzYXJ5IHZlcnNpb25z
IG9mIHRoZXNlIHBhdGNoZXMuIDopDQoNCg==

