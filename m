Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6354FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:31:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A149E2075E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:31:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="xa9jQbw/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A149E2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 167476B0005; Tue, 19 Mar 2019 04:31:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13DDA6B0006; Tue, 19 Mar 2019 04:31:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C5E6B0007; Tue, 19 Mar 2019 04:31:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1D986B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:31:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d128so21696604pgc.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 01:31:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :mime-version;
        bh=QTV7+qgUvy8IkuuMRVmBLevG6PKV21+87YUqfbPVytY=;
        b=QYb+WZs8n+r6vIH7KTvt76nii0oHQ1rO4DRKv/CuxRU0+xYZkB2XIeS0enBfwGbDUw
         Ff0tT3AhRfA86Y1pxiuYLD6B1lBSaCMiwdEHbFZs6xLOJj9w3tUigj/VDzLO+Eue/Bhb
         sWstYH6z4hYjJkcBMbH0OdGZb/QQBEdhUsqf5NO0K+SYrA47cyFouDec5F4KtcBR6x3R
         B0kDt1G9xw3xzkt41+w+hCosmuoTKYDH2odQQkyYe1qD0omknMnChWGM+DXsYXvreuIu
         Q4J+pcUaCaYqzMjopdOUQg5YdBbKRjPTXB0aD8udEMHFVgGkGG33If8AUJUC8MXAfC42
         eYUQ==
X-Gm-Message-State: APjAAAXJnnLflcUludujghljfZVkpwLchBocaxpmDpRppYp5cJWhD/if
	gnJQjsaFqX6C1e5Afb+IX3ZMxkgz6XUfO3FeCI/ka6CVg3vPPtrtoW2XxUz1wS9v3Ybqs9lJ70R
	siobLDcciczcBU8MXmfFad/3ZFWvdr7fuxNRfUxLJcirnM9WxQqWRBIeleRFzVriduA==
X-Received: by 2002:a17:902:234b:: with SMTP id n11mr813780plg.89.1552984304105;
        Tue, 19 Mar 2019 01:31:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZR6l2uo9OKzld3Mt8hI1PEwsxs+gtSguprjPW8OuMqO1SamvltiHc3VIpCXOR2an3RW6k
X-Received: by 2002:a17:902:234b:: with SMTP id n11mr813700plg.89.1552984303033;
        Tue, 19 Mar 2019 01:31:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552984303; cv=none;
        d=google.com; s=arc-20160816;
        b=Ij/dL+EXjmGLlsiy5wywhjQtpj+njICFh437LkLLj1FG3+S8P6jtdFDarpFD0ajOVX
         rASTefCbYsLESpeJZEnUqtlll2+mc7XHK9lWOodU+W9lcepO0o5jhH4UIM7fayvESR1F
         LtSiTt2NlzNJnxGbt8aqFEgcaUsn4j4Xno7SMjLi74esgcJ0FtmWqoaT2IDCtbd2CpzG
         xFqjQgRmAdAclVAJhajc/TBNuHGmc/IFTKosj36MeHvmtrD0AZsUpxOOrIoxz2gYo4nC
         mseeTnVPK62KVGZVo50vLrkwQx17Tqvkd7XQNa3H8SHbBXUpuKA2gdKnZuKBul9iVgLB
         tS1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:message-id:date
         :thread-index:thread-topic:subject:to:from:dkim-signature;
        bh=QTV7+qgUvy8IkuuMRVmBLevG6PKV21+87YUqfbPVytY=;
        b=JUYVSQo3VM0Nt44f+cQDd7Luwk1+NYoh0wMLnP5Iy1ASpQWxEqM76oqpGH2kYjdSQH
         kci9FLeygK0Oz/dqopNKiHcbon0s92D6NzYy/YV6UwQy4Qxj7DFNoRyh21oDCncX4i7+
         6qnfPJxrVNAEMtJB39qRDKId4QSsmgqFXa9ZBBApXWH91e3mg2tQSL6NGtMeSQ0PzRPY
         yiQo7NnMX1qyu4x0v7CmRzbBbYFyYc+Yk4MoY3y0dwYF4UqDGV3TOk+VGqT87a6poFem
         sLatjwuLVES3nK0EZLbTupHjzT2T9fYla+4DcRNVCyrzQBh7PkM0pmZl3bssKT1Ebnqs
         iphA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b="xa9jQbw/";
       spf=pass (google.com: domain of jared.hu@nxp.com designates 40.107.15.50 as permitted sender) smtp.mailfrom=jared.hu@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150050.outbound.protection.outlook.com. [40.107.15.50])
        by mx.google.com with ESMTPS id d16si11384375pfn.42.2019.03.19.01.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 01:31:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jared.hu@nxp.com designates 40.107.15.50 as permitted sender) client-ip=40.107.15.50;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b="xa9jQbw/";
       spf=pass (google.com: domain of jared.hu@nxp.com designates 40.107.15.50 as permitted sender) smtp.mailfrom=jared.hu@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QTV7+qgUvy8IkuuMRVmBLevG6PKV21+87YUqfbPVytY=;
 b=xa9jQbw/UlMC4OGnshsmSz/tl/AcUmdv57W4Bk9KGQW3uyQWNFsYZ9Ry5zQ4rUsOT8B/8fbcwRqoGebrF3k/AXGt9MQcAnfXWafRrvPdCi69wkkLBFweK3q31SYt4wzzGZL6aO5jAX5lsqKqgDR5xefesrfABL70muz+wH2AeHk=
