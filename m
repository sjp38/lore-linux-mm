Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16293C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:05:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0C6B25D4E
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:05:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nutanix.com header.i=@nutanix.com header.b="Y57PsBee"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0C6B25D4E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nutanix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FC9A6B026F; Thu, 30 May 2019 12:05:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AC546B0271; Thu, 30 May 2019 12:05:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372B56B0272; Thu, 30 May 2019 12:05:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 172D26B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:05:46 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id l193so5399672ita.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:05:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=YEJ1nBVURIzQa5lLvibu1r+9KaYBRTUFgzTW8A4TAJw=;
        b=aF4I24BCfz9eBydqg4O0FsjoH6x+pBoXNkBBx92i1Y8n3sM4mRACrU3Q7FtIoGGeSb
         l06hakc/MmcVamvsC2kgxFLr3ffWVR1SgDBlAntogWRMRfsFcQpo2zYhWZGRlaCavynv
         4IwGkxKsXDBs2WFTzo6A4FFVIKIY74qP83FWDntIXA7RhcI5NZPuAfSm/0iMf1TFs1Kk
         7Sma2NSHvi10+os0AMteXXQosT9hR8mBaIrnt0BzpMmMLRbork36T7deg9cZ44lRe2DA
         XCCKL9QHseRTQy4LTC21o0GxQKDMqkV1GtXjveRvz9OJqffgLbQEMB3CdS5elCtdp1Oi
         VH4Q==
X-Gm-Message-State: APjAAAWaAB32UIrOIiEkp/tGGlbIuS861zs8/T91eUFO5RaaeY5D4jLB
	U/UFh0fLUAKbEeXCPuthkztTB8XgPSh4YP0Vodn7RHMU0CZnTsZ+INGTn0lqqTdkcSYhFzfus08
	lLvEpA42/lH1gmFZsV8XTpYIXXncT74qwT4DGRLERfUt+LbxtylkppsPK4mC8thuIgw==
X-Received: by 2002:a02:3002:: with SMTP id q2mr2848332jaq.30.1559232345698;
        Thu, 30 May 2019 09:05:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE3QLQ7HEMp40GTW0mBs00Zrm39EfQNXB/BeIZ6AU3tM7rdI7c+3Ui79oAJT9WqvLIv6sy
X-Received: by 2002:a02:3002:: with SMTP id q2mr2848225jaq.30.1559232344268;
        Thu, 30 May 2019 09:05:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559232344; cv=none;
        d=google.com; s=arc-20160816;
        b=Bu9tO7GN3dGhyV9Fr6ytvo2+PKOPJRASCsQjBU5Spsy5oliQ6y2gyOhLV/L8YIWVvB
         WOxmaXJykmr+jWcFdA1i6uRZR+awxISINgC7QxNchFELJbkvT/SbI+4Z7ctuKJT6N1eM
         kU8xvUq86pIYtoVU5Kbvx9vc41GhIl/0rFIVzzbHCLjFWhEtTLvOreaFaHor5m0y1G6k
         /X5Q3pR7tRXlJDuPKB+LJ+smHq4d9PB5Ct1cjVzuJ5zUCf2EkQnNgoCqibpFB44iH8EP
         PWo9qwHe8LpHws3udzfYZMEe2HUZtu1cE2c6QZ02epADmMOfrjk/IuN8F/8Vd9A90R0n
         TWyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=YEJ1nBVURIzQa5lLvibu1r+9KaYBRTUFgzTW8A4TAJw=;
        b=eyij1AuVukTeiYxdbqkT63bexpTl5gFLo4TZe6fyBQPbnIvCYvqBkd/eFlcqfPABgB
         87lqnn5GOa+gUKcL/M0xARe5gpy8bz0352ujyLbxgU3azbmAxAclqB7VA4inShpMrPA2
         ILm5NlzLAv1nvPCZwrE4CYjwfc+Yt6TVZ0zpzYOSXu9SL74t7Z5hRubqA9yLHKpL/vMD
         BUqsfEPJcNIE6K7FKOux7s8HO/9ed3FfgDvbcwa/TsKxbYD9V8ZwyGlHwalx9O25mIeT
         MTpFLaOHfvjfc8JUUCzEHifyxpnx22OqYWQxqHtR90M4+NP7sCgRVDytHThUwrW2gskt
         Y2nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=Y57PsBee;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.155.12 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from mx0b-002c1b01.pphosted.com (mx0b-002c1b01.pphosted.com. [148.163.155.12])
        by mx.google.com with ESMTPS id w8si2071888ior.82.2019.05.30.09.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 09:05:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.155.12 as permitted sender) client-ip=148.163.155.12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=Y57PsBee;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.155.12 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from pps.filterd (m0127844.ppops.net [127.0.0.1])
	by mx0b-002c1b01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UG4krh028220
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:05:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nutanix.com; h=from : to : cc :
 subject : date : message-id : content-type : content-transfer-encoding :
 mime-version; s=proofpoint20171006;
 bh=YEJ1nBVURIzQa5lLvibu1r+9KaYBRTUFgzTW8A4TAJw=;
 b=Y57PsBeeLCmyuVFydvHbroDnOIeCu/vDxvdCHUgIJaSqIPNX9A3dh3X1PI6wxHCamQQI
 OTtfoR7PyvCRrAieRcE2YYQQdZJwZFy6lc1w0HOk+yJYIPuBgqT9icGqZbyovC9qxBVW
 c6hf6N7aFHR3wN+lcbRpcElPapxEhXc2cuVcZpAk16aSY+coFK6EgsqJhucKs8U2jWO+
 /AIy3TrW6mzaewSRuJZw2tiA6qZ84P4xN6tdh4kYwZ2EHEcetflpQdgxzsx1qCXignAj
 S3G2v0RDDsEvPCRYnCQgJVV480C5Ys5uxwluwzeYQOzVZgNqkksP5/UpdNn22XfqyDu4 Yg== 
