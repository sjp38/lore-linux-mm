Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 18A6A6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 18:03:23 -0400 (EDT)
Date: Fri, 28 Jun 2013 15:03:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] hugetlb: properly account rss
Message-Id: <20130628150321.106fe1e67f0e18a6eb3ca320@linux-foundation.org>
In-Reply-To: <1371581225-27535-2-git-send-email-joern@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
	<1371581225-27535-2-git-send-email-joern@logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joern Engel <joern@logfs.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Jun 2013 14:47:04 -0400 Joern Engel <joern@logfs.org> wrote:

> When moving a program from mmap'ing small pages to mmap'ing huge pages,
> a remarkable drop in rss ensues.  For some reason hugepages were never
> accounted for in rss, which in my book is a clear bug.  Sadly this bug
> has been present in hugetlbfs since it was merged back in 2002.  There
> is every chance existing programs depend on hugepages not being counted
> as rss.
> 
> I think the correct solution is to fix the bug and wait for someone to
> complain.  It is just as likely that noone cares - as evidenced by the
> fact that noone seems to have noticed for ten years.
> 

Yes, that is a concern.  I'll toss it in there so we can see what
happens, but I fear that any problems will take a long time to be
discovered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
