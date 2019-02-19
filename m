Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06CBBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:40:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A37721479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:40:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="LIGiJ2MD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A37721479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11E938E0003; Tue, 19 Feb 2019 15:40:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CEEC8E0002; Tue, 19 Feb 2019 15:40:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB2B78E0003; Tue, 19 Feb 2019 15:40:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBA48E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:40:32 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x47so8860736eda.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:40:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=PWcqMAvh13+eyVEjXk9+t9GSzMWFxosVmHwtxHRWenQ=;
        b=fkNbiofnGsbl2qHx6T8xfTrNHPyvq95vfXM5dS+tU/ksOBaH2HGqx2TZTe/nouv2YI
         3DX0FWxFTDOk9qFl739gbPy2BwQGAWMLxl5UKetBv5xw+xyCFCQe8pmJHs7q0kbxS3ma
         zVX8bZIy7uisJi2uXsNqluYs+op/gqX3ZXvlKICdWPhZPaenJfeTe/XuhuzmAW+S6TsP
         tC/SIVyBJaWmlCvyUrrNesWwzifKlYpNeuT9OWUpn7BOrWUzFNgz2KoBKZM2PK3QkVdJ
         wCGTeKt1F0aVX20kCHOryA3huzDBsXzZOw3lswL8BrcFVt/7apkAkaFePmNBh0wrnMS0
         aH0w==
X-Gm-Message-State: AHQUAubWsId/M3sjSN+Gbp3HvrQBeinA5h7dAFe7qZ2tdj4TuIxjMinf
	Ohx4WcpYOHPt74a2fxSTf9Di1sGf5cAg1qPY5Y+KVr0gAr7d9H7+O+qHHH5kN9iR2a5Rxi2ilul
	RKrW2DZrsjes9U//knYegURAl1cSKR2/Qb13fCGYni8/0OY+dEkFu730TndHfq1UNBA==
X-Received: by 2002:a50:9863:: with SMTP id h32mr25287761edb.291.1550608832148;
        Tue, 19 Feb 2019 12:40:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZC+CcrqAI6zwg9g6oKRSub6l+kyamF/m59GHq7HcShE/abhvLn5GYwD6sXOdNyaNzT/IPA
X-Received: by 2002:a50:9863:: with SMTP id h32mr25287717edb.291.1550608831302;
        Tue, 19 Feb 2019 12:40:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550608831; cv=none;
        d=google.com; s=arc-20160816;
        b=Qlxg8td1YtTmKPTJOYoYzfSMKmgJhYC8z+3VPuqeUrAxdnxWLAHRKIIfd/98k0a2zN
         NNXVIuXGpgdCW5145PFZk+Jz+Y2kGdtI9ayw325JcZsYkf9E0BXUwiTGnZM7WZ3aTlv5
         s3D8nrdrO5UQnDs/NACvCJg4vSxqJFRC5s3f/Ia124I8gq0PIHu6h0z5cCR97Lt7TISy
         81Ze4SmrwWJSDAaO82KGwFP3200Cr2rrblnq0CIoRHx2+rsjTwHcm073SMAALNsr7pBK
         fcsoiZVtwCFXevLrbHNXfo/fsd7dEsVuUMGKum2B/5asPgyaYm+OG7+7EF+rJ8vLMOil
         9Hbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=PWcqMAvh13+eyVEjXk9+t9GSzMWFxosVmHwtxHRWenQ=;
        b=GNf+oWH/sbRbktvzCed1JNcwqjZ0TZOicexOu76quoStkYnCTiu7R9fISPCIaWYyko
         LqGZYPsvuuPP3RtkRtjqdAVma5fz5BJQ2m+3+5v3mjnDx6RwauqgMEXFKOs9/5bl9Wh6
         tdTOdXe1YoY2Id0D7Xiaobgtd4Wfp9Yx9PObeb9vmku+qgLLNzjqyDoWIleW21C1b0po
         cgW3Bhw82anLamHRHc/KMA7JGwJNmchUrzoryd1JxLoLWedWojt7skoDN0ukCraAotPo
         uVZXbBfO+2cizQcKPlX8WpgqZhfuxRHuXYC+HPMIUoG5dpUxDvYLLSUz41R4JtcyrC5P
         cx+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=LIGiJ2MD;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50056.outbound.protection.outlook.com. [40.107.5.56])
        by mx.google.com with ESMTPS id p22si2261186eju.6.2019.02.19.12.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Feb 2019 12:40:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.56 as permitted sender) client-ip=40.107.5.56;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=LIGiJ2MD;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PWcqMAvh13+eyVEjXk9+t9GSzMWFxosVmHwtxHRWenQ=;
 b=LIGiJ2MD04yV+TfElLshl3U5ASNk4n1q6lSe8nJ/YH4wyIz7g0va9eLVMhfn9ewS5RZbF1E0KJgBM+9R18pQRomsMhNfgFn5wYe2I0aKB5HosOsUwbYOkUb+DUhU18KhfnFlumET7yEb6pk+trz5d5oH2hkQWB0vH30MCgpbLQI=
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com (20.179.44.81) by
 DBBPR05MB6331.eurprd05.prod.outlook.com (20.179.41.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.14; Tue, 19 Feb 2019 20:40:26 +0000
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f]) by DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f%2]) with mapi id 15.20.1622.018; Tue, 19 Feb 2019
 20:40:26 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Ross Zwisler <zwisler@kernel.org>, Paolo Bonzini
	<pbonzini@redhat.com>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John
 Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>, Maling list -
 DRI developers <dri-devel@lists.freedesktop.org>, linux-rdma
	<linux-rdma@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 0/9] mmu notifier provide context informations
