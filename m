Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 02A198D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:42:56 -0500 (EST)
Received: by iwn40 with SMTP id 40so6215963iwn.14
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 14:42:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
Date: Tue, 1 Feb 2011 07:42:48 +0900
Message-ID: <AANLkTikdrFYCjYTat+0iLoOJD9S1=KreJhNbFXbzah4x@mail.gmail.com>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge pages
 to near-limit group
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 11:03 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> If reclaim after a failed charging was unsuccessful, the limits are
> checked again, just in case they settled by means of other tasks.
>
> This is all fine as long as every charge is of size PAGE_SIZE, because
> in that case, being below the limit means having at least PAGE_SIZE
> bytes available.
>
> But with transparent huge pages, we may end up in an endless loop
> where charging and reclaim fail, but we keep going because the limits
> are not yet exceeded, although not allowing for a huge page.
>
> Fix this up by explicitely checking for enough room, not just whether
> we are within limits.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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
