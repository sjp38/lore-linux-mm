Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0CC5C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71F6D21479
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="h9DQ+GRs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71F6D21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CBD56B000D; Wed,  8 May 2019 07:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07A9F6B000E; Wed,  8 May 2019 07:29:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E383A6B0010; Wed,  8 May 2019 07:29:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2C0B6B000D
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:29:29 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u15so21368112qkj.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:29:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=ej4TvjRJPb880Evlka3jGsq9toPstBngds/H7MSz+98=;
        b=kMDIXad8PU3MvaXREupZJleecPLhbEr9+xn276BAs/03y/8gSf/bDTsXM+65S6xDJt
         a6DM4Jr1pbqtUSr0dNP4roV1jbgx/DrtSxwrcVyNUouLq7rcUZ/gJMRg/uXxQumH4OxT
         IZNivnlSO84+PAMHR0X3kaXT0Qmb5sUztLIN8jPyns/vqCJsMjVKL5ha5q7RKu5RT6f7
         J06wyRDReK3EzxFR6YPr2kzptEe5ONg1qWrJNPDNKO7RLYnQjLF1n2RZlX7k0KADBf5V
         K+gzAishI8BnZBqRBZWwMLHaRi3iOY3K22n/tYrQquYh6Jh4iCChJRlV3hxEivZH4P5z
         QG4A==
X-Gm-Message-State: APjAAAVnoIdfRqBNJWa+y66178trvAn2odCDIH9Bbe1RX8VMB/9+u4yL
	RC5U4ecS7vX62RCisc0VwGLhn4S9WH+EKxiXDPeuG8iypEBkFVtLeZmUrHy7ojavoNNqhRCigpF
	TR6YgEWgVN+Ku1KWN/6nm4kgsoaJu7JTWxtI68z5ZOfG5/kMF6+jplxe/5iHyVfOZJw==
X-Received: by 2002:ad4:4025:: with SMTP id q5mr29462973qvp.41.1557314969522;
        Wed, 08 May 2019 04:29:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwrdBlyT2fN1QoBIhFWuR2+Y3c0ElmQfdNPeSiT940Nk6TpDnUUBPHytMm1ah05+CMynab
X-Received: by 2002:ad4:4025:: with SMTP id q5mr29462929qvp.41.1557314968879;
        Wed, 08 May 2019 04:29:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557314968; cv=none;
        d=google.com; s=arc-20160816;
        b=GzPnv/3u/kK87T+ZaeSMsLjIbmy/ZpWYQY0HIROpqRLSKiSO3teCKH87Xb1Omjx4Vd
         gFg9bMAXnwRhcEQLZqxpU4JBooFc5JNLTp5KWhUlEH+P2+rkvT5H31yLCiZ9K8S7QGtc
         SJJcuQIle/g6LQRbbGbnZJB4n8pTc27+fskvZ1sx1gK+bvGZmHy3VY2wKK/tZpkm0ccY
         WFPZYv+q6u9oc/RdGBL6Q5eH1e71zKthItJs/ycRJFmbl6r87zlLPbLol3RIHeX/AEY+
         V0DptndV96wMPJk3BulW/6TwiBbx3EXwW6prL/4U9TO0IDxBgd31wKFc3w0A+iuY2wc+
         6peA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=ej4TvjRJPb880Evlka3jGsq9toPstBngds/H7MSz+98=;
        b=R4+AHlYZZfNpAGHZRGGN6fmTO4LQeLt5oUDwvBmLrinazofq1rgrXzekqxQI9yLEFw
         CJLH1nLa0ivlF6JowsfP6yA0+22TNz71to3suFaGm/Gdmcsu+jQkBILZSXLM0QMU5gaj
         dQLoWUvxhU2nECkcWQgahb4Xk0ifugTcEHOXeGyk5eWfdSoC3QYR0z43Gs9ggfA+Zp66
         y7BS0avQo1CYbg8VcxkJG3Po0helgtJ57BkXqlHu9Zh3rit9Dnf4DMZ2eEdTf0mJcgb/
         NjA3xcPISRKnkCwUQZozJFq7ZMX579JCDu1tBss+9kRFOu/wuO/oc95D7jY3cWUFksw2
         aX/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=h9DQ+GRs;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.45 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740045.outbound.protection.outlook.com. [40.107.74.45])
        by mx.google.com with ESMTPS id x8si6703266qtr.309.2019.05.08.04.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:29:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.45 as permitted sender) client-ip=40.107.74.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=h9DQ+GRs;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.45 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ej4TvjRJPb880Evlka3jGsq9toPstBngds/H7MSz+98=;
 b=h9DQ+GRsCQDxKqwstM007EbLcpBHqWjQ2MRqXq5cju0OtcgE40K257CUdmKTcLmNiFsVQ8TTUi5HLpjaCc0tXSIxEMkemV6E3tWUguwanL7bPvyn1MHBba2gc+TzvtAMCzfuHmsH9w9p/tFocvXacJIH4a0VqaLEN/p5NINwGK0=
