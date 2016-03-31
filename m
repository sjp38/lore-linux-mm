Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 018D56B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 20:28:06 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 4so55353254pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 17:28:05 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id lw9si9810876pab.89.2016.03.30.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 17:28:05 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id 4so55353006pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 17:28:05 -0700 (PDT)
Date: Thu, 31 Mar 2016 09:29:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 00/16] Support non-lru page migration
Message-ID: <20160331002932.GA1758@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <20160330161141.4332b189e7a4930e117d765b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160330161141.4332b189e7a4930e117d765b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On (03/30/16 16:11), Andrew Morton wrote:
[..]
> > For details, please read description in
> > "mm/compaction: support non-lru movable page migration".
> 
> OK, I grabbed all these.
> 
> I wonder about testing coverage during the -next period.  How many
> people are likely to exercise these code paths in a serious way before
> it all hits mainline?

I'm hammering the zsmalloc part.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
