Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8722EC3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 02:02:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A4662339E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 02:02:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A4662339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74E366B0006; Wed, 28 Aug 2019 22:02:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE676B000C; Wed, 28 Aug 2019 22:02:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 615286B000D; Wed, 28 Aug 2019 22:02:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 40C846B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:02:36 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E5FF1181AC9AE
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:02:35 +0000 (UTC)
X-FDA: 75873816270.28.war85_1689d0aac4422
X-HE-Tag: war85_1689d0aac4422
X-Filterd-Recvd-Size: 8555
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:02:34 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Aug 2019 19:02:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,442,1559545200"; 
   d="scan'208";a="175115578"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 28 Aug 2019 19:02:31 -0700
Date: Wed, 28 Aug 2019 19:02:31 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190829020230.GA18249@iweiny-DESK2.sc.intel.com>
References: <20190821180200.GA5965@iweiny-DESK2.sc.intel.com>
 <20190821181343.GH8653@ziepe.ca>
 <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
 <20190821194810.GI8653@ziepe.ca>
 <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
 <20190823032345.GG1119@dread.disaster.area>
 <20190823120428.GA12968@ziepe.ca>
 <20190824001124.GI1119@dread.disaster.area>
 <20190824050836.GC1092@iweiny-DESK2.sc.intel.com>
 <20190826055510.GL1119@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826055510.GL1119@dread.disaster.area>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 03:55:10PM +1000, Dave Chinner wrote:
> On Fri, Aug 23, 2019 at 10:08:36PM -0700, Ira Weiny wrote:
> > On Sat, Aug 24, 2019 at 10:11:24AM +1000, Dave Chinner wrote:
> > > On Fri, Aug 23, 2019 at 09:04:29AM -0300, Jason Gunthorpe wrote:
> > >
> > > > IMHO it is wrong to try and create a model where the file lease exists
> > > > independently from the kernel object relying on it. In other words the
> > > > IB MR object itself should hold a reference to the lease it relies
> > > > upon to function properly.
> > > 
> > > That still doesn't work. Leases are not individually trackable or
> > > reference counted objects objects - they are attached to a struct
> > > file bUt, in reality, they are far more restricted than a struct
> > > file.
> > > 
> > > That is, a lease specifically tracks the pid and the _open fd_ it
> > > was obtained for, so it is essentially owned by a specific process
> > > context.  Hence a lease is not able to be passed to a separate
> > > process context and have it still work correctly for lease break
> > > notifications.  i.e. the layout break signal gets delivered to
> > > original process that created the struct file, if it still exists
> > > and has the original fd still open. It does not get sent to the
> > > process that currently holds a reference to the IB context.

But this is an exclusive layout lease which does not send a signal.  There is
no way to break it.

> > >
> > 
> > The fcntl man page says:
> > 
> > "Leases are associated with an open file description (see open(2)).  This means
> > that duplicate file descriptors (created by, for example, fork(2) or dup(2))
> > refer to the same lease, and this lease may be modified or released using any
> > of these descriptors.  Furthermore,  the lease is released by either an
> > explicit F_UNLCK operation on any of these duplicate file descriptors, or when
> > all such file descriptors have been closed."
> 
> Right, the lease is attached to the struct file, so it follows
> where-ever the struct file goes. That doesn't mean it's actually
> useful when the struct file is duplicated and/or passed to another
> process. :/
> 
> AFAICT, the problem is that when we take another reference to the
> struct file, or when the struct file is passed to a different
> process, nothing updates the lease or lease state attached to that
> struct file.

Ok, I probably should have made this more clear in the cover letter but _only_
the process which took the lease can actually pin memory.

That pinned memory _can_ be passed to another process but those sub-process' can
_not_ use the original lease to pin _more_ of the file.  They would need to
take their own lease to do that.

Sorry for not being clear on that.

> 
> > From this I took it that the child process FD would have the lease as well
> > _and_ could release it.  I _assumed_ that applied to SCM_RIGHTS but it does not
> > seem to work the same way as dup() so I'm not so sure.
> 
> Sure, that part works because the struct file is passed. It doesn't
> end up with the same fd number in the other process, though.
> 
> The issue is that layout leases need to notify userspace when they
> are broken by the kernel, so a lease stores the owner pid/tid in the
> file->f_owner field via __f_setown(). It also keeps a struct fasync
> attached to the file_lock that records the fd that the lease was
> created on.  When a signal needs to be sent to userspace for that
> lease, we call kill_fasync() and that walks the list of fasync
> structures on the lease and calls:
> 
> 	send_sigio(fown, fa->fa_fd, band);
> 
> And it does for every fasync struct attached to a lease. Yes, a
> lease can track multiple fds, but it can only track them in a single
> process context. The moment the struct file is shared with another
> process, the lease is no longer capable of sending notifications to
> all the lease holders.
> 
> Yes, you can change the owning process via F_SETOWNER, but that's
> still only a single process context, and you can't change the fd in
> the fasync list. You can add new fd to an existing lease by calling
> F_SETLEASE on the new fd, but you still only have a single process
> owner context for signal delivery.
> 
> As such, leases that require callbacks to userspace are currently
> only valid within the process context the lease was taken in.

But for long term pins we are not requiring callbacks.

> Indeed, even closing the fd the lease was taken on without
> F_UNLCKing it first doesn't mean the lease has been torn down if
> there is some other reference to the struct file. That means the
> original lease owner will still get SIGIO delivered to that fd on a
> lease break regardless of whether it is open or not. ANd if we
> implement "layout lease not released within SIGIO response timeout"
> then that process will get killed, despite the fact it may not even
> have a reference to that file anymore.

I'm not seeing that as a problem.  This is all a result of the application
failing to do the right thing.  The code here is simply keeping the kernel
consistent and safe so that an admin or the user themselves can unwind the
badness without damage to the file system.

> 
> So, AFAICT, leases that require userspace callbacks only work within
> their original process context while they original fd is still open.

But they _work_ IFF the application actually expects to do something with the
SIGIO.  The application could just as well chose to ignore the SIGIO without
closing the FD which would do the same thing.

If the application expected to do something with the SIGIO but closed the FD
then it's really just the applications fault.

So after thinking on this for a day I don't think we have a serious issue.

Even the "zombie" lease is just an application error and it is already possible
to get something like this.  If the application passes the FD to another
process and closes their FD then SIGIO's don't get delivered but there is a
lease hanging off the struct file until it is destroyed.  No harm, no foul.

In the case of close it is _not_ true that users don't have a way to release
the lease.  It is just that they can't call F_UNLCK to do so.  Once they have
"zombie'ed" the lease (again an application error) the only recourse is to
unpin the file through the subsystem which pinned the page.  Probably through
killing the process.

Ira


