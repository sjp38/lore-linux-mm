Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0A4BC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 559DB22DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 23:24:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="AWZWF9nT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 559DB22DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E43286B02B9; Wed, 21 Aug 2019 19:24:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF3486B02BA; Wed, 21 Aug 2019 19:24:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBAA56B02BB; Wed, 21 Aug 2019 19:24:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id A66AD6B02B9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:24:13 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 1469D8248AAF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:24:13 +0000 (UTC)
X-FDA: 75848015586.07.women72_7bc5b60195b01
X-HE-Tag: women72_7bc5b60195b01
X-Filterd-Recvd-Size: 12957
Received: from nat-hk.nvidia.com (nat-hk.nvidia.com [203.18.50.4])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:24:10 +0000 (UTC)
Received: from hkpgpgate102.nvidia.com (Not Verified[10.18.92.100]) by nat-hk.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5dd2920000>; Thu, 22 Aug 2019 07:24:03 +0800
Received: from HKMAIL104.nvidia.com ([10.18.16.13])
  by hkpgpgate102.nvidia.com (PGP Universal service);
  Wed, 21 Aug 2019 16:24:02 -0700
X-PGP-Universal: processed;
	by hkpgpgate102.nvidia.com on Wed, 21 Aug 2019 16:24:02 -0700
Received: from HKMAIL102.nvidia.com (10.18.16.11) by HKMAIL104.nvidia.com
 (10.18.16.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 23:24:02 +0000
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (104.47.41.55) by
 HKMAIL102.nvidia.com (10.18.16.11) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Wed, 21 Aug 2019 23:24:02 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=b/VFJLtNlxlNwsAhyqLh0QR8R8V7ugguZUdlrg/BBQUZLkKlTE7e++zRxe85GuO9s4mgHlcYL/31LKlYNuyRLjlMMZ2Y8JoyaEDPCU8cWHCrIwj6NAkEncurTxkTukTdhj3AZJoUNLD+dfwDmFa4us5xPpve9ksb8sl3X0aM/briPnpRmK4yLqrl47SoZQHAgDut1cba2dd6+4QVLOItNrhQ5Xruj1AOBXQgqAorS5qQiLbg+q2kqK+M6xihpvUZsszOO4eGxWoal+HjJ9+n2eCanyOFt2fX0G1nUJ59jyQ+OA2jcarMAtKWX6vm9QDjb9fvGvnNZEryAds+WN1BMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ql+aqOwMM6SSITAe+zRaZNVJoxvLQftDPEGPlB447JA=;
 b=O9r9IAKC57CXB8xjzda1nPGDQwfoZlGhWBYmLGhkR7dnC/jYIOfz8ikU4YBracePUpZZhvDME850+D4z4GnFrom2gP0OJ6LFOVw6PjgxHGY2jjmq1s66Rn9s5d6BtJEcjArkM11oYpJaRIcvit/RzJtgbkeanIdim6Lp+7/3BflJ42aQm7XGkb4w9LrM+PV3tCng5U1tICUcukt8GSWeWv567MbRlW/xuZVMGvLO5igA1Of3NT1+2bWXkcwivCwRXh1vuBxhruOoCOTWKM8EAlBasS3b2WJ08Ssi1vZ1wceU+uMXJhDexCN8V9oNd3JpjXGIhzd5XAKFU3uq8h0kTQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
Received: from BYAPR12MB3015.namprd12.prod.outlook.com (20.178.53.140) by
 BYAPR12MB3333.namprd12.prod.outlook.com (20.178.55.94) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Wed, 21 Aug 2019 23:23:57 +0000
Received: from BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::8d38:5355:e2aa:c1aa]) by BYAPR12MB3015.namprd12.prod.outlook.com
 ([fe80::8d38:5355:e2aa:c1aa%7]) with mapi id 15.20.2178.020; Wed, 21 Aug 2019
 23:23:57 +0000
From: Nitin Gupta <nigupta@nvidia.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz"
	<vbabka@suse.cz>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>, Yu Zhao
	<yuzhao@google.com>, Qian Cai <cai@lca.pw>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, Jann Horn
	<jannh@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Arun KS
	<arunks@codeaurora.org>, Janne Huttunen <janne.huttunen@nokia.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [RFC] mm: Proactive compaction
Thread-Topic: [RFC] mm: Proactive compaction
Thread-Index: AQHVVHvSPOoT6GjwikqO8JNrunJOkacEogGAgAGdSZA=
Date: Wed, 21 Aug 2019 23:23:56 +0000
Message-ID: <BYAPR12MB3015726BEF236D567FCFB29CD8AA0@BYAPR12MB3015.namprd12.prod.outlook.com>
References: <20190816214413.15006-1-nigupta@nvidia.com>
 <20190820222035.GC4949@bombadil.infradead.org>
