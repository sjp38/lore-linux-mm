Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D590FC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:01:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AEA52081C
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oyz/0Gh3";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="PLZ9cqz2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AEA52081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EA6A6B02B4; Thu, 23 May 2019 17:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172656B02B6; Thu, 23 May 2019 17:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013456B02B7; Thu, 23 May 2019 17:01:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id C70A96B02B4
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:01:03 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id h22so1552198vso.18
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:01:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ClXmZI/N8fwomQ8i6o2AXSf9bNgp0rLsWx833fh4w7w=;
        b=ez9ADwojIsz+F+UZGm6VPMm0Nu0E9fCkT1nop0kBOh4PaaEb5ZyYHHvs7EMLVBYZPo
         U0VPtE5zLPKk9yNfHgHf+T8HG0rmzGzjfovmQwXF6qTtVgduYdq0t2sPqH66OsYQpSvQ
         fEVnA/Jb6m5TNuH+k0yocTaNgpJiu4n5xGiWnBXLnGva0vgZel3c6LUyYnNH3A4AWQsm
         ab7vCeGf2xFshFhzB+WH5m4EQAR6piPpCzcCy1AoZWJdWwmosVlCGVx9Dg69xQuB/lhd
         BBdrAtsED5Jiub8XA2XbdSbxMzVoHr+2F4aRZNLPXUITAyE1lrkH5/bZZrWASXeg0VOq
         9vHw==
X-Gm-Message-State: APjAAAUHEYG2/P//gjB24aKZwNffq+T9gsy04HDLkXZFeq6O8ef13ENb
	ltXDGFB9hSgrvF1/D+F4Ly4v2z87esh338ydVGfe+QbTgciZgT0WjBQRwrvCI+ogYAH0bGMiuTO
	ceskc2t6wHer69W1NUkoQP1hGh97pnz1Y08bjb0llkCT5G3pxEonKvVIRWmDY5kl1QQ==
X-Received: by 2002:a67:6046:: with SMTP id u67mr26897139vsb.106.1558645263376;
        Thu, 23 May 2019 14:01:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysevQqj3E/aKmrw6ZkWVrNiUfD9FzWJ7HHUxGlE3wvOJzqjZ7bczCgb7sF1HYiB/1ItSVJ
