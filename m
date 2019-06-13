Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90976C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:27:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD24208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:27:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD24208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A775B6B000C; Wed, 12 Jun 2019 20:27:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A003B6B000E; Wed, 12 Jun 2019 20:27:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A13F6B0010; Wed, 12 Jun 2019 20:27:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E05A6B000C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:27:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so6927086plo.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:27:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r5mJvWVP6h6qvl6TF1Vepeu4tD3hCnRA8MPlquid6p0=;
        b=fnTm6A2lJkgvW48SONK8QhiaO1JxoGaMmnw7Py5rRbHPpkYJLjuKlb8G01607fCVwo
         D6/ozF7c2duNJUK7ZVq7xDqY/3K55yY876VSihORFyN/SVKMAO7Vs5n4N78/33rcqA4g
         g7ihSVXVTVjALywlLVEf1Zwc0NhOChakXdiC5ELNqtTX77SCj7o5krayo0nGPNRZEBLI
         Dcdk3TzUId2eZrtezmEUfMjRAZ3J8/DkVBr87f9OIHMEs0+3DRY1PyeMd1R38mkttrgl
         r01lHqtE+JVcwISsFITBiK71vkPFgkmLSnk3ErgMTa0RVtj0l69IlP50gZ6Wpf6VMWjJ
         iSog==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVvTZNn/R9K0h4pZLPG+AJd9jM6HUz1F3RLgUoMOzIsTQGhLs7G
	LFQAK6pF5rF5rTfOc2T4mg0MaB7/6Y9cCPMmeAVw2PDwDNRHpYDovQHEFwjYojg2MeiRHYzh7Po
	3isCp+dV/z9/KtZ7RDQ6c8AJndiEDMq8LypQcUFbMElk1pZimz9AOgTI4zzB19Zc=
X-Received: by 2002:a17:90a:ab0c:: with SMTP id m12mr1880640pjq.87.1560385619895;
        Wed, 12 Jun 2019 17:26:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3R7l/fjURgXUECp6GdVeCZZ18B9fnOTO5TCCKtnIsXeCkTRfB6IRFsLVO1QUjQvoj8aqB
X-Received: by 2002:a17:90a:ab0c:: with SMTP id m12mr1880588pjq.87.1560385618924;
        Wed, 12 Jun 2019 17:26:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560385618; cv=none;
        d=google.com; s=arc-20160816;
        b=J4jYOA937BkzcLd6g0efJAbdbS45Pf3YqlK8elRZ8sQc+xLpf49HY41skcjIR4l0SB
         qwrnT7O0PsEQR5bgBNpQfKkHjJanOYLI88+SmGee7o3h8jVC5Yfkrz4VK+aFsuyUtswA
         P+QLoFAu4ST0b4cC3q0DQz2bw3XKakLP5t0mz8yOMqOlEXd6EMlZ9LcGMjbyJelg7LTc
         d9uZALNrbj7wy5mxIkef5LkckUlWsA0dj5F3z/TlKii0cd5ELfCpKcMKMHq9meS+M4Dz
         EsvLSV4W7rhbq4FgOHZ+TX1Q6Yy4aHuNeOXRbZ10ISfWvCMv8x8ERQSHHlfkEsBgeFZO
         CbDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r5mJvWVP6h6qvl6TF1Vepeu4tD3hCnRA8MPlquid6p0=;
        b=tBld94BD/tGbp6ewng7IHOoKj5Vl41o/xEZPAjWKJ+hT5ujYuSlt6OkX7I49y4sENS
         BA7WnBFv0eOJlR3ZhaxoF4+33ege/EG0Fmt8JCEKsX4fJw81oxk7B/H1y6u/Hh2wrjEb
         y7uvTPwcTtihhdHQMYAAGGyNLBI88a20zvHrNEhoGPYJN32uAtDK/ed6FgIur/IaJabH
         mscDrjuJZxpedCFL5EMHa8xrLp3fF9NjXt1zfbqulB1CbyaHO0vfIHd7P43F+kMFk0O7
         JYwPbrDWexxKJ7zy1vOWefcuQPZfMUHsHq6YJOz2bnaW66kWSV4MHfxXpv7krbVY0HgF
         cU1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id m7si947823pls.392.2019.06.12.17.26.58
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 17:26:58 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id D76D33DB9FA;
	Thu, 13 Jun 2019 10:26:52 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbDYx-00046z-Ci; Thu, 13 Jun 2019 10:25:55 +1000
Date: Thu, 13 Jun 2019 10:25:55 +1000
From: Dave Chinner <david@fromorbit.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
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
Message-ID: <20190613002555.GH14363@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612123751.GD32656@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=0tDtZe7MyfZ8QGwI5qwA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > Are you suggesting that we have something like this from user space?
> > > 
> > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > 
> > Rather than "unbreakable", perhaps a clearer description of the
> > policy it entails is "exclusive"?
> > 
> > i.e. what we are talking about here is an exclusive lease that
> > prevents other processes from changing the layout. i.e. the
> > mechanism used to guarantee a lease is exclusive is that the layout
> > becomes "unbreakable" at the filesystem level, but the policy we are
> > actually presenting to uses is "exclusive access"...
> 
> That's rather different from the normal meaning of 'exclusive' in the
> context of locks, which is "only one user can have access to this at
> a time".


Layout leases are not locks, they are a user access policy object.
It is the process/fd which holds the lease and it's the process/fd
that is granted exclusive access.  This is exactly the same semantic
as O_EXCL provides for granting exclusive access to a block device
via open(), yes?

> As I understand it, this is rather more like a 'shared' or
> 'read' lock.  The filesystem would be the one which wants an exclusive
> lock, so it can modify the mapping of logical to physical blocks.

ISTM that you're conflating internal filesystem implementation with
application visible semantics. Yes, the filesystem uses internal
locks to serialise the modification of the things the lease manages
access too, but that has nothing to do with the access policy the
lease provides to users.

e.g. Process A has an exclusive layout lease on file F. It does an
IO to file F. The filesystem IO path checks that Process A owns the
lease on the file and so skips straight through layout breaking
because it owns the lease and is allowed to modify the layout. It
then takes the inode metadata locks to allocate new space and write
new data.

Process B now tries to write to file F. The FS checks whether
Process B owns a layout lease on file F. It doesn't, so then it
tries to break the layout lease so the IO can proceed. The layout
breaking code sees that process A has an exclusive layout lease
granted, and so returns -ETXTBSY to process B - it is not allowed to
break the lease and so the IO fails with -ETXTBSY.

i.e. the exclusive layout lease prevents other processes from
performing operations that may need to modify the layout from
performing those operations. It does not "lock" the file/inode in
any way, it just changes how the layout lease breaking behaves.

Further, the "exclusiveness" of a layout lease is completely
irrelevant to the filesystem that is indicating that an operation
that may need to modify the layout is about to be performed. All the
filesystem has to do is handle failures to break the lease
appropriately.  Yes, XFS serialises the layout lease validation
against other IO to the same file via it's IO locks, but that's an
internal data IO coherency requirement, not anything to do with
layout lease management.

Note that I talk about /writes/ here. This is interchangable with
any other operation that may need to modify the extent layout of the
file, be it truncate, fallocate, etc: the attempt to break the
layout lease by a non-owner should fail if the lease is "exclusive"
to the owner.

> The complication being that by default the filesystem has an exclusive
> lock on the mapping, and what we're trying to add is the ability for
> readers to ask the filesystem to give up its exclusive lock.

The filesystem doesn't even lock the "mapping" until after the
layout lease has been validated or broken.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

