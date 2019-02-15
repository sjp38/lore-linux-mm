Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AF7AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A473621B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:30:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="sMtVZ4hg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A473621B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15F3B8E0002; Thu, 14 Feb 2019 20:30:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10FC18E0001; Thu, 14 Feb 2019 20:30:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1AFF8E0002; Thu, 14 Feb 2019 20:30:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9A68E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 20:30:43 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v26so3218085eds.17
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:30:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=ZDfR3xKh9+bDGXx9v6wdKU1j6bDyz1Go0fyyIhG9Zxo=;
        b=evD7SLw40PxAwiqcCcK1a04ydNcK/yw4chqv2PxhthkXeKuTyxbNQULgxdHc60KEj6
         TJszT/7i0Xxl3Kz9+F3CmxuPcpov4wp5+oiG+GaQB5eXoJ7eYjS2pgSTi8qXUUwQn2+m
         tzbW9kWGzqp5mRaRAkJuB/MdnD6ArGNOURskbXcmVFvsPYLPNC2ape9pBp3DdbUBunvY
         ZHq6vNLPB80wO1kvWQGACA3UndPTB2Iic396yrKDBKNwjOIR/9b9zPMR5SfOc9ylT0+0
         8sC+WzoP+imax1pgITijIV4LRCSzpv0wl+BB+nc5kX2cGXPrpqjGgqZNTRWFAlEQx7e7
         GqRQ==
X-Gm-Message-State: AHQUAuZh84GL2i+wDk9pdQRrNHbOFuwFC8S0xwKizkWCB75v2wz39V++
	XXSZAYe4A/PKciNXz8ZdU/ZVY5O7U7nsO2kvm+GQSMCzVMVVyG8zAjhQBiL5I/yHQTe2G42Brj6
	PL1sLwfsCJPa6g5mJO5r/JPvMbZfRVexS9bFidFoml/hELAsBrnyzbXxPhQoRr36udQ==
X-Received: by 2002:a17:906:812:: with SMTP id e18mr4632273ejd.28.1550194243051;
        Thu, 14 Feb 2019 17:30:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbB4HHD1MI5DXtwUAeRMR9nYBexMkpnGza+7GCuWgCRLeO+3URnhGaypdPNNp96ywU5njZR
X-Received: by 2002:a17:906:812:: with SMTP id e18mr4632229ejd.28.1550194241716;
        Thu, 14 Feb 2019 17:30:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550194241; cv=none;
        d=google.com; s=arc-20160816;
        b=LSub5gnZPWkpC0t0jhiHwKNbTgkiuH4QTPaQD8h8MFDo5nZhBMBTOMz5BMCYSRM0vT
         X0UoALDzbm74eSJa4Mnn84a65SaD4tNPnm2t6RbcjexKlOMGWTvcLTcoCwSkdxZ14Ekk
         3aUEpLrNexHucsQ3D5TFpd9TstBnZK2aUwMlb6MZN4F4z3KAXwTWD2ZhZOacHq50DIfj
         NS3+ymeFktnBY6jXzZprE/dm4h1UAyjaVt+M+B9yNRj9xJQ7nOCL92dRuqLx6OrrKaw7
         swvxKRXt0faCVYDC/qkbAmJ7Rb9UGqnWGBhe6gwxsDij20kQMqM7eVaBHHH7DD8xRQ9P
         m/4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ZDfR3xKh9+bDGXx9v6wdKU1j6bDyz1Go0fyyIhG9Zxo=;
        b=mLUPLikz1/4xkGackiQXTp7vetL7jNQnOdvAN6G1rGmYeurkJCJdSCvQS2ZylMZ48B
         ShTcp4xSPt1ELjjj65YF1EU86eXrduZNyuP0JmnoQEosAUiyC5wEVd7yU8LW5WpCQL7t
         2aAgwrGt+edmoqVqR4t4JF9kCo1SoXe+rNeLcXkDuQp7ExLvyuzMh8A3cuT8SEPAq6gV
         WuelpyKtTDJUXRD2HOayD7Rxg3tQSzphZzRang3kag090IzT0cM3OoeEkdV34oItcfuw
         U3TSWY7S4bWgUtfoFYg2y7dV4j2qm+4UkGxQZ+NDp5GZFDO807K0Mi3wStALioqGlLCl
         ZsPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=sMtVZ4hg;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.0.54 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00054.outbound.protection.outlook.com. [40.107.0.54])
        by mx.google.com with ESMTPS id me7si424239ejb.123.2019.02.14.17.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 17:30:41 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.0.54 as permitted sender) client-ip=40.107.0.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=sMtVZ4hg;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.0.54 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZDfR3xKh9+bDGXx9v6wdKU1j6bDyz1Go0fyyIhG9Zxo=;
 b=sMtVZ4hgK213qWjOdaWGfA3ZCY9psOZNEQ61aPKmYENkRfEcXTvf4ZiUvBy8hw1zrDBbX/7VX2Jh/HwQ3TDPMKGD4iBNEkL9biDZXHXqPdJgUbwDZukr311u7JY0gzGMlThcqmBKjSL0vylpfkYvd0wxxEsVHGhTDidArf7R1zE=
