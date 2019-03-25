Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D98B7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:21:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E0F020811
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:21:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="wuV8oq1A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E0F020811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AD936B0003; Mon, 25 Mar 2019 18:21:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 033D86B0006; Mon, 25 Mar 2019 18:21:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFCF76B0007; Mon, 25 Mar 2019 18:21:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B60726B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:21:43 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x2so15906037ywc.7
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:21:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=rYTL1XEF7dKDcIcXORAZ7/fLGTeAC/CNeVMEnDZAAzg=;
        b=UWyiLqPDixbmiVD1yqmto3wz9wPl65sCyALUG+oCb925BtdKjpba3dnJ/zjzFNWFT7
         F2BuA0jCrMGrqx0B8rQhXS5rUwbqECTiNzq6hPmA8zo9N2EW0GrI9ArW2G8F+2DFnGEm
         p4z3L/pQrHsnQdlwf37mb770/e/oEuwDr+UEe+iC1xBG1wzawhehMBNww9s5eFAx0TzY
         6EK/gFK84gcixYje5ZxW/NB2PmdUoKGnnjgQ6zdYmathCBeHPQ4qOZJyJVa6XPoSmCOM
         vci96dWoHHykmTc6Z9pCBOF5DKmYcz2hPo7fUgn+enL8thhgCPkF95KGLqG1jjWJ+zVU
         USbA==
X-Gm-Message-State: APjAAAVGr8VOqoVjZ9ZS68Dtw0bnT5qD35m7T7j3dXs16anJNMeIodte
	BIcR6PMIiPFctHWLTPsbJHjNR0lSC44b9mE58OV+Cp2TeuUi38Tr2y+VVPyuoeby2u2Qgqt9MAH
	XiDwQ1S+hqJGOei1+bGrb0te0rd9xuTSTlqTi8yM+jgz6bY/bvFa2tk2i7Cppmsc=
X-Received: by 2002:a81:9110:: with SMTP id i16mr23852502ywg.174.1553552503483;
        Mon, 25 Mar 2019 15:21:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJAKurM+JONZh18PIBVicjQEsKS2AEvwIwPGIAlmxtA3JY4hbfHnmZT/wiLxnAuiLi3W3r
X-Received: by 2002:a81:9110:: with SMTP id i16mr23852382ywg.174.1553552501300;
        Mon, 25 Mar 2019 15:21:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553552501; cv=none;
        d=google.com; s=arc-20160816;
        b=UWfFgoyYhxMKkZIacJn/EGlqUaU5NW1nj+R2ykJqE0ipY9NzoENnix398R5gzkejOe
         FmM83gzDATYJsQ+LQlHhddiN427Q5RLnJ9v3SMv7MTtV6cCcm2YnSFhsP7dX3T5WZWGO
         T2pLcGK7Fi+VZiVKICYprzqWmitxqvkNrGEE4Pw29OWW3Nwh3cDxLo2MwxJen9T1m7Zs
         fFI06cpmHbbI9HzYncY2kulalNoYyf3qEa+TTPuu5ULmUkFTCN18z+5a4VaY7yirjVzZ
         /H2TEdEIeMdGsLpFgNoEEVDCQviNFgYKoHfxl8Yd3ioKeWZQcm4nC6EpIH87GNQCKXc7
         XoFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=rYTL1XEF7dKDcIcXORAZ7/fLGTeAC/CNeVMEnDZAAzg=;
        b=sO229bTaTRKZnnzDBXqO0LZ2NHtzaYauc6NovHKKFB/lT1UbQxSCgxmtPbx5dR7d5t
         1WRA5re31ZDDH7enSV/OKvLmrzi+CO5AGb9PLCBXFW0ijoBItwM4h5C74V+oiRavkhQk
         9OHlW8D2GkaMOQIaOThgz/fm6xKfqEDTlvBtXsyIEdauZ//mMXaeJXcg6KKXKAc+FJBU
         RXhsl2WrX25mi5CcPG9wBQQflaV+TrddEyOYjOV6QxiBVlZuH8UPq6Z/OJRKUv4nRubf
         tiIi87LrmBbTZbTyYafUKayQg40NlwNWg4bXByiLgzD8Sutt8I1JGf/PsEWQpHJ90YgC
         46Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=wuV8oq1A;
       spf=neutral (google.com: 40.107.80.45 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800045.outbound.protection.outlook.com. [40.107.80.45])
        by mx.google.com with ESMTPS id 127si8894871ybc.440.2019.03.25.15.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Mar 2019 15:21:41 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.80.45 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.80.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=wuV8oq1A;
       spf=neutral (google.com: 40.107.80.45 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rYTL1XEF7dKDcIcXORAZ7/fLGTeAC/CNeVMEnDZAAzg=;
 b=wuV8oq1APHHZewUsOugBehHf5zH0VRDpYaw6WX7iGcgwziH4fuVomGHsjVIdCT5nvjYKcYzgeUeCEWdFaAK4027D2ca0TpszTwRSKYKk46NPSrs0XvhGfBF9iJhE9292UOTSNeXJ8Q/rJcjATVZPSJnv7/WVsEb9g0gXfiISBrg=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3286.namprd12.prod.outlook.com (20.179.93.207) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Mon, 25 Mar 2019 22:21:35 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::e073:d670:f97c:3eb8]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::e073:d670:f97c:3eb8%7]) with mapi id 15.20.1730.019; Mon, 25 Mar 2019
 22:21:35 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas
	<catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland
	<mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook
	<keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton
	<akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Eric Dumazet
	<edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, Alexei
 Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Steven
 Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra
	<peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, "Zhou, David(ChunMing)" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab
	<mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, Alex
 Williamson <alex.williamson@redhat.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-arch@vger.kernel.org"
	<linux-arch@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Kevin Brodsky <kevin.brodsky@arm.com>, Chintan Pandya
	<cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben
 Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry
 Vyukov <dvyukov@google.com>, Ramana Radhakrishnan
	<Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck
	<luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Evgeniy
 Stepanov <eugenis@google.com>
