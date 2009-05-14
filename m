Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5729F6B0194
	for <linux-mm@kvack.org>; Thu, 14 May 2009 06:58:36 -0400 (EDT)
Date: Thu, 14 May 2009 11:59:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090514105926.GB11770@csn.ul.ie>
References: <bug-13302-10286@http.bugzilla.kernel.org/> <20090513130846.d463cc1e.akpm@linux-foundation.org> <20090514105326.GA11770@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090514105326.GA11770@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 14, 2009 at 11:53:27AM +0100, Mel Gorman wrote:
> On Wed, May 13, 2009 at 01:08:46PM -0700, Andrew Morton wrote:
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > (Please read this ^^^^ !)
> > 
> > On Wed, 13 May 2009 19:54:10 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=13302
> > > 
> > >            Summary: "bad pmd" on fork() of process with hugepage shared
> > >                     memory segments attached
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 2.6.29.1
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: starlight@binnacle.cx
> > >         Regression: Yes
> > > 
> > > 
> > > Kernel reports "bad pmd" errors when process with hugepage
> > > shared memory segments attached executes fork() system call.
> > > Using vfork() avoids the issue.
> > > 
> > > Bug also appears in RHEL5 2.6.18-128.1.6.el5 and causes
> > > leakage of huge pages.
> > > 
> > > Bug does not appear in RHEL4 2.6.9-78.0.13.ELsmp.
> > > 
> > > See bug 12134 for an example of the errors reported
> > > by 'dmesg'.
> > > 
> 
> This seems familiar and I believe it couldn't be reproduced the last time
> and then the problem reporter went away. We need a reproduction case so
> I modified on of the libhugetlbfs tests to do what I think you described
> above. However, it does not trigger the problem for me on x86 or x86-64
> running 2.6.29.1.
> 
> starlight@binnacle.cz, can you try the reproduction steps on your system
> please? If it reproduces, can you send me your .config please? If it
> does not reproduce, can you look at the test program and tell me what
> it's doing different to your reproduction case?
> 

Another question on top of this.

At any point, do you call madvise(MADV_WILLNEED), fadvise(FADV_WILLNEED)
or readahead() on the share memory segment?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
