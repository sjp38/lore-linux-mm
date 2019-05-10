Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A186C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 010D4217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="gru1zGAF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 010D4217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931C76B0003; Fri, 10 May 2019 15:53:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BBB06B0005; Fri, 10 May 2019 15:53:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75B056B0006; Fri, 10 May 2019 15:53:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547866B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:53:24 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y15so5010796iod.10
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=dESb7FNYik5HDj5wOehfO9ebygS6wUs4Qt1amsabA/o=;
        b=Iu/jeZrf274OxaO4svwm1+7SozA+S6Q4HAWfH2pHzdC12zdJo6J6+7UvDY0HO6/rV9
         ug+UblGNaFg6pyL0J+YIil4JUSg4flPfMWlQMZhnjiTo3tbR2Mnz+pIhtZ3YAX1js7V8
         UyzTLnbmqZgx4zxDIIgaP3PqsmEBLqw/UJxEfDp5XRBgf2g7QFjaPHYNl/fkt5C4Snqd
         CBBxzMxdXdENwxLm/IU+gdFY0rYLCzNuYwn5AkhLLSWhtVHGTORHg+LWx8fXu7ytEZFz
         tzqiNF68q8nTGujgUTC37tmvA753AdBjx2wTfRzCTogGPzvDnPe2gz2DLX6+949riWlG
         2s2A==
X-Gm-Message-State: APjAAAXV3WIUaRI7HlM6IY45kWo615Ii0iZIMjXo8jWFS/9QWJhG3lzf
	LyhzotxHTUraAuRDfKD5jZqFEpsXa1fLf+pPdzDyNp7wiquWypVBCHUak/R04jhKLZ8mrWrVEOO
	SXIEJp6ShkKA63aRr44rqNsQrVdR0gacn3+5u3LZCyaWqgWgyBHwO/52SkE7Bkck=
X-Received: by 2002:a24:520f:: with SMTP id d15mr7187306itb.78.1557518004058;
        Fri, 10 May 2019 12:53:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+iYeSZtVSbjn3qIDl0hrZKBF8kyCXM8ZBMyePhXR/o2qHkHSyotxd39xkn11chCtG7mNE
X-Received: by 2002:a24:520f:: with SMTP id d15mr7187265itb.78.1557518003307;
        Fri, 10 May 2019 12:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557518003; cv=none;
        d=google.com; s=arc-20160816;
        b=S6ZP8IpVrsrYETHU/d+/va6WpjrPjI8qiZGbQThNCjc14qwkef+qov4NVVtQ7TgHLP
         hpIwzzxJ4EKU7qiAZTM3H+Y+y3vzzA+++/VwxZGILUSMqbTlnm/raj+Hhr/m8jsjUKbz
         jqCNjmjeBJItrCj8EeF+pMLo7amYbi8/T+Dr0thOvNf7qlSZ4ILLR7K7qY163E0DQog2
         JB1f8onzPBY6hlvVzcwjPUui542W18ccA630i/xr8T560OMvpD3JfSmG8zQYL4B2pMFh
         8xwDEwBMMgHgYo8fPuhi0anLeBOIK0couTfjxkvcGJej4woWF/lpO3+VvPZqC8sFWQqP
         jA+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=dESb7FNYik5HDj5wOehfO9ebygS6wUs4Qt1amsabA/o=;
        b=aYe59G133j8tuj+YptUylaJP0tl3maHWGADuExiXmSbMwN4Ivh94kFSbM05cBXZb4V
         OG/BomX+FdEGLtYS3S0JCnc/WO7IUm5CwolrVhGqgks3T15ZyreGeYH5OxCFXoGimwq5
         Krwhixm6G/f8x8QVLn359kzcnN7e50CNgiSV0shinnr+KZe2EjEiAzVKezgFJ4fmq5VB
         GtLaJToeHpI1vkhEmlKCZKjSCS/ds6AzNhVidWFjHV3L3tc/Ld5cAeHb3E+8eLpSejtv
         L0PvcPp07pRc0568VKAgwt60VPkQJ8HTeuSVFyjWvDpO57zHkLF2Vvt3RkDI2DpdiPmk
         BxCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=gru1zGAF;
       spf=neutral (google.com: 40.107.68.85 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680085.outbound.protection.outlook.com. [40.107.68.85])
        by mx.google.com with ESMTPS id e193si4293234itc.85.2019.05.10.12.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 12:53:23 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.85 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.68.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=gru1zGAF;
       spf=neutral (google.com: 40.107.68.85 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dESb7FNYik5HDj5wOehfO9ebygS6wUs4Qt1amsabA/o=;
 b=gru1zGAFwPmzZjLJjG5OXoBinK2p6d4fZrzZ8aaX4Ah3V2cvEbUxz+meYgRkVHl1Hqs97nDK1rEkJUlvCEmUB8VJPDr4wm3vDOyF7Hn3WEMILcpACpPjYqbsC8EU9NrCpomdlypXNEDroThGY7g12GLXJofCLWJLEDTEZprBzCQ=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3447.namprd12.prod.outlook.com (20.178.196.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.21; Fri, 10 May 2019 19:53:21 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7%4]) with mapi id 15.20.1856.016; Fri, 10 May 2019
 19:53:21 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
