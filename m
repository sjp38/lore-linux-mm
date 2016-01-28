Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 100696B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 03:49:28 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so19825563pab.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 00:49:28 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id ah10si15493225pad.118.2016.01.28.00.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 00:49:27 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id 65so20249944pfd.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 00:49:27 -0800 (PST)
Date: Thu, 28 Jan 2016 00:49:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
In-Reply-To: <56A90345.3020903@oracle.com>
Message-ID: <alpine.LSU.2.11.1601280022040.4201@eggly.anvils>
References: <56A580F8.4060301@oracle.com> <20160125110137.GB11541@node.shutemov.name> <56A62837.7010105@oracle.com> <56A90345.3020903@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, 27 Jan 2016, Mike Kravetz wrote:
> On 01/25/2016 05:50 AM, Mike Kravetz wrote:
> > On 01/25/2016 03:01 AM, Kirill A. Shutemov wrote:
> >> On Sun, Jan 24, 2016 at 05:57:12PM -0800, Mike Kravetz wrote:
> >>> In a search of the archives, it appears huge page support in one form or
> >>> another has been a discussion topic in almost every LSF/MM gathering. Based
> >>> on patches submitted this past year, huge pages is still an area of active
> >>> development.  And, it appears this level of activity will  continue in the
> >>> coming year.
> >>>
> >>> I propose a "Huge Page Futures" session to discuss large works in progress
> >>> as well as work people are considering for 2016.  Areas of discussion would
> >>> minimally include:
> >>>
> >>> - Krill Shutemov's THP new refcounting code and the push for huge page
> >>>   support in the page cache.
> >>
> >> s/Krill/Kirill/ :]
> > 
> > Sorry!
> > 
> >>
> >> I work on huge pages in tmpfs first and will look on huge pages for real
> >> filesystems later.
> >>
> >>>
> >>> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
> >>>   more interesting is the desire for supporting PUD pages.  This seems to
> >>>   beg the question of supporting transparent PUD pages elsewhere.
> >>>
> >>> - Other suggestions?

I would like to attend LSF/MM 2016, and think I can contribute
to Mike's "Huge Page Futures" topic.  I remain very focussed on my
"huge tmpfs" THP pagecache implementation in tmpfs - which has proved
a success within Google over the last year - but hope that once I'm at
conference, can turn my attention to some of the other mm topics too.


> >>>
> >>> My interest in attending also revolves around huge pages.  This past year
> >>> I have added functionality to hugetlbfs.  hugetlbfs is not dead, and is
> >>> very much in use by some DB implementations.  Proposed future work I will
> >>> be attempting includes:
> >>> - Adding userfaultfd support to hugetlbfs
> >>> - Adding shared page table (PMD) support to DAX much like that which exists
> >>>   for hugetlbfs
> >>
> >> Shared page tables for hugetlbfs is rather ugly hack.
> >>
> >> Do you have any thoughts how it's going to be implemented? It would be
> >> nice to have some design overview or better proof-of-concept patch before
> >> the summit to be able analyze implications for the kernel.
> >>
> > 
> > Good to know the hugetlbfs implementation is considered a hack.  I just
> > started looking at this, and was going to use hugetlbfs as a starting
> > point.  I'll reconsider that decision.
> 
> Kirill, can you (or others) explain your reasons for saying the hugetlbfs
> implementation is an ugly hack?  I do not have enough history/experience
> with this to say what is most offensive.  I would be happy to start by
> cleaning up issues with the current implementation.

I disagree that the hugetlbfs shared pagetables are an ugly hack.
What they are is a dark backwater that very few people are aware of,
which we therefore can very easily break or be broken by.

I have regretted bringing them into mm for that reason, and have
thought that they're next in line for the axe, after those non-linear
vmas which Kirill dispatched without tears last year.  But if you're
intent on making more use of them, exposing them to the light of day
is a fair alternative to consider.

Hugh

> 
> If we do shared page tables for DAX, it makes sense that it and hugetlbfs
> should be similar (or common) if possible.
> 
> -- 
> Mike Kravetz
> 
> > 
> > BTW, this request comes from the same DB people taking advantage of shared
> > page tables today.  This will be as important (if not more) with the larger
> > sizes of pmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
