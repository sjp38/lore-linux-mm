Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 86F726B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 16:20:37 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so8383820pac.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 13:20:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id rq7si28657489pab.73.2015.10.12.13.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 13:20:36 -0700 (PDT)
Date: Mon, 12 Oct 2015 22:20:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: use is_zero_pfn after pte_present check
Message-ID: <20151012202033.GI19147@redhat.com>
References: <1444614856-18543-1-git-send-email-minchan@kernel.org>
 <20151012101320.GB2544@node>
 <20151012145746.GA11396@bbox>
 <561BCE7A.1080403@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561BCE7A.1080403@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Mon, Oct 12, 2015 at 05:15:06PM +0200, Vlastimil Babka wrote:
> So this patch should be stable 4.1+. Does it apply both in -next and 
> 4.3-rcX?

It applies clean to 4.3-rc but it'll reject on <= 4.2 because of some
orthogonal change, so for stable it sounds better to send a separate
patch.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
