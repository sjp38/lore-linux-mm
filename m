Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 59DAA6B00AF
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 20:28:10 -0500 (EST)
Received: by iwn9 with SMTP id 9so6869444iwn.14
        for <linux-mm@kvack.org>; Mon, 08 Nov 2010 17:28:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289265320-7025-1-git-send-email-gthelen@google.com>
References: <1289265320-7025-1-git-send-email-gthelen@google.com>
Date: Tue, 9 Nov 2010 10:28:08 +0900
Message-ID: <AANLkTikDUkFgZ67tLeB080UhQByOc4yk4xmKTyEkJYq4@mail.gmail.com>
Subject: Re: [PATCH] memcg: avoid overflow in memcg_hierarchical_free_pages()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 10:15 AM, Greg Thelen <gthelen@google.com> wrote:
> Use page counts rather than byte counts to avoid overflowing
> unsigned long local variables.
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
