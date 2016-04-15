Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7206B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 15:15:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so203453454pfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:15:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lq6si5690740pab.140.2016.04.15.12.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 12:15:50 -0700 (PDT)
Date: Fri, 15 Apr 2016 12:15:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 107771] New: Single process tries to use more than 1/2
 physical RAM, OS starts thrashing
Message-Id: <20160415121549.47e404e3263c71564929884e@linux-foundation.org>
In-Reply-To: <bug-107771-27@https.bugzilla.kernel.org/>
References: <bug-107771-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, theosib@gmail.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

This is ... interesting.

On Thu, 12 Nov 2015 18:46:35 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=107771
> 
>             Bug ID: 107771
>            Summary: Single process tries to use more than 1/2 physical
>                     RAM, OS starts thrashing
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.3.0-040300-generic (Ubuntu)
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: theosib@gmail.com
>         Regression: No
> 
> I have a 24-core (48 thread) system with 64GB of RAM.  
> 
> When I run multiple processes, I can use all of physical RAM before swapping
> starts.  However, if I'm running only a *single* process, the system will start
> swapping after I've exceeded only 1/2 of available physical RAM.  Only after
> swap fills does it start using more of the physical RAM.  
> 
> I can't find any ulimit settings or anything else that would cause this to
> happen intentionally. 
> 
> I had originally filed this against Ubuntu, but I'm now running a more recent
> kernel, and the problem persists, so I think it's more appropriate to file
> here.  There are some logs that they had me collect, so if you want to see
> them, the are here:
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1513673
> 
> I don't recall this problem happening with older kernels (whatever came with
> Ubuntu 15.04), although I may just not have noticed.  By swapping early, I'm
> limited by the speed of my SSD, which is moving only about 20MB/sec in each
> direction, and that makes what I'm running take 10 times as long to complete.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
