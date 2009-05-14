Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 792A26B0163
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:27:27 -0400 (EDT)
Received: by bwz21 with SMTP id 21so1271548bwz.38
        for <linux-mm@kvack.org>; Wed, 13 May 2009 19:27:51 -0700 (PDT)
Date: Thu, 14 May 2009 11:27:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: =?UTF-8?B?W1BBVENI44CAMS8yXQ==?= remove CONFIG_UNEVICTABLE_LRU
 config option
Message-Id: <20090514112731.8b0c1458.minchan.kim@barrios-desktop>
In-Reply-To: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
References: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009 11:05:35 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU config option
> 
> Currently, nobody want to turn UNEVICTABLE_LRU off. Thus
> this configurability is unnecessary.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Minchan kim <minchan.kim@gmail.com>

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
