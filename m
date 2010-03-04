Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55D866B0098
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 18:29:10 -0500 (EST)
Date: Thu, 4 Mar 2010 15:29:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix some coding styles on mm/ tree
Message-Id: <20100304152904.c2d26745.akpm@linux-foundation.org>
In-Reply-To: <20100304110916.GA3197@localhost.localdomain>
References: <20100304110916.GA3197@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: wzt.wzt@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010 19:09:16 +0800
wzt.wzt@gmail.com wrote:

> Fix some coding styles on mm/ tree.
> 
> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
> 
> ---
>  mm/filemap.c     |   10 ++++------
>  mm/filemap_xip.c |    3 +--
>  mm/slab.c        |    8 ++++----
>  mm/vmscan.c      |    4 ++--
>  4 files changed, 11 insertions(+), 14 deletions(-)

I don't mind fixing coding-style issues in there, but I would prefer
that it be more comprehensive than this - someone sits down and does a
series of large, more complete subystem-wide cleanups then sure, in the
long term it's worth the pain of merging them.

But I don't think it's good to do this as a slow, random ad-hoc
pitter-patter of changes like this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
