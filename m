Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 314096B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 22:14:02 -0400 (EDT)
Date: Thu, 20 Sep 2012 22:13:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix NR_ISOLATED_[ANON|FILE] mismatch
Message-ID: <20120921021201.GA12851@cmpxchg.org>
References: <20120920232408.GI13234@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120920232408.GI13234@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Vasiliy Kulikov <segooon@gmail.com>

On Fri, Sep 21, 2012 at 08:24:08AM +0900, Minchan Kim wrote:
> On Thu, Sep 20, 2012 at 11:41:11AM -0400, Johannes Weiner wrote:
> > On Thu, Sep 20, 2012 at 08:51:56AM +0900, Minchan Kim wrote:
> > > From: Minchan Kim <minchan@kernel.org>
> > > Date: Thu, 20 Sep 2012 08:39:52 +0900
> > > Subject: [PATCH] mm: revert 0def08e3, mm/mempolicy.c: check return code of
> > >  check_range

[...]

> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 21 Sep 2012 08:17:37 +0900
> Subject: [PATCH] mm: enhance comment and bug check
> 
> This patch updates comment and bug check.
> It can be fold into [1].
> 
> [1] mm-revert-0def08e3-mm-mempolicyc-check-return-code-of-check_range.patch
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Thanks!  To the patch and this update:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