Received: from DB7PR04MB5580.eurprd04.prod.outlook.com (20.178.106.161) by
 DB7PR04MB4202.eurprd04.prod.outlook.com (52.135.131.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Tue, 19 Mar 2019 08:31:38 +0000
Received: from DB7PR04MB5580.eurprd04.prod.outlook.com
 ([fe80::4083:f0ab:c01c:529]) by DB7PR04MB5580.eurprd04.prod.outlook.com
 ([fe80::4083:f0ab:c01c:529%4]) with mapi id 15.20.1709.015; Tue, 19 Mar 2019
 08:31:38 +0000
From: Jared Hu <jared.hu@nxp.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: question for cma alloc fail issue
Thread-Topic: question for cma alloc fail issue
Thread-Index: AdTeArZhk2kPTlowTUOZN6xkF+t8tg==
Date: Tue, 19 Mar 2019 08:31:37 +0000
Message-ID:
 <DB7PR04MB55808491855429C48CE8CCF298400@DB7PR04MB5580.eurprd04.prod.outlook.com>
Accept-Language: zh-CN, en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jared.hu@nxp.com; 
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 468988c2-1ea4-4d84-54f4-08d6ac454e04
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(49563074)(7193020);SRVR:DB7PR04MB4202;
x-ms-traffictypediagnostic: DB7PR04MB4202:
x-microsoft-antispam-prvs:
 <DB7PR04MB420254F43D369FF23B4A4A1D98400@DB7PR04MB4202.eurprd04.prod.outlook.com>
x-forefront-prvs: 0981815F2F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(366004)(396003)(39860400002)(136003)(53754006)(199004)(189003)(790700001)(71190400001)(52536014)(68736007)(256004)(86362001)(81156014)(81166006)(2501003)(53936002)(71200400001)(6116002)(3846002)(25786009)(74316002)(7736002)(6916009)(8676002)(7696005)(478600001)(5660300002)(14454004)(99286004)(6506007)(316002)(33656002)(44832011)(97736004)(102836004)(8936002)(6306002)(733005)(6436002)(105586002)(26005)(5640700003)(9686003)(476003)(54556002)(55016002)(106356001)(2906002)(54896002)(2351001)(186003)(486006)(66066001)(99936001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR04MB4202;H:DB7PR04MB5580.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 fDqHhJrhLjFYsLqs/iSPzA/65hKRAMxDt00/NQbWIEdRtXUtgQDbfcqulniPyD7pMEj2Up1cYre9IgJ9bLGoU0SUHI8bbtz0gcGXDc0rG2IAMqxK+ToPqmV1jtzSFxkTBQNxqqK8gWmSE28BQGbvczDPPc8Sy2IbqPMVFS+WywL/0F7Bep5i5LYS79/YJO7tYo7J/R622fFxQshkUHD9C//esiXyMga/qo+oGpoljWjJAU2ahJCZqKIh3UTMgcywYR8SuurNgUsugBSOnQynHm8YMJwe02LK2QkXuD5gvDdYK9svHUglGPGDqpodNTbvq56PxffFFQ975G3UKLheZxauoUQiyyLyd2dNu45AuijsxLibxNWpctEaReSD3z5F//5H3EBNJfn+9sIU6/64Cwv7ouVc5Eaga0dYn48pxVQ=
Content-Type: multipart/related;
	boundary="_005_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_";
	type="multipart/alternative"
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 468988c2-1ea4-4d84-54f4-08d6ac454e04
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Mar 2019 08:31:37.9980
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR04MB4202
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_005_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_
Content-Type: multipart/alternative;
	boundary="_000_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_"

--_000_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64

SGkgQWxso6wNCg0KV2UgYXJlIGZhY2luZyBhIGNtYSBtZW1vcnkgYWxsb2MgaXNzdWUuIEluIG91
ciBwbGF0Zm9ybSBpbXg4bSwgd2UgdXNpbmcgY21hIHRvIGFsbG9jYXRlIGxhcmdlIGNvbnRpbnVv
dXMgbWVtb3J5IGJsb2NrIHRvIHN1cHBvcnQgemVyby1jb3B5IGJldHdlZW4gdmlkZW8gZGVjb2Rl
IGFuZCBkaXNwbGF5IHN1Yi1zeXN0ZW0uIEJ1dCBhZnRlciBsb25nIHRpbWUgbG9vcCB2aWRlbyBw
bGF5YmFjayB0ZXN0LCBzeXN0ZW0gd2lsbCByZXBvcnQgYWxsb2MgY21hIGZhaWwgcmV0PWJ1c3ku
DQpXZSB0YWtlIGEgZGVlcCBsb29rIGludG8gY21hLmMgZm91bmQgdGhlcmUgYXJlIHN0aWxsIHNv
bWUgYmlnIGZyZWUgYXJlYXMgaW4gY21hLT5iaXRtYXAgdGhhdCBtYXliZSBjYW4gbWVldCB0aGUg
cmVxdWlyZWQgMzU5NSBwYWdlcy4NCg0KVGhlIHF1ZXN0aW9uIGlzIHBhZ2VzIHRoYXQgYXJlIGZy
ZWUgaW4gY21hLT5iaXRtYXAgc2VlbSBub3QgZnJlZSBpbiBCdWRkeSBzeXN0ZW0/IFRoZW4gd2hp
Y2ggb25lIG1heWJlIG9jY3VweSB0aGVzZSBwYWdlcz8gV2Ugc3VzcGVjdCB0aGVzZSBwYWdlcyBh
cmUgZmlsZSBjYWNoZSBiZWNhdXNlIGlmIGRyb3AgYWxsIGNhY2hlLCB0aGVuIHRoaXMgaXNzdWUg
d2lsbCBub3QgaGFwcGVuLg0KDQpXZSBoYXZlIHR3byBjbHVlcyBhcyBiZWxvdzoNCg0KMS4gICAg
IFBhZ2VCdWRkeSB0ZXN0IGZhaWwgZXZlbiBpZiB0aGUgcGFnZSBpcyAwIGluIGJpdG1hcA0KRWcs
IHBhZ2UgMTE3NzYwIGxvY2F0ZWQgaW4gMTAyNzRAMTE1Njc4LCBQYWdlQnVkZHkoKSB3aWxsIHJl
dHVybiBmYWxzZSBhcyBiZWxvdyBsb2cgc2hvdzoNCm11bHRpcXVldWUxNTQyOi04NDQ0ICBbMDAz
XSBkLi4xIDIyNTIzMy42MjQwNTc6IHRlc3RfcGFnZXNfaXNvbGF0ZWQ6IHBmbiAweDYwYzAwIHBh
Z2VCdWRkeSByZXR1cm4gZmFsc2UNCm11bHRpcXVldWUxNTQyOi04NDQ0ICBbMDAzXSBkLi4xIDIy
NTIzMy42MjQwNTg6IHRlc3RfcGFnZXNfaXNvbGF0ZWQ6IHJldHVybiBwZm49MHg2MGMwMA0KDQpi
ZWxvdyBpcyB0aGUgY21hIGFyZWEgYml0bWFwIHN1bW1hcnkgd2hlbiBlcnJvciBvY2N1cnMsIHRo
ZXJlIGFyZSBzdGlsbCBzb21lIGJpZyBhcmVhcyBpbiB5ZWxsb3cgbWFya3Mgd2hpY2ggY2FuIGhv
bGQgMzU5NSBwYWdlczoNCmNtYV9hbGxvYzogYWxsb2MgZmFpbGVkLCByZXEtc2l6ZTogMzU5NSBw
YWdlcywgcmV0OiAtMTYNCmNtYV9hbGxvYzogbnVtYmVyIG9mIGF2YWlsYWJsZSBwYWdlczoNCjRA
ODQyMCsxOEA4NDMwKzgwQDg4ODArMTI5QDc0NjIzKzEwMjNANzg4NDkrMzRAODI5MTArNjE3OEA4
NTk4MiszNEA5NTE5OCs4MjI2QDk4MjcwKzM0QDEwOTUzNCszNEAxMTI2MDYNCisxMDI3NEAxMTU2
NzgrMTA1OEAxMjg5OTArMzRAMTMzMDg2KzM0QDEzNjE1OCsyMDgyQDEzOTIzMCs5MjUwQDE0NDM1
MCszNEAxNTY2MzgrMTU3MEAxNTk3MTArOTc2MkAxNjQzMTgNCisyNTQ5QDE3NzY3NSsxOTk1N0Ax
ODM4MTkrNTYyMUAyMDczNzErMTI3ODlAMjE2NTg3KzI0NUAyMzI5NzErMjQ1QDIzNjgxMSsyNDVA
MjQwNjUxKzEyNjlAMjQ0NDkxID0+IDkyODEyIGZyZWUgb2YgMjQ1NzYwIHRvdGFsIHBhZ2VzDQoN
Cg0KMi4gICAgIE1lYW53aGlsZSBpbiBkZWJ1ZiBmcyB0aGUgZnJlZSBzaXplIGlzIG5vdCBhbGln
bmVkIHdpdGggdGhhdCBtZW1pbmZvIHJlcG9ydGVkOg0KSW4gZGVidWYgZnM6IDI0NTc2MC0xMzg1
Njg9MTA3MTkyKHBhZ2VzKSA9IDQyODc2OCBrQg0KSW4gL3Byb2MvbWVtaW5mbzogMjk2OTc2IGtC
DQoNCnJvb3RAaW14OG1xZXZrOn4jIGNhdCAvcHJvYy9tZW1pbmZvIHwgZ3JlcCBDbWEqDQpDbWFU
b3RhbDogICAgICAgICA5ODMwNDAga0INCkNtYUZyZWU6ICAgICAgICAgIDI5Njk3NiBrQg0Kcm9v
dEBpbXg4bXFldms6fiMgY2F0IC9zeXMva2VybmVsL2RlYnVnL2NtYS9jbWEtbGludXgsY21hL2Nv
dW50DQoyNDU3NjANCnJvb3RAaW14OG1xZXZrOn4jIGNhdCAvc3lzL2tlcm5lbC9kZWJ1Zy9jbWEv
Y21hLWxpbnV4LGNtYS91c2VkDQoxMzg1NjgNCg0KQ291bGQgc29tZW9uZSBnaXZlIG1lIGEgZmF2
b3IgdG8gZGVidWcgdGhpcyBpc3N1ZT8NCg0KQmVzdCByZWdhcmRzDQpKYXJlZCBIdQ0KTW9iaWxl
OiA4Ni0xNTk2MjEwMDQ4Mg0KW2NpZDppbWFnZTAwMi5wbmdAMDFEMTMxRDcuQUJDMzA3MzBdDQo=

--_000_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_
Content-Type: text/html; charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dgb2312">
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:=CB=CE=CC=E5;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:=B5=C8=CF=DF;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"\@=B5=C8=CF=DF";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:"\@=CB=CE=CC=E5";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:=B5=C8=CF=DF;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	text-indent:21.0pt;
	font-size:10.5pt;
	font-family:=B5=C8=CF=DF;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:=B5=C8=CF=DF;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:=B5=C8=CF=DF;}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:688600075;
	mso-list-type:hybrid;
	mso-list-template-ids:-645334508 -786033108 67698713 67698715 67698703 676=
98713 67698715 67698703 67698713 67698715;}
@list l0:level1
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l0:level2
	{mso-level-number-format:alpha-lower;
	mso-level-text:"%2\)";
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:42.0pt;
	text-indent:-21.0pt;}
