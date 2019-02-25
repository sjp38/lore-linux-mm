Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F187C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:02:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26FE720C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:02:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="qwySljr2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26FE720C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10408E000F; Mon, 25 Feb 2019 13:02:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0278E000D; Mon, 25 Feb 2019 13:02:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B06E8E000F; Mon, 25 Feb 2019 13:02:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 590758E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:02:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 27so2916536pgv.14
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:02:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=ZVQNAfInftjEKQdTVIgTyS8KZ8vMtQLsmwmdsQqTnUs=;
        b=OUlPTi/ZmsyoLSFC0K6qzCJ4Q0n9t+8UARVYL9XQU8fYUgV6dAHiwApNE7uFfcOoI1
         kwRVlzGPLmEh+RYY25viF0K48UK+Hn+5zGxtQyLIdDTpgUwDmSMCuRlvzexeyaWvaOZO
         hpvC6dcfua9KeshjxE8AHmCxW6579j7o9KDq6To83pvbLYlsv97amOnxSJRLw6r5pkBb
         DGFvAw3n7LoCOHOuXDbaZnG3KgskEz+QdVUeKAEKlHAnTT5Nye3Nv8lWD8RPhfKyhaI7
         AHeMtDDMPypN2Z06mIU13BcdGrSQOvWO4w/ERhouURezbgnqGTNF6NNaWRsSm42DfHlO
         RNAA==
X-Gm-Message-State: AHQUAuYLIrFBoWQd98dnSOuTgbCSnPT/sthrGUHG6wvcqc6XYu1DyXgc
	6VjMvQ2sXjovu0WYCk7qppNwJiYJYgfxOCN+s5V4thYJrphucO9knk1N5d8qTeB1WMvLdvU5JcF
	pUcSPLjKoKTMMhDV2s9Lh2ZyIBEI75tV1UxXVWIUEMKRm+KotjMYYRDQUwCb1gkyfvQ==
X-Received: by 2002:a63:5702:: with SMTP id l2mr20336598pgb.2.1551117777934;
        Mon, 25 Feb 2019 10:02:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZaCx8QfT6OrKiskz3S5C34U6nmn8izaSyAC5Voarv0Z6VeMxHgF/z8xLGzGoxqj3RdqimU
X-Received: by 2002:a63:5702:: with SMTP id l2mr20336494pgb.2.1551117776594;
        Mon, 25 Feb 2019 10:02:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551117776; cv=none;
        d=google.com; s=arc-20160816;
        b=d8iyYrtVvr4s3M3ZvhfSD5NlCPuHiB40lkQfGVQfhbWqs2iOmqk1fG544gdwPCdBFc
         g5jMpg3U9Jf07/WfvFHV6NoUYd0hJm9gPoUKCAHXOCTsQdZdHdCs+kDulD5jt+G60syZ
         Xif76ovB1ecbRagrjzbWM4V1aJ9U9DH11aofxyPeTDmH6R69LxTxOPHodf7EUaJbbaSN
         A7n8yXQyHFo4C2ZJL3V8c4whkQcfEkDAiC7ZlN6VA+O8TWQPf0bSfYV/8/eYuA3rD8Ps
         GjciPUuoR+IfrRbjn2YnQGgdz5chYedmrz8FOZHeno1VD0eJtVz/YnlTe8pPFEan02+a
         iung==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=ZVQNAfInftjEKQdTVIgTyS8KZ8vMtQLsmwmdsQqTnUs=;
        b=qgVa3E+DilLHwq5S338n/8Yo9BVKd/O9T/3QCndEKu0COOkvmY+xRBFGc1zZurVxee
         fYV5wC2Fhu/41EHE26fQiCKnyFIVKfaiJfNXHcKV1NcU5hNOwY3PXEbm4Exy4cYQIL6R
         5yOieFWyjevVWLDwDS+C012KtoGrUHh2J7O93+VSX2gB6GRUjcwTWMCpfhYur5VMGb9h
         osX4e42TV/f/ebIhdH7NVR6aPEeLX7PdQETITsSbAWOs/+F7rAt6tnH9qAeK/t0rZizd
         V+EhPvpOkmcjs8kpkBfNFJHI0ZK6QiqUrjE3yYKQmgz/VKShpwD7CBQWC5x/8DkhELFf
         aVGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=qwySljr2;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.15.44 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150044.outbound.protection.outlook.com. [40.107.15.44])
        by mx.google.com with ESMTPS id m1si10190459plt.28.2019.02.25.10.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:02:56 -0800 (PST)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.15.44 as permitted sender) client-ip=40.107.15.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=qwySljr2;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.15.44 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZVQNAfInftjEKQdTVIgTyS8KZ8vMtQLsmwmdsQqTnUs=;
 b=qwySljr2JLUM1To822DuvPb+GGxsMOxL9U0s00GYzpPGwPJiYh2gHT3W0KOhvpr/WoO+qVw69gXSAnTWnhhApFRLc5M0Y0+5Tv12+cIkeaah//xjHmWClpXPf5EotXN8NOdIvlCajTW1ptVFCbPJxqCSHHYcATKq5mYlu5uvTnE=
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com (20.178.13.96) by
 VI1PR08MB3088.eurprd08.prod.outlook.com (52.133.15.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.14; Mon, 25 Feb 2019 18:02:51 +0000
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52]) by VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52%6]) with mapi id 15.20.1643.019; Mon, 25 Feb 2019
 18:02:51 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>