Thread-Topic: [PATCH v5 0/9] mmu notifier provide context informations
Thread-Index: AQHUyI5fmJseBFElC02lRanOuqzgnqXnjrmAgAAEF4CAAAK4gA==
Date: Tue, 19 Feb 2019 20:40:26 +0000
Message-ID: <20190219204017.GP738@mellanox.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <CAPcyv4gq23RXk3BTqP2O+gi3FGE85NSGXD8bdLk+_cgtZrn+Kg@mail.gmail.com>
 <20190219203032.GC3959@redhat.com>
In-Reply-To: <20190219203032.GC3959@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR14CA0042.namprd14.prod.outlook.com
 (2603:10b6:300:12b::28) To DBBPR05MB6570.eurprd05.prod.outlook.com
 (2603:10a6:10:d1::17)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8b4cedb7-3f99-425b-39d0-08d696aa7aa7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6331;
x-ms-traffictypediagnostic: DBBPR05MB6331:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtEQkJQUjA1TUI2MzMxOzIzOlhzb3FJZ3VXeVUyMkRKSXBBbWZJSW04Qi9G?=
 =?utf-8?B?MlArdGRRQ01sbzBHZ1Y5RUR4Z1U5N3RGcW5OV1JnY05GdUsxdTQvakc0czAx?=
 =?utf-8?B?bXZvd0tDZFRsUlRBVnlpVWhITzB2VVUxczRoOEZma3NDcDkxWmVtZHAzWkF0?=
 =?utf-8?B?UVFVU2hKbFZTV1cvWVc2Y25XTzNpNjJJcjRIU1dBc1ZoR2d2VXkwTGtFWU5H?=
 =?utf-8?B?NEJSV3dDeEtHTFFvWnBJSkZ5K2JSMzZBbkRPUmtPR1hQNktZMFJxRVAxWG15?=
 =?utf-8?B?Z1RvU1JQTGZVbHh4V3VTTVhtV0RiVzZ5SW5FTDlyV3pFRnVXN1R2QWJzZ2pD?=
 =?utf-8?B?SVB4OW1WY3Fjajd5YlM2b211RHJBajFsMWZDdWx0R3RWSTlYSHlhb3cyMEJF?=
 =?utf-8?B?NFVCM1l4Y05VMDJJZkZvQ2FlRzVFWGtCUlNiYUMrTi9GRWdFZWdLcG5sbDVX?=
 =?utf-8?B?dWFYNThqVzJ5dmRIU0hYd1I0QktjVG1uU08vQnQ1VHVXdmJPSmJqcUl2dVpj?=
 =?utf-8?B?MTBGaEdDYi9FMG5uNUFPOHQ3QS9Ta3haYUl6a1p3b1pHTmtCT1R1NEpRWHVM?=
 =?utf-8?B?OStwUFhBN2xxbytXaEtSejV6a3NlUDl1SkxQaTR6ZzA4U0hRSWNGWUM4ejJw?=
 =?utf-8?B?R0d1RkViTStSVVVpUjRZTHllN0V4RnpZek5QM0l0eWdiSVdLVjR3QkVCL1lZ?=
 =?utf-8?B?ME5sQmxxeHN6blQrQ3cyeFd0N3ZHeitIY3FzN0dFdmVMS1I4eVF5UkhkV0I4?=
 =?utf-8?B?S3RtcGxxekdXUXErdWN3dnlwU25uS1ZYZGZFeWFLWDFtTG1hMGhjMFBjSkhP?=
 =?utf-8?B?VXF5ak9lNHBKbXVrY2cwV3pUMTg4MVByeCtZaEZyUDY0bTJ3Qk0ydXNUVW5K?=
 =?utf-8?B?TTBPOXlZem5MKzdJekhRdHNSZ3Z2alkrUjJxMWxGOXcrcWFxaHRnc3djY3pZ?=
 =?utf-8?B?SldGcU1ZQ1M4bExhcXdSeFJEd3E5aTJhRFFyOWpZVEh3M2tRc2VpZHh2TG1w?=
 =?utf-8?B?MEk2N1k4ZnNyY2JJbldiTzJUV3lVN3UzbXpGalpEcjZic3ZUNGxVL2Z3ekpl?=
 =?utf-8?B?REtMaG9jandyT2VNbDFWOGRaYUZmaTBhRkkrUkg0OENGQ2VQVUxSTno1MVJa?=
 =?utf-8?B?elgxRVhlUk9IZ2Fock05WEF1ckFSQzloMkpTQ0JGcTkxYkVURXU1ZXMwZmZK?=
 =?utf-8?B?YlZhVmNFR0RpT2VtNUlVdHRvZlV2c04vTFlPSHFwTzZpU21ZUEEydS9WTmtJ?=
 =?utf-8?B?L3gvd21ua2srd1hMTUVjT0R5akl5a0NvaHhTSGxSSTVMbGE0bUpORElpMGRv?=
 =?utf-8?B?WmRWM1lsZm9JWm9GSCtoemVxdENLMkpld3dtOXJGWUJaVndIdnh2REhpQ0lG?=
 =?utf-8?B?aGRlalRKdUpML0RYK2FNenpuaXU0L3pSdkNwMUtZbzZ0T2NSWG5JUDRNZmpP?=
 =?utf-8?B?QUp0c1E5NjJOQ0ViTkRoZ3dZZ0RaeFhWeElpcEw2Y0dndCtjdDBWUnFFNDFE?=
 =?utf-8?B?b0VGSUNuUVlUdXY5U1dQcUdHdXJjcWV0czNWK1dpS3hLMWRjcVdKQ2tmZ2Uv?=
 =?utf-8?B?RXd1NzZ0cTBmK1JQanZCbHR5Um1IaUFKWm1NT0JpTlFqbmpmV05nV00xazN3?=
 =?utf-8?B?eUZLMzQ3MExYRnkzYnpEUytndUo1MW4zNk1ZWUhjU3g2bHdXRlhGeWlwQ1lv?=
 =?utf-8?B?eTdQbVl6SE5KeGErbWFJanVOZDUyUkVOUCtyMmw0KzlqMFlreUJ6K1dRNWJ6?=
 =?utf-8?Q?a6v0wkvkgIJzDvmwt1KLg6ZquSjPCIVKLBTP8=3D?=