In-Reply-To: <20190820222035.GC4949@bombadil.infradead.org>
Accept-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels: MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Enabled=True;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_SiteId=43083d15-7273-40c1-b7db-39efd9ccc17a;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Owner=nigupta@nvidia.com;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_SetDate=2019-08-21T23:23:54.4134724Z;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Name=Unrestricted;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Application=Microsoft Azure
 Information Protection;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Extended_MSFT_Method=Automatic;
 Sensitivity=Unrestricted
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=nigupta@nvidia.com; 
x-originating-ip: [216.228.112.22]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f549518d-fd12-4fd4-2bc2-08d7268ea3cc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR12MB3333;
x-ms-traffictypediagnostic: BYAPR12MB3333:
x-microsoft-antispam-prvs: <BYAPR12MB33336101ABF09C823DF6A02ED8AA0@BYAPR12MB3333.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0136C1DDA4
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(366004)(136003)(39860400002)(346002)(396003)(189003)(199004)(13464003)(52536014)(5660300002)(14444005)(256004)(26005)(64756008)(66446008)(102836004)(66946007)(6506007)(229853002)(7736002)(66556008)(66476007)(305945005)(66066001)(9686003)(76116006)(186003)(53546011)(55016002)(478600001)(8936002)(99286004)(54906003)(446003)(25786009)(11346002)(476003)(7416002)(2906002)(76176011)(14454004)(316002)(4326008)(53936002)(6246003)(7696005)(33656002)(74316002)(86362001)(6436002)(6916009)(486006)(71190400001)(3846002)(6116002)(8676002)(71200400001)(81156014)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3333;H:BYAPR12MB3015.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nvidia.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: z3ZO8slvvrI05UDd6GOWIbhrYksH6tuPpwBOH90BxjSMi+xQ8FWg00AwOrZEk6JINx53yNJI9KISL2VfTKKV4vty6ycfG2fe2vuDRr3OcaPHy+n+C1Fm21AJpeAXAdumJbXXaGz/oEplmZmFWzPiKLIqGRLR2ssZUth+PXf8GPuMI6ExeWNKUyIr63RO9VLw3iB7PhFwRBCnuFK8Z9pzKgh1TmIITxjj20xzS2zRY6KrA7O8xSNyPzpcH5IhzGN97E2SL4cHjUcKp8VW91lfwEapoR91U64rUeZrb8E3aaDC21q64MclChvH/S6bC+tDYH2FUJb0idyhQpXM/C05NWAO47uKbV5DpzTLQ0omiyEaUhWVH27dW8G9FX1cMQ6Jl+jQfaekyVFMtAZQvPJfu23b8YlKeIrCsb3koQ1ql48=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f549518d-fd12-4fd4-2bc2-08d7268ea3cc
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Aug 2019 23:23:56.9294
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: C+78dX2Daz6ruM9ErANKoBlh1O4u+LjUrHRKcxxfBNxaRxDdEFaZ3ehxjCkhhZRp8vTOcSyZUvquh/oT/k5yZg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3333
X-OriginatorOrg: Nvidia.com
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566429843; bh=Ql+aqOwMM6SSITAe+zRaZNVJoxvLQftDPEGPlB447JA=;
	h=X-PGP-Universal:ARC-Seal:ARC-Message-Signature:
	 ARC-Authentication-Results:From:To:CC:Subject:Thread-Topic:
	 Thread-Index:Date:Message-ID:References:In-Reply-To:
	 Accept-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:msip_labels:
	 authentication-results:x-originating-ip:x-ms-publictraffictype:
	 x-ms-office365-filtering-correlation-id:x-microsoft-antispam:
	 x-ms-traffictypediagnostic:x-microsoft-antispam-prvs:
	 x-ms-oob-tlc-oobclassifiers:x-forefront-prvs:
	 x-forefront-antispam-report:received-spf:
	 x-ms-exchange-senderadcheck:x-microsoft-antispam-message-info:
	 x-ms-exchange-transport-forked:MIME-Version:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:X-MS-Exchange-CrossTenant-mailboxtype:
	 X-MS-Exchange-CrossTenant-userprincipalname:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:X-OriginatorOrg:
	 Content-Language:Content-Type:Content-Transfer-Encoding;
	b=AWZWF9nTdOFDTDB0uybE7BRZm+FSlhElpszlpbQbr1JwfWdz/BIDaYW//57Q97XOU
	 0uRMZZIkzEc4pyo/k9KZ5IirhRyqRqIC1c++wKNzAPUfSOf/GBFinlMvu8E3nAZVLj
	 dCc2QLHLvQRRqpUP4o4bn+T6+xOjbsdQOqaMSZXvBBNvU/bVpZeZao54eTQaHq0IAX
	 sHrijzS8lUc24J3Cxqzi0YfRVqtrQpTwNN/5TzNEPYRYVjNF7GyA6CWzSXTxlzyluG
	 4micAtWNe4/TBH7BBrG7MVhnds/nWp3m+1kdjr61j3UqaMJGLEF+6qdQ32XC+tSa1I
	 YPtYcoZHAhQOg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org <owner-linux-mm@kvack.org> On Behalf
