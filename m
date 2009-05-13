Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E311A6B012A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:09:13 -0400 (EDT)
Date: Wed, 13 May 2009 13:08:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
 with hugepage shared memory segments attached
Message-Id: <20090513130846.d463cc1e.akpm@linux-foundation.org>
In-Reply-To: <bug-13302-10286@http.bugzilla.kernel.org/>
References: <bug-13302-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, starlight@binnacle.cx
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

(Please read this ^^^^ !)

On Wed, 13 May 2009 19:54:10 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13302
> 
>            Summary: "bad pmd" on fork() of process with hugepage shared
>                     memory segments attached
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.29.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: starlight@binnacle.cx
>         Regression: Yes
> 
> 
> Kernel reports "bad pmd" errors when process with hugepage
> shared memory segments attached executes fork() system call.
> Using vfork() avoids the issue.
> 
> Bug also appears in RHEL5 2.6.18-128.1.6.el5 and causes
> leakage of huge pages.
> 
> Bug does not appear in RHEL4 2.6.9-78.0.13.ELsmp.
> 
> See bug 12134 for an example of the errors reported
> by 'dmesg'.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
