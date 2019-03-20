Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D432BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:52:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED222083D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:52:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=virtuozzo.com header.i=@virtuozzo.com header.b="NB70ZACo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED222083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A00AC6B0003; Wed, 20 Mar 2019 15:52:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B3EF6B0006; Wed, 20 Mar 2019 15:52:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A0E76B0007; Wed, 20 Mar 2019 15:52:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 495806B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:52:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f1so3649218pgv.12
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:52:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=QHgOg6cGsv9xd65uVTjBVNHAbSXgzLyqtKjVx6L0PNA=;
        b=RMGAMEJYkhaGg/5HEgotNbWy4riQeRnxhEJIPHilzqnZyCT+r+3SmBZOo+Q4aogaIf
         9ljv7QE59EcNaXHg54YG5EpesxwUPpfspT1nWRoblHHBmzoE+t6yrFYJ7vt63oLnvCZb
         CCCSDz/Hpxte2Y3D+h1nxXMM0GB0N6U2zp13PuUKhU+9/NczRB8FWfCtC/MlEQHCwVDW
         m+pwJIWKAVfNkE2wYrLc1UsuY6HjzDj77nMMR5LBzq+QSmsdFFpUAA33XMquN7yyMx1d
         0Dne3itbAcb76azk5qthkFI96m+nwhUOFep+zTR89lzyi1eZbpPGALh/45B0ixhFb1/Y
         9ENg==
X-Gm-Message-State: APjAAAVCh6kSQ7uRDcdk3EEa4WomNqjwMuT4ZK7UfOqvouWjNiMKzmdj
	HZNWD1KcL5LxWNh4LzE6qlBtKuLoZxqzvmpk7jW1GwBWRjbT7rYVIuhfVv6d80zaZ9tzSyDLlaC
	Yr5N4e5Ehqv5ai6mg9t6P6UYXso6XL09sd0jVCuv7nvga3F2zwiWKciPo1Dg5xvcuUQ==
X-Received: by 2002:a65:5a81:: with SMTP id c1mr8967503pgt.217.1553111540916;
        Wed, 20 Mar 2019 12:52:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjFTYT6V1hWN5LVs3ap0HEU8W6Dy8L2F/7+JGEgAUcciw5BPaQv8LSMdksrIPbYQDCUBJh
X-Received: by 2002:a65:5a81:: with SMTP id c1mr8967454pgt.217.1553111540039;
        Wed, 20 Mar 2019 12:52:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553111540; cv=none;
        d=google.com; s=arc-20160816;
        b=MAopsKqnw99CfKwMaivntEEC7ekagKZRjl4sby+flaJLI7cCYVHr0jP3Lrn5mRJrPB
         cLYXWI1/tfXKpTQFlqJWx3DZmQryO1dOO1KiHekOpTJv+qcIGxvUgUO4G1iIxsYYfBfq
         SqT4cgzI5qS7gHUYZRgIUtsJ5Vif1lH9eCgjNGuRDPh+bkn4fExYg6nMMRrNlgKjIFM8
         EBHj2lj5alCfbMjr3lxxX+/9Fc/BU0Gmz3AUePur9JURt2YS1HKlB9rKiVGeh2RNxPnu
         ZrQ5xqnJCeuFSWAPxrmasLojbV+hCeKe8USR7Do2Qk5LjiXFbSjasdItigh+OL2T5ZYK
         0oTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=QHgOg6cGsv9xd65uVTjBVNHAbSXgzLyqtKjVx6L0PNA=;
        b=aEk4ScL9rBMeuhNVLLSBrQtGQPTxjZpzLiVWu0A6RWJMQAQZd5ZHkOsxOsMPMHq86S
         cLD0UriGS4Mqv1joTBrgOJG6m/PGt4v5M6z0d82bSBiy2GU9yI3Sb41hXwAZRAffRQYW
         NudQZn6N3+to+4qqDRCDIB/WvVF/ZIUil8donIZAVkgShOAOrsRevqtwKv6bEkyhY1M5
         SJztax2EZHKcT1pOaOHdRh3qSCioemVbul/oeIZE3xK7mOVcFQ75JVxQQD2GWwophyZf
         GtuZOOYA1oRkT8HW1Q0a5OIKsYYzum+KQtcXOlaFRTxi8x3lDUK7cqVNxQQvGLjpkIfT
         CXtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=NB70ZACo;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.15.113 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150113.outbound.protection.outlook.com. [40.107.15.113])
        by mx.google.com with ESMTPS id d4si2284152pgq.543.2019.03.20.12.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Mar 2019 12:52:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.15.113 as permitted sender) client-ip=40.107.15.113;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=NB70ZACo;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 40.107.15.113 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QHgOg6cGsv9xd65uVTjBVNHAbSXgzLyqtKjVx6L0PNA=;
 b=NB70ZAConJfzBYK2A6y3FVXPFsfFfnq3MeEX739YKfLdGqN/IAoPgpqH3nJmRZg6awnTn/+tAzfi6tEUqUnRwSOgaBaTFv2EufWw/gKzCIFOQwlyXkxzykLQCr2FLf7aDeqz2AQqKe0fZrH/vWLbflxT6L8+QWhlrc093QkowoE=
Received: from DB7PR08MB3771.eurprd08.prod.outlook.com (20.178.47.26) by
 DB7PR08MB3753.eurprd08.prod.outlook.com (20.178.45.211) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Wed, 20 Mar 2019 19:52:14 +0000
