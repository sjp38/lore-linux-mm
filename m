Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D95AC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 03:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4034921537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 03:43:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4034921537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADB386B0005; Thu, 13 Jun 2019 23:43:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8BB16B0006; Thu, 13 Jun 2019 23:43:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97C726B0008; Thu, 13 Jun 2019 23:43:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED8A6B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:43:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so885216pgs.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:43:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u0sRXKKM5V93Crh1idO/XME53W3u7CN9zMbbJ5JbvUA=;
        b=IDCSQ5sN8Bow/QdLfgaNpNHIwzYZucC1Nlutqihkv98kd/slZXVqATcsnP3p8NEPe7
         cOFW8HBYZQY/rIGxpF6P91WLHkLpd8mMMPq2SARjW9cN4mh7tF/vKA4390iRpgDGhfPZ
         rmp8LxRY6w1yPsarLZ8sF99HtjBj6evOqAayuvF0hCSCxiOzR1TqeHtcUyhYZkliNIBY
         NKQ1PG5ziR6mTPNmrmq8WtdKqVLkmoL/pa+3w/wKKQslQIJpRHRHHGo0pcmK018B7MRT
         39j9jfKBnqzQOhzNjSNtWD+OkGNQAxrLIwvFw11zJbfyUAVdVlJsnC+pnD2djXay8T5B
         rQ4A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWS9mNO/+WJAvUQIVfXzl8qu6goCdldk+S8TcRPfhHPgsb+tcnf
	p0imJ8Rfe2GTBU7iDXtJOy5cp77Ha0UYkoTmDf8QFyzh4R6nEOFg+3z4RrP4UoY1V0r4ii0ZyGP
	m6GXlZtdvYxOKLi8WyhOEhk//saBFvladisxYBWNwgMBnMbrACWAuSXDdGw6k4Sk=
X-Received: by 2002:a63:b1d:: with SMTP id 29mr33717700pgl.103.1560483812945;
        Thu, 13 Jun 2019 20:43:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7HdWhrjc095LMVDdxIrwfF0FD5x8qPq/Peonu6CNCXQ/CQDH6MLcg7vEkoEBZNM84rU/o
X-Received: by 2002:a63:b1d:: with SMTP id 29mr33717661pgl.103.1560483811860;
        Thu, 13 Jun 2019 20:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560483811; cv=none;
        d=google.com; s=arc-20160816;
        b=zCTFdm3c8zlhBRcFURJiSgRxa2hnpDFGVxw2pthaVn4AGvzoA7m99Q5/c5C8VlAoNl
         04JWdOu/I7yxdPCJ7gTOZKN/Yv9ASl4jsLGS9MmTfds3cCL2tUSOGACbWeC5XZgddP/L
         yd5CeEtENrHr+1xWMb13J1DSjXG/JY+BRp9xs6ziCO76C043AkOQdIVov5kyfvUG8rQ/
         +4PS8vGKAXPuiwS7riTMfaVBrId6WVPnFGTjHkUicnoYmgai5HCskeSrklmA71W/Dl9P
         OyxByxKBzFIhBXUXnvkJ4cyJceWpHr8SOa8B03Az6llJxMYXxGlX5HhYBq8I7Yn0yPNy
         X+VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u0sRXKKM5V93Crh1idO/XME53W3u7CN9zMbbJ5JbvUA=;
        b=gLJk3Mdc8D3eRMP/aklser7ZxJfhb2WGka30R3d1siSc5wuhIglIfV4O/az7adHwNv
         dVapTy1jMVmsYJMyaGRNcw0g5ghwUw3RcOgfBhpYQ05kiQ+omSkgBGY01gcoyF1bCUDL
         fvltovjOsYzqIA4VnV2dWZdOvv2ImAXiXXEfLEj7h839GgbOyK5+rIbAwaDxKbpXuu8t
         4dgatyrwqza4KKextLcKWj9UHCl60xyIHdQFXnHS0+7t5vyVW6fL1YRo6IY0Wgcw6BR3
         3bcyUNe91WrVtJFdenuAlk+qX/Pq2BI+kvTk19hVVwGkeI+WCFaYcCM/oo4VV5EvQ3vM
         eHuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id k16si1206034pfk.68.2019.06.13.20.43.31
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 20:43:31 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 505E11AD622;
	Fri, 14 Jun 2019 13:43:28 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbd6k-0005oM-Ah; Fri, 14 Jun 2019 13:42:30 +1000
Date: Fri, 14 Jun 2019 13:42:30 +1000
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
Message-ID: <20190614034230.GP14363@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190612233024.GD14336@iweiny-DESK2.sc.intel.com>
 <20190613005552.GI14363@dread.disaster.area>
 <20190613203406.GB32404@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613203406.GB32404@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=k35vKodN1J5BDQ_Sz-4A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 01:34:06PM -0700, Ira Weiny wrote:
