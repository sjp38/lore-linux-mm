Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 81E816B01EA
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:20:24 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090514131734.05890270@binnacle.cx>
Date: Thu, 14 May 2009 13:20:09 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
In-Reply-To: <20090514105926.GB11770@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/>
 <20090513130846.d463cc1e.akpm@linux-foundation.org>
 <20090514105326.GA11770@csn.ul.ie>
 <20090514105926.GB11770@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Definately no.

The possibly unusual thing done is that a file is read into 
something like 30% of the segment, and the remaining pages are 
not touched.


At 11:59 AM 5/14/2009 +0100, Mel Gorman wrote:
>Another question on top of this.
>
>At any point, do you call madvise(MADV_WILLNEED),
>fadvise(FADV_WILLNEED) or readahead() on the share memory segment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
