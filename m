Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7067CC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:16:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C72C21874
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:16:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C72C21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD2106B0005; Thu, 29 Aug 2019 12:16:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B82726B0008; Thu, 29 Aug 2019 12:16:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A71E16B000C; Thu, 29 Aug 2019 12:16:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 858BD6B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:16:32 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3706240E8
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:16:32 +0000 (UTC)
X-FDA: 75875968224.12.dock44_38e456420d029
X-HE-Tag: dock44_38e456420d029
X-Filterd-Recvd-Size: 5169
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:16:30 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Aug 2019 09:16:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,444,1559545200"; 
   d="scan'208";a="183523268"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 29 Aug 2019 09:16:28 -0700
Date: Thu, 29 Aug 2019 09:16:28 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Theodore Ts'o <tytso@mit.edu>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
Message-ID: <20190829161627.GB18249@iweiny-DESK2.sc.intel.com>
References: <20190821185703.GB5965@iweiny-DESK2.sc.intel.com>
 <20190821194810.GI8653@ziepe.ca>
 <20190821204421.GE5965@iweiny-DESK2.sc.intel.com>
 <20190823032345.GG1119@dread.disaster.area>
 <20190823120428.GA12968@ziepe.ca>
 <20190824001124.GI1119@dread.disaster.area>
 <20190824050836.GC1092@iweiny-DESK2.sc.intel.com>
 <20190826055510.GL1119@dread.disaster.area>
 <20190829020230.GA18249@iweiny-DESK2.sc.intel.com>
 <3e5c5053-a74a-509c-660c-a6075ed87f11@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e5c5053-a74a-509c-660c-a6075ed87f11@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 08:27:23PM -0700, John Hubbard wrote:
> On 8/28/19 7:02 PM, Ira Weiny wrote:
> > On Mon, Aug 26, 2019 at 03:55:10PM +1000, Dave Chinner wrote:
> > > On Fri, Aug 23, 2019 at 10:08:36PM -0700, Ira Weiny wrote:
> > > > On Sat, Aug 24, 2019 at 10:11:24AM +1000, Dave Chinner wrote:
> > > > > On Fri, Aug 23, 2019 at 09:04:29AM -0300, Jason Gunthorpe wrote:
> ...
> > > 
> > > Sure, that part works because the struct file is passed. It doesn't
> > > end up with the same fd number in the other process, though.
> > > 
> > > The issue is that layout leases need to notify userspace when they
> > > are broken by the kernel, so a lease stores the owner pid/tid in the
> > > file->f_owner field via __f_setown(). It also keeps a struct fasync
> > > attached to the file_lock that records the fd that the lease was
> > > created on.  When a signal needs to be sent to userspace for that
> > > lease, we call kill_fasync() and that walks the list of fasync
> > > structures on the lease and calls:
> > > 
> > > 	send_sigio(fown, fa->fa_fd, band);
> > > 
> > > And it does for every fasync struct attached to a lease. Yes, a
> > > lease can track multiple fds, but it can only track them in a single
> > > process context. The moment the struct file is shared with another
> > > process, the lease is no longer capable of sending notifications to
> > > all the lease holders.
> > > 
> > > Yes, you can change the owning process via F_SETOWNER, but that's
> > > still only a single process context, and you can't change the fd in
> > > the fasync list. You can add new fd to an existing lease by calling
> > > F_SETLEASE on the new fd, but you still only have a single process
> > > owner context for signal delivery.
> > > 
> > > As such, leases that require callbacks to userspace are currently
> > > only valid within the process context the lease was taken in.
> > 
> > But for long term pins we are not requiring callbacks.
> > 
> 
> Hi Ira,
> 
> If "require callbacks to userspace" means sending SIGIO, then actually
> FOLL_LONGTERM *does* require those callbacks. Because we've been, so
> far, equating FOLL_LONGTERM with the vaddr_pin struct and with a lease.
> 
> What am I missing here?

We agreed back in June that the layout lease would have 2 "levels".  The
"normal" layout lease would cause SIGIO and could be broken and another
"exclusive" level which could _not_ be broken.

Because we _can't_ _trust_ user space to react to the SIGIO properly the
"exclusive" lease is required to take the longterm pins.  Also this is the
lease which causes the truncate to fail (return ETXTBSY) because the kernel
can't break the lease.

The vaddr_pin struct in the current RFC is there for a couple of reasons.

1) To ensure that we have a way to correlate the long term pin user with the
   file if the data file FD's are closed.  (ie the application has zombie'd the
   lease).

2) And more importantly as a token the vaddr_pin*() callers use to be able to
   properly ref count the file itself while in use.

Ira