CC: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: [PATCH 0/2] Two bug-fixes for HMM
Thread-Topic: [PATCH 0/2] Two bug-fixes for HMM
Thread-Index: AQHVB2oFymYy9x0alkiQIwO1y+NKlw==
Date: Fri, 10 May 2019 19:53:21 +0000
Message-ID: <20190510195258.9930-1-Felix.Kuehling@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
x-mailer: git-send-email 2.17.1
x-clientproxiedby: YTXPR0101CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::34) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0810f5a6-c9f8-4ab5-48b8-08d6d58127a7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR12MB3447;
x-ms-traffictypediagnostic: BYAPR12MB3447:
x-microsoft-antispam-prvs:
 <BYAPR12MB34471C6608D3552CA8D78CF6920C0@BYAPR12MB3447.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0033AAD26D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(366004)(39860400002)(346002)(376002)(189003)(199004)(110136005)(102836004)(2501003)(6512007)(86362001)(6436002)(2906002)(52116002)(2201001)(6506007)(386003)(99286004)(6486002)(66066001)(3846002)(478600001)(6116002)(14454004)(72206003)(316002)(305945005)(53936002)(66476007)(66556008)(186003)(8936002)(81166006)(7736002)(486006)(4326008)(64756008)(66446008)(256004)(25786009)(26005)(66946007)(73956011)(476003)(2616005)(71200400001)(71190400001)(8676002)(36756003)(81156014)(5660300002)(50226002)(68736007)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3447;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 jxKJYtCcqhU2oO9qiZ7HOhSw2wTea3S/f07ptlsy6X9q5M9wCb31U3ZcBPK12UgUcNRhI6P8qQSfV7fdcf0tq3zy9b832Qvhu8wfqjSMV97y5qpCSny1QBc8Ks2XPc2H3nMa0gpew76vfosw/ayMPu4mon84nVkhv9o10F6IXQAoKYCs77FOhUOFjYfH7DrSDV3QhWGS/gh2Bkhn0HYrF6X6TiGAhqj1TWWvXLnDqtDvk154aCSZ47m8P1A2cJvVm+1coGWXLOs5+a0Ox/4Sj8lMZxsTahQHUojlnK8G/wjURIIorisCI+oOln4NJxESr+Sxqp3FAmRvFiUNtBX0b5jd/1wlemsiIJSmsWdf5EPL9mDe+pbslQb+WUP7g9zf5vV4bXhQ/oqq8Guiv9bD/HXu3i/6ykOI1/sY+Afequo=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0810f5a6-c9f8-4ab5-48b8-08d6d58127a7
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 May 2019 19:53:21.6748
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3447
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VGhlc2UgcHJvYmxlbXMgd2VyZSBmb3VuZCBpbiBBTUQtaW50ZXJuYWwgdGVzdGluZyBhcyB3ZSdy
ZSB3b3JraW5nIG9uDQphZG9wdGluZyBITU0uIFRoZXkgYXJlIHJlYmFzZWQgYWdhaW5zdCBnbGlz
c2UvaG1tLTUuMi12My4gV2UnZCBsaWtlIHRvIGdldA0KdGhlbSBhcHBsaWVkIHRvIGEgbWFpbmxp
bmUgTGludXgga2VybmVsIGFzIHdlbGwgYXMgZHJtLW5leHQgYW5kDQphbWQtc3RhZ2luZy1kcm0t
bmV4dCBzb29uZXIgcmF0aGVyIHRoYW4gbGF0ZXIuDQoNCkN1cnJlbnRseSB0aGUgSE1NIGluIGFt
ZC1zdGFnaW5nLWRybS1uZXh0IGlzIHF1aXRlIGZhciBiZWhpbmQgaG1tLTUuMi12MywNCmJ1dCB0
aGUgZHJpdmVyIGNoYW5nZXMgZm9yIEhNTSBhcmUgZXhwZWN0ZWQgdG8gbGFuZCBpbiA1LjIgYW5k
IHdpbGwgbmVlZCB0bw0KYmUgcmViYXNlZCBvbiB0aG9zZSBITU0gY2hhbmdlcy4NCg0KSSdkIGxp
a2UgdG8gd29yayBvdXQgYSBmbG93IGJldHdlZW4gSmVyb21lLCBEYXZlLCBBbGV4IGFuZCBteXNl
bGYgdGhhdA0KYWxsb3dzIHVzIHRvIHRlc3QgdGhlIGxhdGVzdCB2ZXJzaW9uIG9mIEhNTSBvbiBh
bWQtc3RhZ2luZy1kcm0tbmV4dCBzbw0KdGhhdCBpZGVhbGx5IGV2ZXJ5dGhpbmcgY29tZXMgdG9n
ZXRoZXIgaW4gbWFzdGVyIHdpdGhvdXQgbXVjaCBuZWVkIGZvcg0KcmViYXNpbmcgYW5kIHJldGVz
dGluZy4NCg0KTWF5YmUgaGF2aW5nIEplcm9tZSdzIGxhdGVzdCBITU0gY2hhbmdlcyBpbiBkcm0t
bmV4dC4gSG93ZXZlciwgdGhhdCBtYXkNCmNyZWF0ZSBkZXBlbmRlbmNpZXMgd2hlcmUgSmVyb21l
IGFuZCBEYXZlIG5lZWQgdG8gY29vcmRpbmF0ZSB0aGVpciBwdWxsLQ0KcmVxdWVzdHMgZm9yIG1h
c3Rlci4NCg0KRmVsaXggS3VlaGxpbmcgKDEpOg0KICBtbS9obW06IE9ubHkgc2V0IEZBVUxUX0ZM
QUdfQUxMT1dfUkVUUlkgZm9yIG5vbi1ibG9ja2luZw0KDQpQaGlsaXAgWWFuZyAoMSk6DQogIG1t
L2htbTogc3VwcG9ydCBhdXRvbWF0aWMgTlVNQSBiYWxhbmNpbmcNCg0KIG1tL2htbS5jIHwgNCAr
Ky0tDQogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCg0K
LS0gDQoyLjE3LjENCg0K

