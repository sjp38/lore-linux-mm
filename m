Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D702FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B72521019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="YAlgegs9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B72521019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B2866B0279; Wed,  8 May 2019 07:30:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 388AF6B027A; Wed,  8 May 2019 07:30:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2781C6B027B; Wed,  8 May 2019 07:30:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3FF76B0279
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:23 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s26so12410870pfm.18
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=2ANUS/cN4JJVZq6SdOb8BTq0Q8zTyuGFxo7xS+ekZas=;
        b=o56KmBym1Vyb8NjOGqoPAUUmCStoDFlylYcj9zG3oDzr+g13iSTYTJC7BEpT9SvzwF
         NoEBMViGhSlhsEtdiceDNq77Ykvh0cNIuU0faIj+TkVQflxgA55D6NVMO1+z9Jb60lSL
         7nYl3mIgUVWKO2qEYvz+ny4TMCP4DI1fRFS+EoeUdliD1NjmojR1sF35rDjwaUS7f8Y9
         /Rw/utT/0U0y2vcH3bSDGhY8dkP0xV+V6WG3Hl/tWOgHs/8zK5mYIrJHptdRXVvxLXrk
         pe+uavYIEb4bhnF9ZW6aOlMAaOGXZ0iE7dPviFNM+FCWZ8C7sW5lghVV4dQA5p+ZfabR
         cpng==
X-Gm-Message-State: APjAAAWBug8NlBNhIYhfcUujaT+HWzi5RP/FAPBI18ENUkd8a68XbPPg
	T+/5729YCUTgw/nbC1Dlf89odsIF0WAZZAdztPv+fwYz19/xVZX38uAMZQgeQP2Nrga9Va8E7bX
	f2/C/iNg+SKcpwukvlv+PqTgGikgQ1RkmEkfShPC4KC3HfzZWMzz4Blu+Bfh/qiNYpA==
X-Received: by 2002:a63:5742:: with SMTP id h2mr45883819pgm.194.1557315023412;
        Wed, 08 May 2019 04:30:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxRUhfCyS+1V/0HqK/iZHLJkFeVpwf8RR7td+2at1XzGa9nzp06lU0AokD7P4W0FOGyiwx
X-Received: by 2002:a63:5742:: with SMTP id h2mr45883728pgm.194.1557315022387;
        Wed, 08 May 2019 04:30:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315022; cv=none;
        d=google.com; s=arc-20160816;
        b=tKlYUiMMoTiQGO0o+tMXwpGtmABO73yj2/av6Bj8gJPNMd0RGPNg2odhZFb8Ti6bH8
         xF2nFbLr/AByJSESnSNpdARd2rwj9B00ZFHumChu1+fEGaqUz5i0tgJp1rCdg6rwjkA6
         8OVWqaxfV4o5Sf3JcJ0TxiT9MCUxNRDcuW18YfSg1ugQ1Sk1ENNNmixKxv6EzwYzC1Hb
         y65bJ4HMOH+OXz97PFo5fUdIaRchyWz+3UGVnxragifvHIUBg4cmZL7AEvcDVz+MjLJE
         2A1WpqXTfMe3yrV6Tm3qjOp4nsfpZzlkmcU/pmQbE5IwEm98Jfj9rvgZtq6rErtROsms
         SRFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=2ANUS/cN4JJVZq6SdOb8BTq0Q8zTyuGFxo7xS+ekZas=;
        b=JqcEdrwtjrkdwZeTQKs49tEXdXdN7mJ3GTlHBwFvqgJxzczCg8651Olq8mW58gFRQW
         3QveBxJ/VWK836R7j2gD9LFbKnemi6Z4ttUlWKQPduBX2U7WuRd/1T9+J2u3M19llbPA
         tfPu8vOdo8wA8e4OeqVFSG1hsPDCEY1+HPTYL5PykJeajOKNKQ3qofi1iDgru0HcwnbF
         ZmTkeCwTqr604iIu+1rMP8+bYJciNkJt3rLlCg9pQC0Cw+97nGDUJn7CnwLE9VhGrCK0
         wFqQ6VfeQ9b57nbppHPB/TM6fQPDNJJQ1eXZ7CB2lirdgVqDFprjVSsf8M9W0UOehYp4
         6/tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=YAlgegs9;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.75 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780075.outbound.protection.outlook.com. [40.107.78.75])
        by mx.google.com with ESMTPS id g3si21626353pfi.97.2019.05.08.04.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.75 as permitted sender) client-ip=40.107.78.75;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=YAlgegs9;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.75 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2ANUS/cN4JJVZq6SdOb8BTq0Q8zTyuGFxo7xS+ekZas=;
 b=YAlgegs92dk0EBLrPaSAvAEoW+a6ILmnKzEUjwH9tQEsaafIGj/Jbgvg9FfspO4AAB0mHpi+xLxqThyb3jNrDhjwFUrYCAkX4mmKxh0huvawVaQ4qJsf1twnbtqNI/QY/ocFBuZ92YZHpWBwOZalU5NYJYyYwmli40Iiko9jix8=
