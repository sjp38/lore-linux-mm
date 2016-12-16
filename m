Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 200336B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:36:19 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id j10so33607820wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:36:19 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id gk8si6396686wjb.257.2016.12.16.02.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 02:36:18 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so13855456wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:36:17 -0800 (PST)
Date: Fri, 16 Dec 2016 11:36:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
Message-ID: <20161216103615.GF13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216095624.GR3107@twins.programming.kicks-ass.net>
 <20161216101915.GC27758@node>
 <a2215cbb-36dd-8cc5-9238-d3bca0170ef4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2215cbb-36dd-8cc5-9238-d3bca0170ef4@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 11:20:40, Vegard Nossum wrote:
> On 12/16/2016 11:19 AM, Kirill A. Shutemov wrote:
> > On Fri, Dec 16, 2016 at 10:56:24AM +0100, Peter Zijlstra wrote:
> > > But I must say mmget() vs mmgrab() is a wee bit confusing.
> > 
> > mm_count vs mm_users is not very clear too. :)
> > 
> 
> I was about to say, I'm not sure it's much better than mmput() vs
> mmdrop() or mm_users vs mm_count either, although the way I rationalised
> it was the 3 vs 4 letters:
> 
> mmget() -- mmgrab()
> mmput() -- mmdrop()
>   ^^^ 3      ^^^^ 4

get -> put
grab -> drop

makes sense to me... No idea about a much more clear name.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
