Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 259A4C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE284214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="TRWzaKL5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE284214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3D96B0280; Wed,  8 May 2019 07:30:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58E6A6B0281; Wed,  8 May 2019 07:30:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425736B0282; Wed,  8 May 2019 07:30:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1950D6B0280
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:46 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j17so2833243otq.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=onHX/dH28+rcBydCYnxXPPy3B5aZvm8nUVopYvgTR/U=;
        b=eF40a8QFBelj5RFaplZjmZRUJmTTOXvBhuYdjyhpZHUIMXzAw/hL2xeekDywf+Rpq6
         ypNG3FFj0k0LKDMd5qcwVmkqtumWV9ZIw9jI5FsEVzGX5QHY4+y3fwQdXGRZaqN+MLuC
         Cbde+TP7jrVpNFgPx1EywJCTwy/odWozYD0ep8Tih9NYnfVfz7feRY9gjZmNYVz6F4ew
         U4zHLml1sf7apmAx8hHe0f2ymQJjCQQEGm4POErD8YAyU1Yp/lI8KIIQPKtdSwK8TENc
         zqFSVefUbHUzd22IipZ7r8Zkjh5b1VjrTbOt0GIaArgIirDSw8CCd24rdQfgdAq66D3h
         qu8A==
X-Gm-Message-State: APjAAAVL+l+Jf7G3aZfFSwDez3acna0TQzAE12wnZZ65BnilHN0yJYUg
	BwHQsJcNk+SYU90WG2o2j87TaAxOzxCoomzfEn9L21SZSFGPsXvHKFoqRO4+9aysZFCIHGrBnP3
	K2MrkLGc4QQOPvpGWV1QGhfSzE0TQdkTTn6WpUOnrS9PCTohuL2j7H0UyFUuJ6lVWkA==
X-Received: by 2002:aca:5f0b:: with SMTP id t11mr729239oib.14.1557315045821;
        Wed, 08 May 2019 04:30:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO9OTzt5yWqxDE3aU3XTboWwJZ629ZfQ96BP6m1sO0unnfd+MEx3qvolHP6mhJT+uiqCio
X-Received: by 2002:aca:5f0b:: with SMTP id t11mr729185oib.14.1557315044842;
        Wed, 08 May 2019 04:30:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315044; cv=none;
        d=google.com; s=arc-20160816;
        b=CxjguL8Y/t6763N5xBLHavXuBtnXirLiVgaWxppkXZTzBjFdI0IY0VFS5TLV3nxrXG
         aoPN2pkQkoU0JqH3d0B6TH8HYC0Ku7Vm7rsupCRWLCeyCevlficFQpN2GJgY3+Z0DEJE
         eBuQLYEBVPHR15TsNcKfJkt05vPo+S6XapHt6IryHu/zJCYz8ZlA+ohDyFSNISMZxzOz
         9WKpebNVN+Hs+7TVpoNNuML1AaspRFyWTWboXgN/4UWglUzvtoHgPyRI4srA8wuujeea
         CsCpf1i9poIkoROKC2BShdWDZhY9RdMR8sDUZH+DGGcN8g7bko1kNNgx8k4G/OtDpg94
         f/xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=onHX/dH28+rcBydCYnxXPPy3B5aZvm8nUVopYvgTR/U=;
        b=qC+NUWEEE/yDRcsKXSVbKa3z0oudPpKxydMu1yWqP0En/RCZfJOiGa09m5cozsG0xT
         qAEcVQp3YHrl2vB0unGN3fvCgvEJKJ6IgifhyJaRkQfNxg2yUKr8cxvNi5svfwuIvzWw
         iQOkI3TBivxThJi4MqY1xxpe8au5rv1Ze8nd8oKk+vk+y0thJaxKfKfQmljF7XDk5Mvo
         CNMQ1X7d5qA/3+rEE0zJ2VXLrdT1WP+I9DZBxdXP4RtNHrCkZrbmsT2Y22xdqLXz1IJV
         cT7PSXs+0Ex8ykp15TqrAppQhcE1lG6TkxHMGQZM1A742A0P4qcxGc18fZHA256/Yfft
         MHlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=TRWzaKL5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.79 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710079.outbound.protection.outlook.com. [40.107.71.79])
        by mx.google.com with ESMTPS id 64si12562243otc.72.2019.05.08.04.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.79 as permitted sender) client-ip=40.107.71.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=TRWzaKL5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.79 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=onHX/dH28+rcBydCYnxXPPy3B5aZvm8nUVopYvgTR/U=;
 b=TRWzaKL5QJNYiXbG+2Oe8fjWtJL+uaSZN7I1Y1mLvIYHbJGfd+k3GEWsuHa6f8MH3o5FyiU8BEW81HV8R20GJd4CjUz2a3wrhgxNZAp7on9a1AKqAYFUNkner8pEKTAQX+E2T5W2P3Av5RpjeoV1wIG/TVCkFL8QTjk7xwoghyE=
