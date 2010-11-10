Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 250FD6B0085
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:04:32 -0500 (EST)
Received: by vws18 with SMTP id 18so2692vws.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 17:04:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-7-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-7-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 10:04:29 +0900
Message-ID: <AANLkTi=fZq_+DiD+E__KhgTQz86eTrALGE9M7twX3hgB@mail.gmail.com>
Subject: Re: [PATCH 6/6] memcg: make mem_cgroup_page_stat() return value unsigned
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> mem_cgroup_page_stat() used to return a negative page count
> value to indicate value.
>
> mem_cgroup_page_stat() has changed so it never returns
> error so convert the return value to the traditional page
> count type (unsigned long).
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

It seems to be late review. Just 1 day.
I don't know why Andrew merge it in a hurry without any review.
Anyway, I add my Reviewed-by in this series since my eyes can't find
any big bug.

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
