Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id AA7A882F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 22:40:26 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so73217047pab.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 19:40:26 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id z4si6792690par.49.2015.11.04.19.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 19:40:25 -0800 (PST)
Received: by padda3 with SMTP id da3so9126763pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 19:40:25 -0800 (PST)
Date: Thu, 5 Nov 2015 12:41:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151105034120.GA502@swordfish>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <20151104021624.GA2476@swordfish>
 <20151104233910.GA7357@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151104233910.GA7357@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

Hi Minchan,

On (11/05/15 08:39), Minchan Kim wrote:
[..]
> > 
> > I think it makes sense to update pmd_trans_unstable() and
> > pmd_none_or_trans_huge_or_clear_bad() comments in asm-generic/pgtable.h
> > Because they explicitly mention MADV_DONTNEED only. Just a thought.
> 
> Hmm, When I read comments(but actually I don't understand it 100%), it
> says pmd disappearing from MADV_DONTNEED with mmap_sem read-side
> lock. But MADV_FREE doesn't remove the pmd. So, I don't understand
> what I should add comment. Please suggest if I am missing something.
> 

Hm, sorry, I need to think about it more, probably my comment is irrelevant.
Was fantasizing some stupid use cases like doing MADV_DONTNEED and MADV_FREE
on overlapping addresses from different threads, processes that share mem, etc.

> > > @@ -379,6 +502,14 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> > >  		return madvise_remove(vma, prev, start, end);
> > >  	case MADV_WILLNEED:
> > >  		return madvise_willneed(vma, prev, start, end);
> > > +	case MADV_FREE:
> > > +		/*
> > > +		 * XXX: In this implementation, MADV_FREE works like
> > 		  ^^^^
> > 		XXX
> 
> What does it mean?

not much. just a minor note that there is a 'XXX' in "XXX: In this implementation"
comment.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
