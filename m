Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA606B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 20:55:52 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id x3so55807061pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 17:55:52 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r86si9916033pfb.219.2016.03.30.17.55.50
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 17:55:51 -0700 (PDT)
Date: Thu, 31 Mar 2016 09:57:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 00/16] Support non-lru page migration
Message-ID: <20160331005734.GC6736@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <20160330161141.4332b189e7a4930e117d765b@linux-foundation.org>
 <20160331002932.GA1758@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160331002932.GA1758@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Thu, Mar 31, 2016 at 09:29:32AM +0900, Sergey Senozhatsky wrote:
> On (03/30/16 16:11), Andrew Morton wrote:
> [..]
> > > For details, please read description in
> > > "mm/compaction: support non-lru movable page migration".
> > 
> > OK, I grabbed all these.
> > 
> > I wonder about testing coverage during the -next period.  How many
> > people are likely to exercise these code paths in a serious way before
> > it all hits mainline?
> 
> I'm hammering the zsmalloc part.

Thanks, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
