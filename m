Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D165EC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93BDA20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:59:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93BDA20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15FDB8E0003; Thu, 13 Jun 2019 22:59:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1119C8E0002; Thu, 13 Jun 2019 22:59:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 000638E0003; Thu, 13 Jun 2019 22:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE79B8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:59:55 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so751629pls.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:59:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wir2EN2E61L9Vav98pO1VVp25skKSAe1Sa/P5lqGq5c=;
        b=L++ZXPSyN4V0TtRDdULnI3Q/TrF2Dp8DxnfgKR96wSVJfjH6aY+4TYrJpGzfnwx5kH
         ATCElr+z/kRH43gn5RZQGC8XTKBOTKPn4q77f1E6gHg7SdPnYKcliVWATD+UVojIw8GO
         I+6qKN0EVcsIRHZc5WsWyF9JE256hRjR/PNnklhH8Tluw5//sB9GIn0dILZSE7eivx3j
         4WviQVt30DjyTgnODYG/G3Gxz1ZyKzgxkQVf7s1zCNUgBZWI02DwPdC5DwGPpLk7zpoh
         e6JSU8WGkM69NrmD1uH3CzFJRsoJTRz3AFM2IxkGueOwZ/xMCLeAghwb4pOdb0CTQMWy
         sjUA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUP3G/b+fDhhs1qMcCaUp40xpneYt3xgcQ4O9vKT+D6OKkXhuKK
	k+nZ6K9po3qmlCv04m8aXxrLTBxLtfTBue/XVfz1G/qvWGkyIW6D0vLBYPmMLOxpRxcqN5xGkRo
	wwaNCv8+tEbzATJFHwV7XEJjBknqbt5W9NPTap9h63tHpmohlYU/GKr/YLhgILUA=
X-Received: by 2002:a63:2848:: with SMTP id o69mr33534132pgo.258.1560481195225;
        Thu, 13 Jun 2019 19:59:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRGKzTRBzERwgPTOL6X0KZ0IeOqtkozs7lEuuqnFKZNHlISPKmyoabLrKt4g22jpph/o6J
X-Received: by 2002:a63:2848:: with SMTP id o69mr33534093pgo.258.1560481194088;
        Thu, 13 Jun 2019 19:59:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560481194; cv=none;
        d=google.com; s=arc-20160816;
        b=kn5jMHIOyNYBHLKdfegy62R7ZRMQbNEbPLMKyIpsdfwCE1jponEhyPQ+MkSo92Lx72
         cbu3Vc14+vV9ub5NE5P8daSYpbFKT9eDlt5p38KcimEU9Scx+toyIltbeRLUKMtBsjIP
         6D35V2gDj48rf3AsEMN/1wiubIQcNRk9I71LQW7ubnNGwMBtaUn+NlcZVD3LzX+wLiDG
         sGpbcL6x+1vuypwQxVWE1qGi4ljxTw+woOKCgWYNdEoUXaKVDGH/U+h+ohhXNz6F13V+
         EXIZc06bV2P3lOr+w3cl0bEu04m9BXg5vcrWPYG/rtzAZ2UfYKkwImazbo9YHD295PUa
         LnCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wir2EN2E61L9Vav98pO1VVp25skKSAe1Sa/P5lqGq5c=;
        b=iZG7RQRYw85E8hnaKadP0dJ7IfgcJ4eA9E/ceid9Gm8AmU7XxLC3GEI2wr0ahZ514R
         DDxfz/t8qYAiBzSx/fR7ugm2WQX8Wnq2eY+uenxKHDzVMWYCzCjyh/aVpcHO80L/YqSW
         RJefKDQ1mKsf+nrw1mPDIy2+OyRfHQNwrbNDlzO1HA7iB96wysWBi/k70FWkxOM6Y6xq
         mqfzNC/k+U7bO7a/fVjGgtpmQ29GK2xHd+6jZQX3RaxNMH+h9SJ/oxa8p5fEKHcxq3K6
         g3SvhZewcoVi1uy/GejPgO/jhacFJwhZ0F5BiGKrdz9OErcNg6Xp+F9g6HDVQmUWw0jE
         /G2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id c7si1049915plr.83.2019.06.13.19.59.53
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 19:59:54 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id E4ACC3DD5BC;
	Fri, 14 Jun 2019 12:59:50 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbcQW-0005bc-NF; Fri, 14 Jun 2019 12:58:52 +1000