x-microsoft-antispam-prvs:
 <DBBPR05MB63312A67A5AAEBC28402AD44CF7C0@DBBPR05MB6331.eurprd05.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(376002)(136003)(366004)(346002)(199004)(189003)(68736007)(5660300002)(229853002)(66066001)(6916009)(256004)(102836004)(6436002)(186003)(6246003)(53936002)(6512007)(6486002)(26005)(71190400001)(71200400001)(6116002)(3846002)(33656002)(478600001)(14454004)(106356001)(54906003)(316002)(105586002)(36756003)(97736004)(53546011)(52116002)(2906002)(81156014)(4326008)(25786009)(8676002)(6506007)(7736002)(305945005)(7416002)(76176011)(1076003)(66574012)(2616005)(476003)(446003)(11346002)(99286004)(486006)(8936002)(386003)(86362001)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6331;H:DBBPR05MB6570.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ML0QDUZA2y4knWZtCMEMsifScz1eKEEaNVtAcDM3IgonwDJ3A+qKz/SVh9zR1iW1NtG1THng8JPkuVdcRrDjEJX+KdLEZ8buqzuC83KlIJ/E2pu/y+gAQdYV1LpRe42orEJRjLm3moNRcE1VugwKwGTpOOq7ybfH7rAARmVocaS/5iKGqDcH92CuoZUPF//S5gOiVj/U/Ii4VRe68bkckesCZkmT+Uc4ieTpfsxaITyIVQdGl8KggAKHhQfSLMtUsaxENEjYtqiVQzJrmYRPEik4ydvYvJZVH4cMyY5RL5o1b3U6LHoxh04Kc/wkKVyAJtTyNEueTgC5EcuxEPhUxtnBLhYF+9OObyLZpDvCoOnogWcNCCVRDYj3mt86QRkB36E96ABE6tbeQT6UFyFnEndOozjD6bXib26mdwauD7k=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E141E9B0AE16924A93A4E3D62440AD81@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8b4cedb7-3f99-425b-39d0-08d696aa7aa7
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 20:40:26.5860
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6331
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCBGZWIgMTksIDIwMTkgYXQgMDM6MzA6MzNQTSAtMDUwMCwgSmVyb21lIEdsaXNzZSB3
cm90ZToNCj4gT24gVHVlLCBGZWIgMTksIDIwMTkgYXQgMTI6MTU6NTVQTSAtMDgwMCwgRGFuIFdp
bGxpYW1zIHdyb3RlOg0KPiA+IE9uIFR1ZSwgRmViIDE5LCAyMDE5IGF0IDEyOjA0IFBNIDxqZ2xp
c3NlQHJlZGhhdC5jb20+IHdyb3RlOg0KPiA+ID4NCj4gPiA+IEZyb206IErDqXLDtG1lIEdsaXNz
ZSA8amdsaXNzZUByZWRoYXQuY29tPg0KPiA+ID4NCj4gPiA+IFNpbmNlIGxhc3QgdmVyc2lvbiBb
NF0gaSBhZGRlZCB0aGUgZXh0cmEgYml0cyBuZWVkZWQgZm9yIHRoZSBjaGFuZ2VfcHRlDQo+ID4g
PiBvcHRpbWl6YXRpb24gKHdoaWNoIGlzIGEgS1NNIHRoaW5nKS4gSGVyZSBpIGFtIG5vdCBwb3N0
aW5nIHVzZXJzIG9mDQo+ID4gPiB0aGlzLCB0aGV5IHdpbGwgYmUgcG9zdGVkIHRvIHRoZSBhcHBy
b3ByaWF0ZSBzdWItc3lzdGVtcyAoS1ZNLCBHUFUsDQo+ID4gPiBSRE1BLCAuLi4pIG9uY2UgdGhp
cyBzZXJpZSBnZXQgdXBzdHJlYW0uIElmIHlvdSB3YW50IHRvIGxvb2sgYXQgdXNlcnMNCj4gPiA+
IG9mIHRoaXMgc2VlIFs1XSBbNl0uIElmIHRoaXMgZ2V0cyBpbiA1LjEgdGhlbiBpIHdpbGwgYmUg
c3VibWl0dGluZw0KPiA+ID4gdGhvc2UgdXNlcnMgZm9yIDUuMiAoaW5jbHVkaW5nIEtWTSBpZiBL
Vk0gZm9sa3MgZmVlbCBjb21mb3J0YWJsZSB3aXRoDQo+ID4gPiBpdCkuDQo+ID4gDQo+ID4gVGhl
IHVzZXJzIGxvb2sgc21hbGwgYW5kIHN0cmFpZ2h0Zm9yd2FyZC4gV2h5IG5vdCBhd2FpdCBhY2tz
IGFuZA0KPiA+IHJldmlld2VkLWJ5J3MgZm9yIHRoZSB1c2VycyBsaWtlIGEgdHlwaWNhbCB1cHN0
cmVhbSBzdWJtaXNzaW9uIGFuZA0KPiA+IG1lcmdlIHRoZW0gdG9nZXRoZXI/IElzIGFsbCBvZiB0
aGUgZnVuY3Rpb25hbGl0eSBvZiB0aGlzDQo+ID4gaW5mcmFzdHJ1Y3R1cmUgY29uc3VtZWQgYnkg
dGhlIHByb3Bvc2VkIHVzZXJzPyBMYXN0IHRpbWUgSSBjaGVja2VkIGl0DQo+ID4gd2FzIG9ubHkg
YSBzdWJzZXQuDQo+IA0KPiBZZXMgcHJldHR5IG11Y2ggYWxsIGlzIHVzZSwgdGhlIHVudXNlIGNh
c2UgaXMgU09GVF9ESVJUWSBhbmQgQ0xFQVINCj4gdnMgVU5NQVAuIEJvdGggb2Ygd2hpY2ggaSBp
bnRlbmQgdG8gdXNlLiBUaGUgUkRNQSBmb2xrcyBhbHJlYWR5IGFjaw0KPiB0aGUgcGF0Y2hlcyBJ
SVJDLCBzbyBkaWQgcmFkZW9uIGFuZCBhbWRncHUuIEkgYmVsaWV2ZSB0aGUgaTkxNSBmb2xrcw0K
PiB3ZXJlIG9rIHdpdGggaXQgdG9vLiBJIGRvIG5vdCB3YW50IHRvIG1lcmdlIHRoaW5ncyB0aHJv
dWdoIEFuZHJldw0KPiBmb3IgYWxsIG9mIHRoaXMgd2UgZGlzY3Vzc2VkIHRoYXQgaW4gdGhlIHBh
c3QsIG1lcmdlIG1tIGJpdHMgdGhyb3VnaA0KPiBBbmRyZXcgaW4gb25lIHJlbGVhc2UgYW5kIGJp
dHMgdGhhdCB1c2UgdGhpbmdzIGluIHRoZSBuZXh0IHJlbGVhc2UuDQoNCkl0IGlzIHVzdWFsbHkg
Y2xlYW5lciBmb3IgZXZlcnlvbmUgdG8gc3BsaXQgcGF0Y2hlcyBsaWtlIHRoaXMsIGZvcg0KaW5z
dGFuY2UgSSBhbHdheXMgcHJlZmVyIHRvIG1lcmdlIFJETUEgcGF0Y2hlcyB2aWEgUkRNQSB3aGVu
DQpwb3NzaWJsZS4gTGVzcyBjb25mbGljdHMuDQoNClRoZSBvdGhlciBzb21ld2hhdCByZWFzb25h
YmxlIG9wdGlvbiBpcyB0byBnZXQgYWNrcyBhbmQgc2VuZCB5b3VyIG93bg0KY29tcGxldGUgUFIg
dG8gTGludXMgbmV4dCB3ZWVrPyBUaGF0IHdvcmtzIE9LIGZvciB0cmVlLXdpZGUgY2hhbmdlcy4N
Cg0KSmFzb24gDQo=

