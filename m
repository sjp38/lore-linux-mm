Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65A4EC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D38320B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:16:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="TvGnXbEc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D38320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7A426B026D; Thu, 13 Jun 2019 10:16:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2C056B026F; Thu, 13 Jun 2019 10:16:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A6236B0270; Thu, 13 Jun 2019 10:16:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A42F6B026D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:16:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so26058911edv.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:16:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=uRCtqGzjhJOBLRtVX0V/ZgSTkU8/jdLSuxxED8NJUIc=;
        b=GbQR/v6otDYP9cHzqhBk7hy1tcE4XioHgSup7ARoqzjWJFSWMtCtSDRXmwRMw8t9dD
         CasUvBSksqWjvsqef6byIuP74zYCqW/UD7fk0kugc8ZLVvDRzWhgNt76NmYg9Sp2jxPl
         VKGOONWssW4hH50TdleAkGK72DVYFZMOE68cdh4NWbKOhYgS0Tg+7gw8KjdqU2ZUO2+i
         L6XParW4UqY0m1qyDIV650/m79GNyx2mXvX984Ooqx7qVZ80lFgZRXAjMk1C4BKBQNdm
         McycwDrwDDh9NG0ZoWGRCE1crH1aTekpuzi/Yxb/LEbaPMwlKplxdMvdys8Ok6GIdqqG
         LoaQ==
X-Gm-Message-State: APjAAAWtMk2s43OCFFUhi8EQseiYBl3eY07MqDeiHuRPsXWNASkLjJGX
	JuZw55x4l8lAmkpHjW0dnJFGJYfmlwyqFeieUWHyvLBV45OVnQlldIajHW1qx20gQoUUjONnuGj
	H5MdELflcXfgpXv7tOkttelSR/MySU4xGbP9FsaNdNbPszKqcEPRFu5i90+Nwm1J+xg==
X-Received: by 2002:a50:c102:: with SMTP id l2mr94670924edf.185.1560435390830;
        Thu, 13 Jun 2019 07:16:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn2ahEtwrW3TSYv9MCAU1wOx3GyZgLSAVb4yjSieom/unA9OdrvZNzXKyd4kR7wKv0mwM+
