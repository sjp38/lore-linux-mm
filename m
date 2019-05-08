Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 147A5C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9493F21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="qQfQKlBU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9493F21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CDB46B0003; Wed,  8 May 2019 07:29:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07CC06B0005; Wed,  8 May 2019 07:29:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E85FB6B000D; Wed,  8 May 2019 07:29:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3F416B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:29:19 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id g8so10901278otq.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:29:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=9mREEcazEV2TFx5JIFnH3pAzE1JX52Mxgf7Nke2hFVA=;
        b=Dn6kTDikQtxYMnMRP6/+viw3vC6UG+uqFNeq+JdrYr3wC+ceE5MvV7+9+2tWqwWt09
         uRjiXQLsOyP4yYkNeIm+ORxFfriV7zoF14nvr6t5yOpqnC1jmKEX9Xu4FGm4NwzXXGc5
         DxqVyDEsw0MuJNyobX3VSNog0TmkX14UOsLP1hlxhfGSeLODTOgWbfqOxtsKMHvwlzYl
         w14STCREjhn77EfCzF/nVch0ZHm1p1Mv4Eq6q1DtCYFhahu8g/aBa2kcWGfF8SYda84k
         nlNOmrJH6Fc0L502pBJt891LyJhNHVMtFl/4V1pl9NY+1ef7uLC5LTQCc+vsXHaIXwtI
         qVIA==
X-Gm-Message-State: APjAAAXrS1gE5R34UH0Q1/2ys1j7ZvpCubN6g/6UlQvN9WqsXUYqTXBa
	0yBzCDONkYOTqyNAVtmJRnyRo0Gb9wuFOJWZfk6Az8WDbVnPe5OMbVAS/tbt4oifFesI/wUq5G1
	TOifPaKRCpkD/KGDcjL/20UJJ7l94P0GRJDq9JRZwo0dRQcL+hQ/H1Frq1Wqx46tqzA==
X-Received: by 2002:aca:418a:: with SMTP id o132mr1959156oia.16.1557314959290;
        Wed, 08 May 2019 04:29:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycS6YGMQFdQYEOLJB3COvv/p6tyYVT1kPIO2KeWDnLPzTteiU/KMn7IYICvZCD33R2JDRX
X-Received: by 2002:aca:418a:: with SMTP id o132mr1959070oia.16.1557314957634;
        Wed, 08 May 2019 04:29:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557314957; cv=none;
        d=google.com; s=arc-20160816;
        b=oAHeFyB4m2b9g9F0FYOR1YxzxOZsIykOnfqBlN8zKcE8Xc1JMyMWXxZkGrD8odVPsX
         VrlplPYupLM/Wne3ie96E4Jj5mxBndm2yuBuM7JaqtpO2KmC8ZAidrkOnBbRxQH38PTa
         lwKfEz4rtYGuzuO5L7xMNe4mzvttEQX1THjoKU9IqCw7D66+xh7cUOKrzBq6O72bUqFt
         l0Yy5nIHndb0hGh6pd6XjMrk+lpzmxyd8WPi7HSDtdtEwCrflRVEcA01zzgA9MTeYSZM
         ghzfxoA1thouw670q93aviaWQdwLrHWTd+EM6At2P1RBfsweJR24Tsqkoq27Ct4UNvy0
         FG0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=9mREEcazEV2TFx5JIFnH3pAzE1JX52Mxgf7Nke2hFVA=;
        b=KaVQ5y3Ep62rjV4ovCykWc65MGrKXNmAw8iXwGwoTRubTFSCWW2iOR5CGKh1vQAcFK
         Y73UVSxHfb0yQjt1SFPQ3a3n76YmMI4/Jw+9MzyL9a1n0/bQfGM8WsYhsh/vO213G3Zl
         PlECz6FvzMCDMf/TH3LBRUKZSSKtVNnQfL1KJk7p6G4xAQH3oemyQwzUByDTWQRmnvy6
         gt1Igi7xQIB5UGxSewiBSYv0UlEMuJqQWWwSf4ygdXUmSkca7f9cy4qkZhSLaC9W6DDF
         zQ5hnt9O3V31WEk3Zfn8N62JoELZwKsmXgs7IvYKK6KvmDDM/BESBH+v5JumngGuwK4D
         UPCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=qQfQKlBU;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.65 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730065.outbound.protection.outlook.com. [40.107.73.65])
        by mx.google.com with ESMTPS id y21si9686470otk.270.2019.05.08.04.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 04:29:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.65 as permitted sender) client-ip=40.107.73.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=qQfQKlBU;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.73.65 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9mREEcazEV2TFx5JIFnH3pAzE1JX52Mxgf7Nke2hFVA=;
 b=qQfQKlBUhqrL+3Zq0CNfpq26DFQMQ47XeDeoOQghyt8YnFxihdOyu/uqLTp4Va2PKJok0DnLUK74RKCRbvROk2XuKOdS1aEBpBZ7S2HyRHxL7vRH6SPzukskQpsFHAO8LtN/Vyu7cA1xYW8YkqaoD+LlmFfxVsALjqdbrsDXj/c=
