Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB726B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 06:16:03 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ld10so5184151pab.25
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 03:16:03 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wm3si12243001pab.136.2013.12.23.03.16.01
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 03:16:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131223105429.CDCC9E0090@blue.fi.intel.com>
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
 <20131223105429.CDCC9E0090@blue.fi.intel.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Content-Transfer-Encoding: 7bit
Message-Id: <20131223111557.3B0D7E0090@blue.fi.intel.com>
Date: Mon, 23 Dec 2013 13:15:57 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Kirill A. Shutemov wrote:
> Mel Gorman wrote:
> > On Fri, Dec 20, 2013 at 06:42:10PM +0100, Andrea Arcangeli wrote:
> > > The reason for not doing this was that it felt slow to have that kind
> > > of mangling in a fast path bad check. But maybe it's no problem to do
> > > it. The above should also avoid the bug.
> > > 
> > 
> > If this bug is related to mprotect then it should also have been fixed
> > indirectly by commit 1667918b ("mm: numa: clear numa hinting information
> > on mprotect") although for the wrong reasons. Applying cleanly requires
> > 
> >  mm: clear pmd_numa before invalidating
> >  mm: numa: do not clear PMD during PTE update scan
> >  mm: numa: do not clear PTE for pte_numa update
> >  mm: numa: clear numa hinting information on mprotect
> > 
> > Is this bug reproducible in 3.13-rc5?
> 
> No. At least with my test case.

Oh. Linus has applied the patch to -rc5.

With patch reverted the bug is reproducible.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