X-Received: by 2002:a50:c102:: with SMTP id l2mr94670835edf.185.1560435389987;
        Thu, 13 Jun 2019 07:16:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560435389; cv=none;
        d=google.com; s=arc-20160816;
        b=IcgKDdifQmeo7Tmmfrr6+zE0JQjPkPUs4IKk6U4a2qyXLJDdzxoqOGcM5tBVtQPYMo
         AQOUNWpRlIlSOArQV97AejUPAftXmpaY+bYyRn7bCYvW2YnnqlyQgvkRr5xTBGfqldmN
         kXgBV/VR0gfApinVaUi81Rh0gXit1XnVBSopQ50pVE2USP/7hll4KyJF6IL93p6CkdAI
         HFknBY9rYmXE2VL4aqEg0W2OAgSzAe9zCtjPoERlNGScsPklSEi+/OE+0MJKzJMHhsFJ
         d2+hrkoiSoueay/E4Tx/x01nttME1y9Y+ULPwCpXOkJtt5AvMii5QkNxff144qqRMWd/
         jxlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=uRCtqGzjhJOBLRtVX0V/ZgSTkU8/jdLSuxxED8NJUIc=;
        b=HzBURlqvl/FCLeTrKal4bQq5VLBu3Ouava5uZ30fL0HhdvNfWB083cxInJT5Ze/5U+
         NJTCSkpngKocycst3knyNy5RT5IY7QGMoxbniCrGE6nXoLxICooPxD45+UJCO7cfZ1IN
         OfNTEiu89Zz7KbgyK0/SNyOIbfc8p5nb1Gt+1yKZN+pqTLHDoVb5p7BBKxOSAPNniLDX
         WGR3VzKR0XIDF3pOvowdIPGzL0dYLa2nmePc+UcIsXayLjuUcrVCy/psh7ksTexv2rcw
         FZe1b6g8kM6NN0IS/dkecl9AMob3+0O5smafE1zy+9+YlXYaCujql9d0giY2SaP8a+E5
         ncrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=TvGnXbEc;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.87 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70087.outbound.protection.outlook.com. [40.107.7.87])
        by mx.google.com with ESMTPS id r5si2394932edm.368.2019.06.13.07.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 07:16:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.87 as permitted sender) client-ip=40.107.7.87;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=TvGnXbEc;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.87 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=uRCtqGzjhJOBLRtVX0V/ZgSTkU8/jdLSuxxED8NJUIc=;
 b=TvGnXbEcjU6Lo/7/fJyphO+gcrunapqxGdLz+M17V8Za/VtKbSX2UybpfN/j0jOX9sC6Lm2xBxEh49cE0w5ymm9p5MQ2sS9TfXQk7dgCrfXyzRlkaSiH5uYLLNWjzlj4HWhvmzR09mBLA4vwuj9bks2IyeyCyk+IavPI2sL/+T0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4783.eurprd05.prod.outlook.com (20.176.4.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Thu, 13 Jun 2019 14:16:27 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 14:16:27 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups
Thread-Topic: dev_pagemap related cleanups
Thread-Index: AQHVIcx5DdVrUhs/HUiF5V2FmmsvzKaZoY4A
Date: Thu, 13 Jun 2019 14:16:27 +0000
Message-ID: <20190613141622.GE22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0048.namprd02.prod.outlook.com
 (2603:10b6:207:3d::25) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ce498060-eaaa-4cfc-43b2-08d6f009b931
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4783;
x-ms-traffictypediagnostic: VI1PR05MB4783:
x-microsoft-antispam-prvs:
 <VI1PR05MB47836CBE2730DE9B4A14468FCFEF0@VI1PR05MB4783.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3513;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(396003)(366004)(376002)(39860400002)(189003)(199004)(26005)(53936002)(81166006)(99286004)(52116002)(6486002)(7736002)(36756003)(305945005)(33656002)(6116002)(2906002)(6512007)(6436002)(229853002)(6506007)(478600001)(14454004)(3846002)(81156014)(8676002)(316002)(386003)(186003)(102836004)(76176011)(66446008)(486006)(2616005)(66556008)(476003)(86362001)(68736007)(54906003)(446003)(7416002)(11346002)(64756008)(1076003)(8936002)(5660300002)(71190400001)(6916009)(7116003)(71200400001)(66066001)(4326008)(66476007)(6246003)(73956011)(66946007)(256004)(25786009)(4744005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4783;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 V7MYS+Xi0yuEwrWiqQdFEyNmIo52ph6edRuO4tk6AgYuo0b1aNnoJUgJdJqY5OPp4z215xdSTIlif805KjTtwoDOCuQP1/9ok+E9ptw226a2wqHVsoDym8cU0BN91wSMfVOXKRek3zPXyZb9qhv022St0teR3Q7xiN1Ey+EgDtjktRjj7eyfPmSIEEQlR/j2pU5iBJDYEbJPX5zNx/rHf3Y9mW0Tfxat4lpIjDoEtlWlW6ETGh76wNSMBwBD+DPQwBTiiBueMm/wuC1Fj+LteWMELDHyIfiZDpZfwJ10/BIGmUIvXpKK5oEPjUqMazcbnVtK340VjdMxLPoD9di01Ku0wuSQafzVeLQ3c31x5f5B8aNtFynOUa4Gx3J12rS/WpKzcwm/1VF+kS/8oMXw9oAdlXksbr9nZCIzWk7EdFA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3F56F1D2ECF2EA44ADBAB2BD95ADFE6F@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ce498060-eaaa-4cfc-43b2-08d6f009b931
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 14:16:27.8375
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4783
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBKdW4gMTMsIDIwMTkgYXQgMTE6NDM6MDNBTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIERhbiwgSsOpcsO0bWUgYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgdGhhdCBjbGVhbnMgdXAgdGhlIGRldl9wYWdlbWFwIGludGVyZmFjZSBzbyB0aGF0
DQo+IGl0IGlzIG1vcmUgZWFzaWx5IHVzYWJsZSwgd2hpY2ggcmVtb3ZlcyB0aGUgbmVlZCB0byB3
cmFwIGl0IGluIGhtbQ0KPiBhbmQgdGh1cyBhbGxvd2luZyB0byBraWxsIGEgbG90IG9mIGNvZGUN
Cg0KRG8geW91IHdhbnQgc29tZSBvZiB0aGlzIHRvIHJ1biB0aHJvdWdoIGhtbS5naXQ/IEkgc2Vl
IG1hbnkgcGF0Y2hlcw0KdGhhdCBkb24ndCBzZWVtIHRvIGhhdmUgaW50ZXItZGVwZW5kZW5jaWVz
Li4NCg0KVGhhbmtzLA0KSmFzb24NCg==

