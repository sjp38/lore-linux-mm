Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1DDBC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:30:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DD7520874
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:30:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="lyyV+knA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DD7520874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0C156B0005; Wed, 12 Jun 2019 08:30:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABB026B000A; Wed, 12 Jun 2019 08:30:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95B136B0269; Wed, 12 Jun 2019 08:30:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 418976B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:30:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d13so25704326edo.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:30:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=JzsvQupAN+gcQeJKOQ2o7kyCHqxsW5uqpl6ZC5jXWRk=;
        b=JSUe1fqehjaU+xKlR9T7H2VqbeVmt+2xhRLKPidEi0VaViRUjjOFvkXi6kn0Z40kNF
         U9YiA9Jf1OTPGNLQY9e+SEaydYa7xXcNL02UV4pSFwvcD4vi2EDRxj2wEo4tjJjcHAvo
         aHws7YldNlbxDQJ8/4uYkXpHIcGlfw8wmkjq6kytNBWMrOIMwta3NTNwBF6vKjjSlQDW
         UQMDtWh9KJ9JTPDB2X0RizT3xl5sk6znHd4ejNzIHOLeB5zf5mBtYxb+1h8noc/B8THx
         uUTnNbynzknaOjPWijGJ3RpYhzDSmyS8CGmK6qDVtBThdrNpL32GhoequBLAH/p6if6Z
         M/TA==
X-Gm-Message-State: APjAAAXcSF6oKYqGREbRSogYtshK2mRuHAIEem4rYLh/x6J7QicLrlaC
	dsOe19ziLGITJHu2zWiSIb2caZ+pjypJeP3h3lPrhUttSkhWpZy3o57KpjOyQH6HFSEWd6647su
	XnAoiLCZFFKseFCJNZynz4d20PDDWzJB+5VPueLJBm3QA5x2M8QXlBNuunJbRmuCVcA==
X-Received: by 2002:a50:972a:: with SMTP id c39mr51974773edb.46.1560342641793;
        Wed, 12 Jun 2019 05:30:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZKJdRnVFHof68cnwbPp+ohpeSAfx5rqyWOQL1dfNlM1xdGzFbqcev1zM6wp+9sDNeZwtR
X-Received: by 2002:a50:972a:: with SMTP id c39mr51974700edb.46.1560342640994;
        Wed, 12 Jun 2019 05:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560342640; cv=none;
        d=google.com; s=arc-20160816;
        b=0H3ZFx3YXTWsfBjY1ywwhUDpR0s4S3d2/qES6XL4XP95yX71luJ/heyYuM4m5hAryO
         lUoXVRGa26ngpq9RWGkEfkGZPmIyXeG3QKKK6notxqd9Wrec+Ikh3DXijOvq7960pw7W
         knkjtlwPOUjHcvawiO81sGTOtRaEBFpepW0zfStdBrJGlBnclNAx/13FKofOQFBDVD52
         olV9j9EG11ODyQPD53FZ2aQIMy5/1oJ66wkonZY3wIQuf3A3ICgvzvwCa5huQaJsau4y
         jJBPTUSl0JobSwaYYy7mb0yQ4/ez2jJtLrtvlW1jLK5Ts5AqY4r6UQhThx6upzUyRXTx
         rLhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=JzsvQupAN+gcQeJKOQ2o7kyCHqxsW5uqpl6ZC5jXWRk=;
        b=gqNfj8djJOOQsrMyLG8Dhr3kqH/eO3gp1ANuljvYC0Zr8zmzH51+DfgEsafmVEkPC5
         gz+UcA4o+Rfuxgks1UmZR85XbV+GGgS/RBK04l695Wut+wgyrfYr45B0AIqKVJ+sNmLp
         y+C9C//KHpl60Iyfb73fwTytZLzwcM6SAhl8Qr0sHrlUF33gFXk+b8E+/xJgmQtvy2P+
         Mwqu6qx5joJMixlZOCEWxYqhOCujSntUKtaqMRnB5xl5L0RpqB86J+iuSGq79Q5aWvwA
         3ERal8E3uzwF6UgcQcz44Aa2vJYmSszbcnIJRie722cWihLMcGL3r0s1xacuAt7lnYSA
         DROg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=lyyV+knA;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140048.outbound.protection.outlook.com. [40.107.14.48])
        by mx.google.com with ESMTPS id f49si9614835edd.361.2019.06.12.05.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Jun 2019 05:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.48 as permitted sender) client-ip=40.107.14.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=lyyV+knA;
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.48 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JzsvQupAN+gcQeJKOQ2o7kyCHqxsW5uqpl6ZC5jXWRk=;
 b=lyyV+knAeziQlFW3VAseHnfQhMeAPOBow4sOExqkD8yABODe6h2ys+HaOKmmRD7k0RGvgQFtdmUr94ZzBTLNwpUr8yUWvXC4eDca9cYEcy4Wv9u2GhxYaD28QvlVs1Z2FPXYNvyTf5L5+PGLYMR+e6AVV0HQdQBoCWncF+7qt3U=
