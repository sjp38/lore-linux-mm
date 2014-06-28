Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 393AB6B0036
	for <linux-mm@kvack.org>; Sat, 28 Jun 2014 15:43:40 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so6256722pad.26
        for <linux-mm@kvack.org>; Sat, 28 Jun 2014 12:43:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qu8si18067464pbb.27.2014.06.28.12.43.39
        for <linux-mm@kvack.org>;
        Sat, 28 Jun 2014 12:43:39 -0700 (PDT)
Date: Sat, 28 Jun 2014 12:44:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] msync: fix incorrect fstart calculation
Message-Id: <20140628124421.c499b001.akpm@linux-foundation.org>
In-Reply-To: <20140628191425.GA2162@thunk.org>
References: <006a01cf91fc$5d225170$1766f450$@samsung.com>
	<20140628191425.GA2162@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Namjae Jeon <namjae.jeon@samsung.com>, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, =?UTF-8?Q?Luk=C3=A1=C5=A1?= Czerner <lczerner@redhat.com>, 'Matthew Wilcox' <matthew.r.wilcox@intel.com>, 'Eric Whitney' <enwlinux@gmail.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Sat, 28 Jun 2014 15:14:25 -0400 "Theodore Ts'o" <tytso@mit.edu> wrote:

> On Fri, Jun 27, 2014 at 08:38:49PM +0900, Namjae Jeon wrote:
> > Fix a regression caused by Commit 7fc34a62ca mm/msync.c: sync only
> > the requested range in msync().
> > xfstests generic/075 fail occured on ext4 data=journal mode because
> > the intended range was not syncing due to wrong fstart calculation.
> > 
> > Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> > Cc: Luk____ Czerner <lczerner@redhat.com>
> > Reported-by: Eric Whitney <enwlinux@gmail.com>
> > Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> > Signed-off-by: Ashish Sangwan <a.sangwan@samsung.com>
> 
> Reviewed-by: Theodore Ts'o <tytso@mit.edu>
> 
> Andrew, do you want to take this in the mm tree,

I have done so.

> or shall I take it in
> the ext4 tree?  I would prefer if we could get this pushed to Linus as
> soon as possible, since it fixes a regression.

Yep, I'll get it over to Linus early next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
