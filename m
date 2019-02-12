Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01955C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:40:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93E21214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:40:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="FIU2FjZI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93E21214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3384F8E0012; Tue, 12 Feb 2019 07:40:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E7F98E0011; Tue, 12 Feb 2019 07:40:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B0C08E0012; Tue, 12 Feb 2019 07:40:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB7448E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:40:05 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so2347470pfe.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:40:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=mi+UIJmAtatj5AmxLGjwT8i27mqFDER4wJRPifriI+8=;
        b=hva+JCLGh+VtmW3F3t6A/zwcL0DtD0f5Nt9RfFCk/qv4Omt4lhb4js/1tnPBsWMLue
         3LT1utOMNIejaT7Uz1lwnVOTD26G121HA3uq18lqwysxzjnQG9Qo60Sh/4rDoQQXhhYc
         Um5wTAmb30BoO0ORIVfnNqDLAZWavBdyb+PqbWNMvA6mZ5baGJvli5Cg6RiJGefA31Yz
         s9X9zvp/JyhXdEr3BGwN8SAcOsufQafA+5RAeFdDBZp3VXUzB80gwp8VV0eVWxLhRfoY
         4uiAqf+Mu+fuaEcBTFE3bLk/FAMhQ6rXzQO0fTYX7edc0clY8/9arQqgdTE07wRJvPzJ
         UFMw==
X-Gm-Message-State: AHQUAuZe8m2/mmj7f2/9PudxcnZjBblWqioqQz8mE1IVssPscPx0fvia
	SWZAxyyhDEOwxnbViWOoIa+Zy5VCCzEk7oolRyq/snTZqe5dhOe0Qbjq0zuj/QD/k7w5xl1OMTa
	itVv6EHNH3Ggx8jTaxu2BaB4aWp1Ycgb81CYttZSDUHPnOaMa9OhR48cRdo1Sj4Ehew==
X-Received: by 2002:a17:902:708b:: with SMTP id z11mr3846838plk.203.1549975205325;
        Tue, 12 Feb 2019 04:40:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZbE0/Q2nCZzktKNp19cbxlt8k/BXR4Z4rYj0u2yFKWgrCty+dW+suBREZzggI31jlBTjpp
X-Received: by 2002:a17:902:708b:: with SMTP id z11mr3846781plk.203.1549975204563;
        Tue, 12 Feb 2019 04:40:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549975204; cv=none;
        d=google.com; s=arc-20160816;
        b=tuafNr00+ueV/h3P/NNM86uhi601sF4ZN1lFrwT6nuC2tRNTuyBY7xUZysBdxUZOwQ
         D3bdsvSkQcR6L0tMdiawQmRv0AsZT1S6pnA5LpM/QkKciDsJGwQ2Xka+yZmyF3jvrmFe
         eR7NuHp73SW4BNstpCQABRovVQxsx3i15Ml23ld12INaFU6jLV4B88uOuvf4HVe6AB0b
         knOXMzj8T5t/l369gIsD5Mak63+0fGInctp8k5D67OIdCwlsfFnAI8aGqE3FNejaXDHw
         YbetJlJX0ZD21xo9u5aXVDSg/z+qPLG4VmyARC2JOKZiBPF4L6c1PgbY5wQW6tGSMxE5
         LUyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=mi+UIJmAtatj5AmxLGjwT8i27mqFDER4wJRPifriI+8=;
        b=FtnThsd3y1z5Rug3hmrl/Qtb9DlRIHfnkTMuJgcp1UStoKgRCr4XS2ez3O8BeSIMg+
         RN03zFT36MZuSXWC4GF0nTTVPvCWCbuN6hrKRAQL31KZnZ3ysD9cfjlUNOGKAEKyccES
         nWQFwsPvzN9VAUfqAItyYL9Vd7Zn2dBsZB6z3wQHWeuVn0yZT8fHS/n0FJZO5hFx2ANu
         Rv50ORu7PzWQhEJ5R667gdjbhNslUDZy8HyseSeAv4v5yJssSNZz5eoVm0Wba6IXESkO
         rpRtpY1ZEW7bSTvP5amvJjJzhoihnKIgxymf2ezCUoJjcIFYsJua2wlr2NgN/qSh+Mee
         WfjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=FIU2FjZI;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40083.outbound.protection.outlook.com. [40.107.4.83])
        by mx.google.com with ESMTPS id x12si12703688plo.164.2019.02.12.04.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 04:40:04 -0800 (PST)
