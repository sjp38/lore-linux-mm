Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 498D66B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:30:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z189so10190708wmb.6
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:30:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d27si3242780wmi.134.2016.10.19.00.30.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 00:30:18 -0700 (PDT)
Date: Wed, 19 Oct 2016 09:30:16 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 20/20] dax: Clear dirty entry tags on cache flush
Message-ID: <20161019073016.GJ29967@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-21-git-send-email-jack@suse.cz>
 <20161018221254.GG7796@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018221254.GG7796@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 18-10-16 16:12:54, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:24PM +0200, Jan Kara wrote:
> > Currently we never clear dirty tags in DAX mappings and thus address
> > ranges to flush accumulate. Now that we have locking of radix tree
> > entries, we have all the locking necessary to reliably clear the radix
> > tree dirty tag when flushing caches for corresponding address range.
> > Similarly to page_mkclean() we also have to write-protect pages to get a
> > page fault when the page is next written to so that we can mark the
> > entry dirty again.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Looks great. 
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Thanks for review Ross! I've rebased the series on top of rc1. Do you have
your PMD series somewhere rebased on top of rc1 so that I can rebase my
patches on top of that as well? Then I'd post another version of the
series...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
