Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DDD6C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6FE1214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="q7IP+9NQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6FE1214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AA246B0271; Wed,  8 May 2019 07:30:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781506B0272; Wed,  8 May 2019 07:30:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 621DB6B0273; Wed,  8 May 2019 07:30:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDFE6B0271
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id v11so7807801ion.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=pjcT89AhZdKkG8M5isLXr+VAVcRFhlBYogTm1g/4pg8=;
        b=aEcW+qiDtg0Iat2Pr5CefSPLfpgqio5+XIgQ/K2epNTwXPGFmJGveUmhu9Z4Mufx62
         jQhrRw0u2Htu2F7svaHmYsBsQLfp41Wuk3eATJn8dlUC/V7kdueJ7CDEVsv/2yN2EOZF
         YJa6+iGo7niArqDY6kGClg/ZjCmeDz4rkkslD3ExdFtZO6+sPsymsHEZcTTw9pX8dvOC
         ug7l+lHO5wlNKU5gC11oLCr3wr+p/j1dRm5tYIA6j/6dprAlatlAkRVLR/ey7ufBtgH9
         98v0D7NRmyCyjy6mCKbIDH0UKcJCoGIneBE6EpNF8a14iQG+uI+IxtAx9BcBNo2k+z8t
         HH1A==
X-Gm-Message-State: APjAAAUdhZ+6ECGmwRa3ZVMLjyYWlm86OBiogyskeeSfKdUrq2iPaPc6
	p21zLGrllPFIDM5toSLNSJET6aTvktko1WyabMn0MRoOTXGnDGbdTuQMI02VWydgDCcjbj4a+jq
	V6U1644RO0TewpM9WQguhT+lbmRaYofMF2EekV+TYDy64Nm4MXH0tx9HgmkWIyj2CEQ==
X-Received: by 2002:a24:b701:: with SMTP id h1mr2969787itf.178.1557315003981;
        Wed, 08 May 2019 04:30:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0Lr/7/vA6TM4fThfIGJC+wKAfSImUclNDhLFqUQQfUu/shacNuWrBuCfivGYJDcx9o1DW
X-Received: by 2002:a24:b701:: with SMTP id h1mr2969744itf.178.1557315003292;
        Wed, 08 May 2019 04:30:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315003; cv=none;
        d=google.com; s=arc-20160816;
        b=OgvyqpbS5YdRA0T+FyQetB+tohsJLCbpB5ua3NwSd0fjtFdeWqm2GgqgQUyxigfB7l
         /Cfq/SgIuNMs1ETAMh4iIbrLvqV4mLqWyWbB8xhdbkGPRGwQBpWNPtSfLDW3aefdKj/A
         9CJxNCMDuxqYgsOsGQSkKTnU03Wn1Ll2xnlkX5Ylv/2yB3dPn3OQAS6toiBhCqp95E5z
         jspyEXP4Dkcl2//XYuKreKGc3UpcoG1NWCECfxOqbT7M4ws2hHm2lRboU+43srcbbzby
         ckw6XVYMEaRAY4o2YMKx3aUiYByIZFtjJYkEeV61cmmxa0cSVKAGk0MxamVry3WVIQna
         TQKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=pjcT89AhZdKkG8M5isLXr+VAVcRFhlBYogTm1g/4pg8=;
        b=FpmIC12YjxPGkSOlbio8hj/zlAKpPzHy7IIre+Em82t7bpkeiaKcBWB3V4dn1YMIqU
         FSYNGYkTerD1p8Z9qd7qDR4UnpdfzvY+gRlsRC18hUVnMVYeAPzGQI9w0wULu7GOsi+2
         2HaXoHoOuwJUwsJrwNl5RWszCtenxmN8AkxXgi2W3E8CzHC57t8a1XuE769rg7Jbft1l
         gEbFgPqqPfJPKUrHfKVpJMrjuLKujABIFZJR9Zb62CSa2MdudXkLoKQYMWMtvk0bKRK/
         7EeouumK7upixIGNU7ksZ+T4AXPXXrziItbwIC+hWuXDBYSMB4pNlE4M0KoktHWFUCib
         3Mzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=q7IP+9NQ;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.72.58 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720058.outbound.protection.outlook.com. [40.107.72.58])
        by mx.google.com with ESMTPS id s10si1727456ita.9.2019.05.08.04.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.72.58 as permitted sender) client-ip=40.107.72.58;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=q7IP+9NQ;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.72.58 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pjcT89AhZdKkG8M5isLXr+VAVcRFhlBYogTm1g/4pg8=;
 b=q7IP+9NQa5EDYubf+Njn1bcwKqmHVEVEGwgvxF4CCCebgPyhKgL87yUmH6oKqvITyTy7ly7BzqJF9CuibfYxh1CD7eVrjMoC5DQyzQjqpnGGsZvQUhXfV78CE1aOuzWdCyhisJf3G2Zqgl4Qabaoo9JYILLYMMWBWRQ5g29Xp+w=
