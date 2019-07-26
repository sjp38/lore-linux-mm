Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 505EEC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BF8D2166E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="BPvqDOZ8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BF8D2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99A006B0003; Thu, 25 Jul 2019 20:16:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94B8C6B0005; Thu, 25 Jul 2019 20:16:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EC078E0002; Thu, 25 Jul 2019 20:16:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5116B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:16:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so33076096edt.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:16:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=0q7KETf8VOgdRydYjPeN0MMEKPYfp/4tpTOPqZtr/E0=;
        b=nNNiOVlBniKUHZmPAKEkrSoCvwlhUPJLQpPpgvYrk6nLBcZMRMJttU7/1LgZE78OaI
         dVQ5Cjo7Z7+MDhCsvwQ+SV27mmob6A+OmcztDX9e/DJmpnfiY6uDaldnAXCTbRgZpUAi
         bLnaqlrJi1QROS2aCRbrtBqu+Yb2GVVWQH7ovNX1y9FEcUlQUs754eKO1mymf4+FumpH
         AcHnqNAzjoaPL549Szpz5wLtPwQbQ0N13voDW9Z2fMGu1B3RCr9EF67q+QvX2WKvdzPD
         0c0PRQ8HERN6j1gyQBqA51jPD0QcSODG8dCd7Vl5xznlZitXbeVYEIZFXLV/FIRA3f+Z
         A56Q==
X-Gm-Message-State: APjAAAW66n2hwjyeqqebGofj4lylqy9/fGlURHjrprB6K14gtqchzpg+
	z35W3+Q39WVEfZl6/f9AW4x91jsg2yYcuIN1SanNPQAS54SfwOHFk2aPmMYwUvbQ2Jx7Oowfqea
	SyMYGePbaP77ChSTvMegfXAsUuY+AazY24GGg73JBI2VQTSTb6YtBPQIYY1gSzXR0zA==
X-Received: by 2002:a50:cd91:: with SMTP id p17mr80990176edi.35.1564100192749;
        Thu, 25 Jul 2019 17:16:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRpmmK0vLUp0b5qBerduZBVO55uHUhGWvT06JOa5z+5iy3xCxOmIp3QCnU01kaNpthgj1R
