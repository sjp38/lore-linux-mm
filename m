Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739D0C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 21:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC5B320679
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 21:57:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="sUaULcOH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC5B320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654EC6B035A; Thu, 22 Aug 2019 17:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 605CA6B035B; Thu, 22 Aug 2019 17:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A4CD6B035C; Thu, 22 Aug 2019 17:57:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0121.hostedemail.com [216.40.44.121])
	by kanga.kvack.org (Postfix) with ESMTP id 215936B035A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 17:57:30 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AC44E52CB
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 21:57:29 +0000 (UTC)
X-FDA: 75851425818.06.cats54_70fc62edd563
X-HE-Tag: cats54_70fc62edd563
X-Filterd-Recvd-Size: 18935
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 21:57:28 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5f0fc70002>; Thu, 22 Aug 2019 14:57:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 22 Aug 2019 14:57:26 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 22 Aug 2019 14:57:26 -0700
Received: from HQMAIL110.nvidia.com (172.18.146.15) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 22 Aug
 2019 21:57:26 +0000
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (104.47.33.55) by
 HQMAIL110.nvidia.com (172.18.146.15) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Thu, 22 Aug 2019 21:57:26 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dKtylpLwtHN3IwuSiCJpoFzrw1/8TqZSrnSXxjryBxpJXXzBhVjCVsiPs+H179H2CKv2MVawWVCuv8Umvy0kMMl7+9X6G+4ojPjy+cxrug92hN7kjx34IYLcCQsyq4XbIKztixpNrufm0INNPb0WwxLQPJuLAuHB66cIDdZbbXbS/ARCWtRkY4makLDg9mIRliFRcOg1bknwCrgQfqAAVQPylwSxIILqJil/dpn0Y83GqffG2zDD9zF1HkGO8X+H/nQwdIwquGl3IRveaQJUbPYWltFCoI/NoPofQ9JeEja0mda0XR1ZcdEBVHuV2LMbOt5UYs8gb4bpOTL2QVkKJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=py2pJY4XW+bWIWVKv7N5NlfOf31bUl+ntXzoDLR9dG0=;
 b=cRKlQUIQNGRRjCske044p9+4eXpGh+7m/TjyqJHCFn4blscwx/NQpN5TZpMVksixzEWfkQLcUz22vf5BqsgPyHXTTN6Xs8UhKipfFYk7E8gRiYIYdlXYraYaPT0TDyE0Kwr6n0y8ke9JFOJ4Q4BJ4O0VSabIaYqulXKtIYtdgjhKTiAxj2pTHLOqO/Vt6ppkDXMcP1ZZFpmajgDNR/qQbtVl7aT9mdnVJKcaC15EXLQxChsRWOWs7PmThgiwDGDu0nZ38IzEvRNwYNefc/gdkxpjPT1eXf53woh5iG5onmE/pdvlFmM+Dp4DdvHz0CV/hLJmwdKuGxxm6terZKyFLg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
Received: from BYAPR12MB3015.namprd12.prod.outlook.com (20.178.53.140) by
 BYAPR12MB2999.namprd12.prod.outlook.com (20.178.53.80) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.23; Thu, 22 Aug 2019 21:57:23 +0000
Received: from BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::8d38:5355:e2aa:c1aa]) by BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::8d38:5355:e2aa:c1aa%7]) with mapi id 15.20.2178.020; Thu, 22 Aug 2019
 21:57:23 +0000
From: Nitin Gupta <nigupta@nvidia.com>
To: Mel Gorman <mgorman@techsingularity.net>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz"
	<vbabka@suse.cz>, "mhocko@suse.com" <mhocko@suse.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>, Yu Zhao
	<yuzhao@google.com>, Matthew Wilcox <willy@infradead.org>, Qian Cai
	<cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin
	<guro@fb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Jann Horn <jannh@google.com>, Johannes Weiner
	<hannes@cmpxchg.org>, Arun KS <arunks@codeaurora.org>, Janne Huttunen
	<janne.huttunen@nokia.com>, Konstantin Khlebnikov
	<khlebnikov@yandex-team.ru>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC] mm: Proactive compaction
