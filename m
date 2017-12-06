Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8A146B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 18:58:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v190so3110109pgv.11
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 15:58:32 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v20si1686306plo.820.2017.12.06.15.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 15:58:31 -0800 (PST)
Date: Wed, 6 Dec 2017 16:58:29 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171206235829.GA28086@linux.intel.com>
References: <20171206004159.3755-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 04:40:46PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I looked through some notes and decided this was version 4 of the XArray.
> Last posted two weeks ago, this version includes a *lot* of changes.
> I'd like to thank Dave Chinner for his feedback, encouragement and
> distracting ideas for improvement, which I'll get to once this is merged.
> 
> Highlights:
>  - Over 2000 words of documentation in patch 8!  And lots more kernel-doc.
>  - The page cache is now fully converted to the XArray.
>  - Many more tests in the test-suite.
> 
> This patch set is not for applying.  0day is still reporting problems,
> and I'd feel bad for eating someone's data.  These patches apply on top
> of a set of prepatory patches which just aren't interesting.  If you
> want to see the patches applied to a tree, I suggest pulling my git tree:
> http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2017-12-04
> I also left out the idr_preload removals.  They're still in the git tree,
> but I'm not looking for feedback on them.

Hey Matthew,

Maybe I missed this from a previous version, but can you explain the
motivation for replacing the radix tree with an xarray?  (I think this should
probably still be part of the cover letter?)  Do we have a performance problem
we need to solve?  A code complexity issue we need to solve?  Something else?

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
