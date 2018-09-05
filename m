Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0586B6B7493
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 14:44:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n4-v6so4209519plk.7
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 11:44:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w14-v6si2516870plp.183.2018.09.05.11.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 11:44:46 -0700 (PDT)
Date: Wed, 5 Sep 2018 11:44:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: linux-next test error
Message-ID: <20180905184433.GA31174@infradead.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905133459.GF23909@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Souptick Joarder <jrdr.linux@gmail.com>, Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, willy@infradead.org

On Wed, Sep 05, 2018 at 09:34:59AM -0400, Theodore Y. Ts'o wrote:
> It's at: 83c0adddcc6ed128168e7b87eaed0c21eac908e4 in the Linux Next
> branch.
> 
> Dmitry, can you try reverting this commit and see if it makes the
> problem go away?
> 
> Souptick, can we just NACK this patch and completely drop it from all
> trees?
> 
> I think we need to be a *lot* more careful about this vm_fault_t patch
> thing.  If you can't be bothered to run xfstests, we need to introduce
> a new function which replaces block_page_mkwrite() --- and then let
> each file system try to convert over to it at their own pace, after
> they've done regression testing.

block_page_mkwrite is only called by ext4 and nilfs2 anyway, so
converting both callers over should not be a problem, as long as
it actually is done properly.

Which is my main beef with this mess of a conversation - it should
have been posted as a single series that actually does a mostly
scriped conversion after fixing up the initial harder issues, and
be properly tested.  It has been pretty much an example of how not
do things, and been dragging on forever while wasting everyones time.
