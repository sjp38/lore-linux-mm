Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6C16B00EA
	for <linux-mm@kvack.org>; Sat,  4 Jun 2011 05:56:40 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1695986pwi.14
        for <linux-mm@kvack.org>; Sat, 04 Jun 2011 02:56:39 -0700 (PDT)
Date: Sat, 4 Jun 2011 18:56:28 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v8 02/12] memcg: add page_cgroup flags for dirty page
 tracking
Message-ID: <20110604095628.GB4731@barrios-laptop>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-3-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307117538-14317-3-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, Jun 03, 2011 at 09:12:08AM -0700, Greg Thelen wrote:
> Add additional flags to page_cgroup to track dirty pages
> within a mem_cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
