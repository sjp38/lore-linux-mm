Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CDEAC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 10:48:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DC4F20850
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 10:48:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="A1n7ucjV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DC4F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A5396B0279; Wed, 10 Apr 2019 06:48:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92D2F6B027A; Wed, 10 Apr 2019 06:48:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CE486B027B; Wed, 10 Apr 2019 06:48:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5AE6B0279
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 06:48:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w27so1034518edb.13
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:48:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=RregPHHcbcgiEmzXfOp04YmDavjHKFPYjchxoWZoSRs=;
        b=oD6TBWlE8zSaUtGD1qnrAef/OeIXKZSwPSrfolIFwcuVoD8PKlBcw8NQrNJxkZ0IbU
         4SZH7aSaXpdGnIcZzSdpTgBwb3vRAXSok4wjZYWThVi/yvPVKbTfvKBjOCjSoXhAaAJ0
         WpuX1hNW7G4UrL5/WkH9vecx2IY1gxP7/QrtAPPg3SCxIQMIpAr5jWghYOh3bqOcwCUS
         foQHthNeTnrorpW36PQKOH0ncYIobx4fH4Z2Ywpg83duGv4VzSHVNCF8XU0jZ4JOQO0Y
         e3PFPVS2mze1PUqkAgnIvWB44WDFy+RujjfoURFSXxNn5016f4U1/i6p2aG8/XesKhWA
         As+A==
X-Gm-Message-State: APjAAAUAfdqjQD86hrdcWaQvq3dcGX4uAdnar4Np4wbaNKHGP4htQB7S
	yzMSNjbF7XRxb2YDKTOA3fd76ZyagBbaGsPQ+VF/4kX8wUOI2rHpabPUvX49ceaNt+eqUrg9U3K
	z/sKw3vSLZfK65okBm8PWCa0SiaPP+3voULaTQbCgKFajt9cDcH9AoMw/jKLDltmYAQ==
X-Received: by 2002:a05:6402:709:: with SMTP id w9mr27491974edx.14.1554893308622;
        Wed, 10 Apr 2019 03:48:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxICPkt2GocRWNmoxZJ1WDBPFnuVSMGbItpKVh77GQ++RA0lpasS9dG9zkhzZkc8p/B0VWY
X-Received: by 2002:a05:6402:709:: with SMTP id w9mr27491939edx.14.1554893307790;
        Wed, 10 Apr 2019 03:48:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554893307; cv=none;
        d=google.com; s=arc-20160816;
        b=vGFO8hVqNKz18j7uFB1JSf9YTgee3fiElPkpILCs44DDa4gr7A2grPjTa6+3eTNjPz
         I5BAEYV9lVcCxWMyQlsxLFl7t0EbSHWl/Zlj5HbrWmUNP+a6m76aqpctbH8NF9Q4i4rn
         IO3/0d4JNinuVCR0KANzm9WUf9N9ip9szfEqnSH1ixexMk2ibdQr5AuaNgNIA5IxlVJh
         UreDLIkue+YiK7EHCHUvedoDsI3l73PxWMCZFs7YHOUftRp2CsUJ7gT/e2oxKU27OvvC
         CaYvihqsU9/2lbipqQX6C/M8EVL6PdXtrfVIrDBpnzhXQjttLbRViCqs6HuoE0f15Xe+
         MHRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=RregPHHcbcgiEmzXfOp04YmDavjHKFPYjchxoWZoSRs=;
        b=uFAOqOe+ARgm1QHqmhr87sUfE3HhFobyOmOh5Ym8DTXaKAtmQo/ZgUkyNKUpNCt9cP
         GV8nnMmlNa/WeNNektOShojgsw3mCyqnFGT3Dkwpd2Fg/6GzfB14429kMi4qlxAmS2zk
         blJRocl+QfFvpuc463CrFWA0MounDZ1W2DpowEWiZtGlTDfh8xISDUlN+qU+om8YwONj
         K94PShCDGfoiTpNbx95wWWP18Wgxf6NlvHxJOKa9ELPh3L6q7D7jJjZVkRvuQ/MglLHA
         baxndpkCFVcHq6kQi2WeCXAB/EajrMUEe++WDYpempqcWvM9LOYIUz46wfeGX2kVHgFw
         Rr+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=A1n7ucjV;
       spf=pass (google.com: domain of jared.hu@nxp.com designates 40.107.3.50 as permitted sender) smtp.mailfrom=jared.hu@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30050.outbound.protection.outlook.com. [40.107.3.50])
        by mx.google.com with ESMTPS id h44si356467ede.156.2019.04.10.03.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Apr 2019 03:48:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jared.hu@nxp.com designates 40.107.3.50 as permitted sender) client-ip=40.107.3.50;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=A1n7ucjV;
       spf=pass (google.com: domain of jared.hu@nxp.com designates 40.107.3.50 as permitted sender) smtp.mailfrom=jared.hu@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RregPHHcbcgiEmzXfOp04YmDavjHKFPYjchxoWZoSRs=;
 b=A1n7ucjV+IgLd+0URyR8KHqaXAVroNrIcWNFJauAD6IRuw9X3NZeZ+A6V21eGa1sAh1TciVPHp4WQ7jIFi4onG2KQ49Zpzu06+qnVkmXjUe41OXB7ox3Ry6hFHhx7mZHymjFoK9I5Auotwx9zBXhMGi98tygyZUS7AjtUVbRlhQ=