CC: nd <nd@arm.com>, Evgenii Stepanov <eugenis@google.com>, Kevin Brodsky
	<Kevin.Brodsky@arm.com>, Dave P Martin <Dave.Martin@arm.com>, Mark Rutland
	<Mark.Rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon
	<Will.Deacon@arm.com>, Linux Memory Management List <linux-mm@kvack.org>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Chintan Pandya <cpandya@codeaurora.org>, Vincenzo Frascino
	<Vincenzo.Frascino@arm.com>, Shuah Khan <shuah@kernel.org>, Ingo Molnar
	<mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley
	<Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook
	<keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey
 Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Alexander
 Viro <viro@zeniv.linux.org.uk>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML
	<linux-kernel@vger.kernel.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Ramana Radhakrishnan
	<Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <Robin.Murphy@arm.com>, Luc Van Oostenryck
	<luc.vanoostenryck@gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Thread-Topic: [RFC][PATCH 0/3] arm64 relaxed ABI
Thread-Index: AQHUyFD8LSHMwEYo7kaikjJNt8xTtqXnc/kAgAlRvYCAABJJAA==
Date: Mon, 25 Feb 2019 18:02:50 +0000
Message-ID: <7afa18b8-f135-036d-943c-b6216e7da481@arm.com>
References: <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
 <ac8f4e3b-84b8-6067-6a7a-fac7dc48daea@arm.com>
 <20190225165720.GA79300@arrakis.emea.arm.com>
In-Reply-To: <20190225165720.GA79300@arrakis.emea.arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.51]
x-clientproxiedby: LO2P265CA0362.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a3::14) To VI1PR08MB4223.eurprd08.prod.outlook.com
 (2603:10a6:803:b5::32)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: eb85d342-77cb-4df6-4dab-08d69b4b74ee
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB3088;
x-ms-traffictypediagnostic: VI1PR08MB3088:
nodisclaimer: True
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB3088;20:yrrnYBcp1F1tDfbY9DStaCTmCCp6zvFBmtTxtKRPIlMNTNJHp0tbQw3hytMUKmbW2rNC7iwqFReQnBVFJT9BErOv75UHU2FXTVAEQPH/6ggtvbMGbIRzrR29IArW6rOIypAw6VIZo5fHyXRHGdVVqQHf121+FBxcgNHgbvNmBsE=
x-microsoft-antispam-prvs:
 <VI1PR08MB3088F036F706BCB18FCA38BAED7A0@VI1PR08MB3088.eurprd08.prod.outlook.com>
