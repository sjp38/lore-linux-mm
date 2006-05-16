Message-ID: <446934E3.5020204@yahoo.com.au>
Date: Tue, 16 May 2006 12:11:47 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] Have ia64 use add_active_range() and free_area_init_nodes
References: <20060508141030.26912.93090.sendpatchset@skynet>	<20060508141211.26912.48278.sendpatchset@skynet>	<20060514203158.216a966e.akpm@osdl.org>	<44683A09.2060404@shadowen.org>	<44685123.7040501@yahoo.com.au>	<446855AF.1090100@shadowen.org>	<20060515192918.c3e2e895.kamezawa.hiroyu@jp.fujitsu.com>	<44691D7C.5060208@yahoo.com.au> <20060516103415.ad964bdf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060516103415.ad964bdf.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: apw@shadowen.org, akpm@osdl.org, mel@csn.ul.ie, davej@codemonkey.org.uk, tony.luck@intel.com, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

>
>Andy's page_zone(page) == page_zone(buddy) check is good, I think.
>
>Making alignment is a difficult problem, I think. It complecates many things.
>We can avoid above check only when memory layout is ideal.
>
>BTW, How about following patch ?
>I don't want to  say "Oh, you have to re-compile your kernel with 
>CONFIG_UNALIGNED_ZONE on your new machine. you are unlucky." to users.
>

No, this is a function of the architecture code, not the specific
machine it is running on.

So if the architecture ensures alignment and no holes, then they don't
need the overhead of CONFIG_UNALIGNED_ZONE or CONFIG_HOLES_IN_ZONE.

If they do not ensure correct alignment, then they must enable
CONFIG_UNALIGNED_ZONE, even if there may be actual systems which do
result in aligned zones.
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
