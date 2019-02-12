Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 905B4C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:53:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 349CC222B1
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 21:53:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sLIBRlBc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 349CC222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86C88E0003; Tue, 12 Feb 2019 16:53:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6148E0001; Tue, 12 Feb 2019 16:53:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5CC8E0003; Tue, 12 Feb 2019 16:53:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6DC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:53:41 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id n22so234517otq.8
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:53:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LEY0p2JsVS3a2cs2tzozqI6GCoofE/g5BNWFzUCn+cU=;
        b=LOtz7RQxXxQYy7WzMDR6+pqqZu5WIJ4N2FD7bC/id0V+txuxTMP0D+MgKo7Fw6gCge
         X2Saf5DWnu8lfftnZsXa/IWWCXwjFK+AJhNws2ZambuJV9724PigXRQ+K/byJqu5dYoQ
         dSIxHOTL1jSAQCGOvZ6rP7ZDi5NN3EK5NaaViMkNg0isckb40h9C/STkGVtaIfLiUDnu
         B6JrOiPd9q4KNEisWXyoF7/OqsOTRjdu1AWSyS6Az8q/TYeDdC0o/t1uILDtSzC2TRi5
         Z+GwwLOYTvb9iZOcgwvMkWg1CHkDEG8nKLBKk8v5tnA3RhxphsSYJSK0hZ99mQp8yZYP
         Jbhg==
X-Gm-Message-State: AHQUAua63H+yrls6x49CdHBvek6SE+OEJG2o6ODcGMr2quzkllBa0j3d
	wQ3EWS20Uc/foAcWGKS2hvEQu82FCGct/p1W4kAEgOiTfQzeGiq8extuPfbctPzdszWnm+7eFTk
	ZrFOhKUb9ryJiPFFtILNSTBFcp1UqmCwh6zmQa6fWxlS5PdHXZ7qyTCjCZ7Hh0Vh7wIY0F8AQqg
	Ysyw04ZYwAxQ9krbDzuWsfXeJPjwVaXp1oS+jD8KekaRDUFHYvgLiwbhTlgBMXw50jA13Kz9pXW
	TjB9KiO8UxD7t/ABKJS/LZ7R4CemV2nWpuFGh0wxCiB16bLkRGy9Kj0Yxo4Qa4wvyC/2yFPOVi4
	uQ4jS3PM9XKbQ2ZdNzt+uSNer2MxoGehZM7dnH0LrC8sekDg0qrUqf3MQeHjUpPp8dBXnwYRiw6
	D
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr6378617otc.224.1550008421164;
        Tue, 12 Feb 2019 13:53:41 -0800 (PST)
X-Received: by 2002:a05:6830:2118:: with SMTP id i24mr6378568otc.224.1550008420208;
        Tue, 12 Feb 2019 13:53:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550008420; cv=none;
        d=google.com; s=arc-20160816;
        b=FkithLJwm7gdx/S/INZE/ihQ42eoE7hdNC4FDRIsmty2IveUs5Hetmp7R/q7kQsJji
         0UNDND7yfpCKU0a7G3RvBGlKG63n3QyJKgWGWt7V/64z84mXWXBpN1avoIYYZgNZIIk7
         p4CEaADhEFWozThXFBDT6dqJtq4JAiG2JjBYK1r61cNXniEkDMO4IQCvcZlVaYRYJisR
         RDqHREAkjmRSxtnI+wakzWTg/ZeLZEHO/1Trh2+nJshvN/5YIefmRtZgIEn17gGyy/OA
         EQml8T+15PXjDkOaV4fiW8EA95Tvf27cU3yWca+K77bJs7dbUTcRQG2HDjhL/Am6Y4tz
         jo2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LEY0p2JsVS3a2cs2tzozqI6GCoofE/g5BNWFzUCn+cU=;
        b=N8UggbHpRMN48uC4d6fJTrXoA/kqVkh15gHFbXxzdLXcPsT+3Dy8bqGtQFx3Qi+l4G
         I5AeiK0JTLYzffiMoqX0rpdrZErR8QundH9lLB/RW5GDSQ11ZXZ5F0RbE3jzpXpv9K2l
         3P09XOV/3roSEMqhC4t3UGOcGcm03IWvc2Mi6pgumPwOWMeVkzrHRlyhgVlcYfZXYk+g
         rFnrlo9yDvetHGVoLS75cMxbyMcrWt6WEP2pwh438dxnSdXEMpW3CpYwZ8c4bp+0Qgsu
         wTXDelne1LZoKfQ0pllEdcytBTqFvBBAWvACvwOT+89aGa6KDDld/FQkvzSaiVERvMI5
         L61Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sLIBRlBc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor10004584oth.145.2019.02.12.13.53.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 13:53:40 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sLIBRlBc;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LEY0p2JsVS3a2cs2tzozqI6GCoofE/g5BNWFzUCn+cU=;
        b=sLIBRlBc+Y8VcrK+ShKJOL8wF5wcZGUpE1b1zS7aKUuoEfelW/Xnsh4EIoEEJd+AkB
         YO7N/Fuqlg4tH7X3nxrOEPc9skJp55kuBARmO6xshNmL3uRFAUbbKRj3SKqKlvWtGhu/
         oIKEsZ0qzAzQzCFTO05o8oAJ31m5M4gqYsHJ74U04N9h8TN4ZkBM/szhAR0WQVBTmn0M
         1FIovxk+90qqM8dr4fx/aDrW28KbxobMUMiX3U+94G4Y/ADcXYEGIZMadw3b0rXOBGci
         dv7Dq/MKHmrhbPTOgzRELvXXowa8lWX/WM0oqsF3p9M9aZ4dOItgGpntqqd92jEjHZmO
         pJLw==
