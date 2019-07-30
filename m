Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E56AC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:21:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ABB52067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:21:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nutanix.com header.i=@nutanix.com header.b="Alpj5DIo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ABB52067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nutanix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C67198E0003; Tue, 30 Jul 2019 17:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C170F8E0001; Tue, 30 Jul 2019 17:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B06398E0003; Tue, 30 Jul 2019 17:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78EFD8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:21:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so41674594pfa.23
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:21:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=86HfZHFtQbPu6YiRJPxlg8jTq9ijupx9IYg6KNHaN90=;
        b=On8sgLrAWZmmgpZza12ze0yVkxfoqV89ZGejHMVccaV/4ySapeMZeyoFl0eI7y4chl
         ft7jk1aYVTBUvvsXeQQOlj/ALvPEDrMbObyrn4ZEAH26/2tx4z8/vdvfgy5owsqfwDf9
         6ud/j8/xpNJnE9AXvvtEbJL5ZFCd2VaW716iA5hpBK5RAIIl47gzYrkRIbdjgSoRu5AD
         t5qlMa6MN3su2MVYzbg2gLbPOBByINrd7e5qDXwI4h8H/0X3hodz11WJx2nNwIwdIjPU
         bluFNOXuyiQ1Siqaf0gopB4enR7PC5iZv7mNoEb72QsALOtImGBK71fkGCbLIYfMxpzu
         7rsA==
X-Gm-Message-State: APjAAAV+WzTAAt0qOArRbClRRssFZV29dfVVde8OFsgWX2lrLTDEKwHP
	IvWLPhTWlN9W6/cfAdvp0mOZmuucGOBdz/Mb/3y82tOpp4FzFA6DGErYMD9narsxaGpLo4UOvrb
	DhVWN26Z024qCGlqCGEKHtYD5NMvsEWrijVO3UPMW48lvTbFrtgLC0G297E5SnHuH/Q==
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr111984869plc.250.1564521676145;
        Tue, 30 Jul 2019 14:21:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxc2JRSEDSusjspq6V7nyrWhsbSObVIZyOsOVDGwZeQpZMtZrrirAgG7zsEBb2OK9NSEBx
