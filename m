Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F439C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 509E5214C6
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 18:15:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="b1+hpPls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 509E5214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C59186B0007; Wed, 14 Aug 2019 14:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE1AF6B000A; Wed, 14 Aug 2019 14:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB2DE6B0007; Wed, 14 Aug 2019 14:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DABE6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 14:15:32 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 38D5755F99
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:15:32 +0000 (UTC)
X-FDA: 75821836104.07.sun83_4d622ff4e513c
X-HE-Tag: sun83_4d622ff4e513c
X-Filterd-Recvd-Size: 7598
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:15:31 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id i4so2682628qtj.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:15:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yv3o7B3UHsHqSeSF1eawcreZUewpnoCKBkRqVbvZv+Y=;
        b=b1+hpPlsUllmS55yStmayLIczHkh/gs2U6xTQjHLoJzP6BS9rrpQYU/Q+zjEtqYpZJ
         bUfdxFnv/io/njD4H81VOrB5HpxoX0UpCfWVJE3iMK6BRX+7xz2/qyYNYBY1s0aQv9oC
         57OzZnbd2E8pHcIPyMI3M38ltO867icv9pCABQ2nRkA4GhB4x8TTEWzbIIEp3I5Bu9v8
         1j7u4CiNFmqOJmrgun4bWFv3s4L2PKJsY5MMwj8yq7JCEFqVNh4FZN9aCdeS6xLd4vsG
         tzdz7jPh3keJQnQMNdxfDM5IWfs75T0jwE2SLAPsGzMCYk/egYJiAQxgc739HbYg2Btp
         tbAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=yv3o7B3UHsHqSeSF1eawcreZUewpnoCKBkRqVbvZv+Y=;
        b=tBM+xN+TNq32OCcmdKwz7wigIRalXvLheIW9qbLyJm+FHOLI6RJgzqE+RNa3yUtXzQ
         eEkQbH9Tb4T4O/aYImcs5vyAH/ubDqzqx7jS1n7T9GkT6Pib0sFE1SZS6fPq4bZFO/yv
         Cm9nCbAxIYGLCJUBYmjoaNq6CM/ZeHW+b71ImgaHdUICcNtvP0CzU14kRMPVoEurKSG1
         jyGt08Ncgge95mO5fFU2G38hiMFbgOJUQZWHunWNeFIVKTfjx1zsGFLGRIk6NS0RrCMa
         dV0onfCRaDcyzTJvdtWq1WDnw9bMvhxbzECEV+Q4WykIs9SMiys3TCvi7LnsTtjvo6Mm
         wDVw==
X-Gm-Message-State: APjAAAVphR9CxMFIcOLb7xARTg7lcGgBOgwJ+T8dB7pQxJzHZA04mvO+
	SJ4y/pbsBUHWYQ8kBUyvYNAoTQ==
X-Google-Smtp-Source: APXvYqwQg84mNfjabrjxPWgnQFA0kP85o9/bjBwuu/n1RL4RSpA12tlrWJldmQ90D3a9zEfF7PDYNg==
X-Received: by 2002:ac8:34ea:: with SMTP id x39mr609754qtb.311.1565806530924;
        Wed, 14 Aug 2019 11:15:30 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id h66sm253461qke.61.2019.08.14.11.15.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 11:15:30 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxxo2-00028Y-0t; Wed, 14 Aug 2019 15:15:30 -0300
Date: Wed, 14 Aug 2019 15:15:30 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 16/19] RDMA/uverbs: Add back pointer to system
 file object