Received: from MWHPR03CA0013.namprd03.prod.outlook.com (10.175.133.151) by
 BN3PR03MB2260.namprd03.prod.outlook.com (10.166.73.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.12; Wed, 8 May 2019 11:29:27 +0000
Received: from BL2NAM02FT056.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::203) by MWHPR03CA0013.outlook.office365.com
 (2603:10b6:300:117::23) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 11:29:26 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 BL2NAM02FT056.mail.protection.outlook.com (10.152.77.221) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:26 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48BTPmx016989
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:25 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:25 -0400
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
Subject: [PATCH 01/16] lib: fix match_string() helper when array size is positive
Date: Wed, 8 May 2019 14:28:27 +0300
Message-ID: <20190508112842.11654-3-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(346002)(376002)(39860400002)(396003)(136003)(2980300002)(189003)(199004)(246002)(8676002)(356004)(5660300002)(1076003)(8936002)(50226002)(53416004)(7416002)(305945005)(2441003)(47776003)(478600001)(7636002)(336012)(107886003)(77096007)(4326008)(186003)(446003)(26005)(44832011)(126002)(476003)(2616005)(11346002)(486006)(86362001)(76176011)(7696005)(51416003)(426003)(14444005)(36756003)(2201001)(48376002)(54906003)(70586007)(110136005)(70206006)(16586007)(316002)(50466002)(2906002)(106002)(921003)(2101003)(1121003)(83996005);DIR:OUT;SFP:1101;SCL:1;SRVR:BN3PR03MB2260;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 06992cbe-c2a0-450f-a978-08d6d3a86d64
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:BN3PR03MB2260;
X-MS-TrafficTypeDiagnostic: BN3PR03MB2260:
X-Microsoft-Antispam-PRVS:
	<BN3PR03MB22605D56BDEC0036712171DFF9320@BN3PR03MB2260.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	HMrFOjcKVNRTHDmX1/HvU/gXQlBl+uBSOtcwOD51vWmdyi5ZtZaq4HeTrVqglmQielk1qFJ8dbdhoPs7SBm2gQas++XsjhD055LJSrs5xjRibQaqSBcjHQ44wcFTrBpHBH89k3Ki8Yow3eXIUMpM+NlewIkNIJV3DPQLKY30RuyrOhfh8nkva9n/YB2AL2kQU6YR15UTz29qyv7g67oh8CMTWpMo3frw6vU81LMqNBFZ66OrPeZSiSJAkJBE/bMd3zQC4Hxw9oF5//2KgiJjBZpmuL6vm8U1PSkG8Dxc2tota5ciVE6wTr78/CN6CfJNaW+OzxN0iMIV1Ig8ZSn8zd4ymGDzX2XaqHB1wZ4OfMvmgpNKxP1+GEdfSFMqVRyw0npwgjP2wrgtmFovCAalytU1DI/oSEu8S/98Y5oQHkE=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:26.1629
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 06992cbe-c2a0-450f-a978-08d6d3a86d64
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN3PR03MB2260
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation the `_match_string()` helper mentions that `n`
(size of the given array) should be:
 * @n: number of strings in the array or -1 for NULL terminated arrays

The behavior of the function is different, in the sense that it exits on
the first NULL element in the array, regardless of whether `n` is -1 or a
positive number.

This patch changes the behavior, to exit the loop when a NULL element is
found and n == -1. Essentially, this aligns the behavior with the
doc-string.

There are currently many users of `match_string()`, and so, in order to go
through them, the next patches in the series will focus on doing some
cosmetic changes, which are aimed at grouping the users of
`match_string()`.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 lib/string.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/string.c b/lib/string.c
index 3ab861c1a857..76edb7bf76cb 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -648,8 +648,11 @@ int match_string(const char * const *array, size_t n, const char *string)
 
 	for (index = 0; index < n; index++) {
 		item = array[index];
-		if (!item)
+		if (!item) {
+			if (n != (size_t)-1)
+				continue;
 			break;
+		}
 		if (!strcmp(item, string))
 			return index;
 	}
-- 
2.17.1

