Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31A47C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4DE120700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="gIEpWEKb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4DE120700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D9828E0114; Fri, 22 Feb 2019 10:35:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389738E0109; Fri, 22 Feb 2019 10:35:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2545B8E0114; Fri, 22 Feb 2019 10:35:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA4A78E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:35:53 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a9so1102381edy.13
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:35:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=ZdAwO8uIP3NsdKEhCOqpTRThOTeSWorKOvbckf1ho+0=;
        b=YFlO3WGT+IMcABk20PKNDmv5kip7EHa4iJYzsQEjIj4FwVbkhDGMh/c3zdcCzknfFQ
         htab8xY/+yc67wSDxV70h2WmPQIy3QQhuPUznuAhJM4MRfCZh28twrovEwYaoDxOS7jU
         r4UYyDPr/cKXmu9ybXG7tnqCfTH2p4n17HgD3czLpSgTadWDSuz+vO15FWo8L/DHlOLm
         dWRjSzoyc3tcYB7dA8h9amjA6xOPd6sTZ+kIoYNmqNHylzsD1g9dsZ045suDq/MwAib6
         matLnXsiof4asB17cAQRQJN9mPT9lCb7cBWQLqKZk1wZDKNIqSCy1o21wTctWFWhRysT
         VLXg==
X-Gm-Message-State: AHQUAubz7nKPgE3Wx0NQWt7rMal79mwM5z8Z0TULnECsENGe95jycI8u
	mayqrtJLLfFcyL4Agf8dMAbHAGalgSiz/yJDzWxvoFq+CCxJfTnom1Z6YfdAFSt8J7DcI6gYGBt
	QrSKZBYHm9PEtaaonynUB+YZ+tXRfdgFQkYwAgF1OL14r3glt2xlBHwEbtXTu8ix7zw==
X-Received: by 2002:a05:6402:1495:: with SMTP id e21mr3674375edv.52.1550849753092;
        Fri, 22 Feb 2019 07:35:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbZ9A6H2Q2c3JO2FOhbuXkOp0DqpQz5rwB8TQAjn59+OATdXnCa4YtwY7cmTArOumCUbyFC
X-Received: by 2002:a05:6402:1495:: with SMTP id e21mr3674276edv.52.1550849751610;
        Fri, 22 Feb 2019 07:35:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550849751; cv=none;
        d=google.com; s=arc-20160816;
        b=gtgApqy1H5n6GUexNOZD9YGYJaCRA9IGKEXwL88vrhOU8TRQM6fYRrzk7aWtCm7IHn
         jFOtQFgSnYv2i30JxJwXfsk07BoFivpFYLk+jq2pKbcudhzRYaMwJ0sC0+T78IzlTTkH
         L9qAuo4t+M3wSS9PQV1hjF3qkK2vxev07hCB+Wtil/i/sKAgxwA48gYevhKQy5qkxkOV
         gR7eq8+3O3lXlmE/c1M7CdibyLtZv1tf2O0tdvnCbiGimrwdwKKaUwgoHKUATrscW6GS
         N5y22aqhkERqKYey3zO/yqMUc3RywWq35KRkRatmxB6RiqK6884YJzqe3OjVhs6pF7pj
         M5aQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=ZdAwO8uIP3NsdKEhCOqpTRThOTeSWorKOvbckf1ho+0=;
        b=l17r1j8mBk3zE0M0nrMmwNSZpy9HpoaqfofTFCpR8MSBlyLBuwamzg7qhgMYj4r9bC
         0BWhOIpbPnM+WnMc4ehOtfFWCFzT40ClrSrU7wQNv6ta/hICfmCWFVWq9gGKufFwawyK
         HaOnay4mHoDSAFQaElN9ZIGpRhCKMD1ZXn5cozsTZLXeSOnKV2OOxfP+hLhsYdBgU55z
         j8vZayWgHTb0duJUEf1FIEKQU6BwyfmOTZFEkeumR6d7Pfqc3aaGvP4fOYsFC1A+p9cA
         OHJBFec8COI2fSNy7mZmxsr0CuIkSxG4JbQUj3TVu2W9B5kgEwKOeiGeUKQ8UJWd5MoU
         CwxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=gIEpWEKb;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.77 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140077.outbound.protection.outlook.com. [40.107.14.77])
        by mx.google.com with ESMTPS id v6si796249edm.178.2019.02.22.07.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Feb 2019 07:35:51 -0800 (PST)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.77 as permitted sender) client-ip=40.107.14.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=gIEpWEKb;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.77 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZdAwO8uIP3NsdKEhCOqpTRThOTeSWorKOvbckf1ho+0=;
 b=gIEpWEKb6ylZNyX+FlBWEQy0yqhR+UAN8jOIjhqJvVDlAO5GUtN398kkuAIQCtIuK+EZ4MWUHICdiJn8/aSKb+FZ1iC75nLEEtmgbW6xDmPdAvs6YUZBD/PPxnxy1GVciNycpV2bTW1nxnpyhcQwKxxYlmnaE+xYFY3tahlVQ60=
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com (20.178.13.96) by
 VI1PR08MB0766.eurprd08.prod.outlook.com (10.164.93.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.18; Fri, 22 Feb 2019 15:35:49 +0000
Received: from VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52]) by VI1PR08MB4223.eurprd08.prod.outlook.com
 ([fe80::896c:c125:b2a3:2f52%6]) with mapi id 15.20.1622.021; Fri, 22 Feb 2019
 15:35:49 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas
	<Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, Mark Rutland
	<Mark.Rutland@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, Kees Cook
	<keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton
	<akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <Vincenzo.Frascino@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-doc@vger.kernel.org"
	<linux-doc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: nd <nd@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany
	<kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith
	<Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan
	<Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, Luc Van
 Oostenryck <luc.vanoostenryck@gmail.com>, Dave P Martin
	<Dave.Martin@arm.com>, Kevin Brodsky <Kevin.Brodsky@arm.com>
