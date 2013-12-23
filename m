Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id AE9FE6B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 05:54:35 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so5174186pbb.0
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 02:54:35 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id e8si12216643pac.111.2013.12.23.02.54.33
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 02:54:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131223102524.GE11295@suse.de>
References: <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
 <20131216205244.GG21218@redhat.com>
 <20131220131003.93C9AE0090@blue.fi.intel.com>
 <20131220133619.4980AE0090@blue.fi.intel.com>
 <20131220174210.GB727@redhat.com>
 <20131223102524.GE11295@suse.de>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Content-Transfer-Encoding: 7bit
Message-Id: <20131223105429.CDCC9E0090@blue.fi.intel.com>
Date: Mon, 23 Dec 2013 12:54:29 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Mel Gorman wrote:
> On Fri, Dec 20, 2013 at 06:42:10PM +0100, Andrea Arcangeli wrote:
> > The reason for not doing this was that it felt slow to have that kind
> > of mangling in a fast path bad check. But maybe it's no problem to do
> > it. The above should also avoid the bug.
> > 
> 
> If this bug is related to mprotect then it should also have been fixed
> indirectly by commit 1667918b ("mm: numa: clear numa hinting information
> on mprotect") although for the wrong reasons. Applying cleanly requires
> 
>  mm: clear pmd_numa before invalidating
>  mm: numa: do not clear PMD during PTE update scan
>  mm: numa: do not clear PTE for pte_numa update
>  mm: numa: clear numa hinting information on mprotect
> 
> Is this bug reproducible in 3.13-rc5?

No. At least with my test case.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
