Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA18261
	for <linux-mm@kvack.org>; Sat, 1 Feb 2003 01:31:26 -0800 (PST)
Date: Sat, 1 Feb 2003 01:31:36 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030201013136.312a946d.akpm@digeo.com>
In-Reply-To: <20030201095848.C789@nightmaster.csn.tu-chemnitz.de>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030131151858.6e9cc35e.akpm@digeo.com>
	<20030201095848.C789@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de> wrote:
>
> Hi Andrew,
> 
> On Fri, Jan 31, 2003 at 03:18:58PM -0800, Andrew Morton wrote:
> > Also, don't mark hugepages as all PageReserved any more.  That's preenting
> > callers from doing proper refcounting.  Any code which does a user pagetable
> > walk and hits part of a hugepage will now handle it transparently.
> 
> Heh, that's helping me a lot and makes get_one_user_page very
> simple again (and simplify the follow_huge_* stuff even more).
> 
> This could help futex slow-path and remove loads of code.
> 
> Once this hugetlb stuff settles down a bit, I'll rewrite the
> page-walking again to accomodate this. No API changes, just
> internal rewrites.

OK...

> So please tell the linux-mm list, when it's finished and I'll have
> sth. ready for -mm in the first week of March[1].

Well I'm thinking of renaming it to hugebugfs.  It should be settled down
shortly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
