Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E67976B00AA
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 18:46:00 -0500 (EST)
Date: Tue, 9 Nov 2010 00:45:34 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/4] memcg: use native word page statistics counters
Message-ID: <20101108234533.GN23393@cmpxchg.org>
References: <20101107215030.007259800@cmpxchg.org>
 <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
 <20101106010357.GD23393@cmpxchg.org>
 <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
 <20101107215030.007259800@cmpxchg.org>
 <20101107220353.964566018@cmpxchg.org>
 <xr93vd478kgx.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93vd478kgx.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2010 at 03:27:26PM -0800, Greg Thelen wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -157,7 +157,7 @@ static inline void mem_cgroup_dec_page_s
> >  bool mem_cgroup_has_dirty_limit(void);
> >  bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
> >  			   struct dirty_info *info);
> > -s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
> > +long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
> 
> Ooops.  I missed something in my review.
> 
> mem_cgroup_page_stat() appears twice in memcontrol.h The return value
> should match regardless of if CONFIG_CGROUP_MEM_RES_CTLR is set.
> 
> I suggest integrating the following into you patch ([patch 4/4] memcg:
> use native word page statistics counters):

Right you are!  Thanks.

	Hannes

> ---
>  include/linux/memcontrol.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4e046d6..7a3d915 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -351,7 +351,7 @@ static inline bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
>         return false;
>  }
>  
> -static inline s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
> +static inline long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
>  {
>         return -ENOSYS;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
