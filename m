Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41FBC6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:53:33 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so477314pac.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 15:53:33 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id di4si29558010pad.183.2015.10.12.15.53.31
        for <linux-mm@kvack.org>;
        Mon, 12 Oct 2015 15:53:32 -0700 (PDT)
Date: Tue, 13 Oct 2015 09:53:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5] mm, dax: fix DAX deadlocks
Message-ID: <20151012225327.GF27164@dastard>
References: <1444258729-21974-1-git-send-email-ross.zwisler@linux.intel.com>
 <1444258729-21974-2-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444258729-21974-2-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Wed, Oct 07, 2015 at 04:58:49PM -0600, Ross Zwisler wrote:
> The following two locking commits in the DAX code:
> 
> commit 843172978bb9 ("dax: fix race between simultaneous faults")
> commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")
> 
> introduced a number of deadlocks and other issues which need to be fixed
> for the v4.3 kernel. The list of issues in DAX after these commits (some
> newly introduced by the commits, some preexisting) can be found here:
> 
> https://lkml.org/lkml/2015/9/25/602
> 
> This undoes most of the changes introduced by those two commits,
> essentially returning us to the DAX locking scheme that was used in v4.2.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I've run this through some testing, the deadlocks aren't present and
there don't appear to be any new regressions, so IMO this is fine to
go to Linus.

Tested-by: Dave Chinner <dchinner@redhat.com>

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