Received: from VE1PR08MB4637.eurprd08.prod.outlook.com (10.255.27.14) by
 VE1PR08MB4735.eurprd08.prod.outlook.com (10.255.112.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.13; Wed, 12 Jun 2019 12:30:36 +0000
Received: from VE1PR08MB4637.eurprd08.prod.outlook.com
 ([fe80::6574:1efb:6972:2b37]) by VE1PR08MB4637.eurprd08.prod.outlook.com
 ([fe80::6574:1efb:6972:2b37%6]) with mapi id 15.20.1965.017; Wed, 12 Jun 2019
 12:30:36 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>
CC: nd <nd@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Vincenzo
 Frascino <Vincenzo.Frascino@arm.com>, Will Deacon <Will.Deacon@arm.com>, Mark
 Rutland <Mark.Rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab
	<mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, Alex
 Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave P Martin
	<Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh
	<enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig
	<hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany
	<kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith
	<Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan
	<Ruben.Ayrapetyan@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, Kevin
 Brodsky <Kevin.Brodsky@arm.com>
Subject: Re: [PATCH v17 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Thread-Topic: [PATCH v17 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Thread-Index: AQHVIRQxA9mqrEC18UGUWJeO7iZYdKaX8xmA
Date: Wed, 12 Jun 2019 12:30:36 +0000
Message-ID: <7cd942c0-d4c1-0cf4-623a-bce6ef14d992@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <e024234e652f23be4d76d63227de114e7def5dff.1560339705.git.andreyknvl@google.com>
In-Reply-To:
 <e024234e652f23be4d76d63227de114e7def5dff.1560339705.git.andreyknvl@google.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
x-originating-ip: [217.140.106.51]
x-clientproxiedby: LO2P265CA0242.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:8a::14) To VE1PR08MB4637.eurprd08.prod.outlook.com
 (2603:10a6:802:b1::14)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 99aee353-e532-4d6e-08cc-08d6ef31c543
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VE1PR08MB4735;
x-ms-traffictypediagnostic: VE1PR08MB4735:
nodisclaimer: True
x-microsoft-antispam-prvs:
 <VE1PR08MB47350D33F85267298368A6C2EDEC0@VE1PR08MB4735.eurprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0066D63CE6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(136003)(376002)(366004)(346002)(189003)(199004)(316002)(4326008)(31696002)(86362001)(7416002)(2201001)(6436002)(2501003)(36756003)(58126008)(65826007)(2906002)(6116002)(8936002)(6246003)(5660300002)(6486002)(3846002)(64126003)(81166006)(52116002)(72206003)(6506007)(54906003)(478600001)(7736002)(68736007)(81156014)(8676002)(99286004)(14454004)(53546011)(102836004)(446003)(66446008)(25786009)(229853002)(11346002)(110136005)(64756008)(65956001)(6512007)(44832011)(66946007)(71200400001)(65806001)(73956011)(53936002)(66556008)(486006)(66066001)(76176011)(256004)(2616005)(31686004)(71190400001)(66476007)(186003)(476003)(386003)(305945005)(26005)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:VE1PR08MB4735;H:VE1PR08MB4637.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 rJ7Myflk/nypTg5f/73dOS7TRRDm+ghZMw88lkc6ZS3BTX3mf2YWXxdJzopWcQoL+pAtHst4LESGB/sFDMU+kDQCtDQ+N+Upw9oABmGwY3Jy1gBzj7BSNJp1sURm642fb5Pkq7vtCJgFYckY+lBpldYk8jnSQbto+SdV3gcndh4C0LoM49y2iwNfmuoKloc2y92N8CyhF511nLoJpEz/xiIcVGmKuwLZyB7L25ujm5gBnome5V0sIaDqhG0ksFSH0LDlVbPwP6o+x3QrNzJQNOKIyCDmikUF4ih2Nhjycxg4HponMHE7rOEo8kqCuaen/dv/NTUk+5qsdMeZHR3GpdeK0+GyDmLONCcLE3PYhZiy5U2URnQY+8ThUrKJeBBHOfWlb6Hbv3WyXRxWifzYMdF3ZI9EvU+z8dvP99lbyvY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2FA45C6A3FFA994DA2213028275DFA44@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 99aee353-e532-4d6e-08cc-08d6ef31c543
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2019 12:30:36.6121
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Szabolcs.Nagy@arm.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VE1PR08MB4735
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMTIvMDYvMjAxOSAxMjo0MywgQW5kcmV5IEtvbm92YWxvdiB3cm90ZToNCj4gLS0tIC9kZXYv
bnVsbA0KPiArKysgYi90b29scy90ZXN0aW5nL3NlbGZ0ZXN0cy9hcm02NC90YWdzX2xpYi5jDQo+
IEBAIC0wLDAgKzEsNjIgQEANCj4gKy8vIFNQRFgtTGljZW5zZS1JZGVudGlmaWVyOiBHUEwtMi4w
DQo+ICsNCj4gKyNpbmNsdWRlIDxzdGRsaWIuaD4NCj4gKyNpbmNsdWRlIDxzeXMvcHJjdGwuaD4N
Cj4gKw0KPiArI2RlZmluZSBUQUdfU0hJRlQJKDU2KQ0KPiArI2RlZmluZSBUQUdfTUFTSwkoMHhm
ZlVMIDw8IFRBR19TSElGVCkNCj4gKw0KPiArI2RlZmluZSBQUl9TRVRfVEFHR0VEX0FERFJfQ1RS
TAk1NQ0KPiArI2RlZmluZSBQUl9HRVRfVEFHR0VEX0FERFJfQ1RSTAk1Ng0KPiArI2RlZmluZSBQ
Ul9UQUdHRURfQUREUl9FTkFCTEUJKDFVTCA8PCAwKQ0KPiArDQo+ICt2b2lkICpfX2xpYmNfbWFs
bG9jKHNpemVfdCBzaXplKTsNCj4gK3ZvaWQgX19saWJjX2ZyZWUodm9pZCAqcHRyKTsNCj4gK3Zv
aWQgKl9fbGliY19yZWFsbG9jKHZvaWQgKnB0ciwgc2l6ZV90IHNpemUpOw0KPiArdm9pZCAqX19s
aWJjX2NhbGxvYyhzaXplX3Qgbm1lbWIsIHNpemVfdCBzaXplKTsNCg0KdGhpcyBkb2VzIG5vdCB3
b3JrIG9uIGF0IGxlYXN0IG11c2wuDQoNCnRoZSBtb3N0IHJvYnVzdCBzb2x1dGlvbiB3b3VsZCBi
ZSB0byBpbXBsZW1lbnQNCnRoZSBtYWxsb2MgYXBpcyB3aXRoIG1tYXAvbXVubWFwL21yZW1hcCwg
aWYgdGhhdCdzDQp0b28gY3VtYmVyc29tZSB0aGVuIHVzZSBkbHN5bSBSVExEX05FWFQgKGFsdGhv
dWdoDQp0aGF0IGhhcyB0aGUgc2xpZ2h0IHdhcnQgdGhhdCBpbiBnbGliYyBpdCBtYXkgY2FsbA0K
Y2FsbG9jIHNvIHdyYXBwaW5nIGNhbGxvYyB0aGF0IHdheSBpcyB0cmlja3kpLg0KDQppbiBzaW1w
bGUgbGludXggdGVzdHMgaSdkIGp1c3QgdXNlIHN0YXRpYyBvcg0Kc3RhY2sgYWxsb2NhdGlvbnMg
b3IgbW1hcC4NCg0KaWYgYSBnZW5lcmljIHByZWxvYWRhYmxlIGxpYiBzb2x1dGlvbiBpcyBuZWVk
ZWQNCnRoZW4gZG8gaXQgcHJvcGVybHkgd2l0aCBwdGhyZWFkX29uY2UgdG8gYXZvaWQNCnJhY2Vz
IGV0Yy4NCg0KPiArDQo+ICtzdGF0aWMgdm9pZCAqdGFnX3B0cih2b2lkICpwdHIpDQo+ICt7DQo+
ICsJc3RhdGljIGludCB0YWdnZWRfYWRkcl9lcnIgPSAxOw0KPiArCXVuc2lnbmVkIGxvbmcgdGFn
ID0gMDsNCj4gKw0KPiArCS8qDQo+ICsJICogTm90ZSB0aGF0IHRoaXMgY29kZSBpcyByYWN5LiBX
ZSBvbmx5IHVzZSBpdCBhcyBhIHBhcnQgb2YgYSBzaW5nbGUNCj4gKwkgKiB0aHJlYWRlZCB0ZXN0
IGFwcGxpY2F0aW9uLiBCZXdhcmUgb2YgdXNpbmcgaW4gbXVsdGl0aHJlYWRlZCBvbmVzLg0KPiAr
CSAqLw0KPiArCWlmICh0YWdnZWRfYWRkcl9lcnIgPT0gMSkNCj4gKwkJdGFnZ2VkX2FkZHJfZXJy
ID0gcHJjdGwoUFJfU0VUX1RBR0dFRF9BRERSX0NUUkwsDQo+ICsJCQkJUFJfVEFHR0VEX0FERFJf
RU5BQkxFLCAwLCAwLCAwKTsNCj4gKw0KPiArCWlmICghcHRyKQ0KPiArCQlyZXR1cm4gcHRyOw0K
PiArCWlmICghdGFnZ2VkX2FkZHJfZXJyKQ0KPiArCQl0YWcgPSByYW5kKCkgJiAweGZmOw0KPiAr
DQo+ICsJcmV0dXJuICh2b2lkICopKCh1bnNpZ25lZCBsb25nKXB0ciB8ICh0YWcgPDwgVEFHX1NI
SUZUKSk7DQo+ICt9DQo+ICsNCj4gK3N0YXRpYyB2b2lkICp1bnRhZ19wdHIodm9pZCAqcHRyKQ0K
PiArew0KPiArCXJldHVybiAodm9pZCAqKSgodW5zaWduZWQgbG9uZylwdHIgJiB+VEFHX01BU0sp
Ow0KPiArfQ0KPiArDQo+ICt2b2lkICptYWxsb2Moc2l6ZV90IHNpemUpDQo+ICt7DQo+ICsJcmV0
dXJuIHRhZ19wdHIoX19saWJjX21hbGxvYyhzaXplKSk7DQo+ICt9DQouLi4NCg==