X-Google-Smtp-Source: AHgI3IZpfzC+AasjrLyEJAqixfclkYCg9uWm1t2iYvho00RBxJ8f327SO5wiNwXoXsM5Sn9KAE1MJ7QK3+hFPfGccP8=
X-Received: by 2002:a9d:7493:: with SMTP id t19mr5757624otk.98.1550008419886;
 Tue, 12 Feb 2019 13:53:39 -0800 (PST)
MIME-Version: 1.0
References: <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz> <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190212160707.GA19076@quack2.suse.cz>
In-Reply-To: <20190212160707.GA19076@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Feb 2019 13:53:28 -0800
Message-ID: <CAPcyv4gKJ3=LhdO8Bnx2f-fnT_7H5D4FxvJDCEDEpcz1udnY_g@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>, 
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 8:07 AM Jan Kara <jack@suse.cz> wrote:
>
> On Mon 11-02-19 09:22:58, Dan Williams wrote:
> > On Mon, Feb 11, 2019 at 2:24 AM Jan Kara <jack@suse.cz> wrote:
> > >
> > > On Fri 08-02-19 12:50:37, Dan Williams wrote:
> > > > On Fri, Feb 8, 2019 at 3:11 AM Jan Kara <jack@suse.cz> wrote:
> > > > >
> > > > > On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > > > > > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > > > > > One approach that may be a clean way to solve this:
> > > > > > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > > > > > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > > > > > >    on the longterm pinned range until the long term pin is removed.
> > > > > >
> > > > > > So, ummm, how do we do block allocation then, which is done on
> > > > > > demand during writes?
> > > > > >
> > > > > > IOWs, this requires the application to set up the file in the
> > > > > > correct state for the filesystem to lock it down so somebody else
> > > > > > can write to it.  That means the file can't be sparse, it can't be
> > > > > > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > > > > > written to it's full size before being shared because otherwise it
> > > > > > exposes stale data to the remote client (secure sites are going to
> > > > > > love that!), they can't be extended, etc.
> > > > > >
> > > > > > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > > > > > an immutable for the purposes of local access.
> > > > > >
> > > > > > Which, essentially we can already do. Prep the file, map it
> > > > > > read/write, mark it immutable, then pin it via the longterm gup
> > > > > > interface which can do the necessary checks.
> > > > >
> > > > > Hum, and what will you do if the immutable file that is target for RDMA
> > > > > will be a source of reflink? That seems to be currently allowed for
> > > > > immutable files but RDMA store would be effectively corrupting the data of
> > > > > the target inode. But we could treat it similarly as swapfiles - those also
> > > > > have to deal with writes to blocks beyond filesystem control. In fact the
> > > > > similarity seems to be quite large there. What do you think?
> > > >
> > > > This sounds so familiar...
> > > >
> > > >     https://lwn.net/Articles/726481/
> > > >
> > > > I'm not opposed to trying again, but leases was what crawled out
> > > > smoking crater when this last proposal was nuked.
> > >
> > > Umm, don't think this is that similar to daxctl() discussion. We are not
> > > speaking about providing any new userspace API for this.
> >
> > I thought explicit userspace API was one of the outcomes, i.e. that we
> > can't depend on this behavior being an implicit side effect of a page
> > pin?
>
> I was thinking an implicit sideeffect of gup_longterm() call. Similarly as
> swapon(2) does not require the file to be marked in any special way. But
> OTOH I agree that RDMA is a less controlled usage than swapon so it is
> questionable. I'd still require something like CAP_LINUX_IMMUTABLE at least
> for gup_longterm() calls that end up pinning the file.
>
> Inspired by Christoph's idea you reference in [2], maybe gup_longterm()
> will succeed only if there is FL_LAYOUT lease for the range being pinned
> and we don't allow the lease to be released until there's a pinned page in
> the range. And we make the file protected (i.e. treat it like swapfile) if
> there's any such lease in it. But this is just a rough sketch and needs more
> thinking.
>
> > > Also I think the
> > > situation about leases has somewhat cleared up with this discussion - ODP
> > > hardware does not need leases since it can use MMU notifiers, for non-ODP
> > > hardware it is difficult to handle leases as such hardware has only one big
> > > kill-everything call and using that would effectively mean lot of work on
> > > the userspace side to resetup everything to make things useful if workable
> > > at all.
> > >
> > > So my proposal would be:
> > >
> > > 1) ODP hardward uses gup_fast() like direct IO and uses MMU notifiers to do
> > > its teardown when fs needs it.
> > >
> > > 2) Hardware not capable of tearing down pins from MMU notifiers will have
> > > to use gup_longterm() (we may actually rename it to a more suitable name).
> > > FS may just refuse such calls (for normal page cache backed file, it will
> > > just return success but for DAX file it will do sanity checks whether the
> > > file is fully allocated etc. like we currently do for swapfiles) but if
> > > gup_longterm() returns success, it will provide the same guarantees as for
> > > swapfiles. So the only thing that we need is some call from gup_longterm()
> > > to a filesystem callback to tell it - this file is going to be used by a
> > > third party as an IO buffer, don't touch it. And we can (and should)
> > > probably refactor the handling to be shared between swapfiles and
> > > gup_longterm().
> >
> > Yes, lets pursue this. At the risk of "arguing past 'yes'" this is a
> > solution I thought we dax folks walked away from in the original
> > MAP_DIRECT discussion [1]. Here is where leases were the response to
> > MAP_DIRECT [2]. ...and here is where we had tame discussions about
> > implications of notifying memory-registrations of lease break events
> > [3].
>
> Yeah, thanks for the references.
>
> > I honestly don't like the idea that random subsystems can pin down
> > file blocks as a side effect of gup on the result of mmap. Recall that
> > it's not just RDMA that wants this guarantee. It seems safer to have
> > the file be in an explicit block-allocation-immutable-mode so that the
> > fallocate man page can describe this error case. Otherwise how would
> > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
>
> So with requiring lease for gup_longterm() to succeed (and the
> FALLOC_FL_PUNCH_HOLE failure being keyed from the existence of such lease),
> does it look more reasonable to you?

That sounds reasonable to me, just the small matter of teaching the
non-ODP RDMA ecosystem to take out FL_LAYOUT leases and do something
reasonable when the lease needs to be recalled.

I would hope that RDMA-to-FSDAX-PMEM support is enough motivation to
either make the necessary application changes, or switch to an
ODP-capable adapter.

Note that I think we need FL_LAYOUT regardless of whether the
legacy-RDMA stack ever takes advantage of it. VFIO device passthrough
to a guest that has a host DAX file mapped as physical PMEM in the
guest needs guarantees that the guest will be killed and DMA force
blocked by the IOMMU if someone punches a hole in memory in use by a
guest, or otherwise have a paravirtualized driver in the guest to
coordinate what effectively looks like a physical memory unplug event.

