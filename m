Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C15FBC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7524521019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="OQVIVgK5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7524521019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C7B6B0273; Wed,  8 May 2019 07:30:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 202796B0274; Wed,  8 May 2019 07:30:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07CEC6B0275; Wed,  8 May 2019 07:30:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC94B6B0273
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:09 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id m207so7030190oig.4
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=TppapvdTdEWShhGPGCPSH9uz8QgU5Op8E8ytcSMFOwg=;
        b=bnMeMZtZSJbnEk97l2BVTEIs/NMZxYDxLfNPa6LX1T6oUxNiAvkChcH/2AMOAzvLs4
         AhQvTjEFahTWFnF4KnwTPPSlowmgHmUyYeebFXDme5bCuN8+SD1NBYHChIrLjjzn1jOf
         Frj/edPB1ygGLkVBNX+Wctt3jZyJCkXHRhR7jkJv+Tm+1+3R1fRBZtlTZrjQRDI8OuEy
         S4Mzkus8Yz2rIo5cl06UpxKj7ZBdQh9jV+taInU0eEUqVcQ6zZ4bJGiZi6ma3dmHDkHF
         m89gm6+Sp/RGrfjC/7MyXKlFcBj5XkyQ1KUb6OBL/sBAIZdncsp2VJYYlRVA6sePo7jG
         pY0Q==
X-Gm-Message-State: APjAAAUdKXitTxBVBZ3kfpDynfLNpkVxLyrWQ73lJ/5ZuYUSi1/L2KSI
	bSkS8B8nLDIe4d/2EfMyCSLpVx2NhBpPpA20caMw5dDh39SUjB+hYF1vvnjRUOKWVd+8DsWa/ID
	O9lzJiwVEFEcuN2aAytYUrqMFJninDd/aqcIDDTxpRqcbnDoM9ld1/3WOU9lbX4yBRA==
X-Received: by 2002:aca:3d89:: with SMTP id k131mr1213244oia.37.1557315009553;
        Wed, 08 May 2019 04:30:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaP2ekh8fDFfxM6MJtiQfuMxGBZi3l6y3xW1zWtA4xwrSN+WTjRjorYKBnFM/8vXjQXA82
X-Received: by 2002:aca:3d89:: with SMTP id k131mr1213193oia.37.1557315008343;
        Wed, 08 May 2019 04:30:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315008; cv=none;
        d=google.com; s=arc-20160816;
        b=sG65As/mGIShHkNDQ59IgINDZBPzE7oMES4wgakLiPsii6KpGA8jcYqdRottdB94zc
         X1VQD7nGtsAzMjpKXL247kGHwus1eIsylGM7bH0z4lWyeXZr6XO/BEfsMSZxnZeUGmaw
         AWAx7CYw/aRaGPO/0gZ5oIMR4xdu8M4bioId8bRVGMp3vwmpA/y9iuRGDVhAi+H1x9qb
         7lqsKZn+YDtiA9is7RjiSEVddg4+SPX0jswL85+XCzpTzLDcVOWVEOK4kt0TJ0vpIQY1
         V99tb/Nu1wkukMeDTl1ra+ESIE01QvP7iABd78YXdO/akhU4JnvQVasQSLSiyiINEyIU
         vGJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=TppapvdTdEWShhGPGCPSH9uz8QgU5Op8E8ytcSMFOwg=;
        b=gwPyhKZRYbSqD5s0V0fkpdbnSmYOkUDUJAgKBcdlULzo77/2PW3CXZRkiStsQC9Kjk
         PVfDPlcHelrvnaojIWyJ9ot7fr9I7xHeAaqYHxiEVThp8hQUdYI3UAm7D8vbwYcTjX5K
         5E7Ir3h/lUmcW8pPJuRDh++f/ohUV3DnFOiDRva23oHbnF1aKi6oDkw3bP3Vh1a6fRNn
         qTbO02cDzvDk44/BeUOeWebDDUVS4uKWzLpEn+scBOO43vd/LnxiXIUt8qODYnarm4cH
         pN6ZbIjnERfkrqYjxqaOawuosIcFzAD1ZAFHFaiP/9DvBHWKRYLR8XqkClHgkLODghPt
         /4+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=OQVIVgK5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 2a01:111:f400:fe49::624 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0624.outbound.protection.outlook.com. [2a01:111:f400:fe49::624])
        by mx.google.com with ESMTPS id k19si10160683otl.158.2019.05.08.04.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 2a01:111:f400:fe49::624 as permitted sender) client-ip=2a01:111:f400:fe49::624;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=OQVIVgK5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 2a01:111:f400:fe49::624 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=TppapvdTdEWShhGPGCPSH9uz8QgU5Op8E8ytcSMFOwg=;
 b=OQVIVgK5JxJMqIfsuBpJyNhsOscNjrf8QoWcS71HKHv5ECSFl4t6qL8cjbEvHO9onyxqCP7Eiq7Wxh8YLQX/ufSvCV0VABMsC9ZaqNqGS8uuuvsMFWUm0Wa0qvupkiH+emRfafnbKdPIl4OkQQXlSvhfm9OK1pHqR4K81+Fv0Z8=
