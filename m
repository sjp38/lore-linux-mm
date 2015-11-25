Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id E2F8A6B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:53:21 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so28896224igb.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:53:21 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id c16si2479897igo.99.2015.11.24.18.53.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 18:53:21 -0800 (PST)
Date: Wed, 25 Nov 2015 11:53:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 00/16] MADV_FREE support
Message-ID: <20151125025318.GA2678@bbox>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
 <20151124135851.bd50e261e30ed4e178baaef9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124135851.bd50e261e30ed4e178baaef9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

Hi Andrew,

On Tue, Nov 24, 2015 at 01:58:51PM -0800, Andrew Morton wrote:
> On Fri, 20 Nov 2015 17:02:32 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > I have been spent a lot of time to land MADV_FREE feature
> > by request of userland people(esp, Daniel and Jason, jemalloc guys.
> 
> A couple of things...
> 
> There's a massive and complex reject storm against Kirill's page-flags
> and thp changes.  The problems in hugetlb.c are more than I can
> reasonably fix up, sorry.  How would you feel about redoing the patches
> against next -mm?

No problem at all.

> 
> Secondly, "mm: introduce lazyfree LRU list" and "mm: support MADV_FREE
> on swapless system" are new, and require significant reviewer
> attention.  But there's so much other stuff flying around that I doubt
> if we'll get effective review.  So perhaps it would be best to shelve
> those new things and introduce them later, after the basic old
> MADV_FREE work has settled in?
> 

That's really what we(Daniel, Michael and me) want so far.
A people who is reluctant to it is Johannes who wanted to support
MADV_FREE on swapless system via new LRU from the beginning.

If Johannes is not strong against Andrew's plan, I will resend
new patchset(ie, not including new stuff) based on next -mmotm.

Hannes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