Received: from DB7PR04MB4490.eurprd04.prod.outlook.com (52.135.138.16) by
 DB7PR04MB4796.eurprd04.prod.outlook.com (20.176.233.94) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Fri, 15 Feb 2019 01:30:40 +0000
Received: from DB7PR04MB4490.eurprd04.prod.outlook.com
 ([fe80::fd45:a391:7591:1aa5]) by DB7PR04MB4490.eurprd04.prod.outlook.com
 ([fe80::fd45:a391:7591:1aa5%6]) with mapi id 15.20.1622.018; Fri, 15 Feb 2019
 01:30:40 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "labbott@redhat.com" <labbott@redhat.com>, "mhocko@suse.com"
	<mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>,
	"iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "rppt@linux.vnet.ibm.com"
	<rppt@linux.vnet.ibm.com>, "m.szyprowski@samsung.com"
	<m.szyprowski@samsung.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>,
	"andreyknvl@google.com" <andreyknvl@google.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>
Subject: RE: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
Thread-Topic: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
Thread-Index: AQHUxGM3TWg8yAT7z0a/qrCp1B+TP6Xfwa8AgABP9aA=
Date: Fri, 15 Feb 2019 01:30:40 +0000
Message-ID:
 <DB7PR04MB449005901376F086215EC79A88600@DB7PR04MB4490.eurprd04.prod.outlook.com>
References: <20190214125704.6678-1-peng.fan@nxp.com>
 <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