X-Received: by 2002:a17:902:24b:: with SMTP id 69mr111984819plc.250.1564521675374;
        Tue, 30 Jul 2019 14:21:15 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564521675; cv=pass;
        d=google.com; s=arc-20160816;
        b=vCkyFB4MXwINXVwIYMXNUytwQ8+e2RvcaolnERG4IxLjRKA1lrRh4FJCjILj635X4W
         RrQuY0xeUDipRc1A6kbgiBHft+Ggq4qsXG3DqMJIpu6wUfm24Q2q8fjlbKTBft7TqVpo
         Sc97lMqQxsRoFeh9mZ1UpgLyuhZkzwTjB7AdRzzWynWHmMy33q7AE9TyIdqIcCjrmnCl
         dY5k1HZpgmU/ydQUE2SNX59T4NdKchx2E7zOwrPzy+dNHss8qWVEqmHjSXNYlYCTA+6c
         HmG8nFA464c2Q5u9Z1sXMrtZsHxtFcPBTpUMDFGUohyEmOg515w3a88kYXuYZZ+qw5DV
         FziQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=86HfZHFtQbPu6YiRJPxlg8jTq9ijupx9IYg6KNHaN90=;
        b=Eh0W3DEH07dwpDebiikbiOy89OcmW8w7hrTCHdzCtfNJnm3z2h1xnxO6K58q0KaeFL
         z+uEqumDT8m13J5+0MQAUxmv3XAiKVG/0w4w0SSWsn+0D2u466V17vcpyS3eO/h1rtel
         TQUTYSD4f9MlpKDPQE7CKV/JkYTiW1DXxpEvvQ0BCXYpVyZOkGWeRj3lhEvwnnDXAXF9
         nqKVnGpfWgrE2ri7As40XuQGgAU/t13FKqQBJMo4QLF9dYAD0GjYeYVrO38RQaz9fjMM
         9Yft/5GNdIgSyUYq/osb5d/T/6BsnArEfnVIfRxa91T6v5x30Ck5GkcnA6ZAWxEPQ9sW
         cm9w==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=Alpj5DIo;
       arc=pass (i=1 spf=pass spfdomain=nutanix.com dkim=pass dkdomain=nutanix.com dmarc=pass fromdomain=nutanix.com);
       spf=pass (google.com: domain of florian.schmidt@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=florian.schmidt@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from mx0a-002c1b01.pphosted.com (mx0a-002c1b01.pphosted.com. [148.163.151.68])
        by mx.google.com with ESMTPS id u9si28813599pjn.86.2019.07.30.14.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:21:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of florian.schmidt@nutanix.com designates 148.163.151.68 as permitted sender) client-ip=148.163.151.68;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=Alpj5DIo;
       arc=pass (i=1 spf=pass spfdomain=nutanix.com dkim=pass dkdomain=nutanix.com dmarc=pass fromdomain=nutanix.com);
       spf=pass (google.com: domain of florian.schmidt@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=florian.schmidt@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from pps.filterd (m0127837.ppops.net [127.0.0.1])
	by mx0a-002c1b01.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x6UL9uOp014791
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:21:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nutanix.com; h=from : to : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=proofpoint20171006;
 bh=86HfZHFtQbPu6YiRJPxlg8jTq9ijupx9IYg6KNHaN90=;
 b=Alpj5DIornuyUEEBsEhEGt2W4tEfgd+Kb3L6/xkhReUDmcYfYFojEosGI8QWDzH0/5bV
 Xpx3kJpybObWpjwhXZqQHI7Q0EBK1Q4W8XLL9xbLVEATkDdEgDDUXIpMa9KTifuA4nIN
 XDpqElFE9vdVrAvzQ0qac/y2GbE/GmAqpe4xru455e2NojbIHsZhG+KKdWcxv5gCKu9/
 reK3d0Q9VoPo4m2HzQCYQkS1W7byxZJlFwwaXh7i+amWCPYF06785Aw2BbdKO+S2+tPO
 VRGVqNT94RhmFfWZ+a27cXVYcQCebvGD9ZQMwmWVtUl6ed/uaaQ27gatY0f3zIAN+5KI +Q== 
Received: from nam04-co1-obe.outbound.protection.outlook.com (mail-co1nam04lp2055.outbound.protection.outlook.com [104.47.45.55])
	by mx0a-002c1b01.pphosted.com with ESMTP id 2u0jh7ebkx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:21:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=NonrfMZO71dT7xjmM9d+X5p07AjvX8hvqkFoKjZJj7nKBZEBFGd+6ptwYw3txUYXo2FeOlEUeAeF59KtdaDaimxL54/padUmkpWzwJ52JlVlY3WnehfkGTH77jJTUe7M3cnAOOnrkPfrVkSksipD4dqrPm5peiWZwMymgDltJyTiuOmCr30p6fbjnj4FpKzNh8ghAOwb/vYyqwyBKz+NnDM6V3HsXZqdhwHDtf92CDa62JOvzlCHXdhQBxQ/xa0d93O+05Xbw2syEe3UnW+nzVvAynU11HyKpqS64AVfyD74rEOSqCesChpR9KAWIHXKSIZx16iGFfkwGOgL7/sG9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=86HfZHFtQbPu6YiRJPxlg8jTq9ijupx9IYg6KNHaN90=;
 b=JuPA5GziSPQ4mpZc7h5kmzPSOi8Mz2ULbuAvR3J/sCRqdYEcKrR4F9ah/EwzkguKbY9WV5utJ3ItD+UwSivGQIudIDp9Yu5KEAdQ75Xp3y5qvbnkFcLmbatCJJG36PLmVctTWFAR1IRVY09jZ9U00rk5EIaHHWBENRLxs/yqbcRquOQLx2DXafXscoqBQF0LVe08gKA/lN57QL+hC2UqBGq/ziSoVgLhjmIZWsAUSIMivedMAJoHceBuSyRhJAtTdnYBoEVBNQg3LWOSU9/Syl+3uGD/1wHtKnT6hjReqxhIVjgwJvFkdshELf5Nm27v2K7cUK5ur7IBXyVt/VIOXw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=nutanix.com;dmarc=pass action=none
 header.from=nutanix.com;dkim=pass header.d=nutanix.com;arc=none
Received: from CY4PR0201MB3588.namprd02.prod.outlook.com (52.132.98.38) by
 CY4PR0201MB3394.namprd02.prod.outlook.com (52.132.98.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.10; Tue, 30 Jul 2019 21:21:12 +0000
Received: from CY4PR0201MB3588.namprd02.prod.outlook.com
 ([fe80::5598:9f2e:9d39:c737]) by CY4PR0201MB3588.namprd02.prod.outlook.com
 ([fe80::5598:9f2e:9d39:c737%6]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 21:21:12 +0000
From: Florian Schmidt <florian.schmidt@nutanix.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: /proc/PID/status shows VmSwap > 0 after swapoff
Thread-Topic: /proc/PID/status shows VmSwap > 0 after swapoff
Thread-Index: AQHVRxy2bbUFwcewrEClzbU+zwm+HQ==
Date: Tue, 30 Jul 2019 21:21:12 +0000
Message-ID: <97518f81-c162-0741-18a5-c54a60fc5cbe@nutanix.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [81.106.30.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e9c39a3b-c51b-40c0-4fc1-08d71533d93e
x-microsoft-antispam: 
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7167020)(7193020);SRVR:CY4PR0201MB3394;
x-ms-traffictypediagnostic: CY4PR0201MB3394:
x-microsoft-antispam-prvs: 
 <CY4PR0201MB3394DF18218204E05A3F1C4EF7DC0@CY4PR0201MB3394.namprd02.prod.outlook.com>
x-proofpoint-crosstenant: true
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: 
 SFV:NSPM;SFS:(10019020)(6029001)(396003)(39860400002)(376002)(366004)(346002)(136003)(189003)(199004)(31686004)(68736007)(66066001)(2501003)(256004)(14444005)(25786009)(6116002)(3846002)(31696002)(86362001)(6436002)(44832011)(6486002)(55236004)(486006)(6506007)(26005)(99286004)(6916009)(102836004)(71200400001)(71190400001)(2616005)(476003)(186003)(316002)(5660300002)(7736002)(305945005)(478600001)(14454004)(81166006)(6512007)(81156014)(2906002)(36756003)(5640700003)(53936002)(66476007)(2351001)(91956017)(76116006)(64756008)(8936002)(8676002)(66556008)(66446008)(66946007)(64030200001);DIR:OUT;SFP:1102;SCL:1;SRVR:CY4PR0201MB3394;H:CY4PR0201MB3588.namprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nutanix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 
 44Dqya/IjFmzCduML4sFwqS+uK7mpNGwKpGCMMHdNKvcviaDTCjKlZBaqLvIL5KewI3M/s3oNHW3iAIKQZvTE0jL54aWf7iM8KZMVxyfGiiwkGK1//Z4Rzl1HboTAld1bIQKNG3YrbzTGbq4dVYCpzFcbj297FdrbUpp9C39p/63xRhdxNCbyd51h4JmYhXVvrP+rTAID00Z1pTvRAOtLmez2h5O8aRWZLn11qGrGscwT0kNWyEh9X1uJ1Y2lWcT8VB2wUXS6Ik5+RcO4SPlpITyaCGST1QV+7MMvSxIG+Mv9Gdl1cSaJzwIeOUjYRQslnT1kYIOE74pf/j2e9Xj5pcrc1IC7svAFmzsPgWYtTV/9ss1gJiT3lI4Jl0U6oYWZIRm5kFS+Qqp/TjcUaN0Y3oHRddkbZoIGqQDkX7Wajk=
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <E9A6678E18B6AC4E9F972038DB246EDA@namprd02.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nutanix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e9c39a3b-c51b-40c0-4fc1-08d71533d93e
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 21:21:12.7030
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: bb047546-786f-4de1-bd75-24e5b6f79043
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: florian.schmidt@nutanix.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY4PR0201MB3394
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:5.22.84,1.0.8
 definitions=2019-07-30_10:2019-07-29,2019-07-30 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey,

TL;DR: is it expected behavior that the "VmSwap" output in=20
/proc/PID/status can be > 0, even without swap, and if so, why?


While experimenting with swap, I've run into a behavior that I can't=20
quite explain. My setup (tested on 5.2.4): I reboot a machine with a=20
swap partition; then I produce memory pressure by allocating lots of=20
memory and writing to each page of allocated memory. So far, so good:=20
memory is being swapped out, and that information is reflected in=20
several respective files in /proc:

$ cat /proc/swaps
Filename                     Type            Size    Used    Priority
/dev/dm-1                    partition       4194300 5644    -2

$ grep Swap /proc/meminfo
SwapCached:          600 kB
SwapTotal:       4194300 kB
SwapFree:        4188656 kB

$ grep VmSwap /proc/[0-9]*/status
/proc/1/status:VmSwap:       464 kB
/proc/257/status:VmSwap:               0 kB
/proc/272/status:VmSwap:               0 kB
/proc/498/status:VmSwap:             176 kB
/proc/499/status:VmSwap:             292 kB
/proc/528/status:VmSwap:              96 kB
/proc/531/status:VmSwap:              56 kB
/proc/535/status:VmSwap:              24 kB
/proc/537/status:VmSwap:              20 kB
/proc/541/status:VmSwap:               8 kB
/proc/542/status:VmSwap:               4 kB
/proc/548/status:VmSwap:             264 kB
/proc/561/status:VmSwap:              76 kB
/proc/564/status:VmSwap:               0 kB
/proc/565/status:VmSwap:             428 kB
/proc/578/status:VmSwap:             156 kB
/proc/579/status:VmSwap:            1272 kB
/proc/587/status:VmSwap:             196 kB
/proc/588/status:VmSwap:             452 kB
/proc/589/status:VmSwap:             908 kB
/proc/599/status:VmSwap:               0 kB
/proc/606/status:VmSwap:               0 kB


Now I disable swap (swapoff -a), which, as far as I understand, should=20
force all swapped out pages to be swapped back in. The swap is indeed gone:

$ grep Swap /proc/meminfo
SwapCached:            0 kB
SwapTotal:             0 kB
SwapFree:              0 kB

However, some processes claim to still have swapped out memory:

$ grep VmSwap /proc/[0-9]*/status
/proc/1/status:VmSwap:         0 kB
/proc/257/status:VmSwap:               0 kB
/proc/272/status:VmSwap:               0 kB
/proc/498/status:VmSwap:               0 kB
/proc/499/status:VmSwap:               0 kB
/proc/528/status:VmSwap:              12 kB
/proc/531/status:VmSwap:               8 kB
/proc/535/status:VmSwap:              16 kB
/proc/537/status:VmSwap:               0 kB
/proc/541/status:VmSwap:               0 kB
/proc/542/status:VmSwap:               0 kB
/proc/548/status:VmSwap:               0 kB
/proc/561/status:VmSwap:               0 kB
/proc/564/status:VmSwap:               0 kB
/proc/565/status:VmSwap:               0 kB
/proc/578/status:VmSwap:               0 kB
/proc/579/status:VmSwap:               0 kB
/proc/587/status:VmSwap:               0 kB
/proc/588/status:VmSwap:               0 kB
/proc/589/status:VmSwap:               0 kB
/proc/599/status:VmSwap:               0 kB
/proc/606/status:VmSwap:               0 kB

How can this be? I understand that VmSwap doesn't account for shmem, so=20
the sum of all VmSwaps might be *smaller* than (SwapTotal - SwapFree),=20
but the other way round? A quick look into the source code tells me=20
VmSwap is read from each process's MM_SWAPENTS, and while that one is=20
only updated in a few places, this leads far enough into the deep end of=20
the mm subsystem that I'm not sure I can immediately understand all=20
situations in which that value is updated.

So before I invest the time to dive into this code, I thought I'd ask=20
here: is that behavior (VmSwap output in proc can be > 0 even without=20
swap) expected, and if so, why?

Cheers,
Florian

