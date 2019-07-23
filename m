Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7672C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F4FA218B8
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:27:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="XJBnB7PI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F4FA218B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F025C8E0006; Tue, 23 Jul 2019 11:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB29F8E0005; Tue, 23 Jul 2019 11:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2B768E0006; Tue, 23 Jul 2019 11:27:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1FA8E0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:27:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so28443550edu.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:27:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=MpcazAqwrCQDcqNA29XrIefQcOTMThsWzZPeF9D1w0Q=;
        b=XE/tMk0/rQgBVtne/W9NU6PR513X0/rz+8JXcObetQwAsSLTqNC6VnM+cv78pdzhEY
         0Vw7pAk68e5cv8nvwWwoAbJe6J7gdpoRFiQOPL7i0x2x6WEeK/EcIHMcXxdK8M6RUDHo
         DJEdP3vSKel/4FIq8O8fNsovdvpJ2Yuw8QWWeub6EDb7IQhWlrLnsup0LDJ+EldKHTCw
         rosB9jCGdlFVhD84sT3XMYMruGTxESxUeRRuIck8hAA5YBKCn2J62p+/me0tQ0pf3Y05
         PpJyzeg9t235yOtufKwWlqzXRoq8G3QdPW5D3NreeyRiadGDp2QlkVGWn3SlibSCxi29
         Ax6A==
X-Gm-Message-State: APjAAAWXs9KPy6zw3BlfjWKpzt4Z21JNL98hNcm0DNa42taLgvN7/OQT
	QiCKVq9+o4IA2qJ1QKuKyyIFFXECLas5NCTm1Da8hjnjGu8QSzO+b2cLyUrYEIN9utAt1aKzVzf
	aET452K3Vl70UDAiOiIyi6X0DEJuy9CUs6BXgetNsAdq6FFQ3BqzBlUrk9bUwd4SMKA==
X-Received: by 2002:a50:a5b7:: with SMTP id a52mr66985663edc.237.1563895665086;
        Tue, 23 Jul 2019 08:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDwISdQIhMpQYXmLmalhCRx+KBA4ZtutlNHyRXnfW1qQslKvnI+rtav7+6WJN2/AuTCdGs