Received: from MWHPR03CA0049.namprd03.prod.outlook.com (2603:10b6:301:3b::38)
 by MWHPR03MB3134.namprd03.prod.outlook.com (2603:10b6:301:3c::27) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.11; Wed, 8 May
 2019 11:29:57 +0000
Received: from BL2NAM02FT003.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::201) by MWHPR03CA0049.outlook.office365.com
 (2603:10b6:301:3b::38) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Wed, 8 May 2019 11:29:57 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 BL2NAM02FT003.mail.protection.outlook.com (10.152.76.204) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:56 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BTu06023698
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:56 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:56 -0400
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
Subject: [PATCH 07/16] device connection: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:33 +0300
Message-ID: <20190508112842.11654-9-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(346002)(396003)(136003)(376002)(39860400002)(2980300002)(199004)(189003)(36756003)(50226002)(246002)(47776003)(8936002)(8676002)(2906002)(48376002)(70586007)(76176011)(54906003)(4326008)(106002)(70206006)(86362001)(51416003)(2201001)(107886003)(14444005)(316002)(110136005)(16586007)(7696005)(486006)(11346002)(53416004)(126002)(476003)(2616005)(446003)(44832011)(2441003)(50466002)(7636002)(305945005)(7416002)(6666004)(426003)(186003)(5660300002)(336012)(478600001)(77096007)(1076003)(356004)(26005)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:MWHPR03MB3134;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 91c3809a-bbd8-4770-1064-08d6d3a87fc5
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:MWHPR03MB3134;
X-MS-TrafficTypeDiagnostic: MWHPR03MB3134:
X-Microsoft-Antispam-PRVS:
	<MWHPR03MB3134ADED8AEA2DE87EDA3597F9320@MWHPR03MB3134.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:6108;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	vPHqUyoLZcW0hVOhWn9GTqMZTbShobrGD2/ViAb1u/5/xckKY/lz+Bdz9sVMaISB5ZX+9BzGInurLqmM2FwjifOIAfCaB8oBwVzIS8pCv9hhyB42Iq3xXxptH5PZSBgO+M5i2dwNxoYHH/OfZkBJA5ivGIM3gJVbqng57UMMXQ2w+fpSmMh4cSgClNCxo8N5onzhk1RNY/exNSfBdSN+Djs9KjT6E9pvBp/NmRaLYmuLC6ZT+yMJ9koDYkjHuyWAEmz0HO0dNrjGBmAXW52KixyJ8drIdiD8EfBe6ovS9H4IykWVZ+zhpPAJrX7aE7bNhPgAj6OIz76YE9VndH2HHEjnLTtm3qOeMcvAav+dbYvG6K++r8veVFChlLmcP/tySHd8yyqVyS0HojCmo6O6IxxBOqhu4D25Gwq0FyInxLU=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:56.9840
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 91c3809a-bbd8-4770-1064-08d6d3a87fc5
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR03MB3134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The `device_connection` struct is defined as:
struct device_connection {
        struct fwnode_handle    *fwnode;
        const char              *endpoint[2];
        const char              *id;
        struct list_head        list;
};

The `endpoint` member is a static array of strings (on the struct), so
using the match_string() (which does an ARRAY_SIZE((con->endpoint)) should
be fine.

The recent change to match_string() (to ignore NULL entries up to the size
of the array) shouldn't affect this.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/base/devcon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/devcon.c b/drivers/base/devcon.c
index 7bc1c619b721..4a2338665585 100644
--- a/drivers/base/devcon.c
+++ b/drivers/base/devcon.c
@@ -70,7 +70,7 @@ void *device_connection_find_match(struct device *dev, const char *con_id,
 	mutex_lock(&devcon_lock);
 
 	list_for_each_entry(con, &devcon_list, list) {
-		ep = __match_string(con->endpoint, 2, devname);
+		ep = match_string(con->endpoint, devname);
 		if (ep < 0)
 			continue;
 
-- 
2.17.1