Date: Fri, 14 Jun 2019 12:58:52 +1000
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
Message-ID: <20190614025852.GN14363@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613203404.GA30404@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613203404.GA30404@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=gnJ_ljic2OsQuunJrboA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 01:34:05PM -0700, Ira Weiny wrote:
> On Thu, Jun 13, 2019 at 10:25:55AM +1000, Dave Chinner wrote:
> > On Wed, Jun 12, 2019 at 05:37:53AM -0700, Matthew Wilcox wrote:
> > > On Sat, Jun 08, 2019 at 10:10:36AM +1000, Dave Chinner wrote:
> > > > On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> > > > > Are you suggesting that we have something like this from user space?
> > > > > 
> > > > > 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);
> > > > 
> > > > Rather than "unbreakable", perhaps a clearer description of the
> > > > policy it entails is "exclusive"?
> > > > 
> > > > i.e. what we are talking about here is an exclusive lease that
> > > > prevents other processes from changing the layout. i.e. the
> > > > mechanism used to guarantee a lease is exclusive is that the layout
> > > > becomes "unbreakable" at the filesystem level, but the policy we are
> > > > actually presenting to uses is "exclusive access"...
> > > 
> > > That's rather different from the normal meaning of 'exclusive' in the
> > > context of locks, which is "only one user can have access to this at
> > > a time".
> > 
> > 
> > Layout leases are not locks, they are a user access policy object.
> > It is the process/fd which holds the lease and it's the process/fd
> > that is granted exclusive access.  This is exactly the same semantic
> > as O_EXCL provides for granting exclusive access to a block device
> > via open(), yes?
> > 
> > > As I understand it, this is rather more like a 'shared' or
> > > 'read' lock.  The filesystem would be the one which wants an exclusive
> > > lock, so it can modify the mapping of logical to physical blocks.
> > 
> > ISTM that you're conflating internal filesystem implementation with
> > application visible semantics. Yes, the filesystem uses internal
> > locks to serialise the modification of the things the lease manages
> > access too, but that has nothing to do with the access policy the
> > lease provides to users.
> > 
> > e.g. Process A has an exclusive layout lease on file F. It does an
> > IO to file F. The filesystem IO path checks that Process A owns the
> > lease on the file and so skips straight through layout breaking
> > because it owns the lease and is allowed to modify the layout. It
> > then takes the inode metadata locks to allocate new space and write
> > new data.
> > 
> > Process B now tries to write to file F. The FS checks whether
> > Process B owns a layout lease on file F. It doesn't, so then it
> > tries to break the layout lease so the IO can proceed. The layout
> > breaking code sees that process A has an exclusive layout lease
> > granted, and so returns -ETXTBSY to process B - it is not allowed to
> > break the lease and so the IO fails with -ETXTBSY.
> > 
> > i.e. the exclusive layout lease prevents other processes from
> > performing operations that may need to modify the layout from
> > performing those operations. It does not "lock" the file/inode in
> > any way, it just changes how the layout lease breaking behaves.
> 
> Question: Do we expect Process A to get notified that Process B was attempting
> to change the layout?

In which case?

In the non-exclusive case, yes, the lease gets
recalled and the application needs to play nice and release it's
references and drop the lease.

In the exclusive case, no. The application has said "I don't play
nice with others" and so we basically tell process B to get stuffed
and process A can continue onwards oblivious to the wreckage it
leaves behind....

> This changes the exclusivity semantics.  While Process A has an exclusive lease
> it could release it if notified to allow process B temporary exclusivity.

And then it's not an exclusive lease - it's just a normal layout
lease. Process B -does not need a lease- to write to the file.

All the layout lease does is provide notification to applications
that rely on the layout of the file being under their control that
someone else is about to modify the layout. The lease holder that
"plays nice" then releases the layout and drops it's lease, allowing
process B to begin it's operation.

Process A then immediately takes a new layout lease, and remaps the
file layout via FIEMAP or by creating a new RDMA MR for the mmap
region. THose operations get serialised by the filesystem because
the operation being run by process B is run atomically w.r.t. the
original lease being broken. Hence the new mapping that process A
gets with it's new lease reflects whatever change was made by
process B.

IOWs, the "normal" layout lease recall behaviour provides "temporary
exclusivity" for third parties. If you are able to release leases
temporarily and regain them then there is no need for an exclusive
lease.

> Question 2: Do we expect other process' (say Process C) to also be able to map
> and pin the file?  I believe users will need this and for layout purposes it is
> ok to do so.  But this means that Process A does not have "exclusive" access to
> the lease.

This is an application architecture problem, not a layout lease or
filesystem problem. :)

i.e. if you have a single process controlling all the RDMA mappings,
then you can use exclusive leases. If you have multiple processes
that are uncoordinated and all require layout access to the same
file then you can't use exclusive layout leases in the application.
i.e. your application has to play nice with others.

Indeed, this is more than a application architecture problem - it's
actually a system wide architecture problem.  e.g. the pNFS server
cannot use exclusive layout leases because it has to play nice with
anything else on the local filesystem that might require a layout
lease. An example of this woudl be an app that provides coherent
RDMA access to the same storage that pNFS is sharing (e.g. a
userspace CIFS server).

Hence I see that exclusive layout leases will end up being the
exception rather than the norm, because most applications will need
to play nice with other applications on the system that also
directly access the storage under the filesystem....

> So given Process C has also placed a layout lease on the file.  Indicating
> that it does not want the layout to change.

That is *not what layout leases provide*.

Layout leases grant the owner the ability to map the layout and
directly access the underlying storage and to do it safely because
they will get a notification of 3rd party access that will
invalidate their mapping. Layout leases do not prevent anyone from
_changing_ the layout and, in fact, pNFS _requires_ the lease holder
to be able to modify the layout.

IOWs, the layout lease _as it stands now_ is a notification
mechanism that tells the lease owner when someone else is about to
modify the layout. It does not make the file layout immutable.

The "exclusive" aspect of layout we have been discussing is a
mechanism that prevents 3rd party modification of the layout by
denying the ability to break the layout. This "exclusive" aspect
does not make the layout immutable, either, it just means the
layout is only modifiable by the exclusive lease holder. 

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

