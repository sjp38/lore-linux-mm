Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D35DC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D08FF2085A
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=microsoft.com header.i=@microsoft.com header.b="PEIYFwDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D08FF2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=microsoft.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71AA96B0005; Wed,  1 May 2019 19:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CA6D6B0006; Wed,  1 May 2019 19:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BAD46B0007; Wed,  1 May 2019 19:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD596B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 19:49:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f3so315621plb.17
        for <linux-mm@kvack.org>; Wed, 01 May 2019 16:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :msip_labels:content-transfer-encoding:mime-version;
        bh=807rdHdx6dzyT7XNfEqHLNKo5f1j+T4QBHXYqYDHEt0=;
        b=XVV8PEN2ZXHxhCquEmYpCRsNHTjCFAs35StjeOmOH2MpH8m1lrRJo1Ld/NmwtEQorO
         8UEb2OT69e3Ms+3wPCvjZI5o+Onhm2vSLJZkvYt9gss8UVG/xzyx3SWRkJmTRX/zwnoo
         WtKYIpEO2fIp9e2iQrpH3haXUdBh/UVDk/ECkO8pWGfC9MQwpdEAIRFyvg3icONPtZAn
         fcw5ww4LvKkQdRWDeqqxZYePDe4EfsCXJlFJDpYcqLVl8smXZwI9+4PuJJ56kK338Rr7
         vqerinkI76itzUoP6fuuBe+22ErllWf+SxKHWeKlAgdsuJ4RKQsPfh9MgMrz/CQaG12k
         mnbw==
X-Gm-Message-State: APjAAAXIt758lRN666U4CjmkLVqJJJNppZ4AfGab7gUsrnPFpwuqLj+H
	orqOmsQeWjpHxPzyi0B1dFFMWmly6GFCsMTpTcuSNttjjR7DMEIqEq3+WSZokWBuhbU1h9/5A05
	EQD53JjF2os4G+QOEPzDBWDWqrPSmduIscW/G0KfydjLQWNX94nblhCGN+/H+sO+2yw==
X-Received: by 2002:aa7:9116:: with SMTP id 22mr704844pfh.165.1556754557231;
        Wed, 01 May 2019 16:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd8d59UEav8c/znLSpM1tsRbnVo5y3AyKcpfCw+gA23U03SsRXfUT7jYdU6tzFYUFMnEJk
X-Received: by 2002:aa7:9116:: with SMTP id 22mr704788pfh.165.1556754556009;
        Wed, 01 May 2019 16:49:16 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1556754556; cv=pass;
        d=google.com; s=arc-20160816;
        b=NCCzojgBEhkifvblSTxfdoaW5OW/du4L22OjuMOnO4jc+4kL2WG/mUPHAvsX3HT3Un
         MUSm1PIfIi1d4NmP5GPaeSN+geSK1K0fOHyucXaQ7KTgz73eMzH3ScI3IWltyd27YCjq
         KDapRinSZbpVH/HESElmnN/YPIL5kc5e1dflnxINVEOL4jnGkvttlvcgaJcVoFjVQi29
         NodLg3n+SssV32WiKgapxUM4kPZAbyBinIlVnpK9PMxCirCAAcyvTlV9aaQ0Av/5AYq5
         6WnI3JlSAnlXW4IrbmuyY57W3CPWgZxBUyeb9VVHcOYiVXSN9qQtDFzJklB2DtHMszvn
         gSog==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:msip_labels:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=807rdHdx6dzyT7XNfEqHLNKo5f1j+T4QBHXYqYDHEt0=;
        b=IhgRb/niMjg62nwjhPTQDFGjOcAaP8ZmRUVwo8jMV6VScfGATeGLzTr7IRxCYaCiJ9
         8QotDPY5z0KosPBKprNc/M+yLGB1QG43qHYU6ja2EUGDeCspkvNKYxikQps5cuq7eijN
         PWHeuN7dVzhjtd+GaUuWwkpgvJAuWkra6zR45btbQ/sJL5XgJ+q124p6dkgMyEx74ze9
         bxt/37onBBfR6CinJadchj+7bl4IVpTlR5455/G71hEd2H5blCpbSXByHw3IKLhBxke6
         dDEIyzlX+0VTIm8vB0bjcuuEiEPRPH8UQjAnbZQjra/UZZJMw6e/IuF7GfC+LP6FbAaz
         JUag==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=PEIYFwDB;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.130.127 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300127.outbound.protection.outlook.com. [40.107.130.127])
        by mx.google.com with ESMTPS id g8si41316672plt.4.2019.05.01.16.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 16:49:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of decui@microsoft.com designates 40.107.130.127 as permitted sender) client-ip=40.107.130.127;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=PEIYFwDB;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.130.127 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=yG/fApfg6ekekj6Hsox/DQzbJUu5MnJ6jpVYWy9KaTzDr8nep3Jm9+MfVd75aRL8RP0bdQVR/qM4L9bZbjIyzJ3SgTw4x+NboxShqSbaO5YCO7DF09GuylIMrK3sbRn3imucPN8LaJsNg5yTPqcKVtv1Vq8IDgijdvPOxitvsz4=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=807rdHdx6dzyT7XNfEqHLNKo5f1j+T4QBHXYqYDHEt0=;
 b=WqHKujURJa7JgicFyQbRES/9m4rD7K4+w/QsNjRDaqiYGP+i9n1iPPhyslOV6IlvB5nm3rHRXJ2FlWJcBYV74BOa7t5i8uQuDSIRmQprT5joHflmwQTmmaZx3+J2OLvv7AOSjMK2FV5uGNblBOWgYhhbW8JtzSDFUAhKH7W48PQ=