Received: from nam05-co1-obe.outbound.protection.outlook.com (mail-co1nam05lp2050.outbound.protection.outlook.com [104.47.48.50])
	by mx0b-002c1b01.pphosted.com with ESMTP id 2stdk70ef3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:05:43 -0700
Received: from MN2PR02MB6205.namprd02.prod.outlook.com (52.132.174.26) by
 MN2PR02MB5773.namprd02.prod.outlook.com (20.179.98.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.18; Thu, 30 May 2019 16:05:41 +0000
Received: from MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd]) by MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd%3]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 16:05:41 +0000
From: Thanos Makatos <thanos.makatos@nutanix.com>
To: linux-mm <linux-mm@kvack.org>
CC: Felipe Franciosi <felipe@nutanix.com>,
        Swapnil Ingle
	<swapnil.ingle@nutanix.com>
Subject: satisfying an mmap call with memory belonging to another process
Thread-Topic: satisfying an mmap call with memory belonging to another process
Thread-Index: AdUW+jwoclyeEpf8QfitdN64NXPT9g==
Date: Thu, 30 May 2019 16:05:41 +0000
Message-ID: 
 <MN2PR02MB620509D3649ABE9CDA6E08B08B180@MN2PR02MB6205.namprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [62.254.189.133]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 99decab9-f85e-4f67-b955-08d6e518aa18
x-microsoft-antispam: 
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MN2PR02MB5773;
x-ms-traffictypediagnostic: MN2PR02MB5773:
x-proofpoint-crosstenant: true
x-microsoft-antispam-prvs: 
 <MN2PR02MB57730A67A6472BA48274D5838B180@MN2PR02MB5773.namprd02.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: 
 SFV:NSPM;SFS:(10019020)(366004)(376002)(136003)(39860400002)(396003)(346002)(199004)(189003)(81156014)(81166006)(8936002)(6506007)(7736002)(99286004)(86362001)(186003)(7696005)(26005)(107886003)(5660300002)(305945005)(3846002)(74316002)(2906002)(68736007)(8676002)(6916009)(6116002)(52536014)(44832011)(102836004)(486006)(476003)(55016002)(54906003)(66556008)(64756008)(6436002)(66476007)(4326008)(71190400001)(71200400001)(478600001)(33656002)(76116006)(66446008)(66946007)(73956011)(14444005)(53936002)(256004)(66066001)(25786009)(316002)(9686003)(14454004)(64030200001);DIR:OUT;SFP:1102;SCL:1;SRVR:MN2PR02MB5773;H:MN2PR02MB6205.namprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nutanix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 
 lKQOjVZ6mKwRShEVyNf27L0So3shZpA9n1Xdjo/Ehh2mtItUaoxBTyYul/6d0Hf9t0Hp8RBLriwfNTgpIEtHhMsU2GFSXzWw+Bi//epdwCnmAs0hZ4p0Hj6PSW5C9vhXiNjUbrTSXe3u3cbY7ciIie+wZ89yIrcPInKDIkLgysSo8CgCSCQLOh6voEn0rMnEjaeSdPS3iRLmeAFCfkWFSBSEcIgGnxfQssKi5gIdTgJ2ex9+DLRSr0drPbaEQJLpeTXwND7fx9atQpPYgrVuXrxbmOgXeBZi71gt29MP/Ozc1JAmZEY/yO/xIxOH/bgvs9ifUwDlfyBuew2HC2tr2U230os3cqPwV764w1C0eHFTBpMZu0S8KgocOMSc28t4c7T3bVBraX5dWNLGEmDHv9f6fMMmAbcTGoz+8XT/UjY=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nutanix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 99decab9-f85e-4f67-b955-08d6e518aa18
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 16:05:41.3787
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: bb047546-786f-4de1-bd75-24e5b6f79043
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: thanos.makatos@nutanix.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR02MB5773
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_09:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I'm prototyping a device driver that is backed by a userspace process (serv=
er) instead of a physical device. In this use case, the client userspace pr=
ocess is supposed to mmap device memory. I does so by opening a custom devi=
ce node and then calling mmap, where I have provided my own .mmap callback.=
 When the custom device driver receives such a call, it instructs the serve=
