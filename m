Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19032C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24AA21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="Ht8Fm6RX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24AA21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70EC66B026F; Wed,  8 May 2019 07:29:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4136B0270; Wed,  8 May 2019 07:29:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55F216B0271; Wed,  8 May 2019 07:29:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29B586B026F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:29:59 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f92so5107075otb.3
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:29:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=peJzb31cm17ABrXFyc+VL8b8kWU6z5UpeWBKRx5iGOY=;
        b=ZKsr0UihA9DNvAYjtkL9y5NzNtZo1NXWux2EQi/Bp0Dq702TFcsO6AeBMku6GSmlhm
         RSI6gZvPy/rFkcUZ9AyWHM0Y+/f1s3AtFVjV9qx866+RhMefsQcqPtwNhEuTW89ef6zN
         Xxm2fsxeNnPi1v0/vOqy+dZetqEmjc6Un9k9TczQAXRjtN8Z50c8xmvgco9Lx/qvadPh
         v2VT6QCR+Kt3lvL//NbVm2W/drXakCj8Gyq7xf7cI0jqmpnzBvQRPK1T7zPmw30kqKXJ
         kT0Dg+M5+agqDhw5o4RypKeNfwk/SdVy9cNEYknuBr/6f5+vRKcJL8RDAYKCDK7+9SnD
         pH5A==
X-Gm-Message-State: APjAAAXkAVkV0itqni6g/TV2N4kllWmE+rqIcnReY7jqZp+XlF0bfPhD
	orx0YHnMu77zIbL1UR/KweY8lpyuFVzQwODadj09eyEQbLcN9dLM0Uauv0r2IH98NvHlkfxpocN
	OEBxqcMytfwB1yP6YUdoc7R1J7vE9k80R33Z93VblcLWG2nhsIOIdFLM3FDHKaGnIow==
X-Received: by 2002:aca:5050:: with SMTP id e77mr1826779oib.31.1557314998841;
        Wed, 08 May 2019 04:29:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFwLSjjxJIVTelKaTpYu6mVpNz1LkKyGPLcTwdANZSWajs8xksQ+iGl5JJcowGb3cbYUn8
X-Received: by 2002:aca:5050:: with SMTP id e77mr1826745oib.31.1557314997956;
        Wed, 08 May 2019 04:29:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557314997; cv=none;
        d=google.com; s=arc-20160816;
        b=oagOB/MEn1OeKjQ98ke64kkCFA8e8S7msuoMKOj/JYPCzVnZXwOKXoW07MDK9WKQwy
         xtAu//Yq8BQxujk7s76tOP74zqpLYGIzaMPpLsQsNOITX4xz3Z3SjVxD2bKDclK9j6xZ
         54zv3+r/yS714oXemD9EGHKanZD29vSuHmADvrOhms1t5sxtN8XSxFQV5Dzln1FmvNoI
         oB9lsMXTv3rGJdCxobbkd/DNgPPGA6PJlRtKgmrxoBwORoi9OqnxeJhZWr4gmS9Jldu+
         EMHm/hs+CUBD5D8uVkFk1cHYLdXB3MB5bKqTA3dt0A6cRqKg/vAXN0PtEJCqTh+6cCD9
         SlDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=peJzb31cm17ABrXFyc+VL8b8kWU6z5UpeWBKRx5iGOY=;
        b=dWO1j4XsiBUCKUPYEKlf6guU19AAFcyR6z54Xp1sqq+gKJLJUTHaPRAl35b0Rw9f/m
         CfoPKcDBvVkCSaVw/58sD96cdV/8Cu4Nxr3js3l7PFPlCFRn4o8NSm1zwszWnWOju75r
         F5TcPt4qNNtZpOtL5egmDt07DM3tM/Rtxx0msGshe8r4NHHQ3REmKMzcA97HmO9CmJ0p
         KhFyCYK1OWb8a9qdDBz1VP4n836CoA3P72zGRuVPjEpBUd1rxl1B8H2HbxV4TyMeFSw+
         MAlvH3K5z3AjvAAKBHMz4zSxQG1CY7u6FUdVFrQeN50lUBQu6t2I3x2vzlFH+p9yxrq7
         0W+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Ht8Fm6RX;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.44 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780044.outbound.protection.outlook.com. [40.107.78.44])
        by mx.google.com with ESMTPS id k127si9628825oif.144.2019.05.08.04.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:29:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.44 as permitted sender) client-ip=40.107.78.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Ht8Fm6RX;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.44 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=peJzb31cm17ABrXFyc+VL8b8kWU6z5UpeWBKRx5iGOY=;
 b=Ht8Fm6RXFzi+Mh2C7TtDBrevghDIkKBBrf5hR26HEMHT3clXH+auLpcCAPlBDjunidMIf2KlMCOrIihkOj8RRHLgWzEWMMKXr0g4KWNemLVVhqUlyEjNr2yadJK+HpBmin3dfirgmdsGRBLIe+wQFsopNOyElR+2pj8AJZVAfxw=
Received: from BYAPR03CA0029.namprd03.prod.outlook.com (2603:10b6:a02:a8::42)
 by CY4PR03MB3127.namprd03.prod.outlook.com (2603:10b6:910:53::28) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.15; Wed, 8 May
 2019 11:29:53 +0000
