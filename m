Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id E89416B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 03:54:28 -0500 (EST)
Date: Mon, 20 Feb 2012 09:54:20 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] memcg: remove
 EXPORT_SYMBOL(mem_cgroup_update_page_stat)
Message-ID: <20120220085420.GA1677@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
 <20120217182535.6a17ec72.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217182535.6a17ec72.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, Feb 17, 2012 at 06:25:35PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 7075e575cc6ee383f8fd161ba44c44a60c295d5f Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 12:05:41 +0900
> Subject: [PATCH 1/6] memcg: remove EXPORT_SYMBOL(mem_cgroup_update_page_stat)
> 
> >From the log, I guess EXPORT was for preparing dirty accounting.
> But _now_, we don't need to export this. Remove this for now.
> 
> Reviewed-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
