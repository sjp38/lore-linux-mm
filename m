Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A638C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AEAC20836
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AEAC20836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCCD88E0125; Mon, 11 Feb 2019 21:28:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C550C8E0115; Mon, 11 Feb 2019 21:28:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1D758E0125; Mon, 11 Feb 2019 21:28:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8789C8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:28:20 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m196so1974843itc.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=gXXpOhiTxJq/WRDdT0/dXnwezqjX1LgWiNFpo2YPk1o=;
        b=K6tIutUWn9Ym+CR8vpEmt4Ky41nUmEefqD/0QuQZAWqlbuNWxPLgnp94c4lNX3P978
         1emEoM03k+QaIrxfFarWITObaAeXyNpzdWu1KODNF+hFo2XgkFF3jbBCoHVWgEHkZmHm
         rqksDMTsySkFupOVMqsis8jJmcVCKLTIPm9InncYKKA87IxIl4UoPlRmECSPsAjacevL
         vr6kth5V1iOrBIFpAOEjBcIDHpj8BHp8O4Xu3fhV0AHyI9+OFoR2Mq5r35aVLHyt6oxn
         9Z9v/k0zqX6SqwuGJMwnDrVUbEfVtOaCvGa+wCoIVtuIzn4Fen9AK/+NxIKRfCBLnYhK
         49Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AHQUAuYeouDFt6gU/uc8+y09vu/0aIKm274QrE6x+HjX15pZgoaqzz3a
	tA7D5VRIpdPXfgOebNAAOCMBQ4g7r1xxxLvQeU+qeXbo0hYuWNxSKiR9T90zyqI2dpr48njSGwo
	hjUtgrJ0CDy3gBM11tKmEhJZ9UZ9gE7LWJDg2jh5xhPojNoutDNNkq9ZKFNwFTD1fIw==
X-Received: by 2002:a02:9951:: with SMTP id d17mr713128jak.134.1549938500239;
        Mon, 11 Feb 2019 18:28:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY9PKwM9KkXhRSU2rpri4AckK3iWRIVlRhYyP2yRuE1zDntrR5I/NS+cRihFaFBmZ9gtxP4
X-Received: by 2002:a02:9951:: with SMTP id d17mr713102jak.134.1549938499326;
        Mon, 11 Feb 2019 18:28:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549938499; cv=none;
        d=google.com; s=arc-20160816;
        b=T7rFpxsOZMJ4OZkQxn2ioAAIyDmdSEPqIoFeQ70QKMOY2ygLRbhT3WVAaLJRMRAM0F
         6hRdVoUgr6kTzfmPfeY6dM3VhSMYL+uW3BtN/AXfHSwZFQjwXTmTqlI/GNL4t1/5YYBK
         YIWFrf0gzm17WLAjNgXqKN1RIKWKtNHGNx2ggdrJQxxHUKhFBBy4WVv6fQr4SfO6rqae
         ARDk6M2Z/fJ9mJjqKvu8oMHS938zb6OYAww7yei2bo1DCqGXRwjsxa9Wog1z+45IZvs9
         Zikg0DINuPQydOTK6HhQ4Z2jB7AJMN1SBJY5SK3wf6xudpxg+mIAnRo4cnySP0+xxWK/
         bE/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=gXXpOhiTxJq/WRDdT0/dXnwezqjX1LgWiNFpo2YPk1o=;
        b=jnytMnxEHmwqGTG7lBRx2Q4qbAI/Je7ZNZhIRklIe4pDN36MGe2C+3Ine3zO43V/ht
         J6OqDy9hUU7xZElC6rO73/Pn4NBeN5CgHUxPukQqAOZp8CJz8+9IaGjI8RALD1ilMctF
         E39IhK+bjCWPhelUitVs7zagUOAyMBr7J8yTPQeOIL2mdF8Wdw7reNgpgZcbjFnQb9f0
         VymCdQuwxZ4Er8pZaDerya3RrhJf0dBSXiWBPOU0g5osh/mDCp/hG0dEiOHWg1BMROFk
         XiSKGmKlqkr7ZzpUEaEIoM4QxU35dxakFxnqO9eaYdn0uR2bCv3davUDtVtBavYiQVpZ
         v+Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id l197si652214itl.32.2019.02.11.18.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:28:19 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x1C2SDTt005703
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 12 Feb 2019 11:28:13 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x1C2SDt8023625;
	Tue, 12 Feb 2019 11:28:13 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x1C2R5hR011347;
	Tue, 12 Feb 2019 11:28:13 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-2305838; Tue, 12 Feb 2019 11:24:30 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0319.002; Tue,
 12 Feb 2019 11:24:29 +0900
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
Thread-Index: AQHUuODePgsnC0Y0+kCvHMlE24frN6XUI3qAgACAsgCAADeYAIAAHE6AgAW8IYCAADdTAA==
Date: Tue, 12 Feb 2019 02:24:28 +0000
Message-ID: <20190212022428.GA12369@hori1.linux.bs1.fc.nec.co.jp>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
 <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
 <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
 <20190208073149.GA14423@hori1.linux.bs1.fc.nec.co.jp>
 <ffe58925-a301-6791-44d5-e3bec7f9ebf3@oracle.com>
