Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 83C286B0032
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 18:02:11 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so6158200pbc.31
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 15:02:11 -0700 (PDT)
Date: Mon, 30 Sep 2013 15:02:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: pagevec: cleanup: drop pvec->cold argument in all
 places
Message-Id: <20130930150207.3661b5c146b6ecea84194547@linux-foundation.org>
In-Reply-To: <1380357239-30102-1-git-send-email-bob.liu@oracle.com>
References: <1380357239-30102-1-git-send-email-bob.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, minchan@kernel.org, Bob Liu <bob.liu@oracle.com>

On Sat, 28 Sep 2013 16:33:58 +0800 Bob Liu <lliubbo@gmail.com> wrote:

> Nobody uses the pvec->cold argument of pagevec and it's also unreasonable for
> pages in pagevec released as cold page, so drop the cold argument from pagevec.

Is it unreasonable?  I'd say it's unreasonable to assume that all pages
in all cases are likely to be cache-hot.  Example: what if the pages
are being truncated and were found to be on the inactive LRU,
unreferenced?

A useful exercise would be to go through all those pagevec_init() sites
and convince ourselves that the decision at each place was the correct
one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
