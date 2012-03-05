Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AD17F6B0092
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 15:07:42 -0500 (EST)
Message-ID: <4F551CB6.5010209@redhat.com>
Date: Mon, 05 Mar 2012 15:06:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use global_dirty_limit in throttle_vm_writeout()
References: <20120302061451.GA6468@localhost>
In-Reply-To: <20120302061451.GA6468@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/02/2012 01:14 AM, Fengguang Wu wrote:
> When starting a memory hog task, a desktop box w/o swap is found to go
> unresponsive for a long time. It's solely caused by lots of congestion
> waits in throttle_vm_writeout():
>
>   gnome-system-mo-4201 553.073384: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>   gnome-system-mo-4201 553.073386: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
>             gtali-4237 553.080377: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>             gtali-4237 553.080378: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
>              Xorg-3483 553.103375: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>              Xorg-3483 553.103377: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
>
> The root cause is, the dirty threshold is knocked down a lot by the
> memory hog task. Fixed by using global_dirty_limit which decreases
> gradually on such events and can guarantee we stay above (the also
> decreasing) nr_dirty in the progress of following down to the new
> dirty threshold.
>
> Signed-off-by: Fengguang Wu<fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
