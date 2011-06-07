Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 466FF6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 03:34:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 848F83EE0B6
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:34:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6489B45DE6A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:34:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B26445DE67
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:34:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 399F51DB803E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:34:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D96D01DB803B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:34:29 +0900 (JST)
Date: Tue, 7 Jun 2011 16:27:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 03/12] memcg: add mem_cgroup_mark_inode_dirty()
Message-Id: <20110607162710.0913759e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1307117538-14317-4-git-send-email-gthelen@google.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
	<1307117538-14317-4-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri,  3 Jun 2011 09:12:09 -0700
Greg Thelen <gthelen@google.com> wrote:

> Create the mem_cgroup_mark_inode_dirty() routine, which is called when
> an inode is marked dirty.  In kernels without memcg, this is an inline
> no-op.
> 
> Add i_memcg field to struct address_space.  When an inode is marked
> dirty with mem_cgroup_mark_inode_dirty(), the css_id of current memcg is
> recorded in i_memcg.  Per-memcg writeback (introduced in a latter
> change) uses this field to isolate inodes associated with a particular
> memcg.
> 
> The type of i_memcg is an 'unsigned short' because it stores the css_id
> of the memcg.  Using a struct mem_cgroup pointer would be larger and
> also create a reference on the memcg which would hang memcg rmdir
> deletion.  Usage of a css_id is not a reference so cgroup deletion is
> not affected.  The memcg can be deleted without cleaning up the i_memcg
> field.  When a memcg is deleted its pages are recharged to the cgroup
> parent, and the related inode(s) are marked as shared thus
> disassociating the inodes from the deleted cgroup.
> 
> A mem_cgroup_mark_inode_dirty() tracepoint is also included to allow for
> easier understanding of memcg writeback operation.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
