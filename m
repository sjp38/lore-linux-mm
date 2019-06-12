Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB353C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:32:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6587220B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:32:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6587220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D586B0008; Wed, 12 Jun 2019 19:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBE5D6B000E; Wed, 12 Jun 2019 19:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE016B0010; Wed, 12 Jun 2019 19:32:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2BE06B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 19:32:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c3so10705262plr.16
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:32:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0x3EZ2qz400B7bsnKl9xr8zap7UvajgnitBR8/hs1jc=;
        b=VHS49avMq7VA2YdVsZCIXClwWc1gJQoSiZhZS2L8f5g01JbgQ2IR+oz0SUzNZsiaze
         WpQnyPk5XQsQZAuu2N+/fUh6tkcoI39D+hZ57gI4DZQy6/rUJgmQROePijhzlA00Pj5y
         HJ//P+6bRZfa3HPp+/d7X6P4DXszdelnlHGmk1VBK2o21memdkCvAR+zv3sjzG97/3Sa
         VC7QEywM/pVQLk82j/isI0CEVTQfaICC2AEsX0USX2bvSIV5JlKAbQ991lMhv9JyWNHV
         riPR6avsfiTHi45Xdi57z4D6hyOaE3tnuewVykazrwbxCNPVekv8I3z9phmSfNS8hfyK
         zCbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXdKezrIi+zupQ2yfgy8Tbdjoy/nFRa/r/H9mH0Ugpk7nTeDVPy
	Y4uP1raSAOrH5heJ+jZZJQ61W0trHvijOv6vpCpzrRvH4wxtBZDMajhv4QHXGqxu3jnW1/+k2I5
	eOjvKRc3vev3GvPxTjU1s1uqYEMgl4PaqhphUxqeFQSLqIdh6YM/P/S8Py14DAZyr1Q==
X-Received: by 2002:aa7:90ce:: with SMTP id k14mr89592149pfk.239.1560382326292;
        Wed, 12 Jun 2019 16:32:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWXUe2l1XmTGj1qPELs90CMR4dBhA0EF29JQ+kIj3qCc3zCwa+MxSrrXGUqTT8yRdrIkZI
X-Received: by 2002:aa7:90ce:: with SMTP id k14mr89592088pfk.239.1560382325545;
        Wed, 12 Jun 2019 16:32:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560382325; cv=none;
        d=google.com; s=arc-20160816;
        b=DTzpfdzs4aEC78hIntDqQARNrtza+SFp0vR9xm+Ll/8pFq5+hhxykqO6JCdQfZ9ajC
         5WpsKZ5mM/wdTYTVAjkUySZkCFfIMZM9fQv8X4OQgoEMahFPCcQXD1qjY9lhVukpvU3Y
         lH5tsZdjtdJHyVY4qEf8Q56D6oj2HJK7W3lEKZ4l0xZPAe2XVVbIs5fFuBY1KOzvi8eq
         SCsMLvI15+U7N74W7yyvn6LmSGC2MpssyuuVjPsesAY8S3TaINLippVMYwhTRz//dr/F
         hyWtLmeLc1Tcds0G9gmNEILInWibEqGmQwnro1NoJ5uMNAJbiWQismS5XVa/BdfqWnkY
         1IHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0x3EZ2qz400B7bsnKl9xr8zap7UvajgnitBR8/hs1jc=;
        b=ueUIorU0TwXxWd0Jb4H60ti/NyJOJMpDYLfYhC8oTvI3FJAm5ZtZ/gHhDBn9MJlewu
         to7XWM9dMyyRhhndkIEqqf8lGV071sNKnIanGMqWVvetC+IdK9ZjLwjer1g466J3CFZN
         xvOaB/yQNJPVMz3+Ukp8Ef2Yl5JMspN44sT5X4/Tfy5ypaGYsIN5cTdNPJWNXVTQiPuq
         19li3mbkiDQ4/39Hdt0yI6sl0NvlXEgK6OEJd58JrVbYZaqRbvvEl5XRcpTYqrT8inKw
         C+ZdtI+n0HGf7IMMxvQUnpVBcfoSNheHwjsJKwUNylMTkzlVj1yl0U35zp4japXIFldO
         q9rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id cx20si1016344pjb.97.2019.06.12.16.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 16:32:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 16:32:04 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 12 Jun 2019 16:32:04 -0700
Date: Wed, 12 Jun 2019 16:33:25 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190612233324.GE14336@iweiny-DESK2.sc.intel.com>
References: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 03:54:19PM -0700, Dan Williams wrote:
> On Wed, Jun 12, 2019 at 3:12 PM Ira Weiny <ira.weiny@intel.com> wrote:
> >
> > On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> > > On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > > > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > > >
> > > > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > > > little HW can actually implement it, having the alternative still
> > > > > > > > require HW support doesn't seem like progress.
> > > > > > > >
> > > > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > > > on fire, I need to unplug it).
> > > > > > >
> > > > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > > > with such an "invalidate".
> > > > > >
> > > > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > > > everything that's going on... And I wanted similar behavior here.
> > > > >
> > > > > It aborts *everything* connected to that file descriptor. Destroying
> > > > > everything avoids creating inconsistencies that destroying a subset
> > > > > would create.
> > > > >
> > > > > What has been talked about for lease break is not destroying anything
> > > > > but very selectively saying that one memory region linked to the GUP
> > > > > is no longer functional.
> > > >
> > > > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > > > and closes the file with existing pins (and thus layout lease) we would
> > > > force it to abort everything. Yes, it is disruptive but then the app didn't
> > > > obey the rule that it has to maintain file lease while holding pins. Thus
> > > > such situation should never happen unless the app is malicious / buggy.
> > >
> > > We do have the infrastructure to completely revoke the entire
> > > *content* of a FD (this is called device disassociate). It is
> > > basically close without the app doing close. But again it only works
> > > with some drivers. However, this is more likely something a driver
> > > could support without a HW change though.
> > >
> > > It is quite destructive as it forcibly kills everything RDMA related
> > > the process(es) are doing, but it is less violent than SIGKILL, and
> > > there is perhaps a way for the app to recover from this, if it is
> > > coded for it.
> >
> > I don't think many are...  I think most would effectively be "killed" if this
> > happened to them.
> >
> > >
> > > My preference would be to avoid this scenario, but if it is really
> > > necessary, we could probably build it with some work.
> > >
> > > The only case we use it today is forced HW hot unplug, so it is rarely
> > > used and only for an 'emergency' like use case.
> >
> > I'd really like to avoid this as well.  I think it will be very confusing for
> > RDMA apps to have their context suddenly be invalid.  I think if we have a way
> > for admins to ID who is pinning a file the admin can take more appropriate
> > action on those processes.   Up to and including killing the process.
> 
> Can RDMA context invalidation, "device disassociate", be inflicted on
> a process from the outside? Identifying the pid of a pin holder only
> leaves SIGKILL of the entire process as the remediation for revoking a
> pin, and I assume admins would use the finer grained invalidation
> where it was available.

No not in the way you are describing it.  As Jason said you can hotplug the
device which is "from the outside" but this would affect all users of that
device.

Effectively, we would need a way for an admin to close a specific file
descriptor (or set of fds) which point to that file.  AFAIK there is no way to
do that at all, is there?

Ira

