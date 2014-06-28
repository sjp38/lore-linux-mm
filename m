Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id E40026B0035
	for <linux-mm@kvack.org>; Sat, 28 Jun 2014 15:14:31 -0400 (EDT)
Received: by mail-yk0-f182.google.com with SMTP id 19so3700000ykq.41
        for <linux-mm@kvack.org>; Sat, 28 Jun 2014 12:14:31 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id l47si8719755yhl.27.2014.06.28.12.14.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 28 Jun 2014 12:14:31 -0700 (PDT)
Date: Sat, 28 Jun 2014 15:14:25 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] msync: fix incorrect fstart calculation
Message-ID: <20140628191425.GA2162@thunk.org>
References: <006a01cf91fc$5d225170$1766f450$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <006a01cf91fc$5d225170$1766f450$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <namjae.jeon@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>, 'Matthew Wilcox' <matthew.r.wilcox@intel.com>, 'Eric Whitney' <enwlinux@gmail.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Fri, Jun 27, 2014 at 08:38:49PM +0900, Namjae Jeon wrote:
> Fix a regression caused by Commit 7fc34a62ca mm/msync.c: sync only
> the requested range in msync().
> xfstests generic/075 fail occured on ext4 data=journal mode because
> the intended range was not syncing due to wrong fstart calculation.
> 
> Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: LukA!A! Czerner <lczerner@redhat.com>
> Reported-by: Eric Whitney <enwlinux@gmail.com>
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Signed-off-by: Ashish Sangwan <a.sangwan@samsung.com>

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

Andrew, do you want to take this in the mm tree, or shall I take it in
the ext4 tree?  I would prefer if we could get this pushed to Linus as
soon as possible, since it fixes a regression.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
