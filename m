Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD1E8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:36:49 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a9so25665912pla.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:36:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 72si332932plb.224.2019.01.03.06.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:36:48 -0800 (PST)
Date: Thu, 3 Jan 2019 06:36:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103143647.GP6310@bombadil.infradead.org>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103143116.GB3395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103143116.GB3395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Thu, Jan 03, 2019 at 09:31:16AM -0500, Jerome Glisse wrote:
> On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> > 
> > One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> > incorrectly.
> > 
> > Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> > Tested-by: Dave Chinner <dchinner@redhat.com>
> 
> Actually now that i have read the code again this is not ok to
> do so. The caller of follow_pte_pmd() will call range_init and
> follow pmd will only update the range address. So existing code
> is ok.

The only caller of follow_pte_pmd() does not call range_init() because it
doesn't know the address.  That's the point of follow_pte_pmd().

> I know this is kind of ugly but i do not see a way around that
> uglyness.

You wrote the code ...
