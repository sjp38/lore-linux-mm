Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7033F9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 16:54:28 -0400 (EDT)
Date: Mon, 20 Jun 2011 13:53:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 37072] New: Random BUG at
 include/linux/swapops.h:105
Message-Id: <20110620135353.cfe979ae.akpm@linux-foundation.org>
In-Reply-To: <bug-37072-10286@https.bugzilla.kernel.org/>
References: <bug-37072-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, luke-jr+linuxbugs@utopios.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 10 Jun 2011 01:09:48 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=37072
> 
>            Summary: Random BUG at include/linux/swapops.h:105
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: luke-jr+linuxbugs@utopios.org
>         Regression: Yes
> 
> 
> Didn't have a sensible console working apparently... photo of monitor:
> http://www.facebook.com/photo.php?pid=2522123&l=ec1a1e6145&id=1496065002
> 

handle_mm_fault
->handle_pte_fault
  ->do_swap_page
    ->migration_entry_wait
      ->migration_entry_to_page
        ->BUG_ON(!PageLocked(p))

How is this supposed to ever work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