@list l0:level3
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	margin-left:63.0pt;
	text-indent:-21.0pt;}
@list l0:level4
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:84.0pt;
	text-indent:-21.0pt;}
@list l0:level5
	{mso-level-number-format:alpha-lower;
	mso-level-text:"%5\)";
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:105.0pt;
	text-indent:-21.0pt;}
@list l0:level6
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	margin-left:126.0pt;
	text-indent:-21.0pt;}
@list l0:level7
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:147.0pt;
	text-indent:-21.0pt;}
@list l0:level8
	{mso-level-number-format:alpha-lower;
	mso-level-text:"%8\)";
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:168.0pt;
	text-indent:-21.0pt;}
@list l0:level9
	{mso-level-number-format:roman-lower;
	mso-level-tab-stop:none;
	mso-level-number-position:right;
	margin-left:189.0pt;
	text-indent:-21.0pt;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"ZH-CN" link=3D"#0563C1" vlink=3D"#954F72" style=3D"text-justi=
fy-trim:punctuation">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Hi All</span>=A3=AC<span lang=
=3D"EN-US"><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">We are facing a cma memory allo=
c issue. In our platform imx8m, we using cma to allocate large continuous m=
emory block to support zero-copy between video decode and display sub-syste=
m. But after long time loop video playback
 test, system will report alloc cma fail ret=3Dbusy.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">We take a deep look into cma.c =
found there are still some big free areas in cma-&gt;bitmap that maybe can =
meet the required 3595 pages.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">The question is pages that are =
free in cma-&gt;bitmap seem not free in Buddy system? Then which one maybe =
occupy these pages? We suspect these pages are file cache because if drop a=
ll cache, then this issue will not happen.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">We have two clues as below:<o:p=
></o:p></span></p>
<p class=3D"MsoListParagraph" style=3D"margin-left:18.0pt;text-indent:-18.0=
pt;mso-list:l0 level1 lfo1">
<![if !supportLists]><b><span lang=3D"EN-US"><span style=3D"mso-list:Ignore=
">1.<span style=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbs=
p;&nbsp;
</span></span></span></b><![endif]><b><u><span lang=3D"EN-US">PageBuddy tes=
t fail even if the page is 0 in bitmap<o:p></o:p></span></u></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Eg, page 117760 located in <spa=
n style=3D"background:yellow;mso-highlight:yellow">
10274@115678</span>, PageBuddy() will return false as below log show:<o:p><=
/o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">multiqueue1542:-8444&nbsp; [003=
] d..1 225233.624057: test_pages_isolated: pfn 0x60c00 pageBuddy return fal=
se<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">multiqueue1542:-8444&nbsp; [003=
] d..1 225233.624058: test_pages_isolated: return pfn=3D0x60c00<o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">below is the cma area bitmap su=
mmary when error occurs, there are still some big areas in yellow marks whi=
ch can hold 3595 pages:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">cma_alloc: alloc failed, req-si=
ze: 3595 pages, ret: -16<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">cma_alloc: number of available =
pages: <o:p>
</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">4@8420&#43;18@8430&#43;80@8880&=
#43;129@74623&#43;1023@78849&#43;34@82910&#43;6178@85982&#43;34@95198&#43;<=
span style=3D"background:yellow;mso-highlight:yellow">8226@98270</span>&#43=
;34@109534&#43;34@112606<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;<span style=3D"background:=
yellow;mso-highlight:yellow">10274@115678</span>&#43;1058@128990&#43;34@133=
086&#43;34@136158&#43;2082@139230&#43;<span style=3D"background:yellow;mso-=
highlight:yellow">9250@144350</span>&#43;34@156638&#43;1570@159710&#43;<spa=
n style=3D"background:yellow;mso-highlight:yellow">9762@164318</span><o:p><=
/o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">&#43;2549@177675&#43;<span styl=
e=3D"background:yellow;mso-highlight:yellow">19957@183819</span>&#43;<span =
style=3D"background:yellow;mso-highlight:yellow">5621@207371</span>&#43;<sp=
an style=3D"background:yellow;mso-highlight:yellow">12789@216587</span>&#43=
;245@232971&#43;245@236811&#43;245@240651&#43;1269@244491
 =3D&gt; 92812 free of 245760 total pages<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoListParagraph" style=3D"margin-left:18.0pt;text-indent:-18.0=
