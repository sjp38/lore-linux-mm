Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BD90C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 090C7206DF
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:53:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Qc1arjBf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 090C7206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C8E66B0007; Mon, 25 Mar 2019 19:53:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 879B36B0008; Mon, 25 Mar 2019 19:53:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 767B16B000A; Mon, 25 Mar 2019 19:53:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25B176B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:53:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so4467348eda.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:53:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=A0PsOXmJWKx21+tmrmPZV8HbMzNRWEv0wsPtoF8KzT8=;
        b=lg/pSIX4rgfIOoSOrgo4koN7+fHLHTNql89oVYfzdhaBtNupbQWfLSNkq4AMQjxDp/
         fofu5tsEq5tlP4E82QHWC7BdwiXvbhd+M7Vq1Uqr7QfxfYHqd1QbJdDyyk7yvSGOCaqW
         z+AhOT79zBV2GlCdy3Ki+kyfsY1rZZyoHOE7nCpoE+W9e+hGlVyDs2lwZBuKY0MvAddI
         NT2eC+ji1mJ7vNtXY6hEpFlXZfh+NCjRbZlvoW7iT+D5+7BUuNMHLaU22O9ru+Ad1cFO
         VF7ieXa5irBPBcGth3LeSuC7cK4BtoHeXVisDpzYv9ErvtggZDRC+R/ieLRjXUQny0eX
         jbGA==
X-Gm-Message-State: APjAAAWNYOozlRVDuW4MVCaXKOZUSCnbUXRjI/8K1BymB5DlHc4Z1mdu
	ZA11C2QrUBSh2bxHfAp+crMZAitzwh/iOexxvWmapD63MU6GCoYl7UzovCDUvDt5YZz01ak43dQ
	RuCu3/UOb8CACdFQQvJ0R5uaa86mGubQ9GMXMFeODbM1CPvONmrC29IjJPRjJwLbZPw==
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr17095535edr.29.1553558035612;
        Mon, 25 Mar 2019 16:53:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnaP5N1QbYDeOgVJyk9oo2d/URxFAQgcnr1BZStN96EWEI29w2y1d5+iwcSptTUcUhalsK
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr17095508edr.29.1553558034786;
        Mon, 25 Mar 2019 16:53:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553558034; cv=none;
        d=google.com; s=arc-20160816;
        b=HLayuN8EkZn9EGxrFkTnb1dzb91lGlqT48a+q+ejFMOtXTMpYpUx4WgjNCrShksswg
         ihcGqXGY1x0r5U09zYlO+o4345OHjcI2mU0WmkF9TCCQSoPRL1iBqQwCPQPJW/IBblZd
         se8prgXBIePQB9ISIz2iGuUy57mrZjCDcFfU8uYps/lSxQdlxkvzbHePpprL07RfMxHL
         OvguNYy+gKYits14ZiO7dUsJJLG7eXx++LZXs8h5IESMj1zEpJkFCxYH71VKi+STkuMZ
         5PFUf1ZENsCSy0Sdubl4KNVhtLYgsjC3OdRiUbm2ROmZ+e4S5JQmLTM3Quhe1AV//rUj
         blaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=A0PsOXmJWKx21+tmrmPZV8HbMzNRWEv0wsPtoF8KzT8=;
        b=lvvL3OnvVaRewpMwmrA2sduUEDhIDyAjL+fVyyVU7Gg/IZTOMPlkNQsi6A7osRP7iO
         KSXukWGB7BiE6opsQkcsjfbL4z3r5b2gGn/RSYRxiyoe3TOqvtGANuqcljAc34EDDz+r
         lphvXXl/49IgcAk810fD95vshaicg7u2eJpc8rv2vKROeroeWimpSWBqPguIWiG/Eg8p
         Z+FGFvQiprFQOTgjJhhtdfEUM3dZ0o7uWslNxBQEglAtF2wbgdbjLkeQ6wI3YcO2lsTl
         Mr6ZUvA9Us906Jl4+hVVKDZjiKQurJ2MnrgtoVy+NbQP7aBlcU6EutFtQgztlPJU8GsM
         e5ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Qc1arjBf;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20085.outbound.protection.outlook.com. [40.107.2.85])
        by mx.google.com with ESMTPS id z1si4254368edp.210.2019.03.25.16.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Mar 2019 16:53:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.85 as permitted sender) client-ip=40.107.2.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Qc1arjBf;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A0PsOXmJWKx21+tmrmPZV8HbMzNRWEv0wsPtoF8KzT8=;
 b=Qc1arjBfd5OqjDgLfRJ7Ex6T5vUI76bPUtOEPsbBf7feg8dGIniMystHEnBgTBwGIHWLh4j/98Y608TOjYa6/XpdYhQc4H/oPWrz2+mP7iBt43lP49SXjiFrEsFDB734lEeqrfugV/mMrohR6Lr7WYxIqK41+i2Ro5tnS/r8kqk=
