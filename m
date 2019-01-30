Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC824C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:48:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C30920857
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 05:48:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="j15oJ+Ss";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="it0uPAty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C30920857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EE678E0002; Wed, 30 Jan 2019 00:48:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6787D8E0001; Wed, 30 Jan 2019 00:48:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F2138E0002; Wed, 30 Jan 2019 00:48:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED468E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:48:19 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so24587951qkf.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:48:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Qcs74qv/rSfIqjuncwcIcw5JfLeumK9NRTjZqv2Ogeo=;
        b=H/YROBXGHnvTlaA2mAPLNNixP2LyTybwVZkP/WUufH3aG/LXAPjgMz/+h0gxpJ3nu2
         8aCSpfeLVYkO15vmcQYtEXc2ZyB8TifGPQ4o8nMacwZaefFhbMaMDT0BfOHmONYh6EqZ
         c0o7Uee1VwFTPCx4bmbQ3gUThIk594lUchnu1TdxRCPliq/UQbHYqfryBZhksY73pJq+
         jpFiDELCzqtrlMr83gT52oZooQgzdqyXy/2l4iQORMPCrqo+cSM47IarGKMCr1oCBcSD
         T/mmySWkiT5OVRKfCXYnn0pLZjwjebAKhct2x0S8Bb0ktmkKFjNQWUHSSQcoNunJnjwc
         1sDQ==
X-Gm-Message-State: AJcUukeB7cOwUI8hszGI1vRKZxX9Nw9whPnV8HVzWI8h5zwgjvzq4rV6
	MYyYFDm/l59G+o+fwgEiBfDusYh6XdiRNbocMtpRWuEyjjMegjz+4EUzAABWSQGsmLERUR5gWMb
	9+HpRMNbJRTP9IST26utb0ygsCg9vnfRRhOIzqIIrKetI9Krrk3S51sKmsNcNNwsYUw==
X-Received: by 2002:ac8:2a55:: with SMTP id l21mr27780571qtl.95.1548827298758;
        Tue, 29 Jan 2019 21:48:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Ldh8lD3cb9ldOMqJGKXxH2/1fqoTrReP7+aDOD7SY/fyx4XYYn8/soFYutZ2PqayF6aLQ
X-Received: by 2002:ac8:2a55:: with SMTP id l21mr27780547qtl.95.1548827297931;
        Tue, 29 Jan 2019 21:48:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548827297; cv=none;
        d=google.com; s=arc-20160816;
        b=j08awbkzKI1K+S1BVdIdo5AX/L8NYS4sejZAm/Oi1VqZEy+A7XaHcVGPu+J3Q47/nU
         nIw4pMXDU3Loe7pWIS7ONlupYP/6JgdNbW90wX3skHjvpofXO1StHhl5QVYLCLFOyVsc
         u3Glm9cxrVJrwsic890tJi47WFYz6wfJ5u78hIf+bpUwcwKGQyHzYAASGdglmG9whrEA
         1ltfh7I5NeRRkFGAQLJRd8Pfe4ipXGJoZBldlXpElI5zTX/keCu+jymSe1PUgJBHiIHa
         yk4FaDmM4if81eg58+lv3JIY66zY8iTLx8We1TGK/zdaIKYUFTIn+vLNrtnCH4zBtRH1
         HQoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Qcs74qv/rSfIqjuncwcIcw5JfLeumK9NRTjZqv2Ogeo=;
        b=q/gMb0q0bbqfDohmemdPbpLeDVp1iVqgfCFZVs2JZCjuCKgabIEQve9R7gxXZzgiuJ
         1iTDqIxtIID3/yaf4e+4bkPr70+PsbSewKKqXjOpkzgXIxbqV3ehPLmfbhShdE6Coh11
         peLrlKMbuu0xnikZj+eNVkogug0APGI6w1hCZqrGx0ERBb90mwb6EfQPQT8aCO/4Ku7X
         RFK3mD2NQgyVeS9uWN7wBXYyRVffy8ZASGIzoNXO8M8L43rveWOrjOOirOEa4Vq+b1OO
         9qn6Dux/jWCY6jfXGlhAxPLDZ3w16tXVyRBGxHAr7w6nit0BtPxmal4VpEOguvAFQdMS
         t+bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=j15oJ+Ss;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=it0uPAty;
       spf=pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=793397e901=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c54si406681qtb.13.2019.01.29.21.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 21:48:17 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=j15oJ+Ss;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=it0uPAty;
       spf=pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=793397e901=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x0U5iD6Z011211;
	Tue, 29 Jan 2019 21:48:12 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Qcs74qv/rSfIqjuncwcIcw5JfLeumK9NRTjZqv2Ogeo=;
 b=j15oJ+SsUDKLA0njGBVA09vuJRAQB2KP/55OV/e9KHDx3ncxDG6xQm34CkANDq1hntoJ
 UmQejFioJT1ZXP1NZhozN+A5PaVT83Lc46cS3SyYws1nIkYo9LcvJ9umfIPBG8EHF78y
 trb69kyZt0d2hxSMkCfsvFE7uIA39IWZvz4= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0089730.ppops.net with ESMTP id 2qb3gv0be2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 29 Jan 2019 21:48:12 -0800
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-hub01.TheFacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 29 Jan 2019 21:48:11 -0800
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Tue, 29 Jan 2019 21:48:11 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qcs74qv/rSfIqjuncwcIcw5JfLeumK9NRTjZqv2Ogeo=;
 b=it0uPAty3x9Hi9nIZahqCSo59J34+2gfHCyGW+Nig6kJcydycfhAMu/N6exGAFhWBeXoG4kfIuUIXMOYIZFSpxVeWN6EAbWIfttyFUJIo18nWTCDO/t9hHxWX1Qh/QT/wVL3jknO9xy99fckA7kDmcYkOiFq9vpP6s+5pB5l+7s=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2564.namprd15.prod.outlook.com (20.179.137.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.21; Wed, 30 Jan 2019 05:48:10 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::41b9:104d:e330:d12d]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::41b9:104d:e330:d12d%5]) with mapi id 15.20.1558.023; Wed, 30 Jan 2019
 05:48:10 +0000