ARC-Authentication-Results: i=1; test.office365.com 1;spf=none;dmarc=none
 action=none header.from=microsoft.com;dkim=none (message not signed);arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=807rdHdx6dzyT7XNfEqHLNKo5f1j+T4QBHXYqYDHEt0=;
 b=PEIYFwDBF68kIUgbhSil5URQ5cJ4K2y6n5qKnf4EVxrGf9otBErz1VJW8VSfVkwvye6g8jd/9kyiIP6NbT8r4SPUQKC0TCI3KcMw7yX9jjuCiJUd42eRoL0uD492BrvoSVDiPyUzXmAw89yCpTmR7RYpundSuNFPbMXVSXxsLKU=
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM (10.170.189.13) by
 PU1P153MB0185.APCP153.PROD.OUTLOOK.COM (10.170.187.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.3; Wed, 1 May 2019 23:49:11 +0000
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::9810:3b6b:debd:1f16]) by PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::9810:3b6b:debd:1f16%4]) with mapi id 15.20.1856.004; Wed, 1 May 2019
 23:49:11 +0000
From: Dexuan Cui <decui@microsoft.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>
CC: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Hugh
 Dickins <hughd@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel
 Gorman <mgorman@techsingularity.net>, "dchinner@redhat.com"
	<dchinner@redhat.com>, Greg Thelen <gthelen@google.com>, Kuo-Hsin Yang
	<vovoy@chromium.org>, "dchinner@redhat.com" <dchinner@redhat.com>, Kuo-Hsin
 Yang <vovoy@chromium.org>
