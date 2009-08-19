Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A8C156B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 03:15:01 -0400 (EDT)
Received: by gxk12 with SMTP id 12so5869899gxk.4
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 00:14:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819154958.18a34aa5.minchan.kim@barrios-desktop>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	 <4A8B7508.4040001@vflare.org>
	 <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
	 <18eba5a10908182324x45261d06y83e0f042e9ee6b20@mail.gmail.com>
	 <20090819154958.18a34aa5.minchan.kim@barrios-desktop>
Date: Wed, 19 Aug 2009 16:14:05 +0900
Message-ID: <18eba5a10908190014q6f903399y30478b4c0a7f256b@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: Chungki woo <chungki.woo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> You means your pages with 79M are swap out in compcache's reserved
> memory?

Compcache don't have reserved memory.
When it needs memory, and then allocate memory.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