Received-SPF: pass (google.com: domain of tariqt@mellanox.com designates 40.107.4.83 as permitted sender) client-ip=40.107.4.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=FIU2FjZI;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mi+UIJmAtatj5AmxLGjwT8i27mqFDER4wJRPifriI+8=;
 b=FIU2FjZIsGcMzP5TFlMmuUNjXZGM4pCfrIxlwpVYxwUySdvLISD4QWH2zGniQInCmBpc/q49xM8vbxzg4RX3O/BDmOV2JXQrzjiKPR72EgANgWdfmiRZmgldC0mOCScHVdtAYmXCl3seynkTJrw7euGAe/LRPq9UPkJYd5ibY34=
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com (10.170.243.19) by
 HE1PR05MB4746.eurprd05.prod.outlook.com (20.176.164.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Tue, 12 Feb 2019 12:40:00 +0000
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a]) by HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a%7]) with mapi id 15.20.1601.023; Tue, 12 Feb 2019
 12:40:00 +0000
From: Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, Ilias Apalodimas
	<ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>,
	"brouer@redhat.com" <brouer@redhat.com>
CC: David Miller <davem@davemloft.net>, "toke@redhat.com" <toke@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Topic: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Index:
 AQHUvvKPEpTQQqXqi0+ZzMx9yc3kKaXUb92AgAADlACAAGXpgIAAAm4AgAACaICABZPkAIAAanSAgAFFsAA=