Thread-Topic: [RFC] mm: Proactive compaction
Thread-Index: AQHVVHvSPOoT6GjwikqO8JNrunJOkacG5KOAgADaxbk=
Date: Thu, 22 Aug 2019 21:57:22 +0000
Message-ID: <BYAPR12MB3015E9DC9DDBA965372ABA6BD8A50@BYAPR12MB3015.namprd12.prod.outlook.com>
References: <20190816214413.15006-1-nigupta@nvidia.com>,<20190822085135.GS2739@techsingularity.net>
In-Reply-To: <20190822085135.GS2739@techsingularity.net>
Accept-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=nigupta@nvidia.com; 
x-originating-ip: [216.228.112.21]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aa04bb03-6877-43dc-6d5a-08d7274bb65e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR12MB2999;
x-ms-traffictypediagnostic: BYAPR12MB2999:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <BYAPR12MB29991FC56CB046FF178CED56D8A50@BYAPR12MB2999.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01371B902F
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(39860400002)(396003)(136003)(376002)(366004)(346002)(199004)(189003)(13464003)(4326008)(99286004)(229853002)(66476007)(25786009)(7736002)(102836004)(71200400001)(8676002)(66946007)(76116006)(6436002)(64756008)(966005)(9686003)(81166006)(7696005)(81156014)(446003)(14454004)(316002)(186003)(3846002)(55016002)(6116002)(86362001)(52536014)(6916009)(66556008)(11346002)(66446008)(33656002)(305945005)(478600001)(74316002)(2906002)(76176011)(54906003)(6506007)(53546011)(6306002)(71190400001)(7416002)(26005)(476003)(14444005)(256004)(6246003)(8936002)(486006)(5660300002)(66066001)(53936002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB2999;H:BYAPR12MB3015.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nvidia.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: kVmvdq6wbTczOinXLcxuSTqhl0eZOWmbu/wjo0jfqR7DeIYCpcRDEoPLXv3C6Jpi3S5Z/IngW6+QBhqfFhPK+8JVK2tuqbLu6+0ob7EfPPY+5+5evVG52ftE1ZvYQc71dDugio/pve+SYpAdgZ90W+avS7iDqwqSGDlnOKQnS1zotrG/ckXS6YTJ8XznAiI9ImpTClPdsqDcMhiXbczT8NSalIpRig0xxNdSzWKMmvXvdHjjYTzCOURX+sGOwJmiPyIM7n2RoheyGJVyLWYyYlNB8qWOtQTc2K+QRmNmk2hCbbgFrsEj4EPHcbiC1GNNRolN3fXq2QKZ7rFgqzU9BzFfQZeTND4IM4QiuKTHWUVkNtSGbLpDmhtCxZQxsCZIB11y/2fW1nEqeB+qRnD/M1UZsCarcueEyrF1JCjEQUY=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: aa04bb03-6877-43dc-6d5a-08d7274bb65e
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Aug 2019 21:57:22.9178
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 3sgyyf1GEH5NaoStERxa9zy34/AmHYPwrzslNUSjS7HrAxPbKnW/eCVCTcFJHWlFiQfGQ3E8PFSi8Dkc0fISDQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB2999
X-OriginatorOrg: Nvidia.com
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566511047; bh=py2pJY4XW+bWIWVKv7N5NlfOf31bUl+ntXzoDLR9dG0=;
	h=X-PGP-Universal:ARC-Seal:ARC-Message-Signature:
	 ARC-Authentication-Results:From:To:CC:Subject:Thread-Topic:
	 Thread-Index:Date:Message-ID:References:In-Reply-To:
	 Accept-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 authentication-results:x-originating-ip:x-ms-publictraffictype:
	 x-ms-office365-filtering-correlation-id:x-microsoft-antispam:
	 x-ms-traffictypediagnostic:x-ms-exchange-purlcount:
	 x-microsoft-antispam-prvs:x-ms-oob-tlc-oobclassifiers:
	 x-forefront-prvs:x-forefront-antispam-report:received-spf:
	 x-ms-exchange-senderadcheck:x-microsoft-antispam-message-info:
	 x-ms-exchange-transport-forked:MIME-Version:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:X-MS-Exchange-CrossTenant-mailboxtype:
	 X-MS-Exchange-CrossTenant-userprincipalname:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:X-OriginatorOrg:
	 Content-Language:Content-Type:Content-Transfer-Encoding;
	b=sUaULcOHlzX5/aOzg24OKtgpIUuTXyRYmGIgaNGBLQhqHweid12szfyBU8oWnbENI
	 iWkPSCNqb+j54Q7vyRryuvr/+fzDXJCDuBdMJDaB6cXQhWNWYV7mLx4MBdB6arLXuZ
	 Y6YRfFILfGpLDPsCzAYXtYm+/p+7/Znevg7t5lXUyYD1JYYfVdBxoRmYRXJyf+07Yk
	 LK6QVJQmySJ7BmQUWlHe1VaR62sa3iQN+uTTUAeQTLKek2FJAcuTS3M8bnUiOx5HIs
	 BarRbKDd06NC2sXUoK6LM1lWu0DMN+nhEU3rs/Rngclw/E72YBzpnZPsyTJJZYWmdy
	 UEiLxEU5KM7Vg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org <owner-linux-mm@kvack.org> On Behalf
> Of Mel Gorman
> Sent: Thursday, August 22, 2019 1:52 AM
> To: Nitin Gupta <nigupta@nvidia.com>
> Cc: akpm@linux-foundation.org; vbabka@suse.cz; mhocko@suse.com;
> dan.j.williams@intel.com; Yu Zhao <yuzhao@google.com>; Matthew Wilcox
> <willy@infradead.org>; Qian Cai <cai@lca.pw>; Andrey Ryabinin
> <aryabinin@virtuozzo.com>; Roman Gushchin <guro@fb.com>; Greg Kroah-
> Hartman <gregkh@linuxfoundation.org>; Kees Cook
> <keescook@chromium.org>; Jann Horn <jannh@google.com>; Johannes
> Weiner <hannes@cmpxchg.org>; Arun KS <arunks@codeaurora.org>; Janne
> Huttunen <janne.huttunen@nokia.com>; Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru>; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org
> Subject: Re: [RFC] mm: Proactive compaction
>=20
> On Fri, Aug 16, 2019 at 02:43:30PM -0700, Nitin Gupta wrote:
> > For some applications we need to allocate almost all memory as
> > hugepages. However, on a running system, higher order allocations can
> > fail if the memory is fragmented. Linux kernel currently does
> > on-demand compaction as we request more hugepages but this style of
> > compaction incurs very high latency. Experiments with one-time full
> > memory compaction (followed by hugepage allocations) shows that kernel
> > is able to restore a highly fragmented memory state to a fairly
> > compacted memory state within <1 sec for a 32G system. Such data
> > suggests that a more proactive compaction can help us allocate a large
> > fraction of memory as hugepages keeping allocation latencies low.
> >
>=20
> Note that proactive compaction may reduce allocation latency but it is no=
t
> free either. Even though the scanning and migration may happen in a kerne=
l
> thread, tasks can incur faults while waiting for compaction to complete i=
f the
> task accesses data being migrated. This means that costs are incurred by
> applications on a system that may never care about high-order allocation
> latency -- particularly if the allocations typically happen at applicatio=
n
> initialisation time.  I recognise that kcompactd makes a bit of effort to
> compact memory out-of-band but it also is typically triggered in response=
 to
> reclaim that was triggered by a high-order allocation request. i.e. the w=
ork
> done by the thread is triggered by an allocation request that hit the slo=
w
> paths and not a preemptive measure.
>=20

Hitting the slow path for every higher-order allocation is a signification
performance/latency issue for applications that requires a large number of
these allocations to succeed in bursts. To get some concrete numbers, I
made a small driver that allocates as many hugepages as possible and
measures allocation latency:

The driver first tries to allocate hugepage using GFP_TRANSHUGE_LIGHT
(referred to as "Light" in the table below) and if that fails, tries to
allocate with `GFP_TRANSHUGE | __GFP_RETRY_MAYFAIL` (referred to as
"Fallback" in table below). We stop the allocation loop if both methods
fail.

Table-1: hugepage allocation latencies on vanilla 5.3.0-rc5. All latencies
are in microsec.

| GFP/Stat |        Any |   Light |   Fallback |
|--------: | ---------: | ------: | ---------: |
|    count |       9908 |     788 |       9120 |
|      min |        0.0 |     0.0 |     1726.0 |
|      max |   135387.0 |   142.0 |   135387.0 |
|     mean |    5494.66 |    1.83 |    5969.26 |
|   stddev |   21624.04 |    7.58 |   22476.06 |

As you can see, the mean and stddev of allocation is extremely high with
the current approach of on-demand compaction.

The system was fragmented from a userspace program as I described in this
patch description. The workload is mainly anonymous userspace pages which
as easy to move around. I intentionally avoided unmovable pages in this
test to see how much latency do we incur just by hitting the slow path for
a majority of allocations.


> > For a more proactive compaction, the approach taken here is to define
> > per page-order external fragmentation thresholds and let kcompactd
> > threads act on these thresholds.
> >
> > The low and high thresholds are defined per page-order and exposed
> > through sysfs:
> >
> >   /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}
> >
>=20
> These will be difficult for an admin to tune that is not extremely famili=
ar with
> how external fragmentation is defined. If an admin asked "how much will
> stalls be reduced by setting this to a different value?", the answer will=
 always