Received: from CY4PR03CA0091.namprd03.prod.outlook.com (2603:10b6:910:4d::32)
 by BLUPR03MB550.namprd03.prod.outlook.com (2a01:111:e400:880::28) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.12; Wed, 8 May
 2019 11:30:03 +0000
Received: from BL2NAM02FT017.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::204) by CY4PR03CA0091.outlook.office365.com
 (2603:10b6:910:4d::32) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Wed, 8 May 2019 11:30:03 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 BL2NAM02FT017.mail.protection.outlook.com (10.152.77.174) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:02 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BU1rk023711
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:01 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:01 -0400
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
Subject: [PATCH 08/16] cpufreq/intel_pstate: remove NULL entry + use match_string()
Date: Wed, 8 May 2019 14:28:34 +0300
Message-ID: <20190508112842.11654-10-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(376002)(396003)(136003)(39860400002)(346002)(2980300002)(199004)(189003)(8676002)(77096007)(47776003)(50466002)(50226002)(26005)(478600001)(336012)(51416003)(186003)(2616005)(1076003)(2201001)(7696005)(246002)(426003)(86362001)(110136005)(106002)(305945005)(126002)(16586007)(446003)(2441003)(316002)(11346002)(54906003)(476003)(486006)(36756003)(107886003)(76176011)(53416004)(8936002)(5660300002)(4326008)(7416002)(356004)(6666004)(7636002)(44832011)(2906002)(48376002)(70586007)(70206006)(921003)(1121003)(2101003)(83996005);DIR:OUT;SFP:1101;SCL:1;SRVR:BLUPR03MB550;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 86204a62-8a3c-4b5a-9dba-08d6d3a8834f
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:BLUPR03MB550;
X-MS-TrafficTypeDiagnostic: BLUPR03MB550:
X-Microsoft-Antispam-PRVS:
	<BLUPR03MB550ACAC1A7934C08542BCC1F9320@BLUPR03MB550.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:541;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	rxv/XoCD6aaHG0TrRZkKWXDRcX000pKd7bfq3vJ62ePHcuWPHuGNJPBOqwgOijZqx3E8HU+x999IZl+ba88JfR0vYIb7Obj0j1eZUKusZuk8BQ/3y6BrYo03I2LI4DxBWK7qu2MZ9Itfu0i5LUpmIJtONUQwaJE75922TD4j9KqTqEJtt7Oe/4c20rd7gXAxLMfmFvG64Cz4/6AKOCc11G5CrFVaAO+gYxZukEzvn6JfBa8EqYvBAsn6lRm+PFLP0hqCZn/uR2nN9VOclRHqQPxm+Va0rH6apLh63EtDW7LtpBEfmUsSBBtIhzfYTLNJ1UfI6Mz02xdbaV19/8eub1YBOgpTClnEpYZAmVHWy3iJ9vzMVWpkffbsdAGUPXMahcgSR5z55fgI7Obs6j3WIQGQdzC6GP62894A4z71zMk=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:02.9332
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 86204a62-8a3c-4b5a-9dba-08d6d3a8834f
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLUPR03MB550
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The change is mostly cosmetic.

The `energy_perf_strings` array is static, so match_string() can be used
(which will implicitly do a ARRAY_SIZE(energy_perf_strings)).

The only small benefit here, is the reduction of the array size by 1
element.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/cpufreq/intel_pstate.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/cpufreq/intel_pstate.c b/drivers/cpufreq/intel_pstate.c
index 6ed1e705bc05..ab9a0b34b900 100644
--- a/drivers/cpufreq/intel_pstate.c
+++ b/drivers/cpufreq/intel_pstate.c
@@ -593,8 +593,7 @@ static const char * const energy_perf_strings[] = {
 	"performance",
 	"balance_performance",
 	"balance_power",
-	"power",
-	NULL
+	"power"
 };
 static const unsigned int epp_values[] = {
 	HWP_EPP_PERFORMANCE,
@@ -680,8 +679,8 @@ static ssize_t show_energy_performance_available_preferences(
 	int i = 0;
 	int ret = 0;
 
-	while (energy_perf_strings[i] != NULL)
-		ret += sprintf(&buf[ret], "%s ", energy_perf_strings[i++]);
+	for (; i < ARRAY_SIZE(energy_perf_strings); i++)
+		ret += sprintf(&buf[ret], "%s ", energy_perf_strings[i]);
 
 	ret += sprintf(&buf[ret], "\n");
 
@@ -701,7 +700,7 @@ static ssize_t store_energy_performance_preference(
 	if (ret != 1)
 		return -EINVAL;
 
-	ret = __match_string(energy_perf_strings, -1, str_preference);
+	ret = match_string(energy_perf_strings, str_preference);
 	if (ret < 0)
 		return ret;
 
-- 
2.17.1

