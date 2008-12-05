Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB5KguwM016864
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:42:56 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB5Khe0G226512
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:43:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB5KhdqP010848
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:43:39 -0700
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1228482500.8392.15.camel@t60p>
References: <1228339524.6598.11.camel@t60p>
	 <1228342567.13111.11.camel@nimitz>  <1228482500.8392.15.camel@t60p>
Content-Type: text/plain
Date: Fri, 05 Dec 2008 12:43:38 -0800
Message-Id: <1228509818.12681.21.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-05 at 14:08 +0100, Gerald Schaefer wrote:
> 
> As explained above, the per-cpu pagevec layout should be independent
> from NUMA or UNEVICTABLE_LRU, so I guess the right thing to do here
> is completely remove the #ifdef as in the patch from Kosaki Motohiro
> (or at least replace it with a CONFIG_SMP as suggested by Kamezawa
> Hiroyuki).

Thanks for looking into it deeper.  That CONFIG_SMP thing really does
look like the right solution.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
