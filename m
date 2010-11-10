Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 03B8B6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:01:17 -0500 (EST)
Received: by qyk5 with SMTP id 5so2467839qyk.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 17:01:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-6-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-6-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 10:01:14 +0900
Message-ID: <AANLkTin9rfeipUsy1GaT1suP+ivES-cK5U2o26i4hCtE@mail.gmail.com>
Subject: Re: [PATCH 5/6] memcg: simplify mem_cgroup_dirty_info()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> Because mem_cgroup_page_stat() no longer returns negative numbers

I tried to understand why mem_cgroup_page_stat doesn't return negative
number any more for a while.
I couldn't find answer by current patches 5/6.
The answer is where 6/6.
It would be better to change 6/6 with 5/6.


> to indicate failure, mem_cgroup_dirty_info() does not need to check
> for such failures.
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