Received: from VE1PR04MB6429.eurprd04.prod.outlook.com (20.179.232.154) by
 VE1PR04MB6528.eurprd04.prod.outlook.com (20.179.233.225) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.16; Wed, 10 Apr 2019 10:48:26 +0000
Received: from VE1PR04MB6429.eurprd04.prod.outlook.com
 ([fe80::45ab:e480:592b:2592]) by VE1PR04MB6429.eurprd04.prod.outlook.com
 ([fe80::45ab:e480:592b:2592%3]) with mapi id 15.20.1771.016; Wed, 10 Apr 2019
 10:48:26 +0000
From: Jared Hu <jared.hu@nxp.com>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz"
	<vbabka@suse.cz>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
	"labbott@redhat.com" <labbott@redhat.com>, "huyue2@yulong.com"
	<huyue2@yulong.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
	"rppt@linux.ibm.com" <rppt@linux.ibm.com>, "andreyknvl@google.com"
	<andreyknvl@google.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: question for cma alloc fail issue
Thread-Topic: question for cma alloc fail issue
Thread-Index: AdTvhcYnK7CyihaiRpazlRl1Ut2i9Q==
Date: Wed, 10 Apr 2019 10:48:26 +0000
Message-ID:
 <VE1PR04MB64290E25D6BAB7E702D08A54982E0@VE1PR04MB6429.eurprd04.prod.outlook.com>
Accept-Language: zh-CN, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jared.hu@nxp.com; 
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6bc0d664-7704-4ad4-36eb-08d6bda20fa0
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:VE1PR04MB6528;
x-ms-traffictypediagnostic: VE1PR04MB6528:
x-microsoft-antispam-prvs:
 <VE1PR04MB6528D33331B781FEA95A1C11982E0@VE1PR04MB6528.eurprd04.prod.outlook.com>