Received: from CY4PR03CA0076.namprd03.prod.outlook.com (2603:10b6:910:4d::17)
 by CO2PR03MB2262.namprd03.prod.outlook.com (2603:10b6:102:e::25) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.11; Wed, 8 May
 2019 11:30:19 +0000
Received: from SN1NAM02FT047.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::204) by CY4PR03CA0076.outlook.office365.com
 (2603:10b6:910:4d::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 11:30:19 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 SN1NAM02FT047.mail.protection.outlook.com (10.152.72.201) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:17 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BUHp9023779
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:17 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:16 -0400
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
Subject: [PATCH 11/16] mm/vmpressure.c: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:37 +0300
Message-ID: <20190508112842.11654-13-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(396003)(39860400002)(376002)(346002)(136003)(2980300002)(189003)(199004)(356004)(6666004)(36756003)(5660300002)(50466002)(48376002)(2616005)(126002)(426003)(336012)(107886003)(51416003)(44832011)(2906002)(47776003)(486006)(2201001)(4326008)(476003)(11346002)(446003)(86362001)(76176011)(26005)(16586007)(246002)(478600001)(2441003)(50226002)(53416004)(1076003)(7696005)(70586007)(70206006)(7636002)(305945005)(7416002)(106002)(77096007)(8676002)(316002)(186003)(110136005)(8936002)(54906003)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:CO2PR03MB2262;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 87f72335-9c22-4180-441e-08d6d3a88cc2
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:CO2PR03MB2262;
X-MS-TrafficTypeDiagnostic: CO2PR03MB2262:
X-Microsoft-Antispam-PRVS:
	<CO2PR03MB2262607B10DB5D9F45A5FAD9F9320@CO2PR03MB2262.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	cnstcSk43+prC/nm0NIlQdVDAfOh8/lZSDEOLvPEWx6u5KaV9jPZl9EcFSH7WaASPwU7+fdDNsMvmlMxhDycs0yr3rd1AFhXDzBVzxhZSOvQ0xiWbSJP7dlM8vH2TA9hrPVkJAY/nJnB9TCO/kJZeFl+F9dkyaNWFKv6+gGPtbDKP5qaktyy9MdiyFHMAJyFPoHyy/awX/7gkUHD4/3KRzk12qCmpUyAH54x75Oxy55ICCRLv533XeQ9CiOTbWpa0gaiE1ymmb3TG31mccB9fGyxe87ONr3LPKarJ/n+0poagb0PJccPHE4Tq8ZMRC89HSguBdFMiCV4kVY2RQiJIJyZ1CpB25EFDyiTdXH7OMkWGVU/rGH+WzIi/AJdCh70xavIYa8Ih81ru3cAAfjVLrgfn3Gcz3OTbKTZVQoCtp4=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:17.8821
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 87f72335-9c22-4180-441e-08d6d3a88cc2
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO2PR03MB2262
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__match_string() is called on 2 static array of strings in this file. For
this reason, the conversion to the new match_string() macro/helper, was
done in this separate commit.

Using the new match_string() helper is mostly a cosmetic change (at this
point in time). The sizes of the arrays will be computed automatically,
which would only help if they ever get expanded.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 mm/vmpressure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index d43f33139568..b8149924f078 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -378,7 +378,7 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 
 	/* Find required level */
 	token = strsep(&spec, ",");
-	level = __match_string(vmpressure_str_levels, VMPRESSURE_NUM_LEVELS, token);
+	level = match_string(vmpressure_str_levels, token);
 	if (level < 0) {
 		ret = level;
 		goto out;
@@ -387,7 +387,7 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 	/* Find optional mode */
 	token = strsep(&spec, ",");
 	if (token) {
-		mode = __match_string(vmpressure_str_modes, VMPRESSURE_NUM_MODES, token);
+		mode = match_string(vmpressure_str_modes, token);
 		if (mode < 0) {
 			ret = mode;
 			goto out;
-- 
2.17.1