> On Thu, Jun 13, 2019 at 10:55:52AM +1000, Dave Chinner wrote:
> > On Wed, Jun 12, 2019 at 04:30:24PM -0700, Ira Weiny wrote:
> > > On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > > > On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > > > > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > > > > Are you suggesting that we have something like this from user space?
> > > > > > 
> > > > > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > > > > 
> > > > > Rather than "unbreakable", perhaps a clearer description of the
> > > > > policy it entails is "exclusive"?
> > > > > 
> > > > > i.e. what we are talking about here is an exclusive lease that
> > > > > prevents other processes from changing the layout. i.e. the
> > > > > mechanism used to guarantee a lease is exclusive is that the layout
> > > > > becomes "unbreakable" at the filesystem level, but the policy we are
> > > > > actually presenting to uses is "exclusive access"...
> > > > 
> > > > That's rather different from the normal meaning of 'exclusive' in the
> > > > context of locks, which is "only one user can have access to this at
> > > > a time".  As I understand it, this is rather more like a 'shared' or
> > > > 'read' lock.  The filesystem would be the one which wants an exclusive
> > > > lock, so it can modify the mapping of logical to physical blocks.
> > > > 
> > > > The complication being that by default the filesystem has an exclusive
> > > > lock on the mapping, and what we're trying to add is the ability for
> > > > readers to ask the filesystem to give up its exclusive lock.
> > > 
> > > This is an interesting view...
> > > 
> > > And after some more thought, exclusive does not seem like a good name for this
> > > because technically F_WRLCK _is_ an exclusive lease...
> > > 
> > > In addition, the user does not need to take the "exclusive" write lease to be
> > > notified of (broken by) an unexpected truncate.  A "read" lease is broken by
> > > truncate.  (And "write" leases really don't do anything different WRT the
> > > interaction of the FS and the user app.  Write leases control "exclusive"
> > > access between other file descriptors.)
> > 
> > I've been assuming that there is only one type of layout lease -
> > there is no use case I've heard of for read/write layout leases, and
> > like you say there is zero difference in behaviour at the filesystem
> > level - they all have to be broken to allow a non-lease truncate to
> > proceed.
> > 
> > IMO, taking a "read lease" to be able to modify and write to the
> > underlying mapping of a file makes absolutely no sense at all.
> > IOWs, we're talking exaclty about a revokable layout lease vs an
> > exclusive layout lease here, and so read/write really doesn't match
> > the policy or semantics we are trying to provide.
> 
> I humbly disagree, at least depending on how you look at it...  :-D
> 
> The patches as they stand expect the user to take a "read" layout lease which
> indicates they are currently using "reading" the layout as is.
> They are not
> changing ("writing" to) the layout.

As I said in a another email in the thread, a layout lease does not
make the layout "read only". It just means the lease owner will be
notified when someone else is about to modify it. The lease owner
can modify the mapping themselves, and they will not get notified
about their own modifications.

> They then pin pages which locks parts of
> the layout and therefore they expect no "writers" to change the layout.

Except they can change the layout themselves. It's perfectly valid
to get a layout lease, write() from offset 0 to EOF and fsync() to
intiialise the file and allocate all the space in the file, then
mmap() it and hand to off to RMDA, all while holding the layout
lease.

> The "write" layout lease breaks the "read" layout lease indicating that the
> layout is being written to.

Layout leases do not work this way.

> In fact, this is what NFS does right now.  The lease it puts on the file is of
> "read" type.
> 
> nfs4layouts.c:
> static int
> nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
> {
> ...
>         fl->fl_flags = FL_LAYOUT;
>         fl->fl_type = F_RDLCK;
> ...
> }

Yes, the existing /implementation/ uses F_RDLCK, but that doesn't
mean the layout is "read only". Look at the pNFS mapping layout code
- the ->map_blocks export operation:

       int (*map_blocks)(struct inode *inode, loff_t offset,
                          u64 len, struct iomap *iomap,
                          bool write, u32 *device_generation);
                          ^^^^^^^^^^

Yup, it has a write variable that, when set, causes the filesystem
to _allocate_ blocks if the range to be written to falls over a hole
in the file.  IOWs, a pNFS layout lease can modify the file layout -
you're conflating use of a "read lock" API to mean that what the
lease _manages_ is "read only". That is not correct.

Layouts are /always writeable/ by the lease owner(s), the question
here is what we do with third parties attempting to modify a layout
covered by an "exclusive" layout lease. Hence, I'll repeat:

> > we're talking exaclty about a revokable layout lease vs an
> > exclusive layout lease here, and so read/write really doesn't match
> > the policy or semantics we are trying to provide.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

