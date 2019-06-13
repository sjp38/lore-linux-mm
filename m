Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCF42C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:56:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BB9E20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:56:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BB9E20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C4056B000C; Wed, 12 Jun 2019 20:56:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074B86B000E; Wed, 12 Jun 2019 20:56:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA65B6B0010; Wed, 12 Jun 2019 20:56:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B47B96B000C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:56:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f10so7234511plr.17
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:56:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JDoTL1IYuRoUan1/1pYvFXcVihRu7UUoyfWiM2y3aC0=;
        b=eXqdMsDnGX9U+C0tKSWvZq48prDBu94/AUBMis5XQVy8fXaK1aZjJ+Wyq1gxT0g4wj
         9bMSuAWZ+nshGtWCdGPReCcI/szC0GenHTaknUJO3wRDPgK9xHiCq1nGhjvse6+rHePd
         9xwEWHLtzJnMBwD0QumESEb/xwfyoccFUtuT0u416/W8pdNqogqXcEY2MyGeTDyAm9OV
         v+gX1KRepuN7DW8+IACoMFDCtnwa/gabmvop1aAY5aF221ser/hOpQIr79IXWeaX8CoE
         4cqngKvTwSkZD6p3N6eM3Mqsoma//+M9s1L1cMFpg6U0lTzSuYBMC3SvmhA6wGarMcxe
         LoAg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVAudZzb2APEFlNhDX3Z4W3Ac2HVuFwdRyGNBi0sDSuJfXN8cLd
	ERBUuvTzcS48bbyg8eK3+KzXvPDi6kTFqP/+rg4TtyqB4xEGTJ9s43WL+HxEWBc/SLQTLq8lH0Y
	yJnE5KcyscWVKITdcJilc6f98f5Cba9kRwqD9UXf7vNYRDl531B5Xu3rpJ9wpkhM=
X-Received: by 2002:a62:1ac8:: with SMTP id a191mr27970534pfa.164.1560387414395;
        Wed, 12 Jun 2019 17:56:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy/Ndwwz8TwwhFKETCxo3KDAADM5iyVtq1SkWzyk9peFiHPtRUHR53fLYvQtCojHo5v0d7
X-Received: by 2002:a62:1ac8:: with SMTP id a191mr27970481pfa.164.1560387413333;
        Wed, 12 Jun 2019 17:56:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560387413; cv=none;
        d=google.com; s=arc-20160816;
        b=ovSAMPWfKoYEHFOK7AMoVxFig2kIDIMR4q+nRIVsc2/m+NRBvpKLd77Tjkf/zITkct
         kwNe326QIpwUCUZQQfb2IU5Q4RbqK0FBy3kfKGCzvenemDNTU6OSelQDYqeFllRrl0ei
         iMjKDYDN3OVbzOBIaSZ7IYmwJ4FbrWee4HUUd6Dv6OHM4UpHXz9mLelxmbSUjTnk9afM
         k1FPZJ/bYSk1GGaKBKOE4Xt8NM4l41pZs5HHsDGuOUAi6VbOuVAExMmAQfwxY1azDDjE
         oZT1IHWPw0y/YW+pmLKZ69P9viGlyze2ylfEQpXz+psLInEyBtU5bIrcMJNQMkOYCNaA
         h/uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JDoTL1IYuRoUan1/1pYvFXcVihRu7UUoyfWiM2y3aC0=;
        b=o8HNHf8VqjGWTDlrElOrlhurq/Q+l1qcD8YeczEw1NOGrspYQ/opezAI7mLohGG5xU
         lSlLRgjEGTpYsMPSORjnkKbjP+b+sqq4JEPeFhxB0WpsvI0WDp2E97cVMrJyPilV+Eto
         JqQUcbDONCQ5kc91twzBqAKOFM/ENghtonyoE9gfsNfuzPEB379tpSeUnUCdcbYld0bR
         w0PRc2VaSIZi3XlcXiSoJordjewm3hB7gADi5QKalNiEiTb1ZG0Zl6i4OZzd4Dkq8x7p
         O8ZUyw7D5sJe7CcHQUs5O31Iao3iQVws4LyHNVov1IS6TbbYnC1kEbAnBTqJhFWXQ0LF
         4BqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id 37si1099650pld.231.2019.06.12.17.56.52
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 17:56:53 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 3CE4F105FED4;
	Thu, 13 Jun 2019 10:56:50 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbE1w-0004JV-Dn; Thu, 13 Jun 2019 10:55:52 +1000
Date: Thu, 13 Jun 2019 10:55:52 +1000
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613005552.GI14363@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190612233024.GD14336@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612233024.GD14336@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=S7HuRrsnkTe4mrBiyeoA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 04:30:24PM -0700, Ira Weiny wrote:
> On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > > Are you suggesting that we have something like this from user space?
> > > > 
> > > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > > 
> > > Rather than "unbreakable", perhaps a clearer description of the
> > > policy it entails is "exclusive"?
> > > 
> > > i.e. what we are talking about here is an exclusive lease that
> > > prevents other processes from changing the layout. i.e. the
> > > mechanism used to guarantee a lease is exclusive is that the layout
> > > becomes "unbreakable" at the filesystem level, but the policy we are
> > > actually presenting to uses is "exclusive access"...
> > 
> > That's rather different from the normal meaning of 'exclusive' in the
> > context of locks, which is "only one user can have access to this at
> > a time".  As I understand it, this is rather more like a 'shared' or
> > 'read' lock.  The filesystem would be the one which wants an exclusive
> > lock, so it can modify the mapping of logical to physical blocks.
> > 
> > The complication being that by default the filesystem has an exclusive
> > lock on the mapping, and what we're trying to add is the ability for
> > readers to ask the filesystem to give up its exclusive lock.
> 
> This is an interesting view...
> 
> And after some more thought, exclusive does not seem like a good name for this
> because technically F_WRLCK _is_ an exclusive lease...
> 
> In addition, the user does not need to take the "exclusive" write lease to be
> notified of (broken by) an unexpected truncate.  A "read" lease is broken by
> truncate.  (And "write" leases really don't do anything different WRT the
> interaction of the FS and the user app.  Write leases control "exclusive"
> access between other file descriptors.)

I've been assuming that there is only one type of layout lease -
there is no use case I've heard of for read/write layout leases, and
like you say there is zero difference in behaviour at the filesystem
level - they all have to be broken to allow a non-lease truncate to
proceed.

IMO, taking a "read lease" to be able to modify and write to the
underlying mapping of a file makes absolutely no sense at all.
IOWs, we're talking exaclty about a revokable layout lease vs an
exclusive layout lease here, and so read/write really doesn't match
the policy or semantics we are trying to provide.

> Another thing to consider is that this patch set _allows_ a truncate/hole punch
> to proceed _if_ the pages being affected are not actually pinned.  So the
> unbreakable/exclusive nature of the lease is not absolute.

If you're talking about the process that owns the layout lease
running the truncate, then that is fine.

However, if you are talking about a process that does not own the
layout lease being allowed to truncate a file without first breaking
the layout lease, then that is fundamentally broken.

i.e. If you don't own a layout lease, the layout leases must be
broken before the truncate can proceed. If it's an exclusive lease,
then you cannot break the lease and the truncate *must fail before
it is started*. i.e.  the layout lease state must be correctly
resolved before we start an operation that may modify a file layout.

Determining if we can actually do the truncate based on page state
occurs /after/ the lease says the truncate can proceed....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

