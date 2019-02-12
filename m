Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32A4FC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:07:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE6DC2184E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:07:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE6DC2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A63A8E0002; Tue, 12 Feb 2019 11:07:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72D7D8E0001; Tue, 12 Feb 2019 11:07:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F4DD8E0002; Tue, 12 Feb 2019 11:07:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0476F8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:07:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so2621154ede.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:07:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cYs2Iy+5oBQO0KHCyPNPCuLr90m+ATG07s+OZ6DzZGY=;
        b=VkkBqEBZanF0cpX7cZjaC1gPM5JN1MUek2dPiHC6NQJUOsE06YKHUU3E4Xowb1N8/O
         iUqz403mV9XbuaZ2BlaijcN3mvXoNM5ezoHawa2LZv4lA0aGkrHTqFOG+AQm9pXnf+M5
         C3No/I1NisD4S7NX6nG7jSLMHO2wihqfIjogLlj1CXQjwV4866TsgVAA9E8ggF9+FXuQ
         7ACL7WXszaJwb9ah25n1tbEOv2t8eiYSCS+S3rghRvh4Foe6+auJtvPke55YT5+NVzT4
         w4AWXUxUJHeWHKxVYsSksHDavn3EdQV3W1qr9B5UFxDbMWlQAhD8fXYEA1wK0hitjh5T
         SUZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYKYL/nzHNWCiYQvcvTjZQwdviO/O7A4dIzpp/gqrqFfAa3+7gH
	uDBdq1ntZhBVM4IpW1E3Ew4AJq1IOExag3qrW8JbX3LT+Oj02izMUImb3vfj/iItwZY2fe0EiJd
	hNIBmEdnIKcKBPYlVXyaQbJXJRibKh5BRe/I2ouwng7FZXJeD+8mA5TGABBqYQFQMag==
X-Received: by 2002:a50:84a9:: with SMTP id 38mr3670279edq.185.1549987634409;
        Tue, 12 Feb 2019 08:07:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbuK059jZbpkvKJQHaqWktNiPYS6AhDSR26WHjibW3Xn3I0QDriQr3gfLk6+1Q//Qmb1QQ0
X-Received: by 2002:a50:84a9:: with SMTP id 38mr3670172edq.185.1549987632623;
        Tue, 12 Feb 2019 08:07:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549987632; cv=none;
        d=google.com; s=arc-20160816;
        b=PkEbSZZeWFZNVNgvbywPq2v5MH1qAcXt8LjEtypHIWfDbQWbUr0yAL82XXsiEKHLSN
         gY4qkBPWlJgrn7fCK2XFx5bkagjFAea9RjfxfGt//B0UeWHIws4MTa0wK8Ygq80k8hzl
         rGj9kKl6SENQ3RMp6kQmJ4qX3nQLVA7XvpulA/PndKathH7a8rDOC7frHlU1b9mh/1AS
         jFSM/5GoPg5ueqiQzApwmsVAllUfSIJF1qoPZMpgGUJBV2E9GyIDrhMPFPsWIu5eEzHi
         rWrp0qaGkse9UCSLpF7ml4DTTMghhUU5qhAgJE1cdy7i7BnNN1tJ1ZPrtFBCBVt2oVUW
         MyAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cYs2Iy+5oBQO0KHCyPNPCuLr90m+ATG07s+OZ6DzZGY=;
        b=LXlUWoq1vvW8Q1/hdnAOdNhbpwKWyAns5xjRXVfulUaaK3Bu/MqmR/ven8bhee+GtA
         q6fM8gA7QGOeajzRDYYCJJmk38w+hcY3Jq8Mvgt90WOZdYE95updER3seegb6S09GJV8
         iANP+Yt7yIDn5vIR0lX7zxzzGARCPIeJ0Zt4Rtpc1deHAWwCuNiNRB5tlcFIDRmTLqy6
         jU3c5ertbIl7AGsUBMwTbB6/n4EGeKPzaTW1mppauQRws4YS9+Snx3Z40SBQiSbhEjqW
         WgkrcRvuOJIxAdHWmNC/apepz2iX0kl8wm60rczaETY9Mtg3H12vLjjaiYya3NK/1FYn
         5ZTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si4823eds.420.2019.02.12.08.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:07:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B01DFB02F;
	Tue, 12 Feb 2019 16:07:11 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id AD5641E09C5; Tue, 12 Feb 2019 17:07:07 +0100 (CET)
