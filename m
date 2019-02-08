Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC1CDC282C2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 02:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56C4420869
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 02:33:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56C4420869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA4DE8E0070; Thu,  7 Feb 2019 21:33:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D570F8E0002; Thu,  7 Feb 2019 21:33:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C44AB8E0070; Thu,  7 Feb 2019 21:33:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 989C98E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 21:33:30 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id c26so1759765otl.19
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 18:33:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=IKpjQkZbRkkhPnPCaC4xHj2Pvhtu37CUCeivN4uuKzg=;
        b=PFOBu7SWrTDkiLbo4DZSmI1DMge53Qypujhg9HrZ+yyymKnBzdpgNJ/Wrzxlvyt1ie
         oUW2Pg4xdhUUkSUONRceBTb7wpcQMacnfqzUURuE8myBnbF2G+h7mpG/m3U3gbjWgBnj
         jpcWh+BVXe5GlI1Tz7RsA4gJbBNOOf346yQ7oOWF9fDMuu6Nn8nU3dW9FejbUZkIqblf
         8zLsg4Ewr7X3H3Sd5xLR42gYk7peR/slXcTsnLjsxfVRi3yEZOQOsJgry3b/PV2VFCJB
         bu4karHgLU13JB3410izeXp01B9f1IlpwVA4LVzhiQYj/z5we5CPtnsxKuhbqUWL3xse
         pAUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AHQUAuasF4VlT53c9GBTeYgP4yCvyGhihHCmKDLLcVR6s0DgLz6BCBKI
	U2eBjriPjHeMODxrWtI1FWJrRxpIp7pNaGLklH75k4kzaDvZcqY6Dzuz+wuXXcgo64TbmAfMwnP
	dil4Y3qBPxgGLSc9SV/kfiLW/XtnrJsYVCqrmBu6mQMuSu3WfRCbLLrLZr7jUBMJcTw==
X-Received: by 2002:a9d:7c8c:: with SMTP id q12mr11215578otn.166.1549593210331;
        Thu, 07 Feb 2019 18:33:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYvWIeTpNiofvnb4cwryi0J8Xr+VwO8xC2aiFCwr7XrcxkYKs0J+IB4xa0As5WfB0xxvLbL
X-Received: by 2002:a9d:7c8c:: with SMTP id q12mr11215537otn.166.1549593209164;
        Thu, 07 Feb 2019 18:33:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549593209; cv=none;
        d=google.com; s=arc-20160816;
        b=yWoy6i2MaR84qzwfdMSMPY0dmCbTKJUE9h+1v6bXgQuYA5RbSM7QiIpXmXq3NwTZdw
         czfV/fdbVDW49gcoRy8nUkhFBT85gbJiissom2bibnM32XOkRsf7Hqemln9afwm3QmbC
         FSAculea1buMuXLq9ArtmiF3OBRfsrW4JNtpTIOa5XYyinaT8f8ieQcXwQ2Trn1pgfg7
         5QKNkDMHRaj0XwCuSisk9Ur1jRMUs80JZyP+vitbNCPeVXPLCQXe1kETyWLPyDdbTxVq
         hW0opnPNUkiGpYw4ehzoXeVghPTcTbQ+07dTQGmvp68kEgP3ZUFg513fmJnUVD0tJ2MJ
         V6/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=IKpjQkZbRkkhPnPCaC4xHj2Pvhtu37CUCeivN4uuKzg=;
        b=AAb3wtqFCD2vHKun7tWXCL17OYzWeULWue4ur5uls8ML3dAbkkDfGOo1ntQgmCXftQ
         Rvai1SOsHTfqdVcHV74LiPhPNULF+hPDN5euE01PowWhH37eE0+5fXZu4JdG5jKPif1W
         GNTrMOiehm4WV493XC5g0x7DXee5Ky2WZ9sWi8FNHBqS6tCDbRRbMa13OmjMWLl4SPed
         MBMIuMxcAfgiuThiMoJsl9ub7TXSJ98sJxv9y2uWe+xN5ydWJv0BX1n07ZDVtbEbIXgi
         tnab90n7ORy8gNCOnw/ftYJUgpyIdM+nwANj5Z+eV7Hx0U1tVVG8oCgPYtniT0vpBRSt
         Pddw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v2si365778oib.3.2019.02.07.18.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 18:33:29 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x182XDnB010804
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 8 Feb 2019 11:33:13 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x182XD1o010380;
	Fri, 8 Feb 2019 11:33:13 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x182UJQ6009244;
	Fri, 8 Feb 2019 11:33:13 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-2243517; Fri, 8 Feb 2019 11:31:37 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0319.002; Fri, 8
 Feb 2019 11:31:33 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Andrea Arcangeli" <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
