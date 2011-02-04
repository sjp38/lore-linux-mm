Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0B58D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 23:10:06 -0500 (EST)
Received: by pxi12 with SMTP id 12so401594pxi.14
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 20:10:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110203125453.GB2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
	<20110201000455.GB19534@cmpxchg.org>
	<20110131162448.e791f0ae.akpm@linux-foundation.org>
	<20110203125357.GA2286@cmpxchg.org>
	<20110203125453.GB2286@cmpxchg.org>
Date: Fri, 4 Feb 2011 09:40:04 +0530
Message-ID: <AANLkTi=Rex6rGYgBwnmnV66oZ_Vs21FOvjU-v=h0g6ZH@mail.gmail.com>
Subject: Re: [patch 1/2] memcg: soft limit reclaim should end at limit not below
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 3, 2011 at 6:24 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Soft limit reclaim continues until the usage is below the current soft
> limit, but the documented semantics are actually that soft limit
> reclaim will push usage back until the soft limits are met again.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
