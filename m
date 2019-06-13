Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70EC5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27E832080A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:54:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JPkB0BV6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27E832080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A53B68E0002; Thu, 13 Jun 2019 12:54:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A06E78E0001; Thu, 13 Jun 2019 12:54:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F28E8E0002; Thu, 13 Jun 2019 12:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DFFD8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:54:10 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id z52so9522246otb.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:54:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=K5QgKSw4Z6Xg8aYYXT+LBjYPe44CbIinLwHH3dcmWHs=;
        b=joTlcu+8UK+//6XFpy/kF0K0MY5LoN6engbn20bl4Xn0TM9VkJM4JervdaP/ItjEdb
         fECXMh+vjULWDLNAANUvRhRTU6GLHawhCgkqSX0tMS0qKuVlpqlTDf7RsvahznESCEnA
         YIoNZW/ivrVvUWSh5a16C5HBSPX4dk2A4fAyFvABcVbsuGOsdULCpb/xAHpbwxUqnHMG
         cJSgciKBnFG5gjUjxDtxufMBCDVNP0OXh9wbpO9FZ5TCnNfHgV5OxwhhLYrgwmUACqK8
         CEJjz3fVVRd7REE20BJYIw+dJmEscnfvykF5b0xVgGaiUlzVeYPsXe5m9zHeasE60joP
         Zt/g==
X-Gm-Message-State: APjAAAWwhHr9OZmX7rHdOP1fauLBpVUWtoI05Jy4BxQzAExdb9fx1cT9
	86fMrVz+hbuuHAQVdBw5JT5S6iPa5GH6ioNmE2CM0OF355GdHN6Bp2vIRlnkPCdE1YpxcTA8Sxa
	VZhY1Y7379W1ovbnCy9hGGRoHLvQaf0+6dvzWnVJTk4+3vRwqpBlb700tEokimSn+9w==
X-Received: by 2002:a05:6830:1617:: with SMTP id g23mr15477010otr.117.1560444850058;
        Thu, 13 Jun 2019 09:54:10 -0700 (PDT)
X-Received: by 2002:a05:6830:1617:: with SMTP id g23mr15476963otr.117.1560444849179;
        Thu, 13 Jun 2019 09:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560444849; cv=none;
        d=google.com; s=arc-20160816;
        b=axKvxdsbwgtbrP6PBVprXx4sZqL3pyW4BfV6658w8ug/gMP7hLPpTDM4mGh2Uh5MH3
         L3Ws8hixZuP9UwMvl3I9x942OMz93DfN+g/QK4C1CeMAEDO+bLoqxZfTL8Y3ZebS6bxF
         2oXeBfjGrViyGldigGxWhtMZmjDR2KugqhhAvDYxV9MBGaoEBMvLAJQstPuhskb+FnMn
         uXHoI0by42szUtk5RDTLINkZ3tfS6Cv7U5lM0S9XgZjZhPCiNkfmPBiQ7VuXDm5On+6G
         uDH4UYG2gPPxX8jyOcY8KC7oRwLPHxBjEESziDeU3pcVX0Zyl3AYPk8yMpDFRwp8FHru
         r1OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=K5QgKSw4Z6Xg8aYYXT+LBjYPe44CbIinLwHH3dcmWHs=;
        b=ootcc2FR0RAU6ZAcA4SNOP0VMvDkyjjEbSfQId+5eSRm8RiwvYKXA/dx392la0A55U
         8wmY9I73glT5UOAh9AVgVxZeoD2DJCHxTCQPe2FQeE/BewY6l0pr9/W6ZyGS7/Ff1PIX
         S9EFipQMqXWuG+OwGl0mIsaHE9AKcM5fd5SM143W+RFSHMvj+7d8xehHMvzFBNo24o6O
         BqAmUmHPDcv53ytMYzjV2byD/Mdy3Wep4nGFLyEQ9dVkiXBSnzntVHgdhgy6qh+fLqcL
         sLfJ6zaTP4McZ+qAYEkWtDi8FQ/ELDCdN/KyEDdoaEzDOginXiMAbNBT45BR0JPZKzY2
         XENg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JPkB0BV6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b72sor97086oii.22.2019.06.13.09.54.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 09:54:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JPkB0BV6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=K5QgKSw4Z6Xg8aYYXT+LBjYPe44CbIinLwHH3dcmWHs=;
        b=JPkB0BV6X6JhIXM15mmuE6WMYycZpu9oR7r0I7K/LQCBr9DwAP6ai9HZjnhDeAYv4q
         TiZo9rDNmnnfaiz17BD3uxFdbeSL7Y/8LOiTSNry6at9hQCVwGCeToNG6Ex+J8u5/KQP
         rSeVmghdMiyUulN3yC6UXoG+jamCw6Iq9RQa6hVQWk/7tpob4VyGK5isoLBgPG5+8CMc
         oA3+NEhNWRx5DhX8fFS+ibJYngtPEXnpdgd2MSVqUjHZLmRvj+vJ+ceFOp5MLrQ4oEX/
         0Rx8uu+6IN2lNuQ5sNTppCrMvyeKhRIg9ncvGbzO5FXYhJ6K3FlfiHQBnhAn2M8BLSYe
         /S4A==
