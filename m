Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E588B6B005A
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 18:40:53 -0400 (EDT)
Received: by gxk12 with SMTP id 12so3101207gxk.4
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 15:40:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
References: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
Date: Sat, 29 Aug 2009 07:40:56 +0900
Message-ID: <28c262360908281540u3336418ev599d4a4b8fbe19d7@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure: remove CONFIG_UNEVICTABLE_LRU config
	option
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 4:09 AM, Vincent Li<macli@brc.ubc.ca> wrote:
> Commit 683776596 (remove CONFIG_UNEVICTABLE_LRU config option) removed this config option.
> Removed it from mm/memory-failure too.
>
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
