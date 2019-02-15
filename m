Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36065C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:01:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B53D2192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:01:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=virtuozzo.com header.i=@virtuozzo.com header.b="RU3EU3x+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B53D2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F66C8E0002; Fri, 15 Feb 2019 17:01:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3B08E0001; Fri, 15 Feb 2019 17:01:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16E738E0002; Fri, 15 Feb 2019 17:01:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B639D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:01:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id u7so4465971edj.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:01:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=3W5UlzZWve2oLpsWzekoZqMv0wretQeJahaAQpJBU48=;
        b=pKAunhl3kFlFGdOgSZIePKBtDeUq/Z9IEz2pzkFZ8mIyTDSyQ6/Na35LEi+SkONAAk
         30Zq+/hzuK6osi9iT4S8kyv4W34bMfziNekJ6+8uDj+QvM1d2QAJ9OtDalPpxk6/I4R/
         qhqbN3mVk1uQnDPz2Njv112Hl+8ctjUH37Fz5j64AO7uJKGYfQk0rXFY1LdvCBAXuWm1
         QxNBvWR0auoM8vx5nftB25Sh8XUm2MKucbOuw2L5EAtF1pp764vNCzC0AcesVCAumIOC
         81Ec9d+DS2P+hkus3YbSJ36aGZ29tJCcJQNU/S9s021Hl5YhvAB5Njz7QkO5udwR0Nf2
         ckbw==
X-Gm-Message-State: AHQUAuZXX1Qw0kEeBskhpBL+7i1afIa6Ig6UVOqPjDRAp8wgz91azkqp
	bvOubXD7s5eZ5PVgcN8GiednDnMKz/y6SFVMeDbda5/jjQFuXoeb7DKnnSNAxCymAt2EffQcTUB
	gm5ai1CRSnMU/gJHAEuy1GnMmIe/6HZZ1cyh3Iovze/t3cp8NyrhdV9ojdWoflz0vKw==
X-Received: by 2002:a50:d311:: with SMTP id g17mr8893915edh.187.1550268069273;
        Fri, 15 Feb 2019 14:01:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWeIsVc431wnxdHPOySFpprI1x7RF0rexWCNeIpEX4LFVGzFzU90pSuAZbGLTA8K7Fwgyx
X-Received: by 2002:a50:d311:: with SMTP id g17mr8893875edh.187.1550268068386;
        Fri, 15 Feb 2019 14:01:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268068; cv=none;
        d=google.com; s=arc-20160816;
        b=mz3KBd1peqBksIwVJoMR6VRWnxKppH+w7ZBk+eos/807F1WcYg1uzJtO4cU2sVGnUw
         9JtO0I+qgjly4VaEMcLVZDHdpQ75LC25v3jOd28/KhYcRuBkBbsOTnkxOVFzB+rF3ivx
         du6eTyJSaM+1ixULBt7/hoY17ZPsYCDc7xW7NucWE03MM0vRLg9cP9zzxUWiPpgjXxbQ
         XpDvtPo++bEV5I7jvU3FSsrxC2ocKhPrIcy+zs87a1K6KqLQEsSuKDpoElqJE9mMfrWJ
         oSJHK4aczN3w7fmYtuT/wpEf4JMpKR2XHBjnL0O5SqyhucIL4sjfK91mZZiHyD/Ric8I
         dhuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=3W5UlzZWve2oLpsWzekoZqMv0wretQeJahaAQpJBU48=;
        b=LLDi0Ktq5V7H5sEjZyDcLb1T8NenSRNn2QsKA1XzFqaJhqLPlhBGD6YmKIUYsemD9y
         DqjO7d1x7r14jLWB4c5QCEaG5Ui+Ygp/CuvnMyDYm2uWiOo78yprErOChLuQoJau5ZLi
         OlJGB1gzabV3u/l5AbfY8hBS1AQnJEQtgCzfOINzXtBRhW9FKLNP0d9hbdvd1I67RByZ
         PQJLqwr5Qi3czwNsnR7oyUUBoL/Wd2w64y5aFzbsycR1fPZhuMG2C3FSdHs7e91ZudE0
         pn2THyCjAGMjhB3H4QJRDnXasbZHxgyxIuPgRL6883Rhbg6FZD2d3t/C5qDEjcAAWIJh
         3Ldw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=RU3EU3x+;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.7.135 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70135.outbound.protection.outlook.com. [40.107.7.135])
        by mx.google.com with ESMTPS id o13si14809ejh.93.2019.02.15.14.01.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Feb 2019 14:01:08 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.7.135 as permitted sender) client-ip=40.107.7.135;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=RU3EU3x+;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.7.135 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3W5UlzZWve2oLpsWzekoZqMv0wretQeJahaAQpJBU48=;
 b=RU3EU3x++7YGKzvzqZ+y+d/v+zFj78IUVHXKKm/DxJRSpEyZ4hEiXxlZhsq2OWRUodbsxWiwIHONRF7ZvSuJSI/0rJFg6pgl+czsMTiRdd0wNGgUJID4OAbAR4SB6xu5f7jwRoDSInCUI+skIEkOmOWjA9QQ+G8nBUa0iBmEHvA=