In-Reply-To: <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b30c9d42-084e-4acb-66c5-08d692e53225
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DB7PR04MB4796;
x-ms-traffictypediagnostic: DB7PR04MB4796:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtEQjdQUjA0TUI0Nzk2OzIzOlBvRzd3Z25YWVBJcUlyN3duNUhFMXJVTW5G?=
 =?gb2312?B?K0hjaXFGZmxvVEtXczV3ZmRDTUhRU0pLN1N0dTU4azBuUjA3UktMcU94T3hk?=
 =?gb2312?B?aFNrbGtPWGNyNllobDRLOFJvTDA4SGdCcHpadWRPeC8yZW5qaDNvR3IvUGxr?=
 =?gb2312?B?VUg4UEIrZWZwbVE5amZ6SkJoQ1lHa0VoNmVxbTZWUHNtRms3VG15QkRTc3hl?=
 =?gb2312?B?YkIxdEFWeDJ2NFV4Qk9KRlBJU2FtejI0WnJPbW50RFEyK3JZUjFtL011NzRK?=
 =?gb2312?B?b2pMVEdJVjNPd0VpL01UWEZlZ0JWckZVNERDR1dCOTBUblJJQlRTQVZjS1Jh?=
 =?gb2312?B?aGpQTGs5VEVzRTc2SVNnRWdrSnJncmk0OWxuNTI5STFiQ1Q0K0NLMm5NdC9u?=
 =?gb2312?B?ZnpHcEhJczVjK1lDN3l4cVVYWHBuR2RQU2hRWEoyMGtWdUR0WFROOWVpWDNq?=
 =?gb2312?B?QlVMcUpVRjkzemg4WHVuTld2SWFnbzF3VmI2aFkveTdWMDFueHVISWZGcU4x?=
 =?gb2312?B?K0ZBZ1dscXBtUzNSZFZ3VDYwRTYzRXovV1o1dDk1TkJIT2hDd3g1SnNOOWVH?=
 =?gb2312?B?Njd2cEIyalhOdUppWkwwQ0NyeVl3ZndlVmpaUFo0MU82cUpYSnAweGtubllR?=
 =?gb2312?B?aVFWVm1DRTBHTXUvdlpMUE9rTitrdit1akcwMGJQTEJGVkQxUzAwdjUrdzJq?=
 =?gb2312?B?aHRsUDFQbTFreXNiUVM5OVplT2gxVnU1R0lERnY2ZlJDalpPWWF5eHE5eHo3?=
 =?gb2312?B?bVRnbGJSM0NjRXUwM0RMallYVDF2ZjdWa2dYOEZGa2RCaVlBNFk5Q1daYXFv?=
 =?gb2312?B?RExZNEs4cVllRnYrNnNBTzlSUS85ODVmNU9FMStVeUlKTFhSdjFxOUV4RkRR?=
 =?gb2312?B?OWlxZHdDdkdIbC9NUDRlWjM0ZkkrVDFiZE0yTG9tK3dPRDQ0ZzRwVTRKWEIx?=
 =?gb2312?B?Q0l2V21yM05OdVJXTld4cFRwRjhYMUw1RmliU1FPZDVxYzZsZTRIVXNwWDBn?=
 =?gb2312?B?ODhaYzUyQU1rUy94NTY3ekNaZ1l2U3BqMFFaTkMrNmxRc2ZCWHUzVTNwYkpy?=
 =?gb2312?B?dFpqWE5HZm45ckJPSWJYSUg1MC81bitCc3hCVEtXNWJBMHZKdTcvL2JFd2hz?=
 =?gb2312?B?R2dkak5OTm8xREFnNy80SmNMckZNMGlkSXEyVmYyTG1qTENpTWpwUTZTYXJC?=
 =?gb2312?B?R0NhQnhNYVFuRitjS0lLUFdzL2ZId3NNSUlRbERZdm9aS0JsUkZQSTZ2SER3?=
 =?gb2312?B?ZWtONHdoWmd3bC9nakJNS0NWcnppN1ZVdWtqWlJnWFo0THNJRy9xRlZ4alhB?=
 =?gb2312?B?MFRtS1JuV1dWRnR5Qi9YeCtLTVBZVkFrYkZQQWk1NC8xR3plM2Y0RE92Uk9p?=
 =?gb2312?B?Q041eEw0N1RjZHZxTG95U2lsOC9TajA3Q2xPSXZrYURJSC9TWkhCeS95RzBG?=
 =?gb2312?B?NlhrdU5NKzNPNUU4Tlc5VmdvVEpOb2N0TGIxRFBCRko3eUpBRmZTbEpVd0VJ?=
 =?gb2312?B?OTFVWjRpVVFvL1J5MXo5RHdIejhQV2hITUF2Y3F0UTVKcWZ3MlpickkxMHBo?=
 =?gb2312?B?M2VHU3FQSTgvbHd2VC9GTHFPaVZmSlpBRjR6cVZaRFhLZ3ZuNWNnemxuOEQr?=
 =?gb2312?B?QVFqam54MEQ3Q25hUjJ4OC9sbHdmaFVpd0QvQzJyUERPN2VPdzdpRVdQRE5I?=
 =?gb2312?Q?MBxcw5rJem1Dwzmqen9XmfX6zeqjhn6JSjPFKsG?=
x-microsoft-antispam-prvs:
 <DB7PR04MB47960321DC774A22AE96E91488600@DB7PR04MB4796.eurprd04.prod.outlook.com>
