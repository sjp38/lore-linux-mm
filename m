Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 729E66B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 19:30:09 -0400 (EDT)
Received: by ewy12 with SMTP id 12so4861701ewy.24
        for <linux-mm@kvack.org>; Mon, 31 Aug 2009 16:30:08 -0700 (PDT)
Date: Tue, 1 Sep 2009 08:29:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090901082926.61872690.minchan.kim@barrios-desktop>
In-Reply-To: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
References: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 31 Aug 2009 15:54:01 -0700
Vincent Li <macli@brc.ubc.ca> wrote:

> commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> sc->isolate_pages() return value properly. Add similar proper return value check for
> shrink_active_list() sc->isolate_pages().
> 
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

You should have write down your patch's effect clearly
in changelog although it's easy. ;-)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
