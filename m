Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5F08C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:39:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E49E2075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:39:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="Hq4eM0+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E49E2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1CD6B0270; Tue, 28 May 2019 03:39:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A52FB6B0273; Tue, 28 May 2019 03:39:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91B6C6B0275; Tue, 28 May 2019 03:39:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 746C26B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:39:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f25so26258176qkk.22
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:39:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gWdImhCfyTIUCYzNfD1iIQYARnPSsxhTsT74g8CuXY0=;
        b=oZE8q1/fzFjIz6hdzhKWtweK2FegWB/GLi8aA3MgdqX6BjYv+IEP558h5ZMaTniD4l
         vNsRQ8SRlowJcOWMmXv4c85R14nmr5nTjHrQFwgYBK4NNGVcf4UOk4Lt69kAyxeKGOuh
         f6ARTDBfr3r4vMoOJTaZkhDCsVVaLZ7zO1jDqvA9xznhHxcGdsbkTDsbYotDSKnfSp4E
         bL8Msu0TM2o16cpcwwFI8appOxq/dHvOQSjg2ssze9ZIw9c5QS1S8aJu7QPt1r4R+3Im
         7a43KelWBXXjOJe5Aik5mq7Y/TdsxZa8eRHlcPbEWrDZbMHsvcRTX7iw5w0s2iTDhVys
         jMMw==
X-Gm-Message-State: APjAAAVPflE+QZLTH6k7JQxKlLjMIiMpSi21BK/PU39N0XL7HaIQG8xr
	x1oFo6AC/nAeT6SwDoQenPdSSkF5i17t/8cblZtk1RT2tIRxpM5ZhEhUXFZyPbot8C+r7VFZdXY
	C2rEeOtnSxNMKdNvCjQL8TRVsfb+RR0Iz6FXUEvqszTr0IC6uIUqdGldn7SpwH/T9cA==
X-Received: by 2002:a37:7342:: with SMTP id o63mr1094790qkc.161.1559029193149;
        Tue, 28 May 2019 00:39:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhMcRoRASir3PmIFq2lhk4L4NToersaVDb4KWP2TGHbDDDpVnvNxqx/LusPlwM1GFxG0Kw
X-Received: by 2002:a37:7342:: with SMTP id o63mr1094768qkc.161.1559029192555;
        Tue, 28 May 2019 00:39:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559029192; cv=none;
        d=google.com; s=arc-20160816;
        b=oVRNlKM+p4hE+jBZ55z1vO55rvBlF78+5DeArCdbzUqbdAfTYcKBeuMlIdBdgbBfbE
         EWd9nyvPWDkqlw27pxm3lbegoziYk10I8XETDfdfo/ANO+IPYzMTLYUdcly2z3EjkGOp
         RTSGkzlCzNJBZNiRuwwo+WnTd8sq1W00+EDTjyTT1wOeHK5yT+0pgSIj2wzkSRVKPktu
         whQdK4TbBHroRNpwNemi+4q28+f8Iby6ZkrL9KM0oxqw8K+6pCqSyogcxH8CeLOtdbKW
         AqvJwxXGcFOIo0zRd8GSv8YcBtjV/dt81B/I+6lLk+lIjTeUGl7Q4V/0bNm+3nMaJaYl
         OeWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gWdImhCfyTIUCYzNfD1iIQYARnPSsxhTsT74g8CuXY0=;
        b=Lf3xbTKMPPEL9JwQCI4ur5fxWnSGqnnFIzEyPdz4M1cVoFfuue1En+y5HOLjMt3F7G
         YrAlmvvDbUtwJ5FK2hkiUMeu3mm20Dur5EvZ02nSdh06HrXSsOD8hpP634Nvr4Dk3C7t
         C743fjQoiYAgKknomZZMe9SiW3WY0UDxbqvXpfeZ5Ok4+e0HX9r+jgPeDaG0SuSY6cc1
         mQubG2ENV6Y0kXsiEoUY88EvNtU8/upbXJu1RLvGQtBMLBjPC4wMlVduM9bf/X90LT8z
         gaDlmGep0L7spuczthsm13dvzjQAxpKmN0DlZvH9Py2jmRyE72Srls9/YtsEfAAhEFnG
         A5sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-onmicrosoft-com header.b=Hq4eM0+Y;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.40 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740040.outbound.protection.outlook.com. [40.107.74.40])
        by mx.google.com with ESMTPS id y3si3824803qvi.30.2019.05.28.00.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 May 2019 00:39:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.40 as permitted sender) client-ip=40.107.74.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-onmicrosoft-com header.b=Hq4eM0+Y;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.74.40 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gWdImhCfyTIUCYzNfD1iIQYARnPSsxhTsT74g8CuXY0=;
 b=Hq4eM0+YUiVIoYHYAGGuEpOyjhWPdcPFHxn0lkng78s7kuN0jDXksfvZQE0kEOvNPTuar+4Cwfyt9c47tyog14C+ba401xryJ9s5hnJiPDekCnghCGKZj4HeQKs4EbPbnH2B4kKA0p9wn6It0lmbB4CJ95H2YYd7PUpoLM2vyVQ=
