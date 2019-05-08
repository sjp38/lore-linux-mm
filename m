Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D440CC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A2D1214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="DrUwW+Hf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A2D1214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A1DC6B0276; Wed,  8 May 2019 07:30:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278166B0277; Wed,  8 May 2019 07:30:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13FEF6B0278; Wed,  8 May 2019 07:30:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E215F6B0276
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:18 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z2so9602582iog.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=1chwJ3hc4UTJ3blAlYUngE824WdNkP//hIXWmk1Ja8A=;
        b=qKGSlanl+nXWAMy+Rhdm6HALJ3aTcjyIccNz0y0UV54BojVfDXKpfD3ml1E9wIRYjr
         vKiWyc31kBrNWEqnD8z/UNaBJi+dpq9WR34Qd5mPR52yisC6odiEjTWnvyuETOURNXR8
         dOsqT/fU7klY7GBBJh14EUWOVrSCAif+UjTpZg8GShd1ylUpV1zFPKoqyKQNpjCX0rpB
         UpKX8SxD82wejrZvJoYepqPu2aKdGRocBHyAry+HzJ/z1Lc8fFwTWKYBI1NJG4FzUmTV
         y9wXufEAhr91hJdHDZB+5VgyG9WSqHUvjNA+3cKGkMaFvF1zM2caQWFl5oUX3kpFkJC1
         2CUw==
X-Gm-Message-State: APjAAAU/ddHFe2H81BuvcGsZOGvgq1xiagee/2n6Qy6fNt28dSOUQXd5
	HA/uOi4CDK2X2XhJM1etvb2chzsoUFmIeAZ+iYDmQBRgRkYGv02EciAPiTItRuYntX7sMSjafY8
	kJNUFuV7Xu54jAQQIpXSDc0Q+OXuRt3i1IAHiMOibz7vDuh5m5TJaxLY21P3dNFDp9A==
X-Received: by 2002:a02:83ce:: with SMTP id j14mr27590819jah.61.1557315018622;
        Wed, 08 May 2019 04:30:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIKWUJT15uDUaSDrqrMIIjBWJTvbO+9f2fCPxPQ9CpX/YUNetMDKZbwRfZ/ocY/S9GMqJk
X-Received: by 2002:a02:83ce:: with SMTP id j14mr27590722jah.61.1557315017084;
        Wed, 08 May 2019 04:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315017; cv=none;
        d=google.com; s=arc-20160816;
        b=KS7EQGLGB8+eWwXHMCYSOge/PlSRNEZOknKJg519pUmbTtkagMhxin95UnmHWoeisJ
         gDlqa984655AKr8ZJiSnoh9xDicVmYOCiXVG7o7rmB9pdqJAGMqc17wNN3VR2OX/NnAq
         wO1Kxo6C/jyDytasswJlxxe2f6ZZq29kN3taOykMgrdD02OZ2GMQBMEwL+t226I3Yj9V
         xKzwnKq2RLX8+cuDBhHJMpH6WkNAoV+SivV0rrf5AfffU45moQEq7QTNp4nHphJWI2vC
         zzV9HA2VgVdxeNipFLnjKuRr2S2N5tbN8VUtubc+zezm0uzloPEca3h92U2TH4tj1TZg
         BNVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=1chwJ3hc4UTJ3blAlYUngE824WdNkP//hIXWmk1Ja8A=;
        b=kgxdyvat85n8NNQ6xoFQL+aHk+XNt902ekyJAQdDuMBKtZB4eAe+67KanvqhT0VUMi
         HfJ4OOCBakms8bihkuEXN6kaGJHTnXT915NNZAWxHWZ3IT8GK+aGEMixuBCseWQvfe1N
         SfzkagvgXk7owf5FOd04iyQAtRkZzINdlKItHeh/sn6qqlK3h3WSgJXlfyaw2yOYWhEW
         yftgwwgJBRn1QKb/BQ8l4xBvYvG4Hx5OggYjn+A+6w+OLtTdyXqyljTgP/EWah3Xge/V
         Ijbh2ewuDXvqk0y9XxHBV7ZOGPT+WmUrWXbQO3TEA06tSO90CDtj/xdaVKbOuW17JO2K
         p6NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=DrUwW+Hf;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680071.outbound.protection.outlook.com. [40.107.68.71])
        by mx.google.com with ESMTPS id k13si13528683jah.101.2019.05.08.04.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) client-ip=40.107.68.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=DrUwW+Hf;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.71 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1chwJ3hc4UTJ3blAlYUngE824WdNkP//hIXWmk1Ja8A=;
 b=DrUwW+HfBrwsEl2in+cz4S+PdeJEOhXU7fVfQQf7K1/7Bu4CQyX95NdYXd/oxxKLzmfA94Sp9RgysVQgxHHyK+aXVQgutw8CgBlEx5J1hG33ICxZPO0+0bHw7kb6PXGJmCSPuSxrDr+dHRaQH2ilSb5oPUIKVnknHgETTrV7qvg=