Thread-Topic: [PATCH] huegtlbfs: fix page leak during migration of file pages
Thread-Index: AQHUuODePgsnC0Y0+kCvHMlE24frN6XUI3qAgACAsgA=
Date: Fri, 8 Feb 2019 02:31:32 +0000
Message-ID: <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
In-Reply-To: <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.51.8.80]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8B32F1E2DB634345BF8BC57CB1E70688@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 10:50:55AM -0800, Mike Kravetz wrote:
> On 1/30/19 1:14 PM, Mike Kravetz wrote:
> > Files can be created and mapped in an explicitly mounted hugetlbfs
> > filesystem.  If pages in such files are migrated, the filesystem
> > usage will not be decremented for the associated pages.  This can
> > result in mmap or page allocation failures as it appears there are
> > fewer pages in the filesystem than there should be.
>=20
> Does anyone have a little time to take a look at this?
>=20
> While migration of hugetlb pages 'should' not be a common issue, we
> have seen it happen via soft memory errors/page poisoning in production
> environments.  Didn't see a leak in that case as it was with pages in a
> Sys V shared mem segment.  However, our DB code is starting to make use
> of files in explicitly mounted hugetlbfs filesystems.  Therefore, we are
> more likely to hit this bug in the field.

Hi Mike,

Thank you for finding/reporting the problem.
# sorry for my late response.

>=20
> >=20
> > For example, a test program which hole punches, faults and migrates
> > pages in such a file (1G in size) will eventually fail because it
> > can not allocate a page.  Reported counts and usage at time of failure:
> >=20
> > node0
> > 537	free_hugepages
> > 1024	nr_hugepages
> > 0	surplus_hugepages
> > node1
> > 1000	free_hugepages
> > 1024	nr_hugepages
> > 0	surplus_hugepages
> >=20
> > Filesystem                         Size  Used Avail Use% Mounted on
> > nodev                              4.0G  4.0G     0 100% /var/opt/hugep=
ool
> >=20
> > Note that the filesystem shows 4G of pages used, while actual usage is
> > 511 pages (just under 1G).  Failed trying to allocate page 512.
> >=20
> > If a hugetlb page is associated with an explicitly mounted filesystem,
> > this information in contained in the page_private field.  At migration
> > time, this information is not preserved.  To fix, simply transfer
> > page_private from old to new page at migration time if necessary. Also,
> > migrate_page_states() unconditionally clears page_private and PagePriva=
te
> > of the old page.  It is unlikely, but possible that these fields could
> > be non-NULL and are needed at hugetlb free page time.  So, do not touch
> > these fields for hugetlb pages.
> >=20
> > Cc: <stable@vger.kernel.org>
> > Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> > ---
> >  fs/hugetlbfs/inode.c | 10 ++++++++++
> >  mm/migrate.c         | 10 ++++++++--
> >  2 files changed, 18 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> > index 32920a10100e..fb6de1db8806 100644
> > --- a/fs/hugetlbfs/inode.c
> > +++ b/fs/hugetlbfs/inode.c
> > @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address_s=
pace *mapping,
> >  	rc =3D migrate_huge_page_move_mapping(mapping, newpage, page);
> >  	if (rc !=3D MIGRATEPAGE_SUCCESS)
> >  		return rc;
> > +
> > +	/*
> > +	 * page_private is subpool pointer in hugetlb pages, transfer
> > +	 * if needed.
> > +	 */
> > +	if (page_private(page) && !page_private(newpage)) {
> > +		set_page_private(newpage, page_private(page));
> > +		set_page_private(page, 0);

You don't have to copy PagePrivate flag?

> > +	}
> > +
> >  	if (mode !=3D MIGRATE_SYNC_NO_COPY)
> >  		migrate_page_copy(newpage, page);
> >  	else
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f7e4bfdc13b7..0d9708803553 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -703,8 +703,14 @@ void migrate_page_states(struct page *newpage, str=
uct page *page)
> >  	 */
> >  	if (PageSwapCache(page))
> >  		ClearPageSwapCache(page);
> > -	ClearPagePrivate(page);
> > -	set_page_private(page, 0);
> > +	/*
> > +	 * Unlikely, but PagePrivate and page_private could potentially
> > +	 * contain information needed at hugetlb free page time.
> > +	 */
> > +	if (!PageHuge(page)) {
> > +		ClearPagePrivate(page);
> > +		set_page_private(page, 0);
> > +	}

# This argument is mainly for existing code...

According to the comment on migrate_page():

    /*
     * Common logic to directly migrate a single LRU page suitable for
     * pages that do not use PagePrivate/PagePrivate2.
     *
     * Pages are locked upon entry and exit.
     */
    int migrate_page(struct address_space *mapping, ...

So this common logic assumes that page_private is not used, so why do
we explicitly clear page_private in migrate_page_states()?
buffer_migrate_page(), which is commonly used for the case when
page_private is used, does that clearing outside migrate_page_states().
So I thought that hugetlbfs_migrate_page() could do in the similar manner.
IOW, migrate_page_states() should not do anything on PagePrivate.
But there're a few other .migratepage callbacks, and I'm not sure all of
them are safe for the change, so this approach might not fit for a small fi=
x.

# BTW, there seems a typo in $SUBJECT.

Thanks,
Naoya Horiguchi=

