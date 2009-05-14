Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 632AD6B01E6
	for <linux-mm@kvack.org>; Thu, 14 May 2009 13:16:50 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090514131432.0575fec8@binnacle.cx>
Date: Thu, 14 May 2009 13:16:24 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
In-Reply-To: <20090514105326.GA11770@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/>
 <20090513130846.d463cc1e.akpm@linux-foundation.org>
 <20090514105326.GA11770@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Will try it out, but it has to wait till this weekend.


At 11:53 AM 5/14/2009 +0100, Mel Gorman wrote:
>starlight@binnacle.cx, can you try the reproduction steps on your system
>please? If it reproduces, can you send me your .config please? If it
>does not reproduce, can you look at the test program and tell me what
>it's doing different to your reproduction case?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
