Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91994C43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:37:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 345F72086D
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 13:37:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="AAv7VdjS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 345F72086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98868E0003; Sat,  2 Mar 2019 08:37:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A48C58E0001; Sat,  2 Mar 2019 08:37:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E8DC8E0003; Sat,  2 Mar 2019 08:37:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 366BA8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 08:37:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u25so405745edd.15
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 05:37:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=/KUUxYoDUSaTPlpT7K4LU/+i+IFiN/A557NxS/OWrl8=;
        b=nkdyJgLj4eCBVEW1Qa8yB7LIF8e15T6wzqD/RdlOWyn1fLBRsxpwMLQg3OmDCz+A3q
         dSLDIJRTjl1GCOGGc7e/oWksTj1kDLMCpkvyiFlulC+gR7lv+ieWYMOwHmuUD1uDHdyB
         4mNmGpCP+23ZxwbrdrdYPIESe0IDS3FMPHqVstShqr7bxOvMBQtNwyifeeVVemHPVGC4
         1tcbIprTdcaHXYqjEOiLSHQFJKy8d/L/sgo73r+ClTlIS7SJNb7LS7LX5ZVwafHDiDAl
         QSaabOC3p22CayfglNY5l1fPwkQbS4mAp1OO7C1k66FLUOQ0XbXcUaTNhjhCty6iClHy
         Kkxg==
X-Gm-Message-State: APjAAAUR8Flk6YsbsT7R3fneGheg6xxc5ngp4Edqpf8d2Nk6Z82wzt/U
	f68eQ+SX4oN7O36ot3J/Sus3QMd6EENSVYkfa2QpTaq3YXOS59hd6LoTJovCNodCfC+5n1CCOg2
	msyakyJ/83V7Ys7ZUy5ww06IiYQYkRdtIeqB3H1Yd96E3vFOa7p1ea+NnFg9W+054vw==
X-Received: by 2002:a50:adc7:: with SMTP id b7mr8353668edd.280.1551533859785;
        Sat, 02 Mar 2019 05:37:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqzXe9Myqbt8C6W0S8laLNjsndrUelzKIICGIYjp4TokEP5h3xP5mx+t4+fmtBbBHULsfCGu
X-Received: by 2002:a50:adc7:: with SMTP id b7mr8353626edd.280.1551533858884;
        Sat, 02 Mar 2019 05:37:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551533858; cv=none;
        d=google.com; s=arc-20160816;
        b=j9V+IdYlzAcwJ8Z+6aetPhMMkoAlfjOE7rXJsiVO2bTdqsFRcyu7wzcK4jCSq0U0ZY
         Od2emSHbOGczW6HZH1+pbE2goXMhBt8QFfslBywLHIMHAFrP+oUg8BYAJh+yZv/E9lLP
         t7ZXk6F9IxmsSm0H6mWfzM1Kdvt99C0XFnX3cvvD1/F6u867ut0VSyCN4tOlPdMbp9Dl
         iDpOUESy87cGh5OHOeFBbi583ES2b0fs1DcR9qme4YtQqKTtl7lnMXgeZe5k+JQx1zBq
         MWftUMSBgoaCFicKp0Ro2H+UzFlKDZP9fvOJ+HbS8EYsGb+rp/xSP2bjoXwLFlAV5fKr
         EVfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=/KUUxYoDUSaTPlpT7K4LU/+i+IFiN/A557NxS/OWrl8=;
        b=RUG6qsJwDBt0/5cjgeGJQc8XvVFLQujK4o+vH3mbQafDbJfZhADQP5Lx4GdqYs3+2G
         PS3FMyWsOZgUyAgiwtCBRk8u4+RJb+SI4IZTs8YZK/fQoPcVP0PqQGE/buKdta6FmiSz
         e4u3YrTFwvQQzho1T26MNmklCtqFgfX9+8OiKPCkOH+sV6Odjt0eD8MBDlBAJPSuSVhP
         /Gz03af46sYmjab/cjS9qBVVoshGDX47KiZuBpYsTOr1IsOOJBHF6o7Xv3IOeI0roVJT
         1qjz0bpbwDhOCvT0FN/Evs90Gh5CiS/RZa4HhpDm2ZeiBu/TnI33KRTPxEOcQr+NrSnm
         op1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=AAv7VdjS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.49 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50049.outbound.protection.outlook.com. [40.107.5.49])
        by mx.google.com with ESMTPS id e55si442083edb.32.2019.03.02.05.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 05:37:38 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.49 as permitted sender) client-ip=40.107.5.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=AAv7VdjS;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.5.49 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/KUUxYoDUSaTPlpT7K4LU/+i+IFiN/A557NxS/OWrl8=;
 b=AAv7VdjSD1vQ9IvP6arfGrijzI56ZuCgtP4seNMhuG7r297LOO8uY/QHBaF50NrHr/7O2poskD2fEmIygTXVZAsQJU54zE+fyNSPz2QoOO2O7VY/MsIr3gBWeXdiw0kOHv5QiTgbPODjCAUPGLX0lyJZS59BUlb/igGdTlBbE9A=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB3954.eurprd04.prod.outlook.com (52.134.124.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Sat, 2 Mar 2019 13:37:37 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 13:37:37 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 03/12] percpu: introduce helper to determine if two
 regions overlap
