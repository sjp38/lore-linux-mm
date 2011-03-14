Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 89A698D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:16:56 -0400 (EDT)
Received: by yib2 with SMTP id 2so2752267yib.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 08:16:54 -0700 (PDT)
Date: Tue, 15 Mar 2011 00:16:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v6 6/9] memcg: add cgroupfs interface to memcg dirty
 limits
Message-ID: <20110314151630.GG11699@barrios-desktop>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-7-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299869011-26152-7-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Mar 11, 2011 at 10:43:28AM -0800, Greg Thelen wrote:
> Add cgroupfs interface to memcg dirty page limits:
>   Direct write-out is controlled with:
>   - memory.dirty_ratio
>   - memory.dirty_limit_in_bytes
> 
>   Background write-out is controlled with:
>   - memory.dirty_background_ratio
>   - memory.dirty_background_limit_bytes
> 
> Other memcg cgroupfs files support 'M', 'm', 'k', 'K', 'g'
> and 'G' suffixes for byte counts.  This patch provides the
> same functionality for memory.dirty_limit_in_bytes and
> memory.dirty_background_limit_bytes.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