Received: from DB7PR08MB3771.eurprd08.prod.outlook.com
 ([fe80::61ed:e02d:9ab5:27df]) by DB7PR08MB3771.eurprd08.prod.outlook.com
 ([fe80::61ed:e02d:9ab5:27df%4]) with mapi id 15.20.1709.015; Wed, 20 Mar 2019
 19:52:14 +0000
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "bigeasy@linutronix.de"
	<bigeasy@linutronix.de>, "adobriyan@gmail.com" <adobriyan@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH] mm/list_lru: Simplify __list_lru_walk_one()
Thread-Topic: [PATCH] mm/list_lru: Simplify __list_lru_walk_one()
Thread-Index: AQHU3w7Lo6KraWJUnkilY0x3WJKyDKYU3h+AgAAQjIA=
Date: Wed, 20 Mar 2019 19:52:13 +0000
Message-ID: <9654f80e-ac2b-9d85-fe93-f42cdc2f6011@virtuozzo.com>
References:
 <155308075272.10600.3895589023886665456.stgit@localhost.localdomain>
 <20190320115251.026f65e83ebde2b8ebf51134@linux-foundation.org>
In-Reply-To: <20190320115251.026f65e83ebde2b8ebf51134@linux-foundation.org>
Accept-Language: ru-RU, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: HE1PR0902CA0059.eurprd09.prod.outlook.com
 (2603:10a6:7:15::48) To DB7PR08MB3771.eurprd08.prod.outlook.com
 (2603:10a6:10:7c::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=ktkhai@virtuozzo.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [128.69.201.161]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8da589af-ccaa-434b-e81b-08d6ad6d8c3a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:DB7PR08MB3753;
x-ms-traffictypediagnostic: DB7PR08MB3753:
x-microsoft-antispam-prvs:
 <DB7PR08MB3753E70B1AC82C03E934EC1BCD410@DB7PR08MB3753.eurprd08.prod.outlook.com>
x-forefront-prvs: 098291215C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(39850400004)(366004)(346002)(396003)(136003)(376002)(189003)(199004)(102836004)(4326008)(55236004)(6506007)(446003)(99286004)(14454004)(5660300002)(229853002)(8936002)(71200400001)(2616005)(71190400001)(486006)(53546011)(14444005)(52116002)(53936002)(4744005)(26005)(6512007)(6916009)(256004)(6436002)(25786009)(186003)(478600001)(76176011)(6486002)(476003)(11346002)(7736002)(86362001)(3846002)(386003)(6116002)(8676002)(6246003)(54906003)(81166006)(97736004)(2906002)(31696002)(316002)(81156014)(305945005)(106356001)(105586002)(66066001)(68736007)(31686004)(36756003);DIR:OUT;SFP:1102;SCL:1;SRVR:DB7PR08MB3753;H:DB7PR08MB3771.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: virtuozzo.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 RhGzIRYVFdk9AjUcVhcsKY+9Q1fnaf6SPIlqy/JhYl9Le06xetl6t3JZTOuPEV8CaG11RlCEdew01oKPy7IptvVEAnf6ZWtztfMGSO051yefJ5xXznyKFCdrqzNOodTIkgEks44VYDU31vyC3aeVGj9ihlWn8pje2VGXwv01LTEepFJUvKHLC9LhpVmxN0WBl+koLIwcMa1+m329k/3a2QJZdYwPthaFKt2dNdUMC1aOjr6pd2GTwxZyaO2GpA3HMSQeZ4izMafsXBwWT3iMkHwRgWevYN1IOmIAKEdo2ghdOID5zeKJKgp20cY+psDMtV4vXD9RmEOPolToPO68ZkFcgSHKY8iMr6EAQQi7dQyzf1/8SdZ2K3iv1VjV2u3pbAQ9huJZL5p1vh5rsc6PlcvoUrRDaEwwXcPK1WZKBIw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <EC1F5FFA01BF7A40A432C62085C271BD@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: virtuozzo.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8da589af-ccaa-434b-e81b-08d6ad6d8c3a
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Mar 2019 19:52:13.8857
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0bc7f26d-0264-416e-a6fc-8352af79c58f
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR08MB3753
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAuMDMuMjAxOSAyMTo1MiwgQW5kcmV3IE1vcnRvbiB3cm90ZToNCj4gT24gV2VkLCAyMCBN
YXIgMjAxOSAxNDoxOToyNyArMDMwMCBLaXJpbGwgVGtoYWkgPGt0a2hhaUB2aXJ0dW96em8uY29t
PiB3cm90ZToNCj4gDQo+PiAxKVNwaW5sb2NrIG11c3QgYmUgbG9ja2VkIGluIGFueSBjYXNlLCBz
byBhc3NlcnRfc3Bpbl9sb2NrZWQoKQ0KPj4gICBhcmUgbW92ZWQgYWJvdmUgdGhlIHN3aXRjaDsN
Cj4gDQo+IFRoaXMgaXNuJ3QgdHJ1ZS4gIFdoZW4gdGhlIC0+aXNvbGF0ZSgpIGhhbmRsZXIgeGZz
X2J1ZnRhcmdfd2FpdF9yZWxlKCkNCj4gKGF0IGxlYXN0KSByZXR1cm5zIExSVV9TS0lQLCB0aGUg
bG9jayBpcyBub3QgaGVsZC4NCg0KT2gsIEkgbWlzc2VkIHRoYXQgOigNClRoYW5rcyBmb3IgcG9p
bnRpbmcuDQoNCktpcmlsbA0K