X-Google-Smtp-Source: APXvYqw1WkLu6931wraGkR43kxA852RaajLizs6v5Jy3HNf2qRKdqa2zWoPAYJUPvBUNSayLXHYwfeMfsWWcQaOonts=
X-Received: by 2002:aca:4208:: with SMTP id p8mr3752304oia.105.1560444848738;
 Thu, 13 Jun 2019 09:54:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz> <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com> <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca> <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca> <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com> <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 09:53:57 -0700
Message-ID: <CAPcyv4hKw7owf+Jpxiu+V7DE+U4GkQ1Hr3korZvgSve-LPexNA@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jeff Layton <jlayton@kernel.org>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-ext4 <linux-ext4@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 4:32 PM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Wed, Jun 12, 2019 at 03:54:19PM -0700, Dan Williams wrote:
> > On Wed, Jun 12, 2019 at 3:12 PM Ira Weiny <ira.weiny@intel.com> wrote:
> > >
> > > On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> > > > On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > > > > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > > > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > > > >
> > > > > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > > > > little HW can actually implement it, having the alternative still
> > > > > > > > > require HW support doesn't seem like progress.
> > > > > > > > >
> > > > > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > > > > on fire, I need to unplug it).
> > > > > > > >
> > > > > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > > > > with such an "invalidate".
> > > > > > >
> > > > > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > > > > everything that's going on... And I wanted similar behavior here.
> > > > > >
> > > > > > It aborts *everything* connected to that file descriptor. Destroying
> > > > > > everything avoids creating inconsistencies that destroying a subset
> > > > > > would create.
> > > > > >
> > > > > > What has been talked about for lease break is not destroying anything
> > > > > > but very selectively saying that one memory region linked to the GUP
> > > > > > is no longer functional.
> > > > >
> > > > > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > > > > and closes the file with existing pins (and thus layout lease) we would
> > > > > force it to abort everything. Yes, it is disruptive but then the app didn't
> > > > > obey the rule that it has to maintain file lease while holding pins. Thus
> > > > > such situation should never happen unless the app is malicious / buggy.
> > > >
> > > > We do have the infrastructure to completely revoke the entire
> > > > *content* of a FD (this is called device disassociate). It is
> > > > basically close without the app doing close. But again it only works
> > > > with some drivers. However, this is more likely something a driver
> > > > could support without a HW change though.
> > > >
> > > > It is quite destructive as it forcibly kills everything RDMA related
> > > > the process(es) are doing, but it is less violent than SIGKILL, and
> > > > there is perhaps a way for the app to recover from this, if it is
> > > > coded for it.
> > >
> > > I don't think many are...  I think most would effectively be "killed" if this
> > > happened to them.
> > >
> > > >
> > > > My preference would be to avoid this scenario, but if it is really
> > > > necessary, we could probably build it with some work.
> > > >
> > > > The only case we use it today is forced HW hot unplug, so it is rarely
> > > > used and only for an 'emergency' like use case.
> > >
> > > I'd really like to avoid this as well.  I think it will be very confusing for
> > > RDMA apps to have their context suddenly be invalid.  I think if we have a way
> > > for admins to ID who is pinning a file the admin can take more appropriate
> > > action on those processes.   Up to and including killing the process.
> >
> > Can RDMA context invalidation, "device disassociate", be inflicted on
> > a process from the outside? Identifying the pid of a pin holder only
> > leaves SIGKILL of the entire process as the remediation for revoking a
> > pin, and I assume admins would use the finer grained invalidation
> > where it was available.
>
> No not in the way you are describing it.  As Jason said you can hotplug the
> device which is "from the outside" but this would affect all users of that
> device.
>
> Effectively, we would need a way for an admin to close a specific file
> descriptor (or set of fds) which point to that file.  AFAIK there is no way to
> do that at all, is there?

You can certainly give the lease holder the option to close the file
voluntarily via the siginfo_t that can be attached to a lease break
signal. But it's not really "close" you want as much as a finer
grained disassociate.

All that said you could require the lease taker opt-in to SIGKILL via
F_SETSIG before marking the lease "exclusive". That effectively
precludes failing truncate, but it's something we can enforce today
and work on finer grained / less drastic escalations over time for
something that should "never" happen.