Message-ID: <20190814181529.GD13770@ziepe.ca>
References: <20190812130039.GD24457@ziepe.ca>
 <20190812172826.GA19746@iweiny-DESK2.sc.intel.com>
 <20190812175615.GI24457@ziepe.ca>
 <20190812211537.GE20634@iweiny-DESK2.sc.intel.com>
 <20190813114842.GB29508@ziepe.ca>
 <20190813174142.GB11882@iweiny-DESK2.sc.intel.com>
 <20190813180022.GF29508@ziepe.ca>
 <20190813203858.GA12695@iweiny-DESK2.sc.intel.com>
 <20190814122308.GB13770@ziepe.ca>
 <20190814175045.GA31490@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814175045.GA31490@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:50:45AM -0700, Ira Weiny wrote:
> On Wed, Aug 14, 2019 at 09:23:08AM -0300, Jason Gunthorpe wrote:
> > On Tue, Aug 13, 2019 at 01:38:59PM -0700, Ira Weiny wrote:
> > > On Tue, Aug 13, 2019 at 03:00:22PM -0300, Jason Gunthorpe wrote:
> > > > On Tue, Aug 13, 2019 at 10:41:42AM -0700, Ira Weiny wrote:
> > > > 
> > > > > And I was pretty sure uverbs_destroy_ufile_hw() would take care of (or ensure
> > > > > that some other thread is) destroying all the MR's we have associated with this
> > > > > FD.
> > > > 
> > > > fd's can't be revoked, so destroy_ufile_hw() can't touch them. It
> > > > deletes any underlying HW resources, but the FD persists.
> > > 
> > > I misspoke.  I should have said associated with this "context".  And of course
> > > uverbs_destroy_ufile_hw() does not touch the FD.  What I mean is that the
> > > struct file which had file_pins hanging off of it would be getting its file
> > > pins destroyed by uverbs_destroy_ufile_hw().  Therefore we don't need the FD
> > > after uverbs_destroy_ufile_hw() is done.
> > > 
> > > But since it does not block it may be that the struct file is gone before the
> > > MR is actually destroyed.  Which means I think the GUP code would blow up in
> > > that case...  :-(
> > 
> > Oh, yes, that is true, you also can't rely on the struct file living
> > longer than the HW objects either, that isn't how the lifetime model
> > works.
> > 
> > If GUP consumes the struct file it must allow the struct file to be
> > deleted before the GUP pin is released.
> 
> I may have to think about this a bit.  But I'm starting to lean toward my
> callback method as a solution...
> 
> > 
> > > The drivers could provide some generic object (in RDMA this could be the
> > > uverbs_attr_bundle) which represents their "context".
> > 
> > For RDMA the obvious context is the struct ib_mr *
> 
> Not really, but maybe.  See below regarding tracking this across processes.
> 
> > 
> > > But for the procfs interface, that context then needs to be associated with any
> > > file which points to it...  For RDMA, or any other "FD based pin mechanism", it
> > > would be up to the driver to "install" a procfs handler into any struct file
> > > which _may_ point to this context.  (before _or_ after memory pins).
> > 
> > Is this all just for debugging? Seems like a lot of complication just
> > to print a string
> 
> No, this is a requirement to allow an admin to determine why their truncates
> may be failing.  As per our discussion here:
> 
> https://lkml.org/lkml/2019/6/7/982

visibility/debugging..

I don't see any solution here with the struct file - we apparently
have a problem with deadlock if the uverbs close() waits as mmput()
can trigger a call close() - see the comment on top of
uverbs_destroy_ufile_hw()

However, I wonder if that is now old information since commit
4a9d4b024a31 ("switch fput to task_work_add") makes fput deferred, so
mmdrop() should not drop waiting on fput??

If you could unwrap this mystery, probably with some testing proof,
then we could make uverbs_destroy_ufile_hw() a fence even for close
and your task is much simpler.

The general flow to trigger is to have a process that has mmap'd
something from the uverbs fd, then trigger both device disassociate
and process exit with just the right race so that the process has
exited enough that the mmdrop on the disassociate threda does the
final cleanup triggering the VMAs inside the mm to do the final fput
on their FDs, triggering final fput() for uverbs inside the thread of
disassociate.

Jason

