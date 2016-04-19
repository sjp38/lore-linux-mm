Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8E46B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:52:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t124so16272180pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:52:04 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id c74si12649197pfb.219.2016.04.19.00.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 00:52:03 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id e128so4267952pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 00:52:03 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:53:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 11/16] zsmalloc: separate free_zspage from
 putback_zspage
Message-ID: <20160419075334.GA537@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-12-git-send-email-minchan@kernel.org>
 <20160418010408.GB5882@swordfish>
 <20160419075118.GD18448@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160419075118.GD18448@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello Minchan,

On (04/19/16 16:51), Minchan Kim wrote:
[..]
> 
> I guess it is remained thing after I rebased to catch any mistake.
> But I'm heavily chainging this part.
> Please review next version instead of this after a few days. :)

ah, got it. thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
