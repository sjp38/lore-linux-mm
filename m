Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E653C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C9FF218AD
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:23:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="p7pZU1mU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C9FF218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0A338E0109; Mon, 11 Feb 2019 12:23:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9728E0108; Mon, 11 Feb 2019 12:23:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA9918E0109; Mon, 11 Feb 2019 12:23:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC5D8E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:23:12 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id e25so3188549otp.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:23:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o1nrH+8ogBjgSgeb4HNQFQvWovEpxMsUGDfu1u+2kkU=;
        b=eJl38pr1cevqibP0lCbyxoN5U9vhTk2W3aB9ppxCT7h2uqA7VTtxVMvo+1U8TGgxOa
         t+lf4szHmjRejDnuCHsyCm1uQrsKQb+0KcukYd308xNlMtHHzZKCdZ9jvNrtrssl4YRD
         ripPT4iUhK+31omkpYDAS8wi+9IIPf8QWA2ub6ZQtPoXA6oPRXqeCi5AmdbFkgAA3Kin
         LRUOdpksDltqSFIgZGUjDBDFL0GXQeDYrIwZvykvou2gyEYDtgHfa9KzACwNCYjpMkOC
         0uo9VseIY0ylYCywn6goW+/6VbR5DIs8ZRzf/ptcJ1rjneeAJJ78G0BwPq+piCCrrA0d
         0STQ==
X-Gm-Message-State: AHQUAuZK62AZ/xqSLPv4JGfUeMQSYC6EZItHYF8Qkq8sGCuvHDGwT2ej
	dbN71cvDBUUq2WtZkMXXoulgePFB+VX1tBI4t4YCUiXfk5NGOts38F/vdtV2M6If3eBQF0x0vB0
	un8BDzNEf5XbuEWDNNVqLLVpZCWEZLCwN4khEnobCUkEAa5mYNOQbX7HfP1ADURFcoLnd9+TFjr
	EbvHZElAocwy//aOA3pNCSkPx7BlswUggCnOtAsRdamTP+lUEHD3+ZvG8awQMY1ednnKzTHtn03
	/sKnGfd1ax4kkFR69/KC2OzSnFqHCD/Kv42lUY8JfKuQYH8vPKPaY/2Djpgu5gODedhbGTWq3KS
	1iVQxzaWUPEzZU3lw3kcU2bmH+O+/YIEZ20sDKEGb1QiW/IaGT4r6QoM2lj7wQRxblKqlm/BikJ
	C
X-Received: by 2002:a9d:2aa2:: with SMTP id e31mr26878225otb.246.1549905792202;
        Mon, 11 Feb 2019 09:23:12 -0800 (PST)
X-Received: by 2002:a9d:2aa2:: with SMTP id e31mr26878152otb.246.1549905791233;
        Mon, 11 Feb 2019 09:23:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549905791; cv=none;
        d=google.com; s=arc-20160816;
        b=Znlpuq3DUTa0gtlbzRG5zLIzJ6aUNGmSF9mgJ7GmYo/jWbiEBvAyrTQtk1w7ZsAHp1
         hkMrPb/1IzdUBIU+KNohtqXWYunUM3GXOhIcpsNQ/rbJhKa1quxXXtdbElnXaV8Hp1/H
         CeUpDcHFbiJnmc0UDGlqvLsHF3Y+Pt2dNBoXKRonvSU7ldvhm54FZUx8krY6ua2pMqWV
         Cef9SLGTey0KXcVJJYTAFWFoQZh4tOaAAIJfe6jSfiPnd+l+zwNjh3MA8XOPZTJNvC/P
         w769A4qU/Kxjg9CgcLj6BmrndlTY81jpkD69ClTl/dz/YizAQdI+/kkYJ4XFTYB7brR/
         FrIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o1nrH+8ogBjgSgeb4HNQFQvWovEpxMsUGDfu1u+2kkU=;
        b=GU0Jy3BAw6ddb+rVQn2T7IJn57JGthDoEtUL2W+O4nYn0GRX8B2t4QjcbB1SSg+zf1
         vErkLk9i9mtc+VKLkQ6sK8NBaa8R3piauiB0ZnzsJzT0eC4SJI842GtABAPQDGGtB/rO
         yGleQlBwIcn/Zld7fYLnCjavzKvnNGihiJLGFHcS8GMF3pMDYSu1dpHqR2ViUfOV5TDO
         Hafn3ZlriA3LCA6x/EF8WJLnbJRgFnBANVfHAvsHWXi9GKOjLoO1TNUILK4GqmqflwDu
         N3MqZIxAkz0aZVywAcICo6cH1tow/eet722aSjKfzj1JfXlnmxk1DfAiurx4SsiKZ5Rs
         9qzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=p7pZU1mU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor6598040otl.153.2019.02.11.09.23.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 09:23:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=p7pZU1mU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o1nrH+8ogBjgSgeb4HNQFQvWovEpxMsUGDfu1u+2kkU=;
        b=p7pZU1mUiFZt/u3lajcfnXFdK2z9M3MMylttADFFO6eUCs5geVuZhtxCw49BYfznNN
         L5/wh9bOceAYCNkf+sOH4He34tW4H+6lTFda+nAtQimmux8Oq69hflpOTOXppqmlWzh/
         rMtIJrWb8zzm/0YUL2kpApbzxO3Ev7W7WPgrZoLZ96DD2NnWnunyDQ8sJrUHq2XEGKUu
         wBuaHS9nGEDwsorvR1ykvKPeSNC40ybYgaebCaanEod3AS88W7zWr994PhTiXXNxvp9D
         AY0tNZOj1PDbzWtX9+gc1FvzR9nIseG2SMCv/sAOVeRreQwSBnpGNEvFAK418F8aw17v
         tqcA==
