Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 12EBB6B02A7
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 05:04:05 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5635117pbb.14
        for <linux-mm@kvack.org>; Sat, 23 Jun 2012 02:04:05 -0700 (PDT)
Date: Sat, 23 Jun 2012 17:03:39 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH 1/6] memcg: replace unsigned long by u64 to avoid overflow
Message-ID: <20120623090339.GA6184@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1340432134-5178-1-git-send-email-liwp.linux@gmail.com>
 <20120623081514.GJ27816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120623081514.GJ27816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Sat, Jun 23, 2012 at 10:15:14AM +0200, Johannes Weiner wrote:
>On Sat, Jun 23, 2012 at 02:15:34PM +0800, Wanpeng Li wrote:
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Since the return value variable in mem_cgroup_zone_nr_lru_pages and
>> mem_cgroup_node_nr_lru_pages functions are u64, so replace the return
>> value of funtions by u64 to avoid overflow.
>
>I wonder what 16 TB of memory must think running on a 32-bit kernel...
>"What is this, an address space for ants?"

Hi Johannes,

You mean change all u64 in memcg to unsigned long? or something I
miss....

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