From: Roman Gushchin <guro@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 0/2] [REGRESSION v4.19-20] mm: shrinkers are now way too
 aggressive
Thread-Topic: [PATCH 0/2] [REGRESSION v4.19-20] mm: shrinkers are now way too
 aggressive
Thread-Index: AQHUuFKzJHb2O8CEQki2pr5FxP/AYaXHThWA
Date: Wed, 30 Jan 2019 05:48:10 +0000
Message-ID: <20190130054759.GA2107@castle.DHCP.thefacebook.com>
References: <20190130041707.27750-1-david@fromorbit.com>
In-Reply-To: <20190130041707.27750-1-david@fromorbit.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR16CA0014.namprd16.prod.outlook.com (2603:10b6:907::27)
 To BN8PR15MB2626.namprd15.prod.outlook.com (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:e58d]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BN8PR15MB2564;20:dr8X4g1cW2rXN/TFWD0kpEynWwoLTuqMVwHgvAoNi3WAyHmpCxUgGHi7uxmHWEJ+CO89ZPhhA19N8uGpjM5SNKfAk3uQ2pgiXdKXpe0Ua55Z/6NIkslJjTd3fW9lsp+kOH2Dft0Uv595/zNCkTsu/2PRw9a0MEHl5Zu2W1DmeDo=
x-ms-office365-filtering-correlation-id: 89f7d626-7a2e-46a9-f3ec-08d6867683ec
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BN8PR15MB2564;
x-ms-traffictypediagnostic: BN8PR15MB2564:
x-microsoft-antispam-prvs: <BN8PR15MB25642E58EE03B441BB12C30CBE900@BN8PR15MB2564.namprd15.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(39860400002)(376002)(136003)(189003)(199004)(54906003)(6486002)(2906002)(46003)(53936002)(25786009)(81166006)(102836004)(229853002)(8936002)(33656002)(186003)(39060400002)(71200400001)(11346002)(486006)(81156014)(476003)(71190400001)(68736007)(8676002)(6116002)(446003)(105586002)(106356001)(97736004)(386003)(966005)(5024004)(52116002)(14454004)(6916009)(14444005)(6436002)(256004)(1076003)(9686003)(6512007)(6246003)(86362001)(6306002)(4326008)(7736002)(478600001)(33896004)(305945005)(6506007)(316002)(76176011)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2564;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: qpO1qRrK49jIvaRuW+e956UGPp7JPLIIJT+nH0bphjrfzZgm/3MR/uZNYx3w3N2KZTMejylAV+5B4Y2wCC7NuNGt/ECZfv/OmrXawKyV/jSTX0qvRGqJaW5s/TSuKe0PYexzmIwm4aXpkBSS+kJKYp7EsB0tYhTfGnWYZeBFj3pni8mBILxu3d1z0akIP9JuUMIL0IUOBWn/yVQ8kBbh19SBc6HTfgPA6s5/BmuMCESfJYt2xdsK0axJ+zBN8cR5cYqr/4mgwsERuZfT50MY1tQS7Uc251VG2j2Izt33pEDgzlml8brczJXzAU6QXj9qhjoTnv9cNavGyNZvkVI57Tu8CKEaLtEgtbj3GE2HQhPXT/2WaFbTO6lAI4/0JOQn2gCE+IzL8FNiWg/Ro3x6vyCbLG2SRAeh1RKfEbTLtc0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <451195CB67CA7D4791CBCB9D696AC099@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 89f7d626-7a2e-46a9-f3ec-08d6867683ec
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 05:48:07.8947
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2564
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_05:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Dave!