r process to allocate the necessary memory using mmap(NULL, size, PROT_READ=
 | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0). It then passes the virtu=
al address of the server process back into the custom device driver, figure=
s out which pages back this memory by calling get_user_pages_fast(), and th=
en finally inserts these pages to the VMA provided by the mmap call by call=
ing vm_insert_page().

This implementation works, however if one of the processes exits without cl=
eanly unmapping this memory (e.g. it crashes), I get the following stack tr=
ace:

[  996.588022] ---[ end trace 6193ca2409940966 ]---
[  996.588770] BUG: Bad page cache in process a.out  pfn:1f3d38
[  996.589422] page:ffffdc4287cf4e00 count:5 mapcount:1 mapping:ffff9ce6981=
e5f20 index:0x0
[  996.590110] shmem_aops
[  996.590112] flags: 0x2ffff8000080037(locked|referenced|uptodate|lru|acti=
ve|swapbacked)
[  996.591498] raw: 02ffff8000080037 ffffdc4287d22dc8 ffffdc4287d73748 ffff=
9ce6981e5f20
[  996.592179] raw: 0000000000000000 0000000000000000 0000000500000000 ffff=
9ce67c4d5000
[  996.592843] page dumped because: still mapped when deleted
[  996.593458] page->mem_cgroup:ffff9ce67c4d5000
[  996.594069] CPU: 1 PID: 670 Comm: a.out Tainted: G        W  O      5.1.=
0-rc4+ #3
[  996.594650] Hardware name: Nutanix AHV, BIOS 1.9.1-5.el6 04/01/2014
[  996.595260] Call Trace:
[  996.595794]  dump_stack+0x5c/0x7b
[  996.596358]  unaccount_page_cache_page+0x132/0x1c0
[  996.596868]  __delete_from_page_cache+0x39/0x200
[  996.597368]  ? xas_load+0x9/0x80
[  996.597882]  ? _cond_resched+0x16/0x40
[  996.598372]  ? down_write+0xe/0x40
[  996.598859]  ? unmap_mapping_pages+0x5e/0x130
[  996.599328]  delete_from_page_cache+0x45/0x70
[  996.599783]  truncate_inode_page+0x22/0x30
[  996.600275]  shmem_undo_range+0x1fd/0x840
[  996.600743]  ? native_usergs_sysret64+0xf/0x10
[  996.601207]  shmem_truncate_range+0x16/0x40
[  996.601671]  shmem_evict_inode+0xad/0x190
[  996.602130]  evict+0xc1/0x1c0
[  996.602561]  __dentry_kill+0xd3/0x180
[  996.602990]  dentry_kill+0x4d/0x1b0
[  996.603408]  dput+0xd7/0x130
[  996.603839]  __fput+0x108/0x230
[  996.604295]  task_work_run+0x8a/0xb0
[  996.604714]  do_exit+0x2df/0xbc0
[  996.605128]  ? vfs_write+0x148/0x190
[  996.605525]  do_group_exit+0x3a/0xa0
[  996.605946]  __x64_sys_exit_group+0x14/0x20
[  996.606358]  do_syscall_64+0x55/0x100
[  996.606763]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  996.607168] RIP: 0033:0x7f05826ca618
[  996.607573] Code: Bad RIP value.
[  996.608013] RSP: 002b:00007ffd59408798 EFLAGS: 00000246 ORIG_RAX: 000000=
00000000e7
[  996.608468] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f05826=
ca618
[  996.608913] RDX: 0000000000000000 RSI: 000000000000003c RDI: 00000000000=
00000
[  996.609338] RBP: 00007f05829a78e0 R08: 00000000000000e7 R09: fffffffffff=
fff98
[  996.609754] R10: 00007ffd59408718 R11: 0000000000000246 R12: 00007f05829=
a78e0
[  996.610165] R13: 00007f05829acc20 R14: 0000000000000000 R15: 00000000000=
00000
[  996.610576] Disabling lock debugging due to kernel taint

My understanding is that there is some mix up with how the mmap'ed memory i=
s set up for the client process, hence the "still mapped when deleted" as t=
he reason stated for the failure. My guess is that the VMA/page of the serv=
er mmap (the one the sever process does using -1 as the fd) seems to be ass=
ociated with /dev/zero or shm (?), while the VMA/page of the client is asso=
ciated with the device file (I'm not even sure I fully understand the probl=
em).

One way I though of fixing this is to make the server process allocate memo=
ry by mmap'ing using the device fd instead of -1, so that both VMAs/pages a=
re against the same struct file. Obviously I'll have to somehow differentia=
te between an mmap belonging to the client and an mmap belonging to the ser=
ver. Would this solve the problem? Is there another way of solving this?