Subject: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689! 
Thread-Topic: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689! 
Thread-Index: AdUAdyzy8F3SUITdRv6SToKOnShIeg==
Date: Wed, 1 May 2019 23:49:10 +0000
Message-ID:
 <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=True;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Owner=decui@microsoft.com;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2019-05-01T23:48:58.2349667Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=General;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Application=Microsoft Azure
 Information Protection;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=3c696052-eebd-4a0b-9aa7-5a558921fc8b;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Extended_MSFT_Method=Automatic
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=decui@microsoft.com; 
x-originating-ip: [2001:4898:80e8:b:722c:5528:2655:ac0d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7d824564-a027-4323-8bfa-08d6ce8f9c09
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:PU1P153MB0185;
x-ms-traffictypediagnostic: PU1P153MB0185:
x-ld-processed: 72f988bf-86f1-41af-91ab-2d7cd011db47,ExtAddr
x-microsoft-antispam-prvs:
 <PU1P153MB018566832132670882B3090FBF3B0@PU1P153MB0185.APCP153.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 00246AB517
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(136003)(396003)(346002)(376002)(39860400002)(366004)(199004)(189003)(66446008)(71200400001)(7736002)(71190400001)(68736007)(2906002)(33656002)(10290500003)(256004)(478600001)(6506007)(8990500004)(73956011)(8676002)(81166006)(10090500001)(5660300002)(8936002)(74316002)(86362001)(4743002)(7416002)(6116002)(52536014)(81156014)(486006)(102836004)(66556008)(99286004)(14444005)(9686003)(66946007)(305945005)(64756008)(186003)(86612001)(7696005)(25786009)(46003)(14454004)(54906003)(53936002)(6436002)(76116006)(66476007)(110136005)(476003)(55016002)(4326008)(2501003)(316002)(22452003);DIR:OUT;SFP:1102;SCL:1;SRVR:PU1P153MB0185;H:PU1P153MB0169.APCP153.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: microsoft.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 oRXFCSBW9u5oxx5AviEQAbur9r3j80usdzzs5hMaH4jebpX2UqIcFHn6g9e0Ypw2b5fHfqL+Ung9896c+kFUzf2gmN2n5SYl99+Y9uwgoZCTFe9IjnZB6DWrjZF/l4CswP6mCi9TZ1w4tmEdKfZjVDMpHiqT0+yFXphdWMLsvRfHxdkfH/E/JeVq8iAl6ls675Dih8a7HrCALEp2EjXGxTqis6KKx3AA4sdn6iwFs5FK7sSwxwDSbPCtH9GeooYt+4I3yys2Z3+dFIOSEFElb/CQoaLwyzGVdn6hPWVOiUPAuhqveAgnl70thioKPYkw0XvEdzBz0GYftnHMYTfw640tOGfJ+ocV3rZbTST5254ODgPBJD/vAqlyuMkbI0TbHE/lUU+eJvXAkR+5n8X/QPWPQ9dmhkakT+mcbpSBQ40=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7d824564-a027-4323-8bfa-08d6ce8f9c09
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 May 2019 23:49:10.9742
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PU1P153MB0185
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
Today I got the below BUG in isolate_lru_pages() when building the kernel.

My current running kernel, which exhibits the BUG, is based on the mainline=
 kernel's commit=20
262d6a9a63a3 ("Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/=
pub/scm/linux/kernel/git/tip/tip").

Looks nobody else reported the issue recently.

So far I only hit the BUG once and I don't know how to reproduce it again, =
so this is just a FYI.

Thanks,
-- Dexuan

The crash log is:

[ 1626.194411] ------------[ cut here ]------------
[ 1626.197031] kernel BUG at mm/vmscan.c:1689!
[ 1626.197031] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC PTI
[ 1626.207112] CPU: 2 PID: 86 Comm: kswapd0 Not tainted 5.0.0+ #67
[ 1626.207112] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090008  12/07/2018
[ 1626.207112] RIP: 0010:isolate_lru_pages+0x4ab/0x4c0
[ 1626.207112] Code: e8 6a bc f1 ff 85 c0 75 e0 48 c7 c2 40 dc 03 af be 41 =
01 00 00 48 c7 c7 de ef 06 af c6 05 2e 6c 17 01 01 e8 d2 8c ef ff eb bf <0f=
> 0b e8 be 50 e9 ff 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 0f
[ 1626.245025] RSP: 0000:ffffa051c0c73ac8 EFLAGS: 00010082
[ 1626.258863] RAX: 00000000ffffffea RBX: ffff8cdb229afc20 RCX: dead0000000=
00200
[ 1626.258863] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffe0f8035=
43000
[ 1626.258863] RBP: 000000000000000c R08: ffffe0f8033c2708 R09: 00000000000=
00002
[ 1626.258863] R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000=
0000b
[ 1626.258863] R13: 000000000000000b R14: ffffa051c0c73de0 R15: ffffe0f8035=
43008
[ 1626.258863] FS:  0000000000000000(0000) GS:ffff8cdb43280000(0000) knlGS:=
0000000000000000
[ 1626.258863] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1626.303683] CR2: 0000563ea696da18 CR3: 00000000e07f0005 CR4: 00000000003=
606e0
[ 1626.303683] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1626.303683] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1626.303683] Call Trace:
[ 1626.327319]  shrink_inactive_list+0xf9/0x700
[ 1626.327319]  ? __lock_acquire+0x42d/0x1190
[ 1626.327319]  ? inactive_list_is_low+0x77/0x2c0
[ 1626.327319]  shrink_node_memcg+0x206/0x780
[ 1626.327319]  ? percpu_ref_put_many+0x8c/0x130
[ 1626.327319]  ? percpu_ref_put_many+0x8c/0x130
[ 1626.327319]  shrink_node+0xcf/0x470
[ 1626.355957]  balance_pgdat+0x2d9/0x560
[ 1626.355957]  kswapd+0x263/0x560
[ 1626.355957]  ? finish_wait+0x80/0x80
[ 1626.355957]  ? balance_pgdat+0x560/0x560
[ 1626.355957]  kthread+0x11b/0x140
[ 1626.373956]  ? kthread_create_on_node+0x60/0x60
[ 1626.373956]  ret_from_fork+0x24/0x30
[ 1626.373956] Modules linked in: crct10dif_pclmul crc32_pclmul ghash_clmul=
ni_intel aesni_intel aes_x86_64 crypto_simd cryptd glue_helper serio_raw hy=
perv_fb evdev autofs4 hid_generic hid_hyperv hv_netvsc hyperv_keyboard hid =
psmouse i2c_piix4 hv_vmbus atkbd i2c_core
[ 1626.373956] ---[ end trace b148bf262999856d ]---
[ 1626.373956] RIP: 0010:isolate_lru_pages+0x4ab/0x4c0
[ 1626.373956] Code: e8 6a bc f1 ff 85 c0 75 e0 48 c7 c2 40 dc 03 af be 41 =
01 00 00 48 c7 c7 de ef 06 af c6 05 2e 6c 17 01 01 e8 d2 8c ef ff eb bf <0f=
> 0b e8 be 50 e9 ff 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 0f
[ 1626.373956] RSP: 0000:ffffa051c0c73ac8 EFLAGS: 00010082
[ 1626.373956] RAX: 00000000ffffffea RBX: ffff8cdb229afc20 RCX: dead0000000=
00200
[ 1626.373956] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffe0f8035=
43000
[ 1626.373956] RBP: 000000000000000c R08: ffffe0f8033c2708 R09: 00000000000=
00002
[ 1626.373956] R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000=
0000b
[ 1626.373956] R13: 000000000000000b R14: ffffa051c0c73de0 R15: ffffe0f8035=
43008
[ 1626.373956] FS:  0000000000000000(0000) GS:ffff8cdb43280000(0000) knlGS:=
0000000000000000
[ 1626.373956] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1626.373956] CR2: 0000563ea696da18 CR3: 00000000e07f0005 CR4: 00000000003=
606e0
[ 1626.373956] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1626.373956] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1626.373956] BUG: sleeping function called from invalid context at includ=
e/linux/percpu-rwsem.h:34
[ 1626.373956] in_atomic(): 1, irqs_disabled(): 1, pid: 86, name: kswapd0
[ 1626.373956] INFO: lockdep is turned off.
[ 1626.373956] irq event stamp: 998186
[ 1626.373956] hardirqs last  enabled at (998185): [<ffffffffae830669>] _ra=
w_spin_unlock_irq+0x29/0x50
[ 1626.373956] hardirqs last disabled at (998186): [<ffffffffae8303ff>] _ra=
w_spin_lock_irq+0xf/0x40
[ 1626.520571] softirqs last  enabled at (993564): [<ffffffffaec0038b>] __d=
o_softirq+0x38b/0x498
[ 1626.520571] softirqs last disabled at (993557): [<ffffffffae0796db>] irq=
_exit+0xdb/0xf0
[ 1626.520571] Preemption disabled at:
[ 1626.520571] [<0000000000000000>]           (null)
[ 1626.520571] CPU: 2 PID: 86 Comm: kswapd0 Tainted: G      D           5.0=
.0+ #67
[ 1626.520571] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090008  12/07/2018
[ 1626.520571] Call Trace:
[ 1626.520571]  dump_stack+0x67/0x90
[ 1626.520571]  ___might_sleep.cold.78+0xf0/0x104
[ 1626.520571]  exit_signals+0x30/0x2d0
[ 1626.520571]  ? finish_wait+0x80/0x80
[ 1626.520571]  do_exit+0xb0/0xc90
[ 1626.520571]  ? balance_pgdat+0x560/0x560
[ 1626.520571]  ? kthread+0x11b/0x140
[ 1626.520571]  rewind_stack_do_exit+0x17/0x20
[ 1626.579941] note: kswapd0[86] exited with preempt_count 1
[ 1691.170873] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
[ 1691.174869] rcu:     5-...0: (6 ticks this GP) idle=3D4e2/1/0x4000000000=
000000 softirq=3D19854/19854 fqs=3D8114 last_accelerate: 0dd1/4d4e, Nonlazy=
 posted: .L.
