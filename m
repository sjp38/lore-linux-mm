Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2F4946B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:42:42 -0400 (EDT)
Date: Tue, 14 Jun 2011 11:42:30 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg fix numa_stat permission
Message-ID: <20110614094230.GA6371@redhat.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
 <20110613120301.09daa339.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110613120301.09daa339.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Mon, Jun 13, 2011 at 12:03:01PM +0900, KAMEZAWA Hiroyuki wrote:
> This is already queued in mmotm.
> ==
> >From 3b1bec1d07ba21339697f069acab47dae6b81097 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 13 Jun 2011 09:32:28 +0900
> Subject: [PATCH 1/5] memcg fix numa_stat permission
> 
> commit 406eb0c9b ("memcg: add memory.numastat api for numa statistics")
>  adds memory.numa_stat file for memory cgroup.  But the file permissions
>  are wrong.
> 
> [kamezawa@bluextal linux-2.6]$ ls -l /cgroup/memory/A/memory.numa_stat
> ---------- 1 root root 0 Jun  9 18:36 /cgroup/memory/A/memory.numa_stat
> 
> This patch fixes the permission as
> 
> [root@bluextal kamezawa]# ls -l /cgroup/memory/A/memory.numa_stat
> -r--r--r-- 1 root root 0 Jun 10 16:49 /cgroup/memory/A/memory.numa_stat
> 
> Acked-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
