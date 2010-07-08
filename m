Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 16B7C6B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 17:30:24 -0400 (EDT)
Date: Thu, 8 Jul 2010 14:28:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16348] New: kswapd continuously active when
 doing IO
Message-Id: <20100708142847.375e505e.akpm@linux-foundation.org>
In-Reply-To: <bug-16348-10286@https.bugzilla.kernel.org/>
References: <bug-16348-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: tolzmann@molgen.mpg.de, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 7 Jul 2010 10:58:50 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16348
> 
>            Summary: kswapd continuously active when doing IO
>            Product: IO/Storage
>            Version: 2.5
>     Kernel Version: 2.6.34
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: io_other@kernel-bugs.osdl.org
>         ReportedBy: tolzmann@molgen.mpg.de
>         Regression: Yes
> 
> 
> Hi..
> 
> this bug may be related to #15193 where i attached the issue as a comment.
> since bug #15193 has status RESOLVED PATCH_ALREADY_AVAILABLE and not CLOSED
> CODE_FIX i file the situation as a new bug since the problem still exists for
> us.
> 
> THE ISSUE:
> we are currently having trouble with continuously running kswapds consuming up
> to 100% CPU time when the system is busy doing (heavy) I/O.
> 
> to reproduce (on our machines):  dd if=/dev/zero of=somefile  will activate all
> kswapds when the file reaches the size of the installed memory (our systems
> have 8G up to 256G). (same effect on local reiserfs and local xfs)
> 
> In kernel 2.6.34 (and 2.6.35-rc3) this issue causes the system to become very
> very slow and unresponsive.
> 
> we switched back to 2.6.34-rc6 which seems to have no issues with the same IO.
> 
> what information can i provide to help fixing this issue.
> 

That's odd - there are no changes in mm/vmscan.c between 2.6.34-rc6 and
2.6.34.  Are you sure about those kernel versions?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
