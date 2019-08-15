Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B581FC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:53:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65E932086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:53:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="Os2CopjL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65E932086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F49F6B0003; Thu, 15 Aug 2019 16:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A5676B000A; Thu, 15 Aug 2019 16:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E108E6B000C; Thu, 15 Aug 2019 16:53:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2C06B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:53:01 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3405B180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:53:01 +0000 (UTC)
X-FDA: 75825861762.28.trade06_375be01b39762
X-HE-Tag: trade06_375be01b39762
X-Filterd-Recvd-Size: 7218
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740079.outbound.protection.outlook.com [40.107.74.79])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:53:00 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ICKqRPK2x8DYlHugvqAGNhwnJ7sHDI4ngiqabCtvft12t6TyPhDUpn6zSLbKvkPE3ZdjRuHBBvfClP9X2kT6P/TjfAMlxwZ+Ojvpo2kR2k+GuFaMbuX+/pzM6OxC4PKRafKexsy4kv4Dx/czeCrNa5706I9ejBCorlJquJ5t5n7OsxoYGIXGVbLsp0jFZt+E9GNXEbDQLMQJZzrJhrYa9ACqn8aGd5dHsZU0hkB2HlFN93bN5fyWAxuOUyw0eGLai9lKj/6uBV6RKrU/HHO7SjlteILM5F/bLg26IhDj0QpazLaBAMKgpAdlECvnRpBx/9sRYaw5JNAeyEbyb2H69g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FwlSdlmppSFwpZoQXUMtkLZgJLBSkUNbt3B+WLM0JFg=;
 b=YilvcRFPmCq8444pAfuYEy5GpZQj9XiIltG6MLrmQX2TmH0NbOIOWbCelFqIqaQ1DBHrJnDeI+9lXVTxmRVN+DTMYR7MC8uezW7k4YMfkzYcfD4enYooncvjrJBNziJxQvXK3G4htC98Fx09FeOC1nWEr1ggEdaqR7bCziKRrhe8vUlHkl4zzAAy7mLSau8iKLrpiWOd4RSGC4zxkP6s0dq9+nS23MASpnZDXLoUW5OnltNZwhnxj8hNWn7dZApu4woDzCZvP75fqQZhxkmmBYDjViR03YljL1AMXLhrfglRWuXRYhVQ0zGbNT7N13baq3zyff89FB6uZ7ZIgCfsDw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amd.com; dmarc=pass action=none header.from=amd.com; dkim=pass
 header.d=amd.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector2-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FwlSdlmppSFwpZoQXUMtkLZgJLBSkUNbt3B+WLM0JFg=;
 b=Os2CopjL/1EgWsIQtsXQyL4NPjvQyBgGoZBGKyuRHQfO6s6vSRT0vpEECFev1zHy2NQy8pafq1avqfDNa8eD1baL6D1WQDw+r10HFx3ByZ+ba7NOTYNUNi2CTd3p2rjvN9JdWvA2Ji0kcARQ8/qsHqo4tSZpmZQAitUIHUiOkbM=
Received: from MWHPR12MB1374.namprd12.prod.outlook.com (10.169.206.9) by
 MWHPR12MB1887.namprd12.prod.outlook.com (10.175.54.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Thu, 15 Aug 2019 20:52:57 +0000
Received: from MWHPR12MB1374.namprd12.prod.outlook.com
 ([fe80::9c57:4338:ff8f:2cb8]) by MWHPR12MB1374.namprd12.prod.outlook.com
 ([fe80::9c57:4338:ff8f:2cb8%12]) with mapi id 15.20.2157.022; Thu, 15 Aug
 2019 20:52:57 +0000
From: "Yang, Philip" <Philip.Yang@amd.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"jgg@mellanox.com" <jgg@mellanox.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>
CC: "Yang, Philip" <Philip.Yang@amd.com>
Subject: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Topic: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Index: AQHVU6tqPJgEXxIoEkOKYOi6xfC1FQ==
Date: Thu, 15 Aug 2019 20:52:56 +0000
Message-ID: <20190815205227.7949-1-Philip.Yang@amd.com>
Accept-Language: en-ZA, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0005.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::18) To MWHPR12MB1374.namprd12.prod.outlook.com
 (2603:10b6:300:12::9)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Philip.Yang@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.17.1
x-originating-ip: [165.204.55.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2f8d6143-b673-4cde-427b-08d721c28ce4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:MWHPR12MB1887;
x-ms-traffictypediagnostic: MWHPR12MB1887:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs:
 <MWHPR12MB18878402E5D80A9F338B26F8E6AC0@MWHPR12MB1887.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3513;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(346002)(366004)(376002)(396003)(39860400002)(199004)(189003)(6506007)(66446008)(14454004)(66556008)(8676002)(64756008)(99286004)(6436002)(386003)(66946007)(66476007)(81166006)(186003)(305945005)(486006)(102836004)(71190400001)(4326008)(1076003)(52116002)(6486002)(6116002)(81156014)(71200400001)(8936002)(2501003)(476003)(5660300002)(14444005)(110136005)(6512007)(478600001)(2201001)(7736002)(53936002)(316002)(25786009)(86362001)(2616005)(256004)(2906002)(50226002)(4744005)(3846002)(36756003)(66066001)(26005);DIR:OUT;SFP:1101;SCL:1;SRVR:MWHPR12MB1887;H:MWHPR12MB1374.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 bfG34piVXhyEJ4jeZ0/4bH5U0ZzhSRoDIX/JsNXT+UmGLpMQgRZT4exaEKP7oYsRo5785XOKqn3GikScvc4H72/zTT3stPNRpbAgi9pghm4cN9l8x30iyFyA28vge//ATrm+0thGna2I0RoUKTcQy5MVFFkrBtTc/Vf3xfYZErhhw7LJ7Yj1x++tB3szk9ZB/0QncxJVi8nrJFYzhgWz8uwk8OfjkcSb9z1AeLszBz64gurNeYs8L8WsXDN3MdgYnvvaNsW4bDUhULsw1h0u63xHsAMwmfYCG3n7qp8wd3EUUCWTGY0C2HCJ53IB375BCoSVoiw36br4HedkeW6199I0o7cblJbrcNALRRhgnoGKuaNXc2d4J/qysBgIyoXgsA/u4eBultV/vYeJB4332SwWBH3gBoVEJVCYcsaDVDI=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2f8d6143-b673-4cde-427b-08d721c28ce4
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 20:52:56.9914
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 46NYgjV4tUtv0I0bZh/M0nJmUqIDdw8QWunUXRRQV+OZRRkuLgh8Cf7HkQ/f/FeA
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR12MB1887
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_range_fault may return NULL pages because some of pfns are equal to
HMM_PFN_NONE. This happens randomly under memory pressure. The reason is
for swapped out page pte path, hmm_vma_handle_pte doesn't update fault
variable from cpu_flags, so it failed to call hmm_vam_do_fault to swap
the page in.

The fix is to call hmm_pte_need_fault to update fault variable.

Change-Id: I2e8611485563d11d938881c18b7935fa1e7c91ee
Signed-off-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 9f22562e2c43..7ca4fb39d3d8 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -544,6 +544,9 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, uns=
igned long addr,
 		swp_entry_t entry =3D pte_to_swp_entry(pte);
=20
 		if (!non_swap_entry(entry)) {
+			cpu_flags =3D pte_to_hmm_pfn_flags(range, pte);
+			hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
+					   &fault, &write_fault);
 			if (fault || write_fault)
 				goto fault;
 			return 0;
--=20
2.17.1


