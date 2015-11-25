Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 402B34402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:36:59 -0500 (EST)
Received: by wmvv187 with SMTP id v187so267994632wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:36:58 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w9si35955303wjf.245.2015.11.25.09.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:36:58 -0800 (PST)
Date: Wed, 25 Nov 2015 12:36:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4 00/16] MADV_FREE support
Message-ID: <20151125173646.GA10156@cmpxchg.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
 <20151124135851.bd50e261e30ed4e178baaef9@linux-foundation.org>
 <20151125025318.GA2678@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125025318.GA2678@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

On Wed, Nov 25, 2015 at 11:53:18AM +0900, Minchan Kim wrote:
> That's really what we(Daniel, Michael and me) want so far.
> A people who is reluctant to it is Johannes who wanted to support
> MADV_FREE on swapless system via new LRU from the beginning.
> 
> If Johannes is not strong against Andrew's plan, I will resend
> new patchset(ie, not including new stuff) based on next -mmotm.
> 
> Hannes?

Yeah, let's shelve the new stuff for now and get this going. As Daniel
said, the feature is already useful, and we can improve it later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