Subject: Re: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
Thread-Topic: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
Thread-Index: AQHU3yyygJ3HP5e3/0iG1r4hvBquJ6Yc89QA
Date: Mon, 25 Mar 2019 22:21:34 +0000
Message-ID: <574648a3-3a05-bea7-3f4e-7d71adedf1dc@amd.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
In-Reply-To:
 <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
x-clientproxiedby: YTOPR0101CA0023.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::36) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cfdc1922-d69c-480b-2137-08d6b1703d75
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR12MB3286;
x-ms-traffictypediagnostic: BYAPR12MB3286:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR12MB32864797A7636BB9FE0C9C22925E0@BYAPR12MB3286.namprd12.prod.outlook.com>
x-forefront-prvs: 0987ACA2E2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(346002)(376002)(136003)(39860400002)(366004)(199004)(189003)(72206003)(71200400001)(6486002)(2201001)(25786009)(36756003)(4326008)(6436002)(105586002)(106356001)(256004)(2501003)(229853002)(71190400001)(86362001)(64126003)(31696002)(2906002)(3846002)(6116002)(186003)(102836004)(76176011)(26005)(476003)(65826007)(66066001)(58126008)(11346002)(2616005)(486006)(54906003)(6506007)(386003)(52116002)(316002)(53546011)(99286004)(7736002)(305945005)(97736004)(7406005)(110136005)(446003)(68736007)(6512007)(53936002)(6306002)(5660300002)(6246003)(7416002)(65806001)(31686004)(81166006)(81156014)(65956001)(8936002)(966005)(14454004)(8676002)(478600001)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3286;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Bid8SSG2UNNQt13kYVdMH6n73SVegbbK2HarO8wdkap6stlX0oL2MaEPmfTWO5tXxywiule/NhK8TE/H7/UoV4TMKMuud9NBUqGqK0izApIDCZ/91OcumRGWwrEVpzgs7klm/O/lWAHAo+7pf4/Sc/zXZ8aCW1ZNiCkr/8Ti1lhkIn+1c7TdRaLrrZfx8SZeWoHJ+SRuy4xwDYTRQkyq9J+YvRmvdu0rGF9qhK9klFT7PxgR99jGl95bdG/4wctoNT4or/nLZiL81s4wShHw/1yAXzH0yT0oWanALkMOfyrRcsKDzG91Ng7sfwH6o/XGDJ65tXrmPk5LUQn7jwbS8BpZGaYCz0PN0gmj5OgZljgK2uercUvHzxEJUoPL8cEVVFN2uat1vo1PpTsJ9hbtB+1WE0EYtgzIjIPGWu6NnPM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <CF30E59880AD324FB34B80E1527F955F@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cfdc1922-d69c-480b-2137-08d6b1703d75
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Mar 2019 22:21:34.9126
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3286
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wMy0yMCAxMDo1MSBhLm0uLCBBbmRyZXkgS29ub3ZhbG92IHdyb3RlOg0KPiBUaGlz
IHBhdGNoIGlzIGEgcGFydCBvZiBhIHNlcmllcyB0aGF0IGV4dGVuZHMgYXJtNjQga2VybmVsIEFC
SSB0byBhbGxvdyB0bw0KPiBwYXNzIHRhZ2dlZCB1c2VyIHBvaW50ZXJzICh3aXRoIHRoZSB0b3Ag
Ynl0ZSBzZXQgdG8gc29tZXRoaW5nIGVsc2Ugb3RoZXINCj4gdGhhbiAweDAwKSBhcyBzeXNjYWxs
IGFyZ3VtZW50cy4NCj4NCj4gYW1kZ3B1X3R0bV90dF9nZXRfdXNlcl9wYWdlcygpIHVzZXMgcHJv
dmlkZWQgdXNlciBwb2ludGVycyBmb3Igdm1hDQo+IGxvb2t1cHMsIHdoaWNoIGNhbiBvbmx5IGJ5
IGRvbmUgd2l0aCB1bnRhZ2dlZCBwb2ludGVycy4NCj4NCj4gVW50YWcgdXNlciBwb2ludGVycyBp
biB0aGlzIGZ1bmN0aW9uLg0KPg0KPiBTaWduZWQtb2ZmLWJ5OiBBbmRyZXkgS29ub3ZhbG92IDxh
bmRyZXlrbnZsQGdvb2dsZS5jb20+DQo+IC0tLQ0KPiAgIGRyaXZlcnMvZ3B1L2RybS9hbWQvYW1k
Z3B1L2FtZGdwdV90dG0uYyB8IDUgKysrLS0NCj4gICAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRp
b25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPg0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9ncHUvZHJt
L2FtZC9hbWRncHUvYW1kZ3B1X3R0bS5jIGIvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1k
Z3B1X3R0bS5jDQo+IGluZGV4IDczZTcxZTYxZGM5OS4uODkxYjAyN2ZhMzNiIDEwMDY0NA0KPiAt
LS0gYS9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfdHRtLmMNCj4gKysrIGIvZHJp
dmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X3R0bS5jDQo+IEBAIC03NTEsMTAgKzc1MSwx
MSBAQCBpbnQgYW1kZ3B1X3R0bV90dF9nZXRfdXNlcl9wYWdlcyhzdHJ1Y3QgdHRtX3R0ICp0dG0s
IHN0cnVjdCBwYWdlICoqcGFnZXMpDQo+ICAgCQkgKiBjaGVjayB0aGF0IHdlIG9ubHkgdXNlIGFu
b255bW91cyBtZW1vcnkgdG8gcHJldmVudCBwcm9ibGVtcw0KPiAgIAkJICogd2l0aCB3cml0ZWJh
Y2sNCj4gICAJCSAqLw0KPiAtCQl1bnNpZ25lZCBsb25nIGVuZCA9IGd0dC0+dXNlcnB0ciArIHR0
bS0+bnVtX3BhZ2VzICogUEFHRV9TSVpFOw0KPiArCQl1bnNpZ25lZCBsb25nIHVzZXJwdHIgPSB1
bnRhZ2dlZF9hZGRyKGd0dC0+dXNlcnB0cik7DQo+ICsJCXVuc2lnbmVkIGxvbmcgZW5kID0gdXNl
cnB0ciArIHR0bS0+bnVtX3BhZ2VzICogUEFHRV9TSVpFOw0KPiAgIAkJc3RydWN0IHZtX2FyZWFf
c3RydWN0ICp2bWE7DQo+ICAgDQo+IC0JCXZtYSA9IGZpbmRfdm1hKG1tLCBndHQtPnVzZXJwdHIp
Ow0KPiArCQl2bWEgPSBmaW5kX3ZtYShtbSwgdXNlcnB0cik7DQo+ICAgCQlpZiAoIXZtYSB8fCB2
bWEtPnZtX2ZpbGUgfHwgdm1hLT52bV9lbmQgPCBlbmQpIHsNCj4gICAJCQl1cF9yZWFkKCZtbS0+
bW1hcF9zZW0pOw0KPiAgIAkJCXJldHVybiAtRVBFUk07DQoNCldlJ2xsIG5lZWQgdG8gYmUgY2Fy
ZWZ1bCB0aGF0IHdlIGRvbid0IGJyZWFrIHlvdXIgY2hhbmdlIHdoZW4gdGhlIA0KZm9sbG93aW5n
IGNvbW1pdCBnZXRzIGFwcGxpZWQgdGhyb3VnaCBkcm0tbmV4dCBmb3IgTGludXggNS4yOg0KDQpo
dHRwczovL2NnaXQuZnJlZWRlc2t0b3Aub3JnL35hZ2Q1Zi9saW51eC9jb21taXQvP2g9ZHJtLW5l
eHQtNS4yLXdpcCZpZD05MTVkM2VlY2ZhMjM2OTNiYWM5ZTU0Y2RhY2Y4NGZiNGVmZGNjNWM0DQoN
CldvdWxkIGl0IG1ha2Ugc2Vuc2UgdG8gYXBwbHkgdGhlIHVudGFnZ2luZyBpbiBhbWRncHVfdHRt
X3R0X3NldF91c2VycHRyIA0KaW5zdGVhZD8gVGhhdCB3b3VsZCBhdm9pZCB0aGlzIGNvbmZsaWN0
IGFuZCBJIHRoaW5rIGl0IHdvdWxkIGNsZWFybHkgcHV0IA0KdGhlIHVudGFnZ2luZyBpbnRvIHRo
ZSB1c2VyIG1vZGUgY29kZSBwYXRoIHdoZXJlIHRoZSB0YWdnZWQgcG9pbnRlciANCm9yaWdpbmF0
ZXMuDQoNCkluIGFtZGdwdV9nZW1fdXNlcnB0cl9pb2N0bCBhbmQgYW1kZ3B1X2FtZGtmZF9ncHV2
bS5jIChpbml0X3VzZXJfcGFnZXMpIA0Kd2UgYWxzbyBzZXQgdXAgYW4gTU1VIG5vdGlmaWVyIHdp
dGggdGhlICh0YWdnZWQpIHBvaW50ZXIgZnJvbSB1c2VyIG1vZGUuIA0KVGhhdCBzaG91bGQgcHJv
YmFibHkgYWxzbyB1c2UgdGhlIHVudGFnZ2VkIGFkZHJlc3Mgc28gdGhhdCBNTVUgbm90aWZpZXJz
IA0KZm9yIHRoZSB1bnRhZ2dlZCBhZGRyZXNzIGdldCBjb3JyZWN0bHkgbWF0Y2hlZCB1cCB3aXRo
IHRoZSByaWdodCBCTy4gSSdkIA0KbW92ZSB0aGUgdW50YWdnaW5nIGZ1cnRoZXIgdXAgdGhlIGNh
bGwgc3RhY2sgdG8gY292ZXIgdGhhdC4gRm9yIHRoZSBHRU0gDQpjYXNlIEkgdGhpbmsgYW1kZ3B1
X2dlbV91c2VycHRyX2lvY3RsIHdvdWxkIGJlIHRoZSByaWdodCBwbGFjZS4gRm9yIHRoZSANCktG
RCBjYXNlLCBJJ2QgZG8gdGhpcyBpbiBhbWRncHVfYW1ka2ZkX2dwdXZtX2FsbG9jX21lbW9yeV9v
Zl9ncHUuDQoNClJlZ2FyZHMsDQogwqAgRmVsaXgNCg0K

