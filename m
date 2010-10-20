Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AD7266B009D
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 10:35:27 -0400 (EDT)
Received: by pzk7 with SMTP id 7so835694pzk.14
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:35:23 -0700 (PDT)
Date: Wed, 20 Oct 2010 23:35:15 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2][memcg+dirtylimit] Fix  overwriting global vm dirty
 limit setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page
 accounting
Message-ID: <20101020143515.GB5243@barrios-desktop>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
 <20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
 <20101020140255.5b8afb63.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101020140255.5b8afb63.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 02:02:55PM +0900, KAMEZAWA Hiroyuki wrote:
> Fixed one here.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, at calculating dirty limit, vm_dirty_param() is called.
> This function returns dirty-limit related parameters considering
> memory cgroup settings.
> 
> Now, assume that vm_dirty_bytes=100M (global dirty limit) and
> memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
> 500MB.
> 
> In this case, global_dirty_limits will consider dirty_limt as
> 500 *0.4 = 200MB. This is bad...memory cgroup is not back door.
> 
> This patch limits the return value of vm_dirty_param() considring
> global settings.
> 
> Changelog:
>  - fixed an argument "mem" int to u64
>  - fixed to use global available memory to cap memcg's value.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

It should have written this on Documentation.
"memcg dirty limit can't exceed global dirty limit"

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
