Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 211BB6B0265
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:38:45 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so13970772pab.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:38:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a2si4158595pgn.278.2016.10.19.09.38.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 09:38:44 -0700 (PDT)
Date: Wed, 19 Oct 2016 10:38:39 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 20/20] dax: Clear dirty entry tags on cache flush
Message-ID: <20161019163839.GA22463@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-21-git-send-email-jack@suse.cz>
 <20161018221254.GG7796@linux.intel.com>
 <20161019073016.GJ29967@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019073016.GJ29967@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Oct 19, 2016 at 09:30:16AM +0200, Jan Kara wrote:
> On Tue 18-10-16 16:12:54, Ross Zwisler wrote:
> > On Tue, Sep 27, 2016 at 06:08:24PM +0200, Jan Kara wrote:
> > > Currently we never clear dirty tags in DAX mappings and thus address
> > > ranges to flush accumulate. Now that we have locking of radix tree
> > > entries, we have all the locking necessary to reliably clear the radix
> > > tree dirty tag when flushing caches for corresponding address range.
> > > Similarly to page_mkclean() we also have to write-protect pages to get a
> > > page fault when the page is next written to so that we can mark the
> > > entry dirty again.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > Looks great. 
> > 
> > Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> Thanks for review Ross! I've rebased the series on top of rc1. Do you have
> your PMD series somewhere rebased on top of rc1 so that I can rebase my
> patches on top of that as well? Then I'd post another version of the
> series...

Sure, I'll rebase & post a new version of my series today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
