Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA6826B7341
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:35:08 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 1-v6so5113154ywd.9
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:35:08 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m203-v6si508540ywb.313.2018.09.05.06.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 06:35:07 -0700 (PDT)
Date: Wed, 5 Sep 2018 09:34:59 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: linux-next test error
Message-ID: <20180905133459.GF23909@thunk.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org, willy@infradead.org

On Wed, Sep 05, 2018 at 03:20:16PM +0530, Souptick Joarder wrote:
> 
> "fs: convert return type int to vm_fault_t" is still under
> review/discusson and not yet merge
> into linux-next. I am not seeing it into linux-next tree.Can you
> please share the commit id ?

It's at: 83c0adddcc6ed128168e7b87eaed0c21eac908e4 in the Linux Next
branch.

Dmitry, can you try reverting this commit and see if it makes the
problem go away?

Souptick, can we just NACK this patch and completely drop it from all
trees?

I think we need to be a *lot* more careful about this vm_fault_t patch
thing.  If you can't be bothered to run xfstests, we need to introduce
a new function which replaces block_page_mkwrite() --- and then let
each file system try to convert over to it at their own pace, after
they've done regression testing.

						- Ted