In-Reply-To: <ffe58925-a301-6791-44d5-e3bec7f9ebf3@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.51.8.82]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <69DFA1325EDE5E42AA1565A296EAB74D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 03:06:27PM -0800, Mike Kravetz wrote:
> On 2/7/19 11:31 PM, Naoya Horiguchi wrote:
> > On Thu, Feb 07, 2019 at 09:50:30PM -0800, Mike Kravetz wrote:
> >> On 2/7/19 6:31 PM, Naoya Horiguchi wrote:
> >>> On Thu, Feb 07, 2019 at 10:50:55AM -0800, Mike Kravetz wrote:
> >>>> On 1/30/19 1:14 PM, Mike Kravetz wrote:
> >>>>> +++ b/fs/hugetlbfs/inode.c
> >>>>> @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct addre=
ss_space *mapping,
> >>>>>  	rc =3D migrate_huge_page_move_mapping(mapping, newpage, page);
> >>>>>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
> >>>>>  		return rc;
> >>>>> +
> >>>>> +	/*
> >>>>> +	 * page_private is subpool pointer in hugetlb pages, transfer
> >>>>> +	 * if needed.
> >>>>> +	 */
> >>>>> +	if (page_private(page) && !page_private(newpage)) {
> >>>>> +		set_page_private(newpage, page_private(page));
> >>>>> +		set_page_private(page, 0);
> >>>
> >>> You don't have to copy PagePrivate flag?
> >>>
> >>
> >> Well my original thought was no.  For hugetlb pages, PagePrivate is no=
t
> >> associated with page_private.  It indicates a reservation was consumed=
.
> >> It is set  when a hugetlb page is newly allocated and the allocation i=
s
> >> associated with a reservation and the global reservation count is
> >> decremented.  When the page is added to the page cache or rmap,
> >> PagePrivate is cleared.  If the page is free'ed before being added to =
page
> >> cache or rmap, PagePrivate tells free_huge_page to restore (increment)=
 the
> >> reserve count as we did not 'instantiate' the page.
> >>
> >> So, PagePrivate is only set from the time a huge page is allocated unt=
il
> >> it is added to page cache or rmap.  My original thought was that the p=
age
> >> could not be migrated during this time.  However, I am not sure if tha=
t
> >> reasoning is correct.  The page is not locked, so it would appear that=
 it
> >> could be migrated?  But, if it can be migrated at this time then perha=
ps
> >> there are bigger issues for the (hugetlb) page fault code?
> >=20
> > In my understanding, free hugetlb pages are not expected to be passed t=
o
> > migrate_pages(), and currently that's ensured by each migration caller
> > which checks and avoids free hugetlb pages on its own.
> > migrate_pages() and its internal code are probably not aware of handlin=
g
> > free hugetlb pages, so if they are accidentally passed to migration cod=
e,
> > that's a big problem as you are concerned.
> > So the above reasoning should work at least this assumption is correct.
> >=20
> > Most of migration callers are not intersted in moving free hugepages.
> > The one I'm not sure of is the code path from alloc_contig_range().
> > If someone think it's worthwhile to migrate free hugepage to get bigger
> > contiguous memory, he/she tries to enable that code path and the assump=
tion
> > will be broken.
>=20
> You are correct.  We do not migrate free huge pages.  I was thinking more
> about problems if we migrate a page while it is being added to a task's p=
age
> table as in hugetlb_no_page.
>=20
> Commit bcc54222309c ("mm: hugetlb: introduce page_huge_active") addresses
> this issue, but I believe there is a bug in the implementation.
> isolate_huge_page contains this test:
>=20
> 	if (!page_huge_active(page) || !get_page_unless_zero(page)) {
> 		ret =3D false;
> 		goto unlock;
> 	}
>=20
> If the condition is not met, then the huge page can be isolated and migra=
ted.
>=20
> In hugetlb_no_page, there is this block of code:
>=20
>                 page =3D alloc_huge_page(vma, haddr, 0);
>                 if (IS_ERR(page)) {
>                         ret =3D vmf_error(PTR_ERR(page));
>                         goto out;
>                 }
>                 clear_huge_page(page, address, pages_per_huge_page(h));
>                 __SetPageUptodate(page);
>                 set_page_huge_active(page);
>=20
>                 if (vma->vm_flags & VM_MAYSHARE) {
>                         int err =3D huge_add_to_page_cache(page, mapping,=
 idx);
>                         if (err) {
>                                 put_page(page);
>                                 if (err =3D=3D -EEXIST)
>                                         goto retry;
>                                 goto out;
>                         }
>                 } else {
>                         lock_page(page);
>                         if (unlikely(anon_vma_prepare(vma))) {
>                                 ret =3D VM_FAULT_OOM;
>                                 goto backout_unlocked;
>                         }
>                         anon_rmap =3D 1;
>                 }
>         } else {
>=20
> Note that we call set_page_huge_active BEFORE locking the page.  This
> means that we can isolate the page and have migration take place while
> we continue to add the page to page tables.  I was able to make this
> happen by adding a udelay() after set_page_huge_active to simulate worst
> case scheduling behavior.  It resulted in VM_BUG_ON while unlocking page.
> My test had several threads faulting in huge pages.  Another thread was
> offlining the memory blocks forcing migration.

This shows another problem, so I agree we need a fix.

>=20
> To fix this, we need to delay the set_page_huge_active call until after
> the page is locked.  I am testing a patch with this change.  Perhaps we
> should even delay calling set_page_huge_active until we know there are
> no errors and we know the page is actually in page tables?

Yes, calling set_page_huge_active after page table is set up sounds nice to=
 me.

>=20
> While looking at this, I think there is another issue.  When a hugetlb
> page is migrated, we do not migrate the 'page_huge_active' state of the
> page.  That should be moved as the page is migrated.  Correct?

Yes, and I think that putback_active_hugepage(new_hpage) at the last step
of migration sequence handles the copying of 'page_huge_active' state.

Thanks,
Naoya Horiguchi=