Thread-Topic: [PATCH 03/12] percpu: introduce helper to determine if two
 regions overlap
Thread-Index: AQHUzwvzZOpEZztyM0qHqrva9HhZI6X4WyeQ
Date: Sat, 2 Mar 2019 13:37:37 +0000
Message-ID:
 <AM0PR04MB44816A833E192E37072B641988770@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-4-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-4-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5b5597d4-d06d-4a01-dd9d-08d69f143bf7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB3954;
x-ms-traffictypediagnostic: AM0PR04MB3954:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUIzOTU0OzIzOjZPdEZmb3FpWU9RdEhUSmVzRHQ4TGp6YXFO?=
 =?gb2312?B?SGN6dFpMaWluSFJ2cmd4R3BoL1VTVzhNTGJ4L0NVV1FRV0MzVHY1TUJJdXd1?=
 =?gb2312?B?bUpMQzRxVlBRYlEvRzcyUkdydW1MTXJMdm1JS21vNGc5NFNQQmVCUU8zY3Vq?=
 =?gb2312?B?b25qOEJiVFZ2M1JPbXJPbWFVRTNmVEg5Wi8yd09ETW5ZZXlxMVJqTE83dXFh?=
 =?gb2312?B?ZlB4NEs4cktMNGdtbUx2TUw3WEJKTDVTSjdwNHg5cElDU1RYTmdLSEdZMnlZ?=
 =?gb2312?B?YldrTnRGc1htZEM1OTBPbDVhNjMydlFYQVF5RmtWT3pjRkNDaDJTQ0N3VUMz?=
 =?gb2312?B?VVVQaTgxWUdERHVrNE5Wby9IeW1jcVZJcmp4em4xUStBNjJ2Ui9jZWlYamFJ?=
 =?gb2312?B?MTZ5Wllob05ubE9GdStCekJIckxCMEVaK2dmUmk5bmdIdytGcGQyb2JnVmJ5?=
 =?gb2312?B?TFgxSEQxYXZUWUZ0SEFsZlF3VExweEx1NUhYK2hRNlAwak9WVWR6WTRDLzNN?=
 =?gb2312?B?dHFiVUhWeHVRV2lFd2JCZUNuU25rT2VtS1JBZHNzZlJrQ0d2MHUwVXh3Zmw2?=
 =?gb2312?B?cGhhMkxmWDRDSkVkNVp4SUEyZFVSWlpiUCs4K2txcUZKQzE1OWNBemtSWml1?=
 =?gb2312?B?UW9HY0llT09KWnBodk5RY3RQRnI3ZFRrNlRnZnd5MXN4bGR0Z0pCQkhQaC9T?=
 =?gb2312?B?Z3MwZlBoc3FkeityUDlSZ2NMRkk3LzlON2crOTM1VnFQWnoyaUZiWXRXUEhL?=
 =?gb2312?B?TWZCcjc4Q3k1NHRMQTBVZDJLU3pzcnVaOWpHL0dLQkJoNmFjbmlpYnJsb2lx?=
 =?gb2312?B?dU41Z0xOUjV2VGdqZTN5ODF1Tmp0U1VCQngvSUYwSU11VmZYNmdsM2JHUVJ3?=
 =?gb2312?B?RnRGRGdHWElOenFHZjlnQWpib1dBMmQrTlgyUXUxclRkais1elIxSFYvdk5y?=
 =?gb2312?B?WGlRS21YYkh0VVh0VThDK0xPVG5NWlFtaWNtYUhjRU9MRVVBQXJjYXUyWDVQ?=
 =?gb2312?B?Unh5SmFqLytyMzFVM1MxbndzVWZzR1pxcTBaa25QdnpkbWFqQUNvTnF6MjFu?=
 =?gb2312?B?OEVBcFZlVkVUalByTzc1WmUySGRhWnZSMTNPSWxuREJFZGRDZlJ6TzVEYUxE?=
 =?gb2312?B?N1JteVZ0d1pGbHBQVDg5WGswcUNCU0hkaFBHaDdBVTR2SmM3bzFoWjB3dXBJ?=
 =?gb2312?B?aE12cjIyRklrV1pON3p5TTdTTThFdmgvWWV3SUxXRFpKV3FjVy96dzRvWnc4?=
 =?gb2312?B?aVdCWVZVMDBkSDNnUWJnMzN6R0JTdlBWbnp1cjlKQmZDU3BtR2dmWWNLdk96?=
 =?gb2312?B?d2htRlU2QTlOWTdNRlJCSHFLb1ZtdTFZU2djeWd3aU8zT2FUTmFxT3pTeDdH?=
 =?gb2312?B?OFpJT3BaVkU4YTFWZENTR1R4eFhoK1BzV05rZWJQYndsK0loY25QekJ5dGs2?=
 =?gb2312?B?anlrNlJHOE1VNVNERWNrRnJkUjNvdTlTcWRkTFBmS2Nmbk1qVHlKTXdWVXpy?=
 =?gb2312?B?WHQ4NWNETGhTYzdtMkkvS2ZTakRqbWRGZHdqOHhXQTJXMloyaXhaWmJId3lq?=
 =?gb2312?B?ajZNN25sYUd5Z1Q3Sko0ZGpGbmFuZFlWU283TUExayt3ZVg4bUMza0taQjNR?=
 =?gb2312?B?amtFdmtjbmgvUnFrZlltanRreForQm1lSEdQbkh2UUFYOXd1TEhIY1M5cFZ6?=
 =?gb2312?B?Y2d3YkJySWV1bU9UOTNTekk1Ri9tQmhoamxiWTcxV0pldTBXMFhZaHJzbmdu?=
 =?gb2312?B?RUdaTG5Ha0VYRitTNGVtQT09?=