Date: Tue, 12 Feb 2019 17:07:07 +0100
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190212160707.GA19076@quack2.suse.cz>
References: <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 09:22:58, Dan Williams wrote:
> On Mon, Feb 11, 2019 at 2:24 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Fri 08-02-19 12:50:37, Dan Williams wrote:
> > > On Fri, Feb 8, 2019 at 3:11 AM Jan Kara <jack@suse.cz> wrote:
> > > >
> > > > On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> > > > > On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > > > > > One approach that may be a clean way to solve this:
> > > > > > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> > > > > >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> > > > > >    on the longterm pinned range until the long term pin is removed.
> > > > >
> > > > > So, ummm, how do we do block allocation then, which is done on
> > > > > demand during writes?
> > > > >
> > > > > IOWs, this requires the application to set up the file in the
> > > > > correct state for the filesystem to lock it down so somebody else
> > > > > can write to it.  That means the file can't be sparse, it can't be
> > > > > preallocated (i.e. can't contain unwritten extents), it must have zeroes
> > > > > written to it's full size before being shared because otherwise it
> > > > > exposes stale data to the remote client (secure sites are going to
> > > > > love that!), they can't be extended, etc.
> > > > >
> > > > > IOWs, once the file is prepped and leased out for RDMA, it becomes
> > > > > an immutable for the purposes of local access.
> > > > >
> > > > > Which, essentially we can already do. Prep the file, map it
> > > > > read/write, mark it immutable, then pin it via the longterm gup
> > > > > interface which can do the necessary checks.
> > > >
> > > > Hum, and what will you do if the immutable file that is target for RDMA
> > > > will be a source of reflink? That seems to be currently allowed for
> > > > immutable files but RDMA store would be effectively corrupting the data of
> > > > the target inode. But we could treat it similarly as swapfiles - those also
> > > > have to deal with writes to blocks beyond filesystem control. In fact the
> > > > similarity seems to be quite large there. What do you think?
> > >
> > > This sounds so familiar...
> > >
> > >     https://lwn.net/Articles/726481/
> > >
> > > I'm not opposed to trying again, but leases was what crawled out
> > > smoking crater when this last proposal was nuked.
> >
> > Umm, don't think this is that similar to daxctl() discussion. We are not
> > speaking about providing any new userspace API for this.
> 
> I thought explicit userspace API was one of the outcomes, i.e. that we
> can't depend on this behavior being an implicit side effect of a page
> pin?

I was thinking an implicit sideeffect of gup_longterm() call. Similarly as
swapon(2) does not require the file to be marked in any special way. But
OTOH I agree that RDMA is a less controlled usage than swapon so it is
questionable. I'd still require something like CAP_LINUX_IMMUTABLE at least
for gup_longterm() calls that end up pinning the file.

Inspired by Christoph's idea you reference in [2], maybe gup_longterm()
will succeed only if there is FL_LAYOUT lease for the range being pinned
and we don't allow the lease to be released until there's a pinned page in
the range. And we make the file protected (i.e. treat it like swapfile) if
there's any such lease in it. But this is just a rough sketch and needs more
thinking.

> > Also I think the
> > situation about leases has somewhat cleared up with this discussion - ODP
> > hardware does not need leases since it can use MMU notifiers, for non-ODP
> > hardware it is difficult to handle leases as such hardware has only one big
> > kill-everything call and using that would effectively mean lot of work on
> > the userspace side to resetup everything to make things useful if workable
> > at all.
> >
> > So my proposal would be:
> >
> > 1) ODP hardward uses gup_fast() like direct IO and uses MMU notifiers to do
> > its teardown when fs needs it.
> >
> > 2) Hardware not capable of tearing down pins from MMU notifiers will have
> > to use gup_longterm() (we may actually rename it to a more suitable name).
> > FS may just refuse such calls (for normal page cache backed file, it will
> > just return success but for DAX file it will do sanity checks whether the
> > file is fully allocated etc. like we currently do for swapfiles) but if
> > gup_longterm() returns success, it will provide the same guarantees as for
> > swapfiles. So the only thing that we need is some call from gup_longterm()
> > to a filesystem callback to tell it - this file is going to be used by a
> > third party as an IO buffer, don't touch it. And we can (and should)
> > probably refactor the handling to be shared between swapfiles and
> > gup_longterm().
> 
> Yes, lets pursue this. At the risk of "arguing past 'yes'" this is a
> solution I thought we dax folks walked away from in the original
> MAP_DIRECT discussion [1]. Here is where leases were the response to
> MAP_DIRECT [2]. ...and here is where we had tame discussions about
> implications of notifying memory-registrations of lease break events
> [3].

Yeah, thanks for the references.

> I honestly don't like the idea that random subsystems can pin down
> file blocks as a side effect of gup on the result of mmap. Recall that
> it's not just RDMA that wants this guarantee. It seems safer to have
> the file be in an explicit block-allocation-immutable-mode so that the
> fallocate man page can describe this error case. Otherwise how would
> you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?

So with requiring lease for gup_longterm() to succeed (and the
FALLOC_FL_PUNCH_HOLE failure being keyed from the existence of such lease),
does it look more reasonable to you?

> [1]: https://lwn.net/Articles/736333/
> [2]: https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg06437.html
> [3]: https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg06499.html

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