Received: from BL2NAM02FT049.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::206) by BYAPR03CA0029.outlook.office365.com
 (2603:10b6:a02:a8::42) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 11:29:52 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 BL2NAM02FT049.mail.protection.outlook.com (10.152.77.118) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:52 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BTp08023613
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:51 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:51 -0400
From: Alexandru Ardelean <alexandru.ardelean@analog.com>
To: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<linux-ide@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-rpi-kernel@lists.infradead.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-rockchip@lists.infradead.org>,
	<linux-pm@vger.kernel.org>, <linux-gpio@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>, <intel-gfx@lists.freedesktop.org>,
	<linux-omap@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-tegra@vger.kernel.org>,
	<devel@driverdev.osuosl.org>, <linux-usb@vger.kernel.org>,
	<kvm@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-mtd@lists.infradead.org>, <cgroups@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-security-module@vger.kernel.org>,
	<linux-integrity@vger.kernel.org>, <alsa-devel@alsa-project.org>
CC: <gregkh@linuxfoundation.org>, <andriy.shevchenko@linux.intel.com>,
	Alexandru Ardelean <alexandru.ardelean@analog.com>
Subject: [PATCH 06/16] x86/mtrr: use new match_string() helper + add gaps == minor fix
Date: Wed, 8 May 2019 14:28:32 +0300
Message-ID: <20190508112842.11654-8-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(39860400002)(346002)(136003)(396003)(376002)(2980300002)(189003)(199004)(478600001)(356004)(7416002)(4326008)(476003)(107886003)(305945005)(5660300002)(76176011)(48376002)(47776003)(50466002)(486006)(7636002)(44832011)(70206006)(70586007)(2906002)(110136005)(6666004)(50226002)(8936002)(54906003)(2616005)(246002)(53416004)(16586007)(1076003)(8676002)(11346002)(106002)(86362001)(7696005)(51416003)(446003)(126002)(426003)(186003)(2441003)(2201001)(336012)(316002)(26005)(36756003)(77096007)(921003)(83996005)(2101003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:CY4PR03MB3127;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 9e84d071-f926-4c84-2e80-08d6d3a87ceb
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:CY4PR03MB3127;
X-MS-TrafficTypeDiagnostic: CY4PR03MB3127:
X-Microsoft-Antispam-PRVS:
	<CY4PR03MB3127E9C16F1035878E392535F9320@CY4PR03MB3127.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:5516;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	hda0K0v5ij/G6H2YACXfIt6bKjpSjAgKGea3NqLag4TL7c+wMp6G/9ToPo3Vo2ALGoXYKL8lIXefI3pjgsKmvrxcQbFYmQXJS7mMxOOHzlhmFQ7IYxncBKfDC4dQju6ANVJhrbiCK6I2H9u41GPFBS6zp5bmQ3KEGqcTA6uu8J8UwkG02mPR404b+UaRjboXhFhWhmzco8OFnY/ZS+Oyiv+jgrcub3OWF1ZE6g2PWZYCiPw+ix3NL4MdKxaNv0gnzhApnIqnJ4GghYC7Eb4ExLnTn+gnu/dJzfLMbsj54G46HtKSw8zG3MhatUk0Fy/RUF/d0ftyuE3K6GD9m91VOurlbnHt9HiykZLpXxUZ0G1o+7zGAAC/ca50ThQK38xp2eRz+OZNwVPJAdO97Sm3P+EhZBozB3hNY3g9PrvxJRw=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:52.2067
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 9e84d071-f926-4c84-2e80-08d6d3a87ceb
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY4PR03MB3127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This change is a bit more than cosmetic.

It replaces 2 values in mtrr_strings with NULL. Previously, they were
defined as "?", which is not great because you could technically pass "?",
and you would get value 2.
It's not sure whether that was intended (likely it wasn't), but this fixes
that.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 arch/x86/kernel/cpu/mtrr/if.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 4ec7a5f7b94c..e67820a044cc 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -20,8 +20,8 @@ static const char *const mtrr_strings[MTRR_NUM_TYPES] =
 {
 	"uncachable",		/* 0 */
 	"write-combining",	/* 1 */
-	"?",			/* 2 */
-	"?",			/* 3 */
+	NULL,			/* 2 */
+	NULL,			/* 3 */
 	"write-through",	/* 4 */
 	"write-protect",	/* 5 */
 	"write-back",		/* 6 */
@@ -29,7 +29,9 @@ static const char *const mtrr_strings[MTRR_NUM_TYPES] =
 
 const char *mtrr_attrib_to_str(int x)
 {
-	return (x <= 6) ? mtrr_strings[x] : "?";
+	if ((x >= ARRAY_SIZE(mtrr_strings)) || (mtrr_strings[x] == NULL))
+		return "?";
+	return mtrr_strings[x];
 }
 
 #ifdef CONFIG_PROC_FS
@@ -142,7 +144,7 @@ mtrr_write(struct file *file, const char __user *buf, size_t len, loff_t * ppos)
 		return -EINVAL;
 	ptr = skip_spaces(ptr + 5);
 
-	i = __match_string(mtrr_strings, MTRR_NUM_TYPES, ptr);
+	i = match_string(mtrr_strings, ptr);
 	if (i < 0)
 		return i;
 
-- 
2.17.1

