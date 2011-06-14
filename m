Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0F2766B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:44:48 -0400 (EDT)
Date: Tue, 14 Jun 2011 11:44:39 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [BUGFIX][PATCH 2/5] memcg: fix init_page_cgroup nid with
 sparsemem
Message-ID: <20110614094439.GB6371@redhat.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
 <20110613120608.d5243bc9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110613120608.d5243bc9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Mon, Jun 13, 2011 at 12:06:08PM +0900, KAMEZAWA Hiroyuki wrote:
> added some clean ups.
> ==
> >From 45b8881201f73015c4e0352eb7e434f6e9c53fdd Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 13 Jun 2011 10:09:17 +0900
> Subject: [PATCH 2/5] [BUGFIX] memcg: fix init_page_cgroup nid with sparsemem
> 
> 
> commit 21a3c96 makes page_cgroup allocation as NUMA aware. But that caused
> a problem https://bugzilla.kernel.org/show_bug.cgi?id=36192.
> 
> The problem was getting a NID from invalid struct pages, which was not
> initialized because it was out-of-node, out of [node_start_pfn, node_end_pfn)
> 
> Now, with sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.
> But this may scan a pfn which is not on any node and can access
> memmap which is not initialized.
> 
> This makes page_cgroup_init() for SPARSEMEM node aware and remove
> a code to get nid from page->flags. (Then, we'll use valid NID
> always.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