pt;mso-list:l0 level1 lfo1">
<![if !supportLists]><b><span lang=3D"EN-US"><span style=3D"mso-list:Ignore=
">2.<span style=3D"font:7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbs=
p;&nbsp;
</span></span></span></b><![endif]><b><u><span lang=3D"EN-US">Meanwhile in =
debuf fs the free size is not aligned with that meminfo reported:<o:p></o:p=
></span></u></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">In debuf fs: 245760-138568=3D10=
7192(pages) =3D
<span style=3D"background:yellow;mso-highlight:yellow">428768 kB</span><o:p=
></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">In /proc/meminfo: <span style=
=3D"background:yellow;mso-highlight:yellow">
296976 kB</span><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">root@imx8mqevk:~# cat /proc/mem=
info | grep Cma*&nbsp;
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">CmaTotal:&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; 983040 kB<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">CmaFree:&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 296976 kB<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">root@imx8mqevk:~# cat /sys/kern=
el/debug/cma/cma-linux,cma/count
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">245760<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">root@imx8mqevk:~# cat /sys/kern=
el/debug/cma/cma-linux,cma/used<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">138568<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Could someone give me a favor t=
o debug this issue?<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"line-height:150%"><span lang=3D"EN-US" styl=
e=3D"font-size:12.0pt;line-height:150%"><img width=3D"288" height=3D"2" sty=
le=3D"width:3.0in;height:.0208in" id=3D"_x0000_i1025" src=3D"cid:image001.p=
ng@01D4DE64.24D9DAE0" alt=3D"cid:image001.png@01D131D7.ABC30730"></span><b>=
<u><span lang=3D"EN-US" style=3D"font-size:12.0pt;line-height:150%"><o:p></=
o:p></span></u></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Best regards<o:p></o:p></span><=
/p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">Jared Hu<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-family:&quot;Aria=
l&quot;,sans-serif">Mobile: 86-15962100482<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt"><img=
 width=3D"288" height=3D"49" style=3D"width:3.0in;height:.5104in" id=3D"_x0=
000_i1026" src=3D"cid:image002.png@01D4DE64.24D9DAE0" alt=3D"cid:image002.p=
ng@01D131D7.ABC30730"></span><span lang=3D"EN-US"><o:p></o:p></span></p>
</div>
</body>
</html>

--_000_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_--

--_005_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_
Content-Type: image/png; name="image001.png"
Content-Description: image001.png
Content-Disposition: inline; filename="image001.png"; size=182;
	creation-date="Tue, 19 Mar 2019 08:31:36 GMT";
	modification-date="Tue, 19 Mar 2019 08:31:36 GMT"
Content-ID: <image001.png@01D4DE64.24D9DAE0>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAASAAAAACCAYAAAD4kAEJAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAA
GXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAENJREFUeNpi/LWF4T/DKKA6mH7O
hibmvtFdMBq4IPBpyUOGr3vkB6PTuDl+PHQwOSM/GkmEAdNoEIyCUTAKBgoABBgAvmoNndLm3ncA
AAAASUVORK5CYII=

--_005_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_
Content-Type: image/png; name="image002.png"
Content-Description: image002.png
Content-Disposition: inline; filename="image002.png"; size=22041;
	creation-date="Tue, 19 Mar 2019 08:31:37 GMT";
	modification-date="Tue, 19 Mar 2019 08:31:37 GMT"
Content-ID: <image002.png@01D4DE64.24D9DAE0>
Content-Transfer-Encoding: base64

