Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B2B16B0164
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:29:29 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 26so397007eyw.44
        for <linux-mm@kvack.org>; Wed, 13 May 2009 19:29:53 -0700 (PDT)
Date: Thu, 14 May 2009 11:29:39 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/2] remove CONFIG_UNEVICTABLE_LRU definition from
 defconfig
Message-Id: <20090514112939.ca23d021.minchan.kim@barrios-desktop>
In-Reply-To: <20090514111519.9B5D.A69D9226@jp.fujitsu.com>
References: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
	<20090514111519.9B5D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009 11:15:49 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU definition from defconfig
> 
> Now, There isn't CONFIG_UNEVICTABLE_LRU. these line are unnecessary.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Minchan Kim <minchan.kim@gmail.com>

Thanks for your lots or effort. :)

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
