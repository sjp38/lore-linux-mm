Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 704E96B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:01:40 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id 123so60552368wmz.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:01:40 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 8si27696739wjx.165.2016.01.25.03.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 03:01:39 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id r129so59016213wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:01:39 -0800 (PST)
Date: Mon, 25 Jan 2016 13:01:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM ATTEND] Huge Page Futures
Message-ID: <20160125110137.GB11541@node.shutemov.name>
References: <56A580F8.4060301@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A580F8.4060301@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun, Jan 24, 2016 at 05:57:12PM -0800, Mike Kravetz wrote:
> In a search of the archives, it appears huge page support in one form or
> another has been a discussion topic in almost every LSF/MM gathering. Based
> on patches submitted this past year, huge pages is still an area of active
> development.  And, it appears this level of activity will  continue in the
> coming year.
> 
> I propose a "Huge Page Futures" session to discuss large works in progress
> as well as work people are considering for 2016.  Areas of discussion would
> minimally include:
> 
> - Krill Shutemov's THP new refcounting code and the push for huge page
>   support in the page cache.

s/Krill/Kirill/ :]

I work on huge pages in tmpfs first and will look on huge pages for real
filesystems later.

> 
> - Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
>   more interesting is the desire for supporting PUD pages.  This seems to
>   beg the question of supporting transparent PUD pages elsewhere.
> 
> - Other suggestions?
> 
> My interest in attending also revolves around huge pages.  This past year
> I have added functionality to hugetlbfs.  hugetlbfs is not dead, and is
> very much in use by some DB implementations.  Proposed future work I will
> be attempting includes:
> - Adding userfaultfd support to hugetlbfs
> - Adding shared page table (PMD) support to DAX much like that which exists
>   for hugetlbfs

Shared page tables for hugetlbfs is rather ugly hack.

Do you have any thoughts how it's going to be implemented? It would be
nice to have some design overview or better proof-of-concept patch before
the summit to be able analyze implications for the kernel.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
