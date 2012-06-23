Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 19F526B02B2
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 06:13:44 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4086395dak.14
        for <linux-mm@kvack.org>; Sat, 23 Jun 2012 03:13:44 -0700 (PDT)
Date: Sat, 23 Jun 2012 18:13:28 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH 4/6] memcg: move recent_rotated and recent_scanned
 informations
Message-ID: <20120623101328.GA2153@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1340432259-5317-1-git-send-email-liwp.linux@gmail.com>
 <20120623095112.GO27816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120623095112.GO27816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

On Sat, Jun 23, 2012 at 11:51:13AM +0200, Johannes Weiner wrote:
>On Sat, Jun 23, 2012 at 02:17:39PM +0800, Wanpeng Li wrote:
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Move recent_rotated and recent_scanned prints next to inactive_anon,
>> ative_anon, inactive_file, active_file, and unevictable prints to
>> save developers' time. Since they have to go a long way(when cat memory.stat)
>> to find recent_rotated and recent_scanned prints which has relationship
>> with the memory cgroup we care. These prints are behind total_* which
>> not just focus on the memory cgroup we care currently.
>
>The hierarchical stats are about that memcg, too.  And I don't want to

Move recent_rotated and recent_scanned prints next to file lru lists
just because the pageout code in vmscan.c keeps track of how many of 
the mem/swap backed and file backed pages are referenced, and the 
higher the rotated/scanned ratio, the more valuable that cache is. 
Move five lru lists and associated debug informations together can 
make things convenience. :-)

Regards,
Wanpeng Li

>turn on debugging and then look for the extra information hiding in
>the middle of regular stats.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
