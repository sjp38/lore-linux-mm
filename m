Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68FB86B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 06:57:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o70so89216040lfg.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 03:57:48 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id f5si43789068wjt.204.2016.05.30.03.57.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 03:57:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 9B5F098C65
	for <linux-mm@kvack.org>; Mon, 30 May 2016 10:57:46 +0000 (UTC)
Date: Mon, 30 May 2016 11:57:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: prevent infinite loop in
 buffered_rmqueue()
Message-ID: <20160530105745.GO2527@techsingularity.net>
References: <20160530090154.GM2527@techsingularity.net>
 <a4da34ff-cda2-a9a9-d586-277eb6f8797e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a4da34ff-cda2-a9a9-d586-277eb6f8797e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 30, 2016 at 11:46:05AM +0200, Vlastimil Babka wrote:
> On 05/30/2016 11:01 AM, Mel Gorman wrote:
> >From: Vlastimil Babka <vbabka@suse.cz>
> >
> >In DEBUG_VM kernel, we can hit infinite loop for order == 0 in
> >buffered_rmqueue() when check_new_pcp() returns 1, because the bad page is
> >never removed from the pcp list. Fix this by removing the page before retrying.
> >Also we don't need to check if page is non-NULL, because we simply grab it from
> >the list which was just tested for being non-empty.
> >
> >Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch
> 
> That was a wrong one, which I corrected later. Also it's no longer mmotm.
> Correction below:
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages
> allocated from the PCP")
> 

Yes sorry, I meant to clean it up but had just re-read the patch itself,
confirmed it was missing and was still required.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