X-Received: by 2002:a50:cd91:: with SMTP id p17mr80990127edi.35.1564100192088;
        Thu, 25 Jul 2019 17:16:32 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564100192; cv=pass;
        d=google.com; s=arc-20160816;
        b=R+hzzRb9x/f/Cfq1B+ZABrbwtwCd3TauJa0aR2TmhXxTgL08B5bJVqREvn39oJwTXB
         Kb9+k+deXxn4ZECrimZkU45a2mbd9h5IHMazh1K0mWEARV2hKgSXv/c5SWCc19Db5Nz9
         DtiJ965w17uY4xlD4KjbxFK/KvgR7kde/oRv+X7sjch4I1CJY+/6r075i+RrIMmQ67Tg
         HBNl3zNmX6c16JG20tbrxVG8knC2vf1Zpgdf0BTmKdP9QwgFuUohfSa5AmFFAY+oA9g9
         QrxSv2EOZ4NYfVWWVxeLB+7lJdFg8j0YcwTv6QKo/QWdy4TFMY2d7giOVvLqzU/TaKLs
         mfBA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=0q7KETf8VOgdRydYjPeN0MMEKPYfp/4tpTOPqZtr/E0=;
        b=QF3eq6SyjoHAcbhdi49/JcLZs8Bq/GoQJCMPlAN46G9DIWfYbaXVhdhrTlktp4ZQAJ
         e1U9jD2c2lIOFA5YIDE75HspTtC9lRwTJ5lk4n3RT4XhRr2SI1mFyycoTJhilj+PjN/b
         Ytthaxxn+jXNBSubtbmpQD06jhSlPEeuQTuDkIl1alurj6mGJSowXbUzAbbyLziqmx0+
         gzY9h5i+Yvk64F/MsNvjrjikklbL75P4t49f+6alE9FrjWzrUXThMK4ZsL7Ji6E1eDEX
         NK72xVGANeAEAVDCK/O3x86wdkewpUgAcLBUp1FS/w+gc7kh7jrNEFZYNeSVmvIsa3EK
         Cqlw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=BPvqDOZ8;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50086.outbound.protection.outlook.com. [40.107.5.86])
        by mx.google.com with ESMTPS id i9si10391711ejf.152.2019.07.25.17.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Jul 2019 17:16:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.86 as permitted sender) client-ip=40.107.5.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=BPvqDOZ8;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=MNI2rM7p45vkpfKHgM+MRU49tgMgLjLIWqj4QUhIhH6Z3LMtLujcoXsbuPRKLbMLD6QCtpoBO1IgCPzxBdXrUayAWR8/6zaNDzu+xLPBqWvPQLEKnUKv+P2HDBNCWDkJ+Rq4cAHYNBQ6h9y1UVMK+aotqbtKvnLL1g8RjAr5U34xj8IXdc4HuI/uHBZofQ3+iuprLiFRRBGMFSmHJVdJdedO79yPk9J+6tFuSEhbwdj9KsMf6J2xPCPoex9gN72HQpriVDtHiT6lMJHAl8qXNty2bLEvjEH44eIjwFVe/moRnz6QIhJHC34TF4H/80SYq74ukVAFkMyJ5uqFRIMQww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0q7KETf8VOgdRydYjPeN0MMEKPYfp/4tpTOPqZtr/E0=;
 b=X2mBSecRCDOHx0jXX9K2PzJ6cHWsQLff8SfDR/vTxdOcGUsnR+L7hYoXbXsWLKfN7RssmG8nL9yHsJEIGADEojF05D/XpYfT+ZjMEK7tK9gtjpotteN96dbLiKslfvaP3j2B8s5C4me1bFA/+LIM/lDfzvo9JpG1CtCrU/8POTb6UrBZOt0HRoEWGyGjWcOjpxwQ7I5rQt6dbKk0O9znrkOl6yJ7Ts/GNrh1FIhf9NRlnD+n3/FnSrCI+2MJcWtQV01/pdzgBpu/4hyOouRiUy6XiR5/j4APO3CIlbfjE2k5K4BA1y73DIKIM8AkZlk8sYPUcKrvYwu6XMVAT6vdPg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0q7KETf8VOgdRydYjPeN0MMEKPYfp/4tpTOPqZtr/E0=;
 b=BPvqDOZ83VGD2ZpojFsykMRzKPQNfABicQx4MWQwP/vZjYzrhD6lAZZz01N145wBImU2sR6lHZ9Bx9O5kfbTTqeJBNrJ/oOkUXdgFQYhv+7NfxZazu+dfGmFc58W6r670I3ya2c5N/3ZjV8HndcgBumjduwXU30hOiMtL/aZyhY=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5389.eurprd05.prod.outlook.com (20.177.63.86) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Fri, 26 Jul 2019 00:16:30 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Fri, 26 Jul 2019
 00:16:30 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v3