X-Google-Smtp-Source: AHgI3Ia+3sp/KNQdqJWhf7lnR3C+r7P+OHqpDAnEvZEn6yGmZeOv13PJfK7OQzWZlo8rxwwNPxrAB4uJucPn8GbUaNk=
X-Received: by 2002:a9d:7d18:: with SMTP id v24mr20500736otn.352.1549905790519;
 Mon, 11 Feb 2019 09:23:10 -0800 (PST)
MIME-Version: 1.0
References: <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com> <20190211102402.GF19029@quack2.suse.cz>
In-Reply-To: <20190211102402.GF19029@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 09:22:58 -0800
Message-ID: <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
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

On Mon, Feb 11, 2019 at 2:24 AM Jan Kara <jack@suse.cz> wrote:
>
> On Fri 08-02-19 12:50:37, Dan Williams wrote:
> > On Fri, Feb 8, 2019 at 3:11 AM Jan Kara <jack@suse.cz> wrote:
> > >
> > > On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > > > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > > > One approach that may be a clean way to solve this:
> > > > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > > > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > > > >    on the longterm pinned range until the long term pin is removed.
> > > >
> > > > So, ummm, how do we do block allocation then, which is done on
> > > > demand during writes?
> > > >
> > > > IOWs, this requires the application to set up the file in the
> > > > correct state for the filesystem to lock it down so somebody else
> > > > can write to it.  That means the file can't be sparse, it can't be
> > > > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > > > written to it's full size before being shared because otherwise it
> > > > exposes stale data to the remote client (secure sites are going to
> > > > love that!), they can't be extended, etc.
> > > >
> > > > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > > > an immutable for the purposes of local access.
> > > >
> > > > Which, essentially we can already do. Prep the file, map it
> > > > read/write, mark it immutable, then pin it via the longterm gup
> > > > interface which can do the necessary checks.
> > >
> > > Hum, and what will you do if the immutable file that is target for RDMA
> > > will be a source of reflink? That seems to be currently allowed for
> > > immutable files but RDMA store would be effectively corrupting the data of
> > > the target inode. But we could treat it similarly as swapfiles - those also
> > > have to deal with writes to blocks beyond filesystem control. In fact the
> > > similarity seems to be quite large there. What do you think?
> >
> > This sounds so familiar...
> >
> >     https://lwn.net/Articles/726481/
> >
> > I'm not opposed to trying again, but leases was what crawled out
> > smoking crater when this last proposal was nuked.
>
> Umm, don't think this is that similar to daxctl() discussion. We are not
> speaking about providing any new userspace API for this.

I thought explicit userspace API was one of the outcomes, i.e. that we
can't depend on this behavior being an implicit side effect of a page
pin?

> Also I think the
> situation about leases has somewhat cleared up with this discussion - ODP
> hardware does not need leases since it can use MMU notifiers, for non-ODP
> hardware it is difficult to handle leases as such hardware has only one big
> kill-everything call and using that would effectively mean lot of work on
> the userspace side to resetup everything to make things useful if workable
> at all.
>
> So my proposal would be:
>
> 1) ODP hardward uses gup_fast() like direct IO and uses MMU notifiers to do
> its teardown when fs needs it.
>
> 2) Hardware not capable of tearing down pins from MMU notifiers will have
> to use gup_longterm() (we may actually rename it to a more suitable name).
> FS may just refuse such calls (for normal page cache backed file, it will
> just return success but for DAX file it will do sanity checks whether the
> file is fully allocated etc. like we currently do for swapfiles) but if
> gup_longterm() returns success, it will provide the same guarantees as for
> swapfiles. So the only thing that we need is some call from gup_longterm()
> to a filesystem callback to tell it - this file is going to be used by a
> third party as an IO buffer, don't touch it. And we can (and should)
> probably refactor the handling to be shared between swapfiles and
> gup_longterm().

Yes, lets pursue this. At the risk of "arguing past 'yes'" this is a
solution I thought we dax folks walked away from in the original
MAP_DIRECT discussion [1]. Here is where leases were the response to
MAP_DIRECT [2]. ...and here is where we had tame discussions about
implications of notifying memory-registrations of lease break events
[3].

I honestly don't like the idea that random subsystems can pin down
file blocks as a side effect of gup on the result of mmap. Recall that
it's not just RDMA that wants this guarantee. It seems safer to have
the file be in an explicit block-allocation-immutable-mode so that the
fallocate man page can describe this error case. Otherwise how would
you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?

[1]: https://lwn.net/Articles/736333/
[2]: https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg06437.html
[3]: https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg06499.html

