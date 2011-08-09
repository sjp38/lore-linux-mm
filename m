Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 950C86B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 21:23:33 -0400 (EDT)
Subject: Re: [PATCH 2/2] vmscan: activate executable pages after first usage
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110808110659.31053.92935.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
	 <20110808110659.31053.92935.stgit@localhost6>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Aug 2011 09:23:29 +0800
Message-ID: <1312853009.27321.3.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 2011-08-08 at 19:07 +0800, Konstantin Khlebnikov wrote:
> Logic added in commit v2.6.30-5507-g8cab475
> (vmscan: make mapped executable pages the first class citizen)
> was noticeably weakened in commit v2.6.33-5448-g6457474
> (vmscan: detect mapped file pages used only once)
> 
> Currently these pages can become "first class citizens" only after second usage.
> 
> After this patch page_check_references() will activate they after first usage,
> and executable code gets yet better chance to stay in memory.
> 
> TODO:
> run some cool tests like in v2.6.30-5507-g8cab475 =)
I used to post a similar patch here:
http://marc.info/?l=linux-mm&m=128572906801887&w=2
but running Fengguang's test doesn't show improvement. And actually the
VM_EXEC protect in shrink_active_list() doesn't show improvement too in
my run, I'm wondering if we should remove it. I guess the (vmscan:
detect mapped file pages used only once) patch makes VM_EXEC protect
lose its effect. It's great if you can show solid data.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
