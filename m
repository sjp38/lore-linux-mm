Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D4D1C5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 09:40:36 -0400 (EDT)
Date: Tue, 14 Apr 2009 15:41:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 4/6] aio: Don't inherit aio ring memory at fork
Message-ID: <20090414134109.GD28265@random.random>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151924.C653.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414151924.C653.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-api@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 03:20:20PM +0900, KOSAKI Motohiro wrote:
> In addition, This patch has good side effect. it also fix "get_user_pages() vs fork" problem.

Yes, patches like 3/6, 4/6, and 6/6 are the side effect of not fixing
the core race in gup and spreading the new rwsem around the gup users,
instead of sticking to a page-granular PG_flag touched at the same
time atomic_inc runs on page->_count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