Received: from BN6PR03CA0012.namprd03.prod.outlook.com (2603:10b6:404:23::22)
 by BL2PR03MB545.namprd03.prod.outlook.com (2a01:111:e400:c23::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1922.15; Tue, 28 May
 2019 07:39:47 +0000
Received: from BL2NAM02FT030.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::202) by BN6PR03CA0012.outlook.office365.com
 (2603:10b6:404:23::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1922.16 via Frontend
 Transport; Tue, 28 May 2019 07:39:47 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 BL2NAM02FT030.mail.protection.outlook.com (10.152.77.172) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1922.16
 via Frontend Transport; Tue, 28 May 2019 07:39:46 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x4S7dkpQ023241
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Tue, 28 May 2019 00:39:46 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Tue, 28 May 2019
 03:39:45 -0400
From: Alexandru Ardelean <alexandru.ardelean@analog.com>
To: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <linux-ide@vger.kernel.org>, <linux-clk@vger.kernel.org>,
        <linux-rpi-kernel@lists.infradead.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-rockchip@lists.infradead.org>, <linux-pm@vger.kernel.org>,
        <linux-gpio@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
        <intel-gfx@lists.freedesktop.org>, <linux-omap@vger.kernel.org>,
        <linux-mmc@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>,
        <linux-tegra@vger.kernel.org>, <devel@driverdev.osuosl.org>,
        <linux-usb@vger.kernel.org>, <kvm@vger.kernel.org>,
        <linux-fbdev@vger.kernel.org>, <linux-mtd@lists.infradead.org>,
        <cgroups@vger.kernel.org>, <linux-mm@kvack.org>,
        <linux-security-module@vger.kernel.org>,
        <linux-integrity@vger.kernel.org>, <alsa-devel@alsa-project.org>
CC: <heikki.krogerus@linux.intel.com>, <gregkh@linuxfoundation.org>,
        <andriy.shevchenko@linux.intel.com>,
        Alexandru Ardelean
	<alexandru.ardelean@analog.com>
Subject: [PATCH 1/3][V2] lib: fix match_string() helper on -1 array size
Date: Tue, 28 May 2019 10:39:30 +0300
Message-ID: <20190528073932.25365-1-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(376002)(396003)(39860400002)(136003)(346002)(2980300002)(54534003)(189003)(199004)(70586007)(70206006)(2441003)(8936002)(47776003)(7416002)(107886003)(316002)(2201001)(8676002)(14444005)(2906002)(2870700001)(86362001)(356004)(51416003)(6666004)(7696005)(26005)(305945005)(7636002)(1076003)(478600001)(36756003)(4326008)(110136005)(2616005)(126002)(44832011)(54906003)(76176011)(48376002)(486006)(476003)(106002)(50466002)(446003)(11346002)(186003)(50226002)(7406005)(426003)(336012)(53416004)(5660300002)(77096007)(246002)(921003)(1121003)(83996005)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:BL2PR03MB545;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 6c76f02a-34d6-47de-ba0c-08d6e33fa89e
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(4709054)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328);SRVR:BL2PR03MB545;
X-MS-TrafficTypeDiagnostic: BL2PR03MB545:
X-Microsoft-Antispam-PRVS:
	<BL2PR03MB545CA0A06BB0E64A1EFBE91F91E0@BL2PR03MB545.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-Forefront-PRVS: 00514A2FE6
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	WYQoPPTo42AknDYSpY9w/xftF7FT7SRtXtbzi4SohjgnHD5P3hVPp3WTmUFaLfcDpBMThORg4NphooGNDC9igOh5UCY+z/qJehstorHN6dXF0JXfvmEyhD606e1CCgn1vUccxto/xRVdXdjRcRHavbu1mYcyAlmvTmEDKuQrxdfC1Vrm8H9/tkgoumu/npzY4P0Eyoj1Hwx3z5/P2OctimPreVyglKaTNX/j7lM7XosmVhLrWYt/TLXycti79mDqjngT5xwxZMvszzx4GLzrMAGI+oe486mPjGQdr4mkGPORfalJMEV5ae4/UIaivCRaqH3nuCzPeZes99dzedzF7DJd9vUvbhN8XxbI4NVjhC5LKkww2k/x2hqF8pFkOcddaQzB5rfbyVzu+jJvUQ8J9ZT6v/eq/Une//VX7JZ43bw=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 28 May 2019 07:39:46.9658
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 6c76f02a-34d6-47de-ba0c-08d6e33fa89e
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL2PR03MB545
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation the `_match_string()` helper mentions that `n`
should be:
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

Changelog v1 -> v2:
* split the initial series into just 3 patches that fix the
  `match_string()` helper and start introducing a new version of this
  helper, which computes array-size of static arrays

 lib/string.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/string.c b/lib/string.c
index 6016eb3ac73d..e2cf5acc83bd 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -681,8 +681,11 @@ int match_string(const char * const *array, size_t n, const char *string)
 
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
2.20.1