Date: Tue, 12 Feb 2019 12:39:59 +0000
Message-ID: <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
In-Reply-To: <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: AM5PR0701CA0016.eurprd07.prod.outlook.com
 (2603:10a6:203:51::26) To HE1PR05MB3257.eurprd05.prod.outlook.com
 (2603:10a6:7:35::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=tariqt@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;HE1PR05MB4746;6:bX24RAEQS9/14t7swxQmM4/E7QTBSTSR+ixxLGn3dVehPd2a6edF+J0Q6XkJ+LJes+FTMPBouivBvSPXE6cSuIUMVV7k/DbePlwVjs8g9dhYE6RRQCyh2u/EvnASdenkm0VWviwo2/dS1sdejEAaJnWbMM/RVC0UqmjNKUk51ZbTxhKOpowspbuO1MTOMPP3FiKE1B6rCVG75Q2U8mqKvX0DeJP0hyRgnD+DdX0QUyo07CIE9pbZ+ED9SBxUtxS1oIS9i81yimWkwA/EM11EuUgE1vp0lqTaIkPYWJ8M5IZB1KMPz7jrYFbXb6WsNUdWzsGE/hJvLDSJjGRk08/1rmUNvM4u11eFFkLt7c5VXuDMlm1HPUxJOlhTVF8Q65sVtwAXohKjUmyAwA5E64XQm0Nbap9WzOQ7igVUhkBJshg0LTz2ql3v2c2mXAdDF7rishF0Ta8ioRFFMflDKwZiDg==;5:uNjoMkWOJ5zqqhjDxj3NZ6klv5Pm95RNGbL8bO/XaudRm9JYl36sLNANQo7fB9ytmXCnOwiQEwOYaluz0V0iUJPJMBLFKRAwUkQ6bX90MD8yLcvy6V8ljPB7565tuitsHzGveN6+Dv74VWVAlgz3crJ6Io2EO3uNtJvSuLImDaCX8eYJZZEAIx18ABLl8UgKUqXzSlwcOG/PiHmu0RDIJA==;7:PazCBq9EhEchH2ZwdkpOlYkQwOBQSXtboKx3RTnHYsg/VUdtdVTs1COzULahduZlTUpbduW5JQmNP8+PzLFIPaaZYzIjkXf+niVMVUnV05HIuPU7udokbtCKGcBNs+NdVU+AeyoCjl2LntOuKrtLjA==
x-ms-office365-filtering-correlation-id: 70be81ab-6b34-46bd-362a-08d690e733a8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:HE1PR05MB4746;
x-ms-traffictypediagnostic: HE1PR05MB4746:
x-microsoft-antispam-prvs:
 <HE1PR05MB47469597F4594F5E067CA906AE650@HE1PR05MB4746.eurprd05.prod.outlook.com>
x-forefront-prvs: 0946DC87A1
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(136003)(346002)(39860400002)(366004)(396003)(199004)(189003)(26005)(6512007)(2616005)(8676002)(256004)(6486002)(6116002)(316002)(14444005)(186003)(7736002)(3846002)(8936002)(6436002)(81166006)(81156014)(11346002)(446003)(2501003)(2906002)(14454004)(53936002)(93886005)(102836004)(71200400001)(229853002)(476003)(36756003)(6246003)(68736007)(105586002)(106356001)(66066001)(86362001)(305945005)(6506007)(31686004)(386003)(4326008)(31696002)(99286004)(25786009)(53546011)(110136005)(76176011)(478600001)(54906003)(52116002)(486006)(71190400001)(97736004);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR05MB4746;H:HE1PR05MB3257.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 dENJLAUcSWptL9RzcgfNhHXeoMEjE7JT54UsN7Ec/9b8R5V+zsf0eSatt8AmYqjkTAicbzFpZkFDmlbdXgc+DAOOOfFNwzS+BKcCp/wA5tSXrm1tApq0bAzXu+/5d1tFgugKq24XuGjDNyvFo9K/hPl4oE1LL2Nr4ZYmRt/OYfSFB+DnVvWq0xvwE65FTj37jYjzPNx3fZlURo2S33KZXkl1877O1pbdw24hLXPAZvIjpsGvgBPOIAN6DO3gWpGOVgVxH2oqB0M9KvZEbTaIp2HMwWp/smt+js1KW90/igMbl5eja2e5owt/r68ZM21f81D+tZ00u9+ukc0MYpft1Ohnn4C+V3qk3wvXsOHbY/mx4Gle96+WNYVxTio6wi3+pG+J9xrc3DhnHK5dT3exh86JaraetLxyaldPz/ZpCfY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C8993C69CEFFA44785F4CFD0273E614D@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 70be81ab-6b34-46bd-362a-08d690e733a8
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Feb 2019 12:39:58.7323
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR05MB4746
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDIvMTEvMjAxOSA3OjE0IFBNLCBFcmljIER1bWF6ZXQgd3JvdGU6DQo+IA0KPiANCj4g
T24gMDIvMTEvMjAxOSAxMjo1MyBBTSwgVGFyaXEgVG91a2FuIHdyb3RlOg0KPj4NCj4gDQo+PiBI
aSwNCj4+DQo+PiBJdCdzIGdyZWF0IHRvIHVzZSB0aGUgc3RydWN0IHBhZ2UgdG8gc3RvcmUgaXRz
IGRtYSBtYXBwaW5nLCBidXQgSSBhbQ0KPj4gd29ycmllZCBhYm91dCBleHRlbnNpYmlsaXR5Lg0K
Pj4gcGFnZV9wb29sIGlzIGV2b2x2aW5nLCBhbmQgaXQgd291bGQgbmVlZCBzZXZlcmFsIG1vcmUg
cGVyLXBhZ2UgZmllbGRzLg0KPj4gT25lIG9mIHRoZW0gd291bGQgYmUgcGFnZXJlZl9iaWFzLCBh
IHBsYW5uZWQgb3B0aW1pemF0aW9uIHRvIHJlZHVjZSB0aGUNCj4+IG51bWJlciBvZiB0aGUgY29z
dGx5IGF0b21pYyBwYWdlcmVmIG9wZXJhdGlvbnMgKGFuZCByZXBsYWNlIGV4aXN0aW5nDQo+PiBj
b2RlIGluIHNldmVyYWwgZHJpdmVycykuDQo+Pg0KPiANCj4gQnV0IHRoZSBwb2ludCBhYm91dCBw
YWdlcmVmX2JpYXMgaXMgdG8gcGxhY2UgaXQgaW4gYSBkaWZmZXJlbnQgY2FjaGUgbGluZSB0aGFu
ICJzdHJ1Y3QgcGFnZSINCj4gDQo+IFRoZSBtYWpvciBjb3N0IGlzIGhhdmluZyBhIGNhY2hlIGxp
bmUgYm91bmNpbmcgYmV0d2VlbiBwcm9kdWNlciBhbmQgY29uc3VtZXIuDQo+IA0KDQpwYWdlcmVm
X2JpYXMgaXMgbWVhbnQgdG8gYmUgZGlydGllZCBvbmx5IGJ5IHRoZSBwYWdlIHJlcXVlc3Rlciwg
aS5lLiB0aGUgDQpOSUMgZHJpdmVyIC8gcGFnZV9wb29sLg0KQWxsIG90aGVyIGNvbXBvbmVudHMg
KGJhc2ljYWxseSwgU0tCIHJlbGVhc2UgZmxvdyAvIHB1dF9wYWdlKSBzaG91bGQgDQpjb250aW51
ZSB3b3JraW5nIHdpdGggdGhlIGF0b21pYyBwYWdlX3JlZmNudCwgYW5kIG5vdCBkaXJ0eSB0aGUg
DQpwYWdlcmVmX2JpYXMuDQoNCkhvd2V2ZXIsIHdoYXQgYm90aGVycyBtZSBtb3JlIGlzIGFub3Ro
ZXIgaXNzdWUuDQpUaGUgb3B0aW1pemF0aW9uIGRvZXNuJ3QgY2xlYW5seSBjb21iaW5lIHdpdGgg
dGhlIG5ldyBwYWdlX3Bvb2wgDQpkaXJlY3Rpb24gZm9yIG1haW50YWluaW5nIGEgcXVldWUgZm9y
ICJhdmFpbGFibGUiIHBhZ2VzLCBhcyB0aGUgcHV0X3BhZ2UgDQpmbG93IHdvdWxkIG5lZWQgdG8g
cmVhZCBwYWdlcmVmX2JpYXMsIGFzeW5jaHJvbm91c2x5LCBhbmQgYWN0IGFjY29yZGluZ2x5Lg0K
DQpUaGUgc3VnZ2VzdGVkIGhvb2sgaW4gcHV0X3BhZ2UgKHRvIGNhdGNoIHRoZSAyIC0+IDEgImJp
YXNlZCByZWZjbnQiIA0KdHJhbnNpdGlvbikgY2F1c2VzIGEgcHJvYmxlbSB0byB0aGUgdHJhZGl0
aW9uYWwgcGFnZXJlZl9iaWFzIGlkZWEsIGFzIGl0IA0KaW1wbGllcyBhIG5ldyBwb2ludCBpbiB3
aGljaCB0aGUgcGFnZXJlZl9iaWFzIGZpZWxkIGlzIHJlYWQgDQoqYXN5bmNocm9ub3VzbHkqLiBU
aGlzIHdvdWxkIHJpc2sgbWlzc2luZyB0aGUgdGhpcyBjcml0aWNhbCAyIC0+IDEgDQp0cmFuc2l0
aW9uISBVbmxlc3MgcGFnZXJlZl9iaWFzIGlzIGF0b21pYy4uLg0KDQoNCj4gcGFnZXJlZl9iaWFz
IG1lYW5zIHRoZSBwcm9kdWNlciBvbmx5IGhhdmUgdG8gcmVhZCB0aGUgInN0cnVjdCBwYWdlIiBh
bmQgbm90IGRpcnR5IGl0DQo+IGluIHRoZSBjYXNlIHRoZSBwYWdlIGNhbiBiZSByZWN5Y2xlZC4N
Cj4gDQo+IA0KPiANCj4+IEkgd291bGQgcmVwbGFjZSB0aGlzIGRtYSBmaWVsZCB3aXRoIGEgcG9p
bnRlciB0byBhbiBleHRlbnNpYmxlIHN0cnVjdCwNCj4+IHRoYXQgd291bGQgY29udGFpbiB0aGUg
ZG1hIG1hcHBpbmcgKGFuZCBvdGhlciBzdHVmZiBpbiB0aGUgbmVhciBmdXR1cmUpLg0KPj4gVGhp
cyBwb2ludGVyIGZpdHMgcGVyZmVjdGx5IHdpdGggdGhlIGV4aXN0aW5nIHVuc2lnbmVkIGxvbmcg
cHJpdmF0ZTsNCj4+IHRoZXkgY2FuIHNoYXJlIHRoZSBtZW1vcnksIGZvciBib3RoIDMyLSBhbmQg
NjQtYml0cyBzeXN0ZW1zLg0KPj4NCj4+IFRoZSBvbmx5IGRvd25zaWRlIGlzIG9uZSBtb3JlIHBv
aW50ZXIgZGUtcmVmZXJlbmNlLiBUaGlzIHNob3VsZCBiZSBwZXJmDQo+PiB0ZXN0ZWQuDQo+PiBI
b3dldmVyLCB3aGVuIGludHJvZHVjaW5nIHRoZSBwYWdlIHJlZmNudCBiaWFzIG9wdGltaXphdGlv
biBpbnRvDQo+PiBwYWdlX3Bvb2wsIEkgYmVsaWV2ZSB0aGUgcGVyZiBnYWluIHdvdWxkIGJlIGd1
YXJhbnRlZWQuDQo+IA0KPiBPbmx5IGluIHNvbWUgY2FzZXMgcGVyaGFwcyAod2hlbiB0aGUgY2Fj
aGUgbGluZSBjYW4gYmUgZGlydGllZCB3aXRob3V0IHBlcmZvcm1hbmNlIGhpdCkNCj4gDQo=

