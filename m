Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8850A6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 22:59:11 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o3-v6so8378808pls.11
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 19:59:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u192sor421926pgc.162.2018.04.09.19.59.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 19:59:10 -0700 (PDT)
Date: Tue, 10 Apr 2018 11:59:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410025903.GA38000@rodete-desktop-imager.corp.google.com>
References: <20180409030930.GA214930@rodete-desktop-imager.corp.google.com>
 <20180409111403.GA31652@bombadil.infradead.org>
 <20180409112514.GA195937@rodete-laptop-imager.corp.google.com>
 <7706245c-2661-f28b-f7f9-8f11e1ae932b@huawei.com>
 <20180409144958.GA211679@rodete-laptop-imager.corp.google.com>
 <20180409152032.GB11756@bombadil.infradead.org>
 <20180409230409.GA214542@rodete-desktop-imager.corp.google.com>
 <20180410011211.GA31282@bombadil.infradead.org>
 <20180410023339.GB214542@rodete-desktop-imager.corp.google.com>
 <20180410024152.GC31282@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410024152.GC31282@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org

On Mon, Apr 09, 2018 at 07:41:52PM -0700, Matthew Wilcox wrote:
> On Tue, Apr 10, 2018 at 11:33:39AM +0900, Minchan Kim wrote:
> > @@ -522,7 +532,7 @@ EXPORT_SYMBOL(radix_tree_preload);
> >   */
> >  int radix_tree_maybe_preload(gfp_t gfp_mask)
> >  {
> > -	if (gfpflags_allow_blocking(gfp_mask))
> > +	if (gfpflags_allow_blocking(gfp_mask) && !(gfp_mask & __GFP_ZERO))
> >  		return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
> >  	/* Preloading doesn't help anything with this gfp mask, skip it */
> >  	preempt_disable();
> 
> No, you've completely misunderstood what's going on in this function.

Okay, I hope this version clear current concerns.