x-forefront-prvs: 095972DF2F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(376002)(136003)(366004)(346002)(199004)(189003)(65826007)(86362001)(99286004)(93886005)(6512007)(6862004)(478600001)(386003)(71190400001)(71200400001)(6506007)(37006003)(65956001)(54906003)(14444005)(256004)(53546011)(31696002)(305945005)(8936002)(65806001)(66066001)(68736007)(53936002)(5660300002)(7736002)(6246003)(44832011)(81166006)(476003)(2616005)(486006)(81156014)(11346002)(446003)(8676002)(26005)(106356001)(3846002)(6486002)(6436002)(4326008)(14454004)(6116002)(97736004)(102836004)(76176011)(316002)(36756003)(52116002)(58126008)(229853002)(7416002)(64126003)(25786009)(6636002)(31686004)(105586002)(72206003)(2906002)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB3088;H:VI1PR08MB4223.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 NW+5VgZcT8Krza092sQKHPkVSFrh5m+AWwqIzbaFCm1qZ7945lZq7Ao/IarsyF1eMosvpDOaQK8VxyLJL57ge9vPBj4/ZD4t/fxQbMNw4JNocR+4RK1Qw3iRKKP98e2n6KuKnb13sZuv2VGKu4AUUIemjtqCACZ8jATjl3pkQZxkFz5yg3BWtz+xtNEIE2xMmyEVTgAHnzRahrPyNBdlpuBWvP5e83a0GBhaMcF/Yt3qVA+sOEIkSpiR9lSSLmfec0N5Va0IK58cxTtOUPuleLXzLKtK2tBgUEKTAmFvC7F6wQtBRuVe+nbzo9nyGd/tGP9BnSgMUVSDHKSra9T7eg+LJo+uOFvu9DybXxF83iqvC3qq6ih0CYR78aS5YBcpM3KdTsM0AJJTiWT0e0fP+N9Zdk1QPmDpRnFWDcpAUKQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <63E1CE8D940678418B16F5E6DCE4B04A@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: eb85d342-77cb-4df6-4dab-08d69b4b74ee
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2019 18:02:49.1159
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB3088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjUvMDIvMjAxOSAxNjo1NywgQ2F0YWxpbiBNYXJpbmFzIHdyb3RlOg0KPiBPbiBUdWUsIEZl
YiAxOSwgMjAxOSBhdCAwNjozODozMVBNICswMDAwLCBTemFib2xjcyBOYWd5IHdyb3RlOg0KPj4g
aSB0aGluayB0aGVzZSBydWxlcyB3b3JrIGZvciB0aGUgY2FzZXMgaSBjYXJlIGFib3V0LCBhIG1v
cmUNCj4+IHRyaWNreSBxdWVzdGlvbiBpcyB3aGVuL2hvdyB0byBjaGVjayBmb3IgdGhlIG5ldyBz
eXNjYWxsIGFiaQ0KPj4gYW5kIHdoZW4vaG93IHRoZSBUQ1JfRUwxLlRCSTAgc2V0dGluZyBtYXkg
YmUgdHVybmVkIG9mZi4NCj4gDQo+IEkgZG9uJ3QgdGhpbmsgdHVybmluZyBUQkkwIG9mZiBpcyBj
cml0aWNhbCAoaXQncyBoYW5keSBmb3IgUEFDIHdpdGgNCj4gNTItYml0IFZBIGJ1dCB0aGVuIGl0
J3Mgc2hvcnQtbGl2ZWQgaWYgeW91IHdhbnQgbW9yZSBzZWN1cml0eSBmZWF0dXJlcw0KPiBsaWtl
IE1URSkuDQoNCnllcywgaSBtYWRlIGEgbWlzdGFrZSBhc3N1bWluZyBUQkkwIG9mZiBpcw0KcmVx
dWlyZWQgZm9yIChvciBhdCBsZWFzdCBjb21wYXRpYmxlIHdpdGgpIE1URS4NCg0KaWYgVEJJMCBu
ZWVkcyB0byBiZSBvbiBmb3IgTVRFIHRoZW4gc29tZSBvZiBteQ0KYW5hbHlzaXMgaXMgd3Jvbmcs
IGFuZCBpIGV4cGVjdCBUQkkwIHRvIGJlIG9uDQppbiB0aGUgZm9yZXNlZWFibGUgZnV0dXJlLg0K
DQo+PiBjb25zaWRlciB0aGUgZm9sbG93aW5nIGNhc2VzICh0YiA9PSB0b3AgYnl0ZSk6DQo+Pg0K
Pj4gYmluYXJ5IDE6IHVzZXIgdGIgPSBhbnksIHN5c2NhbGwgdGIgPSAwDQo+PiAgIHRiaSBpcyBv
biwgImxlZ2FjeSBiaW5hcnkiDQo+Pg0KPj4gYmluYXJ5IDI6IHVzZXIgdGIgPSBhbnksIHN5c2Nh
bGwgdGIgPSBhbnkNCj4+ICAgdGJpIGlzIG9uLCAibmV3IGJpbmFyeSB1c2luZyB0YiINCj4+ICAg
Zm9yIGJhY2t3YXJkIGNvbXBhdCBpdCBuZWVkcyB0byBjaGVjayBmb3IgbmV3IHN5c2NhbGwgYWJp
Lg0KPj4NCj4+IGJpbmFyeSAzOiB1c2VyIHRiID0gMCwgc3lzY2FsbCB0YiA9IDANCj4+ICAgdGJp
IGNhbiBiZSBvZmYsICJuZXcgYmluYXJ5IiwNCj4+ICAgYmluYXJ5IGlzIG1hcmtlZCB0byBpbmRp
Y2F0ZSB1bnVzZWQgdGIsDQo+PiAgIGtlcm5lbCBtYXkgdHVybiB0Ymkgb2ZmOiBhZGRpdGlvbmFs
IHBhYyBiaXRzLg0KPj4NCj4+IGJpbmFyeSA0OiB1c2VyIHRiID0gbXRlLCBzeXNjYWxsIHRiID0g
bXRlDQo+PiAgIGxpa2UgYmluYXJ5IDMsIGJ1dCB3aXRoIG10ZSwgIm5ldyBiaW5hcnkgdXNpbmcg
bXRlIg0KDQpzbyB0aGlzIHNob3VsZCBiZSAibGlrZSBiaW5hcnkgMiwgYnV0IHdpdGggbXRlIi4N
Cg0KPj4gICBkb2VzIGl0IGhhdmUgdG8gY2hlY2sgZm9yIG5ldyBzeXNjYWxsIGFiaT8NCj4+ICAg
b3IgTVRFIEhXQ0FQIHdvdWxkIGltcGx5IGl0Pw0KPj4gICAoaXMgaXQgcG9zc2libGUgdG8gdXNl
IG10ZSB3aXRob3V0IG5ldyBzeXNjYWxsIGFiaT8pDQo+IA0KPiBJIHRoaW5rIE1URSBIV0NBUCBz
aG91bGQgaW1wbHkgaXQuDQo+IA0KPj4gaW4gdXNlcnNwYWNlIHdlIHdhbnQgbW9zdCBiaW5hcmll
cyB0byBiZSBsaWtlIGJpbmFyeSAzIGFuZCA0DQo+PiBldmVudHVhbGx5LCBpLmUuIG1hcmtlZCBh
cyBub3QtcmVseWluZy1vbi10YmksIGlmIGEgZHNvIGlzDQo+PiBsb2FkZWQgdGhhdCBpcyB1bm1h
cmtlZCAobGVnYWN5IG9yIG5ldyB0YiB1c2VyKSwgdGhlbiBlaXRoZXINCj4+IHRoZSBsb2FkIGZh
aWxzIChlLmcuIGlmIG10ZSBpcyBhbHJlYWR5IHVzZWQ/IG9yIGNhbiB3ZSB0dXJuDQo+PiBtdGUg
b2ZmIGF0IHJ1bnRpbWU/KSBvciB0YmkgaGFzIHRvIGJlIGVuYWJsZWQgKHByY3RsPyBkb2VzDQo+
PiB0aGlzIHdvcmsgd2l0aCBwYWM/IG9yIG11bHRpLXRocmVhZHM/KS4NCj4gDQo+IFdlIGNvdWxk
IGVuYWJsZSBpdCB2aWEgcHJjdGwuIFRoYXQncyB0aGUgcGxhbiBmb3IgTVRFIGFzIHdlbGwgKGlu
DQo+IGFkZGl0aW9uIG1heWJlIHRvIHNvbWUgRUxGIGZsYWcpLg0KPiANCj4+IGFzIGZvciBjaGVj
a2luZyB0aGUgbmV3IHN5c2NhbGwgYWJpOiBpIGRvbid0IHNlZSBtdWNoIHNlbWFudGljDQo+PiBk
aWZmZXJlbmNlIGJldHdlZW4gQVRfSFdDQVAgYW5kIEFUX0ZMQUdTIChlaXRoZXIgd2F5LCB0aGUg
dXNlcg0KPj4gaGFzIHRvIGNoZWNrIGEgZmVhdHVyZSBmbGFnIGJlZm9yZSB1c2luZyB0aGUgZmVh
dHVyZSBvZiB0aGUNCj4+IHVuZGVybHlpbmcgc3lzdGVtIGFuZCBpdCBkb2VzIG5vdCBtYXR0ZXIg
bXVjaCBpZiBpdCdzIGEgc3lzY2FsbA0KPj4gYWJpIGZlYXR1cmUgb3IgY3B1IGZlYXR1cmUpLCBi
dXQgaSBkb24ndCBzZWUgYW55dGhpbmcgd3JvbmcNCj4+IHdpdGggQVRfRkxBR1MgaWYgdGhlIGtl
cm5lbCBwcmVmZXJzIHRoYXQuDQo+IA0KPiBUaGUgQVRfRkxBR1MgaXMgYWltZWQgYXQgY2FwdHVy
aW5nIGJpbmFyeSAyIGNhc2UgYWJvdmUsIGkuZS4gdGhlDQo+IHJlbGF4YXRpb24gb2YgdGhlIHN5
c2NhbGwgQUJJIHRvIGFjY2VwdCB0YiA9IGFueS4gVGhlIE1URSBzdXBwb3J0IHdpbGwNCj4gaGF2
ZSBpdHMgb3duIEFUX0hXQ0FQLCBsaWtlbHkgaW4gYWRkaXRpb24gdG8gQVRfRkxBR1MuIEFyZ3Vh
Ymx5LA0KPiBBVF9GTEFHUyBpcyBlaXRoZXIgcmVkdW5kYW50IGhlcmUgaWYgTVRFIGltcGxpZXMg
aXQgKGFuZCBubyBoYXJtIGluDQo+IGtlZXBpbmcgaXQgYXJvdW5kKSBvciB0aGUgbWVhbmluZyBp
cyBkaWZmZXJlbnQ6IGEgdGIgIT0gMCBtYXkgYmUgY2hlY2tlZA0KPiBieSB0aGUga2VybmVsIGFn
YWluc3QgdGhlIGFsbG9jYXRpb24gdGFnIChpLmUuIGdldF91c2VyKCkgY291bGQgZmFpbCwNCj4g
dGhlIHRhZyBpcyBub3QgZW50aXJlbHkgaWdub3JlZCkuDQo+IA0KPj4gdGhlIGRpc2N1c3Npb24g
aGVyZSB3YXMgbW9zdGx5IGFib3V0IGJpbmFyeSAyLA0KPiANCj4gVGhhdCdzIGJlY2F1c2UgcGFz
c2luZyB0YiAhPSAwIGludG8gdGhlIHN5c2NhbGwgQUJJIGlzIHRoZSBtYWluIGJsb2NrZXINCj4g
aGVyZSB0aGF0IG5lZWRzIGNsZWFyaW5nIG91dCBiZWZvcmUgbWVyZ2luZyB0aGUgTVRFIHN1cHBv
cnQuIFRoZXJlIGlzLA0KPiBvZiBjb3Vyc2UsIGEgdmFyaWF0aW9uIG9mIGJpbmFyeSAxIGZvciBN
VEU6DQo+IA0KPiBiaW5hcnkgNTogdXNlciB0YiA9IG10ZSwgc3lzY2FsbCB0YiA9IDANCj4gDQo+
IGJ1dCB0aGlzIHJlcXVpcmVzIGEgbG90IG9mIEMgbGliIGNoYW5nZXMgdG8gc3VwcG9ydCBwcm9w
ZXJseS4NCg0KeWVzLCBpIGRvbid0IHRoaW5rIHdlIHdhbnQgdG8gZG8gdGhhdC4NCg0KYnV0IGl0
J3Mgb2sgdG8gaGF2ZSBib3RoIHN5c2NhbGwgdGJpIEFUX0ZMQUdTIGFuZCBNVEUgSFdDQVAuDQoN
Cj4+IGJ1dCBmb3INCj4+IG1lIHRoZSBvcGVuIHF1ZXN0aW9uIGlzIGlmIHdlIGNhbiBtYWtlIGJp
bmFyeSAzLzQgd29yay4NCj4+ICh3aGljaCByZXF1aXJlcyBzb21lIGVsZiBiaW5hcnkgbWFya2lu
ZywgdGhhdCBpcyByZWNvZ25pc2VkDQo+PiBieSB0aGUga2VybmVsIGFuZCBkeW5hbWljIGxvYWRl
ciwgYW5kIGVmZmljaWVudCBoYW5kbGluZyBvZg0KPj4gdGhlIFRCSTAgYml0LCAuLmlmIGl0J3Mg
bm90IHBvc3NpYmxlLCB0aGVuIGkgZG9uJ3Qgc2VlIGhvdw0KPj4gbXRlIHdpbGwgYmUgZGVwbG95
ZWQpLg0KPiANCj4gSWYgd2UgaWdub3JlIGJpbmFyeSAzLCB3ZSBjYW4ga2VlcCBUQkkwID0gMSBw
ZXJtYW5lbnRseSwgd2hldGhlciB3ZSBoYXZlDQo+IE1URSBvciBub3QuDQo+IA0KPj4gYW5kIGkg
Z3Vlc3Mgb24gdGhlIGtlcm5lbCBzaWRlIHRoZSBvcGVuIHF1ZXN0aW9uIGlzIGlmIHRoZQ0KPj4g
cnVsZXMgMS8yLzMvNCBjYW4gYmUgbWFkZSB0byB3b3JrIGluIGNvcm5lciBjYXNlcyBlLmcuIHdo
ZW4NCj4+IHBvaW50ZXJzIGVtYmVkZGVkIGludG8gc3RydWN0cyBhcmUgcGFzc2VkIGRvd24gaW4g
aW9jdGwuDQo+IA0KPiBXZSd2ZSBiZWVuIHRyeWluZyB0byB0cmFjayB0aGVzZSBkb3duIHNpbmNl
IGxhc3Qgc3VtbWVyIGFuZCB3ZSBjYW1lIHRvDQo+IHRoZSBjb25jbHVzaW9uIHRoYXQgaXQgc2hv
dWxkIGJlIChtb3N0bHkpIGZpbmUgZm9yIHRoZSBub24td2VpcmQgbWVtb3J5DQo+IGRlc2NyaWJl
ZCBhYm92ZS4NCg0KaSB0aGluayBhbiBpbnRlcmVzdGluZyBjYXNlIGlzIHdoZW4gdXNlcnNwYWNl
IHBhc3Nlcw0KYSBwb2ludGVyIHRvIHRoZSBrZXJuZWwgYW5kIGxhdGVyIGdldHMgaXQgYmFjaywN
CndoaWNoIGlzIHdoeSBpIHByb3Bvc2VkIHJ1bGUgNCAoa2VybmVsIGhhcyB0byBrZWVwDQp0aGUg
dGFnIHRoZW4pLg0KDQpidXQgaSB3b25kZXIgd2hhdCdzIHRoZSByaWdodCB0aGluZyB0byBkbyBm
b3Igc3ANCih1c2VyIGNhbiBtYWxsb2MgdGhyZWFkL3NpZ2FsdC9tYWtlY29udGV4dCBzdGFjaw0K
d2hpY2ggd2lsbCBiZSBtdGUgdGFnZ2VkIGluIHByYWN0aWNlIHdpdGggbXRlIG9uKQ0KZG9lcyB0
YWdnZWQgc3Agd29yaz8gc2hvdWxkIHVzZXJzcGFjZSB1bnRhZyB0aGUNCnN0YWNrIG1lbW9yeSBi
ZWZvcmUgc2V0dGluZyBpdCB1cCBhcyBhIHN0YWNrPw0KKGJ1dCB0aGVuIHVzZXIgcG9pbnRlcnMg
dG8gdGhhdCBhbGxvY2F0aW9uIG1heSBnZXQNCmJyb2tlbi4uKQ0K