iVBORw0KGgoAAAANSUhEUgAAASAAAAAxCAYAAAB6fnQKAAAACXBIWXMAAA7EAAAOxAGVKw4bAAA5
5WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0w
TXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRh
LyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMwNjcgNzkuMTU3NzQ3LCAyMDE1LzAzLzMw
LTIzOjQwOjQyICAgICAgICAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMu
b3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJk
ZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFw
LzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMv
MS4xLyIKICAgICAgICAgICAgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bo
b3Rvc2hvcC8xLjAvIgogICAgICAgICAgICB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNv
bS94YXAvMS4wL21tLyIKICAgICAgICAgICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5j
b20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i
aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0
dHA6Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5B
ZG9iZSBQaG90b3Nob3AgQ0MgMjAxNSAoTWFjaW50b3NoKTwveG1wOkNyZWF0b3JUb29sPgogICAg
ICAgICA8eG1wOkNyZWF0ZURhdGU+MjAxNS0xMi0wMVQxMDo1OTo1MS0wNjowMDwveG1wOkNyZWF0
ZURhdGU+CiAgICAgICAgIDx4bXA6TW9kaWZ5RGF0ZT4yMDE1LTEyLTAxVDExOjA1OjQwLTA2OjAw
PC94bXA6TW9kaWZ5RGF0ZT4KICAgICAgICAgPHhtcDpNZXRhZGF0YURhdGU+MjAxNS0xMi0wMVQx
MTowNTo0MC0wNjowMDwveG1wOk1ldGFkYXRhRGF0ZT4KICAgICAgICAgPGRjOmZvcm1hdD5pbWFn
ZS9wbmc8L2RjOmZvcm1hdD4KICAgICAgICAgPHBob3Rvc2hvcDpDb2xvck1vZGU+MzwvcGhvdG9z
aG9wOkNvbG9yTW9kZT4KICAgICAgICAgPHhtcE1NOkluc3RhbmNlSUQ+eG1wLmlpZDozNDI2YWFl
OC05MzAwLTRkNTYtODNkMS00YmVlZWY5OTNkY2Y8L3htcE1NOkluc3RhbmNlSUQ+CiAgICAgICAg
IDx4bXBNTTpEb2N1bWVudElEPnhtcC5kaWQ6NmVhNzk0M2EtZThlYy00NTU0LTg4YjYtNzEyYWM0
ODdhOWI3PC94bXBNTTpEb2N1bWVudElEPgogICAgICAgICA8eG1wTU06T3JpZ2luYWxEb2N1bWVu
dElEPnhtcC5kaWQ6NmVhNzk0M2EtZThlYy00NTU0LTg4YjYtNzEyYWM0ODdhOWI3PC94bXBNTTpP
cmlnaW5hbERvY3VtZW50SUQ+CiAgICAgICAgIDx4bXBNTTpIaXN0b3J5PgogICAgICAgICAgICA8
cmRmOlNlcT4KICAgICAgICAgICAgICAgPHJkZjpsaSByZGY6cGFyc2VUeXBlPSJSZXNvdXJjZSI+
CiAgICAgICAgICAgICAgICAgIDxzdEV2dDphY3Rpb24+Y3JlYXRlZDwvc3RFdnQ6YWN0aW9uPgog
ICAgICAgICAgICAgICAgICA8c3RFdnQ6aW5zdGFuY2VJRD54bXAuaWlkOjZlYTc5NDNhLWU4ZWMt
NDU1NC04OGI2LTcxMmFjNDg3YTliNzwvc3RFdnQ6aW5zdGFuY2VJRD4KICAgICAgICAgICAgICAg
ICAgPHN0RXZ0OndoZW4+MjAxNS0xMi0wMVQxMDo1OTo1MS0wNjowMDwvc3RFdnQ6d2hlbj4KICAg
ICAgICAgICAgICAgICAgPHN0RXZ0OnNvZnR3YXJlQWdlbnQ+QWRvYmUgUGhvdG9zaG9wIENDIDIw
MTUgKE1hY2ludG9zaCk8L3N0RXZ0OnNvZnR3YXJlQWdlbnQ+CiAgICAgICAgICAgICAgIDwvcmRm
OmxpPgogICAgICAgICAgICAgICA8cmRmOmxpIHJkZjpwYXJzZVR5cGU9IlJlc291cmNlIj4KICAg
ICAgICAgICAgICAgICAgPHN0RXZ0OmFjdGlvbj5zYXZlZDwvc3RFdnQ6YWN0aW9uPgogICAgICAg
ICAgICAgICAgICA8c3RFdnQ6aW5zdGFuY2VJRD54bXAuaWlkOjM0MjZhYWU4LTkzMDAtNGQ1Ni04
M2QxLTRiZWVlZjk5M2RjZjwvc3RFdnQ6aW5zdGFuY2VJRD4KICAgICAgICAgICAgICAgICAgPHN0
RXZ0OndoZW4+MjAxNS0xMi0wMVQxMTowNTo0MC0wNjowMDwvc3RFdnQ6d2hlbj4KICAgICAgICAg
ICAgICAgICAgPHN0RXZ0OnNvZnR3YXJlQWdlbnQ+QWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKE1h
Y2ludG9zaCk8L3N0RXZ0OnNvZnR3YXJlQWdlbnQ+CiAgICAgICAgICAgICAgICAgIDxzdEV2dDpj
aGFuZ2VkPi88L3N0RXZ0OmNoYW5nZWQ+CiAgICAgICAgICAgICAgIDwvcmRmOmxpPgogICAgICAg
ICAgICA8L3JkZjpTZXE+CiAgICAgICAgIDwveG1wTU06SGlzdG9yeT4KICAgICAgICAgPHRpZmY6
T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj4KICAgICAgICAgPHRpZmY6WFJlc29sdXRp
b24+OTYwMDAwLzEwMDAwPC90aWZmOlhSZXNvbHV0aW9uPgogICAgICAgICA8dGlmZjpZUmVzb2x1
dGlvbj45NjAwMDAvMTAwMDA8L3RpZmY6WVJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOlJlc29s
dXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDxleGlmOkNvbG9yU3Bh
Y2U+NjU1MzU8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u
PjI4ODwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv
bj40OTwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8
L3JkZjpSREY+CjwveDp4bXBtZXRhPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
IAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAog
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAK
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
IAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAog
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAK
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIAo8P3hwYWNrZXQgZW5k
PSJ3Ij8+BBUoAwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAb
rklEQVR42uydd5wV1dnHv3Pb3u0Lu/ReBERRUCzYQAUbWMJrN1HyWuOrqNGoiZpYYtQoUYyKPbbE
RtTYYlcEFUWpFnrHLbTtu7fNvH+cZ7hnZ+fevQsrrjK/z2c+sztn5sw5Z875nef5nXINy7I2APl4
2F4cB8xKd8OkSZN48sknvZLy4AGwLGvb34al/+dhezAOeC9V4Nq1a+nTp49XSh48uBCQD6jximSH
EEsXeOWVV3ol5MFDCvi8IvjhsGbNGqZPn+4VhAcPHgHtfFx11VVeIXjw4BHQzsfy5cs968eDB4+A
fhw89dRTqYLGAQ96JeRhF8T+wBMeAe0ExOPxVEF9gCO9EvKwC6ILcLRHQDsBWVlZqYJqge+9EvKw
C6IBWO8RkAcPHtoFPALy4MGDR0AePHjY9RAASKx9ELN0JkbYwUcJE4xcAiMesG/NCCvnPcFXi+ZR
XFSEibHtuj9WSWPunmzocAon7pFLp7z0ccZNi5cWxInVvo7R+C6Gv2RbmGFYVNeH6VlcyfB+ZURi
YLa4qMTCMML4fR0IZw2hMO8Iwln9fkrf6z7gPCALWAz8A7gfqAN+iVqXtpt2vwFYwCnAau36n4Fz
gJ5AAngDuBGYB+wB/EHu+c7x/quBAcCF8v8lwBigv3Rm1cCLwN+1Z34HjAJ6OTq+lZKudLhK3jVQ
/v8QuEXOOq4ELtLumwPcAfzb5b59gbuAuY4wO9+3AV8DxwCTgE+Be13S9iSwSOICuEHi7pFBPn8P
nA/Yle9d4HrgC+BRYARgAhXAFmCwfEsDOEq+/13yzpVavKOkfMYAfpTW+CRwndQDG4cBF8v3vsMl
b48BS4C/2k0XNXJ7DhCU8nkcmAY07jABmaUvkFj0IUZBs/aK1QA0LCZw0McZR9qh8j6WfvwV1aGe
FGRFsJd+BBs3UtP5GBb2O5aaulquOKJH2nheXbCRZ+dmU9j4IbHN0zBCHaRVWUTjfmKJAKcdVE7p
RqhtyDzTlqU+ZSgIRfnH0b/nHYSz9mzv5PMBcDgwXSrWZKk8TwkBTUKNrq12EJBdgQCKpOH1k8o3
HegGnAacAHSQyn0m8KwLAf2vNIYLNULqJQ3HEvK7FxgNnCz3XAcUAqsc6dnaQn5nAQcDS4GpEsck
KYMTgNfkvpnAIdp9YcnPdOAe4AotztOBkcB4iU/HAMn3v6WBjZJ4TgM+AhY67j8b+FYjoJvlnC6f
QeAzIapvJb3F0nmMk7QlgE5AXP4HWCfXfRpZngk8pBHQb4Ep8vdTQlyHCtn9Skhtk4Tvo+VtNjDD
5TvbBGQAnwAHAM8JKU4G/iYd4I4TkBHugVEARl7zG4x8iK+aCfnnEhj2WGYE1CWXU/aHZ9cMpiin
dtvXCESyCRV3Z8+u2cxdV86c1Xns17fQNY4NVRHe+nYTg7sMgKpOxKwSjGCfbdZPRVU+Y4esZL9B
sKkassOtz3zChPLNb7Kl6k2GD/mQvJwx7ZV8DpfjbOBprfF3Bcq03jaq9apumCHhh0nDtfFHYCJQ
Lw0YITUn1sg79R5+vlROG3+RSj9ErDQ/8D4wthX5fVbI52SHFXO5kN98+f8/Qj4TgZe1+y4SC+46
IdGH5XqNHAXSy5+rPWPnt1bOUTkSkv5OjjSaUh46Xpa0pMJ/hXzGA286LLNfC9FcqF2/Sb5Nb0c8
9jeIyPlQIZ/XgeMd9+4nHcQn0nnYz5modYzvSKejo0HL23HyfX8BvKJZcMVA5U7RgHyFkFj0OIlV
f80oUrMhl0HdYFjnMjbX5+IzHL6RAR1zg7wwt5xIzHSN47k5ZYBBlr9pEg3DoqYhi24dahk5cD21
DU1ty9bA74O8HEVE3yw/koRZ3V4JqKOc9d404mgARgtxHAHsJZVnpiNsKXC7NLiCVqTLdKlDr8u5
k1bHEq2Is5dYKo+5uFBV0iuvAwaJJXSfg3xsXC+9+EOaBdhb3LdfSy9/UJp05En+RgMl8p6WEE8T
NlIs1CkO8kGsijvkrCNXs5zc3hPVCBsX8rHd0Qu18gLIlvM4IAQ838q6Vy/fYCeJ0H4wciH++TWY
5S0vL0iYfrDgiH7LyQ7GaYgFm7QOy4LC7AAba6K8NL+i2fOfrKhkwfoauuSHMB27hSRMH7FEkAMH
raAg26I+2nLLa8kdywlDbb3JhvKb2ysBvS2N7zXgT6jJjE5US0M7XMjmCLE6hkv4BXK+fQcakRMR
6T1LxKUZDrwkhGNrLFtEaxqjpWtcGkvtJDnf2MK7z8ggP3bYMO1ab9Rs3FUO18PZFhJiDc4BrgH+
TytLUpR/P5d82pqcbRndth3tM9BcHAFxqXyiOz2QJh7bArxYy5tPOqIzgFNJPTn2NfnOH4lG1qst
K3ZmBGQJT4YgNvMUrJo5aW83DItoIxQVRji010oqI9ngsIJM06JbYRbvLt7Myk1JAac2kuDFueUU
5wWbPWMYFpV12ezeo4yhPSuprFPk09AIDRE5ux0SVt8I8QQYRnMSCgVha9WL7ZWAaqW3XiwNczXw
pZjX27xWIaAPxGV4X8TNRyS8e2u5OYN7FotZv1HM8XlCOAdoLs0yYKhYHna63pEG7YahLj2uG3bX
8p0K6xwuiymuA+K6BcRCssPcEBSrq8JhOTrbzjKxcpz5vFbCe2hWXFuhjuRmgrMy+J7dHHntIrrO
YpruaeXX/q6UurcSuBVYKzrWsLbIQKA11dHIAasGYh+NIXTMCgh2TWubmxE4oPd6vt3UhYq6PIod
hBL0+wj5ffzzi1JuOK4/AC98VUZVQ5xeHcKYlrXNujGAxliQ3KwYBw5aRcKESAzCoRL6dL+uBUI0
MM0I0dg6Nm55ikismlAQdOPK74dofD3xxGYC/uL2SELfSqM7RHMhvgD6iivWW6yX/R2VriaNppOq
wZFCXIw43IHeqJmtl4gmdZBGIDaGCDGdp5GaBZSneP+GFG6HE2vlXAxsTiVHupCZvX/T96hRpFuE
JOaniCNXGuGh4tLdhRqds1zy+YkItHo+N2oWkt3m4m1UJ8Ka2za0hXsNTbOxm1WhfIfRcv4ncBbN
97iaKyL9aKl3Z8u1rmnKvg0tII1VjHyw6uqJzTgorWtvALEYGCE4st9yoqafhNn0daZl0Tk/xLKK
euatq6G0KsInKyrpVtjc9bIMqGkIM3LAGrp3jFFdD4kEBAKd6VpyedqjS/FldOt0NX26/509B83F
788h7ki6zwexhEkkupp2jlkinh4s/58q5xzh/XnaMR9YIeGPpdEJnK6E7vs7xU+9dyyWBvYfEbYB
XnA8ky9W0VxHukpTvN/Wfc5tIZ22FnBemnsulfPCFOF/FsKbp1lJhktfautkt4pgbAvsAQdRlbvk
c4MmUCMNvK1QImRWL8SXCkfJ+RlHu49rGtTlqJG1kS55szEDNRR/tISP3dEMtExAloPrTTAKwaxY
RfyzI1qwPCBRD306VTG8SylbGnKaCdKWpVyxVxZU8PCs9RTlBAn4jGauV3VDmN4lW9mnfynV9aqa
GAZYVrR1XUZoAIV5w4nFmhOmZYJp1rdX4tnb8b+d0M0ZfsvpYq28Kqa3E9eghnfnpNBWisTle1W7
FiU5gpIQ4fcUh7jrb6UI/Z24kXdJQ3fiatFWvpAGfrtL2YAaej4MNSqXbpLGIaKp/UfLRypcL67I
HLGutrZCP/sAWICa5+Omf10rVlZrkK2RdUEKPaybpiE+kiauqVKmc6Q8KrSm4SzfBs09+wFdMEM+
R1yMPc2wNIogvvJjyD+fwJ6p8xU3wW/BmD4rWFXas7kgDWQFfNRHE5imRV44QMJsLjzHEwb7DVxN
ThZsrAbfDijPhpGbRuBol1tkn4ya4DcTuFuEwKlCPs85lLoXHT25gZqs+IEQw2rU0P1U0Su6SMXt
ID34N6hh7AfF2poils4j8o6LtHT11YgQsRBuElekQNy/hPTAzzusJ4DLUmg4R0s6v0PNNXlVLKnr
RHOaIvrW4cByIaKnRQAPo0Z9xqCGva9zpNeZhtXiUt3l0D+KUxD7GHH/8lwqy6kuGopNLsvFhVkp
x8Oo0bCOJAcWrnHoTJ1SWGW27hOS83NCttcAJ4pmtUXK5zK551BHZ+Lm5h4tpFqiXfslal7RuyJ0
D5Cy2iA61w9IQI3g63U8YJFY/jpGYdMi9xVCYuGj+AqG4es9OaUVFGuEgsIoh/Zaywtbs/E5vptp
WWQFfEI2TcN8IjwP7VnO4O5RttbuGPnYMoDBTwqz5eNfrFWkmeKL2wTwilTIo1y6kVc0UbYbagbr
ZVrlXIkaJbPdmoeEOO6VRo24FOdIxbbxIsm5KDZOAu5ETeR7R+I6AjhWqz32DO3cVP2WVPRponf9
Wq5vknQ+ovXAfVEzryeJ1WP30DcKGTqtQL/L+6aI69FL06bmCgHHXITt8yVN+mjMNHGLj3UQk0Fy
5KtKiOZByYc9Mlkm6Xf+dMrnkj+nVbZSSH6jdu1iSfMtqFnKNl4TV1SfsvGNPO/cD74SNQXiUtQg
h+12PSJ5HifX3pey3mEty7Asqzq+4Ff5iSXPNJuIaNVAYI+L8O85jejbPbAqv1ckZGpFGwWrEUJj
38AoPk7Vni8nkFj5xrb4LCAYAF8Envz+TL7q+hAFvo1gtWyZx4x++GpuY/ygGygugur65ChWNAb5
ubux9+Clrcr0vO+6Ud9YRjCgu4JqhGyvQTPIzz2sNdGNoflMUm666SZuvPFGt/tPB34jveH2YLBU
5LI26HwGiuaTbnuQ3YTkNrQy/hDJeSo7isEiiq9p4b5BQhirfiIdy2DacE6Nhp5ioS1vQ8HbJ+W7
hebzlTLFWOA2y7L2y0wD8oFV+42y1UbPxMgCq1Z7yjb6AxCbMR6rYYmYNNHmgnRUyaQje6yjIR4k
0x8Dqm3ws3vPUnqVoIbdjaakYRj+VpXA+vKbqKlrSj52VgwD/L7c9l5pl7QB+dhWxmJa3pto2XaQ
D21IPnae12Rw39KfEPnY+Vr3A8S7Xr5tvA3jNCXOirZMaMvD8D7lZhrh/gQOe4/Ye2OxGsAIJwVq
Ixesaoh9dCihYysw8oeB+W6TaIJB1YctLO9OuCSmiCQDEsoNJ1hW2plBeVCQB7WNSRIKBiEaW8fS
1RMyaxHxDVRWzycUcildE4IBP6HQAH4mCMtR2Y7SVCTEVI+HtrJKCtrZN251BjK/ueORBA9+VHnY
MU0aM8EoAKt6I/E5x2LVr8JwrC7xheHrDT4WlHUlPxTJ+J3ZwThlW/OZvTRIVlANl9vw+yCRqKN0
0xsZHVur5hMMqOeamQNxyAoNIOAvaq/f6rfAW6hhdftYRXLpg40zpKdqEEExghp5yXbcdxFqFfwa
EVWXopYbZGoCvoqaGZsJThFLaytqPtJnmlZ1jKTjoTTPT5N7jnYJ6y86xzEuYcMl7DvJ4yrRpWwf
+wG5tkL0llel7Oyy3Rs1gfA1sQT1sl+pxTNZ4rXL8juUEOzWvk6S+JwjkaPkWx7nbAKSrvO1a4dJ
GSakTC3UKJ5zdG28vGulpGs5ajCgv3bPE6iBDTdcghLy7fJYImk86UchIABfj3MJjLwWq4amc0eF
hBLr38Lc8PK2JY2WBaEsqKsJ8tGaXhRkNeIU9X2GQTRu0hgz8TmmKZuWQVFuPYvWdmFZaR5FuckJ
hMoFg+yszI6skD1031yljSegpMOk9txZXCANsEI7SmkqCk8F/iX+/w1Sgd5CDdOuo+lC0nOksn+F
Gn7djJqd/BXJBampcCZqPtGtGdx7LGpukD1X5XbgQE3Q3EvScYE0QidGCFkeh/vs2z8CE1DCtxND
JKwGJeQvlvfOQInO66UMK1BTEI4XC80u2xhqmH6CaGV62ZdrbuZFEu8cEW8bUNuQfOaSps0Sn3M+
1u+EMK53XD9a7i3TyG4GyW1FLhESOUGI5nDt2cPlXUuEYNehRuoWkpwVfY4cbjhXiN0uj6ik8WXc
19/9AC6YC/yDbsOqWUxi8SsYHWk6PB/SRBXAbwB++HhNPyojfvJD0WbSeyxhEvT7wIDGWIKsoK8J
SQT8JoZh8MXyfvTptIhQAGKJtmnVhgF1DVCQl0O3knb9K6Y+6cVGpQg/Wyrnnai5MjbuRwnJS1Gj
OgO1L1RH09XbE6THPBU19JoKf5bevg9qu4t065vukfNA7dptJCc8mqJVBCRe55qkm7X7nKZzvuT7
c9Tyj+E0ndEc16ysLQ7J72nUzPK/aI3tUSFEHfa2Ivu28G0WaPeCGpW6HzVI8ZF23R5mP13eZ8Pe
UWB3kqOEaNbGa6jlNFNx313gUiGpD6QsE1r+j9Xu6ybW6KViwZaSelJoQEhrlAtZ/lWs1gt3qgW0
LWX7voyv515YlQ6Dxkj+b1kQyIHvN+Uxt6wHxeF6TMth/fgMNlRGmDCshPMO6sGmulgzC8WyDApz
Glhd0ZH5qzpTmNPUirGsVh7yTMKEmjql/eze/30MI9SeCcgi9bpbP2qodLODfHQh+RLU0PY4rUE7
Ya8n6pQmHYeJqX+AmP03bkde9G0HcsVCuQs1XK/7wIVCik9J7+vcMOZWKRObtO52KTNcnquj6cZh
kJz347wey1CgdbYl2/opcbl/uoNoDxFyOUvyf6rDpf5U/ra3YnGbgVxLcv+g69J8Y5tsumQim6Yw
Uu5ETc+4gORyl51LQADBQ2ZhFHVS7piv+ZcPyqqXD1bvhoFF0G86XC/YXBulT3GYUf2L6FeSzcje
BZRWRZq5YoYFuVmNzFnRl4rqAHnZSfKJxlp5RNUZC7p1OpGReywkN/vA9q7X1Yq7s7d27CWNtDdq
PDKdJXK/nM/X4vMLkQwTYlkkYc+liedBIZBy1KZUIYfZ78Sf5Py9uColLo23kOQs3ru0sOu1s9vP
jFyKmuNUJzrRGNSSFBu2nTwONYt7b9TcplzUtiROT9ytTdRqrs95clyAmqDn0wg1X8pyD3GbPhVX
7L8u6baXRNjrt+yFuf+SRv8bzVoJSTkjBP1OmrJeLJ2QPW/KnrF8pLiyI1ETCm1dbUdgdzyn7nQX
LNnv5hMcPZPY20Ow6tRiVbvP8VlKeJ67qhvLthTTNbcGM9KUVOIm1EUTXDomud/SGft15dvSOuqi
CXKCviaElp0VY1NNHp8v7cP4fVdQnYDscA8G9b03czNCTCe/rwNZoQGEs/r8VAYMlqN2spvvuH6W
mN2Qes2Tjs5yXiuENlsLmwf8D6mH3fuKi2APO34sxPKIw8XS8ZxYF/dJpZ+GWpd2ntbgfdJwnhFX
yA67Sp5f53BLbJdTbwAXS8O9SVwESC6o1V2dLWIh3J9huddo+poTzwuBrhLy0cvyEyF7t0XAb2nu
3c2i38zS4vyVw9J5TXt2dgvpXUVy4zHb7dRXum+QMvtyB+vjBk1n+5EICDByBhM49DVi7x2vuDuk
1lSFwlBbE2TG2gEUhJovrPYZBhuqIozerSNDuiYHXjrkBPnF8M48Oft7+hZnN6lxlmVQlFPP12u7
M7BbBX1KarCMTnQomMgugL5Soc7SeuuACMj2lPq9tR4uFex5HH2kge6P2przOhEYS9M8+3utxz9Y
np+Dmv7fE8dvPjmsrwdETJ0sJBMWK0J3ca6Ua8M10fWqFHHeLo17kLgtlWKVXaURULYm5FaLWzRd
030yge2aDZZ3+DTLzU77AGn4J4i1dppYlKm2+IigRpZOknzkaFbOA0JAhahdCCtpOqdqVAvp7Udy
61V7QfGe0nG8KOXTFvvO2Nu7fPOjuWDbIimZQOCgqVh1yuXy+5Vx/9HqAVQ1ZpEbijadm25ATSRO
YXaAU/Zp7ooeOUSRUkVttJkrFvCbGD6TT5cMoDEGoUAtuwg6iDvwlpj1/5WesVwaa8zFrdBxiZwf
1rSXhLhd16NmV3/SQl05Q7N8ZkkveoJDd0inYb0qvfqXJFeF2xZCFskRpsdRoywV0tMWOerrUHFP
clH7N8+Ss12ZTrRVAjkvEcthirhPrem17U56qaSnTI4Kh45VJ2k4Xa592kK8zwhZ3OKwimZrQv8o
kkth7HIflybOoUKYTzgI+Bsh3tni5mU6ezfdiqUpGbjrO4eAAPy9JxMYMRmrCgJhWFXegXll3SnJ
qWsmPANsro1x8j5dyMtyL4sz9+tKPGERS5iugvSGLYV8ucIgPzuyqxBQNI3FGkcNpXbEfU7HXqj1
Ut9p5njcUcEmSoO4PMU7rhCd4xjUiNBIOfaWin1RCp1mX00ctaFv+2qTRI5GlCNQQ/XXag1cF1Wn
afkaqR3DHO6SbXp31awpKwMrMdNGqJe//m3OE5csnT4yTcTxq0XXaXCQ0yWS7nsd8aK53Do6iTUa
Q4nzennZBH6S5Odp7bkQzUcXdWKNu1iED6Lmcf1B08i23wWzGr/HctkO2aoBq2Ft5iS0+1SMhq+p
mv8BL37jo6ZhBf5wA5YQULCxnBqjlG/LGhnVI49DBhSl9jeKszlycEdeWBilKLKJ2NZN+ILmtioR
ifl580uLvp3r6d5tlyCg/jSfTKjjWRFarxAT/j5x2Y4S12ojarQFzQXTBdsPhKDuRq2SX6CF5Ys4
XIPa2sGJyeIK/o2mOx36UBPXuoobtlwa0SBN5+jlaOi6e/APR1iVNNrDpOddlMI1u1Y0KXuZiT5X
6Qx59n5HWosdhOgkoK8crpCF2rtoirjH+rd5TNy856VcVruks1x0ry4kFwHb+Le4oji+wzLRuh6Q
998tce+raWKHkBTfO7m8015Y+qxY0KZYWp858jZZLLqJEmaJm91Ls4Bu29FKHQDwdR4PQ3Iwwk3J
3opY+DoNb51Jtc9bbKq8jB6EGJYf2EY+AP7YFhry96Zzx2wmDstrMa6ThncmYsZJ1I3CaNgM/s6a
hmSxqboWy997V7GAHqf5cLITvxVr5I8kR58apce6gqa7HD5L098QAzVf5DHUth16xe8h5v+dKd47
R1yFXBe36yTpKe3Gvhm1q549EvSZkKuetltJbjlhu2mvo+b7DBT38/oUablNLKHdpfG/7tC1nhdC
HijEZL/3c7nX2RXPlutDHB6DT/se/yC5NYaN8ULaB6UgIOQbTaD5yNZHWn7dLKevpYz0nxx6SSw8
fS3cTNFqdOK8QK6NEQL6m7jF/Rx5C6Hm+eRIh+FDzbp+WwhwXpvUasuyqi0PO4LRlmXhPFKshEc0
ghk7gbCyaDqn5seGv43S05Y7qfwcfhm46CeU1rHAHL2dBPDwc0UkjW//YyBB2yyabMsd48yfwXeu
/Ckn3vtteA8ePHgE5MGDB4+APLQRYrGUS4hyyGwdjgcPPzeEabojg0dAPxRMM6W8UIYanfHgYVfD
ZhxLSQzLsuyFdB62D2NwGdWaP38+I0aM8ErHgwcHLG0rC88C+oEwfPhwxo4d6xWEBw9p4BHQD4h7
7rnHKwQPHjwC+nGwxx57MG7cOK8gPHhIQ0Ce/rNjCHpWkAcP24cAamOqfNrpbxK3Y9ibz6b9iZmh
Q4cyceJEXnrpJa/EPHhw4P8HABH3BN/k75YmAAAAAElFTkSuQmCC

--_005_DB7PR04MB55808491855429C48CE8CCF298400DB7PR04MB5580eurp_--

