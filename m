Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C42EC3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:24:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34313233A0
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:24:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34313233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2A8C6B0369; Thu, 22 Aug 2019 20:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DCD16B036B; Thu, 22 Aug 2019 20:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EFAE6B036C; Thu, 22 Aug 2019 20:24:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 687706B0369
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:24:48 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 0234C8248AA0
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:24:48 +0000 (UTC)
X-FDA: 75851797056.12.form42_8113943a0d22f
X-HE-Tag: form42_8113943a0d22f
X-Filterd-Recvd-Size: 3320
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:24:46 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Aug 2019 17:24:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,419,1559545200"; 
   d="scan'208";a="173314320"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 22 Aug 2019 17:24:44 -0700
Date: Thu, 22 Aug 2019 17:24:44 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v2 0/3] mm/gup: introduce vaddr_pin_pages_remote(),
 FOLL_PIN
Message-ID: <20190823002443.GA19517@iweiny-DESK2.sc.intel.com>
References: <20190821040727.19650-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821040727.19650-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 09:07:24PM -0700, John Hubbard wrote:
> Hi Ira,
> 
> This is for your tree. I'm dropping the RFC because this aspect is
> starting to firm up pretty well.
> 
> I've moved FOLL_PIN inside the vaddr_pin_*() routines, and moved
> FOLL_LONGTERM outside, based on our recent discussions. This is
> documented pretty well within the patches.
> 
> Note that there are a lot of references in comments and commit
> logs, to vaddr_pin_pages(). We'll want to catch all of those if
> we rename that. I am pushing pretty hard to rename it to
> vaddr_pin_user_pages().
> 
> v1 of this may be found here:
> https://lore.kernel.org/r/20190812015044.26176-1-jhubbard@nvidia.com

I am really sorry about this...

I think it is fine to pull these in...  There are some nits which are wrong but
I think with the XDP complication and Daves' objection I think the vaddr_pin
information is going to need reworking.  So the documentation there is probably
wrong.  But until we know what it is going to be we should just take this.

Do you have a branch with this on it?

The patches don't seem to apply.  Looks like they got corrupted somewhere...

:-/

Thanks,
Ira

> 
> John Hubbard (3):
>   For Ira: tiny formatting tweak to kerneldoc
>   mm/gup: introduce FOLL_PIN flag for get_user_pages()
>   mm/gup: introduce vaddr_pin_pages_remote(), and invoke it
> 
>  drivers/infiniband/core/umem.c |  1 +
>  include/linux/mm.h             | 61 ++++++++++++++++++++++++++++++----
>  mm/gup.c                       | 40 ++++++++++++++++++++--
>  mm/process_vm_access.c         | 23 +++++++------
>  4 files changed, 106 insertions(+), 19 deletions(-)
> 
> -- 
> 2.22.1
> 
> 

