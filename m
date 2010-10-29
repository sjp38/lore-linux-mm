Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 154286B0146
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:27:15 -0400 (EDT)
Date: Fri, 29 Oct 2010 13:19:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 02/11] memcg: document cgroup dirty memory interfaces
Message-Id: <20101029131952.1191023d.akpm@linux-foundation.org>
In-Reply-To: <1288336154-23256-3-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-3-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 00:09:05 -0700
Greg Thelen <gthelen@google.com> wrote:

> Document cgroup dirty memory interfaces and statistics.
> 
>
> ...
>
> +When use_hierarchy=0, each cgroup has dirty memory usage and limits.
> +System-wide dirty limits are also consulted.  Dirty memory consumption is
> +checked against both system-wide and per-cgroup dirty limits.
> +
> +The current implementation does enforce per-cgroup dirty limits when

"does not", I trust.

> +use_hierarchy=1.  System-wide dirty limits are used for processes in such
> +cgroups.  Attempts to read memory.dirty_* files return the system-wide values.
> +Writes to the memory.dirty_* files return error.  An enhanced implementation is
> +needed to check the chain of parents to ensure that no dirty limit is exceeded.
> +
>  6. Hierarchy support
>  
>  The memory controller supports a deep hierarchy and hierarchical accounting.
> -- 
> 1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
