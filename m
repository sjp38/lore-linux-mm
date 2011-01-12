Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6B0E06B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 18:04:04 -0500 (EST)
Received: by iyj17 with SMTP id 17so1017407iyj.14
        for <linux-mm@kvack.org>; Wed, 12 Jan 2011 15:03:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1101122135070.22297@swampdragon.chaosbits.net>
Date: Thu, 13 Jan 2011 08:03:51 +0900
Message-ID: <AANLkTinqVZhUWqxJEOcC-j5ZPuU7ZVRnqSo_FoQ1DCs6@mail.gmail.com>
Subject: Re: [PATCH] mm: Remove two memset calls in mm/memcontrol.c by using
 the zalloc variants of alloc functions
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 5:39 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> We can avoid two calls to memset() in mm/memcontrol.c by using
> kzalloc_node(), kzalloc & vzalloc().
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
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