x-forefront-prvs: 00032065B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(376002)(396003)(39860400002)(366004)(346002)(53754006)(189003)(199004)(110136005)(186003)(81156014)(8676002)(66066001)(8936002)(2201001)(68736007)(81166006)(25786009)(508600001)(86362001)(6506007)(102836004)(71190400001)(71200400001)(6436002)(6116002)(3846002)(33656002)(486006)(476003)(74316002)(2906002)(55016002)(44832011)(9686003)(53936002)(7736002)(26005)(14454004)(305945005)(2501003)(4326008)(7696005)(105586002)(5660300002)(97736004)(99286004)(106356001)(316002)(52536014)(256004);DIR:OUT;SFP:1101;SCL:1;SRVR:VE1PR04MB6528;H:VE1PR04MB6429.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 J6+V/PEqek2e5yNGEMoV8EfmgBVZYpP8pJiDrlp5tR+oSrm2FonWDqUmMadretXpy4TEmhKvuHvF+TQ7Gw/ecuKf33CuOlM0HQNkdXI/04Xeytg/Re9A5FWaGvKjg2xxVkWgQvYuJ2NhWio32gX1ZUzglS3thDE0XHzfm7IFnRHCeebNVAaqS4fm4nj4S3lgN1GbImpJbPDaYyB6zDCDmzW0vxt8byesq8IrWIAJPaoFG7FdcqD2RJ3suOPhxkE5/CyrDGLfXMDvxN2EQX5QUuRjgmEbVssMNX1pMxvYZzX7Ic4rIA0yY5w5HQOhcBTTv9eb22754TqC0dlWw0ezQEmJo1EXG5eauwP3LdQqebjLOYrQ558mfNYKGt7LmlWznVDf5cKCTF8wKpTSGCxUFAexMTp6kuvatvtsh0z/eXQ=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6bc0d664-7704-4ad4-36eb-08d6bda20fa0
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Apr 2019 10:48:26.2532
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VE1PR04MB6528
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQWxso6wNCg0KV2UgYXJlIGZhY2luZyBhIGNtYSBtZW1vcnkgYWxsb2MgaXNzdWUgb24gbGlu
dXggNC4xNC45OCBhbmQgbG93ZXIgdmVyc2lvbi4NCg0KSW4gb3VyIHBsYXRmb3JtIGlteDhtLCB3
ZSB1c2luZyBjbWEgdG8gYWxsb2NhdGUgbGFyZ2UgY29udGludW91cyBtZW1vcnkNCmJsb2NrIHRv
IHN1cHBvcnQgemVyby1jb3B5IGJldHdlZW4gdmlkZW8gZGVjb2RlIGFuZCBkaXNwbGF5IHN1Yi1z
eXN0ZW0uDQpCdXQgYWZ0ZXIgbG9uZyB0aW1lIGxvb3AgdmlkZW8gcGxheWJhY2sgdGVzdCwgc3lz
dGVtIHdpbGwgcmVwb3J0IGFsbG9jDQpjbWEgZmFpbCByZXQ9YnVzeS4gV2UgdGFrZSBhIGRlZXAg
bG9vayBpbnRvIGNtYS5jIGZvdW5kIHRoZXJlIGFyZSBzdGlsbA0Kc29tZSBiaWcgZnJlZSBhcmVh
cyBpbiBjbWEtPmJpdG1hcCB0aGF0IG1heWJlIGNhbiBhbGxvYyAzNTk1IHBhZ2VzLg0KDQpIZXJl
IGFyZSBzb21lIHF1ZXN0aW9uczoNCjEuIGluIF9fYWxsb2NfY29udGlnX21pZ3JhdGVfcmFuZ2Uo
KSBjYy0+bnJfbWlncmF0ZXBhZ2VzIGFsd2F5cyBiZWVuIDANCkRvZXMgY2MtPm5yX21pZ3JhdGVw
YWdlcyA9IDAgbWVhbnMgdGhlcmUgaXMgbm8gcGFnZSBjYW4gYmUgcmVjbGFpbWVkIG9yDQptaWdy
YXRlZD8gV2hpY2gga2luZCBvZiBwYWdlcyB0aGF0IGNhbm5vdCBiZWVuIHJlY2xhaW1lZC4NCg0K
Mi4gVGhlIHBhZ2VzIHRoYXQgYXJlIGZyZWUgaW4gY21hLT5iaXRtYXAgc2VlbSBub3QgZnJlZSBp
biBCdWRkeSBzeXN0ZW0/DQpQYWdlQnVkZHkoKSB0ZXN0IGNhbiBhbHNvIHJldHVybiBmYWxzZSBl
dmVuIGlmIHRoZSBwYWdlIGlzIGluIHRoZSBmcmVlIGxpc3QgaW4gY21hIGJpdG1hcA0KSSB0ZXN0
IHRoZSBmYWlsIHBhZ2Ugd2l0aCBwYWdlX2lzX2ZpbGVfY2FjaGUocGFnZSkgd2hpY2ggcmV0dXJu
IDAuDQpjb21tZW50IHNob3c6IDAgaWYgQHBhZ2UgaXMgYW5vbnltb3VzLCB0bXBmcyBvciBvdGhl
cndpc2UgcmFtIG9yIHN3YXAgYmFja2VkLg0KV2hhdCBkb2VzIHN3YXAgYmFja2VkIG1lYW4/IFdo
aWNoIG9uZSBtYXliZSBvY2N1cHkgdGhlc2UgcGFnZXM/DQoNCkNvdWxkIHNvbWVvbmUgZ2l2ZSBt
ZSBhIGZhdm9yIHRvIGRlYnVnIHRoaXMgaXNzdWU/DQoNCkJlc3QgcmVnYXJlZHMNCkphcmVkIEh1
DQo=