Received: from DM6PR03CA0001.namprd03.prod.outlook.com (2603:10b6:5:40::14) by
 SN2PR03MB2272.namprd03.prod.outlook.com (2603:10b6:804:d::17) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.10; Wed, 8 May 2019 11:30:13 +0000
Received: from SN1NAM02FT003.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::203) by DM6PR03CA0001.outlook.office365.com
 (2603:10b6:5:40::14) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Wed, 8 May 2019 11:30:13 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 SN1NAM02FT003.mail.protection.outlook.com (10.152.73.29) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:12 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BUBS3023758
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:11 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:11 -0400
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
Subject: [PATCH 10/16] pinctrl: armada-37xx: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:36 +0300
Message-ID: <20190508112842.11654-12-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(396003)(376002)(346002)(39860400002)(136003)(2980300002)(189003)(199004)(50466002)(126002)(70586007)(476003)(246002)(106002)(2441003)(36756003)(478600001)(5660300002)(2906002)(70206006)(356004)(6666004)(44832011)(305945005)(53416004)(16586007)(446003)(11346002)(7636002)(316002)(2616005)(1076003)(486006)(51416003)(426003)(8936002)(7696005)(50226002)(336012)(2201001)(48376002)(107886003)(8676002)(86362001)(26005)(7416002)(4326008)(54906003)(110136005)(76176011)(186003)(47776003)(77096007)(921003)(83996005)(2101003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:SN2PR03MB2272;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 54ae17f8-e934-4104-71ba-08d6d3a88946
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:SN2PR03MB2272;
X-MS-TrafficTypeDiagnostic: SN2PR03MB2272:
X-Microsoft-Antispam-PRVS:
	<SN2PR03MB2272F1E636EAB1142DBF6EF8F9320@SN2PR03MB2272.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:221;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	xfAt8yPIASeIU4SWpAqv7wYVf6rgReoRasBfXu5VkYF5De6r3ChaB98QtwmzFohT7XLUcZv/paBIBGQNzEFCX/rtqn6SNp5cB2YDe1+lv35blIEB09SYcVLlHsYG9cnjNobxye4mP+4dqP11iC3pADRTivOXvbA+Tp0kI3oa4q5J5BL/KnwnnV9B5YLYrUzgEVd4bfoVd7faUQkPXj/dE3Vaf7ISG1AGagwFjfSKKsCgRru7kvI+k/bvrGow8wB5BEPLRNA7GLImCROlk0ZyBozdsEtLuar+oZzScBl6Q+M52D0eHyDc06BKyfl3wepAHxzTYDdZ5odpexJoia97/Y2agzfCyaYjbE1Nby4ArE3NQ7GcIz5zZeXT3zQbIOkDzZYrDXqhS0aaP4Yn31I6ed817wNoRQ0uge0Z2pdkt6I=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:12.0247
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 54ae17f8-e934-4104-71ba-08d6d3a88946
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN2PR03MB2272
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The change is mostly cosmetic.

The `armada_37xx_pin_group` struct is defined as.
struct armada_37xx_pin_group {
        const char      *name;
        unsigned int    start_pin;
        unsigned int    npins;
        u32             reg_mask;
        u32             val[NB_FUNCS];
        unsigned int    extra_pin;
        unsigned int    extra_npins;
        const char      *funcs[NB_FUNCS];
        unsigned int    *pins;
};

The `funcs` field is a static array of strings, so using the
new `match_string()` helper (which does an implicit ARRAY_SIZE(gp->funcs))
should be fine.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/pinctrl/mvebu/pinctrl-armada-37xx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c b/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
index 07a5bcaa0067..68b0db5ef5e9 100644
--- a/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
+++ b/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
@@ -348,7 +348,7 @@ static int armada_37xx_pmx_set_by_name(struct pinctrl_dev *pctldev,
 	dev_dbg(info->dev, "enable function %s group %s\n",
 		name, grp->name);
 
-	func = __match_string(grp->funcs, NB_FUNCS, name);
+	func = match_string(grp->funcs, name);
 	if (func < 0)
 		return -ENOTSUPP;
 
@@ -938,7 +938,7 @@ static int armada_37xx_fill_func(struct armada_37xx_pinctrl *info)
 			struct armada_37xx_pin_group *gp = &info->groups[g];
 			int f;
 
-			f = __match_string(gp->funcs, NB_FUNCS, name);
+			f = match_string(gp->funcs, name);
 			if (f < 0)
 				continue;
 
-- 
2.17.1