x-forefront-prvs: 09497C15EB
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(376002)(366004)(396003)(39860400002)(199004)(189003)(13464003)(81156014)(81166006)(74316002)(53936002)(256004)(11346002)(8676002)(8936002)(305945005)(102836004)(4326008)(71190400001)(71200400001)(6506007)(6246003)(25786009)(7736002)(2906002)(97736004)(55016002)(6116002)(186003)(68736007)(3846002)(53546011)(6436002)(14444005)(229853002)(105586002)(86362001)(316002)(106356001)(66066001)(14454004)(99286004)(26005)(478600001)(9686003)(6916009)(446003)(476003)(54906003)(44832011)(7416002)(76176011)(33656002)(7696005)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR04MB4796;H:DB7PR04MB4490.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 VIZ6yXJY5SogGXM3F/Mzu++9fjZ4hMmzN0yywlzyDqGqT+8P1cz4TXau4RnVGXQkbD1Z+abjz/mJWZtQWYMqLvnQzV8xfbgkJa+YIHdwanR2QuXfF5nIEmRgn/PbVf5l13Ndu+EwQIFxuGN3GEUxDKhphQz49zfeaafCOsK/1c7GwP95B7O3qepB5KBNxtEl4VkBrtDkzyxZgDNgmKjvsMFtEbM9CpxnMJkDuAm//+jEnJx4WOp3I0bfHSUHSS4HVZ4d1rlwz43Bb3oxBCCHnQ6KnQpJQZ7ftIeoBdyfu40sUDeFCLMNszpyDUlbmO/iI38VLlM/2XYUm66xIei4Ufn3SRLGeO7w9nqAAsGlXVbF4PwVO9F+5wghCT2yhM0AIumRswhhqyFeVykfjIJVjfSWiTqrVYjNVVB2hvk9jvw=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b30c9d42-084e-4acb-66c5-08d692e53225
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Feb 2019 01:30:40.4600
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR04MB4796
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQW5kcmV3DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQW5kcmV3
IE1vcnRvbiBbbWFpbHRvOmFrcG1AbGludXgtZm91bmRhdGlvbi5vcmddDQo+IFNlbnQ6IDIwMTnE
6jLUwjE1yNUgNDozOA0KPiBUbzogUGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQo+IENjOiBs
YWJib3R0QHJlZGhhdC5jb207IG1ob2Nrb0BzdXNlLmNvbTsgdmJhYmthQHN1c2UuY3o7DQo+IGlh
bWpvb25zb28ua2ltQGxnZS5jb207IHJwcHRAbGludXgudm5ldC5pYm0uY29tOw0KPiBtLnN6eXBy
b3dza2lAc2Ftc3VuZy5jb207IHJkdW5sYXBAaW5mcmFkZWFkLm9yZzsNCj4gYW5kcmV5a252bEBn
b29nbGUuY29tOyBsaW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5v
cmc7DQo+IHZhbi5mcmVlbml4QGdtYWlsLmNvbTsgTWlrZSBSYXBvcG9ydCA8cnBwdEBsaW51eC5p
Ym0uY29tPg0KPiBTdWJqZWN0OiBSZTogW1BBVENIXSBtbS9jbWE6IGNtYV9kZWNsYXJlX2NvbnRp
Z3VvdXM6IGNvcnJlY3QgZXJyIGhhbmRsaW5nDQo+IA0KPiBPbiBUaHUsIDE0IEZlYiAyMDE5IDEy
OjQ1OjUxICswMDAwIFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPiB3cm90ZToNCj4gDQo+ID4g
SW4gY2FzZSBjbWFfaW5pdF9yZXNlcnZlZF9tZW0gZmFpbGVkLCBuZWVkIHRvIGZyZWUgdGhlIG1l
bWJsb2NrDQo+ID4gYWxsb2NhdGVkIGJ5IG1lbWJsb2NrX3Jlc2VydmUgb3IgbWVtYmxvY2tfYWxs
b2NfcmFuZ2UuDQo+ID4NCj4gPiAuLi4NCj4gPg0KPiA+IC0tLSBhL21tL2NtYS5jDQo+ID4gKysr
IGIvbW0vY21hLmMNCj4gPiBAQCAtMzUzLDEyICszNTMsMTQgQEAgaW50IF9faW5pdCBjbWFfZGVj
bGFyZV9jb250aWd1b3VzKHBoeXNfYWRkcl90DQo+ID4gYmFzZSwNCj4gPg0KPiA+ICAJcmV0ID0g
Y21hX2luaXRfcmVzZXJ2ZWRfbWVtKGJhc2UsIHNpemUsIG9yZGVyX3Blcl9iaXQsIG5hbWUsDQo+
IHJlc19jbWEpOw0KPiA+ICAJaWYgKHJldCkNCj4gPiAtCQlnb3RvIGVycjsNCj4gPiArCQlnb3Rv
IGZyZWVfbWVtOw0KPiA+DQo+ID4gIAlwcl9pbmZvKCJSZXNlcnZlZCAlbGQgTWlCIGF0ICVwYVxu
IiwgKHVuc2lnbmVkIGxvbmcpc2l6ZSAvIFNaXzFNLA0KPiA+ICAJCSZiYXNlKTsNCj4gPiAgCXJl
dHVybiAwOw0KPiA+DQo+ID4gK2ZyZWVfbWVtOg0KPiA+ICsJbWVtYmxvY2tfZnJlZShiYXNlLCBz
aXplKTsNCj4gPiAgZXJyOg0KPiA+ICAJcHJfZXJyKCJGYWlsZWQgdG8gcmVzZXJ2ZSAlbGQgTWlC
XG4iLCAodW5zaWduZWQgbG9uZylzaXplIC8gU1pfMU0pOw0KPiA+ICAJcmV0dXJuIHJldDsNCj4g
DQo+IFRoaXMgZG9lc24ndCBsb29rIHJpZ2h0IHRvIG1lLiAgSW4gdGhlIGBmaXhlZD09dHJ1ZScg
Y2FzZSB3ZSBkaWRuJ3QgYWN0dWFsbHkNCj4gYWxsb2NhdGUgYW55dGhpbmcgYW5kIGluIHRoZSBg
Zml4ZWQ9PWZhbHNlJyBjYXNlLCB0aGUgYWxsb2NhdGVkIG1lbW9yeSBpcyBhdA0KPiBgYWRkcics
IG5vdCBhdCBgYmFzZScuDQoNCk15IGNvZGUgYmFzZSBpcyA1LjAuMC1yYzYsIGluIG1tL2NtYS5j
DQozMTMgICAgICAgICAvKiBSZXNlcnZlIG1lbW9yeSAqLw0KMzE0ICAgICAgICAgaWYgKGZpeGVk
KSB7DQozMTUgICAgICAgICAgICAgICAgIGlmIChtZW1ibG9ja19pc19yZWdpb25fcmVzZXJ2ZWQo
YmFzZSwgc2l6ZSkgfHwNCjMxNiAgICAgICAgICAgICAgICAgICAgIG1lbWJsb2NrX3Jlc2VydmUo
YmFzZSwgc2l6ZSkgPCAwKSB7DQozMTcgICAgICAgICAgICAgICAgICAgICAgICAgcmV0ID0gLUVC
VVNZOw0KMzE4ICAgICAgICAgICAgICAgICAgICAgICAgIGdvdG8gZXJyOw0KMzE5ICAgICAgICAg
ICAgICAgICB9DQozMjAgICAgICAgICB9IGVsc2Ugew0KDQpXaGVuIGZpeGVkIGlzIHRydWUsIG1l
bWJsb2NrX2lzX3JlZ2lvbl9yZXNlcnZlZCB3aWxsIGNoZWNrIHdoZXRoZXIgdGhlIFtiYXNlLCBi
YXNlICsgc2l6ZSkNCmlzIHJlc2VydmVkLCBpZiByZXNlcnZlZCwgcmV0dXJuIC1FQlVTWSwgaWYg
bm90IHJlc2VydmVkLCBpdCB3aWxsIGNhbGwgbWVtYmxvY2tfcmVzZXJ2ZSwNCmlmIG1lbWJsb2Nr
X3Jlc2VydmUgZmFpbCwgaXQgd2lsbCByZXR1cm4gLUVCVVNZLg0KDQpXaGVuIGZpeGVkIGlzIGZh
bHNlLCBhZnRlciBtZW1ibG9ja19hbGxvY19yYW5nZSwgdGhlcmUgaXMgb25lIGxpbmUgY29kZSBg
YmFzZSA9IGFkZHI7YC4NCg0KVGhhbmtzLA0KUGVuZy4NCg0K