Subject: Re: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
Thread-Topic: [PATCH v10 00/12] arm64: untag user pointers passed to the
 kernel
Thread-Index: AQHUyq2dD9o2nPb5w0GtvSKm/T3roaXr8zMA
Date: Fri, 22 Feb 2019 15:35:48 +0000
Message-ID: <464111f3-e255-ad45-8964-58462d889e6f@arm.com>
References: <cover.1550839937.git.andreyknvl@google.com>
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.53]
x-clientproxiedby: LO2P265CA0475.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a2::31) To VI1PR08MB4223.eurprd08.prod.outlook.com
 (2603:10a6:803:b5::32)
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4cba8019-b5cd-4f9e-970b-08d698db6b5d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB0766;
x-ms-traffictypediagnostic: VI1PR08MB0766:
x-ms-exchange-purlcount: 4
nodisclaimer: True
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB0766;20:cv68ELb5zWfc7mF+5WNJGa1kPyWGLYlzb8YDz4e6l82XcMG8kPaYg5indr1tl9Ixh0kiGJ06J6jNTN1E1lj2ZL6oW1APkshgV5iyBLs03jMTmbELiGgcZI9SmFNeN6RBV0s+UJ91iZXGdaVdeLhXFzIA2MscfJn40WlwI5sOW1A=
x-microsoft-antispam-prvs:
 <VI1PR08MB076666D747E327A913BD48B0ED7F0@VI1PR08MB0766.eurprd08.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(366004)(376002)(346002)(136003)(199004)(189003)(58126008)(2501003)(81156014)(54906003)(14444005)(81166006)(8676002)(256004)(4326008)(5660300002)(3846002)(386003)(6346003)(26005)(6506007)(53546011)(102836004)(6116002)(8936002)(71190400001)(65956001)(66066001)(966005)(65806001)(71200400001)(31696002)(86362001)(6246003)(2201001)(76176011)(316002)(14454004)(186003)(110136005)(25786009)(7416002)(11346002)(52116002)(65826007)(486006)(476003)(2616005)(72206003)(478600001)(97736004)(2906002)(44832011)(53936002)(446003)(31686004)(99286004)(105586002)(6512007)(64126003)(6486002)(305945005)(106356001)(7736002)(68736007)(229853002)(36756003)(6306002)(6436002)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB0766;H:VI1PR08MB4223.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 HG3IjifQ3jFx0wQuui5wy+3URNR7OBWcojov90KtaTDGjxHppstPuy37VxowuOSoQ8ge+1OK52IrKk2No9z4rz8F0GNrP4MP2yTPOy9F2sreE1nMPpiIYU4vxIhn/3bdhL7RqauJw35Qv8MwQUvB9aF+KA8YlZHtfOp7YTNBwv2mRWVIrKIEeVyDLur1YCRsD8uOAyzhUHUOSo+lWVlWYmma6BH24OQZvYKQGZNRqfFMDDL3euBuTf0j8DgVPWZboG48Z3V8xBt2XfcdH/9frjwIb8xED2sF9RjuO9xhlWvAcU9mK+0vj/5J26AwL914u+jjCqcbxgNZqCX0io8uL9VEysQ3IOhIDR35XTpp1Ukw7dKuqQ3KFpE12McbvAbd+OoLvXXsXVIAqfiL9yrvTcpmizEatpem/lL6zGzP0hg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E07F0DA7F425EE419E984E8B46948B43@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4cba8019-b5cd-4f9e-970b-08d698db6b5d
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 15:35:47.2379
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB0766
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjIvMDIvMjAxOSAxMjo1MywgQW5kcmV5IEtvbm92YWxvdiB3cm90ZToNCj4gVGhpcyBwYXRj
aHNldCBpcyBtZWFudCB0byBiZSBtZXJnZWQgdG9nZXRoZXIgd2l0aCAiYXJtNjQgcmVsYXhlZCBB
QkkiIFsxXS4NCj4gDQo+IGFybTY0IGhhcyBhIGZlYXR1cmUgY2FsbGVkIFRvcCBCeXRlIElnbm9y
ZSwgd2hpY2ggYWxsb3dzIHRvIGVtYmVkIHBvaW50ZXINCj4gdGFncyBpbnRvIHRoZSB0b3AgYnl0
ZSBvZiBlYWNoIHBvaW50ZXIuIFVzZXJzcGFjZSBwcm9ncmFtcyAoc3VjaCBhcw0KPiBIV0FTYW4s
IGEgbWVtb3J5IGRlYnVnZ2luZyB0b29sIFsyXSkgbWlnaHQgdXNlIHRoaXMgZmVhdHVyZSBhbmQg
cGFzcw0KPiB0YWdnZWQgdXNlciBwb2ludGVycyB0byB0aGUga2VybmVsIHRocm91Z2ggc3lzY2Fs
bHMgb3Igb3RoZXIgaW50ZXJmYWNlcy4NCj4gDQo+IFJpZ2h0IG5vdyB0aGUga2VybmVsIGlzIGFs
cmVhZHkgYWJsZSB0byBoYW5kbGUgdXNlciBmYXVsdHMgd2l0aCB0YWdnZWQNCj4gcG9pbnRlcnMs
IGR1ZSB0byB0aGVzZSBwYXRjaGVzOg0KPiANCj4gMS4gODFjZGRkNjUgKCJhcm02NDogdHJhcHM6
IGZpeCB1c2Vyc3BhY2UgY2FjaGUgbWFpbnRlbmFuY2UgZW11bGF0aW9uIG9uIGENCj4gICAgICAg
ICAgICAgIHRhZ2dlZCBwb2ludGVyIikNCj4gMi4gN2RjZDlkZDggKCJhcm02NDogaHdfYnJlYWtw
b2ludDogZml4IHdhdGNocG9pbnQgbWF0Y2hpbmcgZm9yIHRhZ2dlZA0KPiAJICAgICAgcG9pbnRl
cnMiKQ0KPiAzLiAyNzZlOTMyNyAoImFybTY0OiBlbnRyeTogaW1wcm92ZSBkYXRhIGFib3J0IGhh
bmRsaW5nIG9mIHRhZ2dlZA0KPiAJICAgICAgcG9pbnRlcnMiKQ0KPiANCj4gVGhpcyBwYXRjaHNl
dCBleHRlbmRzIHRhZ2dlZCBwb2ludGVyIHN1cHBvcnQgdG8gc3lzY2FsbCBhcmd1bWVudHMuDQo+
IA0KPiBGb3Igbm9uLW1lbW9yeSBzeXNjYWxscyB0aGlzIGlzIGRvbmUgYnkgdW50YWdpbmcgdXNl
ciBwb2ludGVycyB3aGVuIHRoZQ0KPiBrZXJuZWwgcGVyZm9ybXMgcG9pbnRlciBjaGVja2luZyB0
byBmaW5kIG91dCB3aGV0aGVyIHRoZSBwb2ludGVyIGNvbWVzDQo+IGZyb20gdXNlcnNwYWNlICht
b3N0IG5vdGFibHkgaW4gYWNjZXNzX29rKS4gVGhlIHVudGFnZ2luZyBpcyBkb25lIG9ubHkNCj4g
d2hlbiB0aGUgcG9pbnRlciBpcyBiZWluZyBjaGVja2VkLCB0aGUgdGFnIGlzIHByZXNlcnZlZCBh
cyB0aGUgcG9pbnRlcg0KPiBtYWtlcyBpdHMgd2F5IHRocm91Z2ggdGhlIGtlcm5lbC4NCj4gDQo+
IFNpbmNlIG1lbW9yeSBzeXNjYWxscyAobW1hcCwgbXByb3RlY3QsIGV0Yy4pIGRvbid0IGRvIG1l
bW9yeSBhY2Nlc3NlcyBidXQNCj4gcmF0aGVyIGRlYWwgd2l0aCBtZW1vcnkgcmFuZ2VzLCB1bnRh
Z2dlZCBwb2ludGVycyBhcmUgYmV0dGVyIHN1aXRlZCB0bw0KPiBkZXNjcmliZSBtZW1vcnkgcmFu
Z2VzIGludGVybmFsbHkuIFRodXMgZm9yIG1lbW9yeSBzeXNjYWxscyB3ZSB1bnRhZw0KPiBwb2lu
dGVycyBjb21wbGV0ZWx5IHdoZW4gdGhleSBlbnRlciB0aGUga2VybmVsLg0KDQppIHRoaW5rIHRo
ZSBzYW1lIGlzIHRydWUgd2hlbiB1c2VyIHBvaW50ZXJzIGFyZSBjb21wYXJlZC4NCg0KZS5nLiBp
IHN1c3BlY3QgdGhlcmUgbWF5IGJlIGlzc3VlcyB3aXRoIHRhZ2dlZCByb2J1c3QgbXV0ZXgNCmxp
c3QgcG9pbnRlcnMgYmVjYXVzZSB0aGUga2VybmVsIGRvZXMNCg0KZnV0ZXguYzozNTQxOgl3aGls
ZSAoZW50cnkgIT0gJmhlYWQtPmxpc3QpIHsNCg0Kd2hlcmUgZW50cnkgaXMgYSB1c2VyIHBvaW50
ZXIgdGhhdCBtYXkgYmUgdGFnZ2VkLCBhbmQNCiZoZWFkLT5saXN0IGlzIHByb2JhYmx5IG5vdCB0
YWdnZWQuDQoNCj4gT25lIG9mIHRoZSBhbHRlcm5hdGl2ZSBhcHByb2FjaGVzIHRvIHVudGFnZ2lu
ZyB0aGF0IHdhcyBjb25zaWRlcmVkIGlzIHRvDQo+IGNvbXBsZXRlbHkgc3RyaXAgdGhlIHBvaW50
ZXIgdGFnIGFzIHRoZSBwb2ludGVyIGVudGVycyB0aGUga2VybmVsIHdpdGgNCj4gc29tZSBraW5k
IG9mIGEgc3lzY2FsbCB3cmFwcGVyLCBidXQgdGhhdCB3b24ndCB3b3JrIHdpdGggdGhlIGNvdW50
bGVzcw0KPiBudW1iZXIgb2YgZGlmZmVyZW50IGlvY3RsIGNhbGxzLiBXaXRoIHRoaXMgYXBwcm9h
Y2ggd2Ugd291bGQgbmVlZCBhIGN1c3RvbQ0KPiB3cmFwcGVyIGZvciBlYWNoIGlvY3RsIHZhcmlh
dGlvbiwgd2hpY2ggZG9lc24ndCBzZWVtIHByYWN0aWNhbC4NCj4gDQo+IFRoZSBmb2xsb3dpbmcg
dGVzdGluZyBhcHByb2FjaGVzIGhhcyBiZWVuIHRha2VuIHRvIGZpbmQgcG90ZW50aWFsIGlzc3Vl
cw0KPiB3aXRoIHVzZXIgcG9pbnRlciB1bnRhZ2dpbmc6DQo+IA0KPiAxLiBTdGF0aWMgdGVzdGlu
ZyAod2l0aCBzcGFyc2UgWzNdIGFuZCBzZXBhcmF0ZWx5IHdpdGggYSBjdXN0b20gc3RhdGljDQo+
ICAgIGFuYWx5emVyIGJhc2VkIG9uIENsYW5nKSB0byB0cmFjayBjYXN0cyBvZiBfX3VzZXIgcG9p
bnRlcnMgdG8gaW50ZWdlcg0KPiAgICB0eXBlcyB0byBmaW5kIHBsYWNlcyB3aGVyZSB1bnRhZ2dp
bmcgbmVlZHMgdG8gYmUgZG9uZS4NCj4gDQo+IDIuIFN0YXRpYyB0ZXN0aW5nIHdpdGggZ3JlcCB0
byBmaW5kIHBhcnRzIG9mIHRoZSBrZXJuZWwgdGhhdCBjYWxsDQo+ICAgIGZpbmRfdm1hKCkgKGFu
ZCBvdGhlciBzaW1pbGFyIGZ1bmN0aW9ucykgb3IgZGlyZWN0bHkgY29tcGFyZSBhZ2FpbnN0DQo+
ICAgIHZtX3N0YXJ0L3ZtX2VuZCBmaWVsZHMgb2Ygdm1hLg0KPiANCj4gMy4gU3RhdGljIHRlc3Rp
bmcgd2l0aCBncmVwIHRvIGZpbmQgcGFydHMgb2YgdGhlIGtlcm5lbCB0aGF0IGNvbXBhcmUNCj4g
ICAgdXNlciBwb2ludGVycyB3aXRoIFRBU0tfU0laRSBvciBvdGhlciBzaW1pbGFyIGNvbnN0cyBh
bmQgbWFjcm9zLg0KPiANCj4gNC4gRHluYW1pYyB0ZXN0aW5nOiBhZGRpbmcgQlVHX09OKGhhc190
YWcoYWRkcikpIHRvIGZpbmRfdm1hKCkgYW5kIHJ1bm5pbmcNCj4gICAgYSBtb2RpZmllZCBzeXpr
YWxsZXIgdmVyc2lvbiB0aGF0IHBhc3NlcyB0YWdnZWQgcG9pbnRlcnMgdG8gdGhlIGtlcm5lbC4N
Cj4gDQo+IEJhc2VkIG9uIHRoZSByZXN1bHRzIG9mIHRoZSB0ZXN0aW5nIHRoZSByZXF1cmllZCBw
YXRjaGVzIGhhdmUgYmVlbiBhZGRlZA0KPiB0byB0aGUgcGF0Y2hzZXQuDQo+IA0KPiBUaGlzIHBh
dGNoc2V0IGhhcyBiZWVuIG1lcmdlZCBpbnRvIHRoZSBQaXhlbCAyIGtlcm5lbCB0cmVlIGFuZCBp
cyBub3cNCj4gYmVpbmcgdXNlZCB0byBlbmFibGUgdGVzdGluZyBvZiBQaXhlbCAyIHBob25lcyB3
aXRoIEhXQVNhbi4NCj4gDQo+IFRoaXMgcGF0Y2hzZXQgaXMgYSBwcmVyZXF1aXNpdGUgZm9yIEFS
TSdzIG1lbW9yeSB0YWdnaW5nIGhhcmR3YXJlIGZlYXR1cmUNCj4gc3VwcG9ydCBbNF0uDQo+IA0K
PiBUaGFua3MhDQo+IA0KPiBbMV0gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTgvMTIvMTAvNDAy
DQo+IA0KPiBbMl0gaHR0cDovL2NsYW5nLmxsdm0ub3JnL2RvY3MvSGFyZHdhcmVBc3Npc3RlZEFk
ZHJlc3NTYW5pdGl6ZXJEZXNpZ24uaHRtbA0KPiANCj4gWzNdIGh0dHBzOi8vZ2l0aHViLmNvbS9s
dWN2b28vc3BhcnNlLWRldi9jb21taXQvNWY5NjBjYjEwZjU2ZWMyMDE3YzEyOGVmOWQxNjA2MGUw
MTQ1ZjI5Mg0KPiANCj4gWzRdIGh0dHBzOi8vY29tbXVuaXR5LmFybS5jb20vcHJvY2Vzc29ycy9i
L2Jsb2cvcG9zdHMvYXJtLWEtcHJvZmlsZS1hcmNoaXRlY3R1cmUtMjAxOC1kZXZlbG9wbWVudHMt
YXJtdjg1YQ0KPiANCj4gQ2hhbmdlcyBpbiB2MTA6DQo+IC0gQWRkZWQgIm1tLCBhcm02NDogdW50
YWcgdXNlciBwb2ludGVycyBwYXNzZWQgdG8gbWVtb3J5IHN5c2NhbGxzIiBiYWNrLg0KPiAtIE5l
dyBwYXRjaCAiZnMsIGFybTY0OiB1bnRhZyB1c2VyIHBvaW50ZXJzIGluIGZzL3VzZXJmYXVsdGZk
LmMiLg0KPiAtIE5ldyBwYXRjaCAibmV0LCBhcm02NDogdW50YWcgdXNlciBwb2ludGVycyBpbiB0
Y3BfemVyb2NvcHlfcmVjZWl2ZSIuDQo+IC0gTmV3IHBhdGNoICJrZXJuZWwsIGFybTY0OiB1bnRh
ZyB1c2VyIHBvaW50ZXJzIGluIHByY3RsX3NldF9tbSoiLg0KPiAtIE5ldyBwYXRjaCAidHJhY2lu
ZywgYXJtNjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gc2VxX3ByaW50X3VzZXJfaXAiLg0KPiAN
Cj4gQ2hhbmdlcyBpbiB2OToNCj4gLSBSZWJhc2VkIG9udG8gNC4yMC1yYzYuDQo+IC0gVXNlZCB1
NjQgaW5zdGVhZCBvZiBfX3U2NCBpbiB0eXBlIGNhc3RzIGluIHRoZSB1bnRhZ2dlZF9hZGRyIG1h
Y3JvIGZvcg0KPiAgIGFybTY0Lg0KPiAtIEFkZGVkIGJyYWNlcyBhcm91bmQgKGFkZHIpIGluIHRo
ZSB1bnRhZ2dlZF9hZGRyIG1hY3JvIGZvciBvdGhlciBhcmNoZXMuDQo+IA0KPiBDaGFuZ2VzIGlu
IHY4Og0KPiAtIFJlYmFzZWQgb250byA2NTEwMjIzOCAoNC4yMC1yYzEpLg0KPiAtIEFkZGVkIGEg
bm90ZSB0byB0aGUgY292ZXIgbGV0dGVyIG9uIHdoeSBzeXNjYWxsIHdyYXBwZXJzL3NoaW1zIHRo
YXQgdW50YWcNCj4gICB1c2VyIHBvaW50ZXJzIHdvbid0IHdvcmsuDQo+IC0gQWRkZWQgYSBub3Rl
IHRvIHRoZSBjb3ZlciBsZXR0ZXIgdGhhdCB0aGlzIHBhdGNoc2V0IGhhcyBiZWVuIG1lcmdlZCBp
bnRvDQo+ICAgdGhlIFBpeGVsIDIga2VybmVsIHRyZWUuDQo+IC0gRG9jdW1lbnRhdGlvbiBmaXhl
cywgaW4gcGFydGljdWxhciBhZGRlZCBhIGxpc3Qgb2Ygc3lzY2FsbHMgdGhhdCBkb24ndA0KPiAg
IHN1cHBvcnQgdGFnZ2VkIHVzZXIgcG9pbnRlcnMuDQo+IA0KPiBDaGFuZ2VzIGluIHY3Og0KPiAt
IFJlYmFzZWQgb250byAxN2I1N2IxOCAoNC4xOS1yYzYpLg0KPiAtIERyb3BwZWQgdGhlICJhcm02
NDogdW50YWcgdXNlciBhZGRyZXNzIGluIF9fZG9fdXNlcl9mYXVsdCIgcGF0Y2gsIHNpbmNlDQo+
ICAgdGhlIGV4aXN0aW5nIHBhdGNoZXMgYWxyZWFkeSBoYW5kbGUgdXNlciBmYXVsdHMgcHJvcGVy
bHkuDQo+IC0gRHJvcHBlZCB0aGUgInVzYiwgYXJtNjQ6IHVudGFnIHVzZXIgYWRkcmVzc2VzIGlu
IGRldmlvIiBwYXRjaCwgc2luY2UgdGhlDQo+ICAgcGFzc2VkIHBvaW50ZXIgbXVzdCBjb21lIGZy
b20gYSB2bWEgYW5kIHRoZXJlZm9yZSBiZSB1bnRhZ2dlZC4NCj4gLSBEcm9wcGVkIHRoZSAiYXJt
NjQ6IGFubm90YXRlIHVzZXIgcG9pbnRlcnMgY2FzdHMgZGV0ZWN0ZWQgYnkgc3BhcnNlIg0KPiAg
IHBhdGNoIChzZWUgdGhlIGRpc2N1c3Npb24gdG8gdGhlIHJlcGxpZXMgb2YgdGhlIHY2IG9mIHRo
aXMgcGF0Y2hzZXQpLg0KPiAtIEFkZGVkIG1vcmUgY29udGV4dCB0byB0aGUgY292ZXIgbGV0dGVy
Lg0KPiAtIFVwZGF0ZWQgRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0Lg0K
PiANCj4gQ2hhbmdlcyBpbiB2NjoNCj4gLSBBZGRlZCBhbm5vdGF0aW9ucyBmb3IgdXNlciBwb2lu
dGVyIGNhc3RzIGZvdW5kIGJ5IHNwYXJzZS4NCj4gLSBSZWJhc2VkIG9udG8gMDUwY2RjNmMgKDQu
MTktcmMxKykuDQo+IA0KPiBDaGFuZ2VzIGluIHY1Og0KPiAtIEFkZGVkIDMgbmV3IHBhdGNoZXMg
dGhhdCBhZGQgdW50YWdnaW5nIHRvIHBsYWNlcyBmb3VuZCB3aXRoIHN0YXRpYw0KPiAgIGFuYWx5
c2lzLg0KPiAtIFJlYmFzZWQgb250byA0NGM5MjllMSAoNC4xOC1yYzgpLg0KPiANCj4gQ2hhbmdl
cyBpbiB2NDoNCj4gLSBBZGRlZCBhIHNlbGZ0ZXN0IGZvciBjaGVja2luZyB0aGF0IHBhc3Npbmcg
dGFnZ2VkIHBvaW50ZXJzIHRvIHRoZQ0KPiAgIGtlcm5lbCBzdWNjZWVkcy4NCj4gLSBSZWJhc2Vk
IG9udG8gODFlOTdmMDEzICg0LjE4LXJjMSspLg0KPiANCj4gQ2hhbmdlcyBpbiB2MzoNCj4gLSBS
ZWJhc2VkIG9udG8gZTVjNTFmMzAgKDQuMTctcmM2KykuDQo+IC0gQWRkZWQgbGludXgtYXJjaEAg
dG8gdGhlIGxpc3Qgb2YgcmVjaXBpZW50cy4NCj4gDQo+IENoYW5nZXMgaW4gdjI6DQo+IC0gUmVi
YXNlZCBvbnRvIDJkNjE4YmRmICg0LjE3LXJjMyspLg0KPiAtIFJlbW92ZWQgZXhjZXNzaXZlIHVu
dGFnZ2luZyBpbiBndXAuYy4NCj4gLSBSZW1vdmVkIHVudGFnZ2luZyBwb2ludGVycyByZXR1cm5l
ZCBmcm9tIF9fdWFjY2Vzc19tYXNrX3B0ci4NCj4gDQo+IENoYW5nZXMgaW4gdjE6DQo+IC0gUmVi
YXNlZCBvbnRvIDQuMTctcmMxLg0KPiANCj4gQ2hhbmdlcyBpbiBSRkMgdjI6DQo+IC0gQWRkZWQg
IiNpZm5kZWYgdW50YWdnZWRfYWRkci4uLiIgZmFsbGJhY2sgaW4gbGludXgvdWFjY2Vzcy5oIGlu
c3RlYWQgb2YNCj4gICBkZWZpbmluZyBpdCBmb3IgZWFjaCBhcmNoIGluZGl2aWR1YWxseS4NCj4g
LSBVcGRhdGVkIERvY3VtZW50YXRpb24vYXJtNjQvdGFnZ2VkLXBvaW50ZXJzLnR4dC4NCj4gLSBE
cm9wcGVkICJtbSwgYXJtNjQ6IHVudGFnIHVzZXIgYWRkcmVzc2VzIGluIG1lbW9yeSBzeXNjYWxs
cyIuDQo+IC0gUmViYXNlZCBvbnRvIDNlYjJjZTgyICg0LjE2LXJjNykuDQo+IA0KPiBSZXZpZXdl
ZC1ieTogTHVjIFZhbiBPb3N0ZW5yeWNrIDxsdWMudmFub29zdGVucnlja0BnbWFpbC5jb20+DQo+
IFNpZ25lZC1vZmYtYnk6IEFuZHJleSBLb25vdmFsb3YgPGFuZHJleWtudmxAZ29vZ2xlLmNvbT4N
Cj4gDQo+IEFuZHJleSBLb25vdmFsb3YgKDEyKToNCj4gICB1YWNjZXNzOiBhZGQgdW50YWdnZWRf
YWRkciBkZWZpbml0aW9uIGZvciBvdGhlciBhcmNoZXMNCj4gICBhcm02NDogdW50YWcgdXNlciBw
b2ludGVycyBpbiBhY2Nlc3Nfb2sgYW5kIF9fdWFjY2Vzc19tYXNrX3B0cg0KPiAgIGxpYiwgYXJt
NjQ6IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gc3RybipfdXNlcg0KPiAgIG1tLCBhcm02NDogdW50
YWcgdXNlciBwb2ludGVycyBwYXNzZWQgdG8gbWVtb3J5IHN5c2NhbGxzDQo+ICAgbW0sIGFybTY0
OiB1bnRhZyB1c2VyIHBvaW50ZXJzIGluIG1tL2d1cC5jDQo+ICAgZnMsIGFybTY0OiB1bnRhZyB1
c2VyIHBvaW50ZXJzIGluIGNvcHlfbW91bnRfb3B0aW9ucw0KPiAgIGZzLCBhcm02NDogdW50YWcg
dXNlciBwb2ludGVycyBpbiBmcy91c2VyZmF1bHRmZC5jDQo+ICAgbmV0LCBhcm02NDogdW50YWcg
dXNlciBwb2ludGVycyBpbiB0Y3BfemVyb2NvcHlfcmVjZWl2ZQ0KPiAgIGtlcm5lbCwgYXJtNjQ6
IHVudGFnIHVzZXIgcG9pbnRlcnMgaW4gcHJjdGxfc2V0X21tKg0KPiAgIHRyYWNpbmcsIGFybTY0
OiB1bnRhZyB1c2VyIHBvaW50ZXJzIGluIHNlcV9wcmludF91c2VyX2lwDQo+ICAgYXJtNjQ6IHVw
ZGF0ZSBEb2N1bWVudGF0aW9uL2FybTY0L3RhZ2dlZC1wb2ludGVycy50eHQNCj4gICBzZWxmdGVz
dHMsIGFybTY0OiBhZGQgYSBzZWxmdGVzdCBmb3IgcGFzc2luZyB0YWdnZWQgcG9pbnRlcnMgdG8g
a2VybmVsDQo+IA0KPiAgRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0ICAg
ICAgIHwgMjUgKysrKysrKysrKystLS0tLS0tLQ0KPiAgYXJjaC9hcm02NC9pbmNsdWRlL2FzbS91
YWNjZXNzLmggICAgICAgICAgICAgIHwgMTAgKysrKystLS0NCj4gIGZzL25hbWVzcGFjZS5jICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8ICAyICstDQo+ICBmcy91c2VyZmF1bHRmZC5j
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfCAgNSArKysrDQo+ICBpbmNsdWRlL2xpbnV4
L21lbW9yeS5oICAgICAgICAgICAgICAgICAgICAgICAgfCAgNCArKysNCj4gIGlwYy9zaG0uYyAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8ICAyICsrDQo+ICBrZXJuZWwvc3lz
LmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfCAxNCArKysrKysrKysrKw0KPiAg
a2VybmVsL3RyYWNlL3RyYWNlX291dHB1dC5jICAgICAgICAgICAgICAgICAgIHwgIDIgKy0NCj4g
IGxpYi9zdHJuY3B5X2Zyb21fdXNlci5jICAgICAgICAgICAgICAgICAgICAgICB8ICAyICsrDQo+
ICBsaWIvc3Rybmxlbl91c2VyLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgfCAgMiArKw0K
PiAgbW0vZ3VwLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDQgKysr
DQo+ICBtbS9tYWR2aXNlLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfCAgMiAr
Kw0KPiAgbW0vbWVtcG9saWN5LmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwgIDUg
KysrKw0KPiAgbW0vbWlncmF0ZS5jICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwg
IDEgKw0KPiAgbW0vbWluY29yZS5jICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHwg
IDIgKysNCj4gIG1tL21sb2NrLmMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8
ICA1ICsrKysNCj4gIG1tL21tYXAuYyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICB8ICA3ICsrKysrKw0KPiAgbW0vbXByb3RlY3QuYyAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIHwgIDIgKysNCj4gIG1tL21yZW1hcC5jICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICB8ICAyICsrDQo+ICBtbS9tc3luYy5jICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgfCAgMiArKw0KPiAgbmV0L2lwdjQvdGNwLmMgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIHwgIDIgKysNCj4gIHRvb2xzL3Rlc3Rpbmcvc2VsZnRlc3RzL2FybTY0Ly5naXRp
Z25vcmUgICAgICB8ICAxICsNCj4gIHRvb2xzL3Rlc3Rpbmcvc2VsZnRlc3RzL2FybTY0L01ha2Vm
aWxlICAgICAgICB8IDExICsrKysrKysrDQo+ICAuLi4vdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQv
cnVuX3RhZ3NfdGVzdC5zaCAgfCAxMiArKysrKysrKysNCj4gIHRvb2xzL3Rlc3Rpbmcvc2VsZnRl
c3RzL2FybTY0L3RhZ3NfdGVzdC5jICAgICB8IDE5ICsrKysrKysrKysrKysrDQo+ICAyNSBmaWxl
cyBjaGFuZ2VkLCAxMjkgaW5zZXJ0aW9ucygrKSwgMTYgZGVsZXRpb25zKC0pDQo+ICBjcmVhdGUg
bW9kZSAxMDA2NDQgdG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQvLmdpdGlnbm9yZQ0KPiAg
Y3JlYXRlIG1vZGUgMTAwNjQ0IHRvb2xzL3Rlc3Rpbmcvc2VsZnRlc3RzL2FybTY0L01ha2VmaWxl
DQo+ICBjcmVhdGUgbW9kZSAxMDA3NTUgdG9vbHMvdGVzdGluZy9zZWxmdGVzdHMvYXJtNjQvcnVu
X3RhZ3NfdGVzdC5zaA0KPiAgY3JlYXRlIG1vZGUgMTAwNjQ0IHRvb2xzL3Rlc3Rpbmcvc2VsZnRl
c3RzL2FybTY0L3RhZ3NfdGVzdC5jDQo+IA0KDQo=

