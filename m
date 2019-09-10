Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03647C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:28:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A17902171F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:28:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jKCWcpgj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A17902171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371B76B0007; Tue, 10 Sep 2019 18:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 322C46B0008; Tue, 10 Sep 2019 18:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9B46B000A; Tue, 10 Sep 2019 18:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id E82876B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 18:28:08 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9D87E181AC9CB
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:28:08 +0000 (UTC)
X-FDA: 75920450256.23.beef90_46b684a20fb32
X-HE-Tag: beef90_46b684a20fb32
X-Filterd-Recvd-Size: 18292
Received: from nat-hk.nvidia.com (nat-hk.nvidia.com [203.18.50.4])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:28:05 +0000 (UTC)
Received: from hkpgpgate102.nvidia.com (Not Verified[10.18.92.100]) by nat-hk.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d78236d0000>; Wed, 11 Sep 2019 06:27:57 +0800
Received: from HKMAIL101.nvidia.com ([10.18.16.10])
  by hkpgpgate102.nvidia.com (PGP Universal service);
  Tue, 10 Sep 2019 15:27:57 -0700
X-PGP-Universal: processed;
	by hkpgpgate102.nvidia.com on Tue, 10 Sep 2019 15:27:57 -0700
Received: from HKMAIL104.nvidia.com (10.18.16.13) by HKMAIL101.nvidia.com
 (10.18.16.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 10 Sep
 2019 22:27:56 +0000
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (104.47.41.54) by
 HKMAIL104.nvidia.com (10.18.16.13) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Tue, 10 Sep 2019 22:27:56 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=GJXqlUTsJn9XnHpGr2d3Mpqwzs7jHxFfhLZZWcNw8vQ8k6tM9sq72UhZ1y6G1aYbCBKLGsDqu4BvocZLBh6SGIgmVTQOcaprJ67c1hfsg8SAoVFK4PRb3fivLxdeJTu913n0FrUiIcNg+Cci0ORQRu20qIHNGZ71uQ/Z5fs3k2OhBXtMcm/Sc+wTGJcCZACKL3nobWx4KoIzNq4dokwSjICPCfUmsJL1hyhYNr96lMtu9s4qbTszJoijNonSHQluZMtViaKwJkTuX+zsm9TcA8DCzrm/lmNSklqhh/0V3K1fgbcAGMBq9eVyZHlNClMI+saC2rNVPgWh3o70AQOgdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wQU3gOmpKwDm9CFxTh+rfahEmwujWcbXwOP86JpdcKI=;
 b=KDytyIswME5Wl5oqMXcngACxKWkZrJJEkcN/zQ/v4U3303zcxJgyX2Ixtrl7JxOUGtwM6W7V9TRIzvxfZms3rHVq6p9Xt13wufI3szIeBLSo3GYJ7dR8vWvoMmM/jGXXR33zsSmHFDBOOgPHe6bYc00Ova/Ag1evjO/JZGyiUvb1QdWAi2nykCnV2kXPdKMgzsGpJnpzEcheeQ6o0wZfrVS+erL5lWXmbnbzp3bnWDYHSwmon9DABXB0OeR8MBYvRaF+Rk8sqhxIjs/LwSSa+3JhLG8P25zVZlze6QBBf3AJwhV7EONNrcsjKTdgNh3SgbBUy+gM3O4F5jD5jp8ZBw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
Received: from MN2PR12MB3022.namprd12.prod.outlook.com (20.178.243.160) by
 MN2PR12MB3565.namprd12.prod.outlook.com (20.178.240.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.15; Tue, 10 Sep 2019 22:27:53 +0000
Received: from MN2PR12MB3022.namprd12.prod.outlook.com
 ([fe80::fd61:50ed:5466:1285]) by MN2PR12MB3022.namprd12.prod.outlook.com
 ([fe80::fd61:50ed:5466:1285%7]) with mapi id 15.20.2241.018; Tue, 10 Sep 2019
 22:27:53 +0000
From: Nitin Gupta <nigupta@nvidia.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz"
	<vbabka@suse.cz>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "dan.j.williams@intel.com"
	<dan.j.williams@intel.com>, "khalid.aziz@oracle.com"
	<khalid.aziz@oracle.com>, Matthew Wilcox <willy@infradead.org>, Yu Zhao
	<yuzhao@google.com>, Qian Cai <cai@lca.pw>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Allison Randal <allison@lohutok.net>, "Mike
 Rapoport" <rppt@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>,
	Arun KS <arunks@codeaurora.org>, Wei Yang <richard.weiyang@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH] mm: Add callback for defining compaction completion
Thread-Topic: [PATCH] mm: Add callback for defining compaction completion
Thread-Index: AQHVaBN89sjqlPYaX0aecSzy09g86KclWdWAgAATpPA=
Date: Tue, 10 Sep 2019 22:27:53 +0000
Message-ID: <MN2PR12MB30229414332206E25B9F3B8BD8B60@MN2PR12MB3022.namprd12.prod.outlook.com>
References: <20190910200756.7143-1-nigupta@nvidia.com>
 <20190910201905.GG4023@dhcp22.suse.cz>
In-Reply-To: <20190910201905.GG4023@dhcp22.suse.cz>
Accept-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels: MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Enabled=True;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_SiteId=43083d15-7273-40c1-b7db-39efd9ccc17a;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Owner=nigupta@nvidia.com;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_SetDate=2019-09-10T22:27:46.6026212Z;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Name=Unrestricted;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Application=Microsoft Azure
 Information Protection;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_ActionId=f771cd74-7797-4d23-b998-f09a7d7ff3b6;
 MSIP_Label_6b558183-044c-4105-8d9c-cea02a2a3d86_Extended_MSFT_Method=Automatic
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=nigupta@nvidia.com; 
x-originating-ip: [216.228.112.21]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 32653736-3af4-4f9c-ecee-08d7363e1f4c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MN2PR12MB3565;
x-ms-traffictypediagnostic: MN2PR12MB3565:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs: <MN2PR12MB35655BFDD4A5698F6BB5A046D8B60@MN2PR12MB3565.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01565FED4C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(39860400002)(366004)(346002)(376002)(136003)(396003)(13464003)(189003)(199004)(81156014)(316002)(25786009)(7696005)(229853002)(66066001)(53936002)(7416002)(6306002)(9686003)(71190400001)(71200400001)(11346002)(74316002)(256004)(476003)(6246003)(14444005)(102836004)(53546011)(6506007)(186003)(66476007)(26005)(76176011)(6436002)(446003)(66946007)(66446008)(64756008)(66556008)(14454004)(76116006)(3846002)(478600001)(6116002)(2906002)(7736002)(305945005)(5660300002)(4326008)(54906003)(966005)(6916009)(86362001)(99286004)(8676002)(33656002)(8936002)(81166006)(52536014)(55016002)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR12MB3565;H:MN2PR12MB3022.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nvidia.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: eFr3YU+0/ncbJc/9O9JQDeEXLeLzoSZLSK3ELpw8pJNvPkaHRoTgS+g584AH9e5guQ+WI7VPKOR2pBGlPvq8R/AwoytEkgkfo2AodFVvv8jeBX5XQJSW3lX+Pymcg+Sbh2RB55aCL1r2SrNRBr2MNh0hqSLTL+l5cckzY7D5GB9NjrylzG3Sor+L+rY1vQ/vdQJgWVfHz6+KOni2R0Yk1FEQaTXPga/iFCjKs4ROFUHy/YKu2DDRfJCSgZmsv2D39Zywgg8N2RQ8FeZF4BxQPVehrCyszHrjuUo2Gi9xxZHOZlCeFx/uF4ulws6MqqieaETfFSt43HByma9THVS2dxtrjcneUNNGEDjb+LqavW+FDZ4+2/sxoaDtYNEVJpqJ0uR9XDJ3Hu4Wilo3aAZqsnVhH/eAHVZezMJNoqQ+z/c=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 32653736-3af4-4f9c-ecee-08d7363e1f4c
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Sep 2019 22:27:53.5842
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: N+6pdEp5EyrxBR8McrAJ04D0BlYXQ9DCcLgdwt+pZ57dImegp/DuyUdkvFENAe3eYb4vKxMhGcnLNIFc6Gps7g==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR12MB3565
X-OriginatorOrg: Nvidia.com
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568154477; bh=wQU3gOmpKwDm9CFxTh+rfahEmwujWcbXwOP86JpdcKI=;
	h=X-PGP-Universal:ARC-Seal:ARC-Message-Signature:
	 ARC-Authentication-Results:From:To:CC:Subject:Thread-Topic:
	 Thread-Index:Date:Message-ID:References:In-Reply-To:
	 Accept-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:msip_labels:
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
	b=jKCWcpgjqP7wiLGBENrYj+ltnCLvGZJDN9Zmh5V14ezjTssLJeq+dw1sIcMLhAd76
	 lSKZgVQozCk/okkcPV2zoykgz43LLp460RBXT+IG6l1TuOr/kX2/BnYZ9Q1Ccizfxr
	 gIpIn71WAfdidxeuiR4pNyDjC6oOQwbeAQZgj8V1AhDvt5FbgmTe9EloHtznChyOp9
	 fE7Y5290sOpm0b3Ac2KxqW1vU59Br7ueLG4d6E4v7qHGTh6CifffOiXN/QYpdXLDEF
	 M5OS4uh2uEth1jQkcUVd/x57IkvSXdDWQV1YKZVBu/6u+/akhGfNln17qgZatMcW39
	 K8pKpuK0VMM7g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org <owner-linux-mm@kvack.org> On Behalf
> Of Michal Hocko
> Sent: Tuesday, September 10, 2019 1:19 PM
> To: Nitin Gupta <nigupta@nvidia.com>
> Cc: akpm@linux-foundation.org; vbabka@suse.cz;
> mgorman@techsingularity.net; dan.j.williams@intel.com;
> khalid.aziz@oracle.com; Matthew Wilcox <willy@infradead.org>; Yu Zhao
> <yuzhao@google.com>; Qian Cai <cai@lca.pw>; Andrey Ryabinin
> <aryabinin@virtuozzo.com>; Allison Randal <allison@lohutok.net>; Mike
> Rapoport <rppt@linux.vnet.ibm.com>; Thomas Gleixner
> <tglx@linutronix.de>; Arun KS <arunks@codeaurora.org>; Wei Yang
> <richard.weiyang@gmail.com>; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org
> Subject: Re: [PATCH] mm: Add callback for defining compaction completion
>=20
> On Tue 10-09-19 13:07:32, Nitin Gupta wrote:
> > For some applications we need to allocate almost all memory as
> hugepages.
> > However, on a running system, higher order allocations can fail if the
> > memory is fragmented. Linux kernel currently does on-demand
> compaction
> > as we request more hugepages but this style of compaction incurs very
> > high latency. Experiments with one-time full memory compaction
> > (followed by hugepage allocations) shows that kernel is able to
> > restore a highly fragmented memory state to a fairly compacted memory
> > state within <1 sec for a 32G system. Such data suggests that a more
> > proactive compaction can help us allocate a large fraction of memory
> > as hugepages keeping allocation latencies low.
> >
> > In general, compaction can introduce unexpected latencies for
> > applications that don't even have strong requirements for contiguous
> > allocations. It is also hard to efficiently determine if the current
> > system state can be easily compacted due to mixing of unmovable
> > memory. Due to these reasons, automatic background compaction by the
> > kernel itself is hard to get right in a way which does not hurt unsuspe=
cting
> applications or waste CPU cycles.
>=20
> We do trigger background compaction on a high order pressure from the
> page allocator by waking up kcompactd. Why is that not sufficient?
>=20

Whenever kcompactd is woken up, it does just enough work to create
one free page of the given order (compaction_control.order) or higher.

Such a design causes very high latency for workloads where we want
to allocate lots of hugepages in short period of time. With pro-active
compaction we can hide much of this latency. For some more background
discussion and data, please see this thread:

https://patchwork.kernel.org/patch/11098289/

> > Even with these caveats, pro-active compaction can still be very
> > useful in certain scenarios to reduce hugepage allocation latencies.
> > This callback interface allows drivers to drive compaction based on
> > their own policies like the current level of external fragmentation
> > for a particular order, system load etc.
>=20
> So we do not trust the core MM to make a reasonable decision while we giv=
e
> a free ticket to modules. How does this make any sense at all? How is a
> random module going to make a more informed decision when it has less
> visibility on the overal MM situation.
>

Embedding any specific policy (like: keep external fragmentation for order-=
9
between 30-40%) within MM core looks like a bad idea. As a driver, we
can easily measure parameters like system load, current fragmentation level
for any order in any zone etc. to make an informed decision.
See the thread I refereed above for more background discussion.

> If you need to control compaction from the userspace you have an interfac=
e
> for that.  It is also completely unexplained why you need a completion
> callback.
>=20

/proc/sys/vm/compact_memory does whole system compaction which is
often too much as a pro-active compaction strategy. To get more control
over how to compaction work to do, I have added a compaction callback
which controls how much work is done in one compaction cycle.
=20
For example, as a test for this patch, I have a small test driver which def=
ines
[low, high] external fragmentation thresholds for the HPAGE_ORDER. Whenever
extfrag is within this range, I run compact_zone_order with a callback whic=
h
returns COMPACT_CONTINUE till extfrag > low threshold and returns
COMPACT_PARTIAL_SKIPPED when extfrag <=3D low.

Here's the code for this sample driver:
https://gitlab.com/nigupta/memstress/snippets/1893847

Maybe this code can be added to Documentation/...

Thanks,
Nitin

>=20
> > Signed-off-by: Nitin Gupta <nigupta@nvidia.com>
> > ---
> >  include/linux/compaction.h | 10 ++++++++++
> >  mm/compaction.c            | 20 ++++++++++++++------
> >  mm/internal.h              |  2 ++
> >  3 files changed, 26 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index 9569e7c786d3..1ea828450fa2 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -58,6 +58,16 @@ enum compact_result {
> >  	COMPACT_SUCCESS,
> >  };
> >
> > +/* Callback function to determine if compaction is finished. */
> > +typedef enum compact_result (*compact_finished_cb)(
> > +	struct zone *zone, int order);
> > +
> > +enum compact_result compact_zone_order(struct zone *zone, int order,
> > +		gfp_t gfp_mask, enum compact_priority prio,
> > +		unsigned int alloc_flags, int classzone_idx,
> > +		struct page **capture,
> > +		compact_finished_cb compact_finished_cb);
> > +
> >  struct alloc_context; /* in mm/internal.h */
> >
> >  /*
> > diff --git a/mm/compaction.c b/mm/compaction.c index
> > 952dc2fb24e5..73e2e9246bc4 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1872,6 +1872,9 @@ static enum compact_result
> __compact_finished(struct compact_control *cc)
> >  			return COMPACT_PARTIAL_SKIPPED;
> >  	}
> >
> > +	if (cc->compact_finished_cb)
> > +		return cc->compact_finished_cb(cc->zone, cc->order);
> > +
> >  	if (is_via_compact_memory(cc->order))
> >  		return COMPACT_CONTINUE;
> >
> > @@ -2274,10 +2277,11 @@ compact_zone(struct compact_control *cc,
> struct capture_control *capc)
> >  	return ret;
> >  }
> >
> > -static enum compact_result compact_zone_order(struct zone *zone, int
> > order,
> > +enum compact_result compact_zone_order(struct zone *zone, int order,
> >  		gfp_t gfp_mask, enum compact_priority prio,
> >  		unsigned int alloc_flags, int classzone_idx,
> > -		struct page **capture)
> > +		struct page **capture,
> > +		compact_finished_cb compact_finished_cb)
> >  {
> >  	enum compact_result ret;
> >  	struct compact_control cc =3D {
> > @@ -2293,10 +2297,11 @@ static enum compact_result
> compact_zone_order(struct zone *zone, int order,
> >  					MIGRATE_ASYNC :
> 	MIGRATE_SYNC_LIGHT,
> >  		.alloc_flags =3D alloc_flags,
> >  		.classzone_idx =3D classzone_idx,
> > -		.direct_compaction =3D true,
> > +		.direct_compaction =3D !compact_finished_cb,
> >  		.whole_zone =3D (prio =3D=3D MIN_COMPACT_PRIORITY),
> >  		.ignore_skip_hint =3D (prio =3D=3D MIN_COMPACT_PRIORITY),
> > -		.ignore_block_suitable =3D (prio =3D=3D MIN_COMPACT_PRIORITY)
> > +		.ignore_block_suitable =3D (prio =3D=3D
> MIN_COMPACT_PRIORITY),
> > +		.compact_finished_cb =3D compact_finished_cb
> >  	};
> >  	struct capture_control capc =3D {
> >  		.cc =3D &cc,
> > @@ -2313,11 +2318,13 @@ static enum compact_result
> compact_zone_order(struct zone *zone, int order,
> >  	VM_BUG_ON(!list_empty(&cc.freepages));
> >  	VM_BUG_ON(!list_empty(&cc.migratepages));
> >
> > -	*capture =3D capc.page;
> > +	if (capture)
> > +		*capture =3D capc.page;
> >  	current->capture_control =3D NULL;
> >
> >  	return ret;
> >  }
> > +EXPORT_SYMBOL(compact_zone_order);
> >
> >  int sysctl_extfrag_threshold =3D 500;
> >
> > @@ -2361,7 +2368,8 @@ enum compact_result
> try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> >  		}
> >
> >  		status =3D compact_zone_order(zone, order, gfp_mask, prio,
> > -				alloc_flags, ac_classzone_idx(ac), capture);
> > +				alloc_flags, ac_classzone_idx(ac), capture,
> > +				NULL);
> >  		rc =3D max(status, rc);
> >
> >  		/* The allocation should succeed, stop compacting */ diff --git
> > a/mm/internal.h b/mm/internal.h index e32390802fd3..f873f7c2b9dc
> > 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -11,6 +11,7 @@
> >  #include <linux/mm.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/tracepoint-defs.h>
> > +#include <linux/compaction.h>
> >
> >  /*
> >   * The set of flags that only affect watermark checking and reclaim
> > @@ -203,6 +204,7 @@ struct compact_control {
> >  	bool whole_zone;		/* Whole zone should/has been
> scanned */
> >  	bool contended;			/* Signal lock or sched
> contention */
> >  	bool rescan;			/* Rescanning the same pageblock */
> > +	compact_finished_cb compact_finished_cb;
> >  };
> >
> >  /*
> > --
> > 2.21.0
>=20
> --
> Michal Hocko
> SUSE Labs


