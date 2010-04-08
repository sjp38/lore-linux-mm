Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 809256B0216
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 07:53:48 -0400 (EDT)
Message-ID: <4BBDC3A4.1020305@redhat.com>
Date: Thu, 08 Apr 2010 14:53:08 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 37 of 67] transparent hugepage vmstat
References: <patchbomb.1270691443@v2.random> <cfbeacfad8810945ff91.1270691480@v2.random>
In-Reply-To: <cfbeacfad8810945ff91.1270691480@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On 04/08/2010 04:51 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Add hugepage stat information to /proc/vmstat and /proc/meminfo.
>
>
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -101,6 +101,9 @@ static int meminfo_proc_show(struct seq_
>   #ifdef CONFIG_MEMORY_FAILURE
>   		"HardwareCorrupted: %5lu kB\n"
>   #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +		"AnonHugePages:  %8lu kB\n"
> +#endif
>    


The original AnonPages should include AnonHugePages, or applications 
that are unaware of AnonHugePages will see an unexplained drop in AnonPages.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