Received: from MWHPR03CA0030.namprd03.prod.outlook.com (2603:10b6:301:3b::19)
 by DM5PR03MB3132.namprd03.prod.outlook.com (2603:10b6:4:3c::29) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1878.20; Wed, 8 May
 2019 11:29:15 +0000
Received: from SN1NAM02FT031.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::207) by MWHPR03CA0030.outlook.office365.com
 (2603:10b6:301:3b::19) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.20 via Frontend
 Transport; Wed, 8 May 2019 11:29:14 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 SN1NAM02FT031.mail.protection.outlook.com (10.152.72.116) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:13 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48BTCgt016944
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:12 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:11 -0400
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
Subject: [PATCH 00/16] treewide: fix match_string() helper when array size
Date: Wed, 8 May 2019 14:28:25 +0300
Message-ID: <20190508112842.11654-1-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(376002)(136003)(346002)(396003)(39860400002)(2980300002)(189003)(199004)(336012)(48376002)(6666004)(16586007)(316002)(426003)(356004)(107886003)(2441003)(50226002)(7696005)(51416003)(54906003)(2906002)(478600001)(110136005)(486006)(47776003)(7636002)(44832011)(106002)(50466002)(2616005)(476003)(8676002)(70206006)(246002)(70586007)(4326008)(2201001)(7416002)(26005)(1076003)(186003)(8936002)(77096007)(5660300002)(36756003)(126002)(53416004)(305945005)(86362001)(14444005)(921003)(83996005)(2101003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR03MB3132;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: c32e2cbb-fe64-4c66-7a5d-08d6d3a86664
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:DM5PR03MB3132;
X-MS-TrafficTypeDiagnostic: DM5PR03MB3132:
X-Microsoft-Antispam-PRVS:
	<DM5PR03MB3132F0B0976A4F2194522684F9320@DM5PR03MB3132.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8882;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	j/srRMWDBUltVscxVeW1javD8vK/cachSroUu+/Gbw1dTf/SvbBrFyW07ykT1LHxgf7JFm8qQ93W9eBvUwKDflyO8jAEvFHYdehNb6EHWUlpktuzMPEP4dqtYdoUQPJZJheiLPDUHbBGHPrVF+8TL5mDHJaN5ynPAEYsTTkWak369JERGg4vdXLCAeUTNR0/5p+fpFpKdjOGClAHWrD4fgHBh7O9/Ww1YzfpFB5/ShVxDtLKjt6j5yDaAZJVnp6EeWEY3bKP4Xa20OdzBmuebRIP54BdhQLWgxOFaNRtwz2dquRxZGpNeP4PgyojuMA1RloHq4JkY9VStd6NE4AnfhNTuZyPUNrsaLk3IJ1WIYcn7pLDJzCGmOSiZuodj5CqDCxvmc9nwLsca/AMvRwPw64pvgq4xuPYVpmZdqdwNAA=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:13.4642
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: c32e2cbb-fe64-4c66-7a5d-08d6d3a86664
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR03MB3132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The intent of this patch series is to make a case for fixing the
match_string() string helper.

The doc-string of the `__sysfs_match_string()` helper mentions that `n`
(the size of the given array) should be:
 * @n: number of strings in the array or -1 for NULL terminated arrays

However, this is not the case.
The helper stops on the first NULL in the array, regardless of whether -1
is provided or not.

There are some advantages to allowing this behavior (NULL elements within
in the array). One example, is to allow reserved registers as NULL in an
array.
One example in the series is patch:
   x86/mtrr: use new match_string() helper + add gaps == minor fix
which uses a "?" string for values that are reserved/don't care.

Since the change is a bit big, the change was coupled with renaming
match_string() -> __match_string().
The new match_string() helper (resulted here) does an ARRAY_SIZE() over the
array, which is useful when the array is static. 

Also, this way of doing things is a way to go through all the users of this
helpers and check that nothing goes wrong, and notify them about the change
to match_string().
It's a way of grouping changes in a manage-able way.

The first patch is important, the others can be dropped.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>

Alexandru Ardelean (16):
  lib: fix match_string() helper when array size is positive
  treewide: rename match_string() -> __match_string()
  lib,treewide: add new match_string() helper/macro
  powerpc/xmon: use new match_string() helper/macro
  ALSA: oxygen: use new match_string() helper/macro
  x86/mtrr: use new match_string() helper + add gaps == minor fix
  device connection: use new match_string() helper/macro
  cpufreq/intel_pstate: remove NULL entry + use match_string()
  mmc: sdhci-xenon: use new match_string() helper/macro
  pinctrl: armada-37xx: use new match_string() helper/macro
  mm/vmpressure.c: use new match_string() helper/macro
  rdmacg: use new match_string() helper/macro
  drm/edid: use new match_string() helper/macro
  staging: gdm724x: use new match_string() helper/macro
  video: fbdev: pxafb: use new match_string() helper/macro
  sched: debug: use new match_string() helper/macro

 arch/powerpc/xmon/xmon.c                         |  2 +-
 arch/x86/kernel/cpu/mtrr/if.c                    | 10 ++++++----
 drivers/ata/pata_hpt366.c                        |  2 +-
 drivers/ata/pata_hpt37x.c                        |  2 +-
 drivers/base/devcon.c                            |  2 +-
 drivers/base/property.c                          |  2 +-
 drivers/clk/bcm/clk-bcm2835.c                    |  4 +---
 drivers/clk/clk.c                                |  4 ++--
 drivers/clk/rockchip/clk.c                       |  4 ++--
 drivers/cpufreq/intel_pstate.c                   |  9 ++++-----
 drivers/gpio/gpiolib-of.c                        |  2 +-
 drivers/gpu/drm/drm_edid_load.c                  |  2 +-
 drivers/gpu/drm/drm_panel_orientation_quirks.c   |  2 +-
 drivers/gpu/drm/i915/intel_pipe_crc.c            |  2 +-
 drivers/ide/hpt366.c                             |  2 +-
 drivers/mfd/omap-usb-host.c                      |  2 +-
 drivers/mmc/host/sdhci-xenon-phy.c               | 12 ++++++------
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c |  2 +-
 drivers/pci/pcie/aer.c                           |  2 +-
 drivers/phy/tegra/xusb.c                         |  2 +-
 drivers/pinctrl/mvebu/pinctrl-armada-37xx.c      |  4 ++--
 drivers/pinctrl/pinmux.c                         |  2 +-
 drivers/power/supply/ab8500_btemp.c              |  2 +-
 drivers/power/supply/ab8500_charger.c            |  2 +-
 drivers/power/supply/ab8500_fg.c                 |  2 +-
 drivers/power/supply/abx500_chargalg.c           |  2 +-
 drivers/power/supply/charger-manager.c           |  4 ++--
 drivers/staging/gdm724x/gdm_tty.c                |  3 +--
 drivers/usb/common/common.c                      |  4 ++--
 drivers/usb/typec/class.c                        |  8 +++-----
 drivers/usb/typec/tps6598x.c                     |  2 +-
 drivers/vfio/vfio.c                              |  4 +---
 drivers/video/fbdev/pxafb.c                      |  4 ++--
 fs/ubifs/auth.c                                  |  4 ++--
 include/linux/string.h                           | 11 ++++++++++-
 kernel/cgroup/rdma.c                             |  2 +-
 kernel/sched/debug.c                             |  2 +-
 kernel/trace/trace.c                             |  2 +-
 lib/string.c                                     | 13 ++++++++-----
 mm/mempolicy.c                                   |  2 +-
 mm/vmpressure.c                                  |  4 ++--
 security/apparmor/lsm.c                          |  4 ++--
 security/integrity/ima/ima_main.c                |  2 +-
 sound/firewire/oxfw/oxfw.c                       |  2 +-
 sound/pci/oxygen/oxygen_mixer.c                  |  2 +-
 sound/soc/codecs/max98088.c                      |  2 +-
 sound/soc/codecs/max98095.c                      |  2 +-
 sound/soc/soc-dapm.c                             |  2 +-
 48 files changed, 88 insertions(+), 82 deletions(-)

-- 
2.17.1