x-microsoft-antispam-prvs:
 <AM0PR04MB3954CEA39580767DE3C9DCE988770@AM0PR04MB3954.eurprd04.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(136003)(366004)(346002)(376002)(199004)(189003)(13464003)(6116002)(4326008)(3846002)(53936002)(33656002)(14454004)(106356001)(6436002)(99286004)(105586002)(229853002)(97736004)(7736002)(55016002)(54906003)(478600001)(74316002)(6246003)(66066001)(9686003)(2906002)(305945005)(476003)(446003)(11346002)(8936002)(486006)(44832011)(86362001)(53546011)(186003)(26005)(316002)(68736007)(256004)(76176011)(52536013)(71200400001)(71190400001)(25786009)(14444005)(7696005)(110136005)(102836004)(8676002)(81166006)(81156014)(6506007)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB3954;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 p7i3svkzc/qVAH+kP/eiieP/OJiPsCYJyPSJUuSSglk37ELyoXYes++EWzuURO0dbkNZDVC36zVjnA/IvDnovik/r+U3MvQozn3ohaRPgNkpMl8Ky+XAbAg1F5mfezZTTnAU6HF/YVpdgIT94REcFgcUY8K4dOgp7+Cm3iLvZ1XT7U96MdpRgubu75n+czQ6U9gzycEYjKJyLOmOPivUXXJyEwAO2wdxARFhGj7aPut1r9z66kA7ei47FtMWX6VkGWNplQhq8cmJ5hq1tqnsW9qTeRc73azvbNOAPAt6n9+pc6hT0N3NSMiNIR8Ivis75gzaer1zuTVhsWTzqe44LMIZ1EHVScmqhFE4/ShQR+v3sSyjZ27VyvSx+L+3XHVnfZSESHDEIaYyC3OI7XLc35rBNn1olB6n3kWEQOEpzQw=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5b5597d4-d06d-4a01-dd9d-08d69f143bf7
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 13:37:37.3135
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB3954
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IG93bmVy
LWxpbnV4LW1tQGt2YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZ10gT24N
Cj4gQmVoYWxmIE9mIERlbm5pcyBaaG91DQo+IFNlbnQ6IDIwMTnE6jLUwjI4yNUgMTA6MTkNCj4g
VG86IERlbm5pcyBaaG91IDxkZW5uaXNAa2VybmVsLm9yZz47IFRlanVuIEhlbyA8dGpAa2VybmVs
Lm9yZz47IENocmlzdG9waA0KPiBMYW1ldGVyIDxjbEBsaW51eC5jb20+DQo+IENjOiBWbGFkIEJ1
c2xvdiA8dmxhZGJ1QG1lbGxhbm94LmNvbT47IGtlcm5lbC10ZWFtQGZiLmNvbTsNCj4gbGludXgt
bW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQ
QVRDSCAwMy8xMl0gcGVyY3B1OiBpbnRyb2R1Y2UgaGVscGVyIHRvIGRldGVybWluZSBpZiB0d28g
cmVnaW9ucw0KPiBvdmVybGFwDQo+IA0KPiBXaGlsZSBibG9jayBoaW50cyB3ZXJlIGFsd2F5cyBh
Y2N1cmF0ZSwgaXQncyBwb3NzaWJsZSB3aGVuIHNwYW5uaW5nIGFjcm9zcw0KPiBibG9ja3MgdGhh
dCB3ZSBtaXNzIHVwZGF0aW5nIHRoZSBjaHVuaydzIGNvbnRpZ19oaW50LiBSYXRoZXIgdGhhbiBy
ZWx5IG9uDQo+IGNvcnJlY3RuZXNzIG9mIHRoZSBib3VuZGFyaWVzIG9mIGhpbnRzLCBkbyBhIGZ1
bGwgb3ZlcmxhcCBjb21wYXJpc29uLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogRGVubmlzIFpob3Ug
PGRlbm5pc0BrZXJuZWwub3JnPg0KPiAtLS0NCj4gIG1tL3BlcmNwdS5jIHwgMzEgKysrKysrKysr
KysrKysrKysrKysrKysrKysrLS0tLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDI3IGluc2VydGlvbnMo
KyksIDQgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbW0vcGVyY3B1LmMgYi9tbS9w
ZXJjcHUuYw0KPiBpbmRleCA2OWNhNTFkMjM4YjUuLmI0MDExMmIyZmM1OSAxMDA2NDQNCj4gLS0t
IGEvbW0vcGVyY3B1LmMNCj4gKysrIGIvbW0vcGVyY3B1LmMNCj4gQEAgLTU0Niw2ICs1NDYsMjQg
QEAgc3RhdGljIGlubGluZSBpbnQgcGNwdV9jbnRfcG9wX3BhZ2VzKHN0cnVjdA0KPiBwY3B1X2No
dW5rICpjaHVuaywgaW50IGJpdF9vZmYsDQo+ICAJICAgICAgIGJpdG1hcF93ZWlnaHQoY2h1bmst
PnBvcHVsYXRlZCwgcGFnZV9zdGFydCk7ICB9DQo+IA0KPiArLyoNCj4gKyAqIHBjcHVfcmVnaW9u
X292ZXJsYXAgLSBkZXRlcm1pbmVzIGlmIHR3byByZWdpb25zIG92ZXJsYXANCj4gKyAqIEBhOiBz
dGFydCBvZiBmaXJzdCByZWdpb24sIGluY2x1c2l2ZQ0KPiArICogQGI6IGVuZCBvZiBmaXJzdCBy
ZWdpb24sIGV4Y2x1c2l2ZQ0KPiArICogQHg6IHN0YXJ0IG9mIHNlY29uZCByZWdpb24sIGluY2x1
c2l2ZQ0KPiArICogQHk6IGVuZCBvZiBzZWNvbmQgcmVnaW9uLCBleGNsdXNpdmUNCj4gKyAqDQo+
ICsgKiBUaGlzIGlzIHVzZWQgdG8gZGV0ZXJtaW5lIGlmIHRoZSBoaW50IHJlZ2lvbiBbYSwgYikg
b3ZlcmxhcHMgd2l0aA0KPiArdGhlDQo+ICsgKiBhbGxvY2F0ZWQgcmVnaW9uIFt4LCB5KS4NCj4g
KyAqLw0KPiArc3RhdGljIGlubGluZSBib29sIHBjcHVfcmVnaW9uX292ZXJsYXAoaW50IGEsIGlu
dCBiLCBpbnQgeCwgaW50IHkpIHsNCj4gKwlpZiAoKHggPj0gYSAmJiB4IDwgYikgfHwgKHkgPiBh
ICYmIHkgPD0gYikgfHwNCj4gKwkgICAgKHggPD0gYSAmJiB5ID49IGIpKQ0KDQpJIHRoaW5rIHRo
aXMgY291bGQgYmUgc2ltcGxpZmllZDoNCiAoYSA8IHkpICYmICh4IDwgYikgY291bGQgYmUgdXNl
ZCB0byBkbyBvdmVybGFwIGNoZWNrLg0KDQpSZWdhcmRzLA0KUGVuZy4NCg0KPiArCQlyZXR1cm4g
dHJ1ZTsNCj4gKwlyZXR1cm4gZmFsc2U7DQo+ICt9DQo+ICsNCj4gIC8qKg0KPiAgICogcGNwdV9j
aHVua191cGRhdGUgLSB1cGRhdGVzIHRoZSBjaHVuayBtZXRhZGF0YSBnaXZlbiBhIGZyZWUgYXJl
YQ0KPiAgICogQGNodW5rOiBjaHVuayBvZiBpbnRlcmVzdA0KPiBAQCAtNzEwLDggKzcyOCwxMSBA
QCBzdGF0aWMgdm9pZCBwY3B1X2Jsb2NrX3VwZGF0ZV9oaW50X2FsbG9jKHN0cnVjdA0KPiBwY3B1
X2NodW5rICpjaHVuaywgaW50IGJpdF9vZmYsDQo+ICAJCQkJCVBDUFVfQklUTUFQX0JMT0NLX0JJ
VFMsDQo+ICAJCQkJCXNfb2ZmICsgYml0cyk7DQo+IA0KPiAtCWlmIChzX29mZiA+PSBzX2Jsb2Nr
LT5jb250aWdfaGludF9zdGFydCAmJg0KPiAtCSAgICBzX29mZiA8IHNfYmxvY2stPmNvbnRpZ19o
aW50X3N0YXJ0ICsgc19ibG9jay0+Y29udGlnX2hpbnQpIHsNCj4gKwlpZiAocGNwdV9yZWdpb25f
b3ZlcmxhcChzX2Jsb2NrLT5jb250aWdfaGludF9zdGFydCwNCj4gKwkJCQlzX2Jsb2NrLT5jb250
aWdfaGludF9zdGFydCArDQo+ICsJCQkJc19ibG9jay0+Y29udGlnX2hpbnQsDQo+ICsJCQkJc19v
ZmYsDQo+ICsJCQkJc19vZmYgKyBiaXRzKSkgew0KPiAgCQkvKiBibG9jayBjb250aWcgaGludCBp
cyBicm9rZW4gLSBzY2FuIHRvIGZpeCBpdCAqLw0KPiAgCQlwY3B1X2Jsb2NrX3JlZnJlc2hfaGlu
dChjaHVuaywgc19pbmRleCk7DQo+ICAJfSBlbHNlIHsNCj4gQEAgLTc2NCw4ICs3ODUsMTAgQEAg
c3RhdGljIHZvaWQgcGNwdV9ibG9ja191cGRhdGVfaGludF9hbGxvYyhzdHJ1Y3QNCj4gcGNwdV9j
aHVuayAqY2h1bmssIGludCBiaXRfb2ZmLA0KPiAgCSAqIGNvbnRpZyBoaW50IGlzIGJyb2tlbi4g
IE90aGVyd2lzZSwgaXQgbWVhbnMgYSBzbWFsbGVyIHNwYWNlDQo+ICAJICogd2FzIHVzZWQgYW5k
IHRoZXJlZm9yZSB0aGUgY2h1bmsgY29udGlnIGhpbnQgaXMgc3RpbGwgY29ycmVjdC4NCj4gIAkg
Ki8NCj4gLQlpZiAoYml0X29mZiA+PSBjaHVuay0+Y29udGlnX2JpdHNfc3RhcnQgICYmDQo+IC0J
ICAgIGJpdF9vZmYgPCBjaHVuay0+Y29udGlnX2JpdHNfc3RhcnQgKyBjaHVuay0+Y29udGlnX2Jp
dHMpDQo+ICsJaWYgKHBjcHVfcmVnaW9uX292ZXJsYXAoY2h1bmstPmNvbnRpZ19iaXRzX3N0YXJ0
LA0KPiArCQkJCWNodW5rLT5jb250aWdfYml0c19zdGFydCArIGNodW5rLT5jb250aWdfYml0cywN
Cj4gKwkJCQliaXRfb2ZmLA0KPiArCQkJCWJpdF9vZmYgKyBiaXRzKSkNCj4gIAkJcGNwdV9jaHVu
a19yZWZyZXNoX2hpbnQoY2h1bmspOw0KPiAgfQ0KPiANCj4gLS0NCj4gMi4xNy4xDQoNCg==

