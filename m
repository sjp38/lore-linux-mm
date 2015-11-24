Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B4D756B0258
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:58:54 -0500 (EST)
Received: by wmec201 with SMTP id c201so230013477wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:58:54 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i1si29858154wjq.10.2015.11.24.13.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:58:53 -0800 (PST)
Date: Tue, 24 Nov 2015 13:58:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/16] MADV_FREE support
Message-Id: <20151124135851.bd50e261e30ed4e178baaef9@linux-foundation.org>
In-Reply-To: <1448006568-16031-1-git-send-email-minchan@kernel.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

On Fri, 20 Nov 2015 17:02:32 +0900 Minchan Kim <minchan@kernel.org> wrote:

> I have been spent a lot of time to land MADV_FREE feature
> by request of userland people(esp, Daniel and Jason, jemalloc guys.

A couple of things...

There's a massive and complex reject storm against Kirill's page-flags
and thp changes.  The problems in hugetlb.c are more than I can
reasonably fix up, sorry.  How would you feel about redoing the patches
against next -mm?

Secondly, "mm: introduce lazyfree LRU list" and "mm: support MADV_FREE
on swapless system" are new, and require significant reviewer
attention.  But there's so much other stuff flying around that I doubt
if we'll get effective review.  So perhaps it would be best to shelve
those new things and introduce them later, after the basic old
MADV_FREE work has settled in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