> be "I don't know, maybe some, maybe not".
>

Yes, this is my main worry. These values can be set to emperically
determined values on highly specialized systems like database appliances.
However, on a generic system, there is no real reasonable value.


Still, at the very least, I would like an interface that allows compacting
system to a reasonable state. Something like:

    compact_extfrag(node, zone, order, high, low)

which start compaction if extfrag > high, and goes on till extfrag < low.

It's possible that there are too many unmovable pages mixed around for
compaction to succeed, still it's a reasonable interface to expose rather
than forced on-demand style of compaction (please see data below).

How (and if) to expose it to userspace (sysfs etc.) can be a separate
discussion.


> > Per-node kcompactd thread is woken up every few seconds to check if
> > any zone on its node has extfrag above the extfrag_high threshold for
> > any order, in which case the thread starts compaction in the backgrond
> > till all zones are below extfrag_low level for all orders. By default
> > both these thresolds are set to 100 for all orders which essentially
> > disables kcompactd.
> >
> > To avoid wasting CPU cycles when compaction cannot help, such as when
> > memory is full, we check both, extfrag > extfrag_high and
> > compaction_suitable(zone). This allows kcomapctd thread to stays
> > inactive even if extfrag thresholds are not met.
> >
>=20
> There is still a risk that if a system is completely fragmented that it m=
ay
> consume CPU on pointless compaction cycles. This is why compaction from
> kernel thread context makes no special effort and bails relatively quickl=
y and
> assumes that if an application really needs high-order pages that it'll i=
ncur
> the cost at allocation time.
>=20

