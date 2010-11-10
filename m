Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 55C716B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:51:28 -0500 (EST)
Received: by iwn9 with SMTP id 9so94783iwn.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 16:51:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-2-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-2-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 09:51:23 +0900
Message-ID: <AANLkTikteK-3gVghEu7egfUH+Ngfm1e7aQMyz1KBZ0nT@mail.gmail.com>
Subject: Re: [PATCH 1/6] memcg: add mem_cgroup parameter to mem_cgroup_page_stat()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> This new parameter can be used to query dirty memory usage
> from a given memcg rather than the current task's memcg.
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
