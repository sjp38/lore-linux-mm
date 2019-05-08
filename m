Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37A9FC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE7B721019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="OsAPAAdK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE7B721019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33D0D6B026C; Wed,  8 May 2019 07:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ED1F6B026D; Wed,  8 May 2019 07:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5076B026E; Wed,  8 May 2019 07:29:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E40356B026C
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:29:47 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 18so7592267otu.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=x+Io6nQDgXXj6vWzapFXKhuWEwCuQ7uYG1o8foVltUs=;
        b=kCH3zvndBZlpdpeykMVdgscMlgtnINQ+leByiU+xlhPc5X3DVm3UDm292YjigAc2Yr
         liZuWkpz6btwJ8ixgxEz41KxJaiAWBAKFi2qa3w+KRFEHaBgizkfv9250livL8D+bFMO
         IL/5bq6zRxiMTfdEuJBad9RQlUca6wOM8Gi/F/fwhZKncaLSaTv/+t3fPwEXPoGMIvn2
         pTpgx6SygU1YxNL1dMXxzJ+iS8Vr4+ammKEE+cw/y/zQGNkrNRzL4Wh9E+iAcylf478c
         PgcAaMHVjylYE6BkDKwozsFQSKGimsumFculndArvPJ45pe1QeKT2VLWnV7CQ9s2tAZn
         XRjg==
X-Gm-Message-State: APjAAAWMMYcfvVA0bucS+DBoEUtPgGcjR1GSwD0yxg96p/8vdS+l1ZOg
	s2+OUeNnPySCz4Bk+PDpvi1D/qnf1bJUDZ9Hf/yTTkFcnmbwHM8+Gz/E3UoPvQr+cE6jRklK5Sn
	/BaS+DLKhJw56Hj6wAsuuFWllzWfpXslRQ7FfMM53kygmWxv04XxDb3+j+04BsIfNfQ==
X-Received: by 2002:a9d:760b:: with SMTP id k11mr9068555otl.135.1557314987663;
        Wed, 08 May 2019 04:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/sYnLTmB14/bIs4LTwjnZUDLSqWKpd7/qQvekKHrSJplaUZ8VYr/k3WowdbqOF4J+B9hN
X-Received: by 2002:a9d:760b:: with SMTP id k11mr9068517otl.135.1557314986906;
        Wed, 08 May 2019 04:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557314986; cv=none;
        d=google.com; s=arc-20160816;
        b=qOCSkSxjCSQ3NLQEC+OaDqu+YwV+TKoEQ8XhYbGsTAPZCBMeT22J0QiffuBQ2DulqH
         D4U8XPziZVayTvCPuD90tt+atUXE+e0iidGRvgauxLdavgs7qpYZVXST2ryyanCWKFO5
         QMZ3Qyt3nYSrYWjcW6Ndaa4sV6/EKTbTObuAfFjNmuH/bBk5Ht58TinHpM1mXnlvVLHP
         GMlr2l0b0MqSP+HIubpduLrhbKYeFmgPMW7Df980c8vESgGaYIiKIF3nFAP5j0wTnuxL
         xhSH3L/gLbR376Dcv+V94X0wSqAsX6Bra04oUri44enqtkpC0l6tPnb7nUMTaTOPIcQv
         cdPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=x+Io6nQDgXXj6vWzapFXKhuWEwCuQ7uYG1o8foVltUs=;
        b=pevwv0bkEiEU0lmedJfZHp8oUEAMYQjOpBuiYKDPK2GsYo59thoDUEE9Hbg4ZSPh1o
         FnBf/WMbvPpAGD8BZ037aFeG+rUaPLdd3BMJFm1+ByfQdeBcaf3t669HaRWr/HssTfdS
         TLq6DxL9oUpyf/VPzmKjnHTBL+RM8SJ4m83HTx5JQlCmsCHy6Ovdive7FFctm5OOXAS9
         bG1GJsjqa7eAjEUx55Rjzg/qXn3qicsUodTmE6/bgUx/J6R3qh+YuR/TycKeFPg9TBks
         +8uIjOTj5fdF6udcjEU5fgyZZrJ7RWlDNzvBrLrnc17A9FS618aBNYTrrc/kg0dcV7zM
         XIaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=OsAPAAdK;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.51 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780051.outbound.protection.outlook.com. [40.107.78.51])
        by mx.google.com with ESMTPS id h61si9851257otb.149.2019.05.08.04.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.51 as permitted sender) client-ip=40.107.78.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=OsAPAAdK;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.78.51 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=x+Io6nQDgXXj6vWzapFXKhuWEwCuQ7uYG1o8foVltUs=;
 b=OsAPAAdKA72ag6WEgtGuMxKaWxQ0gZIzCPsuAtgnnj/oFA0fbDHMGodRBcRefG9XbOE2g+Aq3eXHAUOgRsxbe9OUern7w4ZEKU1MFVRM944jQ4MmmTvJjEX5JVN0ZStKQwnZjTEaE6iWfqxBEGLRi5kjF9g1i+IhSA13dB4Oi0w=