[ 1691.174869] rcu:     (detected by 1, t=3D16254 jiffies, g=3D163449, q=3D=
3759)
[ 1691.174869] Sending NMI from CPU 1 to CPUs 5:
[ 1691.174869] NMI backtrace for cpu 5
[ 1691.174869] CPU: 5 PID: 6477 Comm: ld Tainted: G      D W         5.0.0+=
 #67
[ 1691.174869] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090008  12/07/2018
[ 1691.174869] RIP: 0010:queued_spin_lock_slowpath+0x2b/0x1e0
[ 1691.174869] Code: 1f 44 00 00 41 54 55 53 48 89 fb 0f 1f 44 00 00 ba 01 =
00 00 00 8b 03 85 c0 75 0d f0 0f b1 13 85 c0 75 f2 5b 5d 41 5c c3 f3 90 <eb=
> e9 81 fe 00 01 00 00 74 44 81 e6 00 ff ff ff 75 71 f0 0f ba 2b
[ 1691.174869] RSP: 0018:ffffa051c8dafb88 EFLAGS: 00000002
[ 1691.174869] RAX: 0000000000000001 RBX: ffff8cdb47804b80 RCX: 605139ec000=
00000
[ 1691.174869] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff8cdb478=
04b80
[ 1691.174869] RBP: 0000000000000246 R08: 0000000091512c45 R09: 00000000000=
00001
[ 1691.174869] R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000=
00000
[ 1691.174869] R13: ffffffffae1d4fe0 R14: ffff8cdb47800000 R15: ffffe0f8030=
067c0
[ 1691.174869] FS:  00007f9b6e162b80(0000) GS:ffff8cdb43340000(0000) knlGS:=
0000000000000000
[ 1691.174869] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1691.174869] CR2: 00007f9b5648b000 CR3: 00000000e07f0006 CR4: 00000000003=
606e0
[ 1691.174869] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1691.174869] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1691.174869] Call Trace:
[ 1691.174869]  do_raw_spin_lock+0xab/0xb0
[ 1691.174869]  _raw_spin_lock_irqsave+0x40/0x50
[ 1691.174869]  ? pagevec_lru_move_fn+0x6c/0xd0
[ 1691.174869]  pagevec_lru_move_fn+0x6c/0xd0
[ 1691.174869]  __lru_cache_add+0x6b/0xa0
[ 1691.174869]  add_to_page_cache_lru+0x76/0xc0
[ 1691.174869]  pagecache_get_page+0xf2/0x2d0
[ 1691.174869]  grab_cache_page_write_begin+0x1c/0x40
[ 1691.174869]  ext4_da_write_begin+0xe5/0x500
[ 1691.174869]  generic_perform_write+0xf4/0x1c0
[ 1691.174869]  __generic_file_write_iter+0xfa/0x1c0
[ 1691.174869]  ? generic_write_checks+0x4c/0xb0
[ 1691.174869]  ext4_file_write_iter+0xc6/0x3f0
[ 1691.174869]  new_sync_write+0x115/0x180
[ 1691.174869]  vfs_write+0xb7/0x1b0
[ 1691.174869]  ksys_write+0x52/0xc0
[ 1691.174869]  do_syscall_64+0x5e/0x200
[ 1691.174869]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 1691.174869] RIP: 0033:0x7f9b6e48afd4
[ 1691.174869] Code: 00 f7 d8 64 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 =
00 00 00 00 48 8d 05 29 f7 0d 00 8b 00 85 c0 75 13 b8 01 00 00 00 0f 05 <48=
> 3d 00 f0 ff ff 77 54 c3 0f 1f 00 41 54 49 89 d4 55 48 89 f5 53
[ 1691.174869] RSP: 002b:00007ffcb3925b18 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000001
[ 1691.174869] RAX: ffffffffffffffda RBX: 000000000dfd4000 RCX: 00007f9b6e4=
8afd4
[ 1691.174869] RDX: 000000000dfd4000 RSI: 00007f9b5e07a3a0 RDI: 00000000000=
0004e
[ 1691.174869] RBP: 00007f9b5e07a3a0 R08: 000000000dfd4000 R09: 00000000000=
00000
[ 1691.174869] R10: 000000000000000d R11: 0000000000000246 R12: 0000563ea61=
763a0
[ 1691.174869] R13: 000000000dfd4000 R14: 000000000dfd4e20 R15: 00007f9b6e5=
61760

