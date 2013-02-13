Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id CB8826B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 19:51:09 -0500 (EST)
Date: Tue, 12 Feb 2013 16:51:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
Message-Id: <20130212165107.32be0c33.akpm@linux-foundation.org>
In-Reply-To: <bug-53501-27@https.bugzilla.kernel.org/>
References: <bug-53501-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sworddragon2@aol.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri,  8 Feb 2013 09:39:27 +0000 (UTC)
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=53501
> 
>            Summary: Duplicated MemTotal with different values
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: Ubuntu 3.8.0-4.8-generic 3.8.0-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: sworddragon2@aol.com
>         Regression: No
> 
> 
> The installed memory on my system is 16 GiB. /proc/meminfo is showing me
> "MemTotal:       16435048 kB" but /sys/devices/system/node/node0/meminfo is
> showing me "Node 0 MemTotal:       16776380 kB".
> 
> My suggestion: MemTotal in /proc/meminfo should be 16776380 kB too. The old
> value of 16435048 kB could have its own key "MemAvailable".

hm, mine does that too.  A discrepancy between `totalram_pages' and
NODE_DATA(0)->node_present_pages.

I don't know what the reasons are for that but yes, one would expect
the per-node MemTotals to sum up to the global one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
