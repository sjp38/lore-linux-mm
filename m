Date: Sat, 1 Feb 2003 09:58:48 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: hugepage patches
Message-ID: <20030201095848.C789@nightmaster.csn.tu-chemnitz.de>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030131151858.6e9cc35e.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030131151858.6e9cc35e.akpm@digeo.com>; from akpm@digeo.com on Fri, Jan 31, 2003 at 03:18:58PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Fri, Jan 31, 2003 at 03:18:58PM -0800, Andrew Morton wrote:
> Also, don't mark hugepages as all PageReserved any more.  That's preenting
> callers from doing proper refcounting.  Any code which does a user pagetable
> walk and hits part of a hugepage will now handle it transparently.

Heh, that's helping me a lot and makes get_one_user_page very
simple again (and simplify the follow_huge_* stuff even more).

This could help futex slow-path and remove loads of code.

Once this hugetlb stuff settles down a bit, I'll rewrite the
page-walking again to accomodate this. No API changes, just
internal rewrites.

So please tell the linux-mm list, when it's finished and I'll have
sth. ready for -mm in the first week of March[1].

Regards

Ingo Oeser

[1] Important exams in February, sorry.
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