X-Received: by 2002:a50:a5b7:: with SMTP id a52mr66985606edc.237.1563895664441;
        Tue, 23 Jul 2019 08:27:44 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563895664; cv=pass;
        d=google.com; s=arc-20160816;
        b=eDa4AzX7e00pXc/7OFzqlUizsVKwTwC/W1ZQyjqKNWMjd1Sz6yYRynharA1Y281y7s
         7l6ynGnrUMUTlBSgjA0JlNaO2dY/4yZbbminE82wf8d91krxTRnFpvgAP4SLhEiNG+Pa
         q9R5RtQIEwlUCuKlEc4ArGlk1caPXH64lJ/uqNi4dRog0lNgfnPPDgmAkocETYL7ikJw
         82L5zNxZSaWHPbjp2y1t11ptBWeTB9PPKOa6ltdms4aspe1eUGJ+ctKtu/sBf/KHfMys
         P93gFbKQhJLJkx/kmoH9GGfI79RZjRnC4Ux6cRBDbut/undiV3FvU9WU6d5zuAAD7XBi
         rbOA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=MpcazAqwrCQDcqNA29XrIefQcOTMThsWzZPeF9D1w0Q=;
        b=Dkc/culdqESA8vQAgOeut2ICUI2BCMd4uyQGv2Py805Z2XTUoO0Mu/Eq4myeEk0Jap
         D3U07wIQVEc4KQxzYHiURmSfPBTt2dZFNYknBcd4bO6x0TiRt0rtmoLVkkS99iTxiWl/
         bS/VL8BJEUlrf76VseDzOHdYghxL3xXCsiJp67PIUjM5wM3ixT1Cvnxs3Pl/YomNqt48
         KO3Jb7hNx18hFx3B7GThitNFz+4228bt80QF0x/mjJmUySdjonccoOGKOzqZR/jIxFgs
         Pa9flmsq/i8FxBl0jTUNdwq3RfwYjmCmIrYGlliG6ePGVa8O20DlT3vprw8npbACel0e
         BxPA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=XJBnB7PI;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00056.outbound.protection.outlook.com. [40.107.0.56])
        by mx.google.com with ESMTPS id g2si6388225edh.299.2019.07.23.08.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 23 Jul 2019 08:27:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.0.56 as permitted sender) client-ip=40.107.0.56;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=XJBnB7PI;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=a9JVfRA9eJHXCkYNRem5dyoBhHLOryjZThoRqNJPOm4/yihKZhp9AJamZnS1GzDsOjnXUNMc4TJHc13mYPjUo8TJb9LXRPIrl0zYhqlcLR2uRaaPqSVVmpg5obj1HlZA4o+nj5AD1win1Ds5SD28GMPpFWbRtHnkld80PS5PE1VKuKKW2N6/vvX6oo1NJZely3X9t5SJvc0vhX9OYjuDlmQUy7oQKXwnmKPBG7cuVJSctC2uzbEXOgBWJAuyhT1Di0WAR0BBGoC81lx+OK34HRbHse3AtK06sI1iiTRtAw8LZUheoeSjGut+dwQm8N68WDPMP7Oj7yV4bQVaO0z7ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MpcazAqwrCQDcqNA29XrIefQcOTMThsWzZPeF9D1w0Q=;
 b=jm52erIVMC8iZWoT+kq1+d0w3ELz5RvDuIJKUti1F7kLjm3YdL9da0+fmV8TugvsUkPZDQu6fER15qc2ts6cEODPqMz8xpZovU8nHaoM+x7PQt8CeFequOzhJNwvl8I2udWfA3Jqw6x7rsOn5ak3B9QuBFvLN9Hj/1GfJwEJqsbA87WjUNCh1Jrj7Eldv2OQhAKneY+jX0KdaWxade4umlT39z0DtEZu0fQhZwJSmkNpPWKUlFqHhXOMQtQErZX0t2MI7UGMTrJPX1tBeISOXpyKLz5aaDPbR0v/T19Iw/YXDh62ozKiIpxlL81OjhF4w3+mzSvN6450jyDQBkFr8Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MpcazAqwrCQDcqNA29XrIefQcOTMThsWzZPeF9D1w0Q=;
 b=XJBnB7PIkzKOMDnsh5SUGs37M5rW+u53Sx8EGfBiwdYBkeOw1yFpYP3A6LARSKLSQJYIj1XUIY7NyVjEQ0imXacqKZgg6TSHbcucLW8EnVVTDpiP9Fv8XD+QRC4MdO3lKf4qjX3wZN9G4P1pji5WSnBt/Nk0G/88gWKpSYUKtiE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5261.eurprd05.prod.outlook.com (20.178.8.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Tue, 23 Jul 2019 15:27:42 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2094.013; Tue, 23 Jul 2019
 15:27:41 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Thread-Topic: hmm_range_fault related fixes and legacy API removal v2
Thread-Index: AQHVQHIRntNvIPdbDk2nPEKsWJGfiKbYVWyA
Date: Tue, 23 Jul 2019 15:27:41 +0000
Message-ID: <20190723152737.GO15331@mellanox.com>
References: <20190722094426.18563-1-hch@lst.de>
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c7910dff-f7dc-46ae-41ab-08d70f824d91
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5261;
x-ms-traffictypediagnostic: VI1PR05MB5261:
x-microsoft-antispam-prvs:
 <VI1PR05MB5261829FD697C0314F91489FCFC70@VI1PR05MB5261.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0107098B6C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(366004)(396003)(39860400002)(136003)(376002)(189003)(199004)(68736007)(86362001)(3846002)(6116002)(6486002)(99286004)(316002)(6916009)(54906003)(446003)(81166006)(186003)(6246003)(11346002)(386003)(4326008)(66476007)(76176011)(2906002)(33656002)(102836004)(25786009)(6506007)(2616005)(476003)(26005)(66946007)(66446008)(64756008)(66556008)(6436002)(53936002)(6512007)(52116002)(66574012)(1076003)(256004)(8936002)(7736002)(305945005)(486006)(14454004)(5660300002)(66066001)(71190400001)(71200400001)(478600001)(36756003)(4744005)(229853002)(81156014)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5261;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 RxWwY38iPTu3gct/6iBhlpL/aVkkdN7hnnhRxGv2qFeUZas6kcGkuNyN/7QbBf1qgeWRPZ8ywvR6MRXK5bmHutzVZm91HR/iUdU+APW6okeQX/xiLWpVuvJiL71ul/Z6egvJv358/Q5cNJIFzv9fjVKuaE9sk3tXJe0xaxLiqVllAyB2ELo76i2oivCKyzN/bcZj7Amb9Jk6LYmrG5AIi4pcTMJvVASD+F7AHGsiY6bEPhFnH504tr1tIjEXuvfMRRLNhP76FkykhwjIaI3XleE/YNjptqxIgUdonutgj194LNu+JV0smdg2tvu6Rbuvg7940j0zQ5MMfSYd/0yggkv5S8UriywNVtrIz4OZ6WmdxOxGDpcszeFkktbdM1gSLr7byOz3xSIoSfuPB/oUfyYTooR0hYE7mIUk+xxxte4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <26A6F7202CFF03408F66F9FA8B336B7C@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c7910dff-f7dc-46ae-41ab-08d70f824d91
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jul 2019 15:27:41.8784
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5261
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCBKdWwgMjIsIDIwMTkgYXQgMTE6NDQ6MjBBTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIErDqXLDtG1lLCBCZW4gYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgYWdhaW5zdCB0aGUgaG1tIHRyZWUgd2hpY2ggZml4ZXMgdXAgdGhlIG1tYXBfc2Vt
DQo+IGxvY2tpbmcgaW4gbm91dmVhdSBhbmQgd2hpbGUgYXQgaXQgYWxzbyByZW1vdmVzIGxlZnRv
dmVyIGxlZ2FjeSBITU0gQVBJcw0KPiBvbmx5IHVzZWQgYnkgbm91dmVhdS4NCj4gDQo+IFRoZSBm
aXJzdCA0IHBhdGNoZXMgYXJlIGEgYnVnIGZpeCBmb3Igbm91dmVhdSwgd2hpY2ggSSBzdXNwZWN0
IHNob3VsZA0KPiBnbyBpbnRvIHRoaXMgbWVyZ2Ugd2luZG93IGV2ZW4gaWYgdGhlIGNvZGUgaXMg
bWFya2VkIGFzIHN0YWdpbmcsIGp1c3QNCj4gdG8gYXZvaWQgcGVvcGxlIGNvcHlpbmcgdGhlIGJy
ZWFrYWdlLg0KDQpJZ25vcmluZyB0aGUgU1RBR0lORyBpc3N1ZSBJJ3ZlIHRyaWVkIHRvIHVzZSB0
aGUgc2FtZSBndWlkZWxpbmUgYXMgZm9yDQotc3RhYmxlIGZvciAtcmMgLi4gDQoNClNvIHRoaXMg
aXMgYSByZWFsIHByb2JsZW0sIHdlIGRlZmluaXRlbHkgaGl0IHRoZSBsb2NraW5nIGJ1Z3MgaWYg
d2UNCnJldHJ5L2V0YyB1bmRlciBzdHJlc3MsIHNvIEkgd291bGQgYmUgT0sgdG8gc2VuZCBpdCB0
byBMaW51cyBmb3INCmVhcmx5LXJjLg0KDQpIb3dldmVyLCBpdCBkb2Vzbid0IGxvb2sgbGlrZSB0
aGUgMXN0IHBhdGNoIGlzIGZpeGluZyBhIGN1cnJlbnQgYnVnDQp0aG91Z2gsIHRoZSBvbmx5IGNh
bGxlcnMgdXNlcyBibG9ja2luZyA9IHRydWUsIHNvIGp1c3QgdGhlIG1pZGRsZQ0KdGhyZWUgYXJl
IC1yYz8NCg0KVGhhbmtzLA0KSmFzb24NCg==