X-Received: by 2002:a67:6046:: with SMTP id u67mr26897086vsb.106.1558645262385;
        Thu, 23 May 2019 14:01:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558645262; cv=none;
        d=google.com; s=arc-20160816;
        b=ZdZdJI/0GqgrOT5BpXTWgjdIIcFAa2jXZWdFChnhaQT6YO7PyDwZdmR80yKKLYDD18
         Mo7IuTD6ASwnS9B83/l9a2kcLHK7Pl5kPVPXZm4kf5GDHV9dC8KwecvoSIhk/Jlzi/jt
         lu/Gx3lri+5Dz2wxaf+STiPZv0r8VHj9kgo0vcxHcLKnUMsrKBrIdRj2sT1o8foSICxp
         xMhlujOep6tFLoK04b1AYYbF2mvOMu7Zzyere1IlKuHPdDHKq/MuO2gpOvGeEg1irQjl
         QTPrJKAQOQGEEpXshlB7KH0DxSbON6NgQyok/tNnG2WuHlDuOXOJEOdKKU4Ol0/TgbrC
         aMpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=ClXmZI/N8fwomQ8i6o2AXSf9bNgp0rLsWx833fh4w7w=;
        b=uFsTWGfw28dVKjRXa3LQ+msvXKXbt8D79DIWHNMCzQSXwiT9t2n3wpEa2+bxhDAfJM
         pQ9Xyo0kfnGIFpqDcTPRllfbsKy2XP0hbfTBAp63BcaWqNRevIJaf1dpUMPxqsWVyuL2
         58poMiqqDGcAH9O9J1pR1M6h9GubPQE4IxO9y/bNYU91KOkMw5WgqisuXjXzF6vX/SxM
         nL2dDUt6YqFLY71iFIiikPZ/dQLGcFDbN0qktfdOZCTdjAesSHnmLVMSk29sNS7UBumR
         pvYdXmlngC/rSrhv2MT1cjhUQwKx5dGhiDqU33MnhIjuCeZhLjq0xPpnacCgThm0l1GU
         bL7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="oyz/0Gh3";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=PLZ9cqz2;
       spf=pass (google.com: domain of prvs=004624121d=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=004624121d=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v9si81312uao.186.2019.05.23.14.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 14:01:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=004624121d=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="oyz/0Gh3";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=PLZ9cqz2;
       spf=pass (google.com: domain of prvs=004624121d=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=004624121d=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4NKxF58025315;
	Thu, 23 May 2019 14:00:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ClXmZI/N8fwomQ8i6o2AXSf9bNgp0rLsWx833fh4w7w=;
 b=oyz/0Gh3XwjNR0oV+t3VLB0rHM+XdWjakeoqcANNGJD2oebAcnO8BM5XPXWUew0qud6s
 pkAAPEwMSl+j7Yg89U8dLSJxr5YjZ29tVzWX7TT1p2GG1SzIvFyuYntHn3G6y9YE0tTc
 gJ/qwyA++j9+/2tp4bb2+v/QxuMhoceKs88= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2snvfs9jya-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 23 May 2019 14:00:54 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 23 May 2019 14:00:52 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 23 May 2019 14:00:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ClXmZI/N8fwomQ8i6o2AXSf9bNgp0rLsWx833fh4w7w=;
 b=PLZ9cqz2KZq65koeqD8iXRwBudhiGAyk5JVjfYRsOv1kA9inn4eYt4DmhNd6INkgWu1rAOwc2DcFTBjwimXBxEqHYckOzsgfxTZ5tLeq5RyZeddQGNLr/Div8May8XsBnMsEchBKPFvywYzW0BKpavGJVTqX4JlaxBbvDtN5tOs=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3031.namprd15.prod.outlook.com (20.178.238.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Thu, 23 May 2019 21:00:46 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.018; Thu, 23 May 2019
 21:00:46 +0000
From: Roman Gushchin <guro@fb.com>
To: kernel test robot <rong.a.chen@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "lkp@01.org"
	<lkp@01.org>
Subject: Re: [mm] e52271917f:
 BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h
Thread-Topic: [mm] e52271917f:
 BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h
Thread-Index: AQHVEQK9HmiEhlc+A0m0AWi9Kp8XiKZ5MyQA
Date: Thu, 23 May 2019 21:00:46 +0000
Message-ID: <20190523210040.GA8420@tower.DHCP.thefacebook.com>
References: <20190514213940.2405198-6-guro@fb.com>
 <20190523005858.GJ19312@shao2-debian>
In-Reply-To: <20190523005858.GJ19312@shao2-debian>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR08CA0009.namprd08.prod.outlook.com
 (2603:10b6:301:5f::22) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:7b7b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 16109ef3-93e3-47fa-af2c-08d6dfc1ba34
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3031;
x-ms-traffictypediagnostic: BYAPR15MB3031:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <BYAPR15MB30312DE969B6BF7F69A78032BE010@BYAPR15MB3031.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4714;
x-forefront-prvs: 00462943DE
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(366004)(39860400002)(346002)(396003)(199004)(189003)(9686003)(6512007)(6306002)(6116002)(6436002)(6486002)(14454004)(7736002)(305945005)(54906003)(25786009)(5660300002)(4326008)(76176011)(102836004)(99286004)(52116002)(6246003)(386003)(6506007)(256004)(66446008)(66946007)(64756008)(66556008)(66476007)(73956011)(8936002)(5024004)(14444005)(7416002)(86362001)(53936002)(1076003)(446003)(2906002)(46003)(71200400001)(966005)(229853002)(478600001)(186003)(33656002)(11346002)(81166006)(81156014)(8676002)(68736007)(71190400001)(476003)(486006)(6916009)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3031;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ui5iva2r30+dgXH/R+kZUFfoQxMDLAxCGrnFhGRGafEbS7zrZwtApcsDzStE6aakAm2H5srheV9jV7lifEIeTRBPIGnMFO3MYAQyYQLjV8XkV0PzjAsWZyUvq+qpN3KMIw3p6oyU46TF8RtpJO0Iv887JahMWjeng/SjyLZCDdWKRy69mUh0YKv05Ddl/9pm/sGvPyzSQpvTxd1W2EypjRysou82nEesWh/uQmJTyXqXnFxv037Oa8f36zl3Kxb6zG5ZYwcDaE3g6sStdhM/WNCIS68rd3MPZq/l5fDq6gUJCA5wZX9m4Ehvxp1rHHS/NUp6F/2mhOVbgn9tGCBHstqyBtfxcvy3jg8vIkrJ9BP6VbuzznJIB2iQzum/pMqDRruQMptMpCCxjXuqMqZAhRY5IaNlW6gv6PyiBWVBOuI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <14F14FC4BCF487408A51CD4FB01F9AD2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 16109ef3-93e3-47fa-af2c-08d6dfc1ba34
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 May 2019 21:00:46.7859
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3031
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-23_17:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=276 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905230135
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 08:58:58AM +0800, kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-7):
>=20
> commit: e52271917f9f5159c791eda8ba748a66d659c27e ("[PATCH v4 5/7] mm: rew=
ork non-root kmem_cache lifecycle management")
> url: https://github.com/0day-ci/linux/commits/Roman-Gushchin/mm-reparent-=
slab-memory-on-cgroup-removal/20190517-173841
>=20
>=20
> in testcase: nvml
> with following parameters:
>=20
> 	group: obj
> 	test: non-pmem
>=20
>=20
>=20
> on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -=
m 8G
>=20
> caused below changes (please refer to attached dmesg/kmsg for entire log/=
backtrace):
>=20
>=20
> +------------------------------------------------------------------------=
------+------------+------------+
> |                                                                        =
      | ff756a15f3 | e52271917f |
> +------------------------------------------------------------------------=
------+------------+------------+
> | boot_successes                                                         =
      | 5          | 4          |
> | boot_failures                                                          =
      | 861        | 852        |
> | BUG:kernel_reboot-without-warning_in_test_stage                        =
      | 738        | 163        |
> | BUG:kernel_hang_in_boot_stage                                          =
      | 120        | 122        |
> | BUG:soft_lockup-CPU##stuck_for#s                                       =
      | 4          | 1          |
> | RIP:free_unref_page                                                    =
      | 1          |            |
> | Kernel_panic-not_syncing:softlockup:hung_tasks                         =
      | 4          | 1          |
> | RIP:free_reserved_area                                                 =
      | 3          | 1          |
> | BUG:sleeping_function_called_from_invalid_context_at_mm/slab.h         =
      | 0          | 560        |
> | BUG:scheduling_while_atomic                                            =
      | 0          | 561        |
> | WARNING:at_lib/usercopy.c:#_copy_to_user                               =
      | 0          | 116        |
> | RIP:_copy_to_user                                                      =
      | 0          | 116        |
> | WARNING:at_arch/x86/kernel/fpu/signal.c:#copy_fpstate_to_sigframe      =
      | 0          | 534        |
> | RIP:copy_fpstate_to_sigframe                                           =
      | 0          | 532        |
> | WARNING:at_arch/x86/kernel/signal.c:#do_signal                         =
      | 0          | 527        |
> | RIP:do_signal                                                          =
      | 0          | 526        |
> | WARNING:at_lib/usercopy.c:#_copy_from_user                             =
      | 0          | 389        |
> | RIP:_copy_from_user                                                    =
      | 0          | 388        |
> | kernel_BUG_at_mm/vmalloc.c                                             =
      | 0          | 304        |
> | invalid_opcode:#[##]                                                   =
      | 0          | 304        |
> | RIP:__get_vm_area_node                                                 =
      | 0          | 301        |
> | Kernel_panic-not_syncing:Fatal_exception_in_interrupt                  =
      | 0          | 294        |
> | Kernel_panic-not_syncing:Aiee,killing_interrupt_handler                =
      | 0          | 155        |
> | WARNING:at_fs/read_write.c:#vfs_write                                  =
      | 0          | 15         |
> | RIP:vfs_write                                                          =
      | 0          | 15         |
> | BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rws=
em.c  | 0          | 101        |
> | BUG:sleeping_function_called_from_invalid_context_at_include/linux/uacc=
ess.h | 0          | 54         |
> | Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode=3D            =
        | 0          | 47         |
> | BUG:sleeping_function_called_from_invalid_context_at_lib/iov_iter.c    =
      | 0          | 1          |
> | BUG:sleeping_function_called_from_invalid_context_at_fs/dcache.c       =
      | 0          | 57         |
> | BUG:sleeping_function_called_from_invalid_context_at_mm/memory.c       =
      | 0          | 1          |
> | BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/mut=
ex.c  | 0          | 104        |
> | BUG:kernel_hang_in_test_stage                                          =
      | 0          | 5          |
> | WARNING:at_arch/x86/include/asm/uaccess.h:#strncpy_from_user           =
      | 0          | 4          |
> | RIP:strncpy_from_user                                                  =
      | 0          | 4          |
> | WARNING:at_fs/read_write.c:#vfs_read                                   =
      | 0          | 4          |
> | RIP:vfs_read                                                           =
      | 0          | 4          |
> | BUG:sleeping_function_called_from_invalid_context_at_mm/filemap.c      =
      | 0          | 3          |
> | BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c   =
      | 0          | 8          |
> | BUG:sleeping_function_called_from_invalid_context_at_mm/gup.c          =
      | 0          | 1          |
> | BUG:sleeping_function_called_from_invalid_context_at_include/linux/free=
zer.h | 0          | 1          |
> | BUG:sleeping_function_called_from_invalid_context_at/kb                =
      | 0          | 1          |
> +------------------------------------------------------------------------=
------+------------+------------+
>=20
>=20
> If you fix the issue, kindly add following tag
> Reported-by: kernel test robot <rong.a.chen@intel.com>

Hi!

It seems that it's caused by unbalanced rcu_read_lock(),
which already has been fixed in v5.

Thanks!