> Of Matthew Wilcox
> Sent: Tuesday, August 20, 2019 3:21 PM
> To: Nitin Gupta <nigupta@nvidia.com>
> Cc: akpm@linux-foundation.org; vbabka@suse.cz;
> mgorman@techsingularity.net; mhocko@suse.com;
> dan.j.williams@intel.com; Yu Zhao <yuzhao@google.com>; Qian Cai
> <cai@lca.pw>; Andrey Ryabinin <aryabinin@virtuozzo.com>; Roman
> Gushchin <guro@fb.com>; Greg Kroah-Hartman
> <gregkh@linuxfoundation.org>; Kees Cook <keescook@chromium.org>; Jann
> Horn <jannh@google.com>; Johannes Weiner <hannes@cmpxchg.org>; Arun
> KS <arunks@codeaurora.org>; Janne Huttunen
> <janne.huttunen@nokia.com>; Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru>; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org
> Subject: Re: [RFC] mm: Proactive compaction
>=20
> On Fri, Aug 16, 2019 at 02:43:30PM -0700, Nitin Gupta wrote:
> > Testing done (on x86):
> >  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} =3D {25, 30=
}
> > respectively.
> >  - Use a test program to fragment memory: the program allocates all
> > memory  and then for each 2M aligned section, frees 3/4 of base pages
> > using  munmap.
> >  - kcompactd0 detects fragmentation for order-9 > extfrag_high and
> > starts  compaction till extfrag < extfrag_low for order-9.
>=20
> Your test program is a good idea, but I worry it may produce unrealistica=
lly
> optimistic outcomes.  Page cache is readily reclaimable, so you're settin=
g up
> a situation where 2MB pages can once again be produced.
>=20
> How about this:
>=20
> One program which creates a file several times the size of memory (or
> several files which total the same amount).  Then read the file(s).  Mayb=
e by
> mmap(), and just do nice easy sequential accesses.
>=20
> A second program which causes slab allocations.  eg
>=20
> for (;;) {
> 	for (i =3D 0; i < n * 1000 * 1000; i++) {
> 		char fname[64];
>=20
> 		sprintf(fname, "/tmp/missing.%d", i);
> 		open(fname, O_RDWR);
> 	}
> }
>=20
> The first program should thrash the pagecache, causing pages to
> continuously be allocated, reclaimed and freed.  The second will create
> millions of dentries, causing the slab allocator to allocate a lot of
> order-0 pages which are harder to free.  If you really want to make it wo=
rk
> hard, mix in opening some files whihc actually exist, preventing the page=
s
> which contain those dentries from being evicted.
>=20
> This feels like it's simulating a more normal workload than your test.
> What do you think?

This combination of workloads for mixing movable and unmovable
pages sounds good.   I coded up these two and here's what I observed:

- kernel: 5.3.0-rc5 + this patch, x86_64, 32G RAM.
- Set extfrag_{low,high} =3D {25,30} for order-9
- Run pagecache and dentry thrash test programs as you described
    - for pagecache test: mmap and sequentially read 128G file on a 32G sys=
tem.
    - for dentry test: set n=3D100. I created /tmp/missing.[0-10000] so the=
se dentries stay allocated..
- Start linux kernel compile for further pagecache thrashing.

With above workload fragmentation for order-9 stayed 80-90% which kept
kcompactd0 working but it couldn't make progress due to unmovable pages
from dentries.  As expected, we keep hitting compaction_deferred() as
compaction attempts fail.

After a manual `echo 3 | /proc/sys/vm/drop_caches` and stopping dentry thra=
sher,
kcompactd succeded in bringing extfrag below set thresholds.


With unmovable pages spread across memory, there is little compaction
can do. Maybe we should have a knob like 'compactness' (like swapiness) whi=
ch
defines how aggressive compaction can be. For high values, maybe allow
freeing dentries too? This way hugepage sensitive applications can trade
with higher I/O latencies.

Thanks,
Nitin