Instead of reverting (which will bring back the memcg memory leak),
can you, please, try Rik's patch: https://lkml.org/lkml/2019/1/28/1865 ?

It should protect small cgroups from being scanned too hard by the memory
pressure, however keeping the pressure big enough to avoid memory leaks.

Thanks!

On Wed, Jan 30, 2019 at 03:17:05PM +1100, Dave Chinner wrote:
> Hi mm-folks,
>=20
> TL;DR: these two commits break system wide memory VFS cache reclaim
> balance badly, cause severe performance regressions in stable
> kernels and they need to be reverted ASAP.
>=20
> For background, let's start with the bug reports that have come from
> desktop users on 4.19 stable kernels. First this one:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D202349
>=20
> Whereby copying a large amount of data to files on an XFS filesystem
> would cause the desktop to freeze for multiple seconds and,
> apparently occasionally hang completely. Basically, GPU based
> GFP_KERNEL allocations getting stuck in shrinkers under realtively
> light memory loads killing desktop interactivity. Kernel 4.19.16
>=20
> The second:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D202441
>=20
> Whereby copying a large data set across NFS filesystems at the same
> time as running a kernel compile on a local XFS filesystem results
> in the kernel compile going from 3m30s to over an hour and file copy
> performance tanking.
>=20
> We ran an abbreviated bisect from 4.18 through to 4.19.18, and found
> two things:
>=20
> 	1: there was a major change in page cache reclaim behaviour
> 	introduced in 4.19-rc5. Basically the page cache would get
> 	trashed periodically for no apparent reason, the
> 	characteristic being a sawtooth cache usage pattern.
>=20
> 	2: in 4.19.3, kernel compile performance turned to crap.
>=20
> The kernel compile regression is essentially caused by memory
> reclaim driving the XFS inode shrinker hard in to reclaiming dirty
> inodes and getting blocked, essentially slowing reclaim down to the
> rate at which a slow SATA drive could write back inodes. There were
> also indications of a similar GPU-based GFP_KERNEL allocation
> stalls, but most of the testing was done from the CLI with no X so
> that could be discounted.
>=20
> It was reported that less severe slowdowns also occurred on ext2,
> ext3, ext4 and jfs, so XFS is really just the messenger here - it is
> most definitely not the cause of the problem being seen, so stop and
> thing before you go and blame XFS.
>=20
> Looking at the change history of the mm/ subsystem after the first
> bug report, I noticed and red-flagged this commit for deeper
> analysis:
>=20
> 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of =
objects")
>=20
> That "simple" change ran a read flag because it makes shrinker
> reclaim far, far more agressive at initial priority reclaims (ie..
> reclaim priority =3D 12). And it also means that small caches that
> don't need reclaim (because they are small) will be agressively
> scanned and reclaimed when there is very little memory pressure,
> too. It also means tha tlarge caches are reclaimed very agressively
> under light memory pressure - pressure that would have resulted in
> single digit scan count now gets run out to batch size, which for
> filesystems is 1024 objects. i.e. we increase reclaim filesystem
> superblock shrinker pressure by an order of 100x at light reclaim.
>=20
> That's a *bad thing* because it means we can't retain working sets
> of small caches even under light memory pressure - they get
> excessively reclaimed in comparison to large caches instead of in
> proptortion to the rest of the system caches.
>=20
> So, yeah, red flag. Big one. And the patch never got sent to
> linux-fsdevel so us filesystem people didn't ahve any idea that
> there were changes to VFS cache balances coming down the line. Hence
> our users reporting problems ar the first sign we get of a
> regression...
>=20
> So when Roger reported that the page cache behaviour changed
> massively in 4.19-rc5, and I found that commit was between -rc4 and
> -rc5? Yeah, that kinda proved my theory that it changed the
> fundamental cache balance of the system and the red flag is real...
>=20
> So, the second, performance killing change? Well, I think you all
> know what's coming:
>=20
> a76cf1a474d7 mm: don't reclaim inodes with many attached pages
>=20
> [ Yup, a "MM" tagged patch that changed code in fs/inode.c and wasn't
> cc'd to any fileystem list. There's a pattern emerging here. Did
> anyone think to cc the guy who originally designed ithe numa aware
> shrinker infrastucture and helped design the memcg shrinker
> infrastructure on fundamental changes? ]
>=20
> So, that commit was an attempt to fix the shitty behaviour
> introduced by 172b06c32b94 - it's a bandaid over a symptom rather
> than something that attempts to correct the actual bug that was
> introduced. i.e. the increased inode cache reclaim pressure was now
> reclaiming inodes faster than the page cache reclaim was reclaiming
> pages on the inode, and so inode cache reclaim is trashing the
> working set of the page cache.
>=20
> This is actually necessary behaviour - when you have lots of
> temporary inodes and are turning the inode cache over really fast
> (think recursive grep) we want the inode cache to immediately
> reclaim the cached pages on the inode because it's typically a
> single use file. Why wait for the page cache to detect it's single
> use when we already know it's not part of the working file set?
>=20
> And what's a kernel compile? it's a recursive read of a large number
> of files, intermixed with the creation of a bunch of temporary
> files.  What happens when you have a mixed large file workload
> (background file copy) and lots of small files being created and
> removed (kernel compile)?
>=20
> Yup, we end up in a situation where inode reclaim can no longer
> reclaim clean inodes because they have cached pages, yet page reclaim
> doesn't keep up  in reclaiming pages because it hasn't realised they
> are single use pages yet and hence don't get reclaimed. And
> because the page cache preossure is relatively light, we are
> putting a huge amount of scanning pressure put on the shrinkers.
>=20
> The result is the shrinkers are driven into corners where they try
> *really hard* to free objects because there's nothing left that is
> easy to reclaim. e.g. it drives the XFS inode cache shrinker into
> "need to clean dirty reclaimable inodes" land on workloads where the
> working set of cached inodes should never, ever get anywhere near
> that threshold because there are hge amounts of clean pages and
> inodes that should have been reclaimed first.
>=20
> IOWs, the fix to prevent inode cache reclaim from reclaiming inodes
> with pages attached to them essentially breaks a key page cache
> memory reclaim interlock that our systems have implicitly depended
> on for ages.
>=20
> And, in reality, changing fundamental memory reclaim balance is not
> the way to fix a "dying memcg" memory leak. Trying to solve a "we've
> got referenced memory we need to clean up" by faking memory
> pressure and winding up shrinker based reclaim so dying memcg's are
> reclaimed fast is, well, just insane. It's a nasty hack at best.
>=20
> e.g. add a garbage collector via a background workqueue that sits on
> the dying memcg calling something like:
>=20
> void drop_slab_memcg(struct mem_cgroup *dying_memcg)
> {
>         unsigned long freed;
>=20
>         do {
>                 struct mem_cgroup *memcg =3D NULL;
>=20
>                 freed =3D 0;
>                 memcg =3D mem_cgroup_iter(dying_memcg, NULL, NULL);
>                 do {
>                         freed +=3D shrink_slab_memcg(GFP_KERNEL, 0, memcg=
, 0);
>                 } while ((memcg =3D mem_cgroup_iter(NULL, memcg, NULL)) !=
=3D NULL);
>         } while (freed > 0);
> }
>=20
> (or whatever the NUMA aware, rate limited variant should really be)
>=20
> so that it kills off all the slab objects accounted to the memcg
> as quickly as possible? The memcg teardown code is full of these
> "put it on a work queue until something goes away and calls the next
> teardown function" operations, so it makes no sense to me to be
> relying on system wide memory pressure to drive this reclaim faster.
>=20
> Sure, it won't get rid of all of the dying memcgs all of the time,
> but it's a hell of a lot better changing memory reclaim behaviour
> and cache balance for everyone to fix what is, at it's core, a memcg
> lifecycle problem, not a memory reclaim problem.
>=20
> So, revert these broken, misguided commits ASAP, please.
>=20
> -Dave.
>=20