Received: from BN6PR03CA0021.namprd03.prod.outlook.com (2603:10b6:404:23::31)
 by DM2PR03MB558.namprd03.prod.outlook.com (2a01:111:e400:241d::27) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.12; Wed, 8 May
 2019 11:30:40 +0000
Received: from SN1NAM02FT023.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::201) by BN6PR03CA0021.outlook.office365.com
 (2603:10b6:404:23::31) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.20 via Frontend
 Transport; Wed, 8 May 2019 11:30:39 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 SN1NAM02FT023.mail.protection.outlook.com (10.152.72.156) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:38 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BUbuE023873
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:37 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:37 -0400
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
Subject: [PATCH 14/16] staging: gdm724x: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:40 +0300
Message-ID: <20190508112842.11654-16-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(136003)(396003)(376002)(346002)(39860400002)(2980300002)(189003)(199004)(51416003)(7696005)(86362001)(16586007)(486006)(8936002)(476003)(126002)(2616005)(44832011)(53416004)(426003)(11346002)(446003)(2906002)(336012)(107886003)(110136005)(4326008)(316002)(106002)(7416002)(47776003)(36756003)(2201001)(76176011)(7636002)(305945005)(50226002)(54906003)(8676002)(246002)(2441003)(4744005)(478600001)(186003)(77096007)(26005)(6666004)(356004)(50466002)(48376002)(5660300002)(70206006)(70586007)(1076003)(921003)(2101003)(83996005)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM2PR03MB558;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 2ce9d3e2-55ad-41f5-b402-08d6d3a8990a
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:DM2PR03MB558;
X-MS-TrafficTypeDiagnostic: DM2PR03MB558:
X-Microsoft-Antispam-PRVS:
	<DM2PR03MB558F9126D7D7828247866DFF9320@DM2PR03MB558.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:1148;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	EVMADUNDHRaZyM70b9uaph59oQp+EuDL9gb4q2zI9AEdIWoTcnaNWUBe+9FxlQX2b0O7+4xknIyCoImhifcxNPmppoSR9Ju8BlK50RVal3XQVeh9l+A7s/7PGVZecREu2vX9qqBWISF2RTmLi8m3PEwYjEAyyjEX8vfRtxItEKrtpqEt8nOlt7fYyW49KHTABKF5js7qPbGcInT5wIoJWo41C0yk64vCRQXbGltzcSHsKdDUuQ9YfnMd+RoeSwokkISCJ2+H3HCcqX7T0oz1KORlekqmtcJeKwxjA3imNWlqT71dJwi19a46r8S7V/Nae2BSdjex5jOfLsOo066cOWXqmOwMyJTvIsJGUQfFBnqubKtsYZz5Vk6p09jm/MJubme4zc5q/ucRDNwmd5+XDCdCLSscieyA/YOMT+N4Apo=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:38.4867
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 2ce9d3e2-55ad-41f5-b402-08d6d3a8990a
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM2PR03MB558
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The `DRIVER_STRING` array is a static array of strings.
Using match_string() (which computes the array size via ARRAY_SIZE())
is possible.

The change is mostly cosmetic.
No functionality change.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/staging/gdm724x/gdm_tty.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/gdm724x/gdm_tty.c b/drivers/staging/gdm724x/gdm_tty.c
index 6e147a324652..81dd6795599f 100644
--- a/drivers/staging/gdm724x/gdm_tty.c
+++ b/drivers/staging/gdm724x/gdm_tty.c
@@ -56,8 +56,7 @@ static int gdm_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 	struct gdm *gdm = NULL;
 	int ret;
 
-	ret = __match_string(DRIVER_STRING, TTY_MAX_COUNT,
-			     tty->driver->driver_name);
+	ret = match_string(DRIVER_STRING, tty->driver->driver_name);
 	if (ret < 0)
 		return -ENODEV;
 
-- 
2.17.1