Received: from DB7PR08MB3771.eurprd08.prod.outlook.com (20.178.47.26) by
 DB7PR08MB3673.eurprd08.prod.outlook.com (20.177.120.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Fri, 15 Feb 2019 22:01:06 +0000
Received: from DB7PR08MB3771.eurprd08.prod.outlook.com
 ([fe80::59ce:a552:89d5:47b9]) by DB7PR08MB3771.eurprd08.prod.outlook.com
 ([fe80::59ce:a552:89d5:47b9%5]) with mapi id 15.20.1601.023; Fri, 15 Feb 2019
 22:01:06 +0000
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com"
	<mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 4/4] mm: Generalize putback scan functions
Thread-Topic: [PATCH v2 4/4] mm: Generalize putback scan functions
Thread-Index: AQHUxFEL53fZZeHOl0uxGT7DbkvR8aXhVHOAgAAWcQA=
Date: Fri, 15 Feb 2019 22:01:05 +0000
Message-ID: <b2fcd214-52a5-6284-81b9-8a09de27fbea@virtuozzo.com>
References:
 <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
 <155014053725.28944.7960592286711533914.stgit@localhost.localdomain>
 <20190215203926.ldpfniqwpn7rtqif@ca-dmjordan1.us.oracle.com>
In-Reply-To: <20190215203926.ldpfniqwpn7rtqif@ca-dmjordan1.us.oracle.com>
Accept-Language: ru-RU, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: HE1PR06CA0144.eurprd06.prod.outlook.com
 (2603:10a6:7:16::31) To DB7PR08MB3771.eurprd08.prod.outlook.com
 (2603:10a6:10:7c::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=ktkhai@virtuozzo.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [128.69.177.17]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 07d24579-30dd-4718-5126-08d693911546
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:DB7PR08MB3673;
x-ms-traffictypediagnostic: DB7PR08MB3673:
x-microsoft-exchange-diagnostics:
 1;DB7PR08MB3673;20:zPeykguNM5ppb1GzTGxHHyrM1PCMD/FKOkV0nTJZK/FBpDnuMsvFWY4mHauaPs04tz6M675ueFjRVLLWmeq2EK4Zl76Z3D3gOQjWskRxYwB/utlrUJVrPbmHC7GVgwZ+PM4L8A7pWNF1PnemhFZi+zxvdxvbeMRGMacI6LQYz4A=
x-microsoft-antispam-prvs:
 <DB7PR08MB36737D1A4CA15C60E470F913CD600@DB7PR08MB3673.eurprd08.prod.outlook.com>
x-forefront-prvs: 09497C15EB
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(366004)(346002)(136003)(396003)(39850400004)(376002)(199004)(189003)(86362001)(6916009)(476003)(6512007)(102836004)(8936002)(486006)(31696002)(68736007)(26005)(97736004)(66066001)(6506007)(6486002)(2906002)(386003)(316002)(446003)(55236004)(11346002)(6436002)(6246003)(53936002)(256004)(478600001)(5660300002)(2616005)(25786009)(54906003)(99286004)(106356001)(76176011)(81166006)(81156014)(105586002)(53546011)(8676002)(7736002)(14454004)(52116002)(3846002)(36756003)(186003)(71190400001)(71200400001)(229853002)(4326008)(31686004)(305945005)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:DB7PR08MB3673;H:DB7PR08MB3771.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: virtuozzo.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 MabVeYNV7iwGWqfI9vr21SLoNKF/9vHzD3qSDh6ftM9hfWxUgp8SpoipjTNp9Jm1KrwZGGR1NneemsL/ydb7pcGomICW/IWJl/mTEaim86UHxKmmwdZ+f6GAmQkwvHIx0ijruZGKJYaU6PMHctBAwr9lZDsCPRitzNysQIdAv6/jMh6GLFH19ea6kkYFIHMaI2s8SbBbm2VtHMx2ZQPYIPgiLTb3yUro4AeiVlKCcGhJAcITRGJco1sMhIp82pto5HeHpyRgWL7Vv3O/jSGebZFzkWdwfT8zdW+LNLGLCyFQPIJmZz3VUQ0841/YdAzzUnd8Gnt71CE26VKohGNavofWgw9mhCQ2sbdmr2irHIplwRSJL3CRzZhwkYSVnHIFPBKALQSXD84+kFrumMmIrS/upCRk0iS7nMRxeMD7ur8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C117B143E78C6C45940299C83D4F7C6F@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: virtuozzo.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 07d24579-30dd-4718-5126-08d693911546
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Feb 2019 22:01:04.8008
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 0bc7f26d-0264-416e-a6fc-8352af79c58f
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3673
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMTUuMDIuMjAxOSAyMzozOSwgRGFuaWVsIEpvcmRhbiB3cm90ZToNCj4gT24gVGh1LCBGZWIg
MTQsIDIwMTkgYXQgMDE6MzU6MzdQTSArMDMwMCwgS2lyaWxsIFRraGFpIHdyb3RlOg0KPj4gK3N0
YXRpYyB1bnNpZ25lZCBub2lubGluZV9mb3Jfc3RhY2sgbW92ZV9wYWdlc190b19scnUoc3RydWN0
IGxydXZlYyAqbHJ1dmVjLA0KPj4gKwkJCQkJCSAgICAgc3RydWN0IGxpc3RfaGVhZCAqbGlzdCkN
Cj4+ICB7DQo+PiAgCXN0cnVjdCBwZ2xpc3RfZGF0YSAqcGdkYXQgPSBscnV2ZWNfcGdkYXQobHJ1
dmVjKTsNCj4+ICsJaW50IG5yX3BhZ2VzLCBucl9tb3ZlZCA9IDA7DQo+PiAgCUxJU1RfSEVBRChw
YWdlc190b19mcmVlKTsNCj4+ICsJc3RydWN0IHBhZ2UgKnBhZ2U7DQo+PiArCWVudW0gbHJ1X2xp
c3QgbHJ1Ow0KPj4gIA0KPj4gLQkvKg0KPj4gLQkgKiBQdXQgYmFjayBhbnkgdW5mcmVlYWJsZSBw
YWdlcy4NCj4+IC0JICovDQo+PiAtCXdoaWxlICghbGlzdF9lbXB0eShwYWdlX2xpc3QpKSB7DQo+
PiAtCQlzdHJ1Y3QgcGFnZSAqcGFnZSA9IGxydV90b19wYWdlKHBhZ2VfbGlzdCk7DQo+PiAtCQlp
bnQgbHJ1Ow0KPj4gLQ0KPj4gKwl3aGlsZSAoIWxpc3RfZW1wdHkobGlzdCkpIHsNCj4+ICsJCXBh
Z2UgPSBscnVfdG9fcGFnZShsaXN0KTsNCj4+ICAJCVZNX0JVR19PTl9QQUdFKFBhZ2VMUlUocGFn
ZSksIHBhZ2UpOw0KPj4gLQkJbGlzdF9kZWwoJnBhZ2UtPmxydSk7DQo+PiAgCQlpZiAodW5saWtl
bHkoIXBhZ2VfZXZpY3RhYmxlKHBhZ2UpKSkgew0KPj4gKwkJCWxpc3RfZGVsX2luaXQoJnBhZ2Ut
PmxydSk7DQo+IA0KPiBXaHkgY2hhbmdlIHRvIGxpc3RfZGVsX2luaXQ/ICBJdCdzIG1vcmUgc3Bl
Y2lhbCB0aGFuIGxpc3RfZGVsIGJ1dCBkb2Vzbid0IHNlZW0NCj4gbmVlZGVkIHNpbmNlIHRoZSBw
YWdlIGlzIGxpc3RfYWRkKCllZCBsYXRlci4NCg0KTm90IHNvbWV0aGluZyBzcGVjaWFsIGlzIGhl
cmUsIEknbGwgcmVtb3ZlIHRoaXMgX2luaXQuDQogDQo+IFRoYXQgcG9zdHByb2Nlc3Mgc2NyaXB0
IGZyb20gcGF0Y2ggMSBzZWVtcyBraW5kYSBicm9rZW4gYmVmb3JlIHRoaXMgc2VyaWVzLCBhbmQN
Cj4gc3RpbGwgaXMuICBOb3QgdGhhdCBpdCBzaG91bGQgYmxvY2sgdGhpcyBjaGFuZ2UuICBPdXQg
b2YgY3VyaW9zaXR5IGRpZCB5b3UgZ2V0DQo+IGl0IHRvIHJ1bj8NCg0KSSBmaXhlZCBhbGwgbmV3
IHdhcm5pbmdzLCB3aGljaCBjb21lIHdpdGggbXkgY2hhbmdlcywgc28gdGhlIHBhdGNoIGRvZXMg
bm90IG1ha2UNCnRoZSBzY3JpcHQgd29yc2UuDQoNCklmIHlvdSBjaGFuZ2UgYWxsIGFscmVhZHkg
ZXhpc3Rpbmcgd2FybmluZ3MgYnkgcmVuYW1pbmcgdmFyaWFibGVzIGluIGFwcHJvcHJpYXRlDQpw
bGFjZXMsIHRoZSBzY3JpcHQgd2lsbCB3b3JrIGluIHNvbWUgd2F5LiBCdXQgSSdtIG5vdCBzdXJl
IHRoaXMgaXMgZW5vdWdoIHRvIGdldA0KcmVzdWx0cyBjb3JyZWN0LCBhbmQgSSBoYXZlIG5vIGEg
YmlnIHdpc2ggdG8gZGl2ZSBpbnRvIHBlcmwgdG8gZml4IHdhcm5pbmdzDQppbnRyb2R1Y2VkIGJ5
IGFub3RoZXIgcGVvcGxlLCBzbyBJIGRvbid0IHBsYW4gdG8gZG8gd2l0aCB0aGlzIHNjcmlwdCBz
b21ldGhpbmcgZWxzZS4NCg==