As data in Table-1 shows, on-demand compaction can add high latency to
every single allocation. I think it would be a significant improvement (see
Table-2) to at least expose an interface to allow proactive compaction
(like compaction_extfrag), which a driver can itself run in background. Thi=
s
way, we need not add any tunables to the kernel itself and leave compaction
decision to specialized kernel/userspace monitors.


> > This patch is largely based on ideas from Michal Hocko posted here:
> > https://lore.kernel.org/linux-
> mm/20161230131412.GI13301@dhcp22.suse.cz
> > /
> >
> > Testing done (on x86):
> >  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} =3D {25, 30=
}
> > respectively.
> >  - Use a test program to fragment memory: the program allocates all
> > memory  and then for each 2M aligned section, frees 3/4 of base pages
> > using  munmap.
> >  - kcompactd0 detects fragmentation for order-9 > extfrag_high and
> > starts  compaction till extfrag < extfrag_low for order-9.
> >
>=20
> This is a somewhat optimisitic allocation scenario. The interesting ones =
are
> when a system is fragmenteed in a manner that is not trivial to resolve -=
- e.g.
> after a prolonged period of time with unmovable/reclaimable allocations
> stealing pageblocks. It's also fairly difficult to analyse if this is hel=
ping
> because you cannot measure after the fact how much time was saved in
> allocation time due to the work done by kcompactd. It is also hard to
> determine if the sum of the stalls incurred by proactive compaction is lo=
wer
> than the time saved at allocation time.
>=20
> I fear that the user-visible effect will be times when there are very sho=
rt but
> numerous stalls due to proactive compaction running in the background tha=
t
> will be hard to detect while the benefits may be invisible.
>=20

Pro-active compaction can be done in a non-time-critical context, so to
estimate its benefits we can just compare data from Table-1 the same run,
under a similar fragmentation state, but with this patch applied:


Table-2: hugepage allocation latencies with this patch applied on
5.3.0-rc5.

| GFP_Stat |        Any |     Light |   Fallback |
| --------:| ----------:| ---------:| ----------:|
|   count  |   12197.0  |  11167.0  |    1030.0  |
|     min  |       2.0  |      2.0  |       5.0  |
|     max  |  361727.0  |     26.0  |  361727.0  |
|    mean  |    366.05  |     4.48  |   4286.13  |
|   stddev |   4575.53  |     1.41  |  15209.63  |


We can see that mean latency dropped to 366us compared with 5494us before.

This is an optimistic scenario where there was a little mix of unmovable
pages but still the data shows that in case compaction can succeed,
pro-active compaction can give signification reduction higher-order
allocation latencies.


> > The patch has plenty of rough edges but posting it early to see if I'm
> > going in the right direction and to get some early feedback.
> >
>=20
> As unappealing as it sounds, I think it is better to try improve the allo=
cation
> latency itself instead of trying to hide the cost in a kernel thread. It'=
s far
> harder to implement as compaction is not easy but it would be more
> obvious what the savings are by looking at a histogram of allocation late=
ncies
> -- there are other metrics that could be considered but that's the obviou=
s
> one.
>=20

Improving allocation latencies in itself would be a separate effort. In
case memory is full or fragmented we have to deal with reclaim or
compaction to make allocation (esp. higher-order) succeed.  In particular,
forcing compaction to be done only on-demand is in my opinion not the right
approach. As I detailed above, at the very minimum, we need an interface
like `compact_extfrag` which can leave the decision on specific
kernel/userspace drivers on how pro-active you want compaction to be.