Received: from VI1PR05MB5166.eurprd05.prod.outlook.com (20.178.8.147) by
 VI1PR05MB4512.eurprd05.prod.outlook.com (52.133.14.10) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.17; Mon, 25 Mar 2019 23:53:52 +0000
Received: from VI1PR05MB5166.eurprd05.prod.outlook.com
 ([fe80::edda:c897:612:f5b5]) by VI1PR05MB5166.eurprd05.prod.outlook.com
 ([fe80::edda:c897:612:f5b5%3]) with mapi id 15.20.1730.019; Mon, 25 Mar 2019
 23:53:52 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Jann Horn
	<jannh@google.com>, Hugh Dickins <hughd@google.com>, Mike Rapoport
	<rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu
	<peterx@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/1] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Topic: [PATCH 1/1] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Index: AQHU410TBBf7QmDOAUmwUGfyYW5Xq6YdBT+A
Date: Mon, 25 Mar 2019 23:53:52 +0000
Message-ID: <20190325235347.GM9994@mellanox.com>
References: <20190325224949.11068-1-aarcange@redhat.com>
In-Reply-To: <20190325224949.11068-1-aarcange@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0061.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::38) To VI1PR05MB5166.eurprd05.prod.outlook.com
 (2603:10a6:803:a2::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.49.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1159a90f-3fa3-49ea-605b-08d6b17d2225
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR05MB4512;
x-ms-traffictypediagnostic: VI1PR05MB4512:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB45124E626D6635C8202D9327CF5E0@VI1PR05MB4512.eurprd05.prod.outlook.com>
x-forefront-prvs: 0987ACA2E2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(39860400002)(376002)(346002)(396003)(189003)(199004)(305945005)(8936002)(86362001)(7416002)(5660300002)(71200400001)(71190400001)(68736007)(1076003)(53936002)(6306002)(54906003)(6512007)(316002)(229853002)(6436002)(36756003)(97736004)(6486002)(2906002)(76176011)(52116002)(386003)(6506007)(99286004)(102836004)(446003)(256004)(6116002)(105586002)(66066001)(3846002)(11346002)(33656002)(478600001)(14444005)(106356001)(8676002)(2616005)(966005)(14454004)(476003)(6246003)(25786009)(486006)(6916009)(7736002)(4326008)(26005)(81166006)(186003)(81156014);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4512;H:VI1PR05MB5166.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 N29VRnCjQn1wkEL9/rKP8bw7Tr7X+QiqnWeNxfJMsSRNl60MDeuogI7nxnF28kD4JCaTJwqlPhSb8Ls2mC6wtJu6y/CFxdEr+GpdIxOAd08+4Fny5LtLGiGLC+Mw7Er8DWUCMZCcj1xSlkbPY7v+P9Jhqup/pGPXetyzJriBoCOa5JmFByYvjBHavP+kNZFFuApxhF3u7giQszmSR2MmAWPBSKWv5g5J3Hc2eC7gdts+7CKXjX7ljGzbMjKMHsYFxW/YUnBpLdvy2M43MiyenyGpwW73Aitou7R5od/Ntc+ikyRrvWH9igzse8SXB6UAd42+Ajpk4eWb8QUchE0BmwwHakp6pDIR30P7tJEdbFXvqYV6uSefPKvwm42bFDRleEO5lCeFX/+QAJoLz/AmxGyTKvU53PkyeB5QuF0QBbY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1EABA02FD04A0A48A0BD78FE5C114508@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1159a90f-3fa3-49ea-605b-08d6b17d2225
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Mar 2019 23:53:52.4909
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4512
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 06:49:49PM -0400, Andrea Arcangeli wrote:
> The core dumping code has always run without holding the mmap_sem for
> writing, despite that is the only way to ensure that the entire vma
> layout will not change from under it. Only using some signal
> serialization on the processes belonging to the mm is not nearly
> enough. This was pointed out earlier. For example in Hugh's post from
> Jul 2017:
>=20
> https://lkml.kernel.org/r/alpine.LSU.2.11.1707191716030.2055@eggly.anvils
>=20
> "Not strictly relevant here, but a related note: I was very surprised
> to discover, only quite recently, how handle_mm_fault() may be called
> without down_read(mmap_sem) - when core dumping.  That seems a
> misguided optimization to me, which would also be nice to correct"
>=20
> In particular because the growsdown and growsup can move the
> vm_start/vm_end the various loops the core dump does around the vma
> will not be consistent if page faults can happen concurrently.
>=20
> Pretty much all users calling mmget_not_zero()/get_task_mm() and then
> taking the mmap_sem had the potential to introduce unexpected side
> effects in the core dumping code.
>=20
> Adding mmap_sem for writing around the ->core_dump invocation is a
> viable long term fix, but it requires removing all copy user and page
> faults and to replace them with get_dump_page() for all binary formats
> which is not suitable as a short term fix.
>=20
> For the time being this solution manually covers the places that can
> confuse the core dump either by altering the vma layout or the vma
> flags while it runs. Once ->core_dump runs under mmap_sem for writing
> the function mmget_still_valid() can be dropped.
>=20
> Allowing mmap_sem protected sections to run in parallel with the
> coredump provides some minor parallelism advantage to the swapoff
> code (which seems to be safe enough by never mangling any vma field
> and can keep doing swapins in parallel to the core dumping) and to
> some other corner case.
>=20
> In order to facilitate the backporting I added "Fixes: 86039bd3b4e6"
> however the side effect of this same race condition in /proc/pid/mem
> should be reproducible since before commit
> 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 so I couldn't add any other
> "Fixes:" because there's no hash beyond the git genesis commit.
>=20
> Because find_extend_vma() is the only location outside of the process
> context that could modify the "mm" structures under mmap_sem for
> reading, by adding the mmget_still_valid() check to it, all other
> cases that take the mmap_sem for reading don't need the new check
> after mmget_not_zero()/get_task_mm(). The expand_stack() in page fault
> context also doesn't need the new check, because all tasks under core
> dumping are frozen.
>=20
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Jann Horn <jannh@google.com>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Fixes: 86039bd3b4e6 ("userfaultfd: add new syscall to provide memory exte=
rnalization")
> Cc: stable@kernel.org
> Acked-by: Peter Xu <peterx@redhat.com>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> Reviewed-by: Oleg Nesterov <oleg@redhat.com>
> Reviewed-by: Jann Horn <jannh@google.com>
> ---
>  drivers/infiniband/core/uverbs_main.c |  3 +++
>  fs/proc/task_mmu.c                    | 18 ++++++++++++++++++
>  fs/userfaultfd.c                      |  9 +++++++++
>  include/linux/sched/mm.h              | 21 +++++++++++++++++++++
>  mm/mmap.c                             |  7 ++++++-
>  5 files changed, 57 insertions(+), 1 deletion(-)

For the ib part:

Acked-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

