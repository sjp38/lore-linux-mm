Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 575998D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 12:10:04 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v4 11/11] memcg: check memcg dirty limits in page writeback
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-12-git-send-email-gthelen@google.com>
	<20101029164835.06eef3cf.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 29 Oct 2010 09:06:33 -0700
In-Reply-To: <20101029164835.06eef3cf.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Fri, 29 Oct 2010 16:48:35 +0900")
Message-ID: <xr93eib9nfue.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Fri, 29 Oct 2010 00:09:14 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> If the current process is in a non-root memcg, then
>> balance_dirty_pages() will consider the memcg dirty limits
>> as well as the system-wide limits.  This allows different
>> cgroups to have distinct dirty limits which trigger direct
>> and background writeback at different levels.
>> 
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Ideally, I think some comments in the code for "why we need double-check system's
> dirty limit and memcg's dirty limit" will be appreciated.

I will add to the balance_dirty_pages() comment.  It will read:
/*
 * balance_dirty_pages() must be called by processes which are generating dirty
 * data.  It looks at the number of dirty pages in the machine and will force
 * the caller to perform writeback if the system is over `vm_dirty_ratio'.
 * If we're over `background_thresh' then the writeback threads are woken to
 * perform some writeout.  The current task may have per-memcg dirty
 * limits, which are also checked.
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
