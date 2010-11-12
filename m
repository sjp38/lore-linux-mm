Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 185668D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 03:29:41 -0500 (EST)
Date: Fri, 12 Nov 2010 09:29:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/6] memcg: make mem_cgroup_page_stat() return value
 unsigned
Message-ID: <20101112082921.GH9131@cmpxchg.org>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
 <1289294671-6865-7-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289294671-6865-7-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 01:24:31AM -0800, Greg Thelen wrote:
> mem_cgroup_page_stat() used to return a negative page count
> value to indicate value.

Whoops :)

> mem_cgroup_page_stat() has changed so it never returns
> error so convert the return value to the traditional page
> count type (unsigned long).

This changelog feels a bit beside the point.

What's really interesting is that we now don't consider negative sums
to be invalid anymore, but just assume zero!  There is a real
semantical change here.

That the return type can then be changed to unsigned long is a nice
follow-up cleanup that happens to be folded into this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