Thread-Topic: hmm_range_fault related fixes and legacy API removal v3
Thread-Index: AQHVQexyfCYT3znpM0Ow5t5NZiu9m6bcCtwA
Date: Fri, 26 Jul 2019 00:16:30 +0000
Message-ID: <20190726001622.GL7450@mellanox.com>
References: <20190724065258.16603-1-hch@lst.de>
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0071.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::48) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ca69ca56-6347-48a7-0ff0-08d7115e81d4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5389;
x-ms-traffictypediagnostic: VI1PR05MB5389:
x-microsoft-antispam-prvs:
 <VI1PR05MB53890B869C202998ED9D6689CFC00@VI1PR05MB5389.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01106E96F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(39860400002)(366004)(376002)(346002)(136003)(396003)(199004)(189003)(66556008)(66446008)(4744005)(66946007)(66476007)(6486002)(1076003)(64756008)(71200400001)(476003)(66066001)(6246003)(71190400001)(99286004)(6436002)(229853002)(53936002)(25786009)(81166006)(86362001)(478600001)(6916009)(6506007)(256004)(7736002)(3846002)(386003)(81156014)(486006)(76176011)(305945005)(8676002)(36756003)(102836004)(14454004)(4326008)(186003)(11346002)(54906003)(2906002)(316002)(26005)(68736007)(33656002)(8936002)(2616005)(5660300002)(6116002)(52116002)(6512007)(446003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5389;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 NrmVLum9v2YBluzrp/mm1lBfpYaq+Gu1hv0gn7ggZrHzR9yH6MA/0XO7rOE6W6HwiyZvO4QLdhW8urne5fF2yANtHGsYbvMay2mb7f11AE/NLxBSXUhMjAGl0gz3Ts1of3+ERmpQ7ADZe0ediRyTXIUIWFHJRJHdSudZmqFKRN2aH5xjvJbX6BfG30bIDwJ9rbSsXbYryOxrKMg+R2770JxORJZDEC7PYBfM96CoPZuPV+hx+VtIcohphA+EfjVLewRC2wrzf4Jr2HoHpEavGaCP+36436Lv55A2lNph9+/Ixw4uiIfTPOmZZ8FQiod/hewpFI2LJak9KuNHPhsbr85hkpyxGBqefxmjU/fH1e0eVej8i6lf96Ti29mi3os7pmvIDxG2R+VWvVp4iq0dlX4zeJKx5D90mhOueIuMAXM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <86BBF3FDDFDEC14E88EE4CCBA4717F7E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ca69ca56-6347-48a7-0ff0-08d7115e81d4
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Jul 2019 00:16:30.0910
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5389
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCBKdWwgMjQsIDIwMTkgYXQgMDg6NTI6NTFBTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIErDqXLDtG1lLCBCZW4gYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgYWdhaW5zdCB0aGUgaG1tIHRyZWUgd2hpY2ggZml4ZXMgdXAgdGhlIG1tYXBfc2Vt
DQo+IGxvY2tpbmcgaW4gbm91dmVhdSBhbmQgd2hpbGUgYXQgaXQgYWxzbyByZW1vdmVzIGxlZnRv
dmVyIGxlZ2FjeSBITU0gQVBJcw0KPiBvbmx5IHVzZWQgYnkgbm91dmVhdS4NCj4gDQo+IFRoZSBm
aXJzdCA0IHBhdGNoZXMgYXJlIGEgYnVnIGZpeCBmb3Igbm91dmVhdSwgd2hpY2ggSSBzdXNwZWN0
IHNob3VsZA0KPiBnbyBpbnRvIHRoaXMgbWVyZ2Ugd2luZG93IGV2ZW4gaWYgdGhlIGNvZGUgaXMg
bWFya2VkIGFzIHN0YWdpbmcsIGp1c3QNCj4gdG8gYXZvaWQgcGVvcGxlIGNvcHlpbmcgdGhlIGJy
ZWFrYWdlLg0KPiANCj4gQ2hhbmdlcyBzaW5jZSB2MjoNCj4gIC0gbmV3IHBhdGNoIGZyb20gSmFz
b24gdG8gZG9jdW1lbnQgRkFVTFRfRkxBR19BTExPV19SRVRSWSBzZW1hbnRpY3MNCj4gICAgYmV0
dGVyDQo+ICAtIHJlbW92ZSAtRUFHQUlOIGhhbmRsaW5nIGluIG5vdXZlYXUgZWFybGllcg0KDQpJ
IGRvbid0IHNlZSBSYWxwaCdzIHRlc3RlZCBieSwgZG8geW91IHRoaW5rIGl0IGNoYW5nZWQgZW5v
dWdoIHRvDQpyZXF1aXJlIHRlc3RpbmcgYWdhaW4/IElmIHNvLCBSYWxwaCB3b3VsZCB5b3UgYmUg
c28ga2luZD8NCg0KSW4gYW55IGV2ZW50LCBJJ20gc2VuZGluZyB0aGlzIGludG8gbGludXgtbmV4
dCBhbmQgaW50ZW5kIHRvIGZvcndhcmQNCnRoZSBmaXJzdCBmb3VyIG5leHQgd2Vlay4NCg0KVGhh
bmtzLA0KSmFzb24NCg==