Received: from BN6PR03CA0015.namprd03.prod.outlook.com (2603:10b6:404:23::25)
 by SN2PR03MB2270.namprd03.prod.outlook.com (2603:10b6:804:d::15) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.10; Wed, 8 May
 2019 11:29:43 +0000
Received: from CY1NAM02FT047.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::203) by BN6PR03CA0015.outlook.office365.com
 (2603:10b6:404:23::25) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.21 via Frontend
 Transport; Wed, 8 May 2019 11:29:43 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 CY1NAM02FT047.mail.protection.outlook.com (10.152.74.177) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:41 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48BTenk017131
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:40 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:39 -0400
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
Subject: [PATCH 04/16] powerpc/xmon: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:30 +0300
Message-ID: <20190508112842.11654-6-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(136003)(346002)(39860400002)(396003)(376002)(2980300002)(199004)(189003)(76176011)(7696005)(356004)(6666004)(70206006)(51416003)(316002)(7416002)(2201001)(305945005)(7636002)(107886003)(48376002)(47776003)(110136005)(16586007)(4326008)(2906002)(54906003)(53416004)(106002)(11346002)(446003)(14444005)(36756003)(478600001)(2441003)(186003)(486006)(50226002)(126002)(2616005)(476003)(86362001)(70586007)(50466002)(336012)(8936002)(5660300002)(1076003)(4744005)(426003)(77096007)(26005)(44832011)(246002)(8676002)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:SN2PR03MB2270;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: dfbd6645-f3e1-49b6-1450-08d6d3a8774c
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:SN2PR03MB2270;
X-MS-TrafficTypeDiagnostic: SN2PR03MB2270:
X-Microsoft-Antispam-PRVS:
	<SN2PR03MB22702A36CFFB4F24671124AEF9320@SN2PR03MB2270.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	KBaFP+VndcR4Pf2Avf8+W37sHaN8ZZJBBrWfHnFJ8l4xSH7jQGBdDEcnqagJMKs/oHbr9oYooJZUU4xkacMNv18LLG29wwpx6s6jnKluGmQRA4ewJoO4MJMNLnrj+iEP9+WvVm59vBhxTahQbM7N1ZvL80PXwnLkgR8siCzsyJn5Q9X+sxi8zBFAfc3hej5rkB8PZzkxpkMenJqsj2UIckP4SpNwF+OwyJqZITPx+vJWrk9s+k2seUKSvdSE3UyHHJZZuFbdM83NjlN0sSgLj3ONDOP7mfDlxwMMTiSqV4jdRLFHtNH5oVVbb9KCyE8DTMthgbJCPwDGxxN7b7yMODPWnGCw87W2rP6OrHNOLedXGqVbjL3JmBd48mSrS51VpGb77n/hBi2fRQlG4kD6/k+SqAT2KWOmnMUL3fQ2Hos=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:41.2805
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: dfbd6645-f3e1-49b6-1450-08d6d3a8774c
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN2PR03MB2270
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The change is purely cosmetic at this point in time, but it does highlight
the change done in lib/string.c for match_string().

Particularly for this change, if a regname is removed (replaced with NULL)
in the list, the match_string() helper will continue until the end of the
array and ignore the NULL.
This would technically allow for "reserved" regs, though here it's not the
case.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 arch/powerpc/xmon/xmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index efca104ac0cb..b84a7fc1112b 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -3231,7 +3231,7 @@ scanhex(unsigned long *vp)
 			regname[i] = c;
 		}
 		regname[i] = 0;
-		i = __match_string(regnames, N_PTREGS, regname);
+		i = match_string(regnames, regname);
 		if (i < 0) {
 			printf("invalid register name '%%%s'\n", regname);
 			return 0;
-- 
2.17.1

